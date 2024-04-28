/*
Natro Macro (https://github.com/NatroTeam/NatroMacro)
Copyright © Natro Team (https://github.com/NatroTeam)

This file is part of Natro Macro. Our source code will always be open and available.

Natro Macro is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

Natro Macro is distributed in the hope that it will be useful. This does not give you the right to steal sections from our code, distribute it under your own name, then slander the macro.

You should have received a copy of the license along with Natro Macro. If not, please redownload from an official source.
*/

#SingleInstance Force

#Include "%A_ScriptDir%\..\lib\Roblox.ahk"
#Warn VarUnset, Off

OnError (e, mode) => (mode = "Return") ? -1 : 0
DetectHiddenWindows 1
SetWorkingDir A_ScriptDir "\.."
TraySetIcon "nm_image_assets\auryn.ico"

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
		, "ManualHotbarArmed7", 0
		, "ManualHotbarButton1", 0
		, "ManualHotbarButton2", 0
		, "ManualHotbarButton3", 0
		, "ManualHotbarButton4", 0
		, "ManualHotbarButton5", 0
		, "ManualHotbarButton6", 0
		, "ManualHotbarButton7", 0)

	local k, v, i, j
	for k,v in ManualHotbarGlobals ; load the default values as globals, will be overwritten if a new value exists when reading
		for i,j in v
			%i% := j

	local inipath := A_WorkingDir "\settings\manual_hotbar.ini"

	if FileExist(inipath)
		nm_ReadMHBIni(inipath)

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

nm_ReadMHBIni(path)
{
	global
	local ini, str, c, p, k, v

	ini := FileOpen(path, "r"), str := ini.Read(), ini.Close()
	Loop Parse str, "`n", "`r" A_Space A_Tab
	{
		switch (c := SubStr(A_LoopField, 1, 1))
		{
			; ignore comments and section names
			case "[",";":
			continue

			default:
			if (p := InStr(A_LoopField, "="))
				try k := SubStr(A_LoopField, 1, p-1), %k% := IsInteger(v := SubStr(A_LoopField, p+1)) ? Integer(v) : v
		}
	}
}

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
ManualHotbar := Gui("+AlwaysOnTop -Caption +Border +minsize30x15 +E0x08040000 +lastfound -MinimizeBox", "Manual Hotbar")
ManualHotbar.Show("x" ManualHBX " y" ManualHBY " w585 h30")
(GuiCtrl := ManualHotbar.Add("Picture", "x0 y0 w15 h15", ".\nm_image_assets\auryn.ico")).OnEvent("Click", (*) => SendMessage(0xA1, 2))
GuiCtrl.OnEvent("ContextMenu", nm_toggleGuiMode)
ManualHotbar.Add("Button", "xp yp+15 w15 h15 vHelpButton", "?").OnEvent("Click", nm_ManualHotbarHelp)
ManualHotbar.Add("Picture", "x570 y0 w15 h15 vUnlockButton", ".\nm_image_assets\unlock_icon.png").OnEvent("Click", nm_LockHotbar)
ManualHotbar.Add("Picture", "x570 y0 w15 h15 vLockButton Hidden", ".\nm_image_assets\lock_icon.png").OnEvent("Click", nm_UnlockHotbar)
ManualHotbar.Add("Button", "x15 y0 w30 h30 vToggleManualAll", "Start`nALL").OnEvent("Click", nm_ToggleManualAll)

