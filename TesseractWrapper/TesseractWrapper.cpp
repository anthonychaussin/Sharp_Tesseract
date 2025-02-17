#include "pch.h"
#include "TesseractWrapper.h"
#include <tesseract/baseapi.h>
#include <tesseract/osdetect.h>
#include <leptonica/allheaders.h>
#include <tesseract/renderer.h>
#include <string>
#include <opencv2/core.hpp>
#include <opencv2/imgproc.hpp>
#include <opencv2/imgcodecs.hpp>

using namespace System;
using namespace System::Runtime::InteropServices;

namespace TesseractWrapper
{
    static std::string GlobalStringToString(String^ inputString) {
        IntPtr ptrString = Marshal::StringToHGlobalAnsi(inputString);
        std::string outputString = static_cast<const char*>(ptrString.ToPointer());
        Marshal::FreeHGlobal(ptrString);
        return outputString;
    }

    String^ OCRProcessor::ExtractText(String^ imagePath, String^ lang, String^ tessdataPath, int psmMode, bool withPreTreatment)
    {
        std::string imagePathCpp = GlobalStringToString(imagePath);
        std::string langCpp = GlobalStringToString(lang);
        std::string tessdataPathCpp = GlobalStringToString(tessdataPath);

        tesseract::TessBaseAPI ocr;
        if (ocr.Init(tessdataPathCpp.c_str(), langCpp.c_str()))
        {
            return "Erreur : Impossible d'initialiser Tesseract.";
        }

        ocr.SetPageSegMode((tesseract::PageSegMode)psmMode);

        Pix* image;
        if (withPreTreatment) {
            image = PreprocessImage(imagePath);
        }
        else 
        { 
            image = pixRead(imagePathCpp.c_str());
        }

        if (!image)
        {
            return "Erreur : Impossible de charger l'image.";
        }

        ocr.SetImage(image);
        std::string outputText = ocr.GetUTF8Text();

        pixDestroy(&image);
        ocr.End();

        return gcnew String(outputText.c_str());
    }

    int OCRProcessor::DetectOrientation(String^ imagePath, String^ tessdataPath)
    {
        int orientation[4] = { 0, 270, 180, 90 };
        std::string imagePathCpp = GlobalStringToString(imagePath);
        std::string tessdataPathCpp = GlobalStringToString(tessdataPath);


        tesseract::TessBaseAPI ocr;
        if (ocr.Init(tessdataPathCpp.c_str(), "osd"))
        {
            return -1;
        }

        Pix* image = pixRead(imagePathCpp.c_str());
        if (!image)
        {
            return -1;
        }

        tesseract::OSResults osr;
        ocr.DetectOS(&osr);
        int detectedOr = osr.best_result.orientation_id;

        pixDestroy(&image);
        ocr.End();

        return orientation[detectedOr];
    }

    Pix* OCRProcessor::PreprocessImage(String^ imagePath)
    {
        cv::Mat img = cv::imread(GlobalStringToString(imagePath), cv::IMREAD_GRAYSCALE);
        cv::threshold(img, img, 0, 255, cv::THRESH_BINARY | cv::THRESH_OTSU);

        Pix* processedImg = pixCreate(img.cols, img.rows, 8);
        for (int y = 0; y < img.rows; y++)
        {
            for (int x = 0; x < img.cols; x++)
            {
                pixSetPixel(processedImg, x, y, img.at<uchar>(y, x));
            }
        }

        return processedImg;
    }

    bool OCRProcessor::GenerateOCRPDF(String^ imagePath, String^ outputPdfPath, String^ language, String^ tessdataPath, int psmMode, bool withPreTreatment)
    {
        std::string imagePathCpp = GlobalStringToString(imagePath);
        std::string outputPdfPathCpp = GlobalStringToString(outputPdfPath);
        std::string langCpp = GlobalStringToString(language);
        std::string tessdataPathCpp = GlobalStringToString(tessdataPath);

        tesseract::TessBaseAPI ocr;
        if (ocr.Init(tessdataPathCpp.c_str(), langCpp.c_str()))
        {
            return false;
        }

        ocr.SetPageSegMode((tesseract::PageSegMode)psmMode);

        Pix* image;
        if (withPreTreatment) {
            image = PreprocessImage(imagePath);
        }
        else
        {
            image = pixRead(imagePathCpp.c_str());
        }

        if (!image)
        {
            return "Erreur : Impossible de charger l'image.";
        }

        std::string pdfOutputBase = outputPdfPathCpp.substr(0, outputPdfPathCpp.find_last_of('.'));
        tesseract::TessPDFRenderer pdfRenderer(pdfOutputBase.c_str(), tessdataPathCpp.c_str());

        ocr.SetImage(image);
        ocr.Recognize(0);

        if (!ocr.ProcessPages(imagePathCpp.c_str(), nullptr, 0, &pdfRenderer))
        {
            return false;
        }

        pixDestroy(&image);
        ocr.End();

        return true;
    }
}
