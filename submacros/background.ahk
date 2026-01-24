/*
Natro Macro (https://github.com/NatroTeam/NatroMacro)
Copyright © Natro Team (https://github.com/NatroTeam)

This file is part of Natro Macro. Our source code will always be open and available.

Natro Macro is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

Natro Macro is distributed in the hope that it will be useful. This does not give you the right to steal sections from our code, distribute it under your own name, then slander the macro.

You should have received a copy of the license along with Natro Macro. If not, please redownload from an official source.
*/

;//todo: Lots of inefficient code here. Switch to PostMessages instead of writing to nm_config and general rewrites
#SingleInstance Force
#NoTrayIcon
#MaxThreads 255

#Include "%A_ScriptDir%\..\lib"
#Include "Gdip_All.ahk"
#Include "Gdip_ImageSearch.ahk"
#Include "Roblox.ahk"
#Include "DurationFromSeconds.ahk"
#Include "nowUnix.ahk"
#include "ErrorHandling.ahk"
SetWorkingDir A_ScriptDir "\.."

if (A_Args.Length = 0)
{
	msgbox "This script needs to be run by Natro Macro! You are not supposed to run it manually."
	ExitApp
}

;initialization
resetTime:=LastState:=LastConvertBalloon:=nowUnix()
state:=0
MacroState:=2
;NightLastDetected := A_Args[1] not in use
;VBLastKilled := A_Args[2] not in use
StingerCheck := A_Args[3]
;StingerDailyBonusCheck := A_Args[4] not in use
AnnounceGuidingStar := A_Args[5]
ReconnectInterval := A_Args[6]
ReconnectHour := A_Args[7]
ReconnectMin := A_Args[8]
EmergencyBalloonPingCheck := A_Args[9]
ConvertBalloon := A_Args[10]
NightMemoryMatchCheck := A_Args[11]
;LastNightMemoryMatch := A_Args[12] not in use

pToken := Gdip_Startup()
bitmaps := Map(), bitmaps.CaseSense := 0
#Include "%A_ScriptDir%\..\nm_image_assets\offset\bitmaps.ahk"
#Include "%A_ScriptDir%\..\nm_image_assets\night\bitmaps.ahk"

CoordMode "Pixel", "Screen"
DetectHiddenWindows 1

;OnMessages
OnExit((*) => ProcessClose(DllCall("GetCurrentProcessId")))
OnMessage(0x5552, nm_setGlobalInt, 255)
OnMessage(0x5553, nm_setGlobalStr, 255)
OnMessage(0x5554, nm_setGlobalNum, 255)
OnMessage(0x5555, nm_setState, 255)
OnMessage(0x5556, nm_sendHeartbeat)

loop {
	hwnd := GetRobloxHWND(), GetRobloxClientPos(hwnd), offsetY := GetYOffset(hwnd)
	nm_deathCheck()
	nm_guidCheck()
	nm_popStarCheck()
	nm_CheckNight()
	nm_backpackPercentFilter()
	nm_guidingStarDetect()
	nm_dailyReconnect()
	nm_EmergencyBalloon()
	sleep 1000
}

nm_setGlobalNum(wParam, lParam, *){
	Critical
	global resetTime, StingerCheck, LastConvertBalloon, NightMemoryMatchCheck
	static arr:=["resetTime", 0, 0, "StingerCheck", 0, "LastConvertBalloon", "NightMemoryMatchCheck", 0]

	try var := arr[wParam], %var% := lParam
	return 0
}

nm_setState(wParam, lParam, *){
	Critical
	global state, lastState
	state := wParam, LastState := lParam
	return 0
}

