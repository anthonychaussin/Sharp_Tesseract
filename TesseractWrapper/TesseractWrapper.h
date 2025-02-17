#pragma once

#include <leptonica/allheaders.h>

using namespace System;

namespace TesseractWrapper
{
	public ref class OCRProcessor
	{
	public:
		static String^ ExtractText(String^ imagePath, String^ lang, String^ tessdataPath, int psmMode, bool withPreTreatment);
		static int DetectOrientation(String^ imagePath, String^ tessdataPath);
		static Pix* PreprocessImage(String^ imagePath);
		static bool GenerateOCRPDF(String^ imagePath, String^ outputPdfPath, String^ language, String^ tessdataPath, int psmMode, bool withPreTreatment);
	};
}