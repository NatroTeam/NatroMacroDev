#Requires AutoHotkey v2.0

class VisionBitmap {
    static LoadFromFile(path) {
        if !FileExist(path) {
            throw Error("Image file not found: " path)
        }
        src := LoadPicture(path, "", &imgType)
        if !src {
            throw Error("LoadPicture failed: " path)
        }
        normalized := VisionBitmap.NormalizeToDib32(src)
        VisionBitmap.Free(src)
        if !normalized {
            throw Error("NormalizeToDib32 failed: " path)
        }
        return normalized
    }

    static Free(hBitmap) {
        if (hBitmap) {
            DllCall("DeleteObject", "UPtr", hBitmap)
        }
    }

    static NormalizeToDib32(hBitmapSrc) {
        bmSize := (A_PtrSize = 8) ? 32 : 24
        bm := Buffer(bmSize, 0)
        if (DllCall("GetObjectW", "UPtr", hBitmapSrc, "Int", bmSize, "Ptr", bm.Ptr, "Int") = 0) {
            return 0
        }
        width := NumGet(bm, 4, "Int")
        height := Abs(NumGet(bm, 8, "Int"))
        if (width <= 0 || height <= 0) {
            return 0
        }

        srcDc := DllCall("CreateCompatibleDC", "Ptr", 0, "Ptr")
        dstDc := DllCall("CreateCompatibleDC", "Ptr", 0, "Ptr")
        if (!srcDc || !dstDc) {
            if (srcDc) {
                DllCall("DeleteDC", "Ptr", srcDc)
            }
            if (dstDc) {
                DllCall("DeleteDC", "Ptr", dstDc)
            }
            return 0
        }

        oldSrc := DllCall("SelectObject", "Ptr", srcDc, "UPtr", hBitmapSrc, "Ptr")

        bi := Buffer(40, 0)
        NumPut("UInt", 40, bi, 0)
        NumPut("Int", width, bi, 4)
        NumPut("Int", -height, bi, 8)
        NumPut("UShort", 1, bi, 12)
        NumPut("UShort", 32, bi, 14)
        NumPut("UInt", 0, bi, 16)

        bits := 0
        hDib := DllCall("CreateDIBSection", "Ptr", dstDc, "Ptr", bi.Ptr, "UInt", 0, "Ptr*", bits, "Ptr", 0, "UInt", 0, "UPtr")
        if !hDib {
            DllCall("SelectObject", "Ptr", srcDc, "Ptr", oldSrc)
            DllCall("DeleteDC", "Ptr", srcDc)
            DllCall("DeleteDC", "Ptr", dstDc)
            return 0
        }

        oldDst := DllCall("SelectObject", "Ptr", dstDc, "UPtr", hDib, "Ptr")
        DllCall("BitBlt", "Ptr", dstDc, "Int", 0, "Int", 0, "Int", width, "Int", height, "Ptr", srcDc, "Int", 0, "Int", 0, "UInt", 0x00CC0020)

        DllCall("SelectObject", "Ptr", srcDc, "Ptr", oldSrc)
        DllCall("SelectObject", "Ptr", dstDc, "Ptr", oldDst)
        DllCall("DeleteDC", "Ptr", srcDc)
        DllCall("DeleteDC", "Ptr", dstDc)
        return hDib
    }
}

class Vision {
    static STATUS_OK := 0
    static STATUS_INVALID_ARGUMENT := 1
    static STATUS_CONFIG_ERROR := 2
    static STATUS_RUNTIME_ERROR := 3
    static STATUS_BUFFER_TOO_SMALL := 4

    static MAX_HUE_RANGES := 8
    static POINT_SIZE_BYTES := 8

    ; VisionConfigV1 layout (byte offsets)
    static CFG_O_STRUCT_SIZE := 0
    static CFG_O_YELLOW_COUNT := 4
    static CFG_O_YELLOW_RANGES := 8
    static CFG_O_YELLOW_SAT := 72
    static CFG_O_YELLOW_VAL := 80
    static CFG_O_MORPH_OPEN := 88
    static CFG_O_MORPH_CLOSE := 92
    static CFG_O_DILATE := 96
    static CFG_O_MIN_BLOB := 100
    static CFG_O_MAX_BLOB := 104
    static CFG_O_MIN_CIRC := 108
    static CFG_O_MIN_FILL := 112
    static CFG_O_REQUIRE_CTX := 116
    static CFG_O_RING_INNER := 120
    static CFG_O_RING_OUTER := 124
    static CFG_O_PETAL_SAT := 128
    static CFG_O_PETAL_VAL := 136
    static CFG_O_GREEN_COUNT := 144
    static CFG_O_GREEN_RANGES := 148
    static CFG_O_MIN_PETAL := 212
    static CFG_O_DRAW_REJECTED := 216
    static CFG_SIZE_EXPECTED := 220

