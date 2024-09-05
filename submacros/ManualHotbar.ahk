/*
Natro Macro (https://github.com/NatroTeam/NatroMacro)
Copyright © Natro Team (https://github.com/NatroTeam)

This file is part of Natro Macro. Our source code will always be open and available.

Natro Macro is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

Natro Macro is distributed in the hope that it will be useful. This does not give you the right to steal sections from our code, distribute it under your own name, then slander the macro.

You should have received a copy of the license along with Natro Macro. If not, please redownload from an official source.
*/

#SingleInstance Force
#Warn VarUnset, Off

;(! change the v2)
F7::Reload
F8::ExitApp
;OnError (e, mode) => (mode = "Return") ? -1 : 0
DetectHiddenWindows 1
SetWorkingDir A_ScriptDir "\.."
TraySetIcon "nm_image_assets\auryn.ico"
#Include "%A_ScriptDir%\..\lib"
#Include "Roblox.ahk"
#Include "ReadIni.ahk"

; check for the correct AHK version before starting
if (A_PtrSize != 4)
{
    SplitPath(A_AhkPath, , &ahkDirectory)

    if (!FileExist(ahkPath := ahkDirectory "\AutoHotkey32.exe"))
        MsgBox "Couldn't find the 32-bit version of Autohotkey in:`n" ahkPath, "Error", 0x10
    else
        ReloadScript(ahkpath)

    ExitApp
}
ReloadScript(ahkpath) {
	static cmd := DllCall("GetCommandLine", "Str"), params := DllCall("shlwapi\PathGetArgs","Str",cmd,"Str")
	Run '"' ahkpath '" /restart ' params
}

