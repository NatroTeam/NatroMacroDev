localtoppollen := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAACoAAAALBAMAAAD7HQL7AAAAGFBMVEUAAAASFRcTFhgUFxkUFxgWGRsXGhwXGhsckMZRAAAAAXRSTlMAQObYZgAAABd0RVh0U29mdHdhcmUAUGhvdG9EZW1vbiA5LjDNHNgxAAADKGlUWHRYTUw6Y29tLmFkb2JlLnhtcAAAAAAAPD94cGFja2V0IGJlZ2luPSfvu78nIGlkPSdXNU0wTXBDZWhpSHpyZVN6TlRjemtjOWQnPz4KPHg6eG1wbWV0YSB4bWxuczp4PSdhZG9iZTpuczptZXRhLycgeDp4bXB0az0nSW1hZ2U6OkV4aWZUb29sIDEyLjQ0Jz4KPHJkZjpSREYgeG1sbnM6cmRmPSdodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjJz4KCiA8cmRmOkRlc2NyaXB0aW9uIHJkZjphYm91dD0nJwogIHhtbG5zOmV4aWY9J2h0dHA6Ly9ucy5hZG9iZS5jb20vZXhpZi8xLjAvJz4KICA8ZXhpZjpQaXhlbFhEaW1lbnNpb24+NDI8L2V4aWY6UGl4ZWxYRGltZW5zaW9uPgogIDxleGlmOlBpeGVsWURpbWVuc2lvbj4xMTwvZXhpZjpQaXhlbFlEaW1lbnNpb24+CiA8L3JkZjpEZXNjcmlwdGlvbj4KCiA8cmRmOkRlc2NyaXB0aW9uIHJkZjphYm91dD0nJwogIHhtbG5zOnRpZmY9J2h0dHA6Ly9ucy5hZG9iZS5jb20vdGlmZi8xLjAvJz4KICA8dGlmZjpJbWFnZUxlbmd0aD4xMTwvdGlmZjpJbWFnZUxlbmd0aD4KICA8dGlmZjpJbWFnZVdpZHRoPjQyPC90aWZmOkltYWdlV2lkdGg+CiAgPHRpZmY6T3JpZW50YXRpb24+MTwvdGlmZjpPcmllbnRhdGlvbj4KICA8dGlmZjpSZXNvbHV0aW9uVW5pdD4yPC90aWZmOlJlc29sdXRpb25Vbml0PgogIDx0aWZmOlhSZXNvbHV0aW9uPjk2LzE8L3RpZmY6WFJlc29sdXRpb24+CiAgPHRpZmY6WVJlc29sdXRpb24+OTYvMTwvdGlmZjpZUmVzb2x1dGlvbj4KIDwvcmRmOkRlc2NyaXB0aW9uPgo8L3JkZjpSREY+CjwveDp4bXBtZXRhPgo8P3hwYWNrZXQgZW5kPSdyJz8+kVOYmAAAAFdJREFUeNp1zMENg0AUA9HZKFGuHtEAdEIJlED/VSC0u/+C8M1PsjH0hEZF5alVnvovPWEdpelQBQ26IK3rF0IQw62Zo67hTbf58DmgtOkY6F7Kj5kDghc2CgW76l3tzQAAAABJRU5ErkJggg==")