    ; ChromaAhkDebugImageV1 layout (byte offsets)
    static DBG_SIZE_EXPECTED := (A_PtrSize = 8) ? 40 : 32
    static DBG_O_STRUCT_SIZE := 0
    static DBG_O_PIXELS := (A_PtrSize = 8) ? 8 : 4
    static DBG_O_CAPACITY := (A_PtrSize = 8) ? 16 : 8
    static DBG_O_WIDTH := (A_PtrSize = 8) ? 20 : 12
    static DBG_O_HEIGHT := (A_PtrSize = 8) ? 24 : 16
    static DBG_O_STRIDE := (A_PtrSize = 8) ? 28 : 20
    static DBG_O_BYTES_REQUIRED := (A_PtrSize = 8) ? 32 : 24
    static DBG_O_BYTES_WRITTEN := (A_PtrSize = 8) ? 36 : 28

    __New(dllPath) {
        if !FileExist(dllPath) {
            throw Error("Vision.dll not found: " dllPath)
        }
        this.dllPath := dllPath
        this.apiPrefix := "ChromaAhk"
        this._procCache := Map()
        this.hModule := DllCall("LoadLibrary", "Str", this.dllPath, "Ptr")
        if !this.hModule {
            throw Error("LoadLibrary failed for: " this.dllPath)
        }
        try {
            DllCall(this.Api("GetApiVersion"), "Int")
        } catch {
            throw Error("Unsupported vision DLL. Expected ChromaAhk_* exports.")
        }

        cfgSize := this.GetConfigStructSize()
        if (cfgSize != Vision.CFG_SIZE_EXPECTED) {
            throw Error("Vision config layout mismatch. DLL size=" cfgSize ", wrapper expects=" Vision.CFG_SIZE_EXPECTED)
        }
    }

    __Delete() {
        if (HasProp(this, "hModule") && this.hModule) {
            DllCall("FreeLibrary", "Ptr", this.hModule)
            this.hModule := 0
        }
    }

    Api(funcName) {
        exportName := this.apiPrefix "_" funcName
        if this._procCache.Has(exportName) {
            return this._procCache[exportName]
        }

        addr := DllCall("GetProcAddress", "Ptr", this.hModule, "AStr", exportName, "Ptr")
        if !addr {
            throw Error("Missing DLL export: " exportName)
        }

        this._procCache[exportName] := addr
        return addr
    }

    EnsureAutoDebugBuffer(width, height) {
        required := width * height * 8
        if (!HasProp(this, "_autoDebugBuffer") || !IsObject(this._autoDebugBuffer) || this._autoDebugBuffer.Size < required) {
            this._autoDebugBuffer := Buffer(required, 0)
        }
        return this._autoDebugBuffer
    }


    LocateFile(scenePath, maxPoints := 512) {
        hBitmap := VisionBitmap.LoadFromFile(scenePath)
        try {
            return this.LocateHBitmap(hBitmap, maxPoints)
        } finally {
            VisionBitmap.Free(hBitmap)
        }
    }

    GetApiVersion() {
        return DllCall(this.Api("GetApiVersion"), "Int")
    }

    GetConfigStructSize() {
        return DllCall(this.Api("GetConfigStructSize"), "Int")
    }

    GetDefaultConfig() {
        cfgBuf := Buffer(this.GetConfigStructSize(), 0)
        errChars := 1024
        errBuf := Buffer(errChars * 2, 0)
        status := DllCall(
            this.Api("GetDefaultConfig"),
            "Ptr", cfgBuf.Ptr,
            "Ptr", errBuf.Ptr,
            "Int", errChars,
            "Int")

        if (status != Vision.STATUS_OK) {
            throw Error(this.apiPrefix "_GetDefaultConfig failed (" Vision.StatusToText(status) "): " Trim(StrGet(errBuf.Ptr, errChars, "UTF-16"), "`r`n`t "))
        }
        return this.ConfigFromBuffer(cfgBuf)
    }

