#SingleInstance Force
#Requires AutoHotkey v2.0
#Include .\lib\Gdip_All.ahk
pToken := Gdip_Startup()
OnExit((*) =>( Gdip_Shutdown(pToken), ExitApp()))
mgui := Gui("+E" (0x00080000 | 0x00000008) " +AlwaysOnTop +OwnDialogs -Caption")
mgui.Show("NA")
;===Dimensions===
w:=500,h:=325
;===Bee Array===
([].base.find := find)
beeArr := ["Bomber", "Brave", "Bumble", "Cool", "Hasty", "Looker", "Rad", "Rascal", "Stubborn", "Bubble", "Bucko", "Commander", "Demo", "Exhausted", "Fire", "Frosty", "Honey", "Rage", "Riley", "Shocked", "Baby", "Carpenter", "Demon", "Diamond", "Lion", "Music", "Ninja", "Shy", "Buoyant", "Fuzzy", "Precise", "Spicy", "Tadpole", "Vector"]
mutationsArr := [{name: "Ability"}, {name: "Gather"}, {name: "Convert"}, {name: "Energy"}, {name:"Movespeed"}, {name: "Crit"}, {name: "Instant"}, {name: "Attack"}]
(bitmaps := Map()).CaseSense:=0
#Include .\nm_image_assets\mutatorgui\bitmaps.ahk

for i, j in [{name:"move", options:"x0 y0 w" w " h36"}, {name:"selectall", options:"x" w-330 " y220 w40 h18"}, {name:"mutations", options:"x" w-170 " y220 w40 h18"}, {name:"close", options:"x" w-40 " y5 w28 h28"}]
	mgui.AddText("v" j.name " " j.options)