; GUI skinning: https://www.autohotkey.com/boards/viewtopic.php?f=6&t=5841&hilit=gui+skin
GuiTheme := IniRead("settings\nm_config.ini", "Settings", "GuiTheme", "MacLion3")
DllCall(DllCall("GetProcAddress"
		, "Ptr",DllCall("LoadLibrary", "Str",A_WorkingDir "\nm_image_assets\Styles\USkin.dll")
		, "AStr","USkinInit", "Ptr")
	, "Int",0, "Int",0, "AStr",A_WorkingDir "\nm_image_assets\styles\" GuiTheme ".msstyles")

;GLOBALS
nm_importHotbarGlobals() {
	global
	local ManualHotbarGlobals := Map()

	ManualHotbarGlobals["ManualHotbar"] := Map("ManualHBX", 0
		, "ManualHBY", 0
		, "ManualHotbarTimer1", 600
		, "ManualHotbarTimer2", 600
		, "ManualHotbarTimer3", 600
		, "ManualHotbarTimer4", 600
		, "ManualHotbarTimer5", 600
		, "ManualHotbarTimer6", 600
		, "ManualHotbarTimer7", 600
		, "ManualHotbarArmed1", 0
		, "ManualHotbarArmed2", 0
		, "ManualHotbarArmed3", 0
		, "ManualHotbarArmed4", 0
		, "ManualHotbarArmed5", 0
		, "ManualHotbarArmed6", 0
		, "ManualHotbarArmed7", 0)

	local k, v, i, j
	for k,v in ManualHotbarGlobals ; load the default values as globals, will be overwritten if a new value exists when reading
		for i,j in v
			%i% := j

	local inipath := A_WorkingDir "\settings\manual_hotbar.ini"

	if FileExist(inipath)
		nm_ReadIni(inipath)

	local ini := ""
	for k,v in ManualHotbarGlobals ; overwrite any existing .ini with updated one with all new keys and old values
	{
		ini .= "[" k "]`r`n"
		for i in v
			ini .= i "=" %i% "`r`n"
		ini .= "`r`n"
	}
	local file := FileOpen(inipath, "w-d")
	file.Write(ini), file.Close()
}
nm_importHotbarGlobals()

; GUI position
if (ManualHBX && ManualHBY)
{
	Loop (MonitorCount := MonitorGetCount())
	{
		MonitorGetWorkArea A_Index, &MonLeft, &MonTop, &MonRight, &MonBottom
		if(ManualHBX>MonLeft && ManualHBX<MonRight && ManualHBY>MonTop && ManualHBY<MonBottom)
			break
		if(A_Index=MonitorCount)
			ManualHBX:=ManualHBY:=0
	}
}
else
	ManualHBX:=ManualHBY:=20

OnExit(nm_ManualHotbarExit)
;GUI
ManualHotbar := Gui("-Caption +Border +E0x00000088", "Manual Hotbar")
ManualHotbar.Show("x" ManualHBX " y" ManualHBY " w585 h30 NA")
(GuiCtrl := ManualHotbar.Add("Picture", "x0 y0 w15 h15", ".\nm_image_assets\auryn.ico")).OnEvent("Click", (*) => SendMessage(0xA1, 2))
GuiCtrl.OnEvent("ContextMenu", nm_toggleGuiMode)
ManualHotbar.SetFont("s20")
ManualHotbar.Add("Text", "xp y3", Chr(10799)).OnEvent("Click", (*) => (nm_ManualHotbarExit(), ExitApp())) ;Chr 10799 "⨯", close icon
ManualHotbar.SetFont("s8")
ManualHotbar.Add("Picture", "x570 y0 w15 h15 vUnlockButton Hidden", ".\nm_image_assets\unlock_icon.png").OnEvent("Click", nm_LockHotbar)
ManualHotbar.Add("Picture", "x570 y0 w15 h15 vLockButton", ".\nm_image_assets\lock_icon.png").OnEvent("Click", nm_UnlockHotbar)
ManualHotbar.Add("Button", "xp yp+15 w15 h15 vHelpButton", "?").OnEvent("Click", nm_ManualHotbarHelp)
ManualHotbar.Add("Button", "x15 y0 w30 h30 vToggleManualAll", "Start`nALL").OnEvent("Click", nm_ToggleManualAll)

ManualHotbar.SetFont("cRed Bold")
ManualHotbar.Add("Text", "x61 y1 cRED", "Disabled")
loop 6
    ManualHotbar.Add("Text", "xp+75 y1 cRED", "Disabled")
ManualHotbar.SetFont("cBlack Norm")

ManualHotbar.Add("CheckBox", "x46 y0 w13 h13 vManualHotbarArmed1 Checked" ManualHotbarArmed1).OnEvent("Click", nm_armManualHotbar)
Loop 6 
    ManualHotbar.Add("CheckBox", "xp+75 y0 w13 h13 vManualHotbarArmed" A_Index+1 " Checked" ManualHotbarArmed%(A_Index)%).OnEvent("Click", nm_armManualHotbar)

ManualHotbar.SetFont("w700")
ManualHotbar.Add("Edit", "x60 y0 w58 h15 vManualHotbarTimer1 Limit7 Center Disabled " (ManualHotbarArmed1 = 0 ? "Hidden" : ""), ManualHotbarTimer1 || 0).OnEvent("Change", nm_saveManualHotbar)
ManualHotbar.Add("Edit", "xp+75 y0 w58 h15 vManualHotbarTimer2 Limit7 Center Disabled " (ManualHotbarArmed2 = 0 ? "Hidden" : ""), ManualHotbarTimer2 || 0).OnEvent("Change", nm_saveManualHotbar)
ManualHotbar.Add("Edit", "xp+75 y0 w58 h15 vManualHotbarTimer3 Limit7 Center Disabled " (ManualHotbarArmed3 = 0 ? "Hidden" : ""), ManualHotbarTimer3 || 0).OnEvent("Change", nm_saveManualHotbar)
ManualHotbar.Add("Edit", "xp+75 y0 w58 h15 vManualHotbarTimer4 Limit7 Center Disabled " (ManualHotbarArmed4 = 0 ? "Hidden" : ""), ManualHotbarTimer4 || 0).OnEvent("Change", nm_saveManualHotbar)
ManualHotbar.Add("Edit", "xp+75 y0 w58 h15 vManualHotbarTimer5 Limit7 Center Disabled " (ManualHotbarArmed5 = 0 ? "Hidden" : ""), ManualHotbarTimer5 || 0).OnEvent("Change", nm_saveManualHotbar)
ManualHotbar.Add("Edit", "xp+75 y0 w58 h15 vManualHotbarTimer6 Limit7 Center Disabled " (ManualHotbarArmed6 = 0 ? "Hidden" : ""), ManualHotbarTimer6 || 0).OnEvent("Change", nm_saveManualHotbar)
ManualHotbar.Add("Edit", "xp+75 y0 w58 h15 vManualHotbarTimer7 Limit7 Center Disabled " (ManualHotbarArmed7 = 0 ? "Hidden" : ""), ManualHotbarTimer7 || 0).OnEvent("Change", nm_saveManualHotbar)
ManualHotbar.SetFont("Norm")
ManualHotbar.Add("Button", "x46 y15 w73 h15 vManualHotbarButton1", "Start 1").OnEvent("Click", nm_toggleManualHotbar)
ManualHotbar.Add("Button", "xp+75 y15 w73 h15 vManualHotbarButton2", "Start 2").OnEvent("Click", nm_toggleManualHotbar)
ManualHotbar.Add("Button", "xp+75 y15 w73 h15 vManualHotbarButton3", "Start 3").OnEvent("Click", nm_toggleManualHotbar)
ManualHotbar.Add("Button", "xp+75 y15 w73 h15 vManualHotbarButton4", "Start 4").OnEvent("Click", nm_toggleManualHotbar)
ManualHotbar.Add("Button", "xp+75 y15 w73 h15 vManualHotbarButton5", "Start 5").OnEvent("Click", nm_toggleManualHotbar)
ManualHotbar.Add("Button", "xp+75 y15 w73 h15 vManualHotbarButton6", "Start 6").OnEvent("Click", nm_toggleManualHotbar)
ManualHotbar.Add("Button", "xp+75 y15 w73 h15 vManualHotbarButton7", "Start 7").OnEvent("Click", nm_toggleManualHotbar)


ManualHotbar.OnEvent("Close", (*) => ExitApp())
ManualHotbar.SetFont("s8 cDefault w1000", "Tahoma")
OnMessage 0x0102, WM_CHAR
;; Add Placeholders "Delay"
loop 7
    PostMessage 0x1501 , 1 , StrPtr("Delay") , ManualHotbar["ManualHotbarTimer" A_Index]

;initialize countdown timers
ManualHotbarCountdown1:=ManualHotbarTimer1
ManualHotbarCountdown2:=ManualHotbarTimer2
ManualHotbarCountdown3:=ManualHotbarTimer3
ManualHotbarCountdown4:=ManualHotbarTimer4
ManualHotbarCountdown5:=ManualHotbarTimer5
ManualHotbarCountdown6:=ManualHotbarTimer6
ManualHotbarCountdown7:=ManualHotbarTimer7
ManualHotbarButton1:=ManualHotbarButton2:=ManualHotbarButton3:=ManualHotbarButton4:=ManualHotbarButton5:=ManualHotbarButton6:=ManualHotbarButton7:=0

;main loop
DllCall("QueryPerformanceFrequency", "int64p", &f:=0)
loop {
    DllCall("QueryPerformanceCounter", "int64p", &s:=0)
    loop 7
        ManualHotbarArmed%A_Index% && ManualHotbarButton%A_Index% && nm_ManualHotbar(A_Index)
    DllCall("QueryPerformanceCounter", "int64p", &e:=0)
    DllCall("timeBeginPeriod", "uint", 5)
    DllCall("Sleep", "uint", 100 - (e - s) * 1000 // f)
    DllCall("timeEndPeriod", "uint", 5)
}

nm_ManualHotbarHelp(*){
MsgBox "
(
DESCRIPTION:
The Manual Hotbar will automatically press your actionbar buttons at the specified interval (in seconds).

HOW TO CONFIGURE:
1) Click on the cooresponding checkbox for each key that is to be pressed automatically.
2) Unlock/Lock the interval settings by pressing the padlock icon in the upper right corner.
3) Enter the interval (in seconds) for each actionbar key.

HOW TO START/STOP:
* Individual buttons can be start/stopped by pressing the corresponding button below.
* Alternatively, ALL checked buttons can be start/stopped by pressing the "Start ALL" button on the left side of the GUI.

HOW TO MOVE GUI:
Click-and-hold on the Auryn icon in the upper left corner.
Right-click on the Auryn icon to hide the GUI.

RECOMMENDED PLACEMENT:
The GUI is designed to fit just under your actionbar buttons.
)", "Manual Hotbar Help", 0x40000
}

