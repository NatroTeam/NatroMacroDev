#Requires AutoHotkey v2.0

global advancedConfigLoc := "features\All\Quests\nm_advanced_config.ini"

;this is this features GUI lines-of-code used to calculate loading progress
MiscFeatureProgressVolume := (AdvancedFeature) ? 20 : 0
;this is the running total of all macro features included in the load progress metric
LoadingProgressVolume := (AdvancedFeature) ? LoadingProgressVolume+AdvancedFeatureProgressVolume : LoadingProgressVolume

nm_showAdvancedSettings(*){
	global BuffDetectReset
	static i := 0, t1, init := DllCall("GetSystemTimeAsFileTime", "int64p", &t1:=0)
	if (BuffDetectReset = 1)
		return
	DllCall("GetSystemTimeAsFileTime", "int64p", &t2:=0)
	if (t2 - t1 < 50000000)
	{
		if (++i >= 7)
		{
			TabCtrl.Add(["Advanced"])
			nm_AdvancedGUI(1), i := 0
		}
	}
	else
		i := 1, t1 := t2
}
nm_AdvancedGUI(init:=0){
	global
	local hBM, GuiCtrl
	TabCtrl.UseTab("Advanced")
	MainGui.SetFont("s8 cDefault Norm", "Tahoma")
	MainGui.SetFont("w700")
	MainGui.Add("GroupBox", "x5 y24 w240 h90", "Fallback Private Servers")
	MainGui.Add("GroupBox", "x5 y114 w240 h76", "Danger Zone")
	MainGui.Add("GroupBox", "x255 y24 w240 h38", "Debugging")
	MainGui.Add("GroupBox", "x255 y62 w240 h168", "Test Paths/Patterns")
	MainGui.SetFont("s8 cDefault Norm", "Tahoma")
	;reconnect
	MainGui.Add("Text", "x15 y44", "Backup 1:")
	MainGui.Add("Edit", "x65 y42 w170 h18 vFallbackServer1", FallbackServer1).OnEvent("Change", nm_ServerLink)
	MainGui.Add("Text", "x15 y66", "Backup 2:")
	MainGui.Add("Edit", "x65 y64 w170 h18 vFallbackServer2", FallbackServer2).OnEvent("Change", nm_ServerLink)
	MainGui.Add("Text", "x15 y88", "Backup 3:")
	MainGui.Add("Edit", "x65 y86 w170 h18 vFallbackServer3", FallbackServer3).OnEvent("Change", nm_ServerLink)
	;danger
	MainGui.Add("Button", "x90 y114 w12 h14","?").OnEvent("Click", DangerInfo)
	MainGui.Add("CheckBox", "x10 yp+15 vAnnounceGuidingStar Checked" AnnounceGuidingStar, "Announce Guiding Star").OnEvent("Click", nm_AnnounceGuidWarn)
	MainGui.Add("CheckBox", "xp yp+15 vHideErrors Checked" HideErrors, "Hide Errors").OnEvent("Click", nm_HideErrorsWarn)
	;debugging
	(GuiCtrl := MainGui.Add("CheckBox", "x265 y42 vssDebugging Checked" ssDebugging, "Enable Discord Debugging Screenshots")).Section := "Status", GuiCtrl.OnEvent("Click", nm_saveConfig)
	;test
	MainGui.Add("CheckBox", "x265 y89 w14 h14 Checked vTest1Check")
	MainGui.Add("CheckBox", "x265 y121 w14 h14 vTest2Check")
	MainGui.Add("Text", "x285 y88 w174 vTest1Text -Wrap", "<none>")
	MainGui.Add("Text", "x285 y120 w174 vTest2Text -Wrap", "<none>")
	hBM := LoadPicture("shell32.dll", "w20 h-1 Icon046")
	MainGui.Add("Picture", "x465 y86 w20 h20 vBrowse1", "HBITMAP:*" hBM).OnEvent("Click", nm_selectTestPath)
	MainGui.Add("Picture", "x465 y118 w20 h20 vBrowse2", "HBITMAP:*" hBM).OnEvent("Click", nm_selectTestPath)
	DllCall("DeleteObject", "ptr", hBM)
	MainGui.Add("Text", "x298 y149", "Repeat:")
	MainGui.Add("Text", "x342 y147 w54 h18 0x201")
	MainGui.Add("UpDown", "vTestCount Range1-99999", 1)
	MainGui.Add("CheckBox", "x404 y149 vTestInfinite", "Infinite").OnEvent("Click", nm_TestInfinite)
	MainGui.Add("Text", "x283 y174", "On Cycle Start:")
	MainGui.Add("CheckBox", "x362 y174 vTestReset Checked", "Reset")
	MainGui.Add("CheckBox", "x413 y174 vTestMsgBox", "MsgBox")
	MainGui.Add("Button", "x325 y197 w100 h24", "Start Test").OnEvent("Click", nm_testButton)
	MainGui.Add("Button", "x15 y164 w220 h22 vMainLoopPriorityButton", "Main Loop Priority List").OnEvent("Click", nm_priorityListGui)
	if (init = 1)
	{
		TabCtrl.Choose("Advanced")
		IniWrite (BuffDetectReset := 1), "settings\nm_config.ini", "Settings", "BuffDetectReset"
		MsgBox "
		(
		You have enabled Advanced Settings!
		Here you can find options that are not recommended to change.
		Remember that most of these settings are experimental and mainly intended for debugging and testing purposes!
		)", "Advanced Settings", 0x40040 " T20"
	}
}
DangerInfo(*) => MsgBox("
	(
	These settings could cause the macro to not function correctly, or for your roblox account to be at risk.

	Read each warning CAREFULLY. If you are unsure about any of these settings, it is recommended to leave them off.
	)")
nm_TestInfinite(*){
	global
	MainGui["TestCount"].Enabled := !(TestInfinite := MainGui["TestInfinite"].Value)
}
nm_selectTestPath(GuiCtrl, *){
	global Test1Path, Test2Path
	i := SubStr(GuiCtrl.Name, -1), nl := 0
	path := FileSelect(, A_WorkingDir "\paths", "Select Path/Pattern", "AHK Files (*.ahk)")
	if (SubStr(path, -4) = ".ahk")
	{
		Test%i%Path := path
		Loop Parse (str := StrReplace(path, A_WorkingDir "\")), "\"
		{
			if (TextExtent(line := ((p := InStr(str, "\", , , A_Index)-1) > 0) ? SubStr(str, 1, p) : str, MainGui["Test" i "Text"]) > 174)
			{
				str := SubStr(str, 1, InStr(str, "\", , , A_Index-1)-1) "`n" SubStr(str, InStr(str, "\", , , A_Index-1)), nl := 1
				break
			}
		}
		MainGui["Test" i "Text"].Text := str
		MainGui["Test" i "Text"].Move(, (((nl = 1) ? 50 : 56) + 32 * i), , ((nl = 1) ? 28 : 14))
	}
	else if path
		MsgBox "You must select an .ahk file!", "Select Path/Pattern", 0x40030 " T20 Owner" MainGui.Hwnd
}
nm_testButton(*){
	global
	local Test1:="", Test2:="", file
	Test1Check := MainGui["Test1Check"].Value
	Test2Check := MainGui["Test2Check"].Value
	TestCount := MainGui["TestCount"].Value
	TestInfinite := MainGui["TestInfinite"].Value
	TestReset := MainGui["TestReset"].Value
	TestMsgBox := MainGui["TestMsgBox"].Value

	if !GetRobloxHWND()
	{
		MsgBox "You must have Bee Swarm Simulator open to use this!", "Test Paths/Patterns", 0x40030 " T20 Owner" MainGui.Hwnd
		return 0
	}

	if ((Test1Check = 0) && (Test2Check = 0))
	{
		MsgBox "No paths were selected for testing!", "Test Paths/Patterns", 0x40030 " T20 Owner" MainGui.Hwnd
		return 0
	}

	Loop 2
	{
		if (Test%A_Index%Check = 1)
		{
			if (IsSet(Test%A_Index%Path) && (SubStr(Test%A_Index%Path, -4) = ".ahk"))
				file := FileOpen(Test%A_Index%Path, "r"), Test%A_Index% := file.Read(), file.Close()
			else
			{
				MsgBox "Test Path " A_Index " is enabled but not valid!", "Test Paths/Patterns", 0x40030 " T20 Owner" MainGui.Hwnd
				return 0
			}
		}
	}

	movement :=
	(
	'
	Loop' ((TestInfinite = 0) ? (" " TestCount) : "") '
	{
		ActivateRoblox()
		GetRobloxClientPos()
		SendEvent "{Click " windowX+350 " " windowY+offsetY+100 " 0}"
		' ((TestMsgBox = 1) ? 'if (MsgBox("Start Cycle: " A_Index "``r``nContinue?", "Test Paths/Patterns", 0x40044) != "Yes")`r`nExitApp' : 'tooltip "Testing``nCycle: " A_Index') '
		' ((TestReset = 1) ? "nm_reset()" : "") '
		' Test1 '
		' Test2 '
	}
	MsgBox "Test Complete!", "Test Paths/Patterns", 0x40040
	ExitApp
	'
	)

	nm_createWalk(movement, "test",
		(
		'
		size:=1, reps:=1, facingcorner:=0
		FieldName:=FieldPattern:=FieldPatternSize:=FieldReturnType:=FieldSprinklerLoc:=FieldRotateDirection:=""
		FieldUntilPack:=FieldPatternReps:=FieldPatternShift:=FieldSprinklerDist:=FieldRotateTimes:=FieldDriftCheck:=FieldPatternInvertFB:=FieldPatternInvertLR:=FieldUntilMins:=0

		nm_CameraRotation(Dir, count) {
			Static LR := 0, UD := 0, init := OnExit((*) => send("{" Rot%(LR > 0 ? "Left" : "Right")% " " Mod(Abs(LR), 8) "}{" Rot%(UD > 0 ? "Up" : "Down")% " " Abs(UD) "}"), -1)
			send "{" Rot%Dir% " " count "}"
			Switch Dir,0 {
				Case "Left": LR -= count
				Case "Right": LR += count
				Case "Up": UD -= count
				Case "Down": UD += count
			}
		}
		' nm_PathVars()
		)
	)
}

nm_copyDebugLog(param:="", *) {
	static os_version := "", processorName := "", RAMAmount := 0
	, robloxtype:="", robloxpath:=""

	fromRC := (param is number && param = 1)

	SetCursor("IDC_APPSTARTING")

	debugReport :=
	(
	'``````md
	<NM Debug>'
	header("PC Info", "`n")
	PcInfo()

	header("Macro Info")
	MacroInfo()

	header("Roblox Info")
	RobloxInfo()

	header("Detected Problems")
	DetectedProblems()

	header("Recent Issues")
	RecentIssues()
	'``````'
	)
	A_Clipboard := debugReport
	SetCursor("") ;reset back
	if !fromRC
		MsgBox("Copied Debug report to your clipboard.", "Copy Debug Logs", "T10 Iconi")

	return 1

	;formatters
	header(text, newlines:="`n`n") => newlines "# " text
	point(label, text) => "`n- " label ": " text
	path(text) => "``" text "``"

	PcInfo(){
		static DisplayScale := Map(
		96, 100,
		120, 125,
		144, 150,
		192, 200
		)
		if fromRC {
			return
			(
			'%OS%'
			point("Resolution", A_ScreenWidth 'x' A_ScreenHeight ' (' DisplayScale[A_ScreenDPI] '%)')
			'%CPU% %RAM%'
			)
		}
		winmgmts := ComObjGet("winmgmts:")
		if (!os_version) {
			for objItem in winmgmts.ExecQuery("SELECT * FROM Win32_OperatingSystem")
				os_version := Trim(StrReplace(StrReplace(StrReplace(StrReplace(objItem.Caption, "Microsoft"), "Майкрософт"), "مايكروسوفت"), "微软"))
		}
		if (!processorName){
			for objItem in winmgmts.ExecQuery("SELECT * FROM Win32_Processor")
				processorName := Trim(objItem.Name)
		}
		if (!RAMAmount) {
			MEMORYSTATUSEX := Buffer(64,0)
			NumPut("uint", 64, MEMORYSTATUSEX)
			DllCall("kernel32\GlobalMemoryStatusEx", "ptr", MEMORYSTATUSEX)
			RAMAmount := Round(NumGet(MEMORYSTATUSEX, 8, "int64") / 1073741824, 1)
		}

		return
		(
		point("OS", os_version ' (' (A_Is64bitOS ? '64-bit' : '32-bit') ')')
		point("Resolution", A_ScreenWidth 'x' A_ScreenHeight ' (' DisplayScale[A_ScreenDPI] '%)')
		. (processorName ? point("CPU", processorName) : '')
		. (RAMAmount ? point("RAM", RAMAmount ' GB') : '')
		)
	}
	MacroInfo(){
		return
		(
			point("AHK Version", A_AhkVersion (A_AhkPath = A_WorkingDir '\submacros\AutoHotkey32.exe' ? ' (built-in)' : ' (installed)'))
			point("Natro Version", VersionID ((VerCompare(VersionID, LatestVer) < 0) ? ' (outdated)' : ''))
			point("Installation Path", path(StrReplace(A_WorkingDir, EnvGet("USERPROFILE"), '%USERPROFILE%')))
		)
	}
	RobloxInfo(){
		robloxtype := nm_DetectRobloxType()
		robloxpath := ""
		if robloxtype = RobloxTypes.UWP
			robloxpath := nm_GetRobloxUWPPath()
		else
			robloxpath := nm_GetRobloxWebPath()
		if robloxpath
			robloxpath := Trim(StrReplace(StrReplace(StrReplace(robloxpath, EnvGet("USERPROFILE"), '%USERPROFILE%'), '%1', ''), '"', ''))
		return
		(
			(robloxpath ? point("Path", path(robloxpath)) : '')
			point("Default app", robloxtype)
		)
	}
	DetectedProblems(){
		try static remoteDesktopMinimize := RegRead("HKLM\Software\Microsoft\Terminal Server Client", "RemoteDesktop_SuppressWhenMinimized")
		problems := 0
		return (
			checkProblem((A_ScreenDPI != 96), 'Display scale is not set to 100%')
			checkProblem((robloxtype = RobloxTypes.NotFound || robloxtype = RobloxTypes.Custom), 'Roblox not found or using a custom install')
			checkProblem((robloxtype = RobloxTypes.Bootstrapper), 'Using custom bootstrapper (e.g. Bloxstrap), check config')
			checkProblem((A_ScreenHeight <= 600) || (A_ScreenWidth <= 1300), 'Low screen resolution')
			checkProblem((offsetfail ?? 0), 'Recent y-offset fail')
			checkProblem((VerCompare(VersionID, LatestVer) < 0), 'Outdated Natro Macro version')
			checkProblem((InStr(EnvGet("SESSIONNAME"), "RDP") && remoteDesktopMinimize != 2), 'Minimizing remote desktop connection will cause Natro Macro to break')
			checkProblem(((DllCall("GetSystemMetrics", "int", 94)) & 0x40 && DllCall("GetSystemMetrics", "int", 95) >= 2), 'Touchscreen is enabled')
			checkProblem((robloxtype = RobloxTypes.UWP), 'Using UWP Roblox, it is currently unsupported for this Natro Macro version')
			checkProblem((HideErrors = 0), 'Error hiding is disabled')

			(problems = 0 ? '`n<None>' : '`n`n> Total: ' problems)
		)
		checkProblem(condition, text) => ((condition) ? ('`r`n' (++problems) '. ' text) : '')
	}
	RecentIssues(){
		if (DebugLogEnabled = 0)
			return '`n<Debugging disabled>'
		latestDebuglog := FileRead('.\settings\debug_log.txt')
		latestLogs := SubStr(latestDebugLog, ((pos := InStr(latestDebuglog, '`n', 0, -1, -250)) ? pos : 1))
		issues := '', totalissues := 0

		loop parse latestLogs, '`r`n' {
			if InStr(A_LoopField, 'Error') || InStr(A_LoopField, 'Warning') || InStr(A_LoopField, 'Failed'){
				issues .= A_LoopField '`n'
				if ++totalissues > 10
					break
			}
		}
		if !issues
			return '`n<None>'

		return '`n' issues '`n> Total: ' totalissues
	}
}

robloxFPSGui(*) {
	global fpsUnlockerGui
	if isSet(fpsUnlockerGui) && fpsUnlockerGui is Gui
		fpsUnlockerGui.destroy()
	fpsUnlockerGui := Gui("+AlwaysOnTop -MinimizeBox +Owner" MainGui.Hwnd, "FPS Unlocker")
	fpsUnlockerGui.SetFont("s8 cDefault Norm", "Tahoma")
	fpsUnlockerGui.Show("w150 h60")
	fpsUnlockerGui.AddText("vWebFPSCountLabel w100 x5 Disabled", "Web Roblox FPS")
	fpsUnlockerGui.AddText("vWebFPSCountEdit yp xp+100 w50 Right Disabled")
	fpsUnlockerGui.AddUpDown("vWebFPSCount Range15-1000 Disabled", 60)
	fpsUnlockerGui.AddText("vUWPFPSCountLabel w100 x5 Disabled", "UWP Roblox FPS")
	fpsUnlockerGui.AddText("vUWPFPSCountEdit yp xp+100 w50 Right Disabled")
	fpsUnlockerGui.AddUpDown("vUWPFPSCount Range15-1000 Disabled", 60)
	fpsUnlockerGui.AddButton("vApply x5 yp+20 w140 Disabled","Apply").OnEvent("Click", (*) => WriteFPSCounts())
	fpsUnlockerGui.Add("Button", "xp+140 yp w12", "?").OnEvent("Click", nm_FPSUnlockerHelp)
	uwpxml := webxml := ""
	uwpfps := webfps := 60
	for robloxtype in [RobloxTypes.Web, RobloxTypes.UWP] {
		xmlpath := nm_LocateRobloxSettingsXML(robloxtype)
		if (!xmlpath || !RegExMatch(FileRead(xmlpath), "<int name=`"FramerateCap`">(-?\d+)</int>", &match))
			continue
		fps := match[1] = "-1" ? 60 : Integer(match[1])
		isweb := (robloxtype = RobloxTypes.Web)
		prefix := isweb ? "Web" : "UWP"
		fpsUnlockerGui[prefix "FPSCount"].Value := fps
		fpsUnlockerGui[prefix "FPSCountLabel"].Enabled := 1
		fpsUnlockerGui[prefix "FPSCountEdit"].Enabled := 1
		fpsUnlockerGui[prefix "FPSCount"].Enabled := 1
		fpsUnlockerGui["Apply"].Enabled := 1
		%prefix%xml := xmlpath, %prefix%fps := fps
	}
	WriteFPSCounts() {
		if fpsUnlockerGui["WebFPSCount"].Value < 25 && fpsUnlockerGui["WebFPSCount"].Value != webfps
			|| fpsUnlockerGui["UWPFPSCount"].Value < 25 && fpsUnlockerGui["UWPFPSCount"].Value != uwpfps
			if MsgBox('An FPS count of less than 25 is not recommended`nAre you sure you want to proceed?', , 0x40134) != "Yes"
				return
		for robloxtype, xmlpath in Map(RobloxTypes.Web, webxml, RobloxTypes.UWP, uwpxml) {
			if !xmlpath
				continue
			prefix := (robloxtype = RobloxTypes.Web) ? "Web" : "FPS"
			newfps := fpsUnlockerGui[prefix "FPSCount"].Value
			newfpsxml := (newfps = 60) ? "-1" : newfps
			oldfps := (robloxtype = RobloxTypes.Web) ? webfps : uwpfps
			if newfps = oldfps
				continue
			if robloxtype = RobloxTypes.Web {
				while WinExist("ahk_exe RobloxPlayerBeta.exe") || WinExist("ahk_exe ApplicationFrameHost.exe")
					if MsgBox("Please close Web Roblox before applying FPS changes.", , 0x40135) != "Retry"
						continue 2
			} else {
				while WinExist("ahk_exe ApplicationFrameHost.exe")
					if MsgBox("Please close UWP Roblox before applying FPS changes.", , 0x40135) != "Retry"
						continue 2
			}
			try {
				xml := FileRead(xmlpath)
				xml := RegExReplace(
					xml,
					"<int name=`"FramerateCap`">-?\d+</int>",
					"<int name=`"FramerateCap`">" newfpsxml "</int>"
				)
				FileDelete(xmlpath)
				FileAppend(xml, xmlpath)
			}
			catch {
				MsgBox(
					"Failed to write FPS settings to " robloxtype " Roblox settings file.`nSupposed path: "
					StrReplace(xmlpath, EnvGet("USERPROFILE"), "%USERPROFILE%")
					, , 0x40030
				)
				continue
			}
			MsgBox(robloxtype " Roblox FPS limit has been set to " ((newfps = "-1") ? "60" : newfps) "", , 0x40040)
			%prefix%fps = newfps
		}
	}
}