localfindItem(input) {
items := ["Cog", "Ticket", "SprinklerBuilder", "BeequipCase", "Gumdrops", "Coconut", "Stinger", "MicroConverter", "Honeysuckle", "Whirligig", "FieldDice", "SmoothDice", "LoadedDice", "JellyBeans", "RedExtract", "BlueExtract", "Glitter", "Glue", "Oil", "Enzymes", "TropicalDrink", "PurplePotion", "SuperSmoothie", "MarshmallowBee", "MagicBean", "FestiveBean", "CloudVial", "NightBell", "BoxOFrogs", "AntPass", "BrokenDrive", "7ProngedCog", "RoboPass", "Translator", "SpiritPetal", "Present", "Treat", "StarTreat", "AtomicTreat", "SunflowerSeed", "Strawberry", "Pineapple", "Blueberry", "Bitterberry", "Neonberry", "MoonCharm", "GingerbreadBear", "AgedGingerbreadBear", "WhiteDrive", "RedDrive", "BlueDrive", "GlitchedDrive", "ComfortingVial", "InvigoratingVial", "MotivatingVial", "RefreshingVial", "SatisfyingVial", "PinkBalloon", "RedBalloon", "WhiteBalloon", "BlackBalloon", "SoftWax", "HardWax", "CausticWax", "SwirledWax", "Turpentine", "PaperPlanter", "TicketPlanter", "FestivePlanter", "PlasticPlanter", "CandyPlanter", "RedClayPlanter", "BlueClayPlanter", "TackyPlanter", "PesticidePlanter", "HeatTreatedPlanter", "HydroponicPlanter", "PetalPlanter", "ThePlanterOfPlenty", "BasicEgg", "SilverEgg", "GoldEgg", "DiamondEgg", "MythicEgg", "StarEgg", "GiftedSilverEgg", "GiftedGoldEgg", "GiftedDiamondEgg", "GiftedMythicEgg", "RoyalJelly", "StarJelly", "BumbleBeeEgg", "BumbleBeeJelly", "RageBeeJelly", "ShockedBeeJelly"]
; c = corrected
c := localfindClosestItem(items, input)
if (c = "") {
	discord.SendEmbed("either you entered nothing or the item doesnt exist, not running script", 1090401, , , , id)
}else{
	itemLookingFor := c
	global itemBitmaps
	WinActivate, Roblox
	sleep 100
	yoffset := localGetYOffset(hwnd)
	;MsgBox, %yoffset% ; testing
	WinActivate, Roblox
	; find where it's actually screenshotting, testing purposes
	/*
	localWinGetClientPos(windowX, windowY, windowWidth, windowHeight, "ahk_id " localGetRobloxHWND())

	pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY+150 "|306|" windowHeight-350)

	FilePath := A_ScriptDir "\captured_image.png"

	Gdip_SaveBitmapToFile(pBMScreen, FilePath)

	Gdip_DisposeImage(pBMScreen)
	localWinGetClientPos(windowX, windowY, windowWidth, windowHeight, "ahk_id " localGetRobloxHWND())

	pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY+72 "|350|80")

	FilePath := A_ScriptDir "\captured_image2.png"

	Gdip_SaveBitmapToFile(pBMScreen, FilePath)

	Gdip_DisposeImage(pBMScreen)
	localWinGetClientPos(windowX, windowY, windowWidth, windowHeight, "ahk_id " localGetRobloxHWND())

	pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY+y+yoffset++150 "|306|97") ; screenshotting, this one might need a y offset

	FilePath := A_ScriptDir "\captured_image3.png"

	Gdip_SaveBitmapToFile(pBMScreen, FilePath)

	Gdip_DisposeImage(pBMScreen)
	localWinGetClientPos(windowX, windowY, windowWidth, windowHeight, "ahk_id " localGetRobloxHWND())

	pBMScreen := Gdip_BitmapFromScreen(windowX+5 "|" windowY+windowHeight-54 "|50|50") ; screenshotting, this one might need a y offset

	FilePath := A_ScriptDir "\captured_image4.png"

	Gdip_SaveBitmapToFile(pBMScreen, FilePath)

	Gdip_DisposeImage(pBMScreen)
	*/
	localnm_setShiftLock(0)
	sleep 100
	localnm_OpenMenu("itemmenu")
	sleep 100
	MouseMove 46, 219
	localWinGetClientPos(windowX, windowY, windowWidth, windowHeight, "ahk_id " localGetRobloxHWND())
	;mousemove %windowX%, %windowY% ; testing
	;sleep, 100 ; for the testing
	;msgbox, X: %windowX% Y: %windowY% ; testing
	;sleep, 100 ; for the testing
	pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY+150 "|306|" windowHeight-150)
	itemNumbers := {"Cog": 1, "Ticket": 2, "SprinklerBuilder": 3, "BeequipCase": 4, "Gumdrops": 5, "Coconut": 6, "Stinger": 7, "MicroConverter": 8, "Honeysuckle": 9, "Whirligig": 10, "FieldDice": 11, "SmoothDice": 12, "LoadedDice": 13, "JellyBeans": 14, "RedExtract": 15, "BlueExtract": 16, "Glitter": 17, "Glue": 18, "Oil": 19, "Enzymes": 20, "TropicalDrink": 21, "PurplePotion": 22, "SuperSmoothie": 23, "MarshmallowBee": 24, "MagicBean": 25, "FestiveBean": 26, "CloudVial": 27, "NightBell": 28, "BoxOFrogs": 29, "AntPass": 30, "BrokenDrive": 31, "7ProngedCog": 32, "RoboPass": 33, "Translator": 34, "SpiritPetal": 35, "Present": 36, "Treat": 37, "StarTreat": 38, "AtomicTreat": 39, "SunflowerSeed": 40, "Strawberry": 41, "Pineapple": 42, "Blueberry": 43, "Bitterberry": 44, "Neonberry": 45, "MoonCharm": 46, "GingerbreadBear": 47, "AgedGingerbreadBear": 48, "WhiteDrive": 49, "RedDrive": 50, "BlueDrive": 51, "GlitchedDrive": 52, "ComfortingVial": 53, "InvigoratingVial": 54, "MotivatingVial": 55, "RefreshingVial": 56, "SatisfyingVial": 57, "PinkBalloon": 58, "RedBalloon": 59, "WhiteBalloon": 60, "BlackBalloon": 61, "SoftWax": 62, "HardWax": 63, "CausticWax": 64, "SwirledWax": 65, "Turpentine": 66, "PaperPlanter": 67, "TicketPlanter": 68, "FestivePlanter": 69, "PlasticPlanter": 70, "CandyPlanter": 71, "RedClayPlanter": 72, "BlueClayPlanter": 73, "TackyPlanter": 74, "PesticidePlanter": 75, "HeatTreatedPlanter": 76, "HydroponicPlanter": 77, "PetalPlanter": 78, "ThePlanterOfPlenty": 79, "BasicEgg": 80, "SilverEgg": 81, "GoldEgg": 82, "DiamondEgg": 83, "MythicEgg": 84, "StarEgg": 85, "GiftedSilverEgg": 86, "GiftedGoldEgg": 87, "GiftedDiamondEgg": 88, "GiftedMythicEgg": 89, "RoyalJelly": 90, "StarJelly": 91, "BumbleBeeEgg": 92, "BumbleBeeJelly": 93, "RageBeeJelly": 94, "ShockedBeeJelly": 95}
	Loop, % items.Length()+1 { ; looking for the first item in the menu
		item := items[A_Index-1]
		Gdip_ImageSearch(pBMScreen, itemBitmaps[item], itemCoords,,,,,5)
		if (itemCoords != "") {
			firstDetectedItem := item
			Gdip_DisposeImage(pBMScreen)
			break
		}
	}
	itemNumber := itemNumbers[firstDetectedItem] ; giving a number for the found item
	askedItemNumber := itemNumbers[itemLookingFor] ; giving the number to the item looking for
	
	if (itemNumber > askedItemNumber) { ; checking if the macro should scroll up or down
		direction := 1 ; scroll up
	} else if (itemNumber < askedItemNumber) {
		direction := 0 ; scroll down
	} else {
		direction := ""
	}
	
	;MsgBox, first detected `nitem: %firstDetectedItem% (num: %itemNumber%) `ncoords: %itemCoords% `ndirection: %direction% ; debugging stuff
	
	foundItem := false ; resetting/naming var, why not lol
	
	Loop 55 {
		WinActivate, Roblox ; activating roblox
		localWinGetClientPos(windowX, windowY, windowWidth, windowHeight, "ahk_id " localGetRobloxHWND()) ; getting the position of roblox
		pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY+150 "|306|" windowHeight-350) ; screenshotting
		MouseMove 46, 219
		if (direction = 1) { ; scroll up
			if (Gdip_ImageSearch(pBMScreen, itemBitmaps[itemLookingFor], itemCoords,,,,,5)) { ; looking for the asked item
				foundItem := true
				break
			}
			send {WheelUp 1}
		} else if (direction = 0) { ; scroll down
			if (Gdip_ImageSearch(pBMScreen, itemBitmaps[itemLookingFor], itemCoords,,,,,5)) { ; looking for the asked item
				foundItem := true
				break
			}
			send {WheelDown 1}
		} else { ; do nothing
			if (Gdip_ImageSearch(pBMScreen, itemBitmaps[itemLookingFor], itemCoords,,,,,5)) { ; this one is just luck based lol, why not
				foundItem := true
				break
			}
		}
		Gdip_DisposeImage(pBMScreen)
		sleep 300
	}
	if (foundItem) { ; if item is found
		WinActivate, Roblox ; activating roblox
		localWinGetClientPos(windowX, windowY, windowWidth, windowHeight, "ahk_id " localGetRobloxHWND())
		spritcords := StrSplit(itemCoords, ",")
		x := spritcords[1]+windowX
		y := spritcords[2]+150
		MouseMove, x, y
		pBitmap := Gdip_BitmapFromScreen(windowX "|" windowY+y+yoffset-10 "|306|97") ; screenshotting, this one might need a y offset
		discord.SendImage(pBitmap, imgname:="image.png")
		Gdip_DisposeImage(pBitmap)
		;MsgBox, Found item: %itemLookingFor% at coordinates: %itemCoords% `n (%x% %y%) ; testing
	} else {
		;MsgBox, Item %itemLookingFor% not found after %maxAttempts% attempts. ; testing
	}
	; making/clearing info on vars
	firstDetectedItem := "" ; for when looking for the first item in the item menu
	item := "" ; getting the next item from "itemNumber" later on
	itemCoords := "" ; getting the coords of the found item
	itemLookingFor := "" ; the item the person is looking for
	Gdip_DisposeImage(pBMScreen)
	}
}
localLevenshteinDistance(s1, s2) { ; given by sp (or made)
	len1 := StrLen(s1), len2 := StrLen(s2)
	s1 := StrSplit(s1), s2 := StrSplit(s2)
  
	d := [], d[0, 0] := 0
	Loop % len1
	  d[A_Index, 0] := A_Index
	Loop % len2
	  d[0, A_Index] := A_Index
  
	Loop % len1 {
	  i := A_Index
	  Loop % len2 {
		j := A_Index  ; only for simplicity
		cost := s1[i] != s2[j]
		d[i, j] := Min(d[i-1, j] + 1, d[i, j-1] + 1, d[i-1, j-1] + cost)
	  }
	}
  
	return d[len1, len2]
  }