    GetActiveConfig() {
        cfgBuf := Buffer(this.GetConfigStructSize(), 0)
        errChars := 1024
        errBuf := Buffer(errChars * 2, 0)
        status := DllCall(
            this.Api("GetActiveConfig"),
            "Ptr", cfgBuf.Ptr,
            "Ptr", errBuf.Ptr,
            "Int", errChars,
            "Int")

        if (status != Vision.STATUS_OK) {
            throw Error(this.apiPrefix "_GetActiveConfig failed (" Vision.StatusToText(status) "): " Trim(StrGet(errBuf.Ptr, errChars, "UTF-16"), "`r`n`t "))
        }
        return this.ConfigFromBuffer(cfgBuf)
    }

    SetActiveConfig(configObj) {
        cfgBuf := this.ConfigToBuffer(configObj)
        errChars := 1024
        errBuf := Buffer(errChars * 2, 0)
        status := DllCall(
            this.Api("SetActiveConfig"),
            "Ptr", cfgBuf.Ptr,
            "Ptr", errBuf.Ptr,
            "Int", errChars,
            "Int")

        return {
            status: status,
            statusText: Vision.StatusToText(status),
            error: Trim(StrGet(errBuf.Ptr, errChars, "UTF-16"), "`r`n`t ")
        }
    }

    ResetConfigToDefault() {
        errChars := 1024
        errBuf := Buffer(errChars * 2, 0)
        status := DllCall(
            this.Api("ResetConfigToDefault"),
            "Ptr", errBuf.Ptr,
            "Int", errChars,
            "Int")
        return {
            status: status,
            statusText: Vision.StatusToText(status),
            error: Trim(StrGet(errBuf.Ptr, errChars, "UTF-16"), "`r`n`t ")
        }
    }

    LocateBitmapBGRA(pixelPtr, width, height, strideBytes, maxPoints := 512) {
        if !pixelPtr {
            throw Error("pixelPtr is null.")
        }
        if (width <= 0 || height <= 0) {
            throw Error("width/height must be > 0.")
        }
        if (strideBytes = 0) {
            throw Error("strideBytes must not be 0.")
        }

        maxPoints := Max(0, maxPoints)
        pointsBuf := Buffer(maxPoints * Vision.POINT_SIZE_BYTES, 0)
        errChars := 1024
        errBuf := Buffer(errChars * 2, 0)
        totalBuf := Buffer(4, 0)
        writtenBuf := Buffer(4, 0)

        status := DllCall(
            this.Api("LocateBitmapBGRAW"),
            "Ptr", pixelPtr,
            "Int", width,
            "Int", height,
            "Int", strideBytes,
            "Ptr", (maxPoints > 0 ? pointsBuf.Ptr : 0),
            "Int", maxPoints,
            "Ptr", totalBuf.Ptr,
            "Ptr", writtenBuf.Ptr,
            "Ptr", errBuf.Ptr,
            "Int", errChars,
            "Int")
        totalFound := NumGet(totalBuf, 0, "Int")
        written := NumGet(writtenBuf, 0, "Int")

        return {
            status: status,
            statusText: Vision.StatusToText(status),
            error: Trim(StrGet(errBuf.Ptr, errChars, "UTF-16"), "`r`n`t "),
            totalFound: totalFound,
            written: written,
            points: this.ReadPoints(pointsBuf, written)
        }
    }