ManualHotbar.Add("GroupBox", "x45 y-6 w75 h36 Section")
ManualHotbar.Add("GroupBox", "xp+75 yp w75 h36 Section")
ManualHotbar.Add("GroupBox", "xp+75 yp w75 h36 Section")
ManualHotbar.Add("GroupBox", "xp+75 yp w75 h36 Section")
ManualHotbar.Add("GroupBox", "xp+75 yp w75 h36 Section")
ManualHotbar.Add("GroupBox", "xp+75 yp w75 h36 Section")
ManualHotbar.Add("GroupBox", "xp+75 yp w75 h36 Section")
ManualHotbar.Add("Text", "x61 y1 cRED", "DISABLED")
ManualHotbar.Add("Text", "xp+75 y1 cRED", "DISABLED")
ManualHotbar.Add("Text", "xp+75 y1 cRED", "DISABLED")
ManualHotbar.Add("Text", "xp+75 y1 cRED", "DISABLED")
ManualHotbar.Add("Text", "xp+75 y1 cRED", "DISABLED")
ManualHotbar.Add("Text", "xp+75 y1 cRED", "DISABLED")
ManualHotbar.Add("Text", "xp+75 y1 cRED", "DISABLED")
ManualHotbar.Add("CheckBox", "x46 y0 w13 h13 vManualHotbarArmed1 Checked" ManualHotbarArmed1).OnEvent("Click", nm_armManualHotbar)
ManualHotbar.Add("CheckBox", "xp+75 y0 w13 h13 vManualHotbarArmed2 Checked" ManualHotbarArmed2).OnEvent("Click", nm_armManualHotbar)
ManualHotbar.Add("CheckBox", "xp+75 y0 w13 h13 vManualHotbarArmed3 Checked" ManualHotbarArmed3).OnEvent("Click", nm_armManualHotbar)
ManualHotbar.Add("CheckBox", "xp+75 y0 w13 h13 vManualHotbarArmed4 Checked" ManualHotbarArmed4).OnEvent("Click", nm_armManualHotbar)
ManualHotbar.Add("CheckBox", "xp+75 y0 w13 h13 vManualHotbarArmed5 Checked" ManualHotbarArmed5).OnEvent("Click", nm_armManualHotbar)
ManualHotbar.Add("CheckBox", "xp+75 y0 w13 h13 vManualHotbarArmed6 Checked" ManualHotbarArmed6).OnEvent("Click", nm_armManualHotbar)
ManualHotbar.Add("CheckBox", "xp+75 y0 w13 h13 vManualHotbarArmed7 Checked" ManualHotbarArmed7).OnEvent("Click", nm_armManualHotbar)
ManualHotbar.SetFont("w700")
ManualHotbar.Add("Edit", "x60 y0 w58 h15 vManualHotbarTimer1 Number Limit7 Center Disabled " (ManualHotbarArmed1 = 0 ? "Hidden" : ""), ManualHotbarTimer1).OnEvent("Change", nm_saveManualHotbar)
ManualHotbar.Add("Edit", "xp+75 y0 w58 h15 vManualHotbarTimer2 Number Limit7 Center Disabled " (ManualHotbarArmed2 = 0 ? "Hidden" : ""), ManualHotbarTimer2).OnEvent("Change", nm_saveManualHotbar)
ManualHotbar.Add("Edit", "xp+75 y0 w58 h15 vManualHotbarTimer3 Number Limit7 Center Disabled " (ManualHotbarArmed3 = 0 ? "Hidden" : ""), ManualHotbarTimer3).OnEvent("Change", nm_saveManualHotbar)
ManualHotbar.Add("Edit", "xp+75 y0 w58 h15 vManualHotbarTimer4 Number Limit7 Center Disabled " (ManualHotbarArmed4 = 0 ? "Hidden" : ""), ManualHotbarTimer4).OnEvent("Change", nm_saveManualHotbar)
ManualHotbar.Add("Edit", "xp+75 y0 w58 h15 vManualHotbarTimer5 Number Limit7 Center Disabled " (ManualHotbarArmed5 = 0 ? "Hidden" : ""), ManualHotbarTimer5).OnEvent("Change", nm_saveManualHotbar)
ManualHotbar.Add("Edit", "xp+75 y0 w58 h15 vManualHotbarTimer6 Number Limit7 Center Disabled " (ManualHotbarArmed6 = 0 ? "Hidden" : ""), ManualHotbarTimer6).OnEvent("Change", nm_saveManualHotbar)
ManualHotbar.Add("Edit", "xp+75 y0 w58 h15 vManualHotbarTimer7 Number Limit7 Center Disabled " (ManualHotbarArmed7 = 0 ? "Hidden" : ""), ManualHotbarTimer7).OnEvent("Change", nm_saveManualHotbar)
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