localfindClosestItem(items, needle) {
  dist := StrLen(needle)
  for i,v in items
	if ((d := localLevenshteinDistance(needle, v)) < dist)
	  dist := d, item := v
if (dist<6) {
  return item
  }
}
localWinGetClientPos(ByRef X:="", ByRef Y:="", ByRef Width:="", ByRef Height:="", WinTitle:="", WinText:="", ExcludeTitle:="", ExcludeText:="")
{
    local hWnd, RECT
    hWnd := WinExist(WinTitle, WinText, ExcludeTitle, ExcludeText)
    VarSetCapacity(RECT, 16, 0)
    DllCall("GetClientRect", "UPtr",hWnd, "Ptr",&RECT)
    DllCall("ClientToScreen", "UPtr",hWnd, "Ptr",&RECT)
    X := NumGet(&RECT, 0, "Int"), Y := NumGet(&RECT, 4, "Int")
    Width := NumGet(&RECT, 8, "Int"), Height := NumGet(&RECT, 12, "Int")
}

localGetRobloxHWND() {
	if (hwnd := WinExist("Roblox ahk_exe RobloxPlayerBeta.exe"))
		return hwnd
	else if (WinExist("Roblox ahk_exe ApplicationFrameHost.exe"))
	{
		ControlGet, hwnd, Hwnd, , ApplicationFrameInputSinkWindow1
		return hwnd
	}
	else
		return 0
}
localnm_OpenMenu(menu:="", refresh:=0){
	global itemBitmaps
	static x := {"itemmenu":30, "questlog":85, "beemenu":140}, open:=""

	if localGetRobloxHWND()
		WinActivate, Roblox
	else
		return 0

	if ((menu = "") || (refresh = 1)) ; close
	{
		if open ; close the open menu
		{
			Loop, 10
			{
				localWinGetClientPos(windowX, windowY, windowWidth, windowHeight, "ahk_id " localGetRobloxHWND())
				pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY+72 "|350|80")
				if (Gdip_ImageSearch(pBMScreen, itemBitmaps[open], , , , , , 2) != 1) {
					Gdip_DisposeImage(pBMScreen)
					open := ""
					break
				}
				Gdip_DisposeImage(pBMScreen)
				MouseMove, windowX+x[open], windowY+110
				;mathematics := windowX+x[open]
				;mathematics2 := windowY+120
				;mathematics3 := x[open]
				;MsgBox, x: %mathematics% y: %mathematics2% open offset 2: %mathematics3%
				Click
				MouseMove, windowX+350, windowY+110
				sleep, 500
			}
		}
		else ; close any open menu
		{
			for k,v in x
			{
				Loop, 10
				{
					localWinGetClientPos(windowX, windowY, windowWidth, windowHeight, "ahk_id " localGetRobloxHWND())
					pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY+72 "|350|80")
					if (Gdip_ImageSearch(pBMScreen, itemBitmaps[k], , , , , , 2) != 1) {
						Gdip_DisposeImage(pBMScreen)
						break
					}
					Gdip_DisposeImage(pBMScreen)
					MouseMove, windowX+v, windowY+110
					;mathematics := windowX+v
					;mathematics2 := windowY+120
					;mathematics3 := v
					;MsgBox, x: %mathematics% y: %mathematics2% v offset: %mathematics3%
					Click
					MouseMove, windowX+350, windowY+100
					sleep, 500
				}
			}
			open := ""
		}
	}
	else
	{
		if ((menu != open) && open) ; close the open menu
		{
			Loop, 10
			{
				localWinGetClientPos(windowX, windowY, windowWidth, windowHeight, "ahk_id " localGetRobloxHWND())
				pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY+72 "|350|80")
				if (Gdip_ImageSearch(pBMScreen, itemBitmaps[open], , , , , , 2) != 1) {
					Gdip_DisposeImage(pBMScreen)
					open := ""
					break
				}
				Gdip_DisposeImage(pBMScreen)
				MouseMove, windowX+x[open], windowY+110
				;mathematics := windowX+x[open]
				;mathematics2 := windowY+120
				;mathematics3 := x[open]
				;MsgBox, x: %mathematics% y: %mathematics2% open offset: %mathematics3%
				Click
				MouseMove, windowX+350, windowY+100
				sleep, 500
			}
		}
		; open the desired menu
		Loop, 10
		{
			localWinGetClientPos(windowX, windowY, windowWidth, windowHeight, "ahk_id " localGetRobloxHWND())
			pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY+72 "|350|80")
			if (Gdip_ImageSearch(pBMScreen, itemBitmaps[menu], , , , , , 2) = 1) {
				Gdip_DisposeImage(pBMScreen)
				open := menu
				break
			}
			Gdip_DisposeImage(pBMScreen)
			MouseMove, windowX+x[menu], windowY+110
			;mathematics := windowX+x[menu]
			;mathematics2 := windowY+120
			;mathematics3 := x[menu]
			;MsgBox, x: %mathematics% y: %mathematics2% menu offset: %mathematics3%
			Click
			MouseMove, windowX+350, windowY+100
			sleep, 500
		}
	}
}