nm_LockHotbar(*){
    global
    if (ManualHotbarButton1 && ManualHotbarButton2 && ManualHotbarButton3 && ManualHotbarButton4 && ManualHotbarButton5 && ManualHotbarButton6 && ManualHotbarButton7) or (!ManualHotbarArmed1 && !ManualHotbarArmed2 && !ManualHotbarArmed3 && !ManualHotbarArmed4 && !ManualHotbarArmed5 && !ManualHotbarArmed6 && !ManualHotbarArmed7)
        return
    ManualHotbar["UnlockButton"].Visible :=0
    ManualHotbar["LockButton"].Visible :=1
    loop 7
        ManualHotbar["ManualHotbarTimer" A_Index].Enabled := 0
}
nm_UnlockHotbar(*){
    global
    if (ManualHotbarButton1 && ManualHotbarButton2 && ManualHotbarButton3 && ManualHotbarButton4 && ManualHotbarButton5 && ManualHotbarButton6 && ManualHotbarButton7) or (!ManualHotbarArmed1 && !ManualHotbarArmed2 && !ManualHotbarArmed3 && !ManualHotbarArmed4 && !ManualHotbarArmed5 && !ManualHotbarArmed6 && !ManualHotbarArmed7)
        return
    ManualHotbar["LockButton"].Visible :=0
    ManualHotbar["UnlockButton"].Visible :=1
    loop 7
        if !ManualHotbarButton%A_Index%
            ManualHotbar["ManualHotbarTimer" A_Index].Enabled := 1
    WinActivate "Manual Hotbar"
}

