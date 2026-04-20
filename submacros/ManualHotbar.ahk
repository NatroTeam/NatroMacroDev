/*
Natro Macro (https://github.com/NatroTeam/NatroMacro)
Copyright © Natro Team (https://github.com/NatroTeam)

This file is part of Natro Macro. Our source code will always be open and available.

Natro Macro is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

Natro Macro is distributed in the hope that it will be useful. This does not give you the right to steal sections from our code, distribute it under your own name, then slander the macro.

You should have received a copy of the license along with Natro Macro. If not, please redownload from an official source.
*/

#MaxThreads 255
#Requires AutoHotkey v2.0
#SingleInstance Force
#Warn VarUnset, Off

#Include "%A_ScriptDir%\..\lib"
#Include "Roblox.ahk"
#Include "ReadIni.ahk"
#Include "ErrorHandling.ahk"

SendMode "Event"
DetectHiddenWindows 1
SetWorkingDir A_ScriptDir "\.."
TraySetIcon "nm_image_assets\auryn.ico"

OnExit(nm_ManualHotbarExit)


nm_ManualHotbarExit(*){
    nm_saveManualHotbarGui()
    DllCall(A_WorkingDir "\nm_image_assets\Styles\USkin.dll\USkinExit")
}

; check for the correct AHK version before starting
if (A_PtrSize != 4)
{
    SplitPath(A_AhkPath, , &ahkDirectory)

    if (!FileExist(ahkPath := ahkDirectory "\AutoHotkey32.exe"))
        MsgBox "Could not find the 32-bit version of Autohotkey in:`n" ahkPath, "Error", 0x10
    else
        ReloadScript(ahkpath)

    ExitApp
}

ReloadScript(ahkpath)
{
	cmd := DllCall("GetCommandLine", "Str")
    params := DllCall("shlwapi\PathGetArgs", "Str", cmd, "Str")

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
		, "ManualHotbarEnabled1", 0
		, "ManualHotbarEnabled2", 0
		, "ManualHotbarEnabled3", 0
		, "ManualHotbarEnabled4", 0
		, "ManualHotbarEnabled5", 0
		, "ManualHotbarEnabled6", 0
		, "ManualHotbarEnabled7", 0
        , "ManualHotbarTutorial", 0)

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
;GUI
ManualHotbar := Gui("-Caption +Border +E0x00000088 +OwnDialogs", "Manual Hotbar")

MenuWidth := 54
Width := 579
Height := 50

BoxWidth := MenuWidth//3
CurrentX := 1

; natro icon and window control
(GuiCtrl := ManualHotbar.Add("Picture", "x" CurrentX " y0 w" BoxWidth-3 " h" BoxWidth-3, ".\nm_image_assets\auryn.ico")).OnEvent("Click", (*) => SendMessage(0xA1, 2))
GuiCtrl.OnEvent("ContextMenu", nm_toggleGuiMode)

; help icon
ManualHotbar.SetFont("s9 Bold"), CurrentX := BoxWidth, offset := -1 ; offset due to text being rendered a bit to the right, also iucon doesnt take up 100% of width
ManualHotbar.Add("Text", "x" CurrentX+offset " y1 Center w" BoxWidth, "?").OnEvent("Click", nm_ManualHotbarHelp)

; close icon
ManualHotbar.SetFont("s20 Norm") , CurrentX := BoxWidth*2
ManualHotbar.Add("Text", "x" CurrentX " yp-12", Chr(10799)).OnEvent("Click", (*) => (nm_ManualHotbarExit(), ExitApp())) ;Chr 10799 "⨯", close icon

; start button
ManualHotbar.SetFont("s8"), CurrentX := 1, BoxWidth *= 3, offset := -2 ; offset to center 
ManualHotbar.Add("Button", "x1 y17 w" BoxWidth+offset " h33 vToggleManualAll", "Start`nAll").OnEvent("Click", (GuiCtrl, *) => nm_ToggleAll((GuiCtrl.Text = "Start`nAll")))

; dividers
ManualHotbar.Add("Text", "x0 y15 w579 h1 0x7") ;vertical line
ManualHotbar.Add("Text", "x" MenuWidth " y0 w1 h50 0x7") ;horz line

