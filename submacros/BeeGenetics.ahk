/************************************************************************
 * @description Bee Genetics is a macro for Bee Swarm Simulator on Roblox.
 * It supports Royal Jelly rolling and Bitterberry feeding with optional
 * mutation OCR matching and shared auto-radioactive support.
 * @file bee-genetics.ahk
 * @author ninju | .ninju.
 * @date 2024/07/24
 * @version 0.0.2
 ***********************************************************************/

#SingleInstance Force
#Requires AutoHotkey v2.0
#Warn VarUnset, Off
#Include %A_ScriptDir%\..
#Include lib\Gdip_All.ahk
#include lib\Roblox.ahk
#include lib\Gdip_ImageSearch.ahk
#include lib\ErrorHandling.ahk
#include lib\nm_OpenMenu.ahk
#include lib\nm_InventorySearch.ahk
SetWorkingDir(A_ScriptDir "\..")
SendMode("Event")
CoordMode('Pixel', 'Screen')
CoordMode('Mouse', 'Screen')
pToken := Gdip_Startup()
OnExit((*) => (closefunction()), -1)
stopToggle(*) {
	global stopping := true
	ExitApp()
}
class __ArrEx extends Array {
	static __New() {
		Super.Prototype.includes := ObjBindMethod(this, 'includes')
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
	local sectionName, section, key, value, defaultValue, inipath, config, source, isNew, ini
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
			bitterberryMode: 0,
			bitterberryAmount: 1,
			mythicStop: 0,
			giftedStop: 0,
			autoRadioactive: 0,
			neonberryLimit: 0
		},
		advanced: {
			advancedMutations: 0,
			AbilityMin: 0,
			GatherMin: 0,
			ConvertMin: 0,
			InstantMin: 0,
			CritMin: 0,
			AttackMin: 0,
			EnergyMin: 0,
			MovespeedMin: 0,
			GatherUnit: "+",
			ConvertUnit: "+",
			AttackUnit: "+"
		}
	}
	if !FileExist(".\settings")
		DirCreate(".\settings")
	inipath := ".\settings\bee_genetics.ini"
	isNew := !FileExist(inipath)
	source := isNew ? ".\settings\mutations.ini" : inipath
	ini := ""
	for sectionName, section in config.OwnProps() {
		ini .= "[" sectionName "]`r`n"
		for key, defaultValue in section.OwnProps() {
			value := IniRead(source, sectionName, key, defaultValue)
			%key% := IsNumber(defaultValue) ? (IsNumber(value) ? Number(value) : defaultValue) : (value = "%" ? "%" : "+")
			ini .= key "=" %key% "`r`n"
		}
	}
	if isNew
		FileOpen(inipath, "w", "UTF-16").Write(ini)
	if !mutations
		bitterberryMode := autoRadioactive := 0
}
w:=500,h:=397
beeArr := ["Bomber", "Brave", "Bumble", "Cool", "Hasty", "Looker", "Rad", "Rascal", "Stubborn", "Bubble", "Bucko", "Commander", "Demo", "Exhausted", "Fire", "Frosty", "Honey", "Rage", "Riley", "Shocked", "Baby", "Carpenter", "Demon", "Diamond", "Lion", "Music", "Ninja", "Shy", "Buoyant", "Fuzzy", "Precise", "Spicy", "Tadpole", "Vector"]
mutationsArr := [
	{name:"Ability", pattern:"(?:bee)?abilityrate"},
	{name:"Gather", pattern:"gatheramount"},
	{name:"Convert", pattern:"convertamount"},
	{name:"Instant", pattern:"instantconversion"},
	{name:"Crit", pattern:"crit(?:ical)?chance"},
	{name:"Attack", pattern:"attack"},
	{name:"Energy", pattern:"energy"},
	{name:"Movespeed", pattern:"movespeed"}
]
extrasettings:=[
	{name:"bitterberryMode", text: "Bitterberry mode"},
	{name:"mythicStop", text: "Stop on mythics"},
	{name:"giftedStop", text: "Stop on gifteds"},
	{name:"autoRadioactive", text: "Auto-radioactive"},
	{name:"advancedMutations", text: "Advanced mode"}
]
(extraText := Map()).CaseSense := 0
for i, j in extrasettings
	extraText[j.name] := j.text