for i, j in beeArr {
	y := (A_Index-1)//8*1
	mgui.AddText("v" j " x" 10+mod(A_Index-1,8)*60 " y" 50+y*40 " w45 h36")
}
for i, j in mutationsArr {
	y := (A_Index-1)//4*1
	mgui.AddText("v" j.name " x" 10+mod(A_Index-1,4)*120 " y" 260+y*25 " w40 h18")
}
OnMessage(0x201, WM_LBUTTONDOWN)
OnMessage(0x200, WM_MOUSEMOVE)
hBM := CreateDIBSection(w, h)
hDC := CreateCompatibleDC()
SelectObject(hDC, hBM)
G := Gdip_GraphicsFromHDC(hDC)
Gdip_SetSmoothingMode(G, 4)
Gdip_SetInterpolationMode(G, 7)
update := UpdateLayeredWindow.Bind(mgui.hwnd, hDC)
update(A_ScreenWidth//2-w//2, A_ScreenHeight//2-h//2, w, h)
hovercontrol := "", Bomber:=Brave:=Bumble:=Cool:=Hasty:=Looker:=Rad:=Rascal:=Stubborn:=Bubble:=Bucko:=Commander:=Demo:=Exhausted:=Fire:=Frosty:=Honey:=Rage:=Riley:=Shocked:=Baby:=Carpenter:=Demon:=Diamond:=Lion:=Music:=Ninja:=Shy:=Buoyant:=Fuzzy:=Precise:=Spicy:=Tadpole:=Vector:=SelectAll:=mutations:=Ability:=Gather:=Convert:=Energy:=Movespeed:=Crit:=Instant:=Attack:=0
DrawGUI()
DrawGUI() {
	Gdip_GraphicsClear(G)
	Gdip_FillRoundedRectanglePath(G, brush := Gdip_BrushCreateSolid(0xFF131416), 2, 2, w-4, h-4, 20), Gdip_DeleteBrush(brush)
	region := Gdip_GetClipRegion(G)
	Gdip_SetClipRect(G, 2, 21, w-2, 30, 4)
	Gdip_FillRoundedRectanglePath(G, brush := Gdip_BrushCreateSolid("0xFFFEC6DF"), 2, 2, w-4, 40, 20)
	Gdip_SetClipRegion(G, region)
	Gdip_FillRectangle(G, brush, 2, 20, w-4, 14)
	Gdip_DeleteBrush(brush), Gdip_DeleteRegion(region)
	Gdip_TextToGraphics(G, "Auto-Jelly", "s20 x20 y5 w460 Near vCenter c" (brush := Gdip_BrushCreateSolid("0xFF131416")), "Comic Sans MS", 460, 30)
	Gdip_DrawImage(G, bitmaps["close"], w-40, 5, 28, 28)
	for i, j in beeArr {
		;bitmaps are w45 h36
		y := (A_Index-1)//8
		bm := hovercontrol = j && (%j% || SelectAll) ? j "bghover" : %j% || SelectAll ? j "bg" : hovercontrol = j ? j "hover" : j
		Gdip_DrawImage(G, bitmaps[bm], 10+mod(A_Index-1,8)*60, 50+y*40, 45, 36)
	}
	;===Switches===
	Gdip_FillRoundedRectanglePath(G, brush := Gdip_BrushCreateSolid("0xFF" . 13*2 . 14*2 . 16*2), w-330, 220, 40, 18, 9), Gdip_DeleteBrush(brush)
	Gdip_FillEllipse(G, brush:=Gdip_BrushCreateSolid("0xFFFEC6DF"), selectAll ? w-310 : w-330, 218, 22, 22)
	Gdip_TextToGraphics(G, "Select All Bees", "s14 x" w-284 " y220 Near vCenter c" (brush := Gdip_BrushCreateSolid("0xFFFEC6DF")), "Comic Sans MS",, 20)
	Gdip_FillRoundedRectanglePath(G, brush := Gdip_BrushCreateSolid("0xFF" . 13*2 . 14*2 . 16*2), w-170, 220, 40, 18, 9), Gdip_DeleteBrush(brush)
	Gdip_FillEllipse(G, brush:=Gdip_BrushCreateSolid("0xFFFEC6DF"), mutations ? w-150 : w-170, 218, 22, 22)
	Gdip_TextToGraphics(G, "Mutations", "s14 x" w-124 " y220 Near vCenter c" (brush := Gdip_BrushCreateSolid("0xFFFEC6DF")), "Comic Sans MS",, 20)
	For i, j in mutationsArr {
		y := (A_Index-1)//4
		Gdip_FillRoundedRectanglePath(G, brush := Gdip_BrushCreateSolid("0xFF" . 13*2 . 14*2 . 16*2), 10+mod(A_Index-1,4)*120, 260+y*25, 40, 18, 9), Gdip_DeleteBrush(brush)
		Gdip_FillEllipse(G, brush:=Gdip_BrushCreateSolid("0xFFFEC6DF"), (%j.name% ? 3 : 1) * 10+mod(A_Index-1,4)*120, 258+y*25, 22, 22)
		Gdip_TextToGraphics(G, j.name, "s12 x" 56+mod(A_Index-1,4)*120 " y" 260+y*25 " vCenter c" (brush := Gdip_BrushCreateSolid("0xFFFEC6DF")), "Comic Sans MS", 100, 20)
	}
	if !mutations
		Gdip_FillRectangle(G, brush:=Gdip_BrushCreateSolid("0x70131416"), 9, 255, w-18, h-268)
	update()
}
WM_LBUTTONDOWN(wParam, lParam, msg, hwnd) {
	global
	MouseGetPos(,,,&ctrl,2)
	if !ctrl
		return
	switch mgui[ctrl].name, 0 {
		case "move":PostMessage(0xA1,2)
		case "close":PostMessage(0x112,0xF060)
		default:
			if !mutations && mutationsArr.find((j) => j.name = mgui[ctrl].name)
				return
			%mgui[ctrl].name% ^= 1
			DrawGUI()
	}
}
WM_MOUSEMOVE(wParam, lParam, msg, hwnd) {
	global
	MouseGetPos(,,,&ctrl,2)
	if !ctrl {
		if hovercontrol
			hovercontrol := "", DrawGUI(), ReplaceSystemCursors()
		return
	}
	if mgui[ctrl].name = hovercontrol
		return
	if !(mgui[ctrl].name = "move") && !(mgui[ctrl].name = "close")
		ReplaceSystemCursors("IDC_HAND")
	else
		ReplaceSystemCursors()
	hovercontrol := mgui[ctrl].name
	DrawGUI()
}
find(obj,func) {
	for i, j in obj
		if func(j)
			return i
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