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

#Include "%A_ScriptDir%\..\lib\"
#Include "Gdip_All.ahk"
#Include "JSON.ahk"
#Include "Discord.ahk"
#Include "Socket.ahk"
#Include "nowUnix.ahk"
#Include "ErrorHandling.ahk"
#Include "Auxiliary.ahk"
#Include "WM_COPYDATA.ahk"

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
MacroStates := {
	Stopped: 0,
	Paused: 1,
	Running: 2
}
AccountTypes := {
	Disabled: "Disabled",
	Main: "Main Acc",
	TadAlt: "Tad Alt"
}
CommunicationStyles := {
	Socket: "Socket",
	Discord: "Discord"
}
AccountType := A_Args[1]
MacroState := MacroStates.Stopped
CommunicationStyle := A_Args[15]
CommunicationID := (AccountType == AccountTypes.Main ? -1 : A_Args[16])
; discord
;discordMode := A_Args[2]
;discordCheck := A_Args[3]
;MainChannelCheck := A_Args[4]
;MainChannelID := A_Args[5]
;ReportChannelCheck := A_Args[6]
;ReportChannelID := A_Args[7]
;WebhookEasterEgg := A_Args[8]
;DiscordUID := A_Args[9]
Webhook := A_Args[10]
BotToken := A_Args[11]
CommunicationChannelID := A_Args[12]
; Socket
IP := A_Args[13]
PortNumber := A_Args[14]
IdentifiedConnections := {}
CommunicatorSocket := ListenerSocket := -1
CommunicatorIsConnected := ListenerIsConnected := false
; misc
OnExit(ExitFunc, -1)
OnMessage(0x5552, nm_setGlobalInt)
OnMessage(0x5556, nm_sendHeartbeat)
OnMessage(0x004A, SendMessageToAlts)
SetTimer Heartbeat, 1000
DetectHiddenWindows 1

;-----------------
; Discord
;-----------------
ReadMessages() {
	if MacroState != MacroStates.Running
		throw Error("Macro not running")
	if CommunicationChannelID = 0 || BotToken == "" || CommunicationStyle != CommunicationStyles.Discord || AccountType == AccountTypes.Main
		throw Error("Discord communication not set up")

	messages := discord.GetRecentMessages(CommunicationChannelID)
	if messages = -1 || messages.Length = 0
		throw Error("No new messages")

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
	throw Error("No valid JSON found")
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
	static WM := 0x5665

	switch  {
	; main account
	case (AccountType == AccountTypes.Main) && !SocketListenerExists():
		try {
			ListenerSocket := Socket.Server()
			ListenerSocket.Bind("0.0.0.0", PortNumber)
			ListenerIsConnected := true
			ListenerSocket.Listen()
			ListenerSocket.AsyncSelect(Socket.FD.ACCEPT, EventHandler.Main, WM++)
		}
		catch 
			SocketReconnect()
	
	; tad alt 
	case (AccountType == AccountTypes.TadAlt) && ((IP != "127.0.0.1") || SocketListenerExists()):
		try {
			CommunicatorSocket := Socket.Client()
			CommunicatorSocket.Connect(IP, PortNumber)
			CommunicatorIsConnected := true
			CommunicatorSocket.AsyncSelect(Socket.FD.READ | Socket.FD.CLOSE, EventHandler.Alt, WM++)
		}
		catch 
			SocketReconnect()
		else {
			CommunicatorSocket.IsIdentified := false
			CommunicatorSocket.IsOwnedByMain := false
		}
	}
}

SocketAccept(self) {
	static WM := 0x5565
	connected := false
	try {
		hSock := self.Accept()
		new_sock := Socket.Client(hSock)
		connected := true
		new_sock.AsyncSelect(Socket.FD.READ | Socket.FD.CLOSE, EventHandler.Alt, WM++)
	}
	catch
		TryClose(connected, new_sock)
	else {
		new_sock.IsOwnedByMain := true
		new_sock.IsIdentified := false
		new_sock.Identifier := -1
		new_sock.SendText('{"type": "identify"}')	
	}
}

SocketReceive(self) {
	try
		message := JSON.parse(self.ReceiveText())
	catch
		return
	else {
		if self.IsIdentified
			Interpreter(message)	
		else
			SocketIdentification(self, message)
	}
}

