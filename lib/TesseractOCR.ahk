NM_TesseractOCR(bitmap, timeoutMs := 3000, cancelled := 0, layout := false) {
	static runtime := RegExReplace(A_LineFile, "[^\\]+$", "") "tesseract"
	static serial := 0
	deadline := A_TickCount + timeoutMs
	CheckDeadline() {
		if cancelled && cancelled.Call()
			throw Error("OCR was cancelled.")
		if A_TickCount >= deadline
			throw Error("OCR timed out.",, "timeout")
	}
	CheckDeadline()
	executable := runtime "\tesseract.exe"
	if !FileExist(executable) || !FileExist(runtime "\tessdata\eng.traineddata")
		throw Error("The bundled OCR files are missing. Extract the complete macro download.")
	directory := A_Temp "\NatroOCR-" DllCall("GetCurrentProcessId", "uint") "-" A_TickCount "-" (++serial)
	process := thread := 0
	try {
		DirCreate directory
		input := directory "\input.png", output := directory "\result"
		if Gdip_SaveBitmapToFile(bitmap, input) != 0
			throw Error("Unable to prepare the OCR image.")
		CheckDeadline()
		command := '"' executable '" "' input '" "' output '" --tessdata-dir "' runtime '\tessdata" -l eng --psm ' (layout ? '11 -c tessedit_create_tsv=1' : '6')
		commandBuffer := Buffer(StrPut(command, "UTF-16") * 2)
		StrPut(command, commandBuffer, "UTF-16")
		startup := Buffer(A_PtrSize = 8 ? 104 : 68, 0)
		NumPut("uint", startup.Size, startup)
		info := Buffer(A_PtrSize * 2 + 8, 0)
		if !DllCall("CreateProcessW", "wstr", executable, "ptr", commandBuffer, "ptr", 0, "ptr", 0, "int", false, "uint", 0x08000000, "ptr", 0, "wstr", runtime, "ptr", startup, "ptr", info)
			throw OSError(, "Unable to start the bundled OCR engine")
		process := NumGet(info, 0, "ptr"), thread := NumGet(info, A_PtrSize, "ptr")
		loop {
			Sleep -1
			CheckDeadline()
			status := DllCall("WaitForSingleObject", "ptr", process, "uint", 20, "uint")
			if status = 0
				break
			if status != 258
				throw OSError(, "Unable to wait for OCR")
		}
		if !DllCall("GetExitCodeProcess", "ptr", process, "uint*", &code := 0) || code != 0
			throw Error("The bundled OCR engine could not read the image.")
		CheckDeadline()
		return FileRead(output (layout ? ".tsv" : ".txt"), "UTF-8")
	} finally {
		if process {
			if DllCall("WaitForSingleObject", "ptr", process, "uint", 0, "uint") = 258 {
				DllCall("TerminateProcess", "ptr", process, "uint", 1)
				DllCall("WaitForSingleObject", "ptr", process, "uint", 1000)
			}
			DllCall("CloseHandle", "ptr", process)
		}
		if thread
			DllCall("CloseHandle", "ptr", thread)
		try DirDelete directory, true
	}
}

NM_TesseractReady(cancelled := 0) {
	bitmap := Gdip_CreateBitmap(128, 48)
	graphics := 0
	try {
		if !bitmap
			throw Error("Unable to prepare the OCR engine.")
		graphics := Gdip_GraphicsFromImage(bitmap)
		Gdip_GraphicsClear(graphics, 0xFFFFFFFF)
		Gdip_DeleteGraphics(graphics), graphics := 0
		NM_TesseractOCR(bitmap, 3000, cancelled)
	} finally {
		if graphics
			Gdip_DeleteGraphics(graphics)
		if bitmap
			Gdip_DisposeImage(bitmap)
	}
}