; hotbar stuff
loop 7
{
    i := A_Index
    x := 55 + (A_Index - 1) * 75
    
    ManualHotbar.SetFont("s8 w700")
    ManualHotbar.Add("Text", "x" x " y0 w73 h13 Center +BackgroundTrans", "Slot " i)
    
    ManualHotbar.SetFont("cRed Bold")
    ManualHotbar.Add("Text", "x" (x + 15) " y18 cRED vManualHotbarDisabledText" i " " (ManualHotbarEnabled%i% ? "Hidden" : ""), "Disabled").OnEvent("Click", ((GuiCtrl, *) => nm_enableManualHotbarSlot(SubStr(GuiCtrl.Name, -1), GuiCtrl.Visible)))
    ManualHotbar.SetFont("cBlack Norm")
    
    ManualHotbar.Add("CheckBox", "x" x " y18 w13 h13 vManualHotbarEnabled" i " Checked" ManualHotbarEnabled%i%).OnEvent("Click", ((GuiCtrl, *) => nm_enableManualHotbarSlot(SubStr(GuiCtrl.Name, -1), GuiCtrl.Value)))
    
    ; box around timer
    ManualHotbar.SetFont("cBlue")
    loop 2 {
        ManualHotbar.Add("Text", "x" (x+17) " y" 17 + ( A_Index-1 ) * 14 " w56 h1 0x7 vDivider" A_Index "-" i " " (ManualHotbarEnabled%i% = 0 ? "Hidden" : "")) ;divider (1-4)-(1-7)
        ManualHotbar.Add("Text", "x" (x+17) + ( A_Index-1 ) * 55 " y17 w1 h14 0x7 vDivider" A_Index+2 "-" i " " (ManualHotbarEnabled%i% = 0 ? "Hidden" : ""))
    }
    ManualHotbar.SetFont("cBlack w700")

    (GuiCtrl := ManualHotbar.Add("Text", "x" (x + 14) " y17 w58 h15 vManualHotbarTimer" i " Center +BackgroundTrans " (ManualHotbarEnabled%i% = 0 ? "Hidden" : ""), ManualHotbarTimer%i% || 0)).OnEvent("DoubleClick", nm_EditHotbarInterval)
    
    ManualHotbar.SetFont("Norm")
    ManualHotbar.Add("Button", "x" x " y35 w73 h15 vManualHotbarStarted" i " " (!ManualHotbarEnabled%i% ? "Disabled" : ""), "Start").OnEvent("Click", (GuiCtrl, *) => nm_ToggleHotbarSlot(SubStr(GuiCtrl.Name, -1), (GuiCtrl.Text = "Start" ? 1 : 0)))
}

ManualHotbar.OnEvent("Close", (*) => ExitApp())
ManualHotbar.Show("x" ManualHBX " y" ManualHBY " w" Width " h" Height " NA")

; required because the variables are referenced dynamically AND loaded dynamically
ManualHotbarEnabled1:=ManualHotbarEnabled1, ManualHotbarEnabled2:=ManualHotbarEnabled2, ManualHotbarEnabled3:=ManualHotbarEnabled3, ManualHotbarEnabled4:=ManualHotbarEnabled4, ManualHotbarEnabled5:=ManualHotbarEnabled5, ManualHotbarEnabled6:=ManualHotbarEnabled6, ManualHotbarEnabled7:=ManualHotbarEnabled7
ManualHotbarCountdown1 := ManualHotbarTimer1, ManualHotbarCountdown2 := ManualHotbarTimer2, ManualHotbarCountdown3 := ManualHotbarTimer3, ManualHotbarCountdown4 := ManualHotbarTimer4, ManualHotbarCountdown5 := ManualHotbarTimer5, ManualHotbarCountdown6 := ManualHotbarTimer6, ManualHotbarCountdown7 := ManualHotbarTimer7
ManualHotbarStarted1 := ManualHotbarStarted2 := ManualHotbarStarted3 := ManualHotbarStarted4 := ManualHotbarStarted5 := ManualHotbarStarted6 := ManualHotbarStarted7 := 0

if !ManualHotbarTutorial
    nm_ManualHotbarHelp()
