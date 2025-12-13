/*
Natro Macro (https://github.com/NatroTeam/NatroMacro)
Copyright © Natro Team (https://github.com/NatroTeam)

This file is part of Natro Macro. Our source code will always be open and available.

Natro Macro is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

Natro Macro is distributed in the hope that it will be useful. This does not give you the right to steal sections from our code, distribute it under your own name, then slander the macro.

You should have received a copy of the license along with Natro Macro. If not, please redownload from an official source.
*/

#Requires AutoHotkey v2.0
#NoTrayIcon
#SingleInstance Force

#Include "%A_ScriptDir%\..\lib"
#Include "Gdip_All.ahk"
#Include "JSON.ahk"
#Include "Discord.ahk"
#Include "Socket.ahk"
#Include "nowUnix.ahk"
#Include "ErrorHandling.ahk"
#include "Auxiliary.ahk"

#Warn VarUnset, Off
SetWorkingDir A_ScriptDir "\.."

if (A_Args.Length = 0) {
	MsgBox "This script needs to be run by Natro Macro! You are not supposed to run it manually."
	ExitApp
}

;-----------------
; Initialize
;-----------------
; general
MacroState := 0
AccountType := A_Args[1]
; discord
discordMode := A_Args[2]
discordCheck := A_Args[3]
MainChannelCheck := A_Args[4]
MainChannelID := A_Args[5]
ReportChannelCheck := A_Args[6]
ReportChannelID := A_Args[7]
WebhookEasterEgg := A_Args[8]
DiscordUID := A_Args[9]
Webhook := A_Args[10]
BotToken := A_Args[11]
CommunicationChannelID := A_Args[12]
; Socket
IP := A_Args[13]
PortNumber := A_Args[14]
; general
CommunicationStyle := A_Args[15]
CommunicationID := (AccountType = "Main Acc" ? -1 : A_Args[16])
Connections := []
; override valuies
if BotToken != "" && CommunicationStyle = "Discord" && AccountType != "Main Acc"
	discordMode := 1
; misc
OnExit(ExitFunc)
OnMessage(0x5550, SelfReload)
OnMessage(0x5552, nm_setGlobalInt)
OnMessage(0x004A, SendMessageDiscord)
SetTimer Heartbeat, 1000

;-----------------
; Discord
;-----------------
ReadMessages() {
	static LastLoggedMessage := ""
	if MacroState != 2
		return {error: "Macro not running"}
	if CommunicationChannelID = 0 || BotToken = "" || CommunicationStyle != "Discord" || AccountType = "Main Acc"
		return {error: "Discord communication not set up"}

	messages := discord.GetRecentMessages(CommunicationChannelID)
	if !IsObject(messages) || messages = -1 || messages.Length = 0
		return {error: "No new messages"}

	for i, msg in messages {
		if msg["content"] = ""
			continue
		try {
			jsonObj := JSON.parse(msg["content"])
			if jsonObj.Count = 0
				continue
			return jsonObj
		} catch
			continue
	}
	return {error: "No valid JSON found"}
}

; natro_macro.ahk sends data here
SendMessageDiscord(wParam, lParam, *) {
	if Webhook = "" || CommunicationStyle != "Discord" || AccountType != "Main Acc"
		return
	try {
		StringAddress := NumGet(lParam + 2*A_PtrSize, "Ptr")
		StringText := StrGet(StringAddress)
	} catch
		return
	try jsonObj := JSON.parse(StringText)
	catch
		return
	if !IsObject(jsonObj)
		return
	payload := Map("content", JSON.Stringify(jsonObj))
	try  discord.SendMessageAPI(JSON.stringify(payload), "application/json", , Webhook)
	catch
		return
}

;-----------------
; Socket
;-----------------





;-----------------
; Function
;-----------------
GetMessages(*) {
	if MacroState != 2
		return 0
	if CommunicationStyle = "Discord" && AccountType != "Main Acc" {
		msg := ReadMessages()
		if !IsObject(msg) || msg.HasOwnProp("error")
			return 0
	} else
		return 0
	return msg
}

Interpreter(msg, *) {
	if !IsObject(msg) || msg.HasOwnProp("error")
		return
	DetectHiddenWindows 1
	try Send_WM_COPYDATA(JSON.stringify(msg), "natro_macro ahk_class AutoHotkey", 2)
	DetectHiddenWindows 0
}

SelfReload(*) { ; to refresh vals, it has to be ran by natro_macro.ahk
	Critical
	if (A_Args.Length > 0) {
		LastReload := A_Args[A_Args.Length] ; keep A_TickCount at the end
		if (IsNumber(LastReload) && (A_TickCount-LastReload < 5000)) {
			return
		}
	}
	exe_path64 := (A_Is64bitOS && FileExist("submacros\AutoHotkey64.exe")) ? (A_WorkingDir "\submacros\AutoHotkey64.exe") : A_AhkPath
	path := '"' exe_path64 '" /script "' A_WorkingDir '\submacros\Communicator.ahk" ', vars := ""
	for i, x in A_Args
		vars .= '"' (x = "" ? " " : A_Index = A_Args.Length ? A_TickCount : x) '" '
	Run path " " vars
	ExitApp
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

nm_setGlobalInt(wParam, lParam, *)
{
	global
	Critical
	local var
	; enumeration
	#Include %A_ScriptDir%\..\lib\enum\EnumInt.ahk

	var := arr[wParam], %var% := lParam
	return 0
}

Heartbeat() {
	msg := GetMessages()
	if (msg != 0 && !msg.HasOwnProp("error"))
		Interpreter(msg)
}

F9::msgbox "Output`n`n" JSON.stringify(ReadMessages())
ExitFunc(*) {
	Critical

	ExitApp
}