    LocateBitmapWithConfigBGRA(pixelPtr, width, height, strideBytes, configObj, maxPoints := 512) {
        cfgBuf := this.ConfigToBuffer(configObj)
        maxPoints := Max(0, maxPoints)
        pointsBuf := Buffer(maxPoints * Vision.POINT_SIZE_BYTES, 0)
        errChars := 1024
        errBuf := Buffer(errChars * 2, 0)
        totalBuf := Buffer(4, 0)
        writtenBuf := Buffer(4, 0)

        status := DllCall(
            this.Api("LocateBitmapWithConfigBGRAW"),
            "Ptr", pixelPtr,
            "Int", width,
            "Int", height,
            "Int", strideBytes,
            "Ptr", cfgBuf.Ptr,
            "Ptr", (maxPoints > 0 ? pointsBuf.Ptr : 0),
            "Int", maxPoints,
            "Ptr", totalBuf.Ptr,
            "Ptr", writtenBuf.Ptr,
            "Ptr", errBuf.Ptr,
            "Int", errChars,
            "Int")
        totalFound := NumGet(totalBuf, 0, "Int")
        written := NumGet(writtenBuf, 0, "Int")

        return {
            status: status,
            statusText: Vision.StatusToText(status),
            error: Trim(StrGet(errBuf.Ptr, errChars, "UTF-16"), "`r`n`t "),
            totalFound: totalFound,
            written: written,
            points: this.ReadPoints(pointsBuf, written)
        }
    }
    LocateBitmapWithDebugBGRA(pixelPtr, width, height, strideBytes, maxPoints := 512, debugBuffer := 0) {
        if !pixelPtr {
            throw Error("pixelPtr is null.")
        }
        if (width <= 0 || height <= 0) {
            throw Error("width/height must be > 0.")
        }
        if (strideBytes = 0) {
            throw Error("strideBytes must not be 0.")
        }

        if !IsObject(debugBuffer) {
            debugBuffer := this.EnsureAutoDebugBuffer(width, height)
        }

        maxPoints := Max(0, maxPoints)
        pointsBuf := Buffer(maxPoints * Vision.POINT_SIZE_BYTES, 0)
        errChars := 1024
        errBuf := Buffer(errChars * 2, 0)
        totalBuf := Buffer(4, 0)
        writtenBuf := Buffer(4, 0)

        dbgBuf := Buffer(Vision.DBG_SIZE_EXPECTED, 0)
        NumPut("Int", Vision.DBG_SIZE_EXPECTED, dbgBuf, Vision.DBG_O_STRUCT_SIZE)

        if IsObject(debugBuffer) {
            NumPut("Ptr", debugBuffer.Ptr, dbgBuf, Vision.DBG_O_PIXELS)
            NumPut("Int", debugBuffer.Size, dbgBuf, Vision.DBG_O_CAPACITY)
        }

        status := DllCall(
            this.Api("LocateBitmapWithDebugBGRAW"),
            "Ptr", pixelPtr,
            "Int", width,
            "Int", height,
            "Int", strideBytes,
            "Ptr", (maxPoints > 0 ? pointsBuf.Ptr : 0),
            "Int", maxPoints,
            "Ptr", totalBuf.Ptr,
            "Ptr", writtenBuf.Ptr,
            "Ptr", dbgBuf.Ptr,
            "Ptr", errBuf.Ptr,
            "Int", errChars,
            "Int")

        totalFound := NumGet(totalBuf, 0, "Int")
        written := NumGet(writtenBuf, 0, "Int")

        return {
            status: status,
            statusText: Vision.StatusToText(status),
            error: Trim(StrGet(errBuf.Ptr, errChars, "UTF-16"), "`r`n`t "),
            totalFound: totalFound,
            written: written,
            points: this.ReadPoints(pointsBuf, written),
            debug: {
                width: NumGet(dbgBuf, Vision.DBG_O_WIDTH, "Int"),
                height: NumGet(dbgBuf, Vision.DBG_O_HEIGHT, "Int"),
                strideBytes: NumGet(dbgBuf, Vision.DBG_O_STRIDE, "Int"),
                bytesRequired: NumGet(dbgBuf, Vision.DBG_O_BYTES_REQUIRED, "Int"),
                bytesWritten: NumGet(dbgBuf, Vision.DBG_O_BYTES_WRITTEN, "Int"),
                hasBuffer: IsObject(debugBuffer)
            }
        }
    }

    LocateHBitmap(hBitmap, maxPoints := 512) {
        if !hBitmap {
            throw Error("hBitmap is null.")
        }
        hBitmap += 0

        maxPoints := Max(0, maxPoints)
        pointsBuf := Buffer(maxPoints * Vision.POINT_SIZE_BYTES, 0)
        errChars := 1024
        errBuf := Buffer(errChars * 2, 0)
        totalBuf := Buffer(4, 0)
        writtenBuf := Buffer(4, 0)

        status := DllCall(
            this.Api("LocateHBitmap"),
            "UPtr", hBitmap,
            "Ptr", (maxPoints > 0 ? pointsBuf.Ptr : 0),
            "Int", maxPoints,
            "Ptr", totalBuf.Ptr,
            "Ptr", writtenBuf.Ptr,
            "Ptr", errBuf.Ptr,
            "Int", errChars,
            "Int")
        totalFound := NumGet(totalBuf, 0, "Int")
        written := NumGet(writtenBuf, 0, "Int")

        return {
            status: status,
            statusText: Vision.StatusToText(status),
            error: Trim(StrGet(errBuf.Ptr, errChars, "UTF-16"), "`r`n`t "),
            totalFound: totalFound,
            written: written,
            points: this.ReadPoints(pointsBuf, written)
        }
    }

