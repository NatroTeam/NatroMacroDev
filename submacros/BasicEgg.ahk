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

(bitmaps := Map()).CaseSense := 0
Shrine := Map()

#Include ../nm_image_assets/general/bitmaps.ahk

if (MsgBox("WELCOME TO THE BASIC BEE REPLACEMENT PROGRAM!!!!!``nMade by anniespony#8135``n``nMake sure BEE SLOT TO CHANGE is always visible``nDO NOT MOVE THE SCREEN ORRESIZE WINDOW FROM NOW ON.``nMAKE SURE AUTO-JELLY IS DISABLED!!", "Basic Bee Replacement Program", 0x40001) = "Cancel")
	ExitApp

if (MsgBox("After dismissing this message,``nleft click ONLY once on BEE SLOT", "Basic Bee Replacement Program", 0x40001) = "Cancel")
	ExitApp

hwnd := GetRobloxHWND()
ActivateRoblox()
GetRobloxClientPos()
offsetY := GetYOffset(hwnd, &offsetfail)
if (offsetfail = 1) {
	MsgBox "Unable to detect in-game GUI offset!``nStopping Feeder!``n``nThere are a few reasons why this can happen, including:``n - Incorrect graphics settings``n - Your `'Experience Language`' is not set to English``n - Something is covering the top of your Roblox window``n``nJoin our Discord server for support and our Knowledge Base post on this topic (Unable to detect in-game GUI offset)!", "WARNING!!", 0x40030
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
Gdip_TextToGraphics(G, "Hatching... Right Click or Shift to Stop!", "x0 y0 cffff5f1f Bold Center vCenter s24", "Tahoma", windowWidth, 38)
UpdateLayeredWindow(StatusBar.Hwnd, hdc, windowX, windowY, windowWidth, 38)
SelectObject(hdc, obm), DeleteObject(hbm), DeleteDC(hdc), Gdip_DeleteGraphics(G)
Hotkey "Shift", ExitFunc, "On"
Hotkey "RButton", ExitFunc, "On"
Hotkey "F11", ExitFunc, "On"
Sleep 250

curItem := "BasicEgg"
displayName := Map(
	"BasicEgg", "Basic Eggs!",
	"RoyalJelly", "Royal Jellies!"
)

Loop {
	itemRect := nm_InventorySearch(curItem,, 70)
	if not itemRect {
		MsgBox "You ran out of " displayName[curItem], "Basic Bee Replacement Program", 0x40010
		break
	}

	GetRobloxClientPos(hwnd)
	SendEvent "{Click " windowX + 30 " " itemRect.Y + itemRect.H " 0}"
	Send "{Click Down}"
	Sleep 100
	SendEvent "{Click " beeX " " beeY " 0}"
	Sleep 100
	Send "{Click Up}"
	found := false
	Loop 10 {
		Sleep 100
        searchResult := findTextInRect("yes", windowX+windowWidth//2-250, windowY+windowHeight//2-52, 500, 150)
		if searchResult.Has("Word") {
			itemRect := searchResult["Word"].BoundingRect
			SendEvent "{Click " itemRect.x " " itemRect.y " 0}"
			Click
			found := true
		} else if found {
			break
		}

		if (A_Index = 10) { ; force swap
			curItem := curItem = "BasicEgg" ? "RoyalJelly" : "BasicEgg"
			continue 2
		}
	}
	Sleep 750

	beeText := ''
	rarityText := ''
	Loop 8 {
		lines := OCR.FromRect(windowX+windowWidth//2-155, windowY+windowHeight//2 - 300, 310, 600, {scale:3}).Lines
		rarityLine := 4
		beeLine := 3

		if (InStr(StrLower(lines[1].Text), 'hatched') or InStr(StrLower(lines[1].Text), 'transformed')) and lines[2].Text != 'x' {
			rarityLine -= 1
			beeLine -= 1
		}

		rarityText := StrLower(lines[rarityLine].Text)
		beeText := StrLower(lines[beeLine].Text)

		if !InStr(beeText, 'bee') {
			Sleep 100
			if A_Index == 8 { ; Probably gifted basic bee
				; Windows EN-US OCR isn't able to detect it for whatever reason
				if (MsgBox("Couldn't detect the bee type, would you like to keep it?", "Basic Bee Replacement Program", 0x40024) = "Yes") {
					break 2
				}
			}
		} else {
			break
		}
	}

	if InStr(rarityText, 'mythic') { ; Mythic Hatched
		if (MsgBox("MYTHIC!!!!``nKeep this?", "Basic Bee Replacement Program", 0x40024) = "Yes") {
			break
		}
	} else if InStr(beeText, 'gifted') {
		MsgBox rarityText '`n' beeText
		if InStr(beeText, 'basic') { ; Gifted basic bee
			MsgBox "SUCCESS!!!!", "Basic Bee Replacement Program", 0x40020
			break
		} else if (MsgBox("GIFTED!!!!``nKeep this?", "Basic Bee Replacement Program", 0x40024) = "Yes") {  ; Non-Basic Gifted Hatched
			break
		}
	} else if !InStr(rarityText, 'common') { ; got a non basic bee, use basic egg again
		curItem := 'BasicEgg'
	} else {
		curItem := 'RoyalJelly'
	}
}
ExitApp

ExitFunc(*) {
	try Gdip_Shutdown(pToken)
	try StatusBar.Destroy()
	ExitApp
}