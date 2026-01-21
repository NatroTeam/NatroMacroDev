HideErrors := IniRead(A_WorkingDir . "\settings\nm_config.ini", "Settings", "HideErrors", 1)
debugDir := A_WorkingDir "\debug"
if !DirExist(debugDir) {
    DirCreate(debugDir)
    DllCall("SetFileAttributesW", "wstr", debugDir, "uint", 0x2) ; FILE_ATTRIBUTE_HIDDEN
}
OnError ErrorFunction


ErrorFunction(e, mode) {
    static MAX_LOG_SIZE := 1024 * 1024 ; 1 MB
    time := A_NowUTC
    file_name :=
        InStr(e.file, "\") && InStr(e.file, ".") ?
            SubStr(e.file, s := InStr(e.file, "\", , -1) + 1, InStr(e.file, ".", , -1) - s) :
        "unknown"

    text :=
        (
        "####################################
        # Time (UTC): " . time . "
        # File: " . file_name . "
        # Line: " . e.line . "
        # Message: " . e.message . "
        # What: " . e.what . "
        # Extra: " . e.extra . "
        ####################################
        " . e.stack . "
        "
        )
    try {
        f := FileOpen(debugDir . "\" . file_name . ".log", 0x3)
        content := f.Read()
        f.pos := 0
        f.Write(text . content)
        f.pos := Min(f.Length, MAX_LOG_SIZE)
        msgbox f.pos
        if (f.length > MAX_LOG_SIZE) {
            DllCall("kernel32\SetEndOfFile", "ptr", f.Handle)
        }
        msgbox f.Length
        f.Close()
        
    }
    ; catch ignored... if we can't write the log, not much we can do
    if (HideErrors && mode == "Return")
        return -1
    return 0
}
