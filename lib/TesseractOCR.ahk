NM_TesseractOCR(bitmap, timeoutMs := 3000, cancelled := 0, layout := false) {
	static runtime := RegExReplace(A_LineFile, "[^\\]+$", "") "tesseract"
	static serial := 0
	deadline := A_TickCount + timeoutMs
	CheckDeadline() {
		if (cancelled && cancelled.Call()) || A_TickCount >= deadline
			throw Error("OCR was cancelled or timed out.")
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
	Gdip_GetImageDimensions(bitmap, &w, &h)
	copy := Gdip_CloneBitmapArea(bitmap, 0, 0, w, h)
	if !copy
		throw Error("Unable to prepare the SSA menu.")
	locked := false
	try {
		if Gdip_LockBits(copy, 0, 0, w, h, &stride, &scan, &data)
			throw Error("Unable to read the SSA menu pixels.")
		locked := true
		loop h {
			if Mod(A_Index, 32) = 0 {
				Sleep -1
				if cancelled && cancelled.Call()
					throw Error("OCR was cancelled.")
			}
			row := scan + (A_Index - 1) * stride
			loop w {
				address := row + (A_Index - 1) * 4
				pixel := NumGet(address, "uint")
				light := Min((pixel >> 16) & 255, (pixel >> 8) & 255, pixel & 255) > 180
				NumPut("uint", light ? 0xFF000000 : 0xFFFFFFFF, address)
			}
		}
		Gdip_UnlockBits(copy, &data), locked := false
		return copy
	} catch {
		if locked
			Gdip_UnlockBits(copy, &data)
		Gdip_DisposeImage(copy)
		throw
	}
}
