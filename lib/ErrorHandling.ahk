HideErrors := IniRead(A_WorkingDir . "\settings\nm_config.ini", "Settings", "HideErrors", 1)
debugDir := A_WorkingDir "\debug"
if !DirExist(debugDir) {
    DirCreate(debugDir)
    DllCall("SetFileAttributesW", "wstr", debugDir, "uint", 0x2) ; FILE_ATTRIBUTE_HIDDEN
}
OnError ErrorFunction


ErrorFunction(e, mode) {
    time := A_NowUTC

    text :=
    (
    "####################################
    # Time (UTC): " . time . "
    # File: " . e.file . "
    # Line: " . e.line . "
    # Message: " . e.message . "
    # What: " . e.what . "
    # Extra: " . e.extra . "
    ####################################
    " . e.stack . "
    "
    )
    outfile :=
        InStr(e.file, "\") && InStr(e.file, ".") ?
            SubStr(e.file, s:=InStr(e.file, "\",, -1) + 1, InStr(e.file, ".",, -1) - s) . ".log" :
            "unknown_" . time . ".log"
    
    try FileAppend(text, debugDir . "\" . outfile)
    ; catch ignored... if we can't write the log, not much we can do
    if (HideErrors && mode == "Return")
        return -1
    return 0
}