nm_deathCheck(){
	static LastDeathDetected:=0
	if (((nowUnix()-resetTime)>20) && ((nowUnix()-LastDeathDetected)>10)) {
		try
			result := ImageSearch(&FoundX, &FoundY, windowX+windowWidth//2, windowY+windowHeight//2, windowX+windowWidth, windowY+windowHeight, "*50 nm_image_assets\died.png")
		catch
			return
		if (result = 1) {
			if WinExist("natro_macro ahk_class AutoHotkey") {
				PostMessage 0x5555, 1, 1
				Send_WM_COPYDATA("You Died", "natro_macro ahk_class AutoHotkey")
			}
			LastDeathDetected := nowUnix()
		}
	}
}

nm_guidCheck(){
	global windowX, windowY, windowWidth, windowHeight, offsetY, state
	static LastFieldGuidDetected:=1, FieldGuidDetected:=0, confirm:=0
	try
		result := ImageSearch(&FoundX, &FoundY, windowX, windowY+offsetY+30, windowX+windowWidth, windowY+offsetY+90, "*50 nm_image_assets\boostguidingstar.png")
	catch
		return
	if (result = 1) { ;Guid Detected
		confirm:=0
		if ((FieldGuidDetected = 0) && (state = 1)) {
			FieldGuidDetected := 1
			if WinExist("natro_macro ahk_class AutoHotkey") {
				PostMessage 0x5555, 6, 1
				Send_WM_COPYDATA("Detected: Guiding Star Active", "natro_macro ahk_class AutoHotkey")
			}
			LastFieldGuidDetected := nowUnix()
		}
	}
	else if ((nowUnix() - LastFieldGuidDetected > 5) && FieldGuidDetected){
		confirm++
		if (confirm >= 5) {
			confirm:=0
			FieldGuidDetected := 0
			if WinExist("natro_macro ahk_class AutoHotkey") {
				PostMessage 0x5555, 6, 0
			}
		}
	}
}

nm_popStarCheck(){
	static HasPopStar:=0, PopStarActive:=0
	try
		result := ImageSearch(&FoundX, &FoundY, windowX + windowWidth//2 - 275, windowY + 3*windowHeight//4, windowX + windowWidth//2 + 275, windowY + windowHeight, "*30 nm_image_assets\popstar_counter.png")
	catch
		return
	if (result = 1) { ;Has Pop
		if (HasPopStar = 0){
			HasPopStar := 1
			if WinExist("natro_macro ahk_class AutoHotkey") {
				PostMessage 0x5555, 7, 1
			}
		}
		if (HasPopStar && (PopStarActive = 1)){
			PopStarActive := 0
			if WinExist("natro_macro ahk_class AutoHotkey") {
				PostMessage 0x5555, 8, 0
			}
			if WinExist("StatMonitor.ahk ahk_class AutoHotkey") {
				PostMessage 0x5556, 1, 0
			}
		}
	} else {
		if (HasPopStar && (PopStarActive = 0) && (state = 1)){
			PopStarActive := 1
			if WinExist("natro_macro ahk_class AutoHotkey") {
				PostMessage 0x5555, 8, 1
				;Send_WM_COPYDATA("Detected: Pop Star Active", "natro_macro ahk_class AutoHotkey")
			}
			if WinExist("StatMonitor.ahk ahk_class AutoHotkey") {
				PostMessage 0x5556, 1, 1
			}
		}
	}
}

nm_CheckNight() {
	static nightConfidence := 0, NightLastDetected := 0, LastNightState := 0
	; 0 = day, 1 = night, 2 = dusk
	night := 0


	if !StingerCheck && !NightMemoryMatchCheck
		return

	if !CheckBitmap("day", 6) {
		if CheckBitmap("night", 4) && nightConfidence < 6
			nightConfidence++
		else if  nightConfidence > 1
			nightConfidence -= 2
	}

	; max confidence (first trigger) or within 5 mins of last detection means night
	night := (nightConfidence >= 6 || nowUnix()-NightLastDetected < 300) ? 1 : (nightConfidence > 1 ? 2 : 0)
	;tooltip "confidence: " nightConfidence "`nnight: " night "/" LastNightState
	if night = 1 {
		nightConfidence := 0
		if (nowUnix()-NightLastDetected > 300 || nowUnix()-NightLastDetected < 0) {
			NightLastDetected := nowUnix()
			if WinExist("natro_macro ahk_class AutoHotkey") {
				PostMessage 0x5552, 368, night
				Send_WM_COPYDATA("Detected: Night", "natro_macro ahk_class AutoHotkey")
			}
		}
	}

	if (WinExist("PlanterTimers.ahk ahk_class AutoHotkey") && (LastNightState != night))
		PostMessage 0x5552, 367, night

	; prevent excessive postmessages
	LastNightState := night

	CheckBitmap(time, variation){
		try {
			pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY + windowHeight//2 "|" windowWidth "|" windowHeight//2)
			for , v in bitmaps[time] {
				if (Gdip_ImageSearch(pBMScreen, v,,,,,,4) = 1) {
					Gdip_DisposeImage(pBMScreen)
					return 1
				}
			}
			Gdip_DisposeImage(pBMScreen)
		}
		return 0
	}
}

nm_backpackPercent() {
    static LastBackpackPercent := ""

    ; structure=[red_min, red_max, cyan_min, cyan_max, percent]
    ; Using CYAN (green+blue) because it's translucent over different backgrounds
    static colors := [
        [0x00, 0x41, 0xFF86, 0xFFFF, 0],
        [0x41, 0x42, 0xFC85, 0xFF80, 5],
        [0x42, 0x44, 0xF984, 0xFE85, 10],
        [0x44, 0x47, 0xF582, 0xFB84, 15],
        [0x47, 0x4B, 0xF080, 0xF782, 20],
        [0x4B, 0x4F, 0xEA7D, 0xF280, 25],
        [0x4F, 0x55, 0xE37A, 0xEC7D, 30],
        [0x55, 0x5B, 0xDA76, 0xE57A, 35],
        [0x5B, 0x62, 0xD072, 0xDC76, 40],
        [0x62, 0x69, 0xC66D, 0xD272, 45],
        [0x69, 0x72, 0xBA68, 0xC86D, 50],
        [0x72, 0x7B, 0xAD62, 0xBC68, 55],
        [0x7B, 0x85, 0x9E5C, 0xAF62, 60],
        [0x85, 0x90, 0x8F55, 0xA05C, 65],
        [0x90, 0x9C, 0x7E4E, 0x9155, 70],
        [0x9C, 0xA9, 0x6C46, 0x804E, 75],
        [0xA9, 0xB6, 0x5A3F, 0x6E46, 80],
        [0xB6, 0xC4, 0x4637, 0x5D3F, 85],
        [0xC4, 0xD3, 0x322E, 0x4A37, 90],
        [0xD3, 0xE0, 0x0000, 0x342E, 95],
        [0xE0, 0xFF, 0x1000, 0x2427, 100]
    ]
    
    pColor := PixelGetColor(windowX + windowWidth//2 + 62, windowY + offsetY + 6)
	
    if pColor = 0xF70017
        BackpackPercent := 100

    else {
        r := (pColor >> 16) & 0xFF
        cyan := pColor & 0xFFFF
        
        BackpackPercent := 0
        for range in colors {
            if (r >= range[1] && r <= range[2] && cyan >= range[3] && cyan <= range[4]) {
                BackpackPercent := range[5]
                break
            }
        }
    }
    
    if (BackpackPercent != LastBackpackPercent && WinExist("natro_macro ahk_class AutoHotkey")) {
        PostMessage 0x5555, 4, BackpackPercent
        LastBackpackPercent := BackpackPercent
    }

    return BackpackPercent
}

nm_backpackPercentFilter(){
	static PackFilterArray:=[], LastBackpackPercentFiltered:="", i:=0, samplesize:=6 ;6 seconds (6 samples @ 1 sec intervals)

	;make room for new sample
	if(PackFilterArray.Length=samplesize){
		PackFilterArray.Pop()
	}
	;get new sample
	PackFilterArray.InsertAt(1, nm_backpackPercent())
	;calculate rolling average
	sum:=0
	for val in PackFilterArray {
		sum+=val
	}
	BackpackPercentFiltered:=Round(sum/PackFilterArray.Length)
	if ((i=0) && WinExist("StatMonitor.ahk ahk_class AutoHotkey")) {
		PostMessage 0x5557, BackpackPercentFiltered, 60 * A_Min + A_Sec
	}
	i:=Mod(i+1, 6)
	if (BackpackPercentFiltered != LastBackpackPercentFiltered) {
		if WinExist("natro_macro ahk_class AutoHotkey") {
			PostMessage 0x5555, 5, BackpackPercentFiltered
		}
		LastBackpackPercentFiltered := BackpackPercentFiltered
	}
}

nm_guidingStarDetect(){
	static LastGuidDetected:=0, fieldnames := ["PineTree", "Stump", "Bamboo", "BlueFlower", "MountainTop", "Cactus", "Coconut", "Pineapple", "Spider", "Pumpkin", "Dandelion", "Sunflower", "Clover", "Pepper", "Rose", "Strawberry", "Mushroom"]

	if ((AnnounceGuidingStar=0) || (nowUnix()-LastGuidDetected<10))
		return

	xi:=windowX+windowWidth//2
	yi:=windowY+windowHeight//2
	ww:=windowX+windowWidth
	wh:=windowY+windowHeight

	GSfound:=0
	Loop 2 {
		try
			result := ImageSearch(&FoundX, &FoundY, xi, yi, ww, wh, "*50 nm_image_assets\guiding_star_icon" A_Index ".png")
		catch
			return
		if (result = 1) {
			GSfound:=1
			break
		}
	}

	if(GSfound){
		for value in fieldnames {
			try
				result := ImageSearch(&FoundX, &FoundY, xi, yi, ww, wh, "*50 nm_image_assets\guiding_star_" value ".png")
			catch
				return
			if (result = 1) {
				if WinExist("natro_macro ahk_class AutoHotkey") {
					Send_WM_COPYDATA(value, "natro_macro ahk_class AutoHotkey", 1)
					LastGuidDetected := nowUnix()
					break
				}
			}
		}
	}
}

nm_dailyReconnect(){
	static LastDailyReconnect := 0
	if ((ReconnectHour = "") || (ReconnectMin = "") || (ReconnectInterval = "") || (nowUnix() - LastDailyReconnect < 60))
		return
	RChourUTC := Number(FormatTime(A_NowUTC, "HH"))
	RCminUTC := Number(FormatTime(A_NowUTC, "mm"))
	HourReady:=0
	Loop 24//ReconnectInterval
	{
		if (Mod(ReconnectHour+ReconnectInterval*(A_Index-1), 24)=RChourUTC)
		{
			HourReady:=1
			break
		}
	}
	if((Number(ReconnectMin)=RCminUTC) && HourReady && (MacroState = 2)) {
		LastDailyReconnect := nowUnix()
		if WinExist("natro_macro ahk_class AutoHotkey") {
			Send_WM_COPYDATA("Closing: Roblox, Daily Reconnect", "natro_macro ahk_class AutoHotkey")
			PostMessage 0x5557, 60
		}
	}
}

nm_EmergencyBalloon(){
	static LastEmergency:=0
	if ((EmergencyBalloonPingCheck = 1) && (ConvertBalloon != "Never") && (nowUnix() - LastEmergency > 60) && ((time := nowUnix() - LastConvertBalloon) > 2700) && (time < 3600))
	{
		if WinExist("natro_macro ahk_class AutoHotkey") {
			duration := DurationFromSeconds(time, "m'm' ss's'")
			Send_WM_COPYDATA("Detected: No Balloon Convert in " duration, "natro_macro ahk_class AutoHotkey")
			LastEmergency := nowUnix()
		}
	}
}

nm_sendHeartbeat(*){
	Critical
	if WinExist("Heartbeat.ahk ahk_class AutoHotkey") {
		PostMessage 0x5556, 2
	}
	return 0
}

nm_setGlobalInt(wParam, lParam, *)
{
	global
	Critical
	; enumeration
	#Include "%A_ScriptDir%\..\lib\enum\EnumInt.ahk"

	local var := arr[wParam]
	try %var% := lParam
	return 0
}

nm_setGlobalStr(wParam, lParam, *)
{
	global
	Critical
	; enumeration
	#Include "%A_ScriptDir%\..\lib\enum\EnumStr.ahk"
	static sections := ["Boost","Collect","Gather","Planters","Quests","Settings","Status","Blender","Shrine"]

	local var := arr[wParam], section := sections[lParam]
	try %var% := IniRead("settings\nm_config.ini", section, var)
	return 0
}

Send_WM_COPYDATA(StringToSend, TargetScriptTitle, wParam:=0)
{
    CopyDataStruct := Buffer(3*A_PtrSize)
    SizeInBytes := (StrLen(StringToSend) + 1) * 2
    NumPut("Ptr", SizeInBytes
		, "Ptr", StrPtr(StringToSend)
		, CopyDataStruct, A_PtrSize)

	try
		s := SendMessage(0x004A, wParam, CopyDataStruct,, TargetScriptTitle)
	catch
		return -1
	else
		return s
}
