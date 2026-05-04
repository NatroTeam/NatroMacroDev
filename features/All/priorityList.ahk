#Include "customizeGui.ahk"

nm_readPriorityList(*){
	global
	priorityList := IniRead(A_WorkingDir "\features\All\CustomizeGui.ini", "Features", "priorityList")
	priorityList := StrSplit(priorityList, ",")
}

nm_setDefaultPriorityList(*){
	global
	defaultPriorityList:=["Night", "Mondo", "Planter", "Bugrun", "Collect", "QuestRotate", "Personal", "Boost", "GoGather"]
	priorityList:=[]
	;for x in StrSplit(priorityListNumeric)
	for x, v in defaultPriorityList
		priorityList.push(defaultPriorityList[x])
	;remove the disabled features from the function list
	for i in MacroFeatureFunctions {
		if IniRead(A_WorkingDir "\features\All\CustomizeGui.ini", "Features", i)=0 {
			for j in MacroFeatureFunctions[i] {
				for x,v in priorityList
					if j=priorityList[x]
						priorityList.RemoveAt(x)
			}
		}
	}
}

nm_changePriorityList(wParam, lParam, *){
	global
	nm_readPriorityList()
	priorityList.InsertAt(lParam, priorityList.RemoveAt(wParam))
	nm_savePriorityList()
}

nm_savePriorityList(*){
	global
	local temp:=""
	for k, v in priorityList {
		if k>1
		temp .= ","
		temp .= priorityList[k]
	}
	IniWrite temp, A_WorkingDir "\features\All\CustomizeGui.ini", "Features", "priorityList"
}