getConfig()
(bitmaps := Map()).CaseSense:=0
#Include .\nm_image_assets\mutator\bitmaps.ahk
#include .\nm_image_assets\mutatorgui\bitmaps.ahk
#include .\nm_image_assets\general\bitmaps.ahk
#include .\nm_image_assets\inventory\bitmaps.ahk
#include .\nm_image_assets\offset\bitmaps.ahk
bitmaps["greensuccess"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAAA4AAAALCAYAAABPhbxiAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAAhdEVYdENyZWF0aW9uIFRpbWUAMjAyMzowMzowOCAxNToyMzo1N/c+ABwAAAAdSURBVChTY3T+H/6fgQzABKVJBqMa8YDhr5GBAQBwxAKu5PiUjAAAAA5lWElmTU0AKgAAAAgAAAAAAAAA0lOTAAAAAElFTkSuQmCC")
stopping := false
running := false
dragging := false
startGui() {
	global
	local i,j,y,x
	(mgui := Gui("+E" (0x00080000) " +OwnDialogs -Caption -DPIScale", "Bee Genetics")).OnEvent("Close", (*) => ExitApp())
	mgui.Show()
	for i, j in [
		{name:"move", options:"x0 y0 w" w " h36"},
		{name:"selectall", options:"x130 y214 w40 h18"},
		{name:"mutations", options:"x290 y214 w40 h18"},
		{name:"neonLimitCfg", options:"x320 y236 w120 h20"},
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
		mgui.AddText("v" j.name " x" 10+mod(A_Index-1,4)*120 " y" 260+y*25 " w110 h18")
	}
	for i, j in extrasettings {
		x := 10 + (w-12)/extrasettings.length * (i-1), y:=(316+h-42)//2-10
		mgui.AddText("v" j.name " x" x " y" y " w40 h18")
	}
	hBM := CreateDIBSection(w, h)
	hDC := CreateCompatibleDC()
	oldBM := SelectObject(hDC, hBM)
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
	global extraText, advancedMutations
	Gdip_GraphicsClear(G)
	Gdip_FillRoundedRectanglePath(G, brush := Gdip_BrushCreateSolid(0xFF131416), 2, 2, w-4, h-4, 20), Gdip_DeleteBrush(brush)
	region := Gdip_GetClipRegion(G)
	Gdip_SetClipRect(G, 2, 21, w-2, 30, 4)
	Gdip_FillRoundedRectanglePath(G, brush := Gdip_BrushCreateSolid("0xFFFEC6DF"), 2, 2, w-4, 40, 20)
	Gdip_SetClipRegion(G, region)
	Gdip_FillRectangle(G, brush, 2, 20, w-4, 14)
	Gdip_DeleteBrush(brush), Gdip_DeleteRegion(region)
	Gdip_TextToGraphics(G, "Bee Genetics", "s20 x20 y5 w460 Near vCenter c" (brush := Gdip_BrushCreateSolid("0xFF131416")), "Comic Sans MS", 460, 30), Gdip_DeleteBrush(brush)
	Gdip_DrawImage(G, bitmaps["close"], w-40, 5, 28, 28)
	for i, j in beeArr {
		y := (A_Index-1)//8
		bm := hovercontrol = j && (%j% || SelectAll) ? j "bghover" : %j% || SelectAll ? j "bg" : hovercontrol = j ? j "hover" : j
		Gdip_DrawImage(G, bitmaps[bm], 10+mod(A_Index-1,8)*60, 50+y*40, 45, 36)
	}
	rightCol1 := 130, rightCol2 := 290, neonCol := 320, advCol := 450
	Gdip_FillRoundedRectanglePath(G, brush := Gdip_BrushCreateSolid("0xFF" . 13*2 . 14*2 . 16*2), rightCol1, 214, 40, 18, 9), Gdip_DeleteBrush(brush)
	Gdip_FillEllipse(G, brush:=Gdip_BrushCreateSolid("0xFFFEC6DF"), selectAll ? rightCol1+20 : rightCol1-2, 212, 22, 22)
	Gdip_TextToGraphics(G, "Select All Bees", "s14 x" rightCol1+46 " y214 Near vCenter c" brush, "Comic Sans MS",, 20), Gdip_DeleteBrush(brush)
	if !SelectAll {
		Gdip_FillEllipse(G, brush:=Gdip_BrushCreateSolid("0xFF" . 13*2 . 14*2 . 16*2), rightCol1, 214, 18, 18), Gdip_DeleteBrush(brush)
		Gdip_DrawLines(G, Pen:=Gdip_CreatePen("0xFFCC0000", 2), [[rightCol1+5, 219], [rightCol1+13, 227]])
		Gdip_DrawLines(G, Pen								  , [[rightCol1+5, 227], [rightCol1+13, 219]]), Gdip_DeletePen(Pen)
	}
	else
		Gdip_DrawLines(G, Pen:=Gdip_CreatePen("0xFF006600", 2), [[rightCol1+27, 223], [rightCol1+30, 226], [rightCol1+35, 219]]), Gdip_DeletePen(Pen)
	Gdip_FillRoundedRectanglePath(G, brush := Gdip_BrushCreateSolid("0xFF" . 13*2 . 14*2 . 16*2), rightCol2, 214, 40, 18, 9), Gdip_DeleteBrush(brush)
	Gdip_FillEllipse(G, brush:=Gdip_BrushCreateSolid("0xFFFEC6DF"), mutations ? rightCol2+20 : rightCol2-2, 212, 22, 22)
	Gdip_TextToGraphics(G, "Mutations", "s14 x" rightCol2+46 " y214 Near vCenter c" (brush), "Comic Sans MS",, 20), Gdip_DeleteBrush(brush)
	if !mutations {
		Gdip_FillEllipse(G, brush:= Gdip_BrushCreateSolid("0xFF" . 13*2 . 14*2 . 16*2), rightCol2, 214, 18, 18), Gdip_DeleteBrush(brush)
		Gdip_DrawLines(G, Pen:=Gdip_CreatePen("0xFFCC0000", 2), [[rightCol2+5, 219], [rightCol2+13, 227]])
		Gdip_DrawLines(G, Pen								  , [[rightCol2+5, 227], [rightCol2+13, 219]]), Gdip_DeletePen(Pen)
	}
	else
		Gdip_DrawLines(G, Pen:=Gdip_CreatePen("0xFF006600", 2), [[rightCol2+27, 223], [rightCol2+30, 226], [rightCol2+35, 219]]), Gdip_DeletePen(Pen)
	mgui["bitterberryMode"].Visible := true
	mgui["neonLimitCfg"].Visible := true
	mgui["advancedMutations"].Visible := true
	mgui["bitterberryMode"].Move(rightCol1, 236, 40, 18)
	mgui["neonLimitCfg"].Move(neonCol, 236, 120, 20)
	mgui["advancedMutations"].Move(advCol, 214, 40, 18)
	bitterDisabled := !mutations
	Gdip_FillRoundedRectanglePath(G, brush := Gdip_BrushCreateSolid("0xFF262832"), rightCol1, 236, 40, 18, 9), Gdip_DeleteBrush(brush)
	Gdip_FillEllipse(G, brush:=Gdip_BrushCreateSolid(bitterDisabled ? "0xFF7E7E7E" : "0xFFFEC6DF"), bitterberryMode ? rightCol1+20 : rightCol1-2, 234, 22, 22)
	Gdip_TextToGraphics(G, extraText["bitterberryMode"], "s14 x" rightCol1+46 " y236 Left vCenter c" brush, "Comic Sans MS", 130, 20), Gdip_DeleteBrush(brush)
	if !bitterberryMode || bitterDisabled {
		Gdip_FillEllipse(G, brush:=Gdip_BrushCreateSolid("0xFF262832"), rightCol1, 236, 18, 18), Gdip_DeleteBrush(brush)
		Gdip_DrawLines(G, Pen:=Gdip_CreatePen(bitterDisabled ? "0xFF888888" : "0xFFCC0000", 2), [[rightCol1+5, 241], [rightCol1+13, 249]])
		Gdip_DrawLines(G, Pen								  , [[rightCol1+5, 249], [rightCol1+13, 241]]), Gdip_DeletePen(Pen)
	}
	else
		Gdip_DrawLines(G, Pen:=Gdip_CreatePen("0xFF006600", 2), [[rightCol1+27, 245], [rightCol1+30, 248], [rightCol1+35, 241]]), Gdip_DeletePen(Pen)
	if bitterDisabled {
		Gdip_FillRectangle(G, brush:=Gdip_BrushCreateSolid("0x55262832"), rightCol1-1, 233, 178, 26), Gdip_DeleteBrush(brush)
	}
	neonLimitDisabled := (!mutations || !autoRadioactive)
	neonLimitText := (neonberryLimit = 0) ? "Neon limit: inf" : "Neon limit: " neonberryLimit
	Gdip_FillRoundedRectanglePath(G, brush:=Gdip_BrushCreateSolid(neonLimitDisabled ? "0xFF2F323B" : "0xFF262832"), neonCol, 236, 120, 20, 8), Gdip_DeleteBrush(brush)
	if (hovercontrol = "neonLimitCfg" && !neonLimitDisabled)
		Gdip_FillRoundedRectanglePath(G, brush:=Gdip_BrushCreateSolid("0x35FEC6DF"), neonCol, 236, 120, 20, 8), Gdip_DeleteBrush(brush)
	Gdip_TextToGraphics(G, neonLimitText, "s10 x" neonCol+6 " y236 Left vCenter c" (brush := Gdip_BrushCreateSolid(neonLimitDisabled ? "0xFF9A9A9A" : "0xFFFEC6DF")), "Comic Sans MS", 108, 20), Gdip_DeleteBrush(brush)
	if neonLimitDisabled
		Gdip_FillRectangle(G, brush:=Gdip_BrushCreateSolid("0x40262832"), neonCol, 236, 120, 20), Gdip_DeleteBrush(brush)
	advDisabled := !mutations
	Gdip_FillRoundedRectanglePath(G, brush:=Gdip_BrushCreateSolid("0xFF262832"), advCol, 214, 40, 18, 9), Gdip_DeleteBrush(brush)
	Gdip_FillEllipse(G, brush:=Gdip_BrushCreateSolid(advDisabled ? "0xFF7E7E7E" : "0xFFFEC6DF"), advancedMutations ? advCol+18 : advCol-2, 212, 22, 22)
	Gdip_TextToGraphics(G, "Adv", "s12 x" advCol-34 " y214 Left vCenter c" brush, "Comic Sans MS", 30, 20), Gdip_DeleteBrush(brush)
	if !advancedMutations || advDisabled {
		Gdip_FillEllipse(G, brush:=Gdip_BrushCreateSolid("0xFF262832"), advCol, 214, 18, 18), Gdip_DeleteBrush(brush)
		Gdip_DrawLines(G, Pen:=Gdip_CreatePen(advDisabled ? "0xFF888888" : "0xFFCC0000", 2), [[advCol+5, 219], [advCol+13, 227]])
		Gdip_DrawLines(G, Pen								  , [[advCol+5, 227], [advCol+13, 219]]), Gdip_DeletePen(Pen)
	}
	else
		Gdip_DrawLines(G, Pen:=Gdip_CreatePen("0xFF006600", 2), [[advCol+25, 223], [advCol+28, 226], [advCol+33, 219]]), Gdip_DeletePen(Pen)
	For i, j in mutationsArr {
		y := (A_Index-1)//4
		if advancedMutations {
			fieldX := 10+mod(A_Index-1,4)*120
			fieldY := 260+y*25
			minValue := blc_GetMutationMin(j.name)
			advDisabled := !mutations
			advActive := (minValue > 0)
			advText := j.name " >= " (advActive ? blc_FormatThreshold(j.name, minValue) : "OFF")
			Gdip_FillRoundedRectanglePath(G, brush:=Gdip_BrushCreateSolid(advDisabled ? "0xFF2F323B" : advActive ? "0xFF2C2F39" : "0xFF262832"), fieldX, fieldY, 110, 18, 8), Gdip_DeleteBrush(brush)
			if (hovercontrol = j.name && !advDisabled)
				Gdip_FillRoundedRectanglePath(G, brush:=Gdip_BrushCreateSolid("0x35FEC6DF"), fieldX, fieldY, 110, 18, 8), Gdip_DeleteBrush(brush)
			Gdip_TextToGraphics(G, advText, "s10 x" fieldX+6 " y" fieldY " Left vCenter c" (brush := Gdip_BrushCreateSolid(advDisabled ? "0xFF9A9A9A" : "0xFFFEC6DF")), "Comic Sans MS", 102, 18), Gdip_DeleteBrush(brush)
		}
		else {
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
	}
	if !mutations
		Gdip_FillRectangle(G, brush:=Gdip_BrushCreateSolid("0x70131416"), 9, 255, w-18, 52), Gdip_DeleteBrush(brush)
	Gdip_DrawLine(G, Pen:=Gdip_CreatePen("0xFFFEC6DF", 2), 10, 315, w-12, 315), Gdip_DeletePen(Pen)
	bottomExtras := ["mythicStop", "giftedStop", "autoRadioactive"]
	for i, name in bottomExtras {
		x := 10 + (tw:=(w-12)/bottomExtras.Length) * (i-1), y:=(316+h-42)//2-10
		mgui[name].Move(x, y, 40, 18)
		mgui[name].Visible := true
		extraDisabled := ((name = "autoRadioactive") && !mutations) || (bitterberryMode && (name = "mythicStop" || name = "giftedStop"))
		Gdip_FillRoundedRectanglePath(G, brush:=Gdip_BrushCreateSolid("0xFF262832"), x, y, 40, 18, 9), Gdip_DeleteBrush(brush)
		Gdip_FillEllipse(G, brush:=Gdip_BrushCreateSolid(extraDisabled ? "0xFF7E7E7E" : "0xFFFEC6DF"), %name% ? x+18 : x-2, y-2, 22, 22)
		Gdip_TextToGraphics(G, extraText[name], "s12 x" x+46 " y" y " vCenter c" brush, "Comic Sans MS", tw-48,20), Gdip_DeleteBrush(brush)
		if !%name% || extraDisabled {
			Gdip_FillEllipse(G, brush:=Gdip_BrushCreateSolid("0xFF262832"), x, y, 18, 18), Gdip_deleteBrush(brush)
			Gdip_DrawLines(G, Pen:=Gdip_CreatePen(extraDisabled ? "0xFF888888" : "0xFFCC0000", 2), [[x+5, y+5 ], [x+13, y+13]])
			Gdip_DrawLines(G, Pen														, [[x+5, y+13], [x+13, y+5 ]]), Gdip_DeletePen(Pen)
		}
		else
			Gdip_DrawLines(G, Pen:=Gdip_CreatePen("0xFF006600", 2), [[x+25, y+9], [x+28, y+12], [x+33, y+5]]), Gdip_DeletePen(Pen)
		if extraDisabled {
			Gdip_FillRectangle(G, brush:=Gdip_BrushCreateSolid("0x55262832"), x-1, y-3, tw+48, 26), Gdip_DeleteBrush(brush)
		}
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
blc_GetMutationMin(name) {
	global AbilityMin, GatherMin, ConvertMin, InstantMin, CritMin, AttackMin, EnergyMin, MovespeedMin
	switch name, 0 {
		case "Ability": value := AbilityMin
		case "Gather": value := GatherMin
		case "Convert": value := ConvertMin
		case "Instant": value := InstantMin
		case "Crit": value := CritMin
		case "Attack": value := AttackMin
		case "Energy": value := EnergyMin
		case "Movespeed": value := MovespeedMin
		default: return 0
	}
	if !RegExMatch(value, "^\d+(\.\d+)?$")
		return 0
	value := Number(value)
	if (value <= 0)
		return 0
	return value
}
blc_SetMutationMin(name, value) {
	global AbilityMin, GatherMin, ConvertMin, InstantMin, CritMin, AttackMin, EnergyMin, MovespeedMin
	switch name, 0 {
		case "Ability": AbilityMin := value
		case "Gather": GatherMin := value
		case "Convert": ConvertMin := value
		case "Instant": InstantMin := value
		case "Crit": CritMin := value
		case "Attack": AttackMin := value
		case "Energy": EnergyMin := value
		case "Movespeed": MovespeedMin := value
		default: return
	}
	IniWrite(value, ".\settings\bee_genetics.ini", "advanced", name "Min")
}
blc_GetMutationSpec(name) {
	switch name, 0 {
		case "Ability":
			return {mode:"percent", rangeText:"Typical: 1-4%"}
		case "Gather":
			return {mode:"both", rangeText:"Typical: +2-10 or 10-30%"}
		case "Convert":
			return {mode:"both", rangeText:"Typical: +20-80 or 10-30%"}
		case "Instant":
			return {mode:"percent", rangeText:"Typical: 8-20%"}
		case "Crit":
			return {mode:"percent", rangeText:"Typical: 1-3%"}
		case "Attack":
			return {mode:"both", rangeText:"Typical: +1-2 or 5-20%"}
		case "Energy":
			return {mode:"percent", rangeText:"Typical: 10-40%"}
		case "Movespeed":
			return {mode:"plus", rangeText:"Typical: +2-6"}
	}
	return {mode:"both", rangeText:""}
}
blc_MutationUnit(name) {
	global GatherUnit, ConvertUnit, AttackUnit
	if blc_GetMutationSpec(name).mode = "both" {
		key := name "Unit"
		return %key%
	}
	return blc_GetMutationSpec(name).mode = "percent" ? "%" : "+"
}
blc_FormatThreshold(name, value) {
	if !value
		return "0"
	return blc_MutationUnit(name) = "%" ? value "%" : "+" value
}
blc_SetThreshold(name, text) {
	global GatherUnit, ConvertUnit, AttackUnit
	if !RegExMatch(text, "^(\+?)(\d+(?:\.\d+)?)(%?)$", &m)
		return false
	value := Number(m[2]), unit := m[3] = "%" ? "%" : "+"
	spec := blc_GetMutationSpec(name)
	if value && ((m[1] = "" && m[3] = "") || (spec.mode = "percent" && unit != "%") || (spec.mode = "plus" && unit != "+"))
		return false
	blc_SetMutationMin(name, value)
	if spec.mode = "both" {
		key := name "Unit"
		%key% := unit
		IniWrite(unit, ".\settings\bee_genetics.ini", "advanced", key)
	}
	return true
}
blc_ParseMutation(text, requireValue := true) {
	global mutationsArr
	text := StrLower(StrReplace(StrReplace(text, "o/o", "%"), "％", "%"))
	text := RegExReplace(text, "[\r\n]+", "`n")
	text := RegExReplace(text, "[ \t():]", "")
	text := Trim(StrReplace(text, "mutation", ""), "`n")
	if RegExMatch(text, "^(?:no|none|notmutated)\s*$")
		return {name:"none", value:0, unit:""}
	found := 0
	for stat in mutationsArr {
		pattern := "(?:^|`n)(?:\+(\d+(?:[.,]\d+)?)(%?)`n?" stat.pattern "|" stat.pattern "`n?\+(\d+(?:[.,]\d+)?)(%?))(?:`n|$)"
		if (pos := RegExMatch(text, pattern, &m)) {
			if RegExMatch(SubStr(text, pos+StrLen(m[0])-1), pattern)
				return 0
			if IsObject(found)
				return 0
			value := m[1] != "" ? m[1] : m[3]
			unit := (m[1] != "" ? m[2] : m[4]) = "%" ? "%" : "+"
			if (requireValue && blc_GetMutationSpec(stat.name).mode = "percent" && unit != "%")
				return 0
			found := {name:stat.name, value:Number(StrReplace(value, ",", ".")), unit:unit}
		} else if !requireValue && RegExMatch(text, "(?:^|`n)" stat.pattern "(?:`n|$)") {
			if IsObject(found)
				return 0
			found := {name:stat.name, value:"", unit:""}
		}
	}
	return found
}
blc_MutationMatches(parsed, selectedMutations) {
	global advancedMutations
	if !IsObject(parsed)
		throw Error("The mutation could not be read. Stopped before using more items.")
	for stat in selectedMutations
		if stat.name = parsed.name && (!advancedMutations || (parsed.unit = blc_MutationUnit(stat.name) && parsed.value >= stat.min))
			return true
	return false
}

blc_ToggleExtraSetting(name) {
	global bitterberryMode, mythicStop, giftedStop, autoRadioactive, advancedMutations
	switch name, 0 {
		case "bitterberryMode":
			return (bitterberryMode ^= 1)
		case "mythicStop":
			return (mythicStop ^= 1)
		case "giftedStop":
			return (giftedStop ^= 1)
		case "autoRadioactive":
			return (autoRadioactive ^= 1)
		case "advancedMutations":
			return (advancedMutations ^= 1)
	}
	return ""
}
WM_LBUTTONDOWN(wParam, lParam, msg, hwnd) {
	global hovercontrol, mutations, Bomber, Brave, Bumble, Cool, Hasty, Looker, Rad, Rascal
	, Stubborn, Bubble, Bucko, Commander, Demo, Exhausted, Fire, Frosty, Honey, Rage
	, Riley, Shocked, Baby, Carpenter, Demon, Diamond, Lion, Music, Ninja, Shy, Buoyant
	, Fuzzy, Precise, Spicy, Tadpole, Vector, SelectAll, Ability, Gather, Convert, Energy
	, Movespeed, Crit, Instant, Attack, bitterberryMode, bitterberryAmount, mythicStop, giftedStop, autoRadioactive, neonberryLimit, advancedMutations
	, AbilityMin, GatherMin, ConvertMin, InstantMin, CritMin, AttackMin, EnergyMin, MovespeedMin, mgui
	MouseGetPos(,,,&ctrl,2)
	if !ctrl || !IsSet(mgui) || !IsObject(GuiCtrlFromHwnd(ctrl)) || GuiCtrlFromHwnd(ctrl).Gui != mgui
		return
	switch mgui[ctrl].name, 0 {
		case "move":
			PostMessage(0x00A1,2)
		case "close":
			while GetKeyState("LButton", "P")
				sleep -1
			mousegetpos ,,, &ctrl2, 2
			if ctrl = ctrl2
				ExitApp()
		case "roll":
			ReplaceSystemCursors()
			IniWrite(mutations, ".\settings\bee_genetics.ini", "mutations", "mutations")
			IniWrite(bitterberryMode, ".\settings\bee_genetics.ini", "extrasettings", "bitterberryMode")
			IniWrite(autoRadioactive, ".\settings\bee_genetics.ini", "extrasettings", "autoRadioactive")
			IniWrite(neonberryLimit, ".\settings\bee_genetics.ini", "extrasettings", "neonberryLimit")
			IniWrite(advancedMutations, ".\settings\bee_genetics.ini", "advanced", "advancedMutations")
			SetTimer(blc_start, -1)
		case "help":
			ReplaceSystemCursors()
			Msgbox("Bee Genetics supports both Royal Jelly and Bitterberry workflows.`n`nTo use:`n- Select bees for Royal Jelly mode`n- Without Auto-radioactive, leave a Royal Jelly result open before starting`n- Toggle Bitterberry mode ON to feed bitterberries instead`n- Keep Mutations enabled when using Bitterberry mode`n- Select mutation filters for OCR matching`n- Advanced mode: click a mutation to enter a minimum, such as +2 or 10%`n- Enable Auto-radioactive and set Neon limit if desired`n- Click Roll to start`n`nKeep the Roblox window and camera still during the run.`n`nAt start, you'll be asked to left-click a bee slot when needed.`n(Bitterberry mode always needs it; Auto-radioactive needs it too.)`n`nTo stop:`n- Press Escape to stop and close Bee Genetics", "Bee Genetics Help", "0x40040")
		case "selectAll":
			IniWrite(%mgui[ctrl].name% ^= 1, ".\settings\bee_genetics.ini", "bees", mgui[ctrl].name)
		case "Bomber", "Brave", "Bumble", "Cool", "Hasty", "Looker", "Rad", "Rascal", "Stubborn", "Bubble", "Bucko", "Commander", "Demo", "Exhausted", "Fire", "Frosty", "Honey", "Rage", "Riley":
			if !selectAll
				IniWrite(%mgui[ctrl].name% ^= 1, ".\settings\bee_genetics.ini", "bees", mgui[ctrl].name)
		case "Shocked", "Baby", "Carpenter", "Demon", "Diamond", "Lion", "Music", "Ninja", "Shy", "Buoyant", "Fuzzy", "Precise", "Spicy", "Tadpole", "Vector":
			if !selectAll
				IniWrite(%mgui[ctrl].name% ^= 1, ".\settings\bee_genetics.ini", "bees", mgui[ctrl].name)
		case "bitterberryMode", "giftedStop", "mythicStop", "autoRadioactive", "advancedMutations":
			if (mgui[ctrl].name = "bitterberryMode" && !mutations)
				return
			if (mgui[ctrl].name = "autoRadioactive" && !mutations)
				return
			if (mgui[ctrl].name = "advancedMutations" && !mutations)
				return
			if (bitterberryMode && (mgui[ctrl].name = "mythicStop" || mgui[ctrl].name = "giftedStop"))
				return
			newValue := blc_ToggleExtraSetting(mgui[ctrl].name)
			if (newValue = "")
				return
			IniWrite(newValue, ".\settings\bee_genetics.ini", (mgui[ctrl].name = "advancedMutations") ? "advanced" : "extrasettings", mgui[ctrl].name)
		case "neonLimitCfg":
			if (!autoRadioactive || !mutations)
				return
			limitInput := InputBox("Enter max Neonberries Auto-radioactive may use this run.`nEnter 0 for unlimited.", "Auto-radioactive Limit", "w380 h170 T60", neonberryLimit)
			if (limitInput.Result != "OK")
				return
			if !IsInteger(limitInput.Value)
			{
				MsgBox "You must enter a non-negative integer for the Neonberry limit.", "Bee Genetics", 0x40030
				return
			}
			newLimit := Integer(limitInput.Value)
			if (newLimit < 0)
			{
				MsgBox "Neonberry limit cannot be negative.", "Bee Genetics", 0x40030
				return
			}
			neonberryLimit := newLimit
			IniWrite(neonberryLimit, ".\settings\bee_genetics.ini", "extrasettings", "neonberryLimit")
		case "mutations":
			mutations ^= 1
			IniWrite(mutations, ".\settings\bee_genetics.ini", "mutations", "mutations")
			if (!mutations && bitterberryMode)
			{
				bitterberryMode := 0
				IniWrite(bitterberryMode, ".\settings\bee_genetics.ini", "extrasettings", "bitterberryMode")
			}
			if (!mutations && autoRadioactive)
			{
				autoRadioactive := 0
				IniWrite(autoRadioactive, ".\settings\bee_genetics.ini", "extrasettings", "autoRadioactive")
			}
		case "Ability", "Gather", "Convert", "Instant", "Crit", "Attack", "Energy", "Movespeed":
			if !mutations
				return
			if advancedMutations {
				currMin := blc_GetMutationMin(mgui[ctrl].name)
				spec := blc_GetMutationSpec(mgui[ctrl].name)
				minInput := InputBox("Set the minimum " mgui[ctrl].name " mutation.`n" spec.rangeText "`nUse +2 for a flat bonus, 10% for a percentage, or 0 to disable.", "Mutation Threshold", "w420 h180", blc_FormatThreshold(mgui[ctrl].name, currMin))
				if (minInput.Result != "OK")
					return
				if !blc_SetThreshold(mgui[ctrl].name, Trim(minInput.Value)) {
					MsgBox "Enter a value with its unit, such as +2 or 10%. Use 0 to disable.", "Bee Genetics", 0x40030
					return
				}
			}
			else
				IniWrite(%mgui[ctrl].name% ^= 1, ".\settings\bee_genetics.ini", "mutations", mgui[ctrl].name)
		default:
			if mutations
				IniWrite(%mgui[ctrl].name% ^= 1, ".\settings\bee_genetics.ini", "mutations", mgui[ctrl].name)
	}
	DrawGUI()
}
WM_MOUSEMOVE(wParam, lParam, msg, hwnd) {
	global
	local ctrl, hover_ctrl, tt := 0
	MouseGetPos(,,,&ctrl,2)
	if !ctrl || !IsObject(GuiCtrlFromHwnd(ctrl)) || GuiCtrlFromHwnd(ctrl).Gui != mgui || mgui["move"].hwnd = ctrl || mgui["close"].hwnd = ctrl
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
blc_CheckWindow() {
	global runWindow, stopping, windowX, windowY, windowWidth, windowHeight
	if stopping
		throw Error("Stopped.")
	if !WinActive("ahk_id " runWindow.hwnd) || !GetRobloxClientPos(runWindow.hwnd)
		throw Error("Roblox lost focus. Stopped before using more items.")
	if windowX != runWindow.x || windowY != runWindow.y || windowWidth != runWindow.w || windowHeight != runWindow.h
		throw Error("The Roblox window moved or changed size. Start again to select the bee.")
}
blc_Wait(ms) {
	deadline := A_TickCount + ms
	loop {
		blc_CheckWindow()
		if A_TickCount >= deadline
			return
		Sleep Min(25, deadline - A_TickCount)
	}
}
blc_FindImage(name, x, y, w, h, &pos := "", variation := 20) {
	global bitmaps
	bm := Gdip_BitmapFromScreen(x "|" y "|" w "|" h)
	if !bm
		throw Error("Could not capture the Roblox window.")
	try {
		result := Gdip_ImageSearch(bm, bitmaps[name], &pos, , , , , variation, , 2)
		if result < 0
			throw Error("Could not check the " name " image.")
		return result = 1
	} finally Gdip_DisposeImage(bm)
}
blc_FeedPrompt(&pos := "") {
	global windowX, windowY, windowWidth, windowHeight, runWindow
	return blc_FindImage("feed", windowX+(54*windowWidth)//100-300, windowY+runWindow.offset+(46*windowHeight)//100-59, 250, 100, &pos, 2)
}
blc_MutationVisible() {
	global windowX, windowY, windowWidth, windowHeight, runWindow
	return blc_FindImage("greensuccess", windowX+windowWidth//2-295, windowY+runWindow.offset+(4*windowHeight)//10-15, 150, 50)
}
blc_CloseBeeWindow() {
	global windowX, windowY, windowWidth, windowHeight, runWindow
	blc_CheckWindow()
	Click windowX+windowWidth//2-132, windowY+runWindow.offset+(4*windowHeight)//10-150
	blc_Wait(150)
	if blc_MutationVisible()
		throw Error("The previous mutation panel did not close.")
}
blc_DragItem(item, beeX, beeY) {
	global windowX, windowY, dragging
	blc_CheckWindow()
	pos := nm_InventorySearch(item, "down", , , , 70, &failure, 20)
	blc_CheckWindow()
	if !IsObject(pos)
		throw Error("Could not find " item " in the inventory.`n" failure)
	MouseMove windowX+pos[1], windowY+pos[2]
	dragging := true
	SendEvent "{LButton down}"
	try {
		blc_Wait(100)
		MouseMove beeX, beeY
		blc_Wait(100)
	} finally {
		SendEvent "{LButton up}"
		dragging := false
	}
}
blc_Feed(item, amount, beeX, beeY) {
	global windowX, windowY, windowWidth, windowHeight, runWindow
	blc_DragItem(item, beeX, beeY)
	deadline := A_TickCount + 2500
	while !blc_FeedPrompt(&pos) {
		if A_TickCount >= deadline
			throw Error("The " item " feed prompt did not appear.")
		blc_Wait(100)
	}
	xy := StrSplit(pos, ",")
	x := windowX+(54*windowWidth)//100-300+Integer(xy[1])
	y := windowY+runWindow.offset+(46*windowHeight)//100-59+Integer(xy[2])
	blc_CheckWindow()
	Click x+140, y+5
	blc_Wait(100)
	SendEvent "^a"
	SendText amount
	blc_Wait(100)
	Click x, y
	MouseMove windowX+windowWidth-30, windowY+windowHeight-30
	deadline := A_TickCount + 2500
	loop {
		blc_Wait(100)
		if !blc_FeedPrompt()
			break
		if A_TickCount >= deadline
			throw Error("The " item " feed was not confirmed. Stopped before trying again.")
	}
	blc_Wait(750)
}
blc_MakeRadioactive(beeX, beeY, &used, limit) {
	if limit > 0 && used >= limit
		throw Error("The Neonberry limit for this run was reached.")
	blc_Feed("Neonberry", 1, beeX, beeY)
	used += 1
}
blc_OpenJelly(beeX, beeY) {
	global windowX, windowY, windowWidth, windowHeight, runWindow
	blc_DragItem("RoyalJelly", beeX, beeY)
	deadline := A_TickCount + 2500
	loop {
		blc_Wait(100)
		if blc_FindImage("yes", windowX+windowWidth//2-200, windowY+runWindow.offset+windowHeight//2-150, 400, 300, &pos, 10)
			break
		if A_TickCount >= deadline
			throw Error("The Royal Jelly confirmation did not appear.")
	}
	xy := StrSplit(pos, ",")
	Click windowX+windowWidth//2-200+Integer(xy[1])+5, windowY+runWindow.offset+windowHeight//2-150+Integer(xy[2])+5
	MouseMove windowX+windowWidth-30, windowY+windowHeight-30
	blc_Wait(800)
}
blc_ReadBee() {
	global beeArr, bitmaps, windowX, windowY, windowWidth, windowHeight, runWindow
	deadline := A_TickCount + 3000
	loop {
		blc_CheckWindow()
		bm := Gdip_BitmapFromScreen(windowX+windowWidth//2-155 "|" windowY+runWindow.offset+Round(0.425*windowHeight)-200 "|320|140")
		try {
			for bee in beeArr {
				if Gdip_ImageSearch(bm, bitmaps["+" bee]) = 1
					return {name:bee, gifted:true}
				if Gdip_ImageSearch(bm, bitmaps["-" bee]) = 1
					return {name:bee, gifted:false}
			}
		} finally Gdip_DisposeImage(bm)
		if A_TickCount >= deadline
			throw Error("The Royal Jelly result could not be read. Stopped before rolling again.")
		blc_Wait(150)
	}
}
blc_ReadMutationText() {
	global windowX, windowY, windowWidth, windowHeight, runWindow, ocr_language
	blc_CheckWindow()
	bm := Gdip_BitmapFromScreen(windowX+windowWidth//2-320 "|" windowY+runWindow.offset+Round(0.4*windowHeight)+17 "|210|90")
	effect := hBitmap := 0
	try {
		effect := Gdip_CreateEffect(5, -60, 30)
		Gdip_BitmapApplyEffect(bm, effect)
		hBitmap := Gdip_CreateHBITMAPFromBitmap(bm)
		return ocr(HBitmapToRandomAccessStream(hBitmap), ocr_language)
	} finally {
		if hBitmap
			DeleteObject(hBitmap)
		if effect
			Gdip_DisposeEffect(effect)
		Gdip_DisposeImage(bm)
	}
}
blc_ReadMutation() {
	global advancedMutations
	previous := "", count := 0
	Loop 6 {
		parsed := blc_ParseMutation(blc_ReadMutationText(), advancedMutations)
		if IsObject(parsed) {
			key := advancedMutations ? parsed.name "|" parsed.value "|" parsed.unit : parsed.name
			count := key = previous ? count+1 : 1
			previous := key
			if count >= 2
				return parsed
		} else
			previous := "", count := 0
		blc_Wait(150)
	}
	throw Error("The mutation could not be read consistently. Stopped before using more items.")
}
blc_start() {
	global running, stopping, mutations, bitterberryMode, autoRadioactive, bitterberryAmount, neonberryLimit
		, beeArr, SelectAll, mutationsArr, advancedMutations, mgui, mythicStop, giftedStop, runWindow, ocr_language
	if running
		return
	running := true, stopping := false
	Hotkey "~*esc", stopToggle, "On"
	try {
		selectedBees := [], selectedMutations := []
		for bee in beeArr
			if %bee% || SelectAll
				selectedBees.Push(bee)
		if mutations {
			for stat in mutationsArr {
				minimum := advancedMutations ? blc_GetMutationMin(stat.name) : 0
				if (advancedMutations ? minimum > 0 : %stat.name%)
					selectedMutations.Push({name:stat.name, min:minimum})
			}
		}
		if !bitterberryMode && !selectedBees.Length && !selectedMutations.Length
			throw Error("Select at least one bee or mutation before rolling.")
		if advancedMutations && mutations && !selectedMutations.Length
			throw Error("Set at least one mutation minimum, or turn off Advanced mode.")
		if selectedMutations.Length {
			ocr_language := ""
			for language in StrSplit(ocr("ShowAvailableLanguages"), "`n", "`r")
				if InStr(language, "en-") = 1 {
					ocr_language := language
					break
				}
			if !ocr_language
				throw Error("Install an English Windows OCR language before using mutation filters.")
		}
		if bitterberryMode {
			amount := InputBox("Bitterberries per feed:", "Bee Genetics", "w340 h150", bitterberryAmount)
			if amount.Result != "OK"
				return
			if !IsInteger(amount.Value) || Integer(amount.Value) < 1
				throw Error("Enter a positive whole number of Bitterberries.")
			bitterberryAmount := Integer(amount.Value)
			IniWrite(bitterberryAmount, ".\settings\bee_genetics.ini", "extrasettings", "bitterberryAmount")
		}
		if !IsInteger(neonberryLimit) || neonberryLimit < 0
			throw Error("Enter a non-negative whole number for the Neonberry limit.")
		mgui.Hide()
		if !(hwnd := GetRobloxHWND()) || !ActivateRoblox() || !GetRobloxClientPos(hwnd)
			throw Error("Open Bee Swarm Simulator before starting.")
		offset := GetYOffset(hwnd, &failed)
		if failed
			throw Error("The in-game GUI offset could not be detected.")
		runWindow := {hwnd:hwnd, x:windowX, y:windowY, w:windowWidth, h:windowHeight, offset:offset}
		beeX := beeY := 0
		if bitterberryMode || autoRadioactive {
			ToolTip "Click the bee slot to target. Press Escape to cancel."
			KeyWait "LButton"
			KeyWait "LButton", "D"
			MouseGetPos &beeX, &beeY
			KeyWait "LButton"
			ToolTip()
			blc_CheckWindow()
			if beeX < windowX || beeY < windowY || beeX >= windowX+windowWidth || beeY >= windowY+windowHeight
				throw Error("Select a bee inside the Roblox window.")
		}
		used := 0, nextRadioactive := 0, first := true
		loop {
			blc_CheckWindow()
			openedJelly := false
			if autoRadioactive && A_TickCount >= nextRadioactive {
				blc_MakeRadioactive(beeX, beeY, &used, neonberryLimit)
				nextRadioactive := A_TickCount + 11*60*1000
				if !bitterberryMode {
					blc_OpenJelly(beeX, beeY)
					openedJelly := true
				}
			}
			if bitterberryMode {
				if blc_MutationVisible()
					blc_CloseBeeWindow()
				blc_Feed("Bitterberry", bitterberryAmount, beeX, beeY)
				if !blc_MutationVisible()
					continue
				if selectedMutations.Length && !blc_MutationMatches(blc_ReadMutation(), selectedMutations)
					continue
			} else {
				if !first && !openedJelly {
					Click windowX+Round(0.5*windowWidth+10), windowY+offset+Round(0.4*windowHeight+230)
					MouseMove windowX+windowWidth-30, windowY+windowHeight-30
					blc_Wait(800)
				}
				first := false
				bee := blc_ReadBee()
				if mythicStop && ["Buoyant", "Fuzzy", "Precise", "Spicy", "Tadpole", "Vector"].includes(bee.name)
					break
				if giftedStop && bee.gifted
					break
				if selectedBees.Length && !selectedBees.includes(bee.name)
					continue
				if selectedMutations.Length && !blc_MutationMatches(blc_ReadMutation(), selectedMutations)
					continue
			}
			if MsgBox("Found a match!`nKeep this result?", "Bee Genetics", 0x40044) = "Yes"
				break
			ActivateRoblox()
		}
	} catch Error as err {
		MsgBox err.Message, "Bee Genetics", 0x40030
	} finally {
		ToolTip()
		Hotkey "~*esc", stopToggle, "Off"
		running := false
		mgui.Show()
	}
}
closeFunction(*) {
	global xPos, yPos
	if dragging
		SendEvent "{LButton up}"
	ToolTip()
	ReplaceSystemCursors()
	try {
		mgui.GetPos(&xp, &yp)
		if xp >= 0 && yp >= 0 {
			IniWrite(xp, ".\settings\bee_genetics.ini", "GUI", "xPos")
			IniWrite(yp, ".\settings\bee_genetics.ini", "GUI", "yPos")
		}
	}
	try mgui.Destroy()
	try Gdip_DeleteGraphics(G)
	try SelectObject(hDC, oldBM)
	try DeleteObject(hBM)
	try DeleteDC(hDC)
	if IsSet(bitmaps)
		for name, bitmap in bitmaps
			Gdip_DisposeImage(bitmap)
	Gdip_Shutdown(pToken)
}

HBitmapToRandomAccessStream(hBitmap) {
	stream := picture := randomAccess := 0
	try {
		DllCall("Ole32\CreateStreamOnHGlobal", "Ptr", 0, "UInt", true, "PtrP", &stream, "HRESULT")
		desc := Buffer(8+A_PtrSize*2, 0)
		NumPut("UInt", desc.Size, "UInt", 1, "Ptr", hBitmap, desc)
		DllCall("OleAut32\OleCreatePictureIndirect", "Ptr", desc, "Ptr", CLSIDFromString("{7BF80980-BF32-101A-8BBB-00AA00300CAB}"), "UInt", false, "PtrP", &picture, "HRESULT")
		ComCall(15, picture, "Ptr", stream, "UInt", true, "UIntP", &size := 0)
		DllCall("ShCore\CreateRandomAccessStreamOverStream", "Ptr", stream, "UInt", 0, "Ptr", CLSIDFromString("{905A0FE1-BC53-11DF-8C49-001E4FC686DA}"), "PtrP", &randomAccess, "HRESULT")
		return randomAccess
	} finally {
		if picture
			ObjRelease(picture)
		if stream
			ObjRelease(stream)
	}
}
CLSIDFromString(iid) {
	guid := Buffer(16)
	DllCall("ole32\CLSIDFromString", "WStr", iid, "Ptr", guid, "HRESULT")
	return guid
}
CreateClass(name, iid) {
	hString := 0
	try {
		DllCall("Combase\WindowsCreateString", "WStr", name, "UInt", StrLen(name), "PtrP", &hString, "HRESULT")
		DllCall("Combase\RoGetActivationFactory", "Ptr", hString, "Ptr", CLSIDFromString(iid), "PtrP", &factory := 0, "HRESULT")
		return factory
	} finally DllCall("Combase\WindowsDeleteString", "Ptr", hString)
}
blc_String(hString) {
	try return StrGet(DllCall("Combase\WindowsGetStringRawBuffer", "Ptr", hString, "UIntP", &length := 0, "Ptr"), length, "UTF-16")
	finally DllCall("Combase\WindowsDeleteString", "Ptr", hString)
}
WaitForAsync(&object) {
	info := ComObjQuery(object, "{00000036-0000-0000-C000-000000000046}")
	deadline := A_TickCount+3000
	loop {
		ComCall(7, info, "UIntP", &status := 0)
		if status = 1
			break
		if status != 0
			throw Error("Windows OCR could not complete the read.")
		if A_TickCount >= deadline {
			ComCall(9, info)
			throw Error("Windows OCR timed out. Stopped before using more items.")
		}
		Sleep 10
	}
	ComCall(8, object, "PtrP", &result := 0)
	ObjRelease(object)
	object := result
}
ocr(input, language := "") {
	static engineStatics := 0, languageFactory := 0, decoderStatics := 0, engine := 0, activeLanguage := ""
	stream := IsInteger(input) ? input : 0
	languageObject := decoder := software := result := lines := languages := 0
	try {
		if !engineStatics
			engineStatics := CreateClass("Windows.Media.Ocr.OcrEngine", "{5BFFA85A-3384-3540-9940-699120D428A8}")
		if !languageFactory
			languageFactory := CreateClass("Windows.Globalization.Language", "{9B0252AC-0C27-44F8-B792-9793FB66C63E}")
		if input = "ShowAvailableLanguages" {
			ComCall(7, engineStatics, "PtrP", &languages)
			ComCall(7, languages, "UIntP", &count := 0)
			text := ""
			Loop count {
				ComCall(6, languages, "UInt", A_Index-1, "PtrP", &languageObject)
				ComCall(6, languageObject, "PtrP", &hText := 0)
				text .= blc_String(hText) "`n"
				ObjRelease(languageObject), languageObject := 0
			}
			return text
		}
		if !decoderStatics
			decoderStatics := CreateClass("Windows.Graphics.Imaging.BitmapDecoder", "{438CCB26-BCEF-4E95-BAD6-23A822E58D01}")
		if !engine || activeLanguage != language {
			if engine
				ObjRelease(engine), engine := 0
			hString := 0
			try {
				DllCall("Combase\WindowsCreateString", "WStr", language, "UInt", StrLen(language), "PtrP", &hString, "HRESULT")
				ComCall(6, languageFactory, "Ptr", hString, "PtrP", &languageObject)
				ComCall(9, engineStatics, "Ptr", languageObject, "PtrP", &engine)
			} finally DllCall("Combase\WindowsDeleteString", "Ptr", hString)
			if !engine
				throw Error("The selected Windows OCR language is unavailable.")
			activeLanguage := language
		}
		ComCall(14, decoderStatics, "Ptr", stream, "PtrP", &decoder)
		WaitForAsync(&decoder)
		frame := ComObjQuery(decoder, "{FE287C9A-420C-4963-87AD-691436E08383}")
		ComCall(6, frame, "PtrP", &software)
		WaitForAsync(&software)
		ComCall(6, engine, "Ptr", software, "PtrP", &result)
		WaitForAsync(&result)
		ComCall(6, result, "PtrP", &lines)
		ComCall(7, lines, "UIntP", &count := 0)
		text := ""
		Loop count {
			ComCall(6, lines, "UInt", A_Index-1, "PtrP", &line := 0)
			try {
				ComCall(7, line, "PtrP", &hText := 0)
				text .= blc_String(hText) "`n"
			} finally ObjRelease(line)
		}
		return text
	} finally {
		for object in [stream, software] {
			if object {
				try {
					closable := ComObjQuery(object, "{30D5A829-7FA4-4026-83BB-D75BAE4EA99E}")
					ComCall(6, closable)
				}
			}
		}
		for object in [languageObject, decoder, software, result, lines, languages, stream]
			if object
				ObjRelease(object)
	}
}
