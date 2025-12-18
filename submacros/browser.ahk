;TODO://MAKE THIS MUCH SMARTER PROB

#NoTrayIcon
#SingleInstance Force
#MaxThreads 255
#Include "%A_ScriptDir%\..\lib"
#Include "Gdip_All.ahk"
#Include "Gdip_ImageSearch.ahk"
#Include "JSON.ahk"

DetectHiddenWindows 1
pToken := Gdip_Startup()

(bitmaps := Map()).CaseSense := 0
(fileContents := Map()).CaseSense := 0

; #Include "%A_ScriptDir%\..\nm_image_assets\patterndl\bitmaps.ahk"
bitmaps["TitleBar"] := Gdip_CreateBitmap(500, 32), gTitleBar := Gdip_GraphicsFromImage(bitmaps["TitleBar"]), pBrush := Gdip_BrushCreateSolid(0xff5427F8), Gdip_FillRectangle(gTitleBar, pBrush, 0, 0, 500, 32), Gdip_DeleteBrush(pBrush), Gdip_DeleteGraphics(gTitleBar), gTitleBar := Gdip_GraphicsFromImage(bitmaps["TitleBar"]), Gdip_SetSmoothingMode(gTitleBar, 2), pBrush := Gdip_BrushCreateSolid(0xFFFFFFFF), Gdip_TextToGraphics(gTitleBar, "Custom Paths & Patterns", "s18 Bold Center vCenter cFFFFFFFF", "Arial", 500, 36), Gdip_DeleteBrush(pBrush), Gdip_DeleteGraphics(gTitleBar)
bitmaps["Close"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAABoAAAAaCAYAAACpSkzOAAAACXBIWXMAAAsTAAALEwEAmpwYAAAFsGlUWHRYTUw6Y29tLmFkb2JlLnhtcAAAAAAAPD94cGFja2V0IGJlZ2luPSLvu78iIGlkPSJXNU0wTXBDZWhpSHpyZVN6TlRjemtjOWQiPz4gPHg6eG1wbWV0YSB4bWxuczp4PSJhZG9iZTpuczptZXRhLyIgeDp4bXB0az0iQWRvYmUgWE1QIENvcmUgNy4xLWMwMDAgNzkuOWNjYzRkZSwgMjAyMi8wMy8xNC0xMToyNjoxOSAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvIiB4bWxuczpkYz0iaHR0cDovL3B1cmwub3JnL2RjL2VsZW1lbnRzLzEuMS8iIHhtbG5zOnBob3Rvc2hvcD0iaHR0cDovL25zLmFkb2JlLmNvbS9waG90b3Nob3AvMS4wLyIgeG1sbnM6eG1wTU09Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9tbS8iIHhtbG5zOnN0RXZ0PSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvc1R5cGUvUmVzb3VyY2VFdmVudCMiIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIDIzLjMgKFdpbmRvd3MpIiB4bXA6Q3JlYXRlRGF0ZT0iMjAyMy0wMi0wN1QxNzo1Mzo1NVoiIHhtcDpNb2RpZnlEYXRlPSIyMDIzLTAyLTA3VDE3OjU2OjIyWiIgeG1wOk1ldGFkYXRhRGF0ZT0iMjAyMy0wMi0wN1QxNzo1NjoyMloiIGRjOmZvcm1hdD0iaW1hZ2UvcG5nIiBwaG90b3Nob3A6Q29sb3JNb2RlPSIzIiB4bXBNTTpJbnN0YW5jZUlEPSJ4bXAuaWlkOjE4OTVjNTRhLWFmZGMtZDU0ZC1hOTUyLTdiNTQ4NDQxNWEwNiIgeG1wTU06RG9jdW1lbnRJRD0iYWRvYmU6ZG9jaWQ6cGhvdG9zaG9wOmI1ZGZiN2M1LTFkYWYtMGI0ZS05MjAzLTNiNDIwZDc0Y2MxOSIgeG1wTU06T3JpZ2luYWxEb2N1bWVudElEPSJ4bXAuZGlkOjBhMThjNWRmLTlhZDQtZjU0ZC05OTM2LTk2MmUxNGE0MTRhNyI+IDx4bXBNTTpIaXN0b3J5PiA8cmRmOlNlcT4gPHJkZjpsaSBzdEV2dDphY3Rpb249ImNyZWF0ZWQiIHN0RXZ0Omluc3RhbmNlSUQ9InhtcC5paWQ6MGExOGM1ZGYtOWFkNC1mNTRkLTk5MzYtOTYyZTE0YTQxNGE3IiBzdEV2dDp3aGVuPSIyMDIzLTAyLTA3VDE3OjUzOjU1WiIgc3RFdnQ6c29mdHdhcmVBZ2VudD0iQWRvYmUgUGhvdG9zaG9wIDIzLjMgKFdpbmRvd3MpIi8+IDxyZGY6bGkgc3RFdnQ6YWN0aW9uPSJzYXZlZCIgc3RFdnQ6aW5zdGFuY2VJRD0ieG1wLmlpZDoxODk1YzU0YS1hZmRjLWQ1NGQtYTk1Mi03YjU0ODQ0MTVhMDYiIHN0RXZ0OndoZW49IjIwMjMtMDItMDdUMTc6NTY6MjJaIiBzdEV2dDpzb2Z0d2FyZUFnZW50PSJBZG9iZSBQaG90b3Nob3AgMjMuMyAoV2luZG93cykiIHN0RXZ0OmNoYW5nZWQ9Ii8iLz4gPC9yZGY6U2VxPiA8L3htcE1NOkhpc3Rvcnk+IDwvcmRmOkRlc2NyaXB0aW9uPiA8L3JkZjpSREY+IDwveDp4bXBtZXRhPiA8P3hwYWNrZXQgZW5kPSJyIj8+dPVL6AAAAoNJREFUSImVls1LVFEYxp+ZWogbESKp0Ejp28nChJiiqFUJ/QERQbTURUVtooUtUlq0yChcRLmRaFEThZCGVlSGERE2ORFEJVT0RUGLIDJ+LeZce+fMPXf0hcPMeb7ee++593BSgCrUckk7JWUlrZZUJykl6Yukl5LGJQ1LKiSmAKHRBuSYfQ0CW0J5qcAd9Ug65mFTkiYlfXTzOklrJTV6ul5Jh2ZzR4PelV4CtiXceRbo8zz3gLTV+aYhI84DGxMa+KMZeGz8Y6FGPUZ0B0jNoYkdN0xOn99olSFfe8YFQFWF8GXe/JnJa7ONbhtihTHUAt+ByYQm3cA0sNtgi0zek6hRvQEvG3Ej8MtwwzFNDlNa+wx33uBrBBw0QKv3OL55QTnDd1BeewzfZPATAq66yfuYK64GJrywXmB/TJPtMf6C40bs5HqMUMB8YDwmOKq/wOaAt99p3qbdFy5JnwK71LSkTZKuxHAFSRlJYwHvZ/dbk7abREAc1WgM9k7Jm+lMZlrSV/d/YYKhQ9KFGLxdUi7BF2X+lFsbgKnAc/Zf4Q8UtxdbtwLe546/K+CoMWSMqAroiln4Bsf7L8gosMT4GwzXHX2YUV00wnWUV9bwaYobr63jhj9t8PUReN+A9Q6bB3QaPO47qQZeOf4aUMP/reuPw/OYva7FBOa9sCPA3pgm0VgMnPQwu4ZbbSMBZw15MyG40hgwOQMR7oseGtEjYOUcGiwFRox/wvK+OE3pegGcATYkNGgGTgG/jecpxfWb0YUOJ+ckdXrYC0l5lR5OMpJaPF2/pANliQlXusN7FJXqAdAeygvdka1WSbtUPEA2SapV8QD5Q9IbFQ+QQ+43WP8ANwq8BrGnZFkAAAAASUVORK5CYII=")
bitmaps["LeftArrow"] := Gdip_CreateBitmap(30, 30), gLeft := Gdip_GraphicsFromImage(bitmaps["LeftArrow"]), Gdip_SetSmoothingMode(gLeft, 2), pPen := Gdip_CreatePen(0xff704AFE, 3), Gdip_DrawLine(gLeft, pPen, 20, 8, 8, 15), Gdip_DrawLine(gLeft, pPen, 8, 15, 20, 22), Gdip_DeletePen(pPen), Gdip_DeleteGraphics(gLeft)
bitmaps["RightArrow"] := Gdip_CreateBitmap(30, 30), gRight := Gdip_GraphicsFromImage(bitmaps["RightArrow"]), Gdip_SetSmoothingMode(gRight, 2), pPen := Gdip_CreatePen(0xff704AFE, 3), Gdip_DrawLine(gRight, pPen, 10, 8, 22, 15), Gdip_DrawLine(gRight, pPen, 22, 15, 10, 22), Gdip_DeletePen(pPen), Gdip_DeleteGraphics(gRight)
bitmaps["DownloadArrow"] := Gdip_CreateBitmap(30, 30), gDownload := Gdip_GraphicsFromImage(bitmaps["DownloadArrow"]), Gdip_SetSmoothingMode(gDownload, 2), pPen := Gdip_CreatePen(0xff704AFE, 3), Gdip_DrawLine(gDownload, pPen, 15, 5, 15, 18), Gdip_DrawLine(gDownload, pPen, 15, 18, 8, 11), Gdip_DrawLine(gDownload, pPen, 15, 18, 22, 11), Gdip_DeletePen(pPen), pPen := Gdip_CreatePen(0xff704AFE, 3), Gdip_DrawLine(gDownload, pPen, 5, 25, 25, 25), Gdip_DeletePen(pPen), Gdip_DeleteGraphics(gDownload)

currentMode := "patterns"
currentIndex := 1
fileList := []
currentContent := ""
w := 500, h := 700

cacheDir := A_ScriptDir "\..\settings\cache"
if !DirExist(cacheDir)
    DirCreate(cacheDir)

PatternDownloader := Gui("-Caption +E0x80000 +E0x8000000 +LastFound +AlwaysOnTop +ToolWindow +OwnDialogs -DPIScale")
hMain := PatternDownloader.Hwnd
PatternDownloader.OnEvent("Close", (*) => GetOut())
PatternDownloader.OnEvent("Escape", (*) => GetOut())
PatternDownloader.Show("NA")

PatternDownloader.Add("Text", "x0 y0 w" w " h32 vTitle BackgroundTrans")
PatternDownloader.Add("Text", "x10 y6 w100 h20 vToggleMode BackgroundTrans")
PatternDownloader.Add("Text", "x" w-32 " y3 w26 h26 vClose BackgroundTrans")
PatternDownloader.Add("Text", "x50 y" h-40 " w30 h30 vLeftArrow BackgroundTrans")
PatternDownloader.Add("Text", "x" w-80 " y" h-40 " w30 h30 vRightArrow BackgroundTrans")
PatternDownloader.Add("Text", "x" w-45 " y" h-40 " w30 h30 vDownloadBtn BackgroundTrans")

hbm := CreateDIBSection(w, h)
hdc := CreateCompatibleDC()
obm := SelectObject(hdc, hbm)
G := Gdip_GraphicsFromHDC(hdc)
Gdip_SetSmoothingMode(G, 2)
Gdip_SetInterpolationMode(G, 2)

UpdateLayeredWindow(hMain, hdc, (A_ScreenWidth-w)//2, (A_ScreenHeight-h)//2, w, h)

CacheOrFetch()
LoadFiles()
nm_PatternGUI()
return

CacheOrFetch() {
    global cacheDir
    
    patternsCacheDir := cacheDir "\patterns"
    pathsCacheDir := cacheDir "\paths"
    
    needsFetch := false
    
    if !DirExist(patternsCacheDir) || !DirExist(pathsCacheDir)
        needsFetch := true
    else {
        patternFiles := []
        pathFiles := []
        Loop Files, patternsCacheDir "\*.ahk"
            patternFiles.Push(A_LoopFileName)
        Loop Files, pathsCacheDir "\*.ahk"
            pathFiles.Push(A_LoopFileName)
        
        if patternFiles.Length = 0 || pathFiles.Length = 0
            needsFetch := true
    }
    
    if needsFetch {
        if !DirExist(patternsCacheDir)
            DirCreate(patternsCacheDir)
        if !DirExist(pathsCacheDir)
            DirCreate(pathsCacheDir)
        
        patternsList := Fetch("patterns")
        
        totalPatterns := patternsList.Length
        Loop totalPatterns {
            fileName := patternsList[A_Index]
            url := "https://raw.githubusercontent.com/NatroTeam/NatroMacro/main/patterns/" fileName
            
            try {
                cmx := ComObject("WinHttp.WinHttpRequest.5.1")
                cmx.Open("GET", url, 1)
                cmx.SetRequestHeader("User-Agent", "AutoHotkey-Script")
                cmx.Send()
                cmx.WaitForResponse()
                
                cacheFile := patternsCacheDir "\" fileName
                FileAppend(cmx.ResponseText, cacheFile, "UTF-8")
            }
        }
        
        pathsList := Fetch("paths")
        
        totalPaths := pathsList.Length
        Loop totalPaths {
            fileName := pathsList[A_Index]
            url := "https://raw.githubusercontent.com/NatroTeam/NatroMacro/main/paths/" fileName
            
            try {
                cmx := ComObject("WinHttp.WinHttpRequest.5.1")
                cmx.Open("GET", url, 1)
                cmx.SetRequestHeader("User-Agent", "AutoHotkey-Script")
                cmx.Send()
                cmx.WaitForResponse()
                
                cacheFile := pathsCacheDir "\" fileName
                FileAppend(cmx.ResponseText, cacheFile, "UTF-8")
            }
        }
    }
}

LoadFiles() {
    global fileList, currentIndex, currentMode, fileContents, cacheDir
    
    fileList := []
    cacheSubDir := cacheDir "\" currentMode
    
    Loop Files, cacheSubDir "\*.ahk" {
        fileList.Push(A_LoopFileName)
    }
    
    currentIndex := 1
    
    if fileList.Length > 0
        LoadFileContent()
}

LoadFileContent() {
    global fileList, currentIndex, currentMode, currentContent, cacheDir
    
    if (fileList.Length = 0) {
        currentContent := "No files found"
        return
    }
    
    fileName := fileList[currentIndex]
    cacheFile := cacheDir "\" currentMode "\" fileName
    
    try {
        rawContent := FileRead(cacheFile, "UTF-8")
    } catch {
        currentContent := "Error reading file"
        return
    }
    
    commentLines := []
    lines := StrSplit(rawContent, "`n", "`r")
    
    for line in lines {
        trimmed := Trim(line)
        if (SubStr(trimmed, 1, 1) = ";") {
            comment := Trim(SubStr(trimmed, 2))
            if (comment != "")
                commentLines.Push(comment)
        }
    }
    
    currentContent := ""
    for comment in commentLines
        currentContent .= comment "`n"
    
    if currentContent = ""
        currentContent := "No description found for pattern!"
}

nm_PatternGUI() {
    global
    local yPos := 50
    
    Gdip_GraphicsClear(G)

    pBrush := Gdip_BrushCreateSolid(0xff9F85FD), Gdip_FillRectangle(G, pBrush, 0, 0, w, h), Gdip_DeleteBrush(pBrush)
    
    Gdip_DrawImage(G, bitmaps["TitleBar"], 0, 0)
    Gdip_DrawImage(G, bitmaps["Close"], w-32, 3)
    
    pBrush := Gdip_BrushCreateSolid(0xff582AFF)
    Gdip_FillRoundedRectangle(G, pBrush, 10, 6, 100, 20, 4)
    Gdip_DeleteBrush(pBrush)

    pPen := Gdip_CreatePen(0x40000000, 1)
    Gdip_DrawRoundedRectangle(G, pPen, 10, 6, 100, 20, 4)
    Gdip_DeletePen(pPen)
    
    modeText := (currentMode = "patterns") ? "Patterns" : "Paths"
    Gdip_TextToGraphics(G, modeText, "x10 y7 w100 h20 Center vCenter Bold s10 cFFFFFFFF", "Arial")

    pBrush := Gdip_BrushCreateSolid(0xff1a1a2e)
    Gdip_FillRectangle(G, pBrush, 10, 45, w-20, h-95), Gdip_DeleteBrush(pBrush)
    
    if (currentContent != "" && currentContent != "Error fetching files!" && currentContent != "Error loading file!") {
        lines := StrSplit(currentContent, "`n", "`r")
        yPos := 55
        
        Loop Min(30, lines.Length) {
            Gdip_TextToGraphics(G, Trim(lines[A_Index]), "x20 y" yPos " s18 cFFFFFFFF", "Arial", w, h)
            yPos += 20
            if yPos > h-100
                break
        }
    } else
        Gdip_TextToGraphics(G, "Content: " SubStr(currentContent, 1, 50), "x50 y300 s12 cFFFFFFFF", "Arial", w, h)
    
    Gdip_DrawImage(G, bitmaps["LeftArrow"], 50, h-40)
    Gdip_DrawImage(G, bitmaps["RightArrow"], w-80, h-40)
    Gdip_DrawImage(G, bitmaps["DownloadArrow"], w-45, h-40)
    
    if (fileList.Length > 0) {
        fileName := fileList[currentIndex]
        fileText := currentIndex "/" fileList.Length " - " StrReplace(fileName, ".ahk", "")
        
        pBrush := Gdip_BrushCreateSolid(0xff1a1a2e)
        Gdip_FillRoundedRectangle(G, pBrush, 90, h-40, w-180, 30, 5)
        Gdip_DeleteBrush(pBrush)
        
        Options := "x" 90 " y" (h-38) " w" (w-180) " h30 Center vCenter Bold s17 cFFFFFFFF"
        Gdip_TextToGraphics(G, fileText, Options, "Arial", w, h)
    }
    
    UpdateLayeredWindow(hMain, hdc)
    OnMessage(0x200, WM_MOUSEMOVE)
    OnMessage(0x201, WM_LBUTTONDOWN)
    OnMessage(0x202, WM_LBUTTONUP)
}

WM_MOUSEMOVE(*) {
    global
    local hCtrl, ctrl
    
    MouseGetPos , , , &hCtrl, 2
    if !hCtrl
        return 0
    
    try {
        ctrl := GuiCtrlFromHwnd(hCtrl)
        if !ctrl
            return 0
        
        name := ctrl.Name
        if !name
            return 0
        
        switch name, 0 {
            case "ToggleMode", "Close", "LeftArrow", "RightArrow", "DownloadBtn":
                hover_ctrl := hCtrl
                ReplaceSystemCursors("IDC_HAND")
                while (hCtrl = hover_ctrl) {
                    Sleep 20
                    MouseGetPos , , , &hCtrl, 2
                }
                ReplaceSystemCursors()
        }
    }
    return 0
}

WM_LBUTTONDOWN(wParam, lParam, msg, hwnd) {
    global currentMode, fileList, currentIndex, PatternDownloader
    local hCtrl, ctrl, ctrlName
    
    MouseGetPos ,, , &hCtrl, 2
    try {
        ctrl := GuiCtrlFromHwnd(hCtrl)
        if !ctrl
            return 0
        ctrlName := ctrl.Name
    } catch
        return 0
    
    switch ctrlName {
        case "Close":
            GetOut()
        case "ToggleMode":
            currentMode := (currentMode = "patterns") ? "paths" : "patterns"
            LoadFiles()
            nm_PatternGUI()
        case "LeftArrow":
            if (fileList.Length > 0) {
                currentIndex--
                if (currentIndex < 1)
                    currentIndex := fileList.Length
                LoadFileContent()
                nm_PatternGUI()
            }
        case "RightArrow":
            if fileList.Length > 0 {
                currentIndex++
                if currentIndex > fileList.Length
                    currentIndex := 1
                LoadFileContent()
                nm_PatternGUI()
            }
        case "DownloadBtn":
            DownloadPattern()
        case "Title":
            PostMessage 0xA1, 2
    }
}

GetFiles(url) {
    try {
        cmx := ComObject("WinHttp.WinHttpRequest.5.1")
        cmx.Open("GET", url, 1)
        cmx.SetRequestHeader("User-Agent", "AutoHotkey-Script")
        cmx.Send()
        cmx.WaitForResponse()
        
        data := JSON.parse(cmx.ResponseText, false, true)
        fileList := []
        
        if Type(data) = "Array" {
            for item in data {
                if Type(item) = "Map" && item.Has("name") && InStr(item["name"], ".ahk")
                    fileList.Push(item["name"])
            }
        }
        
        return fileList
    }
    return []
}

Fetch(type) {
    type := StrLower(type)
    urls := Map(
        "paths", "https://api.github.com/repos/NatroTeam/NatroMacro/contents/paths",
        "patterns", "https://api.github.com/repos/NatroTeam/NatroMacro/contents/patterns")
    
    return GetFiles(urls[type])
}

WM_LBUTTONUP(*) {
    ReplaceSystemCursors()
    return 0
}

DownloadPattern() {
    global currentIndex, fileList, currentMode, cacheDir
    
    if fileList.Length = 0 {
        MsgBox("No files available to download!", "Error", 0x40044)
        return
    }
    
    fileName := fileList[currentIndex]
    cacheFile := cacheDir "\" currentMode "\" fileName

    destFolder := A_ScriptDir "\.." (currentMode = "patterns" ? "\patterns" : "\paths")
    destFile := destFolder "\" fileName

    if !DirExist(destFolder) {
        try DirCreate(destFolder)
        catch {
            MsgBox("Could not create destination folder!", "Error", 0x40044)
            return
        }
    }

    if FileExist(destFile) {
        result := MsgBox("File already exists! Overwrite?", "Confirm", 0x40044)
        if result = "No"
            return
    }

    try {
        if FileExist(destFile)
            FileDelete(destFile)
        FileCopy(cacheFile, destFile, 1)
        
        displayName := StrReplace(fileName, ".ahk", "")
        MsgBox("Successfully downloaded: " displayName, "Success", 0x40044)
        
    } catch as err 
        MsgBox("Failed to download file!`n`nError: " err.Message, "Error", 0x40044)
}

ReplaceSystemCursors(IDC := "") {
    static IMAGE_CURSOR := 2, SPI_SETCURSORS := 0x57
         , SysCursors := Map(
              "IDC_APPSTARTING", 32650
            , "IDC_ARROW"     , 32512
            , "IDC_CROSS"     , 32515
            , "IDC_HAND"      , 32649
            , "IDC_HELP"      , 32651
            , "IDC_IBEAM"     , 32513
            , "IDC_NO"        , 32648
            , "IDC_SIZEALL"   , 32646
            , "IDC_SIZENESW"  , 32643
            , "IDC_SIZENWSE"  , 32642
            , "IDC_SIZEWE"    , 32644
            , "IDC_SIZENS"    , 32645
            , "IDC_UPARROW"   , 32516
            , "IDC_WAIT"      , 32514 )
    
    if !IDC
        DllCall("SystemParametersInfo", "UInt", SPI_SETCURSORS, "UInt", 0, "UInt", 0, "UInt", 0)
    else {
        hCursor := DllCall("LoadCursor", "Ptr", 0, "UInt", SysCursors[IDC], "Ptr")
        for k, v in SysCursors {
            hCopy := DllCall("CopyImage", "Ptr", hCursor, "UInt", IMAGE_CURSOR, "Int", 0, "Int", 0, "UInt", 0, "Ptr")
            DllCall("SetSystemCursor", "Ptr", hCopy, "UInt", v)
        }
    }
}

GetOut() {
    global pToken
    try Gdip_Shutdown(pToken)
    ExitApp()
}

F3::Reload