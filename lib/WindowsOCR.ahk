nm_OCRFromBitmap(bitmap, withRegions := false, timeoutMs := 3000) {
	static language := ""
	if !language {
		for candidate in StrSplit(nm_OCRRead("ShowAvailableLanguages"), "`n", "`r")
			if InStr(candidate, "en-") = 1 {
				language := candidate
				break
			}
		if !language
			throw Error("Install an English Windows OCR language to read game text.")
	}
	hBitmap := Gdip_CreateHBITMAPFromBitmap(bitmap)
	if !hBitmap
		throw Error("Windows OCR could not capture the image.")
	try return nm_OCRRead(nm_OCRBitmapStream(hBitmap), language, withRegions, timeoutMs)
	finally DeleteObject(hBitmap)
}
nm_OCRBitmapStream(hBitmap) {
	stream := picture := randomAccess := 0
	try {
		DllCall("Ole32\CreateStreamOnHGlobal", "Ptr", 0, "UInt", true, "PtrP", &stream, "HRESULT")
		desc := Buffer(8+A_PtrSize*2, 0)
		NumPut("UInt", desc.Size, "UInt", 1, "Ptr", hBitmap, desc)
		DllCall("OleAut32\OleCreatePictureIndirect", "Ptr", desc, "Ptr", nm_OCRGuid("{7BF80980-BF32-101A-8BBB-00AA00300CAB}"), "UInt", false, "PtrP", &picture, "HRESULT")
		ComCall(15, picture, "Ptr", stream, "UInt", true, "UIntP", &size := 0)
		DllCall("ShCore\CreateRandomAccessStreamOverStream", "Ptr", stream, "UInt", 0, "Ptr", nm_OCRGuid("{905A0FE1-BC53-11DF-8C49-001E4FC686DA}"), "PtrP", &randomAccess, "HRESULT")
		return randomAccess
	} finally {
		if picture
			ObjRelease(picture)
		if stream
			ObjRelease(stream)
	}
}
nm_OCRGuid(iid) {
	guid := Buffer(16)
	DllCall("ole32\CLSIDFromString", "WStr", iid, "Ptr", guid, "HRESULT")
	return guid
}
nm_OCRFactory(name, iid) {
	hString := 0
	try {
		DllCall("Combase\WindowsCreateString", "WStr", name, "UInt", StrLen(name), "PtrP", &hString, "HRESULT")
		DllCall("Combase\RoGetActivationFactory", "Ptr", hString, "Ptr", nm_OCRGuid(iid), "PtrP", &factory := 0, "HRESULT")
		return factory
	} finally DllCall("Combase\WindowsDeleteString", "Ptr", hString)
}
nm_OCRString(hString) {
	try return StrGet(DllCall("Combase\WindowsGetStringRawBuffer", "Ptr", hString, "UIntP", &length := 0, "Ptr"), length, "UTF-16")
	finally DllCall("Combase\WindowsDeleteString", "Ptr", hString)
}
nm_OCRWait(&object, deadline) {
	info := ComObjQuery(object, "{00000036-0000-0000-C000-000000000046}")
	loop {
		ComCall(7, info, "UIntP", &status := 0)
		if status = 1
			break
		if status != 0
			throw Error("Windows OCR could not complete the read.")
		if DllCall("GetTickCount64", "UInt64") >= deadline {
			ComCall(9, info)
			throw Error("Windows OCR timed out.")
		}
		Sleep 10
	}
	ComCall(8, object, "PtrP", &result := 0)
	ObjRelease(object)
	object := result
}
nm_OCRRead(input, language := "", withRegions := false, timeoutMs := 3000) {
	static engineStatics := 0, languageFactory := 0, decoderStatics := 0, engine := 0, activeLanguage := ""
	deadline := DllCall("GetTickCount64", "UInt64")+Max(1, timeoutMs)
	stream := IsInteger(input) ? input : 0
	languageObject := decoder := software := result := lines := languages := 0
	try {
		if !engineStatics
			engineStatics := nm_OCRFactory("Windows.Media.Ocr.OcrEngine", "{5BFFA85A-3384-3540-9940-699120D428A8}")
		if !languageFactory
			languageFactory := nm_OCRFactory("Windows.Globalization.Language", "{9B0252AC-0C27-44F8-B792-9793FB66C63E}")
		if input = "ShowAvailableLanguages" {
			ComCall(7, engineStatics, "PtrP", &languages)
			ComCall(7, languages, "UIntP", &count := 0)
			text := ""
			Loop count {
				ComCall(6, languages, "UInt", A_Index-1, "PtrP", &languageObject)
				ComCall(6, languageObject, "PtrP", &hText := 0)
				text .= nm_OCRString(hText) "`n"
				ObjRelease(languageObject), languageObject := 0
			}
			return text
		}
		if !decoderStatics
			decoderStatics := nm_OCRFactory("Windows.Graphics.Imaging.BitmapDecoder", "{438CCB26-BCEF-4E95-BAD6-23A822E58D01}")
		if !engine || activeLanguage != language {
			if engine
				ObjRelease(engine), engine := 0
			hString := 0
			try {
				DllCall("Combase\WindowsCreateString", "WStr", language, "UInt", StrLen(language), "PtrP", &hString, "HRESULT")
				ComCall(6, languageFactory, "Ptr", hString, "PtrP", &languageObject)
				ComCall(9, engineStatics, "Ptr", languageObject, "PtrP", &engine)
			} finally DllCall("Combase\WindowsDeleteString", "Ptr", hString)
			if !engine
				throw Error("The selected Windows OCR language is unavailable.")
			activeLanguage := language
		}
		ComCall(14, decoderStatics, "Ptr", stream, "PtrP", &decoder)
		nm_OCRWait(&decoder, deadline)
		frame := ComObjQuery(decoder, "{FE287C9A-420C-4963-87AD-691436E08383}")
		ComCall(6, frame, "PtrP", &software)
		nm_OCRWait(&software, deadline)
		ComCall(6, engine, "Ptr", software, "PtrP", &result)
		nm_OCRWait(&result, deadline)
		ComCall(6, result, "PtrP", &lines)
		ComCall(7, lines, "UIntP", &count := 0)
		text := "", regions := []
		Loop count {
			ComCall(6, lines, "UInt", A_Index-1, "PtrP", &line := 0)
			try {
				ComCall(7, line, "PtrP", &hText := 0)
				lineText := nm_OCRString(hText)
				text .= lineText "`n"
				if withRegions {
					ComCall(6, line, "PtrP", &words := 0)
					try {
						ComCall(7, words, "UIntP", &wordCount := 0)
						left := top := 100000, right := bottom := 0
						Loop wordCount {
							ComCall(6, words, "UInt", A_Index-1, "PtrP", &word := 0)
							try {
								rect := Buffer(16)
								ComCall(6, word, "Ptr", rect)
								x := NumGet(rect, 0, "Float"), y := NumGet(rect, 4, "Float")
								w := NumGet(rect, 8, "Float"), h := NumGet(rect, 12, "Float")
								left := Min(left, x), top := Min(top, y)
								right := Max(right, x+w), bottom := Max(bottom, y+h)
							} finally ObjRelease(word)
						}
						if wordCount
							regions.Push({text:lineText, x:left, y:top, w:right-left, h:bottom-top})
					} finally ObjRelease(words)
				}
			} finally ObjRelease(line)
		}
		return withRegions ? regions : text
	} finally {
		for object in [stream, software] {
			if object {
				try {
					closable := ComObjQuery(object, "{30D5A829-7FA4-4026-83BB-D75BAE4EA99E}")
					ComCall(6, closable)
				}
			}
		}
		for object in [languageObject, decoder, software, result, lines, languages, stream]
			if object
				ObjRelease(object)
	}
}