; Main Loop
DllCall("QueryPerformanceFrequency", "int64p", &f:=0)
loop
{
    DllCall("QueryPerformanceCounter", "int64p", &s:=0)
    
    loop 7
        if ManualHotbarEnabled%A_Index% && ManualHotbarStarted%A_Index%
            nm_ManualHotbar(A_Index)
    
    loop
    {
        DllCall("QueryPerformanceCounter", "int64p", &e:=0)
        if ((e - s) * 1000 // f >= 100)
            break
    }
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; GUI functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

nm_ManualHotbarHelp(*){
    MsgBox "
    (
    DESCRIPTION:
    The Manual Hotbar will automatically press your hotbar slot buttons at the specified interval (in seconds).

    HOW TO CONFIGURE:
    1) Click on the cooresponding checkbox for each key that is to be pressed automatically.
    2) Double click the number to edit the interaval of the item.
    3) Enter the interval (in seconds) for each hotbar slot key.

    HOW TO START/STOP:
    * Individual buttons can be start/stopped by pressing the Start/Stop button.
    * Alternatively, all checked buttons can be started/stopped by pressing the "Start All" button.

    HOW TO MOVE GUI:
    Click-and-hold on the Auryn icon in the upper left corner.
    Right-click on the Auryn icon to minimize the GUI.

    RECOMMENDED PLACEMENT:
    The GUI is designed to fit just under your actionbar buttons.
    )" . (!ManualHotbarTutorial ? "
    (
    `n
    NOTE:
    This message will only be shown once, but you can access it again by clicking the "?" button.
    )" : ""), "Manual Hotbar Help", 0x40000

    if !ManualHotbarTutorial
        IniWrite 1, "settings\manual_hotbar.ini", "ManualHotbar", "ManualHotbarTutorial"
}

nm_saveManualHotbarGui(*){
    try {
        WinGetPos(&x, &y, , , "ahk_id" ManualHotbar.hwnd)
        if (x > 0)
            IniWrite x, "settings\manual_hotbar.ini", "ManualHotbar", "ManualHBX"
        if (y > 0)
            IniWrite y, "settings\manual_hotbar.ini", "ManualHotbar", "ManualHBY"
    }   
}

nm_toggleGuiMode(*)
{
    static GuiHidden := 0
    ManualHotbar.Show((GuiHidden := !GuiHidden) ? "w17 h15" : "w" Width "h" Height)
}

nm_EditHotbarInterval(GuiCtrl, *){
    num := SubStr(GuiCtrl.Name, -1)
    
    if ManualHotbarStarted%num%
        return

    previousText := GuiCtrl.Text
    GuiCtrl.Text := ""
    input := InputHook("B1 L5 T10", "{Enter}{Esc}{Space}wasd,.")
    input.OnChar := checkNum
    input.OnEnd := checkReason
    input.KeyOpt("{All}", "+I")
    input.KeyOpt("1,2,3,4,5,6,7,8,9,0", "-I")
    input.Start()
    Tooltip "Start typing to change interval in seconds. Press Enter to save..."
    input.Wait()
    Tooltip ""

    checkNum(input, char){
        if IsNumber(char){
            GuiCtrl.Text := input.Input
        }
    }
    checkReason(input){
        if input.EndReason = "EndKey" 
            if input.EndKey != "Enter"
                return GuiCtrl.Text := previousText
        if input.EndReason = "Timeout"
            return GuiCtrl.Text := previousText

        GuiCtrl.Text := Number(GuiCtrl.Text)

        if !GuiCtrl.Text
            nm_DisableSlot(num)
    }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Manual Hotbar functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

nm_ManualHotbar(num, *){
    global
    ManualHotbarCountdown%num% -= 0.1
    if ManualHotbarCountdown%num% <= 0.1
    {
        ManualHotbarCountdown%num% := ManualHotbarTimer%num%
        send "{sc00" num+1 "}"
    }
    ManualHotbar["ManualHotbarTimer" num].Text := Round(ManualHotbarCountdown%num%,1)
}

nm_ToggleAll(toggle) => (toggle ? nm_StartAll() : nm_StopAll())
nm_StopAll(){
    loop 7
        nm_stopHotbarSlot(A_Index)
}
nm_StartAll(){
    loop 7
        nm_startHotbarSlot(A_Index)
}

; starting
nm_ToggleHotbarSlot(num, toggle) => ( toggle ? nm_startHotbarSlot(num) : nm_stopHotbarSlot(num) )
nm_startHotbarSlot(num){
    global

    if !ManualHotbar["ManualHotbarTimer" num].Text || !ManualHotbarEnabled%num%
        return 0
    
    ManualHotbar["ManualHotbarStarted" num].Text := "Stop"
    ManualHotbarStarted%num% := 1
    ManualHotbarCountdown%num% := ManualHotbarTimer%num%
    ManualHotbar["ManualHotbarTimer" num].SetFont("cGreen")
    
    ManualHotbar["ToggleManualAll"].Text := "Stop`nAll"
    
    ActivateRoblox()
}

nm_stopHotbarSlot(num){
    global
    
    ManualHotbar["ManualHotbarStarted" num].Text := "Start"
    ManualHotbarStarted%num% := 0
    ManualHotbar["ManualHotbarTimer" num].Text := ManualHotbarTimer%num%
    ManualHotbar["ManualHotbarTimer" num].SetFont("cBlack")

    loop 7 {
        if ManualHotbarStarted%A_Index%
            break
        if A_Index = 7
            ManualHotbar["ToggleManualAll"].Text := "Start`nAll"
    }

    ActivateRoblox()
}

nm_enableManualHotbarSlot(index, toggle){
    nm_saveManualHotbar("ManualHotbarEnabled" index, toggle)
    nm_ToggleSlot(index, toggle)
}

; checkbox toggles
nm_ToggleSlot(num, toggle) => (toggle ? nm_EnableSlot(num) : nm_DisableSlot(num))
nm_DisableSlot(num){
    global
    ManualHotbar["ManualHotbarTimer" num].Visible := 0
    ManualHotbar["ManualHotbarDisabledText" num].Visible := 1
    ManualHotbar["ManualHotbarEnabled" num].Value := 0
    ManualHotbar["ManualHotbarStarted" num].Enabled := 0
    
    loop 4 {
        ManualHotbar["Divider" A_Index "-" num].Visible := 0
    }

    nm_stopHotbarSlot(num)
}

nm_EnableSlot(num){
    global
    ManualHotbar["ManualHotbarTimer" num].Visible := 1
    ManualHotbar["ManualHotbarDisabledText" num].Visible := 0
    ManualHotbar["ManualHotbarEnabled" num].Value := 1
    ManualHotbar["ManualHotbarStarted" num].Enabled := 1
    loop 4 {
        ManualHotbar["Divider" A_Index "-" num].Visible := 1
    }
}

nm_saveManualHotbar(name, value)
{
	global
	IniWrite (%name% := value), "settings\manual_hotbar.ini", "ManualHotbar", name
}
