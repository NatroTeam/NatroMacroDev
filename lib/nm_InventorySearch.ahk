#Include %A_LineFile%\..\WindowsOCR.ahk

nm_InventorySearch(item, direction:="down", prescroll:=0, prescrolldir:="", scrolltoend:=1, max:=70, &failure:="", check:=0){ ;~ item: string of item; direction: down or up; prescroll: number of scrolls before direction switch; prescrolldir: direction to prescroll, set blank for same as direction; scrolltoend: set 0 to omit scrolling to top/bottom after prescrolls; max: number of scrolls in total
	failure := "", previousRows := 0, lastStep := 0, batch := 3

	if IsObject(check)
		check.Call()
	nm_OpenMenu("itemmenu", , check)

	if (hwnd := GetRobloxHWND())
	{
		offsetY := GetYOffset(hwnd, &offsetFailed)
		if offsetFailed || !GetRobloxClientPos(hwnd)
			return (failure := "The Roblox inventory position could not be read.", 0)
		searchWidth := windowWidth, searchHeight := windowHeight
		if windowWidth < 306 || windowHeight-offsetY-150 < 100
			return (failure := "The Roblox window is too small to search the inventory.", 0)
	}
	else
		return (failure := "The Roblox window could not be found.", 0)

	captureTop := offsetY+150
	captureWidth := Min(windowWidth, 700)
	captureHeight := windowHeight-captureTop

	; search inventory
	Loop max+1
	{
		if IsObject(check)
			check.Call()
		ActivateRoblox()
		if !GetRobloxClientPos(hwnd) || windowWidth != searchWidth || windowHeight != searchHeight
			return (failure := "The Roblox window changed during inventory search. Start again.", 0)
		pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY+captureTop "|" captureWidth "|" captureHeight)

		try page := nm_InventoryRead(pBMScreen, item)
		finally Gdip_DisposeImage(pBMScreen)
		if IsObject(check)
			check.Call()
		if IsObject(page.target)
			return [page.target[1], page.target[2]+captureTop]
		if !page.rows.Count
			return (failure := "The inventory item names could not be read.", 0)
		if lastStep > 1 {
			overlap := false
			for name in page.rows
				if previousRows.Has(name) {
					overlap := true
					break
				}
			if !overlap {
				if IsObject(check)
					check.Call()
				SendEvent "{Click " windowX+30 " " windowY+captureTop+page.scroll " 0}"
				SendInput "{Wheel" (lastDirection = "Down" ? "Up" : "Down") " " lastStep-1 "}"
				Sleep 500
				lastStep := 0, batch := 1
				continue
			}
		}
		if A_Index > max
			break

		scrollY := captureTop+page.scroll
		switch A_Index
		{
			case (prescroll+1): ; scroll entire inventory on (prescroll+1)th search
			if (scrolltoend = 1)
			{
				lastStep := 0
				Loop 100
				{
					if IsObject(check)
						check.Call()
					SendEvent "{Click " windowX+30 " " windowY+scrollY " 0}"
					SendInput "{Wheel" ((direction = "down") ? "Up" : "Down") "}"
					Sleep 50
				}
			}
			default:
			if IsObject(check)
				check.Call()
			SendEvent "{Click " windowX+30 " " windowY+scrollY " 0}"
			lastDirection := (A_Index <= prescroll) ? (prescrolldir ? prescrolldir : direction) : direction
			lastDirection := lastDirection = "down" ? "Down" : "Up"
			lastStep := A_Index > prescroll && page.rows.Count >= 5 ? batch : 1
			previousRows := page.rows
			SendInput "{Wheel" lastDirection " " lastStep "}"
			Sleep 50
		}
		Sleep 500 ; wait for scroll to finish
	}
	return (failure := "The inventory search limit was reached without finding this item.", 0)
}

nm_InventoryName(text) {
	name := StrLower(RegExReplace(Trim(text), "[\s-]"))
	switch name {
		case "sprout": return "magicbean"
		case "theplanterofplenty": return "planterofplenty"
	}
	return name
}
nm_InventoryRead(bitmap, item) {
	Gdip_GetImageDimensions(bitmap, &width, &height)
	regions := nm_OCRFromBitmap(bitmap, true)
	rows := Map(), target := 0, scroll := 0, wanted := nm_InventoryName(item)
	for line in regions {
		name := nm_InventoryName(line.text)
		if line.h < 8 || line.x < 3*line.h || line.x+line.w/2 > 16*line.h
			continue
		if name != wanted && !RegExMatch(line.text, "^[A-Z0-9][A-Za-z0-9'-]*(?:\s+(?:[A-Z0-9][A-Za-z0-9'-]*|of|the|and))*$")
			continue
		y := Round(line.y+line.h*1.5)
		if line.x+line.w >= width-2 || y >= height-2
			continue
		rows[name] := y
		if !scroll || y < scroll
			scroll := y
		if name = wanted
			target := [30, y]
	}
	return {target:target, rows:rows, scroll:scroll}
}