localnm_setShiftLock(state){
	localSC_LShift:="sc02a" ; LShift
	global SC_LShift, ShiftLockEnabled
    localbmshiftlock := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAABkAAAAZAgMAAAC5h23wAAAADFBMVEUAAAAFov4Fov0Gov5PyD1RAAAAAXRSTlMAQObYZgAAAG1JREFUeNp1zrENwlAMhOEvOOmQQsEgGSBSVkjB24dRMgIjeBRGyAZBLhBpKOz/ijvdEcfyhpEZXkQST+yMMHNFvUm3CjZ9L1K6dZzYtbYWh9YekoE7sij/cit/pKny8e379Udiryt92ns5lp0PKyEgGjSX+tcAAAAASUVORK5CYII=")
	localWinGetClientPos(windowX, windowY, windowWidth, windowHeight, "Roblox ahk_exe RobloxPlayerBeta.exe") ; Shift Lock is not supported on UWP app at the moment
	if (windowWidth = 0)
		return 2
	else
		WinActivate, Roblox

	pBMScreen := Gdip_BitmapFromScreen(windowX+5 "|" windowY+windowHeight-54 "|50|50")

	switch (v := Gdip_ImageSearch(pBMScreen, localbmshiftlock, , , , , , 2))
	{
		; shift lock enabled - disable if needed
		case 1:
		if (state = 0)
		{
			send {%localSC_LShift%}
			result := 0
		}
		else
			result := 1

		; shift lock disabled - enable if needed
		case 0:
		if (state = 1)
		{
			send {%localSC_LShift%}
			result := 1
		}
		else
			result := 0
	}

	Gdip_DisposeImage(pBMScreen)
	return (ShiftLockEnabled := result)
}
localGetYOffset(hwnd, ByRef fail:="")
{
	global bitmaps
	static hRoblox, offset := 0

	if (hwnd = hRoblox)
		return offset
	else
	{
		WinActivate, Roblox
		WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "ahk_id " hwnd)
		pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2 "|" windowY "|300|100")

		Loop, 20 ; for red vignette effect
		{ 
			if ((Gdip_ImageSearch(pBMScreen, localtoppollen, pos, , , , , 16) = 1)
				&& (Gdip_ImageSearch(pBMScreen, localtoppollen, , x := SubStr(pos, 1, (comma := InStr(pos, ",")) - 1), y := SubStr(pos, comma + 1), x + 41, y + 10, 16) = 0))
			{
				Gdip_DisposeImage(pBMScreen)
				hRoblox := hwnd
				return (offset := y - 14), (fail := 0)
			}
			else
			{
				if (A_Index = 20)
				{
					Gdip_DisposeImage(pBMScreen)
					return 0 ; default offset, change this if needed
						, (fail := 1)
				}
				else
				{
					Sleep, 50
					Gdip_DisposeImage(pBMScreen)
					pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2 "|" windowY "|60|100")
				}				
			}
		}
	}
}
