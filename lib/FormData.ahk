class FormData {
    __data := 0
    __New() {
        this.buf := Buffer(1), this.offset := 0
        this.boundary := '------------------------' A_Now A_TickCount
        this.contentType := 'multipart/form-data; boundary=' this.boundary
    }
    append(name, value, size, contentType, filename?) {
        if this.__data
            throw TypeError("Data has been created")
        if !(name is String)
            throw TypeError("Expected a string but received a " Type(name))
        if !(contentType is String)
            throw TypeError("Expected a string but received a " Type(contentType))
        if IsSet(filename) && !filename is String
            throw TypeError("Expected a string but received a " Type(filename))
        str := (this.offset ? '`n' : '') '--' this.boundary '`nContent-Disposition: form-data; name="' name '"' (IsSet(filename) ? '; filename="' filename '"' : '') '`nContent-Type: ' contentType '`n`n' (value is String ? value : '')
        this.buf.Size += len := StrLen(str), StrPut(str, this.buf.ptr + this.offset, 'utf-8'), this.offset += len
        if ( not Value is String)
            this.buf.Size += size, DllCall('RtlMoveMemory', 'ptr', this.buf.ptr + this.offset, 'ptr', value, 'uint', size), this.offset += size
        return this
    }
    data {
        get {
            if this.__data
                return this.__data
            this.buf.Size += StrLen(str := '`n--' this.boundary '--`n'), StrPut(str, this.buf.ptr + this.offset, 'utf-8')
            this.__data := ComObjArray(0x11, this.buf.Size)
            DllCall('oleaut32\SafeArrayAccessData', 'ptr', this.__data, 'ptr*', &p := 0)
            DllCall('RtlMoveMemory', 'ptr', p, 'ptr', this.buf.ptr, 'uint', this.buf.Size)
            DllCall('oleaut32\SafeArrayUnaccessData', 'ptr', this.__data)
            return this.__data
        }
    }
}