NM_OCRLeftInset(bitmap) {
	Gdip_GetImageDimensions(bitmap, &w, &h)
	if Gdip_LockBits(bitmap, 0, 0, w, h, &stride, &scan, &data)
		return 0
	first := -1, last := -1, gap := 0
	try {
		loop w {
			x := A_Index - 1, ink := false
			loop h {
				pixel := NumGet(scan + (A_Index - 1) * stride + x * 4, "uint")
				if Max((pixel >> 16) & 255, (pixel >> 8) & 255, pixel & 255) < 128 {
					ink := true
					break
				}
			}
			if ink {
				if first < 0 {
					if x > 1
						return 0
					first := x
				} else if gap >= 8
					return last - first < 8 ? last + 1 + gap // 2 : 0
				last := x, gap := 0
				if last - first >= 8
					return 0
			} else if first >= 0
				gap += 1
		}
	} finally Gdip_UnlockBits(bitmap, &data)
	return 0
}

NM_OCRLightText(bitmap, cancelled := 0) {
	channels := NM_OCRTextMask(bitmap, 180 / 255, "1|0|0|0|0|0|1|0|0|0|0|0|1|0|0|0|0|0|1|0|0|0|0|0|1", cancelled)
	try return NM_OCRTextMask(channels, 0.2, "-0.3333|-0.3333|-0.3333|0|0|-0.3333|-0.3333|-0.3333|0|0|-0.3333|-0.3333|-0.3333|0|0|0|0|0|1|0|1|1|1|0|1", cancelled)
	finally Gdip_DisposeImage(channels)
}
NM_OCRDarkText(bitmap, cancelled := 0) {
	return NM_OCRTextMask(bitmap, 0.35, "0.3333|0.3333|0.3333|0|0|0.3333|0.3333|0.3333|0|0|0.3333|0.3333|0.3333|0|0|0|0|0|1|0|0|0|0|0|1", cancelled)
}

NM_OCRTextMask(bitmap, threshold, matrix, cancelled := 0) {
	if cancelled && cancelled.Call()
		throw Error("OCR was cancelled.")
	Gdip_GetImageDimensions(bitmap, &w, &h)
	copy := Gdip_CreateBitmap(w, h), graphics := 0, attributes := 0, complete := false
	try {
		if !copy
			throw Error("Unable to prepare the SSA menu.")
		graphics := Gdip_GraphicsFromImage(copy)
		attributes := Gdip_SetImageAttributesColorMatrix(matrix)
		if !graphics || !attributes || DllCall("gdiplus\GdipSetImageAttributesThreshold", "ptr", attributes, "int", 1, "int", 1, "float", threshold)
			throw Error("Unable to prepare the SSA menu colors.")
		if DllCall("gdiplus\GdipDrawImageRectRectI", "ptr", graphics, "ptr", bitmap, "int", 0, "int", 0, "int", w, "int", h, "int", 0, "int", 0, "int", w, "int", h, "int", 2, "ptr", attributes, "ptr", 0, "ptr", 0)
			throw Error("Unable to prepare the SSA menu pixels.")
		if cancelled && cancelled.Call()
			throw Error("OCR was cancelled.")
		complete := true
		return copy
	} finally {
		if attributes
			Gdip_DisposeImageAttributes(attributes)
		if graphics
			Gdip_DeleteGraphics(graphics)
		if !complete && copy
			Gdip_DisposeImage(copy)
	}
}

NM_OCRTextBitmap(bitmap, scale, interpolation, grayscale := false) {
	Gdip_GetImageDimensions(bitmap, &w, &h)
	copy := Gdip_CreateBitmap(w * scale + 20, h * scale + 20), graphics := 0, complete := false
	try {
		if !copy
			throw Error("Unable to prepare the SSA text.")
		graphics := Gdip_GraphicsFromImage(copy)
		if !graphics
			throw Error("Unable to prepare the SSA text.")
		Gdip_GraphicsClear(graphics, 0xFFFFFFFF)
		Gdip_SetInterpolationMode(graphics, interpolation)
		Gdip_SetPixelOffsetMode(graphics, 2)
		matrix := grayscale ? "0.299|0.299|0.299|0|0|0.587|0.587|0.587|0|0|0.114|0.114|0.114|0|0|0|0|0|1|0|0|0|0|0|1" : 1
		if Gdip_DrawImage(graphics, bitmap, 10, 10, w * scale, h * scale, 0, 0, w, h, matrix)
			throw Error("Unable to resize the SSA text.")
		complete := true
		return copy
	} finally {
		if graphics
			Gdip_DeleteGraphics(graphics)
		if !complete && copy
			Gdip_DisposeImage(copy)
	}
}
