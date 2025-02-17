using TesseractWrapper;

namespace Sharp_Tesseract
{
    public enum TessdataVersion
    {
        Legacy,  // Par défaut, c'est la version classique utilisée par Tesseract
        Fast,
        Best
    }

    public class OCR
    {
        private readonly TessdataVersion _tessdataVersion;
        private static readonly string _baseTessDataUrl = "https://github.com/tesseract-ocr/tessdata_";
        private string tessDataPath;

        private string TessdataFolder
        {
            get
            {
                return GetTessdataFolderName();
            }
        }

        private string TessdataUrlFolder
        {
            get
            {
                return $"{_baseTessDataUrl}_{TessdataFolder}/raw/main";
            }
        }

        private string TessDataPath
        {
            get
            {
                return tessDataPath;
            }
            set
            {
                if (!Directory.Exists(value))
                {
                    Directory.CreateDirectory(value);
                }
                tessDataPath = value;
            }
        }

        public OCR(string? customTessDataPath = null, TessdataVersion tessdataVersion = TessdataVersion.Legacy)
        {
            TessDataPath = customTessDataPath ?? Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "tessdata");
            _tessdataVersion = tessdataVersion;
        }

        /// <summary>
        /// Vérifie si un fichier traineddata existe dans le dossier tessdata.
        /// Si non, il est téléchargé.
        /// </summary>
        private async Task EnsureTessDataExists(string language)
        {
            string[] languages = language.Split('+'); // Support multi-langues
            foreach (var lang in languages)
            {
                string trainedDataPath = Path.Combine(TessDataPath, GetTraindataFileName(lang));

                if (!File.Exists(trainedDataPath))
                {
                    Console.WriteLine($"Le fichier {lang}.traineddata est manquant. Téléchargement en cours...");

                    using (HttpClient client = new())
                    {
                        try
                        {
                            string url = $"{TessdataUrlFolder}/{GetTraindataFileName(lang)}";
                            byte[] data = await client.GetByteArrayAsync(url);
                            await File.WriteAllBytesAsync(trainedDataPath, data);
                            Console.WriteLine($"Téléchargement terminé : {trainedDataPath}");
                        }
                        catch (Exception ex)
                        {
                            Console.WriteLine($"Erreur lors du téléchargement de {GetTraindataFileName(lang)} : {ex.Message}");
                            throw;
                        }
                    }
                }
            }
        }

        /// <summary>
        /// Retourne le nom du fichier tessdata en fonction de la lang
        /// </summary>
        /// <param name="lang"></param>
        /// <returns></returns>
        private static string GetTraindataFileName(string lang)
        {
            return $"{lang}.traineddata";
        }

        /// <summary>
        /// Retourne le bon dossier tessdata en fonction de la version choisie.
        /// </summary>
        private string GetTessdataFolderName()
        {
            return _tessdataVersion switch
            {
                TessdataVersion.Fast => "fast",
                TessdataVersion.Best => "best",
                _ => "legacy"
            };
        }

        /// <summary>
        /// Effectue la reconnaissance de texte en s'assurant que le fichier traineddata est présent.
        /// </summary>
        public async Task<string> ExtractTextAsync(string imagePath, string language = "eng", int psmMode = 3)
        {
            await EnsureTessDataExists(language);
            return OCRProcessor.ExtractText(imagePath, language, TessDataPath, psmMode, false);
        }

        /// <summary>
        /// Génère le fichier pdf avec l'OCR.
        /// </summary>
        public async Task<bool> GenerateOcrPdf(string imagePath, string outputPath, string language = "eng", int psmMode = 3)
        {
            await EnsureTessDataExists(language);
            return OCRProcessor.GenerateOCRPDF(imagePath, outputPath, language, TessDataPath, psmMode, false);
        }

        /// <summary>
        /// Génère le fichier pdf avec l'OCR.
        /// </summary>
        public async Task<string> GetOcrPdf(string imagePath, string language = "eng", int psmMode = 3)
        {
            await EnsureTessDataExists(language);
            var guid = Guid.NewGuid();
            var currentApplicationPath = ""; //TODO retrouver le chemin courant d'application
            var outputPath = Path.Combine(currentApplicationPath, guid + ".pdf");

            if(OCRProcessor.GenerateOCRPDF(imagePath, outputPath, language, TessDataPath, psmMode, false))
            {
                return File.ReadAllText(outputPath);
            } else
            {
                throw new Exception("Erreur ?"); //TODO lever une erreure plus explicite
            }
        }
        //TODO ajouter la possibiliter de detection de l'orientation
        //TODO faire un enum documenter pour l'orientation
        //TODO faire des tests pour trouver la meilleure amélioration d'image possible et surtout voir si le pdf peut être générer sur l'image améliorer, mais l'ocr fait sur l'image optimale
        //TODO ajouter les autres types de sorti et faire en sorte qu'ils soit cummulables. Faire une sorti dossier ? Zip ? (si zip retour stream)
        //TODO ajouter la prise en charge d'un fichier pdf en entré
        //TODO Si le pdf est gros il faut penser à un moyen de streamer le flux pour le pas attendre l'intégraliter de la transformation du pdf pour faire l'ocr
        //TODO ajouter la possibilité de retirer les pages blanches (sans texte ou voir si on peut détecter les pages blanche)

    }
}
