/*
Natro Macro (https://github.com/NatroTeam/NatroMacro)
Copyright © Natro Team (https://github.com/NatroTeam)

This file is part of Natro Macro. Our source code will always be open and available.

Natro Macro is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation,
either version 3 of the License, or (at your option) any later version.

Natro Macro is distributed in the hope that it will be useful. This does not give you the right to steal sections from our code, distribute it under your own name, then slander the macro.

You should have received a copy of the license along with Natro Macro. If not, please redownload from an official source.
*/

;Compiler directives (currently not in use):
;@Ahk2Exe-SetName Natro Macro
;@Ahk2Exe-SetDescription Natro Macro
;@Ahk2Exe-SetCompanyName Natro Team
;@Ahk2Exe-SetCopyright Copyright © Natro Team
;@Ahk2Exe-SetOrigFilename natro_macro.exe
#MaxThreads 255
#Requires AutoHotkey v2.0
#SingleInstance Force

#Include "%A_ScriptDir%\..\lib"
#Include "Gdip_All.ahk"
#Include "Gdip_ImageSearch.ahk"
#Include "JSON.ahk"
#Include "Roblox.ahk"
#Include "DurationFromSeconds.ahk"
#Include "nowUnix.ahk"
#Include "ErrorHandling.ahk"
#Include "HashFile.ahk"

;This is where you can include new feature files
#Include "nm_functions.ahk"
#Include "GameData.ahk"
#Include "%A_ScriptDir%\..\features\All\customizeGui.ahk"
#Include "%A_ScriptDir%\..\features\All\BaselineFeatures.ahk"
#Include "%A_ScriptDir%\..\features\All\priorityList.ahk"
#Include "%A_ScriptDir%\..\features\All\Gather\GatherFeature.ahk"
#Include "%A_ScriptDir%\..\features\All\CollectKill\CollectKillFeature.ahk"
#Include "%A_ScriptDir%\..\features\All\Boost\BoostFeature.ahk"
#Include "%A_ScriptDir%\..\features\All\Quests\QuestsFeature.ahk"
#Include "%A_ScriptDir%\..\features\All\Planters\PlantersFeature.ahk"
#Include "%A_ScriptDir%\..\features\All\Status\StatusFeature.ahk"
#Include "%A_ScriptDir%\..\features\All\Settings\SettingsFeature.ahk"
#Include "%A_ScriptDir%\..\features\All\Misc\MiscFeature.ahk"
#Include "%A_ScriptDir%\..\features\All\Credits\CreditsFeature.ahk"
#Include "%A_ScriptDir%\..\features\All\Advanced\AdvancedFeature.ahk"
#Include "%A_ScriptDir%\..\settings\Personal\PersonalFeature.ahk"

#Warn VarUnset, Off

SetWorkingDir A_ScriptDir "\.."
CoordMode "Mouse", "Screen"
CoordMode "Pixel", "Screen"
SendMode "Event"


; check for the correct AHK version before starting
RunWith32()

; elevate script if required (check write permissions in ScriptDir using Heartbeat.ahk)
ElevateScript()

; declare executable paths
exe_path32 := A_AhkPath
exe_path64 := (A_Is64bitOS && FileExist("submacros\AutoHotkey64.exe")) ? (A_WorkingDir "\submacros\AutoHotkey64.exe") : A_AhkPath

; close any remnant running natro scripts and start heartbeat
DetectHiddenWindows 1
CloseScripts(1)
if !WinExist("Heartbeat.ahk ahk_class AutoHotkey")
	run '"' exe_path32 '" /script "' A_WorkingDir '\submacros\Heartbeat.ahk"'
DetectHiddenWindows 0

