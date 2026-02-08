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
;#Include "ErrorHandling.ahk"
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
IdentifiedConnections := {}
CommunicatorSocket := ListenerSocket := -1
CommunicatorIsConnected := ListenerIsConnected := false
; general
CommunicationStyle := A_Args[15]
CommunicationID := (AccountType = "Main Acc" ? -1 : A_Args[16])
; override valuies
if BotToken != "" && CommunicationStyle = "Discord" && AccountType != "Main Acc"
	discordMode := 1
; misc
OnExit(ExitFunc, -1)
OnMessage(0x5550, SelfReload)
OnMessage(0x5552, nm_setGlobalInt)
OnMessage(0x5556, nm_sendHeartbeat)
OnMessage(0x004A, SendMessageToAlts)
SetTimer Heartbeat, 1000
DetectHiddenWindows 1
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

;-----------------
; Socket
;-----------------
EventHandler := {
	Alt: {
		Receive: SocketReceive, 
		Close: SocketClose
	},
	Main: {
		Accept: SocketAccept
	}
}

SocketSetup() {
	global CommunicatorSocket, ListenerSocket, CommunicatorIsConnected, ListenerIsConnected
	static WM := 0x5565

	setup_succeded := false
	if (AccountType = "Main Acc") && !SocketListenerExists() {
		try {
			ListenerSocket := Socket.Server()
			ListenerSocket.Bind("0.0.0.0", PortNumber)
			ListenerSocket.Listen(10)
			ListenerSocket.AsyncSelect(Socket.FD.ACCEPT, EventHandler.Main, WM++)
			ListenerIsConnected := setup_succeded := true
		}
	}
	else if (IP != "127.0.0.1") || SocketListenerExists() {
		try {
			CommunicatorSocket := Socket.Client()
			CommunicatorSocket.Connect(IP, PortNumber)
			CommunicatorSocket.AsyncSelect(Socket.FD.READ | Socket.FD.CLOSE, EventHandler.Alt, WM++)
			CommunicatorSocket.IsIdentified := false
			CommunicatorSocket.IsOwnedByMain := false
			CommunicatorIsConnected := setup_succeded := true
		}
	}

	if !setup_succeded
		SocketReconnect()
}

SocketAccept(self) {
	static WM := 0x5565
	accepted := false
	try {
		hSock := self.Accept()
		new_sock := Socket.Client(hSock)
		new_sock.AsyncSelect(Socket.FD.READ | Socket.FD.CLOSE, EventHandler.Alt, WM++)
		accepted := true
	}
	if accepted {
		new_sock.IsOwnedByMain := true
		new_sock.IsIdentified := false
		new_sock.Identifier := -1
		new_sock.SendText('{"type": "identify"}')		
	}
}

SocketReceive(self) {
	received_message := false	
	try {
		message := JSON.parse(self.ReceiveText())
		received_message := true
	}
	if received_message {
		if self.IsIdentified
			Interpreter(message)	
		else
			SocketIdentification(self, message)
	}
}

SocketClose(self) {
	global CommunicatorSocket, CommunicatorIsConnected
	try self.Close()

	if self.IsOwnedByMain {
		if IdentifiedConnections.HasOwnProp(self.Identifier)
			IdentifiedConnections.DeleteProp(self.Identifier)
		self.IsIdentified := false, self.Identifier := -1
		nm_UpdateConnectionTotal(ObjOwnPropCount(IdentifiedConnections))

		; reconnect the listener if none exists
		if !SocketListenerExists() && ListenerIsConnected 
			SocketReconnect()
	}
	else {
		CommunicatorIsConnected := false
		CommunicatorSocket := -1
		SocketReconnect()
	}
}

SocketIdentification(self, message) {
	if !self.IsOwnedByMain {
		received_identifer := false
		try {
			self.SendText('{"identifier": ' CommunicationID '}')
			received_identifer := true
		}
		if received_identifer
			self.IsIdentified := true
		else
			SocketReconnect()
	} 
	else {
		identifier := message["identifier"]
		IdentifiedConnections.%identifier% := self
		self.Identifier := identifier
		self.IsIdentified := true
		nm_UpdateConnectionTotal(ObjOwnPropCount(IdentifiedConnections))
	}
}

SocketListenerExists() {
	static AF_INET := 2, TCP_TABLE_BASIC_LISTENER := 0
	listener_exists := false
	pTcpTable := Buffer(4096)
	DllCall("IPHLPAPI\GetExtendedTcpTable",
		"ptr", pTcpTable.Ptr,
		"uint*", &(size := pTcpTable.Size), ; in case of future use
		"uchar", true,
		"int64", AF_INET,
		"int", TCP_TABLE_BASIC_LISTENER,
		"int64", 0,
		"uint")

	struct_count := NumGet(pTcpTable, "uint")
	loop struct_count {
		MIB_TCPROW := pTcpTable.Ptr + 4 + (20 * (A_Index - 1))    
		dwLocalPort := NumGet(MIB_TCPROW, 8, "uint")
		if (((dwLocalPort >> 8) & 0xff) | ((dwLocalPort & 0xff) << 8)) = PortNumber
			listener_exists := true
	}
	return listener_exists
}

SocketReconnect() {
	global CommunicatorSocket, ListenerSocket, CommunicatorIsConnected, ListenerIsConnected
	if AccountType != "Main Acc" {
		ListenerSocketSocket := -1
		ListenerIsConnected := false
	}
	else {
		CommunicatorSocket := -1
		CommunicatorIsConnected := false
	}

	SetTimer((*) => SocketSetup(), -10000)
}

if CommunicationStyle = "Socket"
	SocketSetup()

;-----------------
; Function
;-----------------
; natro_macro.ahk sends data here
SendMessageToAlts(wParam, lParam, *) {
	try {
		StringAddress := NumGet(lParam + 2*A_PtrSize, "Ptr")
		StringText := StrGet(StringAddress)
		jsonObj := JSON.parse(StringText)
	} catch
		return

	if Webhook != "" && CommunicationStyle = "Discord" && AccountType = "Main Acc" {
		payload := Map("content", JSON.Stringify(jsonObj))
		try discord.SendMessageAPI(JSON.stringify(payload), "application/json", , Webhook)
	}
	if CommunicationStyle = "Socket" && AccountType = "Main Acc" && ListenerIsConnected {
		for identifier, sock in IdentifiedConnections.OwnProps() {
			requested_id := jsonObj.Has("identifier") ? jsonObj["identifier"] : identifier
			if identifier != requested_id
				continue
			try sock.SendText(JSON.Stringify(jsonObj))
		}
	}
}

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
	incorrect_id := msg.Has("identifier") && (msg["identifier"] != CommunicationID)
	if !IsObject(msg) || msg.HasOwnProp("error") || incorrect_id
		return

	try Send_WM_COPYDATA(JSON.stringify(msg), "natro_macro ahk_class AutoHotkey", 2)
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

nm_UpdateConnectionTotal(num) {
	Critical
	try SendMessage(0x5561,num,,,"natro_macro ahk_class AutoHotkey")
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

nm_sendHeartbeat(*){
	Critical
	if WinExist("Heartbeat.ahk ahk_class AutoHotkey") 
		PostMessage 0x5556, 4
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

ExitFunc(*) {
	Critical
	try	CommunicatorSocket.Close()
	try CommunicatorSocket.Cleanup()
	ExitApp
}
