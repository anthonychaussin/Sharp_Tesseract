using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
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
        private string _tessDataPath;
        private readonly TessdataVersion _tessdataVersion;
        private static readonly string _baseTessDataUrl = "https://github.com/tesseract-ocr/tessdata_";


        public OCR(string? customTessDataPath = null, TessdataVersion tessdataVersion = TessdataVersion.Legacy)
        {
            _tessDataPath = customTessDataPath ?? Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "tessdata");
            _tessdataVersion = tessdataVersion;

            if (!Directory.Exists(_tessDataPath))
            {
                Directory.CreateDirectory(_tessDataPath);
            }

        }

        /// <summary>
        /// Vérifie si un fichier traineddata existe dans le dossier tessdata.
        /// Si non, il est téléchargé.
        /// </summary>
        private async Task EnsureTessDataExists(string language)
        {
            string tessdataFolder = GetTessdataFolderName();

            string[] languages = language.Split('+'); // Support multi-langues
            foreach (var lang in languages)
            {
                string trainedDataPath = Path.Combine(_tessDataPath, $"{lang}.traineddata");

                if (!File.Exists(trainedDataPath))
                {
                    Console.WriteLine($"Le fichier {lang}.traineddata est manquant. Téléchargement en cours...");

                    using (HttpClient client = new HttpClient())
                    {
                        try
                        {
                            string url = $"{_baseTessDataUrl}_{tessdataFolder}/raw/main/{lang}.traineddata";
                            byte[] data = await client.GetByteArrayAsync(url);
                            await File.WriteAllBytesAsync(trainedDataPath, data);
                            Console.WriteLine($"Téléchargement terminé : {trainedDataPath}");
                        }
                        catch (Exception ex)
                        {
                            Console.WriteLine($"Erreur lors du téléchargement de {lang}.traineddata : {ex.Message}");
                            throw;
                        }
                    }
                }
            }
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
            return OCRProcessor.ExtractText(imagePath, language, _tessDataPath, psmMode);
        }
    }
}