    LocateHBitmapAll(hBitmap) {
        if !hBitmap {
            throw Error("hBitmap is null.")
        }
        hBitmap += 0

        errChars := 1024
        errBuf := Buffer(errChars * 2, 0)
        totalBuf := Buffer(4, 0)
        writtenBuf := Buffer(4, 0)
        points := []
        written := 0
        status := Vision.STATUS_RUNTIME_ERROR

        statusCount := DllCall(
            this.Api("LocateHBitmap"),
            "UPtr", hBitmap,
            "Ptr", 0,
            "Int", 0,
            "Ptr", totalBuf.Ptr,
            "Ptr", writtenBuf.Ptr,
            "Ptr", errBuf.Ptr,
            "Int", errChars,
            "Int")
        totalFound := NumGet(totalBuf, 0, "Int")

        if ((statusCount = Vision.STATUS_OK || statusCount = Vision.STATUS_BUFFER_TOO_SMALL) && (totalFound > 0)) {
            pointsBuf := Buffer(totalFound * Vision.POINT_SIZE_BYTES, 0)
            status := DllCall(
                this.Api("LocateHBitmap"),
                "UPtr", hBitmap,
                "Ptr", pointsBuf.Ptr,
                "Int", totalFound,
                "Ptr", totalBuf.Ptr,
                "Ptr", writtenBuf.Ptr,
                "Ptr", errBuf.Ptr,
                "Int", errChars,
                "Int")
            written := NumGet(writtenBuf, 0, "Int")
            points := this.ReadPoints(pointsBuf, written)
            totalFound := NumGet(totalBuf, 0, "Int")
        } else {
            status := statusCount
            written := NumGet(writtenBuf, 0, "Int")
        }

        return {
            status: status,
            statusText: Vision.StatusToText(status),
            error: Trim(StrGet(errBuf.Ptr, errChars, "UTF-16"), "`r`n`t "),
            totalFound: totalFound,
            written: written,
            points: points
        }
    }

    LocateHWND(hWnd, captureClientArea := true, maxPoints := 512) {
        if !hWnd {
            throw Error("hWnd is null/0.")
        }

        maxPoints := Max(0, maxPoints)
        pointsBuf := Buffer(maxPoints * Vision.POINT_SIZE_BYTES, 0)
        errChars := 1024
        errBuf := Buffer(errChars * 2, 0)
        totalBuf := Buffer(4, 0)
        writtenBuf := Buffer(4, 0)

        status := DllCall(
            this.Api("LocateHWND"),
            "Ptr", hWnd,
            "Int", captureClientArea ? 1 : 0,
            "Ptr", (maxPoints > 0 ? pointsBuf.Ptr : 0),
            "Int", maxPoints,
            "Ptr", totalBuf.Ptr,
            "Ptr", writtenBuf.Ptr,
            "Ptr", errBuf.Ptr,
            "Int", errChars,
            "Int")
        totalFound := NumGet(totalBuf, 0, "Int")
        written := NumGet(writtenBuf, 0, "Int")

        return {
            status: status,
            statusText: Vision.StatusToText(status),
            error: Trim(StrGet(errBuf.Ptr, errChars, "UTF-16"), "`r`n`t "),
            totalFound: totalFound,
            written: written,
            points: this.ReadPoints(pointsBuf, written)
        }
    }

