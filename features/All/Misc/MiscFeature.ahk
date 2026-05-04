#Requires AutoHotkey v2.0

global miscConfigLoc := "features\All\Quests\nm_misc_config.ini"

;this is this features GUI lines-of-code used to calculate loading progress
MiscFeatureProgressVolume := (MiscFeature) ? 20 : 0
;this is the running total of all macro features included in the load progress metric
LoadingProgressVolume := (MiscFeature) ? LoadingProgressVolume+MiscFeatureProgressVolume : LoadingProgressVolume

nm_MiscTab(*) {
	global
	TabCtrl.UseTab("Misc")
	MainGui.SetFont("w700")
	MainGui.Add("GroupBox", "x5 y24 w160 h144", "Hive Tools")
	MainGui.Add("GroupBox", "x5 y168 w160 h62", "Other Tools")
	MainGui.Add("GroupBox", "x170 y24 w160 h62", "Calculators")
	MainGui.Add("GroupBox", "x170 y106 w160 h62", "Roblox FPS Editor")
	MainGui.Add("GroupBox", "x170 y168 w160 h62 vAutoClickerButton", "AutoClicker (" AutoClickerHotkey ")")
	MainGui.Add("GroupBox", "x335 y24 w160 h84", "Macro Tools")
	MainGui.Add("GroupBox", "x335 y108 w160 h60", "Discord Tools")
	MainGui.Add("GroupBox", "x335 y168 w160 h62", "Bugs and Suggestions")
	MainGui.SetFont("s9 cDefault Norm", "Tahoma")
	;hive tools
	MainGui.Add("Button", "x10 y40 w150 h40 vBasicEggHatcherButton Disabled", "Gifted Basic Bee`nAuto-Hatcher").OnEvent("Click", nm_BasicEggHatcher)
	MainGui.Add("Button", "x10 y82 w150 h40 vBitterberryFeederButton Disabled", "Bitterberry`nAuto-Feeder").OnEvent("Click", nm_BitterberryFeeder)
	MainGui.Add("Button", "x10 y124 w150 h40 vAutoMutatorButton Disabled", "Auto-Jelly").OnEvent("Click", blc_mutations)
	;other tools
	MainGui.Add("Button", "x10 y184 w150 h42 vGenerateBeeListButton Disabled", "Export Hive Bee List`n(for Hive Builder)").OnEvent("Click", nm_GenerateBeeList)
	;calculators
	MainGui.Add("Button", "x175 y40 w150 h40 vBSSCalculatorsButton Disabled", "BSS Calculators`n(Google Sheets)").OnEvent("Click", nm_BSSCalculators)
	;fps editor
	MainGui.Add("Button", "x175 y122 w150 h40 vRobloxFPSButton Disabled", "Edit FPS").OnEvent("Click", robloxFPSGui)
	;autoclicker
	MainGui.Add("Button", "x175 y184 w150 h42 vAutoClickerGUI Disabled", "AutoClicker`nSettings").OnEvent("Click", nm_AutoClickerButton)
	;macro tools
	MainGui.Add("Button", "x340 y40 w150 h20 vHotkeyGUI Disabled", "Change Hotkeys").OnEvent("Click", nm_HotkeyGUI)
	MainGui.Add("Button", "x340 y62 w150 h20 vDebugLogGUI Disabled", "Debug Options").OnEvent("Click", nm_DebugLogGUI)
	MainGui.Add("Button", "x340 y84 w150 h20 vAutoStartManagerGUI Disabled", "Auto-Start Manager").OnEvent("Click", nm_AutoStartManager)
	;discord tools
	MainGui.Add("Button", "x340 y124 w150 h40 vNightAnnouncementGUI Disabled", "Night Detection`nAnnouncement").OnEvent("Click", nm_NightAnnouncementGUI)
	;reporting
	MainGui.Add("Button", "x340 y184 w150 h20 vReportBugButton Disabled", "Report Bugs").OnEvent("Click", nm_ReportBugButton)
	MainGui.Add("Button", "x340 y206 w150 h20 vMakeSuggestionButton Disabled", "Make Suggestions").OnEvent("Click", nm_MakeSuggestionButton)
	MainGui.SetFont("s8 cDefault Norm", "Tahoma")
	CurrentLoadProgress:=CurrentLoadProgress+MiscFeatureProgressVolume
	SetLoadingProgress(floor(CurrentLoadProgress/LoadingProgressVolume*100))
}
nm_BitterberryFeeder(*)
{
	if !GetRobloxHWND()
	{
		MsgBox "You must have Bee Swarm Simulator open to use this!", "Bitterberry Auto-Feeder", 0x40030 " T20"
		return
	}

	script :=
	(
	'
	#NoTrayIcon
	#SingleInstance Force

	#Include "%A_ScriptDir%\lib"
	#Include "Gdip_All.ahk"
	#Include "Gdip_ImageSearch.ahk"
	#Include "Roblox.ahk"
	#Include "nm_OpenMenu.ahk"
	#Include "nm_InventorySearch.ahk"

	CoordMode "Mouse", "Screen"
	OnExit(ExitFunc)
	pToken := Gdip_Startup()

	bitmaps := Map()
	bitmaps["itemmenu"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAACcAAAAuAQAAAACD1z1QAAAAAnRSTlMAAHaTzTgAAAB4SURBVHjanc2hDcJQGAbAex9NQCCQyA6CqGMswiaM0lGACSoQDWn6I5A4zNnDiY32aCPbuoujA1rNUIsggqZRrgmGdJAd+qwN2YdDdEiPXUCgy3lGQJ6I8VK1ZoT4cQBjVa2tUAH/uTHwvZbcMWfClBduVK2i9/YB0wgl4MlLHxIAAAAASUVORK5CYII=")
	bitmaps["questlog"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAACoAAAAnAQAAAABRJucoAAAAAnRSTlMAAHaTzTgAAACASURBVHjajczBCcJAEEbhl42wuSUVmFjJphRL2dLGEuxAxQIiePCw+MswBRgY+OANMxgUoJG1gZj1Bd0lWeIIkKCrgBqjxzcfjxs4/GcKhiBXVyL7M0WEIZiCJVgDoJPPJUGtcV5ksWMHB6jCWQv0dl46ToxqzJZePHnQw9W4/QAf0C04CGYsYgAAAABJRU5ErkJggg==")
	bitmaps["beemenu"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAACsAAAAsAQAAAADUI3zVAAAAAnRSTlMAAHaTzTgAAACaSURBVHjadc5BDgIhDAXQT9U4y1m6G24inkyO4lGaOUm9AW7MzMY6HyQxJjaBFwotxdW3UAEjNhCc+/1z+mXGmgCH22Ti/S5bIRoXSMgtmTASBeOFsx6td/lDIgGIJ8Czl6kVRAguGL4mW9NcC8zJUjRvlCXXZH3kxiUYW+sBgewhRPq3exIwEOhYiZHl/nS3HdIBePQBlfvtDUnsNfflK46tAAAAAElFTkSuQmCC")
	bitmaps["item"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAAAMAAAAUAQMAAAByNRXfAAAAA1BMVEXU3dp/aiCuAAAAC0lEQVR42mMgEgAAACgAAU1752oAAAAASUVORK5CYII=")
	bitmaps["bitterberry"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAAG8AAAAbCAMAAABFqCGFAAAB11BMVEUbKjUcKzYdLDceLDceLTgfLjkgLzohMDoiMDsjMTwkMj0kMz0lND4mND8oNkApN0EqOEMrOUMsOkQtO0UuPEYvPUcwPkgyQEkzQUo0QUs1Q0w3RU44RU85Rk86SFE8SVM9SlM+S1Q/TFVATVZCT1hDUFlEUVlFUVpGU1xHVFxJVV5KVl9LV19NWWJPW2NRXWVSXmZUYGhVYWhWYWlXYmpXY2tbZm5cZ29daG9eanFibXRibnVkb3ZlcHdoc3ptd35ueX9veoBweoFzfYN0foR1f4V2gIZ4god6hIp7hYt+h41/iY6Aio+FjpSGj5SHkJWKk5iLlJmMlZqNlpqOl5uQmJ2QmZ2Rmp6Sm5+UnKCVnaGZoaWbo6ecpKigp6uhqKyjq66mrbCnrrGnr7Kor7OrsrWss7avtrmwt7myuLu2vL+4v8G5wMK6wMO8wsS+xMa/xcfAxsjBx8nDyMrEyszGzM3HzM7Izc/Jzs/Jz9DK0NHN0tPP1NXQ1dbR1tfS19jV2drX3NzY3N3Z3d7b4ODc4OHe4uLf4+Pg5OTg5eXi5ubj5+fm6urn6+vo7Ovp7ezq7e3r7u7r7+7s8O/t8fDu8fHv8vHw8/Lx9PPx9fTy9fTz9vX09/ZX5XClAAACKElEQVR42u3W61NMYQDH8W9iu7uEhAhJURIphYRci0QiFXKJXAttQnIPXdVWK/3+WHvK6dnZfaY3O443fm9+L34zz2fmzDPnHORt+O/9BS8HJ6mlL2Xys6XJlCVTLbUxepDQJaln9b5ZSXs4J7dsKeZIzB45kvzpRY6XHYLcsiU/Ju+YpOHD8NEdPPDUD8+kL52dwcW9K2kF3cazzqYX8d5Ar9QMQ7qMk/o/JU3WZfnWnx2RVEpWPLSFvJ1FKekVvZIss9v10C9JfXAy0hsswTdu937tx0nepHMgkDCifHPFLLPbn5dQI0k18NpyX05r3ot8nq2sejz+dCVNcwfeDAwq5CW1TzzPZLttNl3CmqA0k0G+or3kd7J7uTRIqqNw7oFJcrwKSbfhvWU2fRfuSw+h1eKxdsjqBeKYT6pz0G4Z7yt0WGbTkys4IFWSPKpwr1rSjzPQbPW+4SYY4U1Dm3V2WyeIHxhOpEpRnoJJnLJ6E3BJ84nwQlS7bTaeHxquwwuLN5XIeRmvVgu1iTJJ09FeB7wys83TNjYXslXR3mg1+Be8XeTe8bt1gbgbga6Msu5wL+lWoG8L62ZkZpt3FeCa/f15VAteLfDJrYkdOFn+NtybS9w9ycw27/tS8A1ZvGXZjTPGGzuYvNfUaM0GX2bVB5mDqgoOFaWkFT+SrLPxVA6VXn5vG+GJl14eG2c99Hrgojz0jhM/4KE3lkK5PPRa4cG/+x/8DdlCsT+3EwaSAAAAAElFTkSuQmCC")
	bitmaps["feed"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAADwAAAAUAQMAAADrzcxqAAAABlBMVEUAAAD3//lCqWtQAAAAAXRSTlMAQObYZgAAAE1JREFUeNqNzbENwCAMRNHfpYxLSo/ACB4pG8SjMkImIAiwRIe46lX3+QtzAcE5wQ1cHeKQHhw10EwFwISK6YAvvCVg7LBamuM5fRGFBk/MFx8u1mbtAAAAAElFTkSuQmCC")
	bitmaps["greensuccess"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAAA4AAAALCAYAAABPhbxiAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAAhdEVYdENyZWF0aW9uIFRpbWUAMjAyMzowMzowOCAxNToyMzo1N/c+ABwAAAAdSURBVChTY3T+H/6fgQzABKVJBqMa8YDhr5GBAQBwxAKu5PiUjAAAAA5lWElmTU0AKgAAAAgAAAAAAAAA0lOTAAAAAElFTkSuQmCC")
	#Include "%A_ScriptDir%\nm_image_assets\offset\bitmaps.ahk"

	if (MsgBox("BITTERBERRY AUTO FEEDER v0.2 by anniespony#8135``nMake sure BEE SLOT TO MUTATE is always visible``nDO NOT MOVE THE SCREEN OR RESIZE WINDOW FROM NOW ON.``nMAKE SURE BEE IS RADIOACTIVE AT ALL TIMES!", "Bitterberry Auto-Feeder v0.2", 0x40001) = "Cancel")
		ExitApp

	bitterberrynos := InputBox("Enter the amount of bitterberry used each time", "How many bitterberry?", "w320 h180 T60").Value
	if IsInteger(bitterberrynos) {
		if (bitterberrynos > 30)
			if (MsgBox("You have entered " bitterberrynos " which is more than 30.``nAre you sure?", "Bitterberry Auto-Feeder v0.2", 0x40034) = "No")
				ExitApp
	} else {
		MsgBox "You must enter a number for Bitterberries!!``nStopping Feeder!", "Bitterberry Auto-Feeder v0.2", 0x40010
		ExitApp
	}

	if (MsgBox("After dismissing this message,``nleft click ONLY once on BEE SLOT", "Bitterberry Auto-Feeder v0.2", 0x40001) = "Cancel")
		ExitApp

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
	try
	{
		Hotkey "Shift", ExitFunc, "On"
		Hotkey "RButton", ExitFunc, "On"
		Hotkey "F11", ExitFunc, "On"
	}
	Sleep 250

	Loop
	{
		if ((pos := nm_InventorySearch("bitterberry", "down", , , , (A_Index = 1) ? 40 : 4)) = 0)
		{
			MsgBox "You ran out of Bitterberries!", "Bitterberry Auto-Feeder v0.2", 0x40010
			break
		}
		GetRobloxClientPos(hwnd)

		SendEvent "{Click " windowX+pos[1] " " windowY+pos[2] " 0}"
		Send "{Click Down}"
		Sleep 100
		SendEvent "{Click " beeX " " beeY " 0}"
		Sleep 100
		Send "{Click Up}"
		Loop 10
		{
			Sleep 100
			pBMScreen := Gdip_BitmapFromScreen(windowX+(54*windowWidth)//100-300 "|" windowY+offsetY+(46*windowHeight)//100-59 "|250|100")
			if (Gdip_ImageSearch(pBMScreen, bitmaps["feed"], &pos, , , , , 2, , 2) = 1)
			{
				Gdip_DisposeImage(pBMScreen)
				SendEvent "{Click " windowX+(54*windowWidth)//100-300+SubStr(pos, 1, InStr(pos, ",")-1)+140 " " windowY+offsetY+(46*windowHeight)//100-59+SubStr(pos, InStr(pos, ",")+1)+5 "}" ; Click Number
				Sleep 100
				Loop StrLen(bitterberrynos)
				{
					SendEvent "{Text}" SubStr(bitterberrynos, A_Index, 1)
					Sleep 100
				}
				SendEvent "{Click " windowX+(54*windowWidth)//100-300+SubStr(pos, 1, InStr(pos, ",")-1) " " windowY+offsetY+(46*windowHeight)//100-59+SubStr(pos, InStr(pos, ",")+1) "}" ; Click Feed
				break
			}
			Gdip_DisposeImage(pBMScreen)
			if (A_Index = 10)
				continue 2
		}
		Sleep 750

		pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2-295 "|" windowY+offsetY+((4*windowHeight)//10 - 15) "|150|50")
		if (Gdip_ImageSearch(pBMScreen, bitmaps["greensuccess"], , , , , , 20) = 1) {
			if (MsgBox("SUCCESS!!!!``nKeep this?", "Bitterberry Auto-Feeder v0.2", 0x40024) = "Yes")
			{
				Gdip_DisposeImage(pBMScreen)
				break
			}
			else
			{
				ActivateRoblox()
				SendEvent "{Click " windowX + (windowWidth//2 - 132) " " windowY + offsetY + ((4*windowHeight)//10 - 150) "}" ; Close Bee
			}
		}
		Gdip_DisposeImage(pBMScreen)
	}
	ExitApp

	ExitFunc(*)
	{
		try StatusBar.Destroy()
		try Gdip_Shutdown(pToken)
		ExitApp
	}
	'
	)

	shell := ComObject("WScript.Shell")
	exec := shell.Exec('"' exe_path64 '" /script /force *')
	exec.StdIn.Write(script), exec.StdIn.Close()
}
nm_BasicEggHatcher(*)
{
	if !GetRobloxHWND()
	{
		MsgBox "You must have Bee Swarm Simulator open to use this!", "Basic Bee Replacement Program", 0x40030 " T20"
		return
	}

	script :=
	(
	'
	#NoTrayIcon
	#SingleInstance Force

	#Include "%A_ScriptDir%\lib"
	#Include "Gdip_All.ahk"
	#Include "Gdip_ImageSearch.ahk"
	#Include "Roblox.ahk"
	#Include "nm_OpenMenu.ahk"
	#Include "nm_InventorySearch.ahk"

	CoordMode "Mouse", "Screen"
	OnExit(ExitFunc)
	pToken := Gdip_Startup()

	bitmaps := Map()
	bitmaps["itemmenu"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAACcAAAAuAQAAAACD1z1QAAAAAnRSTlMAAHaTzTgAAAB4SURBVHjanc2hDcJQGAbAex9NQCCQyA6CqGMswiaM0lGACSoQDWn6I5A4zNnDiY32aCPbuoujA1rNUIsggqZRrgmGdJAd+qwN2YdDdEiPXUCgy3lGQJ6I8VK1ZoT4cQBjVa2tUAH/uTHwvZbcMWfClBduVK2i9/YB0wgl4MlLHxIAAAAASUVORK5CYII=")
	bitmaps["questlog"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAACoAAAAnAQAAAABRJucoAAAAAnRSTlMAAHaTzTgAAACASURBVHjajczBCcJAEEbhl42wuSUVmFjJphRL2dLGEuxAxQIiePCw+MswBRgY+OANMxgUoJG1gZj1Bd0lWeIIkKCrgBqjxzcfjxs4/GcKhiBXVyL7M0WEIZiCJVgDoJPPJUGtcV5ksWMHB6jCWQv0dl46ToxqzJZePHnQw9W4/QAf0C04CGYsYgAAAABJRU5ErkJggg==")
	bitmaps["beemenu"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAACsAAAAsAQAAAADUI3zVAAAAAnRSTlMAAHaTzTgAAACaSURBVHjadc5BDgIhDAXQT9U4y1m6G24inkyO4lGaOUm9AW7MzMY6HyQxJjaBFwotxdW3UAEjNhCc+/1z+mXGmgCH22Ti/S5bIRoXSMgtmTASBeOFsx6td/lDIgGIJ8Czl6kVRAguGL4mW9NcC8zJUjRvlCXXZH3kxiUYW+sBgewhRPq3exIwEOhYiZHl/nS3HdIBePQBlfvtDUnsNfflK46tAAAAAElFTkSuQmCC")
	bitmaps["item"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAAAMAAAAUAQMAAAByNRXfAAAAA1BMVEXU3dp/aiCuAAAAC0lEQVR42mMgEgAAACgAAU1752oAAAAASUVORK5CYII=")
	bitmaps["basicegg"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAAGIAAAAaCAMAAAB7CnmQAAABuVBMVEUbKjUdLDceLDceLTgfLjkgLzohMDoiMDsjMTwkMj0lND4nNUAoNkApOEIqOEMrOUMsOkQtO0UuPEYvPEYvPUcwPkgxP0kyQEkzQUo0QUs1Qkw2RE03RU44RU85Rk86SFE7SVI8SVNATVZEUVlGUltGU1xKVl9LV19MWWFPW2NQXGRRXWVVYWhWYWlXYmpXY2tdaXBeanFga3JhbHNibXRibnVjbnVkb3ZmcXhncnhoc3ppdHtqdXtsdn1td35ueX9veoBweoFzfYN0foR1f4V2gIZ3gYd4god6hIp+h42Ci5GFjpSGj5SIkZaJkpePl5yQmJ2VnaGWnqKZoaWaoqabo6ecpKidpamfp6qjq66mrbCnr7Kor7Ots7avtrmwt7m1vL63vcC+xMa/xcfAxsjBx8nCyMnDyMrEyszFy8zGzM3HzM7Izc/Jzs/Jz9DN0tPQ1dbR1tfS19jT2NjU2NnV2drV2tvW29zY3N3Z3d7a39/c4OHe4uLg5OTg5eXi5ubj5+fl6ejm6enm6uro7Ovp7ezq7e3r7u7r7+7s8O/t8fDu8fHv8vHw8/Lx9PPx9fTy9fTz9vX09/Y9aLFlAAACKklEQVR42u3Ta1MSUQDG8cfiVmZBUoqmBhVkRtj9JkmoSRGmlbZadiG6mXnpSmG6QWlqCDyfuNlYTu3sMsNM6zufV/9X5zc7Zw+46cMWUTvhg7KdoenNJgDbU1bZa9fxEvXzQt2zWgn4WGVTzs7/JSIkc+eBNGubIKJq1UZwHkiRfHm5xdI8mOW/yySTeTOIWeANmd4GZQdzJJOd9Q1d4wVyBJBJyv0t1v3nZoyJwu1DDncEkDStIZaCsK6QHDgQH+sGhsgndVAWrhDf2qHM8cKQCKM8SbSGUDdIkqt5stiGIHkS/uzHIW+6QtxA3f21lNOaoPa6ZaWfA+GFhR5AEm1A7HhLkp/ONmxvqkeAjMDzuMgSK8Q+nCY5vUQjIgbnL/IrIIk2IOCWyczecvvJd7sAT2K5QqwAd6pf9wl0Uz1WbS0RJbkcA0bIa2ifXf/QoRD8fNEKtM6pRBp4UJ3wo1c9VrSOYN6BAfIwxkge+UOQi3EbAjV9RRdOqceK1hPrdsSVw28JYoPkKPBTcxevFg2JCJqK6rFq64nvUWCK7IcrlbtrU4gJz/gPuQeODe0fZUkYEY+A69nMBUASbXTdvSS/iOuWG8t1U7yLNt27UBciS0G1JdE6wuIdLlAxrrjtR6+GYqQc99ldxyb593X3NVvdZ2ZoRHA13mFtvARIogVh6uaBh5o2nxgG5jRtOvF+N1oLmjabmNwDjGradOIe0Kdp84m1wERJ378B3+p4iisaatgAAAAASUVORK5CYII=")
	bitmaps["royaljelly"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAAGwAAAAcCAMAAACzmqo+AAAB+FBMVEUbKjUcKzYdLDceLDceLTgfLjkgLzohMDoiMDsjMTwkMj0kMz0lND4mND8nNUAoNkApN0EpOEIqOEMrOUMsOkQtO0UuPEYvPEYvPUcwPkgyQEkzQUo0QUs1Qkw1Q0w3RU44RU85Rk86SFE7SVI8SVM+S1Q/TFVDUFlEUVlFUVpGUltGU1xIVV1KVl9LV19MWWFPW2NWYWlXYmpXY2tbZm5cZ29daG9daXBga3JibXRibnVlcHdpdHttd35weoFxe4FyfIJzfYN0foR1f4V2gIZ3gYd4god5goh6hIp7hYt8hot+h41/iI6Aio+BipCCi5GFjpSFjpOGj5SHkJWIkZaJkpeKk5iKk5eLlJmMlZqNlpqPl5yQmJ2QmZ2Rmp6Sm5+UnKCVnaGaoqabo6ecpKigp6ujq66kq6+lrLCor7Ots7avtrmwt7mxt7qyuLu1vL62vL+3vcC5wMK6wMO8wsS9w8W/xcfAxsjDyMrDycvEyszGzM3HzM7Jzs/K0NHL0NLN0tPO09TP1NXQ1dbR1tfS19jT2NjV2drV2tvW29zX3NzY3N3a39/b4ODc4OHd4eLe4uLf4+Pg5OTg5eXi5ubj5+fk6Ojm6enm6urn6+vo7Ovp7ezq7e3r7u7r7+7s8O/t8fDu8fHv8vHw8/Lx9fTy9fTz9vX09/a7z3nGAAACf0lEQVR42u3W+VOMcQDH8Y9KVkUUkXQqJEqH0OWokHLlzplyRSgJFZWjnEmOtqhWx77/TbNPzHeenbZtZk3GjPcPO7O73/m8dvZ5fnjEPKb/2L+IpcqTI+sBc6s9d2RuR8xBb0wKaWEuXZe+Y69Beul9ZPrVJ6Z1bvBf7eyYOVI7M7YHGMiROucLo0tqwmdtRfEL4/YN/insmfQC+FyW4EiqGIRT1nvr81LeBk//0c5ZMFd1UujaiiEbZlsx2NBOpQMD8fKU8pX3QaoEqJSeQlni0frt0knf2FSOPKW7bJhtReYGWfwEKFdks6txsY5AtmImYDJWGcDYBEwlKds3Vqfo5pGWKF2yYbYVgwV1A1NLdBo4qFVwU7oF96Q64HXB8pA1S5XpG9ugGqBamXbMrJhr1ig1Ax+kx1jfDeNapm1QqLBh6IuR1Raf2NgCTRdhx8yKwcajVAR0Sr1Ah/QK9iq43+lQMVCu5K4fvSm+sZ4B/W7ChpkVg7Fb4SPwUWoDmqxz7VJNvfQI2KR6IMMbw9kHcE3qH5XOznjrmxWDtUo3wB3965rFA6xXSqbSsJhzM2CTu8K2TgIlWuEmWXnAuB2zrRjMHa9s4LAi7rpuO6Z/5UVJugxQqpUPnVcWeWHsl3b0OOtCVAXHteDqWGtsXpsXZlYMxiEF9YMzTZ7SRwA+hUihXwDezXyDuApktXkURjfKU+Rzb8ysGKxbugAMVyU7Uo+NYpUvFYKlFa92ZJXkHrBjuBuyYxelnrCOD1cmhMYVv8EbMytits5L9wkks+IfS1eimwAyK/6xDukMgWRW/GMlCu4ngMyKf+xbuPIJJLPiH6uT7hBAZuVvPMr9BDBOM9MqS26gAAAAAElFTkSuQmCC")
	bitmaps["giftedstar"] := Gdip_CreateBitmap(8,8), G := Gdip_GraphicsFromImage(bitmaps["giftedstar"]), Gdip_GraphicsClear(G,0xffffac33), Gdip_DeleteGraphics(G)
	bitmaps["yes"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAAB0AAAAPAQMAAAAiQ1bcAAAABlBMVEUAAAD3//lCqWtQAAAAAXRSTlMAQObYZgAAAFZJREFUeAEBSwC0/wDDAAfAAEIACGAAfgAQMAA8ABAQABgAIAgAGAAgCAAYACAYABgAP/gAGAAgAAAYAAAAABgAIAAAGAAwAAAYADAAABgAGDAAGAAP4FGfB+0KKAbEAAAAAElFTkSuQmCC")
	#Include "%A_ScriptDir%\nm_image_assets\offset\bitmaps.ahk"
	common := Gdip_CreateBitmap(1,4), G := Gdip_GraphicsFromImage(common), Gdip_GraphicsClear(G,0xffae792f), Gdip_DeleteGraphics(G)
	mythic := Gdip_CreateBitmap(2,2), G := Gdip_GraphicsFromImage(mythic), Gdip_GraphicsClear(G,0xffbda4ff), Gdip_DeleteGraphics(G)
	if (MsgBox("WELCOME TO THE BASIC BEE REPLACEMENT PROGRAM!!!!!``nMade by anniespony#8135``n``nMake sure BEE SLOT TO CHANGE is always visible``nDO NOT MOVE THE SCREEN OR RESIZE WINDOW FROM NOW ON.``nMAKE SURE AUTO-JELLY IS DISABLED!!", "Basic Bee Replacement Program", 0x40001) = "Cancel")
		ExitApp

	if (MsgBox("After dismissing this message,``nleft click ONLY once on BEE SLOT", "Basic Bee Replacement Program", 0x40001) = "Cancel")
		ExitApp
	hwnd := GetRobloxHWND()
	ActivateRoblox()
	GetRobloxClientPos(hwnd)
	offsetY := GetYOffset(hwnd, &offsetfail)
	if (offsetfail = 1) {
		MsgBox "Unable to detect in-game GUI offset!``nStopping Hatcher!``n``nThere are a few reasons why this can happen, including:``n - Incorrect graphics settings``n - Your `'Experience Language`' is not set to English``n - Something is covering the top of your Roblox window``n``nJoin our Discord server for support and our Knowledge Base post on this topic (Unable to detect in-game GUI offset)!", "WARNING!!", 0x40030
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
	rj := 0
	Loop
	{
		if YesButton() {
			sleep 750
			if detect(&rj)
				break
			continue
		}
		if ((pos := (A_Index = 1) ? nm_InventorySearch("basicegg", "up", , , , 70) : (rj = 1) ? nm_InventorySearch("royaljelly", "down", , , 0, 7) : nm_InventorySearch("basicegg", "up", , , 0, 7)) = 0)
		{
			MsgBox "You ran out of " ((rj = 1) ? "Royal Jellies!" : "Basic Eggs!"), "Basic Bee Replacement Program", 0x40010
			break
		}
		GetRobloxClientPos(hwnd)
		SendEvent "{Click " windowX+pos[1] " " windowY+pos[2] " 0}"
		Send "{Click Down}"
		Sleep 100
		SendEvent "{Click " beeX " " beeY " 0}"
		Sleep 100
		Send "{Click Up}"
		Loop 10
		{
			Sleep 100
			if YesButton()
				break
			if (A_Index = 10)
			{
				rj := 1
				continue 2
			}
		}
		Sleep 750
		if detect(&rj)=1
			break
		sleep 100
	}
	detect(&rj) {
		rj := 0
		pBMScreen := Gdip_BitmapFromScreen(windowX+(windowWidth//2)-155 "|" windowY+(((4*windowHeight)//10) - 135) "|310|205")
		if (Gdip_ImageSearch(pBMScreen, mythic, , , , , , 2) = 1) { ; Mythic Hatched
			if (MsgBox("MYTHIC!!!!``nKeep this?", "Basic Bee Replacement Program", 0x40024) = "Yes")
			{
				Gdip_DisposeImage(pBMScreen)
				return 1
			}
		}
		else if (Gdip_ImageSearch(pBMScreen, common, , , , , , 2) = 1) { ; check if common
			rj := 1
			if (Gdip_ImageSearch(pBMScreen, bitmaps["giftedstar"], , , , , , 5) = 1) { ; If gifted is hatched, stop
				MsgBox "SUCCESS!!!!", "Basic Bee Replacement Program", 0x40020
				Gdip_DisposeImage(pBMScreen)
				return 1
			}
		}
		else if (Gdip_ImageSearch(pBMScreen, bitmaps["giftedstar"], , , , , , 5) = 1) { ; Non-Basic Gifted Hatched
			if (MsgBox("GIFTED!!!!``nKeep this?", "Basic Bee Replacement Program", 0x40024) = "Yes")
			{
				Gdip_DisposeImage(pBMScreen)
				return 1
			}
		}
		Gdip_DisposeImage(pBMScreen)
		return 0
	}
	YesButton(){
		pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2-250 "|" windowY+windowHeight//2-52 "|500|150")
		if (Gdip_ImageSearch(pBMScreen, bitmaps["yes"], &pos, , , , , 2, , 2) = 1)
		{
			Gdip_DisposeImage(pBMScreen)
			SendEvent "{Click " windowX+windowWidth//2-250+SubStr(pos, 1, InStr(pos, ",")-1) " " windowY+windowHeight//2-52+SubStr(pos, InStr(pos, ",")+1) "}"
			return 1
		}
		Gdip_DisposeImage(pBMScreen)
		return 0
	}
	ExitApp

	ExitFunc(*)
	{
		try Gdip_DisposeImage(common), Gdip_DisposeImage(mythic)
		try StatusBar.Destroy()
		try Gdip_Shutdown(pToken)
		ExitApp
	}
	'
	)

	shell := ComObject("WScript.Shell")
	exec := shell.Exec('"' exe_path64 '" /script /force *')
	exec.StdIn.Write(script), exec.StdIn.Close()
}
nm_GenerateBeeList(*)
{
	global bitmaps
	static bees := ["basic"
		,"bomber","brave","bumble","cool","hasty","looker","rad","rascal","stubborn"
		,"bubble","bucko","commander","demo","exhausted","fire","frosty","honey","rage","riley","shocked"
		,"baby","carpenter","demon","diamond","lion","music","ninja","shy"
		,"buoyant","fuzzy","precise","spicy","tadpole","vector"
		,"bear","cobalt","crimson","digital","festive","gummy","photon","puppy","tabby","vicious","windy"]

	if !GetRobloxHWND()
	{
		MsgBox "You must have Bee Swarm Simulator open to use this!", "Export Bee List", 0x40030 " T20"
		return
	}

	; initialise object to fill
	bee_data := Map()

	; open menu
	ActivateRoblox()
	hwnd := GetRobloxHWND()
	offsetY := GetYOffset(hwnd)
	GetRobloxClientPos(hwnd)
	nm_OpenMenu()
	nm_OpenMenu("beemenu")
	MouseMove windowX+30, windowY+offsetY+200, 5

	; obtain lower bound of search
	pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY+offsetY+150 "|306|" windowHeight-offsetY-150)
	local pBMWhite, pBMRed, pBMBlue
	lb := 450
	for k,v in Map("white",0xffc4c8cb, "red",0xffc7403c, "blue",0xff4d87ca)
	{
		pBM%k% := Gdip_CreateBitmap(6, 2), G := Gdip_GraphicsFromImage(pBM%k%), Gdip_GraphicsClear(G, v), Gdip_DeleteGraphics(G)
		if (Gdip_ImageSearch(pBMScreen, pBM%k%, &lpos, , , 10, , 2, , 2) = 1)
		{
			l := SubStr(lpos, InStr(lpos, ",")+1)
			lb := Max(l+2, lb)
		}
	}
	Gdip_DisposeImage(pBMScreen)

	; loop through bees and fill object
	pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY+offsetY+150 "|306|" lb)
	ub := 0
	for k,v in bees
	{
		Loop 3
		{
			; find upper coordinate of current bee
			uc := lb
			for i,j in ["white","red","blue"]
			{
				if (Gdip_ImageSearch(pBMScreen, pBM%j%, &upos, , ub, 10, , 2) = 1)
				{
					u := SubStr(upos, InStr(upos, ",")+1)
					uc := Min(u, uc)
				}
			}

			; if bee is too low, scroll up, else, set upper bound for next
			if (lb-uc < 120)
			{
				Loop (lb//150 - 2)
				{
					MouseMove windowX+30, windowY+offsetY+200, 5
					Sleep 50
					SendInput "{WheelDown}"
				}

				; obtain reference image for scroll distance
				DllCall("GetSystemTimeAsFileTime","Int64P",&s:=0)
				pBM := Gdip_CloneBitmapArea(pBMScreen, 6, Gdip_GetImageHeight(pBMScreen)-206, 294, 200)
				Gdip_LockBits(pBM, 0, 0, 294, 200, &stride, &scan0, &bmData)
				Loop 294
				{
					x := A_Index - 1
					if ((x+6 < windowWidth//2 - 261) || ((x+6 > windowWidth//2 - 190) && (x+6 < windowWidth//2 - 186)) || ((x+6 > windowWidth//2 - 115) && (x+6 < windowWidth//2 - 111)))
					{
						Loop 200
						{
							y := A_Index - 1
							switch Gdip_GetLockBitPixel(scan0, x, y, stride)
							{
								case 0xff4d87ca, 0xffc4c8cb, 0xffc7403c, 0xff74a9e6, 0xffe1e4e7, 0xffe46764:
								default:
								Gdip_SetLockBitPixel(0x00000000, scan0, x, y, stride)
							}
						}
					}
					else
					{
						Loop 200
						{
							y := A_Index - 1
							Gdip_SetLockBitPixel(0x00000000, scan0, x, y, stride)
						}
					}
				}
				Gdip_UnlockBits(pBM, &bmData)
				DllCall("GetSystemTimeAsFileTime","Int64P",&f:=0)

				; wait for scroll end then measure distance
				Sleep 500 - (f-s)//10000
				Gdip_DisposeImage(pBMScreen)
				pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY+offsetY+150 "|306|" lb)
				ub := Max(0, ub - (((Gdip_ImageSearch(pBMScreen, pBM, &pos) = 1)) ? Min(lb - 206 - SubStr(pos, InStr(pos, ",")+1), 150 * (lb//150 - 2)) : (150 * (lb//150 - 2))))
				Gdip_DisposeImage(pBM)
			}
			else
			{
				ub := uc + 120
				break
			}
		}

		; detect number of current bee
		(digits := Map()).Default := ""
		Loop 10
		{
			n := 10-A_Index
			Gdip_ImageSearch(pBMScreen, bitmaps["beedigit" n], &pos, 0, uc+100, 100, uc+120, , , 5, 2, , "`n")
			Loop Parse pos, "`n"
				if (A_Index & 1)
					digits[Integer(A_LoopField)] := n
		}
		num := (digits.Count > 0) ? "" : 0
		for x,y in digits
			num .= y


		; detect if current bee has gifted status
		gifted := ((num > 0) && (Gdip_ImageSearch(pBMScreen, bitmaps["gifted"], , 260, uc, 306, uc+40, 2) = 1))

		bee_data[v] := Map("amount",num, "gifted",gifted)
	}

	; stringify the object into JSON format for export
	str := '{"type":"natro",'
	for k,v in bee_data
		str .= (v["amount"] > 0) ? ('"' k '":{"amount":' v["amount"] ',"gifted":' (v["gifted"] ? "true" : "false") '},') : ""
	str := RTrim(str, ",") "}"

	A_Clipboard := str
	MsgBox "Copied Bee List to clipboard!`nPaste the output into the '/hive import' command of Hive Builder to view your hive!", "Export Bee List", 0x40040 " T20"
}
nm_BSSCalculators(*){
	global
	GuiClose(*){
		if (IsSet(CalculatorsGui) && IsObject(CalculatorsGui))
			CalculatorsGui.Destroy(), CalculatorsGui := ""
	}
	GuiClose()
	CalculatorsGui := Gui("+AlwaysOnTop -MinimizeBox +Owner" MainGui.Hwnd, "BSS Calculators")
	CalculatorsGui.OnEvent("Close", GuiClose)
	CalculatorsGui.SetFont("s8 cDefault Bold", "Tahoma")
	CalculatorsGui.Add("Button", "x10 y10 w120 h30", "Ticket Shop Calculator").OnEvent("Click", nm_TicketShopCalculatorButton)
	CalculatorsGui.Add("Button", "xp yp+35 wp hp", "SSA Calculator").OnEvent("Click", nm_SSACalculatorButton)
	CalculatorsGui.Add("Button", "xp yp+35 wp hp", "Bond Calculator").OnEvent("Click", nm_BondCalculatorButton)
	CalculatorsGui.Add("Button", "xp yp+35 wp hp", "Beequip Chances").OnEvent("Click", nm_BeequipChancesButton)
	CalculatorsGui.Add("Text", "x10 yp+35 wp cGray BackgroundTrans Wrap", "Credits to SP and gyhkijffk for these calculators!")

	CalculatorsGui.Show("Autosize Center")
}
nm_TicketShopCalculatorButton(*) => Run("https://docs.google.com/spreadsheets/d/1_5JP_9uZUv7PUqjL76T5orEA3MIHe4R8gLu27L8KJ-A/")
nm_SSACalculatorButton(*) => Run("https://docs.google.com/spreadsheets/d/1nupF_6g1TLJk1W5MpLBsfe1yk6C99-ooMMffuxdn580/")
nm_BondCalculatorButton(*) => Run("https://docs.google.com/spreadsheets/d/1TFTAahwsB4WRmRkX4YiM8mPQyk53CDmfAKOSOYv-Bow/")
nm_BeequipChancesButton(*) => Run("https://docs.google.com/spreadsheets/d/10_7oay1yHgykAccrhqYp5gr-P_0jpEKMbTJS9ty4JA8/")

nm_AutoClickerButton(*)
{
	global
	local GuiCtrl,GuiCtrlDuration, GuiCtrlDelay
	GuiClose(*){
		if (IsSet(AutoClickerGui) && IsObject(AutoClickerGui))
			AutoClickerGui.Destroy(), AutoClickerGui := ""
	}
	GuiClose()
	AutoClickerGui := Gui("+AlwaysOnTop -MinimizeBox +Owner" MainGui.Hwnd, "AutoClicker")
	AutoClickerGui.OnEvent("Close", GuiClose)
	AutoClickerGui.SetFont("s8 cDefault w700", "Tahoma")
	AutoClickerGui.Add("GroupBox", "x5 y2 w161 h80", "Settings")
	AutoClickerGui.SetFont("Norm")
	AutoClickerGui.Add("CheckBox", "x76 y2 vClickMode Checked" ClickMode, "Infinite").OnEvent("Click", nm_ClickMode)
	AutoClickerGui.Add("Text", "x13 y21", "Repeat")
	AutoClickerGui.Add("Edit", "x50 y19 w80 h18 vClickCountEdit Number Limit7 Disabled" ClickMode)
	(GuiCtrl := AutoClickerGui.Add("UpDown", "vClickCount Range0-9999999 Disabled" ClickMode, ClickCount)).Section := "Settings", GuiCtrl.OnEvent("Change", nm_saveConfig)
	AutoClickerGui.Add("Text", "x133 y21", "times")
	AutoClickerGui.Add("Text", "x10 y41", "Click Interval (ms):")
	AutoClickerGui.Add("Edit", "x100 y39 w61 h18 Number Limit5", ClickDelay).OnEvent("Change", (*) => nm_saveConfig(GuiCtrlDelay))
	(GuiCtrlDelay := AutoClickerGui.Add("UpDown", "vClickDelay Range0-99999", ClickDelay)).Section := "Settings", GuiCtrlDelay.OnEvent("Change", nm_saveConfig)
	AutoClickerGui.Add("Text", "x10 y61", "Click Duration (ms):")
	AutoClickerGui.Add("Edit", "x104 y59 w57 h18 Number Limit4", ClickDuration).OnEvent("Change", (*) => nm_saveConfig(GuiCtrlDuration))
	(GuiCtrlDuration := AutoClickerGui.Add("UpDown", "vClickDuration Range0-9999", ClickDuration)).Section := "Settings", GuiCtrlDuration.OnEvent("Change", nm_saveConfig)
	AutoClickerGui.Add("Button", "x45 y88 w80 h20", "Start (" AutoClickerHotkey ")").OnEvent("Click", nm_StartAutoClicker)
	AutoClickerGui.Show("w160 h104")
	nm_StartAutoClicker(*){
		GuiClose()
		MainGui.Minimize()
		autoclicker()
	}
}
nm_ClickMode(*){
	global
	IniWrite (ClickMode := AutoClickerGui["ClickMode"].Value), "settings\nm_config.ini", "Settings", "ClickMode"
	AutoClickerGui["ClickCount"].Enabled := AutoClickerGui["ClickCountEdit"].Enabled := ClickMode
}
nm_saveKeyDelay(*){
	global
	KeyDelay := MainGui["KeyDelay"].Value
	IniWrite KeyDelay, "settings\nm_config.ini", "Settings", "KeyDelay"
}
nm_HotkeyGUI(*){
	global
	local GuiCtrl
	GuiClose(*){
		if (IsSet(HotkeyGui) && IsObject(HotkeyGui))
			HotkeyGui.Destroy(), HotkeyGui := ""
	}
	GuiClose()
	HotkeyGui := Gui("+AlwaysOnTop -MinimizeBox +Owner" MainGui.Hwnd, "Hotkeys")
	HotkeyGui.OnEvent("Close", GuiClose)
	HotkeyGui.SetFont("s8 cDefault Bold", "Tahoma")
	HotkeyGui.Add("GroupBox", "x5 y2 w190 h144", "Change Hotkeys")
	HotkeyGui.SetFont("Norm")
	HotkeyGui.Add("Text", "x10 y23 w60 +BackgroundTrans", "Start:")
	HotkeyGui.Add("Text", "x10 yp+19 w60 +BackgroundTrans", "Pause:")
	HotkeyGui.Add("Text", "x10 yp+19 w60 +BackgroundTrans", "Stop:")
	HotkeyGui.Add("Text", "x10 yp+19 w60 +BackgroundTrans", "AutoClicker:")
	HotkeyGui.Add("Text", "x10 yp+19 w60 +BackgroundTrans", "Timers:")
	HotkeyGui.Add("Text", "x10 yp+19 w60 +BackgroundTrans", "Debug Report:")
	HotkeyGui.Add("Hotkey", "x70 y20 w120 h18 vStartHotkeyEdit", StartHotkey).OnEvent("Change", nm_saveHotkey)
	HotkeyGui.Add("Hotkey", "x70 yp+19 w120 h18 vPauseHotkeyEdit", PauseHotkey).OnEvent("Change", nm_saveHotkey)
	HotkeyGui.Add("Hotkey", "x70 yp+19 w120 h18 vStopHotkeyEdit", StopHotkey).OnEvent("Change", nm_saveHotkey)
	HotkeyGui.Add("Hotkey", "x70 yp+19 w120 h18 vAutoClickerHotkeyEdit", AutoClickerHotkey).OnEvent("Change", nm_saveHotkey)
	HotkeyGui.Add("Hotkey", "x70 yp+19 w120 h18 vTimersHotkeyEdit", TimersHotkey).OnEvent("Change", nm_saveHotkey)
	HotkeyGui.Add("Hotkey", "x70 yp+19 w120 h18 vDebugHotkeyEdit", DebugHotkey).OnEvent("Change", nm_saveHotkey)
	HotkeyGui.Add("Button", "x30 yp+20 w140 h20", "Restore Defaults").OnEvent("Click", nm_ResetHotkeys)

	HotkeyGui.SetFont("s8 cDefault Bold", "Tahoma")
	HotkeyGui.Add("GroupBox", "x5 yp+22 w190 h34", "Settings")
	HotkeyGui.SetFont("Norm")
	(GuiCtrl := HotkeyGui.Add("CheckBox", "x10 yp+16 vShowOnPause Checked" ShowOnPause, "Show Natro on Pause")).Section := "Settings", GuiCtrl.OnEvent("Click", nm_saveConfig)

	HotkeyGui.Show("w190 h190")
}
nm_ResetHotkeys(*){
	global
	try {
		Hotkey StartHotkey, start, "Off"
		Hotkey PauseHotkey, nm_pause, "Off"
		Hotkey StopHotkey, stop, "Off"
		Hotkey AutoClickerHotkey, autoclicker, "Off"
		Hotkey TimersHotkey, timers, "Off"
		Hotkey DebugHotkey, nm_copyDebugLog, "Off"
	}
	IniWrite (StartHotkey := "F1"), "settings\nm_config.ini", "Settings", "StartHotkey"
	IniWrite (PauseHotkey := "F2"), "settings\nm_config.ini", "Settings", "PauseHotkey"
	IniWrite (StopHotkey := "F3"), "settings\nm_config.ini", "Settings", "StopHotkey"
	IniWrite (AutoClickerHotkey := "F4"), "settings\nm_config.ini", "Settings", "AutoClickerHotkey"
	IniWrite (TimersHotkey := "F5"), "settings\nm_config.ini", "Settings", "TimersHotkey"
	IniWrite (DebugHotkey := "F6"), "settings\nm_config.ini", "Settings", "DebugHotkey"
	HotkeyGui["StartHotkeyEdit"].Value := "F1"
	HotkeyGui["PauseHotkeyEdit"].Value := "F2"
	HotkeyGui["StopHotkeyEdit"].Value := "F3"
	HotkeyGui["AutoClickerHotkeyEdit"].Value := "F4"
	HotkeyGui["TimersHotkeyEdit"].Value := "F5"
	HotkeyGui["DebugHotkeyEdit"].Value := "F6"
	MainGui["StartButton"].Text := " Start (F1)"
	MainGui["PauseButton"].Text := " Pause (F2)"
	MainGui["StopButton"].Text := " Stop (F3)"
	MainGui["AutoClickerButton"].Text := "AutoClicker (F4)"
	MainGui["TimersButton"].Text := " Show Timers (F5)"
	try {
		Hotkey StartHotkey, start, "On"
		Hotkey PauseHotkey, nm_pause, "On"
		Hotkey StopHotkey, stop, "On"
		Hotkey AutoClickerHotkey, autoclicker, "On T2"
		Hotkey TimersHotkey, timers, "On"
		Hotkey DebugHotkey, nm_copyDebugLog, "On"
	}
}
nm_saveHotkey(GuiCtrl, *){
	global
	local k, v, l, NewHotkey, StartHotkeyEdit, PauseHotkeyEdit, StopHotkeyEdit, TimersHotkeyEdit, AutoClickerHotkeyEdit, DebugHotkeyEdit
	k := GuiCtrl.Name, %k% := GuiCtrl.Value

	v := StrReplace(k, "Edit")
	if !(%k% ~= "^[!^+]+$")
	{
		; do not allow necessary keys
		switch Format("sc{:03X}", GetKeySC(%k%)), 0
		{
			case FwdKey,LeftKey,BackKey,RightKey,RotLeft,RotRight,RotUp,RotDown,ZoomIn,ZoomOut,SC_E,SC_R,SC_L,SC_Esc,SC_Enter,SC_LShift,SC_Space:
			GuiCtrl.Value := %v%
			MsgBox "That hotkey cannot be used!`nThe key is already used elsewhere in the macro.", "Unacceptable Hotkey!", 0x1030
			return

			case SC_1,"sc003","sc004","sc005","sc006","sc007","sc008":
			GuiCtrl.Value := %v%
			MsgBox "That hotkey cannot be used!`nIt will be required to use your hotbar slots.", "Unacceptable Hotkey!", 0x1030
			return
		}

		if ((StrLen(%k%) = 0) || (%k% = StartHotkey) || (%k% = PauseHotkey) || (%k% = StopHotkey) || (%k% = AutoClickerHotkey) || (%k% = TimersHotkey) || (%k% = DebugHotkey)) ; do not allow empty or already used hotkey (not necessary in most cases)
			GuiCtrl.Value := %v%
		else ; update the hotkey
		{
			l := StrReplace(v, "Hotkey")
			try Hotkey %v%, (l = "Pause") ? nm_Pause : (l = "Debug") ? nm_copyDebugLog : %l%, "Off"
			IniWrite (%v% := %k%), "settings\nm_config.ini", "Settings", v
			if l != "Debug"
				MainGui[l "Button"].Text := ((l = "Timers") ? " Show " : (l = "AutoClicker") ? "" : " ") l " (" %v% ")"
			try Hotkey %v%, (l = "Pause") ? nm_Pause : (l = "Debug") ? nm_copyDebugLog : %l%, (v = "AutoClickerHotkey") ? "On T2" : "On"
		}
	}
}
nm_DebugLogGUI(*){
	global
	GuiClose(*){
		if (IsSet(DebugLogGui) && IsObject(DebugLogGui))
			DebugLogGui.Destroy(), DebugLogGui := ""
	}
	GuiClose()
	DebugLogGui := Gui("+AlwaysOnTop -MinimizeBox +Owner" MainGui.Hwnd, "Debug Options")
	DebugLogGui.OnEvent("Close", GuiClose)
	DebugLogGui.SetFont("s8 cDefault Norm", "Tahoma")
	DebugLogGui.Add("CheckBox", "x10 y6 vDebugLogEnabled Checked" DebugLogEnabled, "Enable Debug Logging").OnEvent("Click", nm_DebugLogCheck)
	DebugLogGui.Add("Button", "xp+140 y5 h16", "Go To File").OnEvent("Click", (*) => Run('explorer.exe /e, /n, /select,"' A_WorkingDir '\settings\debug_log.txt"'))
	DebugLogGui.Add("Button", "x10 yp+20 hp w200", "Copy Logs (" DebugHotkey ")").OnEvent("Click", nm_copyDebugLog)
	DebugLogGui.Show("w210 h36")
}
nm_DebugLogCheck(*){
	global
	IniWrite (DebugLogEnabled := DebugLogGui["DebugLogEnabled"].Value), "settings\nm_config.ini", "Status", "DebugLogEnabled"
	PostSubmacroMessage("Status", 0x5552, 222, DebugLogEnabled)
}
nm_AutoStartManager(*){
	global ASMGui

	if A_IsAdmin
		MsgBox "
		(
		Natro Macro has been run as administrator!
		Auto-Start Manager can only launch Natro Macro on logon without admin privileges.

		If you need to run Natro Macro as admin, either:
		- fix the reason why admin is required (reinstall Roblox unelevated, move Natro Macro folder)
		- manually set up a Scheduled Task in Task Scheduler with 'Run with highest privileges' checked
		- disable UAC (not recommended at all!)
		)", "Auto-Start Manager", 0x40030 " T120 Owner" MainGui.Hwnd

	if !(task := RegRead("HKCU\Software\Microsoft\Windows\CurrentVersion\Run", "NatroMacro", ""))
		validScript := 0, autostart := 0, delay := "None", status := 1
	else
	{
		; modified from Args() By SKAN,  http://goo.gl/JfMNpN,  CD:23/Aug/2014 | MD:24/Aug/2014
		A := [], pArgs := DllCall("Shell32\CommandLineToArgvW", "Str",task, "PtrP",&nArgs:=0, "Ptr")
		Loop nArgs
			A.Push(StrGet(NumGet((A_Index - 1) * A_PtrSize + pArgs, "UPtr"), "UTF-16"))
		DllCall("LocalFree", "Ptr", pArgs)

		validScript := (A.Has(1) && (A[1] = A_WorkingDir "\START.bat"))
		autostart := (A.Has(2) && (A[2] = 1))
		delay := (A.Has(4) && IsNumber(A[4])) ? hmsFromSeconds(A[4]) : "None"
		status := validScript ? 0 : 2
	}

	w := 260, h := 200
	GuiClose(*){
		if (IsSet(ASMGui) && IsObject(ASMGui))
			ASMGui.Destroy(), ASMGui := ""
	}
	GuiClose()
	ASMGui := Gui("+AlwaysOnTop -MinimizeBox +Owner" MainGui.Hwnd, "Auto-Start Manager")
	ASMGui.OnEvent("Close", GuiClose)
	ASMGui.SetFont("s11 cDefault Bold", "Tahoma")
	ASMGui.Add("Text", "x0 y4 vStatusLabel", "Current Status: ")
	ASMGui.Add("Text", "x0 y4 vStatusVal c" ((status > 0) ? "Red" : "Green"), (status > 0) ? "Inactive" : "Active")
	CenterText(ASMGui["StatusLabel"], ASMGui["StatusVal"], ASMGui["StatusLabel"])
	ASMGui.SetFont("s9 cDefault Bold", "Tahoma")
	ASMGui.Add("Text", "x0 y24 w" w " h36 vStatusText +Center c" ((status > 0) ? "Red" : "Green")
		, ((status = 0) ? "Natro Macro will automatically start on user login using the settings below:"
		: (status = 1) ? "No Natro Macro auto-start found!`nUse the 'Add' button below."
		: "Your auto-start needs updating!`nUse 'Add' to create a new auto-start."))

	ASMGui.Add("Text", "x0 yp+34 vNTLabel", "Natro Macro Path: ")
	ASMGui.Add("Text", "x0 yp vNTVal c" ((validScript) ? "Green" : "Red"), (status = 1) ? "None" : (validScript) ? "Valid" : "Invalid")
	CenterText(ASMGui["NTLabel"], ASMGui["NTVal"], ASMGui["StatusText"])
	ASMGui.Add("Text", "x0 yp+16 vASLabel", "Start Macro On Run: ")
	ASMGui.Add("Text", "x0 yp vASVal c" ((autostart) ? "Green" : "Red"), (status = 1) ? "None" : (autostart) ? "Enabled" : "Disabled")
	CenterText(ASMGui["ASLabel"], ASMGui["ASVal"], ASMGui["StatusText"])
	ASMGui.Add("Text", "x0 yp+16 w" w " vDelay +Center", "Delay Duration: " delay)

	ASMGui.Add("Button", "x10 yp+22 w115 h24", "Remove").OnEvent("Click", RemoveButton)
	ASMGui.Add("Button", "x135 yp w115 h24", "Add").OnEvent("Click", AddButton)

	ASMGui.Add("GroupBox", "x5 yp+30 w250 h54 Section", "New Task Settings")
	ASMGui.SetFont("s8 cDefault Norm", "Tahoma")
	ASMGui.Add("CheckBox", "vAutoStartCheck x12 ys+18 Checked", "Start Macro on Run")
	ASMGui.Add("Text", "x13 yp+16", "Delay Before Run:")
	ASMGui.Add("Text", "vDelayText x+0 yp w50 +Center", "0s")
	ASMGui.Add("UpDown", "vDelayDuration x+0 yp-1 w10 h16 -16 Range0-3599", 0).OnEvent("Change", ChangeDelay)

	ASMGui.Show("w" w-10 " h" h-10)
}
ChangeDelay(*)
{
	ASMGui["DelayText"].Text := hmsFromSeconds(ASMGui["DelayDuration"].Value)
}
AddButton(*)
{
	global
	local task, autostart, secs

	if (task := RegRead("HKCU\Software\Microsoft\Windows\CurrentVersion\Run", "NatroMacro", ""))
		if (MsgBox("Are you sure?`nThis will overwrite the existing Natro Macro auto-start!", "Overwrite Existing Entry", 0x40024 " T30 Owner" ASMGui.Hwnd) != "Yes")
			return

	autostart := ASMGui["AutoStartCheck"].Value
	secs := ASMGui["DelayDuration"].Value

	RegWrite '"' A_WorkingDir '\START.bat"'
		. ((autostart = 1) ?  ' "1"' : ' ""')		; autostart parameter
		. ' ""'										; existing heartbeat PID
		. ((secs > 0) ?  ' "' secs '"' : ' ""')		; delay before run (.bat)
		, "REG_SZ", "HKCU\Software\Microsoft\Windows\CurrentVersion\Run", "NatroMacro"

	ASMGui["Delay"].Text := "Delay Duration: " ((secs > 0) ? hmsFromSeconds(secs) : "None")
	ASMGui["StatusVal"].SetFont("cGreen", "Tahoma"), ASMGui["StatusVal"].Text := "Active"
	CenterText(ASMGui["StatusLabel"], ASMGui["StatusVal"], ASMGui["StatusLabel"])
	ASMGui["StatusText"].SetFont("cGreen"), ASMGui["StatusText"].Text := "Natro Macro will automatically start on user login using the settings below:"
	ASMGui["NTVal"].SetFont("cGreen"), ASMGui["NTVal"].Text := "Valid"
	CenterText(ASMGui["NTLabel"], ASMGui["NTVal"], ASMGui["StatusText"])
	ASMGui["ASVal"].SetFont((autostart = 1) ? "cGreen" : "cRed"), ASMGui["ASVal"].Text := (autostart = 1) ? "Enabled" : "Disabled"
	CenterText(ASMGui["ASLabel"], ASMGui["ASVal"], ASMGui["StatusText"])
}
RemoveButton(*)
{
	global

	try RegDelete "HKCU\Software\Microsoft\Windows\CurrentVersion\Run", "NatroMacro"
	catch
	{
		; show msgbox
	}
	else
	{
		ASMGui["Delay"].Text := "Delay Duration: None"
		ASMGui["StatusVal"].SetFont("cRed", "Tahoma"), ASMGui["StatusVal"].Text := "Inactive"
		CenterText(ASMGui["StatusLabel"], ASMGui["StatusVal"], ASMGui["StatusLabel"])
		ASMGui["StatusText"].SetFont("cRed"), ASMGui["StatusText"].Text := "No Natro Macro auto-start found!`nUse the 'Add' button below."
		ASMGui["NTVal"].SetFont("cRed"), ASMGui["NTVal"].Text := "None"
		CenterText(ASMGui["NTLabel"], ASMGui["NTVal"], ASMGui["StatusText"])
		ASMGui["ASVal"].SetFont("cRed"), ASMGui["ASVal"].Text := "None"
		CenterText(ASMGui["ASLabel"], ASMGui["ASVal"], ASMGui["StatusText"])
	}
}
nm_NightAnnouncementGUI(*){
	global
	GuiClose(*){
		if (IsSet(NightGui) && IsObject(NightGui))
			NightGui.Destroy(), NightGui := ""
	}
	GuiClose()
	NightGui := Gui("+AlwaysOnTop -MinimizeBox +Owner" MainGui.Hwnd, "Announce Night Detection")
	NightGui.OnEvent("Close", GuiClose)
	NightGui.SetFont("s8 cDefault Bold", "Tahoma")
	NightGui.Add("GroupBox", "x5 y2 w290 h65", "Settings")
	NightGui.Add("CheckBox", "x73 y2 vNightAnnouncementCheck Checked" NightAnnouncementCheck, "Enabled").OnEvent("Click", nm_NightAnnouncementCheck)
	NightGui.SetFont("Norm")
	NightGui.Add("Button", "x150 y1 w135 h16", "What does this do?").OnEvent("Click", nm_NightAnnouncementHelp)
	NightGui.Add("Text", "x15 y23", "Name:")
	NightGui.Add("Edit", "x48 y21 w75 h18 vNightAnnouncementName Disabled" (NightAnnouncementCheck = 0), NightAnnouncementName).OnEvent("Change", nm_saveNightAnnouncementName)
	NightGui.Add("Text", "x130 y23", "Ping ID:")
	NightGui.Add("Edit", "x170 y21 w115 h18 vNightAnnouncementPingID Disabled" (NightAnnouncementCheck = 0), NightAnnouncementPingID).OnEvent("Change", nm_saveNightAnnouncementPingID)
	NightGui.Add("Text", "x15 y45", "Webhook:")
	NightGui.Add("Edit", "x67 y43 w218 h18 vNightAnnouncementWebhook Disabled" (NightAnnouncementCheck = 0), NightAnnouncementWebhook).OnEvent("Change", nm_saveNightAnnouncementWebhook)
	NightGui.Show("w290 h62")
}
nm_NightAnnouncementCheck(*){
	global NightAnnouncementCheck, NightGui
	NightAnnouncementCheck := NightGui["NightAnnouncementCheck"].Value
	PostSubmacroMessage("Status", 0x5552, 220, NightAnnouncementCheck)
	IniWrite NightAnnouncementCheck, "settings\nm_config.ini", "Status", "NightAnnouncementCheck"
	NightGui["NightAnnouncementName"].Enabled := NightGui["NightAnnouncementPingID"].Enabled := NightGui["NightAnnouncementWebhook"].Enabled := NightAnnouncementCheck
}
nm_saveNightAnnouncementName(GuiCtrl, *){
	global NightAnnouncementName
	p := EditGetCurrentCol(GuiCtrl)
	NewNightAnnouncementName := GuiCtrl.Value

	if InStr(NewNightAnnouncementName, "\")
	{
		GuiCtrl.Value := NightAnnouncementName
		SendMessage 0xB1, p-2, p-2, GuiCtrl
		nm_ShowErrorBalloonTip(GuiCtrl, "Unacceptable Character", "The name cannot include the following characters:`n'\'")
	}
	else
	{
		NightAnnouncementName := NewNightAnnouncementName
		IniWrite NightAnnouncementName, "settings\nm_config.ini", "Status", "NightAnnouncementName"
		PostSubmacroMessage("Status", 0x5553, 48, 7)
	}

	;enum
	IniWrite NightAnnouncementName, "settings\nm_config.ini", "Status", "NightAnnouncementName"
}
nm_saveNightAnnouncementPingID(GuiCtrl, *){
	global NightAnnouncementPingID
	p := EditGetCurrentCol(GuiCtrl)
	NewNightAnnouncementPingID := GuiCtrl.Value

	if (NewNightAnnouncementPingID ~= "i)^&?[0-9]*$")
	{
		NightAnnouncementPingID := NewNightAnnouncementPingID
		IniWrite NightAnnouncementPingID, "settings\nm_config.ini", "Status", "NightAnnouncementPingID"
		PostSubmacroMessage("Status", 0x5553, 49, 7)
	}
	else
	{
		GuiCtrl.Value := NightAnnouncementPingID
		SendMessage 0xB1, p-2, p-2, GuiCtrl
		nm_ShowErrorBalloonTip(GuiCtrl, "Invalid Discord Ping ID!", "Make sure it is a valid User ID or Role ID (starting with &).")
	}
}
nm_saveNightAnnouncementWebhook(GuiCtrl, *){
	global NightAnnouncementWebhook
	p := EditGetCurrentCol(GuiCtrl)
	str := GuiCtrl.Value
	RegexMatch(str, "i)https:\/\/(canary\.|ptb\.)?(discord|discordapp)\.com\/api\/webhooks\/([\d]+)\/([a-z0-9_-]+)", &NewNightAnnouncementWebhook)

	if ((StrLen(str) = 0) || IsObject(NewNightAnnouncementWebhook))
	{
		NightAnnouncementWebhook := IsObject(NewNightAnnouncementWebhook) ? NewNightAnnouncementWebhook[0] : ""
		IniWrite NightAnnouncementWebhook, "settings\nm_config.ini", "Status", "NightAnnouncementWebhook"
		PostSubmacroMessage("Status", 0x5553, 50, 7)
	}
	else
	{
		GuiCtrl.Value := NightAnnouncementWebhook
		SendMessage 0xB1, p-2, p-2, GuiCtrl
		nm_ShowErrorBalloonTip(GuiCtrl, "Invalid Discord Webhook Link!", "Make sure your link is copied directly from Discord.")
	}
}
nm_NightAnnouncementHelp(*){
	MsgBox "
	(
	DESCRIPTION:
	When this option is enabled, the macro will send a message to the specified webhook alerting others that night has been detected in your server, allowing them to join and help fight Vicious Bee.
	NOTE: 'Kill Vicious Bee' must be enabled in Collect/Kill tab for night detection to run!

	Name:
	This is just what your name will show as, i.e. ___'s Server.

	Ping ID:
	You can enter either a User ID or Role ID here. Make sure to start a Role ID with '&'. If this option is not empty, the macro will ping this user/role when it sends the Night Detection message.

	Webhook:
	Here, you must enter the destination webhook for Night Detection Announcements.
	This is the channel where messages will be sent and people with access to the channel will be informed that it is nighttime in your server.
	)", "Announce Night Detection", 0x40000
}
nm_ReportBugButton(*){
	Run "https://github.com/NatroTeam/NatroMacro/issues/new?assignees=&labels=bug%2Cneeds+triage&projects=&template=bug.yml"
}
nm_MakeSuggestionButton(*){
	Run "https://github.com/NatroTeam/NatroMacro/issues/new?assignees=&labels=suggestion%2Cneeds+triage&projects=&template=suggestion.yml"
}
blc_mutations(*) {
	global
	local script, exec
	try ProcessClose(MGUIPID)
	script :=
	(
	'
	/************************************************************************
	 * @description Auto-Jelly is a macro for the game Bee Swarm Simulator on Roblox. It automatically rolls bees for mutations and stops when a bee with the desired mutation is found. It also has the ability to stop on mythic and gifted bees.
	 * @file auto-jelly.ahk
	 * @author ninju | .ninju.
	 * @date 2024/07/24
	 * @version 0.0.1
	 ***********************************************************************/

	#SingleInstance Force
	#Requires AutoHotkey v2.0
	#Warn VarUnset, Off
	;=============INCLUDES=============
	#Include %A_ScriptDir%\lib\Gdip_All.ahk
	#include %A_ScriptDir%\lib\Roblox.ahk
	#include %A_ScriptDir%\lib\Gdip_ImageSearch.ahk
	#include %A_ScriptDir%\lib\ErrorHandling.ahk
	;==================================
	SendMode("Event")
	CoordMode(`'Pixel`', `'Screen`')
	CoordMode(`'Mouse`', `'Screen`')
	;==================================
	pToken := Gdip_Startup()
	OnExit((*) => (closefunction()), -1)
	stopToggle(*) {
		global stopping := true
	}
	class __ArrEx extends Array {
		static __New() {
			Super.Prototype.includes := ObjBindMethod(this, `'includes`')
		}
		static includes(arr, val) {
			for i, j in arr {
				if j = val
					return i
			}
			return 0
		}
	}

	if A_ScreenDPI !== 96
		throw Error("This macro requires a display-scale of 100%")
	traySetIcon(".\nm_image_assets\birb.ico")
	getConfig() {
		global
		local k, v, p, c, i, section, key, value, inipath, config, f, ini
		config := {
			mutations: {
				Mutations: 0,
				Ability: 0,
				Gather: 0,
				Convert: 0,
				Energy: 0,
				Movespeed: 0,
				Crit: 0,
				Instant: 0,
				Attack: 0
			},
			bees: {
				Bomber: 0,
				Brave: 0,
				Bumble: 0,
				Cool: 0,
				Hasty: 0,
				Looker: 0,
				Rad: 0,
				Rascal: 0,
				Stubborn: 0,
				Bubble: 0,
				Bucko: 0,
				Commander: 0,
				Demo: 0,
				Exhausted: 0,
				Fire: 0,
				Frosty: 0,
				Honey: 0,
				Rage: 0,
				Riley: 0,
				Shocked: 0,
				Baby: 0,
				Carpenter: 0,
				Demon: 0,
				Diamond: 0,
				Lion: 0,
				Music: 0,
				Ninja: 0,
				Shy: 0,
				Buoyant: 0,
				Fuzzy: 0,
				Precise: 0,
				Spicy: 0,
				Tadpole: 0,
				Vector: 0,
				selectAll: 0
			},
			GUI : {
				xPos: A_ScreenWidth//2-w//2,
				yPos: A_ScreenHeight//2-h//2
			},
			extrasettings: {
				mythicStop: 0,
				giftedStop: 0
			}
		}
		for i, section in config.OwnProps()
			for key, value in section.OwnProps()
				%key% := value
		if !FileExist(".\settings")
			DirCreate(".\settings")
		inipath := ".\settings\mutations.ini"
		if FileExist(inipath) {
			loop parse FileRead(inipath), "``n", "``r" A_Space A_Tab {
				switch (c:=SubStr(A_LoopField,1,1)) {
					case "[", ";": continue
					default:
					if (p := InStr(A_LoopField, "="))
						try k := SubStr(A_LoopField, 1, p-1), %k% := IsInteger(v := SubStr(A_LoopField, p+1)) ? Integer(v) : v
				}
			}
		}
		ini:=""
		for k, v in config.OwnProps() {
			ini .= "[" k "]``r``n"
			for i in v.OwnProps()
				ini .= i "=" %i% "``r``n"
			ini .= "``r``n"
		}
		(f:=FileOpen(inipath, "w")).Write(ini), f.Close()
	}
	;===Dimensions===
	w:=500,h:=397
	;===Bee Array===
	beeArr := ["Bomber", "Brave", "Bumble", "Cool", "Hasty", "Looker", "Rad", "Rascal", "Stubborn", "Bubble", "Bucko", "Commander", "Demo", "Exhausted", "Fire", "Frosty", "Honey", "Rage", "Riley", "Shocked", "Baby", "Carpenter", "Demon", "Diamond", "Lion", "Music", "Ninja", "Shy", "Buoyant", "Fuzzy", "Precise", "Spicy", "Tadpole", "Vector"]
	mutationsArr := [
		{name:"Ability", triggers:["rate", "abil", "ity"], full:"AbilityRate"},
		{name:"Gather", triggers:["gath", "herAm"], full:"GatherAmount"},
		{name:"Convert", triggers:["convert", "vertAm"], full:"ConvertAmount"},
		{name:"Instant", triggers:["inst", "antConv"], full:"InstantConversion"},
		{name:"Crit", triggers:["crit", "chance"], full:"CriticalChance"},
		{name:"Attack", triggers:["attack", "att", "ack"], full:"Attack"},
		{name:"Energy", triggers:["energy", "rgy"], full:"Energy"},
		{name:"Movespeed", triggers:["movespeed", "speed", "move"], full:"MoveSpeed"},
	]
	extrasettings:=[
		{name:"mythicStop", text: "Stop on mythics"},
		{name:"giftedStop", text: "Stop on gifteds"}
	]
	getConfig()
	(bitmaps := Map()).CaseSense:=0
	#Include .\nm_image_assets\mutator\bitmaps.ahk
	#include .\nm_image_assets\mutatorgui\bitmaps.ahk
	#include .\nm_image_assets\offset\bitmaps.ahk
	startGui() {
		global
		local i,j,y,hBM,x
		(mgui := Gui("+E" (0x00080000) " +OwnDialogs -Caption -DPIScale", "Auto-Jelly")).OnEvent("Close", ExitApp)
		mgui.Show()
		for i, j in [
			{name:"move", options:"x0 y0 w" w " h36"},
			{name:"selectall", options:"x" w-330 " y220 w40 h18"},
			{name:"mutations", options:"x" w-170 " y220 w40 h18"},
			{name:"close", options:"x" w-40 " y5 w28 h28"},
			{name:"roll", options:"x10 y" h-42 " w" w-56 " h30"},
			{name:"help", options:"x" w-40 " y" h-42 " w28 h28"}
		]
			mgui.AddText("v" j.name " " j.options)
		for i, j in beeArr {
			y := (A_Index-1)//8*1
			mgui.AddText("v" j " x" 10+mod(A_Index-1,8)*60 " y" 50+y*40 " w45 h36")
		}
		for i, j in mutationsArr {
			y := (A_Index-1)//4*1
			mgui.AddText("v" j.name " x" 10+mod(A_Index-1,4)*120 " y" 260+y*25 " w40 h18")
		}
		for i, j in extrasettings {
			x := 10 + (w-12)/extrasettings.length * (i-1), y:=(316+h-42)//2-10
			mgui.AddText("v" j.name " x" x " y" y " w40 h18")
		}
		hBM := CreateDIBSection(w, h)
		hDC := CreateCompatibleDC()
		SelectObject(hDC, hBM)
		G := Gdip_GraphicsFromHDC(hDC)
		Gdip_SetSmoothingMode(G, 4)
		Gdip_SetInterpolationMode(G, 7)
		update := UpdateLayeredWindow.Bind(mgui.hwnd, hDC)
		update(xpos < 0 ? 0 : xpos > A_ScreenWidth ? 0 : xpos, ypos < 0 ? 0 : ypos > A_ScreenHeight ? 0 : ypos, w, h)
		hovercontrol := ""
		DrawGUI()
	}
	startGUI()
	OnMessage(0x201, WM_LBUTTONDOWN)
	OnMessage(0x200, WM_MOUSEMOVE)
	DrawGUI() {
		Gdip_GraphicsClear(G)
		Gdip_FillRoundedRectanglePath(G, brush := Gdip_BrushCreateSolid(0xFF131416), 2, 2, w-4, h-4, 20), Gdip_DeleteBrush(brush)
		region := Gdip_GetClipRegion(G)
		Gdip_SetClipRect(G, 2, 21, w-2, 30, 4)
		Gdip_FillRoundedRectanglePath(G, brush := Gdip_BrushCreateSolid("0xFFFEC6DF"), 2, 2, w-4, 40, 20)
		Gdip_SetClipRegion(G, region)
		Gdip_FillRectangle(G, brush, 2, 20, w-4, 14)
		Gdip_DeleteBrush(brush), Gdip_DeleteRegion(region)
		Gdip_TextToGraphics(G, "Auto-Jelly", "s20 x20 y5 w460 Near vCenter c" (brush := Gdip_BrushCreateSolid("0xFF131416")), "Comic Sans MS", 460, 30), Gdip_DeleteBrush(brush)
		Gdip_DrawImage(G, bitmaps["close"], w-40, 5, 28, 28)
		for i, j in beeArr {
			;bitmaps are w45 h36
			y := (A_Index-1)//8
			bm := hovercontrol = j && (%j% || SelectAll) ? j "bghover" : %j% || SelectAll ? j "bg" : hovercontrol = j ? j "hover" : j
			Gdip_DrawImage(G, bitmaps[bm], 10+mod(A_Index-1,8)*60, 50+y*40, 45, 36)
		}
		;===Switches===
		Gdip_FillRoundedRectanglePath(G, brush := Gdip_BrushCreateSolid("0xFF" . 13*2 . 14*2 . 16*2), w-330, 220, 40, 18, 9), Gdip_DeleteBrush(brush)
		Gdip_FillEllipse(G, brush:=Gdip_BrushCreateSolid("0xFFFEC6DF"), selectAll ? w-310 : w-332, 218, 22, 22)
		Gdip_TextToGraphics(G, "Select All Bees", "s14 x" w-284 " y220 Near vCenter c" brush, "Comic Sans MS",, 20), Gdip_DeleteBrush(brush)
		if !SelectAll {
			Gdip_FillEllipse(G, brush:=Gdip_BrushCreateSolid("0xFF" . 13*2 . 14*2 . 16*2), w-330, 220, 18, 18), Gdip_DeleteBrush(brush)
			Gdip_DrawLines(G, Pen:=Gdip_CreatePen("0xFFCC0000", 2), [[w-325, 225], [w-317, 233]])
			Gdip_DrawLines(G, Pen								  , [[w-325, 233], [w-317, 225]]), Gdip_DeletePen(Pen)
		}
		else
			Gdip_DrawLines(G, Pen:=Gdip_CreatePen("0xFF006600", 2), [[w-303, 229], [w-300, 232], [w-295, 225]]), Gdip_DeletePen(Pen)
		Gdip_FillRoundedRectanglePath(G, brush := Gdip_BrushCreateSolid("0xFF" . 13*2 . 14*2 . 16*2), w-170, 220, 40, 18, 9), Gdip_DeleteBrush(brush)
		Gdip_FillEllipse(G, brush:=Gdip_BrushCreateSolid("0xFFFEC6DF"), mutations ? w-150 : w-172, 218, 22, 22)
		Gdip_TextToGraphics(G, "Mutations", "s14 x" w-124 " y220 Near vCenter c" (brush), "Comic Sans MS",, 20), Gdip_DeleteBrush(brush)
		if !mutations {
			Gdip_FillEllipse(G, brush:= Gdip_BrushCreateSolid("0xFF" . 13*2 . 14*2 . 16*2), w-170, 220, 18, 18), Gdip_DeleteBrush(brush)
			Gdip_DrawLines(G, Pen:=Gdip_CreatePen("0xFFCC0000", 2), [[w-165, 225], [w-157, 233]])
			Gdip_DrawLines(G, Pen								  , [[w-165, 233], [w-157, 225]]), Gdip_DeletePen(Pen)
		}
		else
			Gdip_DrawLines(G, Pen:=Gdip_CreatePen("0xFF006600", 2), [[w-143, 229], [w-140, 232], [w-135, 225]]), Gdip_DeletePen(Pen)
		For i, j in mutationsArr {
			y := (A_Index-1)//4
			Gdip_FillRoundedRectanglePath(G, brush := Gdip_BrushCreateSolid("0xFF" . 13*2 . 14*2 . 16*2), 10+mod(A_Index-1,4)*120, 260+y*25, 40, 18, 9), Gdip_DeleteBrush(brush)
			Gdip_FillEllipse(G, brush:=Gdip_BrushCreateSolid("0xFFFEC6DF"), (%j.name% ? 3.2 : 1) * 8+mod(A_Index-1,4)*120, 258+y*25, 22, 22), Gdip_DeleteBrush(brush)
			Gdip_TextToGraphics(G, j.name, "s13 x" 56+mod(A_Index-1,4)*120 " y" 260+y*25 " vCenter c" (brush := Gdip_BrushCreateSolid("0xFFFEC6DF")), "Comic Sans MS", 100, 20), Gdip_DeleteBrush(brush)
			if !%j.name% {
				Gdip_FillEllipse(G, brush:=Gdip_BrushCreateSolid("0xFF262832"), x:=10+mod(A_Index-1,4)*120, yp:=258+y*25+2, 18, 18), Gdip_DeleteBrush(brush)
				Gdip_DrawLines(G, Pen:=Gdip_CreatePen("0xFFCC0000", 2), [[x+5, yp+5 ], [x+13, yp+13]])
				Gdip_DrawLines(G, Pen								  , [[x+5, yp+13], [x+13, yp+5 ]]), Gdip_DeletePen(Pen)
			}
			else
				Gdip_DrawLines(G, Pen:=Gdip_CreatePen("0xFF006600", 2), [[x:=32.6+mod(A_Index-1,4)*120, yp:=269+y*25], [x+3, yp+3], [x+8, yp-4]]), Gdip_DeletePen(Pen)
		}
		if !mutations
			Gdip_FillRectangle(G, brush:=Gdip_BrushCreateSolid("0x70131416"), 9, 255, w-18, 52), Gdip_DeleteBrush(brush)
		Gdip_DrawLine(G, Pen:=Gdip_CreatePen("0xFFFEC6DF", 2), 10, 315, w-12, 315), Gdip_DeletePen(Pen)
		;two more switches for "stop on mythic" and "stop on gifted"
		for i, j in extrasettings {
			x := 10 + (tw:=(w-12)/extrasettings.length) * (i-1), y:=(316+h-42)//2-10
			Gdip_FillRoundedRectanglePath(G, brush:=Gdip_BrushCreateSolid("0xFF262832"), x, y, 40, 18, 9), Gdip_DeleteBrush(brush), Gdip_DeleteBrush(brush)
			Gdip_FillEllipse(G, brush:=Gdip_BrushCreateSolid("0xFFFEC6DF"), %j.name% ? x+18 : x-2, y-2, 22, 22)
			Gdip_TextToGraphics(G, j.text, "s14 x" x+46 " y" y " vCenter c" brush, "Comic Sans MS", tw,20), Gdip_DeleteBrush(brush)
			if !%j.name% {
				Gdip_FillEllipse(G, brush:=Gdip_BrushCreateSolid("0xFF262832"), x, y, 18, 18), Gdip_deleteBrush(brush)
				Gdip_DrawLines(G, Pen:=Gdip_CreatePen("0xFFCC0000", 2), [[x+5, y+5 ], [x+13, y+13]])
				Gdip_DrawLines(G, Pen								  , [[x+5, y+13], [x+13, y+5 ]]), Gdip_DeletePen(Pen)
			}
			else
				Gdip_DrawLines(G, Pen:=Gdip_CreatePen("0xFF006600", 2), [[x+25, y+9], [x+28, y+12], [x+33, y+5]]), Gdip_DeletePen(Pen)
		}
		if hovercontrol = "roll"
			Gdip_FillRoundedRectanglePath(G, brush:=Gdip_BrushCreateSolid("0x30FEC6DF"), 10, h-42, w-56, 30, 10), Gdip_DeleteBrush(brush)
		if hovercontrol = "help"
			Gdip_FillRoundedRectanglePath(G, brush:=Gdip_BrushCreateSolid("0x30FEC6DF"), w-40, h-42, 30, 30, 10), Gdip_DeleteBrush(brush)
		Gdip_TextToGraphics(G, "Roll!", "x10 y" h-40 " Center vCenter s15 c" (brush:=Gdip_BrushCreateSolid("0xFFFEC6DF")),"Comic Sans MS",w-56, 28)
		Gdip_TextToGraphics(G, "?", "x" w-39 " y" h-40 " Center vCenter s15 c" brush,"Comic Sans MS",30, 28), Gdip_DeleteBrush(brush)
		Gdip_DrawRoundedRectanglePath(G, pen:=Gdip_CreatePen("0xFFFEC6DF", 4), 10, h-42, w-56, 30, 10)
		Gdip_DrawRoundedRectanglePath(G, pen, w-40, h-42, 30, 30, 10), Gdip_DeletePen(pen)
		update()
	}
	WM_LBUTTONDOWN(wParam, lParam, msg, hwnd) {
		global hovercontrol, mutations, Bomber, Brave, Bumble, Cool, Hasty, Looker, Rad, Rascal
		, Stubborn, Bubble, Bucko, Commander, Demo, Exhausted, Fire, Frosty, Honey, Rage
		, Riley, Shocked, Baby, Carpenter, Demon, Diamond, Lion, Music, Ninja, Shy, Buoyant
		, Fuzzy, Precise, Spicy, Tadpole, Vector, SelectAll, Ability, Gather, Convert, Energy
		, Movespeed, Crit, Instant, Attack, mythicStop, giftedStop
		MouseGetPos(,,,&ctrl,2)
		if !ctrl
			return
		switch mgui[ctrl].name, 0 {
			case "move":
				PostMessage(0x00A1,2)
			case "close":
				while GetKeyState("LButton", "P")
					sleep -1
				mousegetpos ,,, &ctrl2, 2
				if ctrl = ctrl2
					PostMessage(0x0112,0xF060)
			case "roll":
				ReplaceSystemCursors()
				blc_start()
			case "help":
				ReplaceSystemCursors()
				Msgbox("This feature allows you to roll royal jellies until you obtain your specified bees and/or mutations!``n``nTo use:``n- Select the bees and mutations you want``n- Make sure your in-game Auto-Jelly settings are right``n- Put a neonberry on the bee you want to change (if trying ``n  to obtain a mutated bee) ``n- Use one royal jelly on the bee and click Yes``n- Click on Roll.``n``nTo stop: ``n- Press the escape key``n``nAdditional options:``n- Stop on Gifteds stops on any gifted bee, ``n  ignoring the mutation and your bee selection``n- Stop on Mythics stops on any mythic bee, ``n  ignoring the mutation and your bee selection", "Auto-Jelly Help", "0x40040")
			case "selectAll":
				IniWrite(%mgui[ctrl].name% ^= 1, ".\settings\mutations.ini", "bees", mgui[ctrl].name)
			case "Bomber", "Brave", "Bumble", "Cool", "Hasty", "Looker", "Rad", "Rascal", "Stubborn", "Bubble", "Bucko", "Commander", "Demo", "Exhausted", "Fire", "Frosty", "Honey", "Rage", "Riley":
				if !selectAll
					IniWrite(%mgui[ctrl].name% ^= 1, ".\settings\mutations.ini", "bees", mgui[ctrl].name)
			case "Shocked", "Baby", "Carpenter", "Demon", "Diamond", "Lion", "Music", "Ninja", "Shy", "Buoyant", "Fuzzy", "Precise", "Spicy", "Tadpole", "Vector":
				if !selectAll
					IniWrite(%mgui[ctrl].name% ^= 1, ".\settings\mutations.ini", "bees", mgui[ctrl].name)
			case "giftedStop", "mythicStop":
				IniWrite(%mgui[ctrl].name% ^= 1, ".\settings\mutations.ini", "extrasettings", mgui[ctrl].name)
			case "mutations":
				IniWrite(%mgui[ctrl].name% ^= 1, ".\settings\mutations.ini", "mutations", mgui[ctrl].name)
			default:
				if mutations
					IniWrite(%mgui[ctrl].name% ^= 1, ".\settings\mutations.ini", "mutations", mgui[ctrl].name)
		}
		DrawGUI()
	}
	WM_MOUSEMOVE(wParam, lParam, msg, hwnd) {
		global
		local ctrl, hover_ctrl, tt := 0
		MouseGetPos(,,,&ctrl,2)
		if !ctrl || mgui["move"].hwnd = ctrl || mgui["close"].hwnd = ctrl
			return
		ReplaceSystemCursors("IDC_HAND")
		hovercontrol := mgui[ctrl].name
		hover_ctrl := mgui[ctrl].hwnd
		DrawGUI()
		while ctrl = hover_ctrl {
			sleep(20),MouseGetPos(,,,&ctrl,2)
			if A_Index > 120 && beeArr.includes(hovercontrol) && !tt
				tt:=1,ToolTip(hovercontrol . " Bee")
		}
		hovercontrol := ""
		ToolTip()
		ReplaceSystemCursors()
		DrawGUI()
	}
	ReplaceSystemCursors(IDC := "")
	{
		static IMAGE_CURSOR := 2, SPI_SETCURSORS := 0x57
			, SysCursors := Map(  "IDC_APPSTARTING", 32650
								, "IDC_ARROW"      , 32512
								, "IDC_CROSS"      , 32515
								, "IDC_HAND"       , 32649
								, "IDC_HELP"       , 32651
								, "IDC_IBEAM"      , 32513
								, "IDC_NO"         , 32648
								, "IDC_SIZEALL"    , 32646
								, "IDC_SIZENESW"   , 32643
								, "IDC_SIZENWSE"   , 32642
								, "IDC_SIZEWE"     , 32644
								, "IDC_SIZENS"     , 32645
								, "IDC_UPARROW"    , 32516
								, "IDC_WAIT"       , 32514 )
		if !IDC
			DllCall("SystemParametersInfo", "UInt", SPI_SETCURSORS, "UInt", 0, "UInt", 0, "UInt", 0)
		else
		{
			hCursor := DllCall("LoadCursor", "Ptr", 0, "UInt", SysCursors[IDC], "Ptr")
			for k, v in SysCursors
			{
				hCopy := DllCall("CopyImage", "Ptr", hCursor, "UInt", IMAGE_CURSOR, "Int", 0, "Int", 0, "UInt", 0, "Ptr")
				DllCall("SetSystemCursor", "Ptr", hCopy, "UInt", v)
			}
		}
	}
	blc_start() {
		global stopping:=false
		hotkey "~*esc", stopToggle, "On"
		selectedBees := [], selectedMutations := []
		for i in beeArr
			if %i% || SelectAll
				selectedBees.push(i)
		if mutations {
			selectedMutations := []
			for i in mutationsArr
				if %i.name%
					selectedMutations.push(i)
		}
		ocr_enabled := 1
		ocr_language := ""
		for k,v in Map("Windows.Globalization.Language","{9B0252AC-0C27-44F8-B792-9793FB66C63E}", "Windows.Graphics.Imaging.BitmapDecoder","{438CCB26-BCEF-4E95-BAD6-23A822E58D01}", "Windows.Media.Ocr.OcrEngine","{5BFFA85A-3384-3540-9940-699120D428A8}") {
			CreateHString(k, &hString)
			GUID := Buffer(16), DllCall("ole32\CLSIDFromString", "WStr", v, "Ptr", GUID)
			result := DllCall("Combase.dll\RoGetActivationFactory", "Ptr", hString, "Ptr", GUID, "PtrP", &pClass:=0)
			DeleteHString(hString)
			if (result != 0)
			{
				ocr_enabled := 0
				break
			}
		}
		if !(ocr_enabled) && mutations
			msgbox "OCR is disabled. This means that the macro will not be able to detect mutations.",, 0x40010
		list := ocr("ShowAvailableLanguages")
		lang:="en-"
		Loop Parse list, "``n", "``r" {
			if (InStr(A_LoopField, lang) = 1) {
				ocr_language := A_LoopField
				break
			}
		}
		if (ocr_language = "" && ocr_enabled)
			if ((ocr_language := SubStr(list, 1, InStr(list, "``n")-1)) = "")
				return msgbox("No OCR supporting languages are installed on your system! Please follow the Knowledge Base guide to install a supported language as a secondary language on Windows.", "WARNING!!", 0x1030)
		if !(hwndRoblox:=GetRobloxHWND()) || !(GetRobloxClientPos(), windowWidth)
			return msgbox("You must have Bee Swarm Simulator open to use this!", "Auto-Jelly", 0x40030)
		if !selectedBees.length
			return msgbox("You must select at least one bee to run this macro!", "Auto-Jelly", 0x40030)
		yOffset := GetYOffset(hwndRoblox, &fail)
		if fail
			MsgBox("Unable to detect in-game GUI offset!``nThis means the macro will NOT work correctly!``n``nThere are a few reasons why this can happen:``n- Incorrect graphics settings (check Troubleshooting Guide!)``n- Your Experience Language is not set to English``n- Something is covering the top of your Roblox window``n``nJoin our Discord server for support!", "WARNING!!", 0x1030 " T60")
		if mgui is Gui
			mgui.hide()
		While !stopping {
			ActivateRoblox()
			click windowX + Round(0.5 * windowWidth + 10) " " windowY + yOffset + Round(0.4 * windowHeight + 230)
			sleep 800
			pBitmap := Gdip_BitmapFromScreen(windowX + 0.5*windowWidth - 155 "|" windowY + yOffset + 0.425*windowHeight - 200 "|" 320 "|" 140)
			if mythicStop
				for i, j in ["Buoyant", "Fuzzy", "Precise", "Spicy", "Tadpole", "Vector"]
					if Gdip_ImageSearch(pBitmap, bitmaps["-" j]) || Gdip_ImageSearch(pBitmap, bitmaps["+" j]) {
						Gdip_DisposeImage(pBitmap)
						msgbox "Found a mythic bee!", "Auto-Jelly", 0x40040
						break 2
					}
			if giftedStop
				for i, j in beeArr {
					if Gdip_ImageSearch(pBitmap, bitmaps["+" j]) {
						Gdip_DisposeImage(pBitmap)
						msgbox "Found a gifted bee!", "Auto-Jelly", 0x40040
						break 2
					}
				}
			found := 0
			for i, j in selectedBees {
				if Gdip_ImageSearch(pBitmap, bitmaps["-" j]) || Gdip_ImageSearch(pBitmap, bitmaps["+" j]) {
					if (!mutations || !ocr_enabled || !selectedMutations.length) {
						Gdip_DisposeImage(pBitmap)
						if msgbox("Found a match!``nDo you want to keep this?","Auto-Jelly!", 0x40044) = "Yes"
							break 2
						else
							continue 2
					}
					found := 1
					break
				}
			}
			Gdip_DisposeImage(pBitmap)
			if !found
				continue
			pBitmap := Gdip_BitmapFromScreen(windowX + Round(0.5 * windowWidth - 320) "|" windowY + yOffset + Round(0.4 * windowHeight + 17) "|210|90")
			pEffect := Gdip_CreateEffect(5, -60,30)
			Gdip_BitmapApplyEffect(pBitmap, pEffect)
			Gdip_DisposeEffect(pEffect)
			hBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmap)
			pIRandomAccessStream := HBitmapToRandomAccessStream(hBitmap)
			text:= RegExReplace(ocr(pIRandomAccessStream), "i)([\r\n\s]|mutation)*")
			found := 0
			for i, j in selectedMutations
				for k, trigger in j.triggers
					if inStr(text, trigger) {
						found := 1
						break
					}
			if !found
				continue
			if msgbox("Found a match!``nDo you want to keep this?","Auto-Jelly!", 0x40044) = "Yes"
				break
		}
		hotkey "~*esc", stopToggle, "Off"
		mgui.show()
	}
	closeFunction(*) {
		global xPos, yPos
		Gdip_Shutdown(pToken)
		ReplaceSystemCursors()
		try {
			mgui.getPos(&xp, &yp)
			if !(xp < 0) && !(xp > A_ScreenWidth) && !(yp < 0) && !(yp > A_ScreenHeight)
				xPos := xp, yPos := yp
			IniWrite(xpos, ".\settings\mutations.ini", "GUI", "xpos")
			IniWrite(ypos, ".\settings\mutations.ini", "GUI", "ypos")
		}
	}
	HBitmapToRandomAccessStream(hBitmap) {
		static IID_IRandomAccessStream := "{905A0FE1-BC53-11DF-8C49-001E4FC686DA}"
				, IID_IPicture            := "{7BF80980-BF32-101A-8BBB-00AA00300CAB}"
				, PICTYPE_BITMAP := 1
				, BSOS_DEFAULT   := 0
				, sz := 8 + A_PtrSize * 2

		DllCall("Ole32\CreateStreamOnHGlobal", "Ptr", 0, "UInt", true, "PtrP", &pIStream:=0, "UInt")

		PICTDESC := Buffer(sz, 0)
		NumPut("uint", sz
			, "uint", PICTYPE_BITMAP
			, "ptr", hBitmap, PICTDESC)

		riid := CLSIDFromString(IID_IPicture)
		DllCall("OleAut32\OleCreatePictureIndirect", "Ptr", PICTDESC, "Ptr", riid, "UInt", false, "PtrP", &pIPicture:=0, "UInt")
		; IPicture::SaveAsFile
		ComCall(15, pIPicture, "Ptr", pIStream, "UInt", true, "UIntP", &size:=0, "UInt")
		riid := CLSIDFromString(IID_IRandomAccessStream)
		DllCall("ShCore\CreateRandomAccessStreamOverStream", "Ptr", pIStream, "UInt", BSOS_DEFAULT, "Ptr", riid, "PtrP", &pIRandomAccessStream:=0, "UInt")
		ObjRelease(pIPicture)
		ObjRelease(pIStream)
		Return pIRandomAccessStream
	}

	CLSIDFromString(IID, &CLSID?) {
		CLSID := Buffer(16)
		if res := DllCall("ole32\CLSIDFromString", "WStr", IID, "Ptr", CLSID, "UInt")
		throw Error("CLSIDFromString failed. Error: " . Format("{:#x}", res))
		Return CLSID
	}

	ocr(file, lang := "FirstFromAvailableLanguages")
	{
		static OcrEngineStatics, OcrEngine, MaxDimension, LanguageFactory, Language, CurrentLanguage:="", BitmapDecoderStatics, GlobalizationPreferencesStatics
		if !IsSet(OcrEngineStatics)
		{
			CreateClass("Windows.Globalization.Language", ILanguageFactory := "{9B0252AC-0C27-44F8-B792-9793FB66C63E}", &LanguageFactory)
			CreateClass("Windows.Graphics.Imaging.BitmapDecoder", IBitmapDecoderStatics := "{438CCB26-BCEF-4E95-BAD6-23A822E58D01}", &BitmapDecoderStatics)
			CreateClass("Windows.Media.Ocr.OcrEngine", IOcrEngineStatics := "{5BFFA85A-3384-3540-9940-699120D428A8}", &OcrEngineStatics)
			ComCall(6, OcrEngineStatics, "uint*", &MaxDimension:=0)
		}
		text := ""
		if (file = "ShowAvailableLanguages")
		{
			if !IsSet(GlobalizationPreferencesStatics)
				CreateClass("Windows.System.UserProfile.GlobalizationPreferences", IGlobalizationPreferencesStatics := "{01BF4326-ED37-4E96-B0E9-C1340D1EA158}", &GlobalizationPreferencesStatics)
			ComCall(9, GlobalizationPreferencesStatics, "ptr*", &LanguageList:=0)   ; get_Languages
			ComCall(7, LanguageList, "int*", &count:=0)   ; count
			loop count
			{
				ComCall(6, LanguageList, "int", A_Index-1, "ptr*", &hString:=0)   ; get_Item
				ComCall(6, LanguageFactory, "ptr", hString, "ptr*", &LanguageTest:=0)   ; CreateLanguage
				ComCall(8, OcrEngineStatics, "ptr", LanguageTest, "int*", &bool:=0)   ; IsLanguageSupported
				if (bool = 1)
				{
					ComCall(6, LanguageTest, "ptr*", &hText:=0)
					b := DllCall("Combase.dll\WindowsGetStringRawBuffer", "ptr", hText, "uint*", &length:=0, "ptr")
					text .= StrGet(b, "UTF-16") "``n"
				}
				ObjRelease(LanguageTest)
			}
			ObjRelease(LanguageList)
			return text
		}
		if (lang != CurrentLanguage) or (lang = "FirstFromAvailableLanguages")
		{
			if IsSet(OcrEngine)
			{
				ObjRelease(OcrEngine)
				if (CurrentLanguage != "FirstFromAvailableLanguages")
					ObjRelease(Language)
			}
			if (lang = "FirstFromAvailableLanguages")
				ComCall(10, OcrEngineStatics, "ptr*", &OcrEngine:=0)   ; TryCreateFromUserProfileLanguages
			else
			{
				CreateHString(lang, &hString)
				ComCall(6, LanguageFactory, "ptr", hString, "ptr*", &Language:=0)   ; CreateLanguage
				DeleteHString(hString)
				ComCall(9, OcrEngineStatics, "ptr", Language, "ptr*", &OcrEngine:=0)   ; TryCreateFromLanguage
			}
			if (OcrEngine = 0)
			{
				msgbox `'Can not use language "`' lang `'" for OCR, please install language pack.`'
				ExitApp
			}
			CurrentLanguage := lang
		}
		IRandomAccessStream := file
		ComCall(14, BitmapDecoderStatics, "ptr", IRandomAccessStream, "ptr*", &BitmapDecoder:=0)   ; CreateAsync
		WaitForAsync(&BitmapDecoder)
		BitmapFrame := ComObjQuery(BitmapDecoder, IBitmapFrame := "{72A49A1C-8081-438D-91BC-94ECFC8185C6}")
		ComCall(12, BitmapFrame, "uint*", &width:=0)   ; get_PixelWidth
		ComCall(13, BitmapFrame, "uint*", &height:=0)   ; get_PixelHeight
		if (width > MaxDimension) or (height > MaxDimension)
		{
			msgbox "Image is to big - " width "x" height ".``nIt should be maximum - " MaxDimension " pixels"
			ExitApp
		}
		BitmapFrameWithSoftwareBitmap := ComObjQuery(BitmapDecoder, IBitmapFrameWithSoftwareBitmap := "{FE287C9A-420C-4963-87AD-691436E08383}")
		ComCall(6, BitmapFrameWithSoftwareBitmap, "ptr*", &SoftwareBitmap:=0)   ; GetSoftwareBitmapAsync
		WaitForAsync(&SoftwareBitmap)
		ComCall(6, OcrEngine, "ptr", SoftwareBitmap, "ptr*", &OcrResult:=0)   ; RecognizeAsync
		WaitForAsync(&OcrResult)
		ComCall(6, OcrResult, "ptr*", &LinesList:=0)   ; get_Lines
		ComCall(7, LinesList, "int*", &count:=0)   ; count
		loop count
		{
			ComCall(6, LinesList, "int", A_Index-1, "ptr*", &OcrLine:=0)
			ComCall(7, OcrLine, "ptr*", &hText:=0)
			buf := DllCall("Combase.dll\WindowsGetStringRawBuffer", "ptr", hText, "uint*", &length:=0, "ptr")
			text .= StrGet(buf, "UTF-16") "``n"
			ObjRelease(OcrLine)
		}
		Close := ComObjQuery(IRandomAccessStream, IClosable := "{30D5A829-7FA4-4026-83BB-D75BAE4EA99E}")
		ComCall(6, Close)   ; Close
		Close := ComObjQuery(SoftwareBitmap, IClosable := "{30D5A829-7FA4-4026-83BB-D75BAE4EA99E}")
		ComCall(6, Close)   ; Close
		ObjRelease(IRandomAccessStream)
		ObjRelease(BitmapDecoder)
		ObjRelease(SoftwareBitmap)
		ObjRelease(OcrResult)
		ObjRelease(LinesList)
		return text
	}

	CreateClass(str, interface, &Class)
	{
		CreateHString(str, &hString)
		GUID := CLSIDFromString(interface)
		result := DllCall("Combase.dll\RoGetActivationFactory", "ptr", hString, "ptr", GUID, "ptr*", &Class:=0)
		if (result != 0)
		{
			if (result = 0x80004002)
				msgbox "No such interface supported"
			else if (result = 0x80040154)
				msgbox "Class not registered"
			else
				msgbox "error: " result
		}
		DeleteHString(hString)
	}

	CreateHString(str, &hString)
	{
		DllCall("Combase.dll\WindowsCreateString", "wstr", str, "uint", StrLen(str), "ptr*", &hString:=0)
	}

	DeleteHString(hString)
	{
		DllCall("Combase.dll\WindowsDeleteString", "ptr", hString)
	}

	WaitForAsync(&Object)
	{
		AsyncInfo := ComObjQuery(Object, IAsyncInfo := "{00000036-0000-0000-C000-000000000046}")
		loop
		{
			ComCall(7, AsyncInfo, "uint*", &status:=0)   ; IAsyncInfo.Status
			if (status != 0)
			{
				if (status != 1)
				{
					ComCall(8, AsyncInfo, "uint*", &ErrorCode:=0)   ; IAsyncInfo.ErrorCode
					msgbox "AsyncInfo status error: " ErrorCode
					ExitApp
				}
				break
			}
			sleep 10
		}
		ComCall(8, Object, "ptr*", &ObjectResult:=0)   ; GetResults
		ObjRelease(Object)
		Object := ObjectResult
	}
	'
	)
	exec := ComObject("WScript.shell").Exec('"' exe_path64 '" /script /force *')
	exec.StdIn.Write(script), exec.StdIn.Close()
	return (MGUIPID := exec.processID)
}