SocketClose(self) {
	global CommunicatorSocket, CommunicatorIsConnected

	try (CommunicatorIsConnected) && self.Close()
	if self.IsOwnedByMain {
		if IdentifiedConnections.HasOwnProp(self.Identifier)
			IdentifiedConnections.DeleteProp(self.Identifier)
		self.IsIdentified := false
		self.Identifier := -1

		nm_UpdateConnectionTotal(ObjOwnPropCount(IdentifiedConnections))
		if !SocketListenerExists() && ListenerIsConnected
			SocketReconnect()
	}
	else {
		self.IsIdentified := false
		SocketReconnect()
	}
}

SocketIdentification(self, message) {
	if self.IsOwnedByMain {
		identifier := message["identifier"]
		IdentifiedConnections.%identifier% := self
		self.Identifier := identifier
		self.IsIdentified := true
		nm_UpdateConnectionTotal(ObjOwnPropCount(IdentifiedConnections))
	}
	else {
		try
			self.SendText('{"identifier": ' CommunicationID '}')
		catch
			SocketReconnect()
		else 
			self.IsIdentified := true
	}
}

SocketListenerExists() {
	static AF_INET := 2, TCP_TABLE_BASIC_LISTENER := 0
	pTcpTable := Buffer(4096)
	DllCall("IPHLPAPI\GetExtendedTcpTable",
		"ptr", pTcpTable.Ptr,
		"uint*", &(size := pTcpTable.Size),
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
			return true
	}
	return false
}

SocketReconnect() {
	global CommunicatorSocket, ListenerSocket, CommunicatorIsConnected, ListenerIsConnected
	if AccountType == AccountTypes.Main {
		TryClose(ListenerIsConnected, ListenerSocket)
		ListenerIsConnected := false
	}
	else {
		TryClose(CommunicatorIsConnected, CommunicatorSocket)
		CommunicatorIsConnected := false
	}

	SetTimer((*) => SocketSetup(), -10000)
}

TryClose(condition, sock) {
	try (condition) && sock.Close()
}

if CommunicationStyle = CommunicationStyles.Socket
	SocketSetup()

;-----------------
; Function
;-----------------
; natro_macro.ahk sends data here
SendMessageToAlts(wParam, lParam, *) {
	parsed := false
	try {
		StringText := StringFromCopyData(lParam)
		jsonObj := JSON.parse(StringText)
		parsed := true
	} 
	if (AccountType != AccountTypes.Main) || !parsed 
		return

	if (Webhook != "") && (CommunicationStyle == CommunicationStyles.Discord) {
		payload := Map("content", JSON.Stringify(jsonObj))
		try discord.SendMessageAPI(JSON.stringify(payload), "application/json", , Webhook)
	}
	if ListenerIsConnected && (CommunicationStyle == CommunicationStyles.Socket) {
		for identifier, sock in IdentifiedConnections.OwnProps() {
			requested_id := jsonObj.Has("identifier") ? jsonObj["identifier"] : identifier
			if identifier != requested_id
				continue
			try sock.SendText(JSON.Stringify(jsonObj))
		}
	}
}

GetMessages(*) {
	is_discord := CommunicationStyle == CommunicationStyles.Discord
	is_main := AccountType != AccountTypes.Main
	if (MacroState != MacroStates.Running) && !is_discord && is_main 
		return 0

	try 
		msg := ReadMessages()
	catch
		return 0

	return msg
}

Interpreter(msg, *) {
	if (MacroState != MacroStates.Running) && (msg.Has("identifier") && (msg["identifier"] != CommunicationID))
		return

	try Send_WM_COPYDATA(JSON.stringify(msg), "natro_macro ahk_class AutoHotkey", 2)
}

nm_UpdateConnectionTotal(num) {
	Critical
	if WinExist("natro_macro.ahk ahk_class AutoHotkey") > 0
		SendMessage(0x5561, num)
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
	if msg != 0
		Interpreter(msg)
}

ExitFunc(*) {
	Critical
	if AccountType != AccountTypes.Main {
		try (CommunicatorIsConnected) && CommunicatorSocket.Close()
		(CommunicatorSocket != -1) && CommunicatorSocket.Cleanup()
	} 
	else {
		try (ListenerIsConnected) && ListenerSocket.Close()
		(ListenerSocket != -1) && ListenerSocket.Cleanup()
	}
	ExitApp()
}