    ConfigFromBuffer(cfgBuf) {
        cfg := {}
        yCount := NumGet(cfgBuf, Vision.CFG_O_YELLOW_COUNT, "Int")
        yCount := Max(0, Min(yCount, Vision.MAX_HUE_RANGES))
        gCount := NumGet(cfgBuf, Vision.CFG_O_GREEN_COUNT, "Int")
        gCount := Max(0, Min(gCount, Vision.MAX_HUE_RANGES))

        cfg.yellowHueRanges := []
        Loop yCount {
            i := A_Index - 1
            off := Vision.CFG_O_YELLOW_RANGES + (i * 8)
            cfg.yellowHueRanges.Push([NumGet(cfgBuf, off, "Int"), NumGet(cfgBuf, off + 4, "Int")])
        }
        cfg.yellowSatRange := [NumGet(cfgBuf, Vision.CFG_O_YELLOW_SAT, "Int"), NumGet(cfgBuf, Vision.CFG_O_YELLOW_SAT + 4, "Int")]
        cfg.yellowValRange := [NumGet(cfgBuf, Vision.CFG_O_YELLOW_VAL, "Int"), NumGet(cfgBuf, Vision.CFG_O_YELLOW_VAL + 4, "Int")]

        cfg.morphOpenIterations := NumGet(cfgBuf, Vision.CFG_O_MORPH_OPEN, "Int")
        cfg.morphCloseIterations := NumGet(cfgBuf, Vision.CFG_O_MORPH_CLOSE, "Int")
        cfg.dilateIterations := NumGet(cfgBuf, Vision.CFG_O_DILATE, "Int")

        cfg.minBlobArea := NumGet(cfgBuf, Vision.CFG_O_MIN_BLOB, "Int")
        cfg.maxBlobArea := NumGet(cfgBuf, Vision.CFG_O_MAX_BLOB, "Int")
        cfg.minCircularity := NumGet(cfgBuf, Vision.CFG_O_MIN_CIRC, "Float")
        cfg.minCenterFillRatio := NumGet(cfgBuf, Vision.CFG_O_MIN_FILL, "Float")

        cfg.requirePetalContext := NumGet(cfgBuf, Vision.CFG_O_REQUIRE_CTX, "Int") != 0
        cfg.ringInnerRadiusPercent := NumGet(cfgBuf, Vision.CFG_O_RING_INNER, "Int")
        cfg.ringOuterRadiusPercent := NumGet(cfgBuf, Vision.CFG_O_RING_OUTER, "Int")

        cfg.petalSatRange := [NumGet(cfgBuf, Vision.CFG_O_PETAL_SAT, "Int"), NumGet(cfgBuf, Vision.CFG_O_PETAL_SAT + 4, "Int")]
        cfg.petalValRange := [NumGet(cfgBuf, Vision.CFG_O_PETAL_VAL, "Int"), NumGet(cfgBuf, Vision.CFG_O_PETAL_VAL + 4, "Int")]

        cfg.greenHueRanges := []
        Loop gCount {
            i := A_Index - 1
            off := Vision.CFG_O_GREEN_RANGES + (i * 8)
            cfg.greenHueRanges.Push([NumGet(cfgBuf, off, "Int"), NumGet(cfgBuf, off + 4, "Int")])
        }
        cfg.minPetalRatio := NumGet(cfgBuf, Vision.CFG_O_MIN_PETAL, "Float")
        cfg.drawRejectedCandidates := NumGet(cfgBuf, Vision.CFG_O_DRAW_REJECTED, "Int") != 0
        return cfg
    }

