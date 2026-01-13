HideErrors := IniRead(A_WorkingDir . "\settings\nm_config.ini", "Settings", "HideErrors", 1)
debugDir := A_WorkingDir "\debug"
if !DirExist(debugDir) {
    DirCreate(debugDir)
    if !DllCall("SetFileAttributesW", "wstr", debugDir, "uint", 0x2) ; FILE_ATTRIBUTE_HIDDEN
        msgbox "Failed to set hidden attribute on debug directory. LastError: " . A_LastError,, "T10"
        ; Failed to set hidden attribute on debug directory (permissions issue?). msgbox with 10s timeout.
        ; This is non-fatal, and should basically never happen
}
OnError ErrorFunction


; mode = "Return" => -1
ErrorFunction(e, mode) {
    time := A_NowUTC . A_MSec

    text :=
    (
    "##################
    # ERROR LOG FILE #
    ##################
    # Time (UTC): " . time . "
    # File: " . e.file . "
    # Line: " . e.line . "
    # Message: " . e.message . "
    # What: " . e.what . "
    # Extra: " . e.extra . "
    ##################
    " . e.stack . "
    "
    )
    outfile :=
        InStr(e.file, "\") && InStr(e.file, ".") ?
            SubStr(e.file, s:=InStr(e.file, "\",, -1) + 1, InStr(e.file, ".",, -1) - s) . "_" . time . ".log" :
            "unknown_" . time . ".log"
    
    try FileAppend(text, debugDir . "\" . outfile)
    ; catch ignored... if we can't write the log, not much we can do
    if (HideErrors && mode == "Return")
        return -1
    return 0
}