;initialize countdown timers
ManualHotbarCountdown1:=ManualHotbarTimer1
ManualHotbarCountdown2:=ManualHotbarTimer2
ManualHotbarCountdown3:=ManualHotbarTimer3
ManualHotbarCountdown4:=ManualHotbarTimer4
ManualHotbarCountdown5:=ManualHotbarTimer5
ManualHotbarCountdown6:=ManualHotbarTimer6
ManualHotbarCountdown7:=ManualHotbarTimer7

;main loop
loop {
    loop 7
        ManualHotbarArmed%A_Index% && ManualHotbarButton%A_Index% && nm_ManualHotbar(A_Index)
    sleep 1000
}

nm_ManualHotbarHelp(*){
;msgbox "DESCRIPTION:`nThe Manual Hotbar will automatically press hotbar buttons at the specified interval (in seconds)`n", "Manual Hotbar Help"
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
    ManualHotbar["UnlockButton"].Visible :=0
    ManualHotbar["LockButton"].Visible :=1
    loop 7
        ManualHotbar["ManualHotbarTimer" A_Index].Enabled := 0
}
nm_UnlockHotbar(*){
    ManualHotbar["LockButton"].Visible :=0
    ManualHotbar["UnlockButton"].Visible :=1
    loop 7
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

    ManualHotbar["ManualHotbarTimer" num].Text := ManualHotbarCountdown%num%

    if(ManualHotbarCountdown%num%=0) {
        ManualHotbarCountdown%num% := ManualHotbarTimer%num%-1
        send "{sc00" num+1 "}"
    } else
        ManualHotbarCountdown%num%--
}

nm_ToggleManualAll(GuiCtrl, *){
    ;toggle on
    global
    if(GuiCtrl.Text = "Start`nAll" && ((ManualHotbarButton1=0 && ManualHotbarArmed1) || (ManualHotbarButton2=0 && ManualHotbarArmed2) || (ManualHotbarButton3=0 && ManualHotbarArmed3) || (ManualHotbarButton4=0 && ManualHotbarArmed4) || (ManualHotbarButton5=0 && ManualHotbarArmed5) || (ManualHotbarButton6=0 && ManualHotbarArmed6) || (ManualHotbarButton7=0 && ManualHotbarArmed7))) {
        GuiCtrl.Text := "Stop`nAll"
        loop 7 {
            if(!ManualHotbarButton%A_Index% && ManualHotbarArmed%A_Index%)
                nm_ToggleManualHotbar(ManualHotbar["ManualHotbarButton" A_Index])
        }
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
    if WinExist("ahk_id" GetRobloxHWND()) {
        WinActivate
    }
}

nm_ToggleManualHotbar(GuiCtrl, *){
    global
    num := SubStr(GuiCtrl.Name, -1)
    if(ManualHotbar["ManualHotbarButton" num].Text = ("Start " . num) && ManualHotbarArmed%num%) {
        ManualHotbar["ManualHotbarButton" num].Text := ("Stop " . num)
        ManualHotbar["ToggleManualAll"].Text := "Stop`nAll"
        ManualHotbarButton%num% := 1
        ;ManualHotbar["ManualHotbarTimer" num].Enabled := 0
        ManualHotbarCountdown%num%:=ManualHotbarTimer%num%
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
    if WinExist("ahk_id" GetRobloxHWND()) {
        WinActivate
    }
}
nm_armManualHotbar(GuiCtrl, *){
    global
    num := SubStr(GuiCtrl.Name, -1)
    nm_saveManualHotbar(GuiCtrl)

    if(ManualHotbarArmed%num%=1){
        ManualHotbar["ManualHotbarTimer" num].Opt("-Hidden")
    } else {
        ManualHotbar["ManualHotbarTimer" num].Opt("+Hidden")
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
    %GuiCtrl.Name% := GuiCtrl.Value
	IniWrite GuiCtrl.Value, "settings\manual_hotbar.ini", "ManualHotbar", GuiCtrl.Name
;msgbox GuiCtrl.Name " =" GuiCtrl.Value
}
nm_toggleGuiMode(*) {
    static GuiHidden := 0
    if GuiHidden := !GuiHidden
        ManualHotbar.Show("h15 w15")
    else
        ManualHotbar.Show("h30 w585")
}