    ConfigToBuffer(configObj) {
        cfg := this.MergeWithDefaultConfig(configObj)
        cfgBuf := Buffer(this.GetConfigStructSize(), 0)

        NumPut("Int", this.GetConfigStructSize(), cfgBuf, Vision.CFG_O_STRUCT_SIZE)

        yRanges := cfg.yellowHueRanges
        if (yRanges.Length < 1) {
            throw Error("yellowHueRanges must contain at least one range.")
        }
        yCount := Min(yRanges.Length, Vision.MAX_HUE_RANGES)
        NumPut("Int", yCount, cfgBuf, Vision.CFG_O_YELLOW_COUNT)
        Loop yCount {
            i := A_Index - 1
            off := Vision.CFG_O_YELLOW_RANGES + (i * 8)
            r := yRanges[A_Index]
            NumPut("Int", r[1], cfgBuf, off)
            NumPut("Int", r[2], cfgBuf, off + 4)
        }

        NumPut("Int", cfg.yellowSatRange[1], cfgBuf, Vision.CFG_O_YELLOW_SAT)
        NumPut("Int", cfg.yellowSatRange[2], cfgBuf, Vision.CFG_O_YELLOW_SAT + 4)
        NumPut("Int", cfg.yellowValRange[1], cfgBuf, Vision.CFG_O_YELLOW_VAL)
        NumPut("Int", cfg.yellowValRange[2], cfgBuf, Vision.CFG_O_YELLOW_VAL + 4)

        NumPut("Int", cfg.morphOpenIterations, cfgBuf, Vision.CFG_O_MORPH_OPEN)
        NumPut("Int", cfg.morphCloseIterations, cfgBuf, Vision.CFG_O_MORPH_CLOSE)
        NumPut("Int", cfg.dilateIterations, cfgBuf, Vision.CFG_O_DILATE)

        NumPut("Int", cfg.minBlobArea, cfgBuf, Vision.CFG_O_MIN_BLOB)
        NumPut("Int", cfg.maxBlobArea, cfgBuf, Vision.CFG_O_MAX_BLOB)
        NumPut("Float", cfg.minCircularity, cfgBuf, Vision.CFG_O_MIN_CIRC)
        NumPut("Float", cfg.minCenterFillRatio, cfgBuf, Vision.CFG_O_MIN_FILL)

        NumPut("Int", cfg.requirePetalContext ? 1 : 0, cfgBuf, Vision.CFG_O_REQUIRE_CTX)
        NumPut("Int", cfg.ringInnerRadiusPercent, cfgBuf, Vision.CFG_O_RING_INNER)
        NumPut("Int", cfg.ringOuterRadiusPercent, cfgBuf, Vision.CFG_O_RING_OUTER)

        NumPut("Int", cfg.petalSatRange[1], cfgBuf, Vision.CFG_O_PETAL_SAT)
        NumPut("Int", cfg.petalSatRange[2], cfgBuf, Vision.CFG_O_PETAL_SAT + 4)
        NumPut("Int", cfg.petalValRange[1], cfgBuf, Vision.CFG_O_PETAL_VAL)
        NumPut("Int", cfg.petalValRange[2], cfgBuf, Vision.CFG_O_PETAL_VAL + 4)

        gRanges := cfg.greenHueRanges
        gCount := Min(gRanges.Length, Vision.MAX_HUE_RANGES)
        NumPut("Int", gCount, cfgBuf, Vision.CFG_O_GREEN_COUNT)
        Loop gCount {
            i := A_Index - 1
            off := Vision.CFG_O_GREEN_RANGES + (i * 8)
            r := gRanges[A_Index]
            NumPut("Int", r[1], cfgBuf, off)
            NumPut("Int", r[2], cfgBuf, off + 4)
        }
        NumPut("Float", cfg.minPetalRatio, cfgBuf, Vision.CFG_O_MIN_PETAL)
        NumPut("Int", cfg.drawRejectedCandidates ? 1 : 0, cfgBuf, Vision.CFG_O_DRAW_REJECTED)

        return cfgBuf
    }

    MergeWithDefaultConfig(overrides) {
        cfg := this.GetDefaultConfig()
        if (overrides = 0 || !IsObject(overrides)) {
            return cfg
        }

        keys := [
            "yellowHueRanges", "yellowSatRange", "yellowValRange",
            "morphOpenIterations", "morphCloseIterations", "dilateIterations",
            "minBlobArea", "maxBlobArea", "minCircularity", "minCenterFillRatio",
            "requirePetalContext", "ringInnerRadiusPercent", "ringOuterRadiusPercent",
            "petalSatRange", "petalValRange",
            "greenHueRanges", "minPetalRatio", "drawRejectedCandidates"
        ]

        isMap := (Type(overrides) = "Map")
        for key in keys {
            if (isMap && overrides.Has(key)) {
                cfg.%key% := overrides[key]
            } else if (!isMap && HasProp(overrides, key)) {
                cfg.%key% := overrides.%key%
            }
        }
        return cfg
    }

    ReadPoints(pointsBuf, pointCount) {
        points := []
        Loop pointCount {
            idx := A_Index - 1
            offset := idx * Vision.POINT_SIZE_BYTES
            x := NumGet(pointsBuf, offset, "Int")
            y := NumGet(pointsBuf, offset + 4, "Int")
            points.Push({ x: x, y: y })
        }
        return points
    }

    static StatusToText(status) {
        switch status {
            case Vision.STATUS_OK:
                return "OK"
            case Vision.STATUS_INVALID_ARGUMENT:
                return "INVALID_ARGUMENT"
            case Vision.STATUS_CONFIG_ERROR:
                return "CONFIG_ERROR"
            case Vision.STATUS_RUNTIME_ERROR:
                return "RUNTIME_ERROR"
            case Vision.STATUS_BUFFER_TOO_SMALL:
                return "BUFFER_TOO_SMALL"
            default:
                return "UNKNOWN(" status ")"
        }
    }
}
