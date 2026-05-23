#NoTrayIcon
#SingleInstance Force

#Include "%A_ScriptDir%\..\lib"
#Include "Gdip_All.ahk"
#Include "Gdip_ImageSearch.ahk"
#Include "Roblox.ahk"
#Include "nm_OpenMenu.ahk"
#Include "nm_InventorySearch.ahk"

CoordMode "Mouse", "Screen"
OnExit(ExitFunc)
pToken := Gdip_Startup()

bitmaps := Map()
Shrine := Map()

#Include ..\nm_image_assets\general\bitmaps.ahk
bitmaps["greensuccess"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAAA4AAAALCAYAAABPhbxiAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAAhdEVYdENyZWF0aW9uIFRpbWUAMjAyMzowMzowOCAxNToyMzo1N/c+ABwAAAAdSURBVChTY3T+H/6fgQzABKVJBqMa8YDhr5GBAQBwxAKu5PiUjAAAAA5lWElmTU0AKgAAAAgAAAAAAAAA0lOTAAAAAElFTkSuQmCC")

if (MsgBox("BITTERBERRY AUTO FEEDER v0.2 by anniespony#8135``nMake sure BEE SLOT TO MUTATE is always visible``nDO NOT MOVE THE SCREEN OR RESIZE WINDOW FROM NOW ON.``nMAKE SURE BEE IS RADIOACTIVE AT ALL TIMES!", "Bitterberry Auto-Feeder v0.2", 0x40001) = "Cancel") {
    ExitApp
}

loop 10 {
    bitterberrynos := InputBox("Enter the amount of bitterberry used each time", "How many bitterberry?", "w320 h180 T60").Value
    if IsInteger(bitterberrynos) {
        if (bitterberrynos > 30) {
            if (MsgBox("You have entered " bitterberrynos " which is more than 30.``nAre you sure?", "Bitterberry Auto-Feeder v0.2", 0x40034) = "No") {
                ExitApp
            }
        }
        break
    } else {
        MsgBox "You must enter a number for Bitterberries!!", "Bitterberry Auto-Feeder v0.2", 0x40010
    }
}

if (MsgBox("After dismissing this message,``nleft click ONLY once on BEE SLOT", "Bitterberry Auto-Feeder v0.2", 0x40001) = "Cancel") {
    ExitApp
}

hwnd := GetRobloxHWND()
ActivateRoblox()
GetRobloxClientPos(hwnd)
offsetY := GetYOffset(hwnd, &offsetfail)
if (offsetfail = 1) {
    MsgBox "Unable to detect in-game GUI offset!``nStopping Feeder!``n``nThere are a few reasons why this can happen, including:``n - Incorrect graphics settings``n - Your `'Experience Language`' is not set to English``n - Something is covering the top of your Roblox window``n``nJoin our Discord server for support and our Knowledge Base post on this topic (Unable to detect in-game GUI offset)!", "WARNING!!", "0x40030"
    ExitApp
}

StatusBar := Gui("-Caption +E0x80000 +AlwaysOnTop +ToolWindow -DPIScale")
StatusBar.Show("NA")
hbm := CreateDIBSection(windowWidth, windowHeight), hdc := CreateCompatibleDC(), obm := SelectObject(hdc, hbm)
G := Gdip_GraphicsFromHDC(hdc), Gdip_SetSmoothingMode(G, 2), Gdip_SetInterpolationMode(G, 2)
Gdip_FillRectangle(G, pBrush := Gdip_BrushCreateSolid(0x60000000), -1, -1, windowWidth+1, windowHeight+1), Gdip_DeleteBrush(pBrush)
UpdateLayeredWindow(StatusBar.Hwnd, hdc, windowX, windowY, windowWidth, windowHeight)

KeyWait "LButton", "D" ; Wait for the left mouse button to be pressed down.
MouseGetPos &beeX, &beeY
Gdip_GraphicsClear(G), Gdip_FillRectangle(G, pBrush := Gdip_BrushCreateSolid(0xd0000000), -1, -1, windowWidth+1, 38), Gdip_DeleteBrush(pBrush)
Gdip_TextToGraphics(G, "Mutating... Right Click or Shift to Stop!", "x0 y0 cffff5f1f Bold Center vCenter s24", "Tahoma", windowWidth, 38)
UpdateLayeredWindow(StatusBar.Hwnd, hdc, windowX, windowY, windowWidth, 38)
SelectObject(hdc, obm), DeleteObject(hbm), DeleteDC(hdc), Gdip_DeleteGraphics(G)
try {
    Hotkey "Shift", ExitFunc, "On"
    Hotkey "RButton", ExitFunc, "On"
    Hotkey "F11", ExitFunc, "On"
}
Sleep 250

rect := ''
Loop {
    berryRect := nm_InventorySearch("bitterberry",, (A_Index = 1) ? 40 : 4)
    if berryRect == 0 {
        MsgBox "You ran out of Bitterberries!", "Bitterberry Auto-Feeder v0.2", 0x40010
        break
    }
    
    GetRobloxClientPos(hwnd)

    SendEvent "{Click " windowX + 30 " " berryRect.Y + berryRect.H " 0}"
    Send "{Click Down}"
    Sleep 100
    SendEvent "{Click " beeX " " beeY " 0}"
    Sleep 100
    Send "{Click Up}"
    if !rect { ; should be fine to cache
        Loop 20 {
            Sleep 100
            searchResult := findTextInRect("feed:", windowX+windowWidth//2 - 200, windowY+windowHeight//2 - 100, 400, 250, 2)
            if searchResult.Has("Word") {
                rect := searchResult["Word"]
                break
            }
        }
    }
    if rect {
        Sleep 700
        SendEvent "{Click " rect.x + 140 " " rect.y + 5 "}" ; Click Number
        Sleep 100
        Loop StrLen(bitterberrynos) {
            SendEvent "{Text}" SubStr(bitterberrynos, A_Index, 1)
            Sleep 100
        }
        SendEvent "{Click " rect.x " " rect.y "}" ; Click Feed
    }
    Sleep 750
    
    pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2-295 "|" windowY+offsetY+((4*windowHeight)//10 - 15) "|150|50")
    if (Gdip_ImageSearch(pBMScreen, bitmaps["greensuccess"], , , , , , 20) = 1) {
        if (MsgBox("SUCCESS!!!!``nKeep this?", "Bitterberry Auto-Feeder v0.2", 0x40024) = "Yes") {
            Gdip_DisposeImage(pBMScreen)
            break
        } else {
            ActivateRoblox()
            SendEvent "{Click " windowX + (windowWidth//2 - 132) " " windowY + offsetY + ((4*windowHeight)//10 - 150) "}" ; Close Bee
        }
    }

    Gdip_DisposeImage(pBMScreen)
}

ExitFunc(*) {
    try StatusBar.Destroy()
    try Gdip_Shutdown(pToken)
    ExitApp
}