nm_resizePriorityList(*){
	global
	if isSet(priorityGui) && priorityGui is Gui
		priorityGui.destroy()
	priorityGui := Gui("-Caption +E0x80000 +E0x8000000 +LastFound +AlwaysOnTop +ToolWindow +OwnDialogs -DPIScale")
	priorityGui.OnEvent("Close", (*) => ExitApp()), priorityGui.OnEvent("Escape", (*) => ExitApp())
	priorityGui.Show("NA")

	for i in ["moveRegion", "close", "Reset", "ToolTip"]
		priorityGui.AddText("v" i)
	for i, v in priorityList {
		priorityGui.AddText("vp" i)
	}

	w:=250, h:=priorityList.Length * 34 + 87
	hbm := CreateDIBSection(w, h)
	hdc := CreateCompatibleDC()
	obm := SelectObject(hdc, hbm)
	G := Gdip_GraphicsFromHDC(hdc)
	Gdip_SetSmoothingMode(G, 2)
	Gdip_SetInterpolationMode(G, 2)
	UpdateLayeredWindow(priorityGui.hwnd, hdc, A_ScreenWidth//2-w//2,A_ScreenHeight//2-h//2, w, h)

	;colors:
	backgroundColor := "0xff131416"
	textColor := "0xffffffff"
	itemsColor := "0xff323942"
	accentColors := [
		"0xFFF24646", "0xFFF34F4F", "0xFFF45858", "0xFFF56161",
		"0xFFF66A6A", "0xFFF77373", "0xFFF87C7C", "0xFFF98585",
		"0xFFFA8E8E", "0xFFFB9797", "0xFFF9B5B5"
	]
	priorityGui["moveRegion"].move(0, 0, w-42, 30)
	priorityGui["close"].move(w-42, 4, 28, 28)
	for i,v in priorityList
		priorityGui["p" i].move(15, i*34+3, w-30, 30)
	priorityGui["Reset"].move(15, h-50, w-62, 30)
	priorityGui["ToolTip"].move(w-45, h-50, 30, 30)
}

nm_priorityListGui(warning:=1, *) {
	global
	local script, exec

	try ProcessClose(PGUIPID)

	if warning
	Msgbox("Warning:``n``nThis option will change the ORDER in which the macro attempts each task, but not necessarily the AMOUNT OF TIME spent on each task.``n``nIf you have enabled any Gather Interrupts, or options requiring interrupts, those will also override the order you specify here. For example:``n- if you enable Vicious Bee or Night Memory Match, it will interrupt gather to attempt these every night time even if you place these lower on the priority list.``n- if you enable Gather Interrupt for Quests or Bug Kills, it will interrupt gather to do these tasks every time they come off cool-down, even if you place them lower on the priority list.``n``nGenerally, the DEFAULT ORDER is recommended in most cases.","Priority list",0x40040)
	;msgbox "warning="

	;if not IsSet(warning)
	;	warning:=1
	script :=
	(
	'
	#NoTrayIcon
	#SingleInstance Force
	#MaxThreads 255
	#Include lib
	#Include Gdip_All.ahk
	pToken := Gdip_Startup()
	DetectHiddenWindows 1
	#Warn VarUnset, Off

	(bitmaps := Map()).CaseSense := 0
	#Include "%A_ScriptDir%\nm_image_assets\webhook_gui\bitmaps.ahk"
	#Include "%A_ScriptDir%\features\All\priorityList.ahk"

	;;config
	;defaultList := ["Night", "Mondo", "Planter", "Bugrun", "Collect", "QuestRotate", "Personal", "Boost", "GoGather"]
	priorityList := []
	priorityList := StrSplit(IniRead(A_ScriptDir "\features\All\CustomizeGui.ini", "Features", "priorityList"), ",")

	nm_resizePriorityList()
	nm_priorityGui()
	;Msgbox("Warning:``n``nThis option will change the ORDER in which the macro attempts each task, but not necessarily the AMOUNT OF TIME spent on each task.``n``nIf you have enabled any Gather Interrupts, or options requiring interrupts, those will also override the order you specify here. For example:``n- if you enable Vicious Bee or Night Memory Match, it will interrupt gather to attempt these every night time even if you place these lower on the priority list.``n- if you enable Gather Interrupt for Quests or Bug Kills, it will interrupt gather to do these tasks every time they come off cool-down, even if you place them lower on the priority list.``n``nGenerally, the DEFAULT ORDER is recommended in most cases.","Priority list",0x40040)

	nm_priorityGui(movingItem?, mouseY?, drop?) {
		global priorityList
		local v,i
		;;Title Bar
		Gdip_GraphicsClear(G)
		Gdip_FillRoundedRectanglePath(G, pBrush := Gdip_CreateLineBrushFromRect(0, 0, w, h, 0x00000000, 0x78000000), 14, 6, w-16, h-16, 12), Gdip_DeleteBrush(pBrush)
		pBrush := Gdip_BrushCreateSolid(accentColors[1]), Gdip_FillRoundedRectanglePath(G, pBrush, 8, 0, w-16, 30, 12), Gdip_FillRectangle(G, pBrush, 8, 13, w-16, 20), Gdip_DeleteBrush(pBrush)
		Gdip_DrawImage(G, bitmaps["close"], w-42, 4)
		Gdip_TextToGraphics(G, "Priority List", "x23 y8 s17 cffffffff Bold","Arial", w-16, 30)

		;;Background
		Gdip_FillRectangle(G, pBrush := Gdip_BrushCreateSolid(backgroundColor), 8, 32, w-16, h-80), Gdip_FillRoundedRectanglePath(G, pBrush, 8, h-100, w-16, 84, 12),Gdip_DeleteBrush(pBrush)

		;;Check for update in priority list
		if IsSet(movingItem) && !IsSet(drop) {
			index := ((mouseY > priorityList.Length * 34+3) ? priorityList.Length*34+3 : mouseY < 44 ? 44 : mouseY) // 34
			Gdip_DrawLine(G , pPen:=Gdip_CreatePen(accentColors[1], 2), 15, (index*34+3), w-15,  (index*34+3)), Gdip_DeletePen(pPen)
		}
		if IsSet(drop) {
			index := ((mouseY > priorityList.Length * 34 + 3) ? priorityList.Length*34+3 : mouseY < 44 ? 44 : mouseY) // 34
			if WinExist("natro_macro.ahk ahk_class AutoHotkey")
				PostMessage 0x5561, ObjHasValue(priorityList, movingItem), index
			priorityList.InsertAt(index, priorityList.RemoveAt(ObjHasValue(priorityList, movingItem)))
		}
		lower := 0
		;;Priority List
		for i, v in priorityList {
			if IsSet(movingItem) && movingItem = v && !IsSet(drop) {
				lower := 1
				continue
			}
			groupx := 15, groupy := ((i-=lower)*34)+3, groupw := w-30, grouph := 30
			Gdip_FillRoundedRectangle(G, pBrush := Gdip_BrushCreateSolid(itemsColor), groupx, groupy, groupw, grouph, 8), Gdip_DeleteBrush(pBrush)
			Gdip_TextToGraphics(G, v, "x" groupx+8 " y" groupY + 7 " s15 cffffffff Bolder","Arial")
			Gdip_DrawLine(G, pPen := Gdip_CreatePen(accentColors[i+1], 3), groupw-20, groupy + 10, groupw-5, groupy + 10)
			Gdip_DrawLine(G, pPen, groupw-20, groupy + 15, groupw-5, groupy + 15)
			Gdip_DrawLine(G, pPen, groupw-20, groupy + 20, groupw-5, groupy + 20), Gdip_DeletePen(pPen)
		}
		if IsSet(movingItem) && !IsSet(drop) {
			groupy := (mouseY > priorityList.Length * 34+3) ? priorityList.Length * 34+3 : mouseY < 44 ? 44 : mouseY
			Gdip_FillRoundedRectangle(G, pBrush := Gdip_BrushCreateSolid("0x99323942"), groupx, groupy, groupw, grouph, 8), Gdip_DeleteBrush(pBrush)
			Gdip_TextToGraphics(G, movingItem, "x" groupx+8 " y" groupY + 7 " s15 c99ffffff Bolder","Arial")
			Gdip_DrawLine(G, pPen := Gdip_CreatePen(accentColors[10], 3), groupw-20, groupy + 10, groupw-5, groupy + 10)
			Gdip_DrawLine(G, pPen, groupw-20, groupy + 15, groupw-5, groupy + 15)
			Gdip_DrawLine(G, pPen, groupw-20, groupy + 20, groupw-5, groupy + 20), Gdip_DeletePen(pPen)
		}
		Gdip_FillRoundedRectangle(G, pBrush := Gdip_BrushCreateSolid(accentColors[5]), 15, h-50, w-62, 30, 8)
		Gdip_FillRoundedRectangle(G, pBrush, w-45, h-50, 30, 30, 8), Gdip_DeleteBrush(pBrush)
		priorityGui["Reset"].enabled := true
		Gdip_TextToGraphics(G, "Reset", "x15 y" h-43 " s15 cFFFFFFFF" " Bold Center","Arial", w-62)
		Gdip_TextToGraphics(G, "?", "x" w-45 " y" h-43 " s15 cFFFFFFFF Bold Center","Arial", 30)
		UpdateLayeredWindow(priorityGui.hwnd, hdc)
		OnMessage(0x201, WM_LBUTTONDOWN)
		OnExit(ExitFunc)
	}
	ObjHasValue(obj,value) {
		for q,o in obj
			if o = value
				return q
		return false
	}

	WM_LBUTTONDOWN(*) {
		global priorityList
		MouseGetPos ,,,&hCtrl,2
		if !hCtrl
			return
		switch priorityGui[hCtrl].name, 0 {
			case "moveRegion":
				PostMessage(0xA1, 2)
			case "close":
				ExitApp()
			case "Reset":
				nm_setDefaultPriorityList()
				nm_savePriorityList()
				nm_resizePriorityList()
				nm_priorityGui()
			case "ToolTip":
				Msgbox("Priority List``r``n``r``nDrag and drop to reorder the priority list.``r``nPress Reset to reset the priority list back to default.``n``nNote:``n - The priority list will not override interrupts, e.g., for bug kills or vicious bee.``n - In one loop each task will be completed.``n - The DEFAULT priority is usually optimal for most players.","Priority List",0x40040)
			default:
				MouseGetPos(,&y)
				priorityGui.GetPos(,&wy)
				index := SubStr(priorityGui[hCtrl].name,2)
				offset := y - wy-(index*34+3)
				ReplaceSystemCursors("IDC_HAND")
				While GetKeyState("LButton", "P") {
					MouseGetPos(,&y)
					y-=offset + wy
					nm_priorityGui(priorityList[index], y)
				}
				ReplaceSystemCursors()
				nm_priorityGui(priorityList[index], y, 1)
		}
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
	UpdateInt(name, value)
	{
		IniWrite value, "settings\nm_config.ini", "settings", name
		if WinExist("natro_macro.ahk ahk_class AutoHotkey")
			PostMessage 0x5552, 366, value
		if WinExist("Status.ahk ahk_class AutoHotkey")
			PostMessage 0x5552, 366, value
	}

	ExitFunc(*)
	{
		PriorityGui.Destroy()
		try Gdip_Shutdown(pToken)
		ReplaceSystemCursors()
	}
	'
	)

	exec := ComObject("WScript.Shell")
			.exec('"' exe_path64 '" /script /force *')
	exec.StdIn.Write(script), exec.StdIn.Close()

	return (PGUIPID := exec.ProcessID)
}