nm_saveManualHotbarGui(*){
	wp := Buffer(44)
    DllCall("GetWindowPlacement", "UInt", ManualHotbar.Hwnd, "Ptr", wp)
	x := NumGet(wp, 28, "Int"), y := NumGet(wp, 32, "Int")
	if (x > 0)
		IniWrite x, "settings\manual_hotbar.ini", "ManualHotbar", "ManualHBX"
	if (y > 0)
		IniWrite y, "settings\manual_hotbar.ini", "ManualHotbar", "ManualHBY"
}

nm_ManualHotbarExit(*){
    nm_saveManualHotbarGui()
    DllCall(A_WorkingDir "\nm_image_assets\Styles\USkin.dll\USkinExit")
}

nm_ManualHotbar(num, *){
    global
    ManualHotbarCountdown%num% -= 0.1
    if(ManualHotbarCountdown%num%<=0.1) {
        ManualHotbarCountdown%num% := ManualHotbarTimer%num%
        send "{sc00" num+1 "}"
    }
    ManualHotbar["ManualHotbarTimer" num].Text := Round(ManualHotbarCountdown%num%,1)
}

nm_ToggleManualAll(GuiCtrl, *){
    ;toggle on
    global
    local startNum := 0
    if(GuiCtrl.Text = "Start`nAll" && ((ManualHotbarButton1=0 && ManualHotbarArmed1) || (ManualHotbarButton2=0 && ManualHotbarArmed2) || (ManualHotbarButton3=0 && ManualHotbarArmed3) || (ManualHotbarButton4=0 && ManualHotbarArmed4) || (ManualHotbarButton5=0 && ManualHotbarArmed5) || (ManualHotbarButton6=0 && ManualHotbarArmed6) || (ManualHotbarButton7=0 && ManualHotbarArmed7))) {
        GuiCtrl.Text := "Stop`nAll"
        loop 7 {
            if(!ManualHotbarButton%A_Index% && ManualHotbarArmed%A_Index%)
                startNum += nm_ToggleManualHotbar(ManualHotbar["ManualHotbarButton" A_Index], -1)
        }
        if !startNum
            GuiCtrl.Text := "Start`nAll"
    }
    ;toggle off
    else if (GuiCtrl.Text = "Stop`nAll") {
        GuiCtrl.Text := "Start`nAll"
        loop 7 {
            if(ManualHotbarButton%A_Index%)
                nm_ToggleManualHotbar(ManualHotbar["ManualHotbarButton" A_Index])
        }
    }
    nm_LockHotbar()
    ActivateRoblox()
}

