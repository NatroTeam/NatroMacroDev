Class Attachment {
    ptr := 0, size := 0, contentType := '', filename := '', description := ''
    Class File extends Attachment {
        __New(path, contentType?, description?) {
            if !(path is String)
                throw TypeError("Expected a string but received a " Type(path))
            if !FileExist(path)
                throw TypeError("File does not exist")
            if IsSet(description) && description is String
                this.description := description
            f := FileOpen(path, "R")
            f.RawRead(buf := Buffer(this.size := f.Length, 0)), this.ptr := buf.Ptr
            if !IsSet(contentType) || !contentType {
                this.contentType := (n := f.ReadUInt() = 0x474E5089) ? "image/png"
                    : n = 0x38464947 ? "image/gif"
                    : n = 0x25504446 ? "application/pdf"
                    : n = 0x504B0304 ? "application/zip"
                    : n = 0x504B0506 ? "application/zip"
                    : n = 0x504B0708 ? "application/zip"
                    : n & 0xFFFF = 0x4D42 ? "image/bmp"
                    : n & 0xFFFF = 0xD8FF ? "image/jpeg"
                    : n & 0xFFFF = 0x4949 ? "image/tiff"
                    : n & 0xFFFF = 0x4D4D ? "image/tiff"
                    : 'application/octet-stream'
            }
            else this.contentType := contentType
            SplitPath(path, &filename)
            this.filename := filename
            f.Close()
        }
    }
    Class Bitmap extends Attachment {
        contentType := "image/png", hGlobal := 0
        __New(pBitmap, filename := 'image.png', description?) {
            if !(pBitmap is Integer)
                throw TypeError("Expected an integer but received a " Type(pBitmap))
            if !(filename is String)
                throw TypeError("Expected a string but received a " Type(filename))
            if IsSet(description) && description is String
                this.description := description
            DllCall("gdiplus\GdipGetImageEncodersSize", "uintp", &n := 0, "uintp", &s := 0)
            if !n || !s
                throw OSError("Failed to get GdipGetImageEncodersSize")
            buf := Buffer(s)
            DllCall("GdiPlus\GdipGetImageEncoders", "uint", n, "uint", s, "ptr", buf)
            loop n
                if InStr(StrGet(NumGet(buf, (idx := (48 + 7 * A_PtrSize) * (A_Index - 1)) + 32 + 3 * A_PtrSize, "UPtr"), "UTF-16"), "*.PNG")
                    this.hGlobal := DllCall("GlobalAlloc", "uint", 0x2, "uint", 0), DllCall("ole32\CreateStreamOnHGlobal", "ptr", this.hGlobal, "int", 1, "ptrp", &pStream := 0), DllCall("GdiPlus\GdipSaveImageToStream", "ptr", pBitmap, "ptr", pStream, "ptr", buf.ptr + idx, "ptr", 0)
            if !this.HasProp('hGlobal')
                throw OSError('Can`'t find PNG encoder')
            this.ptr := DllCall("GlobalLock", "ptr", this.hGlobal), this.size := DllCall("GlobalSize", "ptr", this.hGlobal), this.filename := filename
        }
        __Delete() {
            if !this.hGlobal
                return
            if !this.ptr
                return DllCall("GlobalFree", "ptr", this.hGlobal)
            DllCall("GlobalUnlock", "ptr", this.ptr), DllCall("GlobalFree", "ptr", this.hGlobal)
        }
    }
}