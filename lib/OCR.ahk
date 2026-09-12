/************************************************************************
 * Original implementation: malcev, teadrinker
 * https://www.autohotkey.com/boards/viewtopic.php?t=72674
 ************************************************************************/

HBitmapToRandomAccessStream(hBitmap) {
	DllCall("Ole32\CreateStreamOnHGlobal", "ptr", 0, "int", true, "ptr*", &ptr := 0, "hresult")
	stream := ComValue(13, ptr)
	desc := Buffer(8 + A_PtrSize * 2, 0)
	NumPut("uint", desc.Size, "uint", 1, "ptr", hBitmap, desc)
	DllCall("OleAut32\OleCreatePictureIndirect", "ptr", desc, "ptr", CLSIDFromString("{7BF80980-BF32-101A-8BBB-00AA00300CAB}"), "int", false, "ptr*", &ptr := 0, "hresult")
	picture := ComValue(13, ptr)
	ComCall(15, picture, "ptr", stream, "int", true, "uint*", &size := 0)
	DllCall("ShCore\CreateRandomAccessStreamOverStream", "ptr", stream, "uint", 0, "ptr", CLSIDFromString("{905A0FE1-BC53-11DF-8C49-001E4FC686DA}"), "ptr*", &ptr := 0, "hresult")
	return ptr
}

ocr(file, lang := "FirstFromAvailableLanguages", timeoutMs := 5000, cancelled := 0) {
	stream := (file = "ShowAvailableLanguages") ? 0 : ComValue(13, file)
	bitmap := 0
	try {
		static languageFactory := NM_OCRFactory("Windows.Globalization.Language", "{9B0252AC-0C27-44F8-B792-9793FB66C63E}")
		static decoderFactory := NM_OCRFactory("Windows.Graphics.Imaging.BitmapDecoder", "{438CCB26-BCEF-4E95-BAD6-23A822E58D01}")
		static engineFactory := NM_OCRFactory("Windows.Media.Ocr.OcrEngine", "{5BFFA85A-3384-3540-9940-699120D428A8}")
		static engine := 0, currentLanguage := ""
		if (file = "ShowAvailableLanguages") {
			ComCall(7, engineFactory, "ptr*", &ptr := 0)
			languages := ComValue(13, ptr)
			ComCall(7, languages, "uint*", &count := 0)
			text := ""
			loop count {
				ComCall(6, languages, "uint", A_Index - 1, "ptr*", &ptr := 0)
				language := ComValue(13, ptr)
				ComCall(6, language, "ptr*", &hText := 0)
				text .= NM_OCRString(hText) "`n"
			}
			return text
		}
		if (!engine || lang != currentLanguage) {
			if (lang = "FirstFromAvailableLanguages")
				ComCall(10, engineFactory, "ptr*", &ptr := 0)
			else {
				CreateHString(lang, &hString)
				try ComCall(6, languageFactory, "ptr", hString, "ptr*", &ptr := 0)
				finally DeleteHString(hString)
				language := ComValue(13, ptr)
				ComCall(9, engineFactory, "ptr", language, "ptr*", &ptr := 0)
			}
			if !ptr
				throw Error("No OCR language pack is available for " lang ".")
			engine := ComValue(13, ptr)
			currentLanguage := lang
		}
		deadline := A_TickCount + timeoutMs
		ComCall(14, decoderFactory, "ptr", stream, "ptr*", &ptr := 0)
		decoder := NM_OCRAwait(ptr, deadline, cancelled)
		frame := ComObjQuery(decoder, "{72A49A1C-8081-438D-91BC-94ECFC8185C6}")
		ComCall(12, frame, "uint*", &width := 0)
		ComCall(13, frame, "uint*", &height := 0)
		ComCall(6, engineFactory, "uint*", &maxDimension := 0)
		if (width > maxDimension || height > maxDimension)
			throw Error("OCR image exceeds " maxDimension " pixels.")
		softwareFrame := ComObjQuery(decoder, "{FE287C9A-420C-4963-87AD-691436E08383}")
		ComCall(6, softwareFrame, "ptr*", &ptr := 0)
		bitmap := NM_OCRAwait(ptr, deadline, cancelled)
		ComCall(6, engine, "ptr", bitmap, "ptr*", &ptr := 0)
		result := NM_OCRAwait(ptr, deadline, cancelled)
		ComCall(6, result, "ptr*", &ptr := 0)
		lines := ComValue(13, ptr)
		ComCall(7, lines, "uint*", &count := 0)
		text := ""
		loop count {
			ComCall(6, lines, "uint", A_Index - 1, "ptr*", &ptr := 0)
			line := ComValue(13, ptr)
			ComCall(7, line, "ptr*", &hText := 0)
			text .= NM_OCRString(hText) "`n"
		}
		return text
	} finally {
		for value in [bitmap, stream]
			if value
				try ComCall(6, ComObjQuery(value, "{30D5A829-7FA4-4026-83BB-D75BAE4EA99E}"))
	}
}

NM_OCRAwait(ptr, deadline, cancelled := 0) {
	operation := ComValue(13, ptr)
	info := ComObjQuery(operation, "{00000036-0000-0000-C000-000000000046}")
	try {
		loop {
			if (cancelled && cancelled.Call()) || A_TickCount >= deadline {
				try ComCall(9, info)
				throw Error("OCR was cancelled or timed out.")
			}
			ComCall(7, info, "uint*", &status := 0)
			if status = 1
				break
			if status != 0 {
				ComCall(8, info, "uint*", &code := 0)
				throw Error("OCR operation failed: " Format("0x{:08X}", code))
			}
			Sleep 10
		}
		ComCall(8, operation, "ptr*", &ptr := 0)
		return ComValue(13, ptr)
	} finally {
		try ComCall(10, info)
	}
}

NM_OCRFactory(name, iid) {
	CreateHString(name, &hString)
	try {
		DllCall("Combase\RoGetActivationFactory", "ptr", hString, "ptr", CLSIDFromString(iid), "ptr*", &ptr := 0, "hresult")
		return ComValue(13, ptr)
	} finally DeleteHString(hString)
}

NM_OCRString(hString) {
	try {
		ptr := DllCall("Combase\WindowsGetStringRawBuffer", "ptr", hString, "uint*", &length := 0, "ptr")
		return length ? StrGet(ptr, length, "UTF-16") : ""
	} finally DeleteHString(hString)
}

CLSIDFromString(iid) {
	guid := Buffer(16)
	DllCall("Ole32\CLSIDFromString", "wstr", iid, "ptr", guid, "hresult")
	return guid
}

CreateHString(str, &hString) {
	DllCall("Combase\WindowsCreateString", "wstr", str, "uint", StrLen(str), "ptr*", &hString := 0, "hresult")
}

DeleteHString(hString) {
	DllCall("Combase\WindowsDeleteString", "ptr", hString)
}