; OnMessages
OnMessage(0x004A, nm_WM_COPYDATA)
OnMessage(0x5550, nm_ForceLabel, 255)
OnMessage(0x5551, nm_setShiftLock, 255)
OnMessage(0x5552, nm_setGlobalInt, 255)
OnMessage(0x5553, nm_setGlobalStr, 255)
OnMessage(0x5555, nm_backgroundEvent, 255)
OnMessage(0x5556, nm_sendHeartbeat)
OnMessage(0x5557, nm_ForceReconnect)
OnMessage(0x5558, nm_AmuletPrompt)
OnMessage(0x5559, nm_FindItem)
OnMessage(0x5560, nm_copyDebugLog)
OnMessage(0x0020, nm_WM_SETCURSOR)
OnMessage(0x5561, nm_changePriorityList)

; set version identifier
VersionID := "2.0.0"

;initial load warnings
if (A_ScreenDPI != 96)
	MsgBox "
	(
	Your Display Scale seems to be a value other than 100%. This means the macro will NOT work correctly!

	To fix this:
	Right click on your Desktop -> Click 'Display Settings' -> Under 'Scale & Layout', set Scale to 100% -> Close and Restart Roblox before starting the macro.
	)", "WARNING!!", 0x1030 " T60"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; CREATE SETTINGS FOLDERS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
nm_CreateFolder("settings")
nm_CreateFolder("settings\imported")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; IMPORT PATTERNS AND PATHS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; assign scan codes to key variables
TCFBKey:=FwdKey:="sc011" ; w
TCLRKey:=LeftKey:="sc01e" ; a
AFCFBKey:=BackKey:="sc01f" ; s
AFCLRKey:=RightKey:="sc020" ; d
RotLeft:="sc033" ; ,
RotRight:="sc034" ; .
RotUp:="sc149" ; PgUp
RotDown:="sc151" ; PgDn
ZoomIn:="sc017" ; i
ZoomOut:="sc018" ; o
SC_E:="sc012" ; e
SC_R:="sc013" ; r
SC_L:="sc026" ; l
SC_Esc:="sc001" ; Esc
SC_Enter:="sc01c" ; Enter
SC_LShift:="sc02a" ; LShift
SC_Space:="sc039" ; Space
SC_1:="sc002" ; 1
SC_Slash  := "sc035" ; /

nm_importPatterns()
nm_importPaths()

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; IMPORT GLOBALS FROM CONFIG
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
nm_importConfig() ;in GameData.ahk

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; GAME DATA
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#Include "data\memorymatch.ahk"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; FIELD DEFAULT OVERRIDES
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
nm_importFieldDefaults()

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; MANUAL PLANTERS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
nm_importManualPlanters() ;in PlantersFeature.ahk

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; DECLARE GLOBALS AND PREPARE GUI
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
try Hotkey StopHotkey, stop, "On"

pToken := Gdip_Startup()
currentWalk := {pid:"", name:""} ; stores "pid" (script process ID) and "name" (pattern/movement name)

nm_readPriorityList()
;check priorityList integrity
if IsSet(priorityList) {
	for x,v in priorityList {
		if v=""
			priorityList:=[]
	}
}
if (not IsSet(priorityList)) || (priorityList.length=0) {
	nm_setDefaultPriorityList()
	nm_savePriorityList()
}

CheckNight:=0
LostPlanters:=""
QuestFields:=""
youDied:=0
GameFrozenCounter:=0
AFBrollingDice:=0
AFBuseGlitter:=0
AFBuseBooster:=0
MacroState:=0 ; 0=stopped, 1=paused, 2=running
resetTime := MacroStartTime:=MacroReloadTime:=nowUnix()
PausedRuntime:=0
FieldGuidDetected:=0
HasPopStar:=0
PopStarActive:=0
PreviousAction:="None"
CurrentAction:="Startup"
fieldnamelist := ["Bamboo","Blue Flower","Cactus","Clover","Coconut","Dandelion","Mountain Top","Mushroom","Pepper","Pine Tree","Pineapple","Pumpkin","Rose","Spider","Strawberry","Stump","Sunflower"]
hotbarwhilelist := ["Never","Always","At Hive","Gathering","Attacking","Microconverter","Whirligig","Enzymes","GatherStart","Snowflake"]
sprinklerImages := ["saturator"]
ReconnectDelay:=0
GatherStartTime := ConvertStartTime := 0
QuestAnt := 0
QuestBlueBoost := 0
QuestRedBoost := 0
HiveConfirmed := 0
ShiftLockEnabled := 0
VBStart := 0
VBResults := {
	; status states
	success: "Killed",
	failed: "Failed",
	retry: "Retrying field",
	notfound: "Not Found",
	; detection states
	found: "Found",
	dead: "Dead"
}
VBReasons := {
	inactiveHoney: "Inactive honey",
	youDied: "You Died",
	otherPlayer: "Killed by other player",
	timeout: "Timeout",
	killed: "Killed"
}
CUSTOM_CURSOR := 1
nm_WM_SETCURSOR(*) => CUSTOM_CURSOR

