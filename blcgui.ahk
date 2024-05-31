#SingleInstance Force
#Requires AutoHotkey v2.0
#Include .\lib\Gdip_All.ahk
pToken := Gdip_Startup()

mgui := Gui("+E" (0x00080000 | 0x00000008) " +AlwaysOnTop +OwnDialogs -Caption")
mgui.Show("NA")
;===Dimensions===
w:=500,h:=275
;===Bee Array===
beeArr := ["Bomber", "Brave", "Bumble", "Cool", "Hasty", "Looker", "Rad", "Rascal", "Stubborn", "Bubble", "Bucko", "Commander", "Demo", "Exhausted", "Fire", "Frosty", "Honey", "Rage", "Riley", "Shocked", "Baby", "Carpenter", "Demon", "Diamond", "Lion", "Music", "Ninja", "Shy", "Buoyant", "Fuzzy", "Precise", "Spicy", "Tadpole", "Vector"]
(bitmaps := Map()).CaseSense:=0
#Include .\nm_image_assets\mutatorgui\bitmaps.ahk

for i, j in [{name:"move", options:"x0 y0 w" w " h36"}]
	mgui.AddText("v" j.name " " j.options)
for i, j in beeArr {
	y := (A_Index-1)//8*1
	mgui.AddText("v" j " x" 10+mod(A_Index-1,8)*60 " y" 50+y*40 " w45 h36")
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
hovercontrol := "", Bomber:=0,Brave:=0,Bumble:=0,Cool:=0,Hasty:=0,Looker:=0,Rad:=0,Rascal:=0,Stubborn:=0,Bubble:=0,Bucko:=0,Commander:=0,Demo:=0,Exhausted:=0,Fire:=0,Frosty:=0,Honey:=0,Rage:=0,Riley:=0,Shocked:=0,Baby:=0,Carpenter:=0,Demon:=0,Diamond:=0,Lion:=0,Music:=0,Ninja:=0,Shy:=0,Buoyant:=0,Fuzzy:=0,Precise:=0,Spicy:=0,Tadpole:=0,Vector:=0
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
	for i, j in beeArr {
		;bitmaps are w45 h36
		y := (A_Index-1)//8*1
		bm := hovercontrol = j && %j% ? j "bghover" : %j% ? j "bg" : hovercontrol = j ? j "hover" : j
		Gdip_DrawImage(G, bitmaps[bm], 10+mod(A_Index-1,8)*60, 50+y*40, 45, 36)
	}
	update()
}
WM_LBUTTONDOWN(wParam, lParam, msg, hwnd) {
	global
	MouseGetPos(,,,&ctrl,2)
	if !ctrl
		return
	switch mgui[ctrl].name, 0 {
		case "move":PostMessage(0xA1,2)
		default:
			%mgui[ctrl].name% ^= 1
			DrawGUI()
	}
}
WM_MOUSEMOVE(wParam, lParam, msg, hwnd) {
	global
	MouseGetPos(,,,&ctrl,2)
	if !ctrl {
		if hovercontrol
			hovercontrol := "", DrawGUI()
		return
	}
	hovercontrol := mgui[ctrl].name
	DrawGUI()
}