nm_ToggleManualHotbar(GuiCtrl, param?,*){
    global
    num := SubStr(GuiCtrl.Name, -1)
    if(!ManualHotbarButton%num% && ManualHotbarArmed%num%) {
        if !ManualHotbar["ManualHotbarTimer" num].Value
            if IsSet(param) && param == -1
                return 0
            else return msgbox("Cant start a timer with 0 seconds",,0x40010)
        ManualHotbar["ManualHotbarButton" num].Text := ("Stop " . num)
        ManualHotbar["ToggleManualAll"].Text := "Stop`nAll"
        ManualHotbarButton%num% := 1
        ;ManualHotbar["ManualHotbarTimer" num].Enabled := 0
        ManualHotbarCountdown%num%:=ManualHotbarTimer%num%
        return 1
    } else {
        ManualHotbar["ManualHotbarButton" num].Text := ("Start " . num)
        ManualHotbarButton%num% := 0
        ;ManualHotbar["ManualHotbarTimer" num].Enabled := 1
        ManualHotbar["ManualHotbarTimer" num].Text := ManualHotbarTimer%num%
        if(!ManualHotbarButton1 && !ManualHotbarButton2 && !ManualHotbarButton3 && !ManualHotbarButton4 && !ManualHotbarButton5 && !ManualHotbarButton6 && !ManualHotbarButton7){
            ManualHotbar["ToggleManualAll"].Text := "Start`nAll"
        }
    }
    nm_LockHotbar()
    ActivateRoblox()
}
nm_armManualHotbar(GuiCtrl, *){
    global
    num := SubStr(GuiCtrl.Name, -1)
    nm_saveManualHotbar(GuiCtrl)

    if(ManualHotbarArmed%num%=1) 
        ManualHotbar["ManualHotbarTimer" num].Visible := 1
    else {
        ManualHotbar["ManualHotbarTimer" num].Visible := 0
        if(ManualHotbarButton%num%) {
            ManualHotbar["ManualHotbarButton" num].Text := "Start " num
            ManualHotbarButton%num% := 0
            ManualHotbarCountdown%num%:=ManualHotbarTimer%num%
            ManualHotbar["ManualHotbarTimer" num].Text := ManualHotbarTimer%num%
            ManualHotbar["ManualHotbarTimer" num].Enabled := 1
        }
    }
}

nm_saveManualHotbar(GuiCtrl, *) {
	global
    if (GuiCtrl.type = "Edit" && !(GuiCtrl.Value ~= '^\d*(\.\d?)?$')) {
        nm_showErrorBalloonTip(GuiCtrl, "Invalid Input", "Only numbers with one decimal place are allowed")
        GuiCtrl.Value := %GuiCtrl.Name%
        return
    }
    %GuiCtrl.Name% := GuiCtrl.Value
	IniWrite GuiCtrl.Value, "settings\manual_hotbar.ini", "ManualHotbar", GuiCtrl.Name
}
nm_toggleGuiMode(*) {
    static GuiHidden := 0
    ManualHotbar.Show((GuiHidden := !GuiHidden) ? "w15 h15" : "w585 h30")
}
nm_showErrorBalloonTip(ctrl, Title, text) {
    Buf := Buffer(4 * A_PtrSize, 0)
    NumPut("uint", 4*A_PtrSize,
            "ptr", StrPtr(Title),
            "ptr", StrPtr(text),
            "uint", 3, Buf)
    SendMessage(0x1503, 0, Buf, ctrl)
}
WM_CHAR(a*) {
    if a[3] != 0x0102 || !a[4]
        return
    if !(a[1] = 0x8 || a[1] = 0x2E || (a[1] > 0x2f && a[1] < 0x3A))
        return nm_showErrorBalloonTip(ManualHotbar[a[4]], "Invalid Input", "Only numbers are allowed") || 0
}