ForceStart := 0
RemoteStart := 0

;ensure Gui will be visible
if (GuiX && GuiY)
{
	Loop (MonitorCount := MonitorGetCount())
	{
		MonitorGetWorkArea A_Index, &MonLeft, &MonTop, &MonRight, &MonBottom
		if(GuiX>MonLeft && GuiX<MonRight && GuiY>MonTop && GuiY<MonBottom)
			break
		if(A_Index=MonitorCount)
			guiX:=guiY:=0
	}
}
else
	guiX:=guiY:=0

BackpackPercent:=BackpackPercentFiltered:=0
ActiveHotkeys:=[]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; RUN STATUS HANDLER
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
if (StatusFeature) {
	Run
	(
	'"' exe_path64 '" /script "' A_WorkingDir '\submacros\Status.ahk" '
	'"' discordMode '" "' discordCheck '" "' webhook '" "' bottoken '" "' MainChannelCheck '" "' MainChannelID '" "' ReportChannelCheck '" "' ReportChannelID '" '
	'"' WebhookEasterEgg '" "' ssCheck '" "' ssDebugging '" "' CriticalSSCheck '" "' AmuletSSCheck '" "' MachineSSCheck '" "' BalloonSSCheck '" "' ViciousSSCheck '" '
	'"' DeathSSCheck '" "' PlanterSSCheck '" "' HoneySSCheck '" "' criticalCheck '" "' discordUID '" "' CriticalErrorPingCheck '" "' DisconnectPingCheck '" "' GameFrozenPingCheck '" '
	'"' PhantomPingCheck '" "' UnexpectedDeathPingCheck '" "' EmergencyBalloonPingCheck '" "' commandPrefix '" "' NightAnnouncementCheck '" "' NightAnnouncementName '" '
	'"' NightAnnouncementPingID '" "' NightAnnouncementWebhook '" "' PrivServer '" "' DebugLogEnabled '" "' MonsterRespawnTime '" "' HoneyUpdateSSCheck '" "' discordUIDCommands '"'
	)
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; GDIP BITMAPS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
bitmaps := Map(), bitmaps.CaseSense := 0
shrine := Map(), shrine.CaseSense := 0
hBitmapsSBT := Map(), hBitmapsSBT.CaseSense := 0
#Include "%A_ScriptDir%\..\nm_image_assets"
#Include "general\bitmaps.ahk"
#Include "gui\bitmaps.ahk"
#Include "beemenu\bitmaps.ahk"
#Include "buffs\bitmaps.ahk"
#Include "convert\bitmaps.ahk"
#Include "collect\bitmaps.ahk"
#Include "kill\bitmaps.ahk"
#Include "boost\bitmaps.ahk"
#Include "inventory\bitmaps.ahk"
#Include "reconnect\bitmaps.ahk"
#Include "fdc\bitmaps.ahk"
#Include "offset\bitmaps.ahk"
#Include "perfstats\bitmaps.ahk"
#Include "gui\blendershrine_bitmaps.ahk"
#Include "quests\bitmaps.ahk"
#Include "sprinkler\bitmaps.ahk"
#Include "stickerstack\bitmaps.ahk"
#Include "stickerprinter\bitmaps.ahk"
#Include "memorymatch\bitmaps.ahk"
#include "reset\bitmaps.ahk"
#include "night\bitmaps.ahk"

(hBitmapsSB := Map()).CaseSense := 0
for x,y in hBitmapsSBT
	hBitmapsSB[x] := Gdip_CreateHBITMAPFromBitmap(y), Gdip_DisposeImage(y)
hBitmapsSB["None"] := 0


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; SYSTEM TRAY
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
TraySetIcon "nm_image_assets\auryn.ico"
A_TrayMenu.Delete()
A_TrayMenu.Add()
A_TrayMenu.Add("Open Logs", (*) => ListLines())
A_TrayMenu.Add("Copy Logs", nm_copyDebugLog)
A_TrayMenu.Add()
A_TrayMenu.Add("Edit Roblox FPS", robloxFPSGui)
A_TrayMenu.Add()
A_TrayMenu.Add("Edit This Script", (*) => Edit())
A_TrayMenu.Add("Suspend Hotkeys", (*) => (A_TrayMenu.ToggleCheck("Suspend Hotkeys"), Suspend()))
A_TrayMenu.Add()
A_TrayMenu.Add("Start Macro", start)
A_TrayMenu.Add("Pause Macro", nm_pause)
A_TrayMenu.Add("Stop Macro", stop)
A_TrayMenu.Add()
A_TrayMenu.Add("Show Timers", timers)
A_TrayMenu.Add()
A_TrayMenu.Add("Close", (*) => ExitApp())
A_TrayMenu.Add()
A_TrayMenu.Default := "Start Macro"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; GUI SKINNING
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;https://www.autohotkey.com/boards/viewtopic.php?f=6&t=5841&hilit=gui+skin
DllCall(DllCall("GetProcAddress"
		, "Ptr",DllCall("LoadLibrary", "Str",A_WorkingDir "\nm_image_assets\Styles\USkin.dll")
		, "AStr","USkinInit", "Ptr")
	, "Int",0, "Int",0, "AStr",A_WorkingDir "\nm_image_assets\styles\" GuiTheme ".msstyles")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; DEFAULT ROBLOX TYPE/PATH DETECTION
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
nm_GetRobloxWebPath() => RegRead("HKCR\roblox\shell\open\command")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; DETECT INCORRECT ROBLOX SETTINGS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; AUTO-UPDATE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; CREATE GUI
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
OnExit(GetOut)
MainGui := Gui((AlwaysOnTop ? "+AlwaysOnTop " : "") "+Border +OwnDialogs", "Natro Macro (Loading 0%)")
WinSetTransparent 255-floor(GuiTransparency*2.55), MainGui
MainGui.Show("x" GuiX " y" GuiY " w490 h275")
SetLoadingProgress(percent) => MainGui.Title := "Natro Macro (Loading " Round(percent) "%)"
MainGui.OnEvent("Close", (*) => ExitApp())
MainGui.SetFont("s8 cDefault Norm", "Tahoma")
MainGui.SetFont("w700")
MainGui.Add("Text", "x5 y241 w80 -Wrap +BackgroundTrans", "Current Field:")
MainGui.Add("Text", "x177 y241 w30 +BackgroundTrans", "Status:")
MainGui.SetFont("s8 cDefault Norm", "Tahoma")
MainGui.Add("Button", "x82 y240 w10 h15 vcurrentFieldUp Disabled", "<").OnEvent("Click", nm_currentFieldUp)
MainGui.Add("Button", "x165 y240 w10 h15 vcurrentFieldDown Disabled", ">").OnEvent("Click", nm_currentFieldDown)
MainGui.Add("Text", "x92 y240 w73 +center +BackgroundTrans +border vCurrentField", CurrentField:=FieldName%CurrentFieldNum%)
MainGui.Add("Text", "x220 y240 w275 +BackgroundTrans +border vstate", "Startup: UI")

; version label and links
(GuiCtrl := MainGui.Add("Text", "x435 y264 vVersionText", "v" versionID)).OnEvent("Click", nm_showAdvancedSettings), GuiCtrl.Move(494 - (VersionWidth := TextExtent("v" VersionID, GuiCtrl)))
hBM := Gdip_CreateHBITMAPFromBitmap(bitmaps["warninggui"])
MainGui.Add("Picture", "+BackgroundTrans x482 y264 w14 h14 Hidden vImageUpdateLink", "HBITMAP:*" hBM).OnEvent("Click", nm_AutoUpdateGUI)
DllCall("DeleteObject", "Ptr", hBM)
hBM := Gdip_CreateHBITMAPFromBitmap(bitmaps["githubgui"])
MainGui.Add("Picture", "+BackgroundTrans x" 494-VersionWidth-23 " y262 w18 h18 vImageGitHubLink", "HBITMAP:*" hBM)
DllCall("DeleteObject", "Ptr", hBM)
pBM := Gdip_BitmapConvertGray(bitmaps["discordgui"]), hBM := Gdip_CreateHBITMAPFromBitmap(pBM)
MainGui.Add("Picture", "+BackgroundTrans x" 494-VersionWidth-48 " y263 w21 h16 vImageDiscordLink", "HBITMAP:*" hBM)
Gdip_DisposeImage(pBM), DllCall("DeleteObject", "Ptr", hBM)
hBM := Gdip_CreateHBITMAPFromBitmap(bitmaps["paypalgui"])
MainGui.Add("Picture", "+BackgroundTrans x" 494-VersionWidth-67 " y262 w14 h16 vImageDonateLink", "HBITMAP:*" hBM).OnEvent("Click", nm_DonateLink)
DllCall("DeleteObject", "Ptr", hBM)

; control buttons
MainGui.SetFont("s8 cDefault Norm", "Tahoma")
MainGui.Add("Button", "x5 y260 w65 h20 -Wrap Disabled vStartButton", " Start (" StartHotkey ")").OnEvent("Click", nm_StartButton)
MainGui.Add("Button", "x75 y260 w65 h20 -Wrap Disabled vPauseButton", " Pause (" PauseHotkey ")").OnEvent("Click", nm_PauseButton)
MainGui.Add("Button", "x145 y260 w65 h20 -Wrap Disabled vStopButton", " Stop (" StopHotkey ")").OnEvent("Click", nm_StopButton)
MainGui.Add("Button", "x215 y260 w55 h20 -Wrap Disabled vCustomizeButton", "Customize").OnEvent("Click", nm_CustomizeButton)

for k,v in ["PMondoGuid","PMondoGuidComplete","PFieldBoosted","PFieldGuidExtend","PFieldGuidExtendMins","PFieldBoostExtend","PPopStarExtend"]
	%v%:=0
#include "*i %A_ScriptDir%\..\settings\personal.ahk"


; add tabs
TabArr := []
(GatherFeature) && TabArr.Push("Gather")
(CollectKillFeature) && TabArr.Push("Collect/Kill")
(BoostFeature) && TabArr.Push("Boost")
(QuestsFeature) && TabArr.Push("Quests")
(PlantersFeature) && TabArr.Push("Planters")
(StatusFeature) && TabArr.Push("Status")
(MiscFeature) && TabArr.Push("Misc")
TabArr.Push("Settings")
(BuffDetectReset = 1 && AdvancedFeature) && TabArr.Push("Advanced")
(CreditsFeature) && TabArr.Push("Credits")
(PersonalFeature) && TabArr.Push("Personal")
(TabCtrl := MainGui.Add("Tab", "x0 y-1 w500 h240 -Wrap", TabArr)).OnEvent("Change", (*) => TabCtrl.Focus())
SendMessage 0x1331, 0, 20, , TabCtrl ; set minimum tab width
; check for update
try AsyncHttpRequest("GET", "https://api.github.com/repos/NatroTeam/NatroMacro/releases", nm_AutoUpdateHandler
, Map("accept", "application/vnd.github+json", "X-GitHub-Api-Version", "2022-11-28"))
; open Timers
if (TimersOpen = 1)
	run '"' exe_path32 '" /script "' A_WorkingDir '\submacros\PlanterTimers.ahk"'

; GATHER TAB
; ------------------------
if(GatherFeature) {
 nm_GatherTab()
}

; CREDITS TAB
; ------------------------
if(CreditsFeature) {
 nm_CreditsTab()
}

; PERSONAL TAB
; ------------------------
if(PersonalFeature) {
 nm_PersonalTab()
}

; MISC TAB
; ------------------------
if(MiscFeature) {
 nm_MiscTab()
}

; STATUS TAB
; ------------------------
if(StatusFeature) {
 nm_StatusTab()
}

; SETTINGS TAB
; ------------------------
nm_SettingsTab()

;COLLECT/Kill TAB
;------------------------
if(CollectKillFeature) {
 nm_CollectKillTab()
}

;BOOST TAB
;------------------------
if(BoostFeature) {
 nm_BoostTab()
}

;QUESTS TAB
;------------------------
if(QuestsFeature) {
 nm_QuestsTab()
}

;PLANTERS TAB
;------------------------
if(PlantersFeature) {
 nm_PlantersTab()
}

;ADVANCED TAB
;------------------------
if (BuffDetectReset = 1 && AdvancedFeature)
	nm_AdvancedGUI()
SetCursor(0)
SetLoadingProgress(100)

;unlock tabs
nm_LockTabs(0)
nm_setStatus("Startup", "UI")
TabCtrl.Focus()
MainGui.Title := "Natro Macro"
MainGui["StartButton"].Enabled := 1
MainGui["PauseButton"].Enabled := 1
MainGui["StopButton"].Enabled := 1
MainGui["CustomizeButton"].Enabled := 1

;enable hotkeys
try {
	Hotkey StartHotkey, start, "On"
	Hotkey PauseHotkey, nm_pause, "On"
	Hotkey AutoClickerHotkey, autoclicker, "On T2"
	Hotkey TimersHotkey, timers, "On"
	Hotkey DebugHotkey, nm_copyDebugLog, "On"
}

SetTimer Background, 2000
if (A_Args.Has(1) && (A_Args[1] = 1)){
	ForceStart := 1
	SetTimer start, -1000
}
return


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; MAIN LOOP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
nm_Start(){
	ActivateRoblox()
	global serverStart := nowUnix()
	Loop
		for i in priorityList
			(%"nm_" i%)()
	nm_planter() => (mp_Planter(),ba_planter())
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; FUNCTIONS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#Include "%A_ScriptDir%\..\lib"
#Include "nm_OpenMenu.ahk"
#Include "nm_InventorySearch.ahk"
;interrupts
nm_MondoInterrupt() => (utc_min := FormatTime(A_NowUTC, "m"), now := nowUnix(),
	((MondoBuffCheck = 1) && ((utc_min<14 && (now-LastMondoBuff)>960 && MondoAction="Kill")
		|| (!nm_GatherBoostInterrupt()
			&& ((utc_min<14 && (now-LastMondoBuff)>960 && MondoAction="Buff")
			|| (utc_min<12 && (now-LastGuid)<60 && PMondoGuid && MondoAction="Guid")
			|| (utc_min<=8 && (now-LastMondoBuff)>960 && PMondoGuid && MondoAction="Tag")))
		)
	)
)
nm_BeesmasInterrupt() {
	global BeesmasGatherInterruptCheck
	now := nowUnix()
	return ((beesmasActive = 1) && (BeesmasGatherInterruptCheck = 1)
		&& ((StockingsCheck && (now-LastStockings)>3600)
		|| (FeastCheck && (now-LastFeast)>5400)
		|| (RBPDelevelCheck && (now-LastRBPDelevel)>10800)
		|| (GingerbreadCheck && (now-LastGingerbread)>7200)
		|| (SnowMachineCheck && (now-LastSnowMachine)>7200)
		|| (CandlesCheck && (now-LastCandles)>14400)
		|| (SamovarCheck && (now-LastSamovar)>21600)
		|| (LidArtCheck && (now-LastLidArt)>28800)
		|| (GummyBeaconCheck && (now-LastGummyBeacon)>28800)
		|| (WinterMemoryMatchCheck && (now-LastWinterMemoryMatch)>14400))
	)
}
nm_BugrunInterrupt() {
	global BugrunInterruptCheck
	now := nowUnix()
	multiplier := 1-(MonsterRespawnTime?MonsterRespawnTime:0)*0.01
	return ((((BugrunInterruptCheck && BugrunLadybugsCheck)
			|| (PolarQuestCheck && PolarQuestGatherInterruptCheck && QuestLadybugs)
			|| (RileyQuestCheck && RileyQuestGatherInterruptCheck && (RileyLadybugs || RileyAll)))
			&& ((now-LastBugrunLadybugs)>floor(330*multiplier)))
		|| (((BugrunInterruptCheck && BugrunRhinoBeetlesCheck)
			|| (PolarQuestCheck && PolarQuestGatherInterruptCheck && QuestRhinoBeetles)
			|| (RileyQuestCheck && RileyQuestGatherInterruptCheck && RileyAll)
			|| (BuckoQuestCheck && BuckoQuestGatherInterruptCheck && BuckoRhinoBeetles))
			&& ((now-LastBugrunRhinoBeetles)>floor(330*multiplier)))
		|| (((BugrunInterruptCheck && BugrunSpiderCheck)
			|| (PolarQuestCheck && PolarQuestGatherInterruptCheck && QuestSpider)
			|| (RileyQuestCheck && RileyQuestGatherInterruptCheck && RileyAll))
			&& ((now-LastBugrunSpider)>floor(1830*multiplier)))
		|| (((BugrunInterruptCheck && BugrunMantisCheck)
			|| (PolarQuestCheck && PolarQuestGatherInterruptCheck && QuestMantis)
			|| (RileyQuestCheck && RileyQuestGatherInterruptCheck && RileyAll)
			|| (BuckoQuestCheck && BuckoQuestGatherInterruptCheck && BuckoMantis))
			&& ((now-LastBugrunMantis)>floor(1230*multiplier)))
		|| (((BugrunInterruptCheck && BugrunScorpionsCheck)
			|| (PolarQuestCheck && PolarQuestGatherInterruptCheck && QuestScorpions)
			|| (RileyQuestCheck && RileyQuestGatherInterruptCheck && (RileyScorpions || RileyAll)))
			&& ((now-LastBugrunScorpions)>floor(1230*multiplier)))
		|| (((BugrunInterruptCheck && BugrunWerewolfCheck)
			|| (PolarQuestCheck && PolarQuestGatherInterruptCheck && QuestWerewolf)
			|| (RileyQuestCheck && RileyQuestGatherInterruptCheck && RileyAll))
			&& ((now-LastBugrunWerewolf)>floor(3600*multiplier))))
}
nm_GatherBoostInterrupt() => (now := nowUnix(), ((now-GatherFieldBoostedStart<900) || (now-LastGlitter<900) || nm_boostBypassCheck()))
nm_MemoryMatchInterrupt() {
	global MemoryMatchInterruptCheck
	now := nowUnix()
	return ((MemoryMatchInterruptCheck = 1)
		&& ((NormalMemoryMatchCheck && (now-LastNormalMemoryMatch)>7200)
		|| (MegaMemoryMatchCheck && (now-LastMegaMemoryMatch)>14400)
		|| (ExtremeMemoryMatchCheck && (now-LastExtremeMemoryMatch)>28800)
		|| ((beesmasActive = 1) && WinterMemoryMatchCheck && (now-LastWinterMemoryMatch)>14400))
	)
}



