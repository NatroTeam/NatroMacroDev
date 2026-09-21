nm_InventorySearch(item, direction:="down", prescroll:=0, prescrolldir:="", scrolltoend:=1, max:=70, &failure:="", variation:=10){ ;~ item: string of item; direction: down or up; prescroll: number of scrolls before direction switch; prescrolldir: direction to prescroll, set blank for same as direction; scrolltoend: set 0 to omit scrolling to top/bottom after prescrolls; max: number of scrolls in total
	global bitmaps
	static hRoblox:=0, l:=0, cachedWidth:=0, cachedHeight:=0, cachedOffset:=0
	failure := "", pos := ""

	nm_OpenMenu("itemmenu")

	; detect inventory end for current hwnd
	if (hwnd := GetRobloxHWND())
	{
		offsetY := GetYOffset(hwnd, &offsetFailed)
		if offsetFailed || !GetRobloxClientPos(hwnd)
			return (failure := "The Roblox inventory position could not be read.", 0)
		searchWidth := windowWidth, searchHeight := windowHeight
		if windowWidth < 306 || windowHeight-offsetY-150 < 100
			return (failure := "The Roblox window is too small to search the inventory.", 0)
		if (hwnd != hRoblox || windowWidth != cachedWidth || windowHeight != cachedHeight || offsetY != cachedOffset)
		{
			ActivateRoblox()
			pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY+offsetY+150 "|306|" windowHeight-offsetY-150)

			Loop 40
			{
				if (Gdip_ImageSearch(pBMScreen, bitmaps["item"], &lpos, , , 6, , 2, , 2) = 1)
				{
					Gdip_DisposeImage(pBMScreen)
					l := SubStr(lpos, InStr(lpos, ",")+1)-60 ; image 20px, item 80px => y+20-80 = y-60
					if l < 20 {
						hRoblox := 0
						return (failure := "The inventory rows could not be read. Check that the inventory is visible.", 0)
					}
					hRoblox := hwnd, cachedWidth := windowWidth, cachedHeight := windowHeight, cachedOffset := offsetY
					break
				}
				else
				{
					if (A_Index = 40)
					{
						Gdip_DisposeImage(pBMScreen)
						hRoblox := 0
						return (failure := "The inventory rows could not be read. Check that the inventory is visible.", 0)
					}
					else
					{
						Sleep 50
						Gdip_DisposeImage(pBMScreen)
						pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY+offsetY+150 "|306|" windowHeight-offsetY-150)
					}
				}
			}
		}
	}
	else
		return (failure := "The Roblox window could not be found.", 0)

	; search inventory
	Loop max+1
	{
		ActivateRoblox()
		if !GetRobloxClientPos(hwnd) || windowWidth != searchWidth || windowHeight != searchHeight
			return (failure := "The Roblox window changed during inventory search. Start again.", 0)
		pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY+offsetY+150 "|306|" l)

		; wait for red vignette effect to disappear
		Loop 40
		{
			if (Gdip_ImageSearch(pBMScreen, bitmaps["item"], , , , 6, , 2) = 1)
				break
			else
			{
				if (A_Index = 40)
				{
					Gdip_DisposeImage(pBMScreen)
					hRoblox := 0
					return (failure := "The inventory rows could not be read. Check that the inventory is visible.", 0)
				}
				else
				{
					Sleep 50
					Gdip_DisposeImage(pBMScreen)
					pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY+offsetY+150 "|306|" l)
				}
			}
		}

		if (Gdip_ImageSearch(pBMScreen, bitmaps[item], &pos, , , , , variation, , 5) = 1) {
			Gdip_DisposeImage(pBMScreen)
			break ; item found
		}
		Gdip_DisposeImage(pBMScreen)
		if A_Index > max
			break

		switch A_Index
		{
			case (prescroll+1): ; scroll entire inventory on (prescroll+1)th search
			if (scrolltoend = 1)
			{
				Loop 100
				{
					SendEvent "{Click " windowX+30 " " windowY+offsetY+200 " 0}"
					SendInput "{Wheel" ((direction = "down") ? "Up" : "Down") "}"
					Sleep 50
				}
			}
			default: ; scroll once
			SendEvent "{Click " windowX+30 " " windowY+offsetY+200 " 0}"
			SendInput "{Wheel" ((A_Index <= prescroll) ? (prescrolldir ? ((prescrolldir = "Down") ? "Down" : "Up") : ((direction = "down") ? "Down" : "Up")) : ((direction = "down") ? "Down" : "Up")) "}"
			Sleep 50
		}
		Sleep 500 ; wait for scroll to finish
	}
	if !pos
		return (failure := "The inventory search limit was reached without finding this item.", 0)
	return [30, SubStr(pos, InStr(pos, ",")+1)+offsetY+190]
}
