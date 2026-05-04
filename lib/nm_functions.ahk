; check for the correct AHK version before starting
RunWith32() {
	if (A_PtrSize != 4) {
		SplitPath A_AhkPath, , &ahkDirectory

		if !FileExist(ahkPath := ahkDirectory "\AutoHotkey32.exe")
			MsgBox "Couldn't find the 32-bit version of Autohotkey in:`n" ahkPath, "Error", 0x10
		else
			ReloadScript(ahkpath)

		ExitApp
	}
}
ReloadScript(ahkpath) {
	static cmd := DllCall("GetCommandLine", "Str"), params := DllCall("shlwapi\PathGetArgs","Str",cmd,"Str")
	Run '"' ahkpath '" /restart ' params
}

; elevate script if required (check write permissions in ScriptDir using Heartbeat.ahk)
ElevateScript() {
	try
		file := FileOpen("submacros\Heartbeat.ahk", "a")
	catch {
		if (!A_IsAdmin || !(DllCall("GetCommandLine","Str") ~= " /restart(?!\S)"))
			Try RunWait '*RunAs "' A_AhkPath '" /script /restart "' A_ScriptFullPath '"'
		if !A_IsAdmin {
			MsgBox "You must run Natro Macro as administrator in this folder!`nIf you don't want to do this, move the macro to a different folder (e.g. Downloads, Desktop)", "Error", 0x40010
			ExitApp
		}
		; elevated but still can't write, read-only directory?
		MsgBox "You cannot run Natro Macro in this folder!`nTry moving the macro to a different folder (e.g. Downloads, Desktop)", "Error", 0x40010
	}
	else
		file.Close()
}

; close any remnant running natro scripts and start heartbeat
CloseScripts(hb:=0) {
	list := WinGetList("ahk_class AutoHotkey ahk_exe " exe_path32)
	if (exe_path32 != exe_path64)
		list.Push(WinGetList("ahk_class AutoHotkey ahk_exe " exe_path64)*)
	for hwnd in list
		if !((hwnd = A_ScriptHwnd) || ((hb = 1) && A_Args.Has(2) && (hwnd = A_Args[2])))
			try WinClose "ahk_id " hwnd
}

; CREATE SETTINGS FOLDERS
nm_CreateFolder(folder) {
	if !FileExist(folder)
	{
		try
			DirCreate folder
		catch
			MsgBox
			(
			'Could not create the ' folder ' directory!
			This means the macro will NOT work correctly!
			Try moving the macro to a different folder (e.g. Downloads, Desktop)'
			), "Error", 0x40010 " T60"
	}
}


; import patterns and syntax check
nm_importPatterns()
{
	global patterns := Map()
	patterns.CaseSense := 0
	global patternlist := []

	installedPatternHashes := []



	if FileExist("settings\imported\patterns.ahk")
		file := FileOpen("settings\imported\patterns.ahk", "r"), imported := file.Read(), file.Close()
	else
		imported := ""

	if FileExist("settings\imported\patternHashes.ahk")
		getHashes()
	else
		hashDefaults()

	import := ""
	Loop Files A_WorkingDir "\patterns\*.ahk"
	{
		bypassWarning := 0
		file := FileOpen(A_LoopFilePath, "r"), pattern := file.Read(), file.Close()
		if RegexMatch(pattern, "im)patterns\[")
			MsgBox
			(
			"Pattern '" A_LoopFileName "' seems to be deprecated!
			This means the pattern will NOT work!
			Check for an updated version of the pattern
			or ask the creator to update it"
			), "Error", 0x40010 " T60"
		if !InStr(imported, imported_pattern := '("' (pattern_name := StrReplace(A_LoopFileName, "." A_LoopFileExt)) '")`r`n' pattern '`r`n`r`n')
		{
			patternhash := HashFile(A_LoopFilePath, 6)
			for hash in installedPatternHashes {
				if patternhash = hash {
					bypassWarning := 1
				}
			}
			if !bypassWarning {
				MsgBox(
					(
						'IMPORTANT!! READ THIS WHOLE MESSAGE

						Pattern files can execute any AutoHotkey code, including potentially malicious code.
						You should only run patterns from sources you trust.

						We provide a few sources for trusted pattern downloads, including:

						- Our discord server, in the #patterns channel
						- https://github.com/NatroTeam/Paths-Patterns, a collection of verified patterns

						We review every pattern or path submitted to these sources, so you can be sure that they are 100% safe.

						HOWEVER, you should not download a pattern from a stranger telling you to test out their pattern.
						If all else fails, just download it from the sources above.


						IMPORTANT!! READ THIS WHOLE MESSAGE
						'
					), "Pattern Import Warning", 0x40030
				)
				if (MsgBox("Do you FULLY trust the pattern " pattern_name " and want to import it?", "Pattern Import Confirmation", 0x40004 " T60") != "Yes")
					continue
			}
			script :=
			(
			'
			#NoTrayIcon
			#SingleInstance Off
			#Warn All, StdOut

			' nm_KeyVars() '

			size:=1, reps:=1, facingcorner:=0
			FieldName:=FieldPattern:=FieldPatternSize:=FieldReturnType:=FieldSprinklerLoc:=FieldRotateDirection:=""
			FieldUntilPack:=FieldPatternReps:=FieldPatternShift:=FieldSprinklerDist:=FieldRotateTimes:=FieldDriftCheck:=FieldPatternInvertFB:=FieldPatternInvertLR:=FieldUntilMins:=0

			Walk(param1, param2?) => ""
			HyperSleep(param1) => ""
			nm_Walk(param1, param2, param3?) => ""
			Gdip_ImageSearch(*) => ""
			Gdip_BitmapFromBase64(*) => ""
			nm_CameraRotation(param1, param2) => ""

			' pattern '

			'
			)

			exec := ComObject("WScript.Shell").Exec('"' exe_path64 '" /script /Validate /ErrorStdOut *'), exec.StdIn.Write(script), exec.StdIn.Close()
			if (stdout := exec.StdOut.ReadAll())
			{
				MsgBox
				(
				"Unable to import '" pattern_name "' pattern!
				Click 'OK' to continue loading the macro without this pattern installed, otherwise fix the error and reload the macro.

				The error found on loading is stated below:
				" stdout
				), "Unable to Import Pattern!", 0x40010 " T60"
				continue
			}
		}

		import .= imported_pattern
		patternlist.Push(pattern_name)
		patterns[pattern_name] := pattern
	}

	if (import != imported)
		file := FileOpen(A_WorkingDir "\settings\imported\patterns.ahk", "w-d"), file.Write(import), file.Close()


	hashDefaults(){
		hashes := []

		output := FileOpen(A_WorkingDir "\settings\imported\patternHashes.ahk", "w-d")

		loop files "patterns/*.ahk" {
			fileHash := HashFile(A_LoopFileFullPath, 6)
			hashes.push(fileHash)
		}

		output.Write(JSON.stringify(hashes))
		output.Close()
		installedPatternHashes := hashes
	}
	getHashes() => (installedPatternHashes := JSON.parse(FileRead("settings\imported\patternHashes.ahk")))
}

nm_importPaths()
{
	static path_names := Map(
		"gtb", ["blue", "mountain", "red"], ; go to (field) booster
		"gtc", ["clock", "antpass", "robopass", "honeydis", "treatdis", "blueberrydis", "strawberrydis", "coconutdis", "gluedis", "royaljellydis", "blender", "windshrine", ; go to collect (machine)
				"stockings", "wreath", "feast", "gingerbread", "snowmachine", "candles", "samovar", "lidart", "gummybeacon", "rbpdelevel", ; beesmas
				"honeylb", "honeystorm", "stickerstack", "stickerprinter", "normalmm", "megamm", "nightmm", "extrememm", "wintermm"], ; other
		"gtf", ["bamboo", "blueflower", "cactus", "clover", "coconut", "dandelion", "mountaintop", "mushroom", "pepper", "pinetree", "pineapple", "pumpkin",
				"rose", "spider", "strawberry", "stump", "sunflower"], ; go to field
		"gtp", ["bamboo", "blueflower", "cactus", "clover", "coconut", "dandelion", "mountaintop", "mushroom", "pepper", "pinetree", "pineapple", "pumpkin",
				"rose", "spider", "strawberry", "stump", "sunflower"], ; go to planter
		"gtq", ["black", "brown", "bucko", "honey", "polar", "riley"], ; go to questgiver
		"wf",  ["bamboo", "blueflower", "cactus", "clover", "coconut", "dandelion", "mountaintop", "mushroom", "pepper", "pinetree", "pineapple", "pumpkin",
				"rose", "spider", "strawberry", "stump", "sunflower"]  ; walk from (field to hive)
	)

	global paths := Map()
	paths.CaseSense := 0

	for k, list in path_names
	{
		(paths[k] := Map()).CaseSense := 0
		for v in list
		{
			try {
				file := FileOpen(A_WorkingDir "\paths\" k "-" v ".ahk", "r"), paths[k][v] := file.Read(), file.Close()
				if regexMatch(paths[k][v], "im)paths\[")
					MsgBox
					(
					"Path '" k '-' v "' seems to be deprecated!
					This means the macro will NOT work correctly!
					Check for an updated version of the path or
					restore the default path"
					), "Error", 0x40010 " T60"
			}
			catch
				MsgBox
				(
				"Could not find the '" k '-' v "' path!
				This means the macro will NOT work correctly!
				Make sure the path exists in the 'paths' folder and redownload if it doesn't!"
				), "Error", 0x40010 " T60"
		}
	}
}

nm_ReadIni(path)
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

nm_ReadIniSection(path, section)
{
	global
	local ini, str, c, p, k, v
	local readVals := 0

	ini := FileOpen(path, "r"), str := ini.Read(), ini.Close()
	Loop Parse str, "`n", "`r" A_Space A_Tab
	{
		switch (c := SubStr(A_LoopField, 1))
		{
			;locate ini section
			case "[" section "]":
			readVals:=1
			continue

			;read section data
			default:
			if (readVals) {
				if (p := InStr(A_LoopField, "=")) {
					try k := SubStr(A_LoopField, 1, p-1), %k% := IsInteger(v := SubStr(A_LoopField, p+1)) ? Integer(v) : v
				} else { ;done reading section
					break
				}
			}
		}
	}
}

; auxiliary map/array functions
ObjFullyClone(obj)
{
	nobj := obj.Clone()
	for k,v in nobj
		if IsObject(v)
			nobj[k] := ObjFullyClone(v)
	return nobj
}
ObjHasValue(obj, value)
{
	for k,v in obj
		if (v = value)
			return 1
	return 0
}
ObjMinIndex(obj)
{
	for k,v in obj
		return k
	return 0
}

; DEFAULT ROBLOX TYPE/PATH DETECTION
nm_GetRobloxUWPPath()
{
	try {
		loop Reg, "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppModel\Repository\Packages", "K" {
			if InStr(StrLower(A_LoopRegName),"robloxcorporation") {
				exePath := "C:\Program Files\WindowsApps\" A_LoopRegName "\Windows10Universal.exe"
				if FileExist(exePath)
					return exePath
				exePath := "C:\XboxGames\Roblox\Content\RobloxPlayerBeta.exe"
				if FileExist(exePath)
					return exePath
			}
		}
	}
}

RobloxTypes := {
	UWP: "UWP Version",
	Bootstrapper: "Bootstrapper (Web)",
	Web: "Web Version",
	Custom: "Custom/Unknown (Web)",
	NotFound: "Not found"
}

nm_DetectRobloxType()
{
	robloxpath := defaultapp := ""

	try robloxpath := nm_GetRobloxWebPath()
	if robloxpath {
		switch {
			case robloxpath ~= "i)[a-z]+strap":
				return RobloxTypes.Bootstrapper
			case InStr(robloxpath, "RobloxPlayerBeta"):
				return RobloxTypes.Web
			case robloxpath:
				return RobloxTypes.Custom
		}
	}

	if nm_GetRobloxUWPPath()
		return RobloxTypes.UWP

	return RobloxTypes.NotFound
}

; DETECT INCORRECT ROBLOX SETTINGS
JoinArray(arr, sep := "`n") {
    out := ""
    for i, val in arr
        out .= (i > 1 ? sep : "") val
    return out
}
nm_LocateRobloxSettingsXML(robloxtype)
{
	static localappdata := EnvGet("LOCALAPPDATA")
	try switch robloxtype {
		case RobloxTypes.Custom, RobloxTypes.Web, RobloxTypes.Bootstrapper:
			Loop Files, localappdata "\Roblox\GlobalBasicSettings_*.xml", "F"
				if !InStr(A_LoopFileName, "Studio")
					return A_LoopFileFullPath
		case RobloxTypes.UWP:
			Loop Files, localappdata "\Packages\ROBLOXCORPORATION.ROBLOX_" StrReplace(StrSplit(nm_GetRobloxUWPPath(),"__")[2], "\Windows10Universal.exe") "\LocalState\GlobalBasicSettings_*.xml", "F"
				return A_LoopFileFullPath
			Loop Files, localappdata "\RobloxPCGDK\GlobalBasicSettings_*.xml", "F"
				return A_LoopFileFullPath
	}
}
;//todo: add checkProblem() conditions from debug log
nm_MsgBoxIncorrectRobloxSettings()
{
	global IgnoreIncorrectRobloxSettings
	static RecommendedRobloxSettings := Map(
		"Correct", Map(
			"All", Map(
				'"GraphicsQualityLevel">3', "Set Graphics Quality to LOWEST",
				'"PreferredTextSize">1', 'Set Text Size to LOWEST'
			),
			"UWP Version", Map(),
			"Web Version", Map(
				'"ControlMode">1', 'Turn ON Shift Lock'
			)
		),
		"Incorrect", Map(
			"All", Map(
				'"CameraYInverted">true', 'Turn OFF Inverted Camera',
				'"OnScreenProfilerEnabled">true', 'Turn OFF Microprofiler',
				'"ComputerCameraMovementMode">2', 'Set Camera Mode to CLASSIC',
				'"ComputerMovementMode">2', 'Set Movement Mode to KEYBOARD',
				'"GraphicsQualityLevel">0', "Switch to MANUAL Graphics"
			),
			"UWP Version", Map(
				'"Fullscreen">true', 'Turn OFF Fullscreen',
				'"ControlMode">1', 'Turn OFF Shift Lock'
			),
			"Web Version", Map()
		)
	)

	GuiClose(*){
		if (IsSet(IncSettingsGui) && IsObject(AFBGIncSettingsGuiui))
			IncSettingsGui.Destroy(), IncSettingsGui := ""
	}
	GuiClose()
	if IgnoreIncorrectRobloxSettings
		return 0
	robloxtype := nm_DetectRobloxType()
	xmlpath := nm_LocateRobloxSettingsXML(robloxtype)
	if !xmlpath
		return 0
	xml := FileRead(xmlpath)
	recommendations := []
	for tier, tiermap in RecommendedRobloxSettings {
		for platform, platformmap in tiermap {
			if platform = "All" || platform = robloxtype || (platform = "Web Version" && robloxtype != RobloxTypes.UWP)
				for xmltext, recommendation in platformmap {
					if tier = "Incorrect" && InStr(xml, xmltext)
						recommendations.Push("- " recommendation)
					else if tier = "Correct" && !InStr(xml, xmltext)
						recommendations.Push("- " recommendation)
				}
		}
	}
	if recommendations.Length {
		rectext := JoinArray(recommendations, "`n")
		IncSettingsGui := Gui("+AlwaysOnTop +Owner" MainGui.Hwnd, "Incorrect Roblox Settings Detected")
		IncSettingsGui.SetFont("s9", "Tahoma")
		IncSettingsGui.OnEvent("Close", (*) => GuiClose())
		IncSettingsGui.SetFont("Bold s10 c" (robloxtype = RobloxTypes.NotFound || robloxtype = RobloxTypes.UWP ? "Red" : "0a7e00"), "Tahoma")
		IncSettingsGui.Add("Text", "x10 y10 w400 +Center", "Default Roblox Installation: " robloxtype)
		IncSettingsGui.SetFont("s9 cDefault", "Tahoma")
		IncSettingsGui.Add("Text", "x10 y40 w400 +BackgroundTrans", "The detected Roblox installation might have incorrect settings, please do these:")
		IncSettingsGui.SetFont("s9 cRed", "Tahoma")
		IncSettingsGui.Add("Text", "x10 y70 w400 r" recommendations.Length " +BackgroundTrans", rectext)
		IncSettingsGui.SetFont("s8 cDefault", "Tahoma")
		IncSettingsGui.Add("Text", "x10 y" (80 + 14 * recommendations.Length) " w400 +BackgroundTrans", "You can safely ignore this message if you have already changed them.")
		IncSettingsGui.SetFont("s9", "Tahoma")
		IncSettingsGui.Add("CheckBox", "x10 y" (110 + 14 * recommendations.Length) " w200 vIncorrectSettingsCheckbox", "Do not show again")
		IncSettingsGui.SetFont("s9 cDefault Norm", "Tahoma")
		IncSettingsGui.Add("Button", "x320 y" (110 + 14 * recommendations.Length) " w90 h28 Default", "OK").OnEvent("Click"
		, (*) => (
			IncSettingsGui["IncorrectSettingsCheckbox"].Value
				? (MsgBox("You ticked the 'Do not show again' checkbox, which means you won't get any warning messages about incorrect Roblox settings anymore. Are you sure that you want to do this?", "Are you sure?", 0x1034) = "Yes"
					? (IniWrite((IgnoreIncorrectRobloxSettings := 1), "settings\nm_config.ini", "Settings", "IgnoreIncorrectRobloxSettings"), IncSettingsGui.Destroy())
					: "")
				: (IncSettingsGui.Destroy(), IgnoreIncorrectRobloxSettings := 1) ; disable for this session
		))
		IncSettingsGui.Show("AutoSize Center")
		return 1
	}
	return 0
}

; AUTO-UPDATE
nm_AutoUpdateHandler(req)
{
	global
	local release, releases

	if (req.readyState != 4)
		return

	if (req.status = 200)
	{
		; determine release channel

		releases := JSON.parse(req.responseText)
		for , release in releases
		{
			if (
				release["prerelease"] = true && ReleaseChannel = "Beta"
				|| release["prerelease"] = false
			) && (
				IsObject(release["assets"]) && release["assets"].Length > 0
			) {
				latest_release := release
				break
			}
			; should only be here if latest is pre release + on stable channel
		}
		if !IsSet(latest_release)
			latest_release := releases[1] ; should never happen unless we publish 30+ betas

		LatestVer := Trim(latest_release["tag_name"], "v")
		if (VerCompare(VersionID, LatestVer) < 0)
		{
			MainGui["ImageUpdateLink"].Visible := 1
			VersionWidth += 16
			MainGui["VersionText"].Move(494 - VersionWidth), MainGui["VersionText"].Redraw()
			MainGui["ImageGitHubLink"].Move(494 - VersionWidth - 23), MainGui["ImageGitHubLink"].Redraw()
			MainGui["ImageDiscordLink"].Move(494 - VersionWidth - 48), MainGui["ImageDiscordLink"].Redraw()
			try MainGui["SecretButton"].Move(494-VersionWidth-104), MainGui["SecretButton"].Redraw()

			if (LatestVer != IgnoreUpdateVersion)
				nm_AutoUpdateGUI()
		}
	}
}
nm_AutoUpdateGUI(*)
{
	global
	local size, downloads, posW, hBM, UpdateText, GuiCtrl
	GuiClose(*){
		if (IsSet(UpdateGui) && IsObject(UpdateGui))
			UpdateGui.Destroy(), UpdateGui := ""
	}
	GuiClose()
	UpdateGui := Gui("+AlwaysOnTop -MinimizeBox +Owner" MainGui.Hwnd, "Natro Macro Update")
	UpdateGui.OnEvent("Close", GuiClose), UpdateGui.OnEvent("Escape", GuiClose)
	UpdateGui.SetFont("s9 cDefault Norm", "Tahoma")
	UpdateText := UpdateGui.Add("Text", "x20 w260 +Center +BackgroundTrans", "A newer version of Natro Macro was found!`nDo you want to update now?")

	posW := TextExtent("Natro Macro v" VersionID " ⮕ v" LatestVer, UpdateText)
	UpdateGui.Add("Text", "x" 149-posW//2 " y40 +BackgroundTrans", "Natro Macro v" VersionID " ⮕ ")
	UpdateGui.Add("Text", "x+0 yp +c379e37 +BackgroundTrans", "v" LatestVer)

	posW := TextExtent((size := Round(latest_release["assets"][1]["size"]/1048576, 2)) " MB // Downloads: " (downloads := latest_release["assets"][1]["download_count"]), UpdateText)
	UpdateGui.Add("Text", "x" 150-posW//2 " y54 +BackgroundTrans", size " MB // Downloads: " downloads)

	hBM := Gdip_CreateHBITMAPFromBitmap(bitmaps["githubgui"]), UpdateGui.Add("Picture", "x76 y+1 w16 h16 +BackgroundTrans", "HBITMAP:*" hBM).OnEvent("Click", GitHubRepoLink), DllCall("DeleteObject", "ptr", hBM)
	UpdateGui.Add("Text", "x+4 yp+1 c0046ee +BackgroundTrans", "Patch Notes && Updates").OnEvent("Click", GitHubReleaseLink)

	UpdateGui.SetFont("s8 w700")
	local MajorUpdate := (StrSplit(VersionID, ".")[1] < StrSplit(LatestVer, ".")[1])
	UpdateGui.Add("GroupBox", "x50 y+4 w200 h" (MajorUpdate ? 74 : 50), "Options")
	UpdateGui.SetFont("Norm")
	UpdateGui.Add("CheckBox", "xp+8 yp+16 Checked vCopySettings", "Copy Settings")
	UpdateGui.Add("CheckBox", "xp+92 yp vCopyPatterns Checked" (!MajorUpdate) " Disabled" MajorUpdate, "Copy Patterns")
	UpdateGui.Add("CheckBox", "xp-92 yp+16 vCopyPaths Checked" (!MajorUpdate) " Disabled" MajorUpdate, "Copy Paths")
	UpdateGui.Add("CheckBox", "xp+92 yp vDeleteOld", "Delete v" VersionID)
	if MajorUpdate
		UpdateGui.Add("Button", "x60 y+5 w180 h18", "Why are some options disabled?").OnEvent("Click", nm_MajorUpdateHelp)

	UpdateGui.SetFont("s9")
	UpdateGui.Add("Button", "x8 y+12 w92 h26", "Never").OnEvent("Click", nm_NeverButton)
	UpdateGui.Add("Button", "xp+96 yp wp hp vDismissButton", "Dismiss (120)").OnEvent("Click", nm_DismissButton)
	SetTimer nm_DismissLabel, -1000

	UpdateGui.SetFont("Bold")
	(GuiCtrl := UpdateGui.Add("Button", "xp+96 yp wp hp", "Update")).OnEvent("Click", nm_UpdateButton)
	UpdateGui.Show("w290 h168")
	GuiCtrl.Focus()
	WinWaitClose "ahk_id " UpdateGui.Hwnd, , 125
	GuiClose()
}
nm_DismissLabel()
{
	static countdown := unset
	global UpdateGUI
	if !IsSet(countdown)
		countdown := 120

	if UpdateGui {
		if (--countdown <= 0) {
			countdown := unset
			UpdateGui.Destroy()
		} else {
			UpdateGui["DismissButton"].Text := "Dismiss (" countdown ")"
			SetTimer nm_DismissLabel, -1000
		}
	}
	else
		countdown := unset
}
nm_DismissButton(*)
{
	global UpdateGui
	UpdateGui.Destroy(), UpdateGui := ""
}
nm_NeverButton(*)
{
	global UpdateGui
	if (MsgBox(
	(
	"Are you sure you want to disable prompts for v" LatestVer "?
	You can still update manually, or by clicking the red symbol in the bottom right corner of the GUI."
	), "Disable Automatic Update", 0x1044 " Owner" UpdateGui.Hwnd) = "Yes")
	{
		IniWrite (IgnoreUpdateVersion := LatestVer), "settings\nm_config.ini", "Settings", "IgnoreUpdateVersion"
		UpdateGui.Destroy(), UpdateGui := ""
	}
}
nm_UpdateButton(*)
{
	global latest_release, VersionID, UpdateGui
	url := latest_release["assets"][1]["browser_download_url"]
	olddir := A_WorkingDir
	CopySettings := UpdateGui["CopySettings"].Value
	CopyPatterns := UpdateGui["CopyPatterns"].Value
	CopyPaths := UpdateGui["CopyPaths"].Value
	DeleteOld := UpdateGui["DeleteOld"].Value
	changedpaths := ""
	UpdateGui.Destroy(), UpdateGui := ""

	if (CopyPaths = 1)
	{
		try
		{
			wr := ComObject("WinHttp.WinHttpRequest.5.1")
			wr.Open("GET", "https://api.github.com/repos/NatroTeam/NatroMacro/tags?per_page=100", 1)
			wr.SetRequestHeader("accept", "application/vnd.github+json")
			wr.SetRequestHeader("X-GitHub-Api-Version", "2022-11-28")
			wr.Send()
			wr.WaitForResponse()
			for k,v in (tags := JSON.parse(wr.ResponseText))
				if ((VerCompare(Trim(v["name"], "v"), VersionID) <= 0) && (base := v["name"]))
					break
			if !base
				throw

			wr := ComObject("WinHttp.WinHttpRequest.5.1")
			wr.Open("GET", "https://api.github.com/repos/NatroTeam/NatroMacro/compare/" base "..." latest_release["tag_name"] , 1)
			wr.SetRequestHeader("accept", "application/vnd.github+json")
			wr.SetRequestHeader("X-GitHub-Api-Version", "2022-11-28")
			wr.Send()
			wr.WaitForResponse()
			for k,v in (files := JSON.parse(wr.ResponseText)["files"])
				if (SubStr(v["filename"], 1, 6) = "paths/")
					changedpaths .= '"' SubStr(v["filename"], 7) '" '
			changedpaths := RTrim(changedpaths)
		}
		catch
		{
			MsgBox "Unable to fetch changed paths from GitHub!`nIf you still want to update, disable 'Copy Paths' (and copy them manually) or try again later.", "Error", 0x1010 " T30"
			return
		}
	}

	Run '"' A_WorkingDir '\submacros\update.bat" "' url '" "' olddir '" "' CopySettings '" "' CopyPatterns '" "' CopyPaths '" "' DeleteOld '" "' changedpaths '"'
	ExitApp
}
nm_MajorUpdateHelp(*)
{
	MsgBox "v" VersionID " to v" LatestVer " is a major version update.`n`n"
	. "This means that backward compatibility of Paths and Patterns cannot be guaranteed, so they cannot be automatically copied.`n"
	. "However, in Natro Macro, your Settings are guaranteed to be transferable to any new version, so that option remains enabled.`n`n"
	. "For more information, you can review the convention at https://semver.org/", "Major Update", 0x1040
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; GUI FUNCTIONS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;buttons
nm_StartButton(GuiCtrl, *){
	MouseGetPos , , , &hCtrl, 2
	if (hCtrl = GuiCtrl.Hwnd)
		SetTimer start, -50
}
nm_PauseButton(GuiCtrl, *){
	MouseGetPos , , , &hCtrl, 2
	if (hCtrl = GuiCtrl.Hwnd)
		return nm_pause()
}
nm_StopButton(GuiCtrl, *){
	MouseGetPos , , , &hCtrl, 2
	if (hCtrl = GuiCtrl.Hwnd)
		return stop()
}
nm_CustomizeButton(GuiCtrl, *){
	MouseGetPos , , , &hCtrl, 2
	if (hCtrl = GuiCtrl.Hwnd)
		return nm_customizeGui()
}

;save GUI position (on exit)
nm_saveGUIPos(){
	global GuiX, GuiY
	wp := Buffer(44)
	DllCall("GetWindowPlacement", "UInt", MainGui.Hwnd, "Ptr", wp)
	x := NumGet(wp, 28, "Int"), y := NumGet(wp, 32, "Int")
	if (x > 0)
		try IniWrite x, "settings\nm_config.ini", "Settings", "GuiX"
	if (y > 0)
		try IniWrite y, "settings\nm_config.ini", "Settings", "GuiY"
}

;tab (un)lock
nm_LockTabs(lock:=1){
	static tabs := ["Gather","Collect","Boost","Quests","Planters","Status","Settings","Misc"]
	global bitmaps

	;controls outside tabs
	if (lock = 1)
	{
		MainGui["CurrentFieldUp"].Enabled := 0
		MainGui["CurrentFieldDown"].Enabled := 0
		try MainGui["SecretButton"].Enabled := 0

		pBM := Gdip_BitmapConvertGray(bitmaps["discordgui"]), hBM := Gdip_CreateHBITMAPFromBitmap(pBM)
		MainGui["ImageDiscordLink"].Value := "HBITMAP:*" hBM, MainGui["ImageDiscordLink"].OnEvent("Click", DiscordLink, 0)
		Gdip_DisposeImage(pBM), DllCall("DeleteObject", "Ptr", hBM)

		MainGui["ImageGitHubLink"].OnEvent("Click", GitHubRepoLink, 0)

		c := "Lock"
	}
	else
	{
		MainGui["CurrentFieldUp"].Enabled := 1
		MainGui["CurrentFieldDown"].Enabled := 1
		try MainGui["SecretButton"].Enabled := 1

		hBM := Gdip_CreateHBITMAPFromBitmap(bitmaps["discordgui"])
		MainGui["ImageDiscordLink"].Value := "HBITMAP:*" hBM, MainGui["ImageDiscordLink"].OnEvent("Click", DiscordLink)
		DllCall("DeleteObject", "Ptr", hBM)

		MainGui["ImageGitHubLink"].OnEvent("Click", GitHubRepoLink)

		c := "UnLock"
	}

	for i,tab in tabs
		nm_Tab%tab%%c%()
}
nm_TabGatherLock(){
	global
	local hBM := Gdip_CreateHBITMAPFromBitmap(bitmaps["savefielddisabled"])
	MainGui["FieldName1"].Enabled := 0
	MainGui["FieldPattern1"].Enabled := 0
	MainGui["FieldPatternSize1UpDown"].Enabled := 0
	MainGui["FieldPatternReps1"].Enabled := 0
	MainGui["FieldPatternShift1"].Enabled := 0
	MainGui["FieldPatternInvertFB1"].Enabled := 0
	MainGui["FieldPatternInvertLR1"].Enabled := 0
	MainGui["FieldUntilMins1"].Enabled := 0
	MainGui["FieldUntilPack1UpDown"].Enabled := 0
	MainGui["FieldSprinklerDist1"].Enabled := 0
	MainGui["FieldRotateTimes1"].Enabled := 0
	MainGui["FieldDriftCheck1"].Enabled := 0
	MainGui["FRD1Left"].Enabled := 0
	MainGui["FRD1Right"].Enabled := 0
	MainGui["FRT1Left"].Enabled := 0
	MainGui["FRT1Right"].Enabled := 0
	MainGui["FSL1Left"].Enabled := 0
	MainGui["FSL1Right"].Enabled := 0
	MainGui["FDCHelp1"].Enabled := 0
	MainGui["CopyGather1"].Enabled := 0
	MainGui["PasteGather1"].Enabled := 0
	MainGui["SaveFieldDefault1"].Enabled := 0
	MainGui["SaveFieldDefault1"].Value := "HBITMAP:*" hBM
	MainGui["FieldName2"].Enabled := 0
	MainGui["FieldPattern2"].Enabled := 0
	MainGui["FieldPatternSize2UpDown"].Enabled := 0
	MainGui["FieldPatternReps2"].Enabled := 0
	MainGui["FieldPatternShift2"].Enabled := 0
	MainGui["FieldPatternInvertFB2"].Enabled := 0
	MainGui["FieldPatternInvertLR2"].Enabled := 0
	MainGui["FieldUntilMins2"].Enabled := 0
	MainGui["FieldUntilPack2UpDown"].Enabled := 0
	MainGui["FieldSprinklerDist2"].Enabled := 0
	MainGui["FieldRotateTimes2"].Enabled := 0
	MainGui["FieldDriftCheck2"].Enabled := 0
	MainGui["FRD2Left"].Enabled := 0
	MainGui["FRD2Right"].Enabled := 0
	MainGui["FRT2Left"].Enabled := 0
	MainGui["FRT2Right"].Enabled := 0
	MainGui["FSL2Left"].Enabled := 0
	MainGui["FSL2Right"].Enabled := 0
	MainGui["FDCHelp2"].Enabled := 0
	MainGui["CopyGather2"].Enabled := 0
	MainGui["PasteGather2"].Enabled := 0
	MainGui["SaveFieldDefault2"].Enabled := 0
	MainGui["SaveFieldDefault2"].Value := "HBITMAP:*" hBM
	MainGui["FieldName3"].Enabled := 0
	MainGui["FieldPattern3"].Enabled := 0
	MainGui["FieldPatternSize3UpDown"].Enabled := 0
	MainGui["FieldPatternReps3"].Enabled := 0
	MainGui["FieldPatternShift3"].Enabled := 0
	MainGui["FieldPatternInvertFB3"].Enabled := 0
	MainGui["FieldPatternInvertLR3"].Enabled := 0
	MainGui["FieldUntilMins3"].Enabled := 0
	MainGui["FieldUntilPack3UpDown"].Enabled := 0
	MainGui["FieldSprinklerDist3"].Enabled := 0
	MainGui["FieldRotateTimes3"].Enabled := 0
	MainGui["FieldDriftCheck3"].Enabled := 0
	MainGui["FRD3Left"].Enabled := 0
	MainGui["FRD3Right"].Enabled := 0
	MainGui["FRT3Left"].Enabled := 0
	MainGui["FRT3Right"].Enabled := 0
	MainGui["FSL3Left"].Enabled := 0
	MainGui["FSL3Right"].Enabled := 0
	MainGui["FDCHelp3"].Enabled := 0
	MainGui["CopyGather3"].Enabled := 0
	MainGui["PasteGather3"].Enabled := 0
	MainGui["SaveFieldDefault3"].Enabled := 0
	MainGui["SaveFieldDefault3"].Value := "HBITMAP:*" hBM
}
nm_TabGatherUnLock(){
	global
	local hBM := Gdip_CreateHBITMAPFromBitmap(bitmaps["savefield"])
	MainGui["FieldName1"].Enabled := 1
	MainGui["FieldName2"].Enabled := 1
	MainGui["FieldPattern1"].Enabled := 1
	MainGui["FieldPatternSize1UpDown"].Enabled := 1
	MainGui["FieldPatternReps1"].Enabled := 1
	MainGui["FieldPatternShift1"].Enabled := 1
	MainGui["FieldPatternInvertFB1"].Enabled := 1
	MainGui["FieldPatternInvertLR1"].Enabled := 1
	MainGui["FieldUntilMins1"].Enabled := 1
	MainGui["FieldUntilPack1UpDown"].Enabled := 1
	MainGui["FieldSprinklerDist1"].Enabled := 1
	MainGui["FieldRotateTimes1"].Enabled := 1
	MainGui["FieldDriftCheck1"].Enabled := 1
	MainGui["FRD1Left"].Enabled := 1
	MainGui["FRD1Right"].Enabled := 1
	MainGui["FRT1Left"].Enabled := 1
	MainGui["FRT1Right"].Enabled := 1
	MainGui["FSL1Left"].Enabled := 1
	MainGui["FSL1Right"].Enabled := 1
	MainGui["FDCHelp1"].Enabled := 1
	MainGui["CopyGather1"].Enabled := 1
	MainGui["PasteGather1"].Enabled := 1
	MainGui["PasteGather2"].Enabled := 1
	MainGui["SaveFieldDefault1"].Enabled := 1
	MainGui["SaveFieldDefault1"].Value := "HBITMAP:*" hBM
	if(FieldName2!="none"){
		MainGui["FieldName3"].Enabled := 1
		MainGui["FieldPattern2"].Enabled := 1
		MainGui["FieldPatternSize2UpDown"].Enabled := 1
		MainGui["FieldPatternReps2"].Enabled := 1
		MainGui["FieldPatternShift2"].Enabled := 1
		MainGui["FieldPatternInvertFB2"].Enabled := 1
		MainGui["FieldPatternInvertLR2"].Enabled := 1
		MainGui["FieldUntilMins2"].Enabled := 1
		MainGui["FieldUntilPack2UpDown"].Enabled := 1
		MainGui["FieldSprinklerDist2"].Enabled := 1
		MainGui["FieldRotateTimes2"].Enabled := 1
		MainGui["FieldDriftCheck2"].Enabled := 1
		MainGui["FRD2Left"].Enabled := 1
		MainGui["FRD2Right"].Enabled := 1
		MainGui["FRT2Left"].Enabled := 1
		MainGui["FRT2Right"].Enabled := 1
		MainGui["FSL2Left"].Enabled := 1
		MainGui["FSL2Right"].Enabled := 1
		MainGui["FDCHelp2"].Enabled := 1
		MainGui["CopyGather2"].Enabled := 1
		MainGui["PasteGather3"].Enabled := 1
		MainGui["SaveFieldDefault2"].Enabled := 1
		MainGui["SaveFieldDefault2"].Value := "HBITMAP:*" hBM
	}
	if(FieldName3!="none"){
		MainGui["FieldPattern3"].Enabled := 1
		MainGui["FieldPatternSize3UpDown"].Enabled := 1
		MainGui["FieldPatternReps3"].Enabled := 1
		MainGui["FieldPatternShift3"].Enabled := 1
		MainGui["FieldPatternInvertFB3"].Enabled := 1
		MainGui["FieldPatternInvertLR3"].Enabled := 1
		MainGui["FieldUntilMins3"].Enabled := 1
		MainGui["FieldUntilPack3UpDown"].Enabled := 1
		MainGui["FieldSprinklerDist3"].Enabled := 1
		MainGui["FieldRotateTimes3"].Enabled := 1
		MainGui["FieldDriftCheck3"].Enabled := 1
		MainGui["FRD3Left"].Enabled := 1
		MainGui["FRD3Right"].Enabled := 1
		MainGui["FRT3Left"].Enabled := 1
		MainGui["FRT3Right"].Enabled := 1
		MainGui["FSL3Left"].Enabled := 1
		MainGui["FSL3Right"].Enabled := 1
		MainGui["FDCHelp3"].Enabled := 1
		MainGui["CopyGather3"].Enabled := 1
		MainGui["SaveFieldDefault3"].Enabled := 1
		MainGui["SaveFieldDefault3"].Value := "HBITMAP:*" hBM
	}
	DllCall("DeleteObject", "ptr", hBM)
}
nm_TabCollectLock(){
	global
	;collect
	MainGui["BlenderAddSlot"].Enabled := 0
	MainGui["BlenderAdd1"].Enabled := 0
	MainGui["BlenderAdd2"].Enabled := 0
	MainGui["BlenderAdd3"].Enabled := 0
	MainGui["BlenderAmount"].Enabled := 0
	MainGui["BlenderIndex"].Enabled := 0
	MainGui["BlenderIndexOption"].Enabled := 0
	MainGui["BlenderLeft"].Enabled := 0
	MainGui["BlenderRight"].Enabled := 0
	MainGui["ClockCheck"].Enabled := 0
	MainGui["MondoBuffCheck"].Enabled := 0
	MainGui["MondoSecs"].Enabled := 0
	MainGui["MLDLeft"].Enabled := 0
	MainGui["MLDRight"].Enabled := 0
	MainGui["MALeft"].Enabled := 0
	MainGui["MARight"].Enabled := 0
	MainGui["RoboPassCheck"].Enabled := 0
	MainGui["HoneystormCheck"].Enabled := 0
	MainGui["AntPassCheck"].Enabled := 0
	MainGui["AntPassBuyCheck"].Enabled := 0
	MainGui["APALeft"].Enabled := 0
	MainGui["APARight"].Enabled := 0
	MainGui["HoneyDisCheck"].Enabled := 0
	MainGui["TreatDisCheck"].Enabled := 0
	MainGui["BlueberryDisCheck"].Enabled := 0
	MainGui["StrawberryDisCheck"].Enabled := 0
	MainGui["CoconutDisCheck"].Enabled := 0
	MainGui["RoyalJellyDisCheck"].Enabled := 0
	MainGui["GlueDisCheck"].Enabled := 0
	MainGui["BeesmasGatherInterruptCheck"].Enabled := 0
	MainGui["StockingsCheck"].Enabled := 0
	MainGui["WreathCheck"].Enabled := 0
	MainGui["FeastCheck"].Enabled := 0
	MainGui["RBPDelevelCheck"].Enabled := 0
	MainGui["GingerbreadCheck"].Enabled := 0
	MainGui["SnowMachineCheck"].Enabled := 0
	MainGui["CandlesCheck"].Enabled := 0
	MainGui["WinterMemoryMatchCheck"].Enabled := 0
	MainGui["SamovarCheck"].Enabled := 0
	MainGui["LidArtCheck"].Enabled := 0
	MainGui["GummyBeaconCheck"].Enabled := 0
	MainGui["NormalMemoryMatchCheck"].Enabled := 0
	MainGui["MegaMemoryMatchCheck"].Enabled := 0
	MainGui["NightMemoryMatchCheck"].Enabled := 0
	MainGui["ExtremeMemoryMatchCheck"].Enabled := 0
	MainGui["MemoryMatchOptions"].Enabled := 0
	;kill
	MainGui["BugRunCheck"].Enabled := 0
	MainGui["MonsterRespawnTime"].Enabled := 0
	MainGui["MonsterRespawnTimeHelp"].Enabled := 0
	MainGui["BugrunInterruptCheck"].Enabled := 0
	MainGui["BugrunLadybugsCheck"].Enabled := 0
	MainGui["BugrunRhinoBeetlesCheck"].Enabled := 0
	MainGui["BugrunSpiderCheck"].Enabled := 0
	MainGui["BugrunMantisCheck"].Enabled := 0
	MainGui["BugrunScorpionsCheck"].Enabled := 0
	MainGui["BugrunWerewolfCheck"].Enabled := 0
	MainGui["BugrunLadybugsLoot"].Enabled := 0
	MainGui["BugrunRhinoBeetlesLoot"].Enabled := 0
	MainGui["BugrunSpiderLoot"].Enabled := 0
	MainGui["BugrunMantisLoot"].Enabled := 0
	MainGui["BugrunScorpionsLoot"].Enabled := 0
	MainGui["BugrunWerewolfLoot"].Enabled := 0
	MainGui["StingerCheck"].Enabled := 0
	MainGui["StingerDailyBonusCheck"].Enabled := 0
	MainGui["StingerCloverCheck"].Enabled := 0
	MainGui["StingerSpiderCheck"].Enabled := 0
	MainGui["StingerCactusCheck"].Enabled := 0
	MainGui["StingerRoseCheck"].Enabled := 0
	MainGui["StingerMountainTopCheck"].Enabled := 0
	MainGui["StingerPepperCheck"].Enabled := 0
	MainGui["TunnelBearCheck"].Enabled := 0
	MainGui["TunnelBearBabyCheck"].Enabled := 0
	MainGui["KingBeetleCheck"].Enabled := 0
	MainGui["KingBeetleBabyCheck"].Enabled := 0
	MainGui["KingBeetleAmuletMode"].Enabled := 0
	MainGui["CocoCrabCheck"].Enabled := 0
	MainGui["StumpSnailCheck"].Enabled := 0
	MainGui["ShellAmuletMode"].Enabled := 0
	MainGui["SnailHealthEdit"].Enabled := 0
	MainGui["SnailTimeUpDown"].Enabled := 0
	MainGui["CommandoCheck"].Enabled := 0
	MainGui["ChickLevel"].Enabled := 0
	MainGui["ChickHealthEdit"].Enabled := 0
	MainGui["ChickTimeUpDown"].Enabled := 0
	MainGui["BossConfigHelp"].Enabled := 0
}
nm_TabCollectUnLock(){
	global
	;collect
	MainGui["BlenderAddSlot"].Enabled := 1
	MainGui["BlenderAdd1"].Enabled := 1
	MainGui["BlenderAdd2"].Enabled := 1
	MainGui["BlenderAdd3"].Enabled := 1
	MainGui["BlenderAmount"].Enabled := 1
	MainGui["BlenderIndexOption"].Enabled := 1
	MainGui["BlenderIndex"].Enabled := 1
	MainGui["BlenderLeft"].Enabled := 1
	MainGui["BlenderRight"].Enabled := 1
	MainGui["ClockCheck"].Enabled := 1
	MainGui["MondoBuffCheck"].Enabled := 1
	MainGui["MondoSecs"].Enabled := 1
	MainGui["MLDLeft"].Enabled := 1
	MainGui["MLDRight"].Enabled := 1
	MainGui["MALeft"].Enabled := 1
	MainGui["MARight"].Enabled := 1
	MainGui["RoboPassCheck"].Enabled := 1
	MainGui["HoneystormCheck"].Enabled := 1
	MainGui["AntPassCheck"].Enabled := 1
	MainGui["AntPassBuyCheck"].Enabled := 1
	MainGui["APALeft"].Enabled := 1
	MainGui["APARight"].Enabled := 1
	MainGui["HoneyDisCheck"].Enabled := 1
	MainGui["TreatDisCheck"].Enabled := 1
	MainGui["BlueberryDisCheck"].Enabled := 1
	MainGui["StrawberryDisCheck"].Enabled := 1
	MainGui["CoconutDisCheck"].Enabled := 1
	MainGui["RoyalJellyDisCheck"].Enabled := 1
	MainGui["GlueDisCheck"].Enabled := 1
	if (beesmasActive = 1)
	{
		MainGui["BeesmasGatherInterruptCheck"].Enabled := 1
		MainGui["StockingsCheck"].Enabled := 1
		MainGui["WreathCheck"].Enabled := 1
		MainGui["FeastCheck"].Enabled := 1
		MainGui["RBPDelevelCheck"].Enabled := 1
		MainGui["GingerbreadCheck"].Enabled := 1
		MainGui["SnowMachineCheck"].Enabled := 1
		MainGui["CandlesCheck"].Enabled := 1
		MainGui["WinterMemoryMatchCheck"].Enabled := 1
		MainGui["SamovarCheck"].Enabled := 1
		MainGui["LidArtCheck"].Enabled := 1
		MainGui["GummyBeaconCheck"].Enabled := 1
	}
	MainGui["NormalMemoryMatchCheck"].Enabled := 1
	MainGui["MegaMemoryMatchCheck"].Enabled := 1
	MainGui["NightMemoryMatchCheck"].Enabled := 1
	MainGui["ExtremeMemoryMatchCheck"].Enabled := 1
	MainGui["MemoryMatchOptions"].Enabled := 1
	;kill
	MainGui["BugRunCheck"].Enabled := 1
	MainGui["MonsterRespawnTime"].Enabled := 1
	MainGui["MonsterRespawnTimeHelp"].Enabled := 1
	MainGui["BugrunInterruptCheck"].Enabled := 1
	MainGui["BugrunLadybugsCheck"].Enabled := 1
	MainGui["BugrunRhinoBeetlesCheck"].Enabled := 1
	MainGui["BugrunSpiderCheck"].Enabled := 1
	MainGui["BugrunMantisCheck"].Enabled := 1
	MainGui["BugrunScorpionsCheck"].Enabled := 1
	MainGui["BugrunWerewolfCheck"].Enabled := 1
	MainGui["BugrunLadybugsLoot"].Enabled := 1
	MainGui["BugrunRhinoBeetlesLoot"].Enabled := 1
	MainGui["BugrunSpiderLoot"].Enabled := 1
	MainGui["BugrunMantisLoot"].Enabled := 1
	MainGui["BugrunScorpionsLoot"].Enabled := 1
	MainGui["BugrunWerewolfLoot"].Enabled := 1
	MainGui["StingerCheck"].Enabled := 1
	if (StingerCheck = 1)
	{
		MainGui["StingerDailyBonusCheck"].Enabled := 1
		MainGui["StingerCloverCheck"].Enabled := 1
		MainGui["StingerSpiderCheck"].Enabled := 1
		MainGui["StingerCactusCheck"].Enabled := 1
		MainGui["StingerRoseCheck"].Enabled := 1
		MainGui["StingerMountainTopCheck"].Enabled := 1
		MainGui["StingerPepperCheck"].Enabled := 1
	}
	MainGui["TunnelBearCheck"].Enabled := 1
	MainGui["TunnelBearBabyCheck"].Enabled := 1
	MainGui["KingBeetleCheck"].Enabled := 1
	MainGui["KingBeetleBabyCheck"].Enabled := 1
	MainGui["KingBeetleAmuletMode"].Enabled := 1
	MainGui["CocoCrabCheck"].Enabled := 1
	MainGui["StumpSnailCheck"].Enabled := 1
	MainGui["ShellAmuletMode"].Enabled := 1
	MainGui["SnailHealthEdit"].Enabled := 1
	MainGui["SnailTimeUpDown"].Enabled := 1
	MainGui["CommandoCheck"].Enabled := 1
	MainGui["ChickLevel"].Enabled := 1
	MainGui["ChickHealthEdit"].Enabled := 1
	MainGui["ChickTimeUpDown"].Enabled := 1
	MainGui["BossConfigHelp"].Enabled := 1
}
nm_TabBoostLock(){
	global
	MainGui["ShrineAddSlot"].Enabled := 0
	MainGui["ShrineAdd1"].Enabled := 0
	MainGui["ShrineAdd2"].Enabled := 0
	MainGui["ShrineAmount"].Enabled := 0
	MainGui["ShrineIndex"].Enabled := 0
	MainGui["ShrineIndexOption"].Enabled := 0
	MainGui["ShrineLeft"].Enabled := 0
	MainGui["ShrineRight"].Enabled := 0
	MainGui["FB1Left"].Enabled := 0
	MainGui["FB1Right"].Enabled := 0
	MainGui["FB2Left"].Enabled := 0
	MainGui["FB2Right"].Enabled := 0
	MainGui["FB3Left"].Enabled := 0
	MainGui["FB3Right"].Enabled := 0
	MainGui["FieldBoosterMinsUpDown"].Enabled := 0
	MainGui["BoostChaserCheck"].Enabled := 0
	MainGui["AutoFieldBoostButton"].Enabled := 0
	MainGui["BoostedFieldSelectButton"].Enabled := 0
	MainGui["HotbarWhile2"].Enabled := 0
	MainGui["HotbarWhile3"].Enabled := 0
	MainGui["HotbarWhile4"].Enabled := 0
	MainGui["HotbarWhile5"].Enabled := 0
	MainGui["HotbarWhile6"].Enabled := 0
	MainGui["HotbarWhile7"].Enabled := 0
	MainGui["HotbarTime2"].Enabled := 0
	MainGui["HotbarTime3"].Enabled := 0
	MainGui["HotbarTime4"].Enabled := 0
	MainGui["HotbarTime5"].Enabled := 0
	MainGui["HotbarTime6"].Enabled := 0
	MainGui["HotbarTime7"].Enabled := 0
	MainGui["HotbarMax2"].Enabled := 0
	MainGui["HotbarMax3"].Enabled := 0
	MainGui["HotbarMax4"].Enabled := 0
	MainGui["HotbarMax5"].Enabled := 0
	MainGui["HotbarMax6"].Enabled := 0
	MainGui["HotbarMax7"].Enabled := 0
	MainGui["StickerStackCheck"].Enabled := 0
	MainGui["SSILeft"].Enabled := 0
	MainGui["SSIRight"].Enabled := 0
	MainGui["SSMLeft"].Enabled := 0
	MainGui["SSMRight"].Enabled := 0
	MainGui["StickerStackTimer"].Enabled := 0
	MainGui["StickerStackItemHelp"].Enabled := 0
	MainGui["StickerStackModeHelp"].Enabled := 0
	MainGui["StickerStackHive"].Enabled := 0
	MainGui["StickerStackCub"].Enabled := 0
	MainGui["StickerStackVoucher"].Enabled := 0
	MainGui["StickerStackSkinsHelp"].Enabled := 0
	MainGui["StickerPrinterCheck"].Enabled := 0
	MainGui["SPELeft"].Enabled := 0
	MainGui["SPERight"].Enabled := 0
}
nm_TabBoostUnLock(){
	global
	MainGui["ShrineAddSlot"].Enabled := 1
	MainGui["ShrineAdd1"].Enabled := 1
	MainGui["ShrineAdd2"].Enabled := 1
	MainGui["ShrineAmount"].Enabled := 1
	MainGui["ShrineIndexOption"].Enabled := 1
	MainGui["ShrineIndex"].Enabled := 1
	MainGui["ShrineLeft"].Enabled := 1
	MainGui["ShrineRight"].Enabled := 1
	MainGui["FB1Left"].Enabled := 1
	MainGui["FB1Right"].Enabled := 1
	nm_FieldBooster()
	MainGui["FieldBoosterMinsUpDown"].Enabled := 1
	MainGui["BoostChaserCheck"].Enabled := 1
	MainGui["AutoFieldBoostButton"].Enabled := 1
	MainGui["BoostedFieldSelectButton"].Enabled := 1
	MainGui["HotbarWhile2"].Enabled := 1
	MainGui["HotbarWhile3"].Enabled := 1
	MainGui["HotbarWhile4"].Enabled := 1
	MainGui["HotbarWhile5"].Enabled := 1
	MainGui["HotbarWhile6"].Enabled := 1
	MainGui["HotbarWhile7"].Enabled := 1
	MainGui["HotbarTime2"].Enabled := 1
	MainGui["HotbarTime3"].Enabled := 1
	MainGui["HotbarTime4"].Enabled := 1
	MainGui["HotbarTime5"].Enabled := 1
	MainGui["HotbarTime6"].Enabled := 1
	MainGui["HotbarTime7"].Enabled := 1
	MainGui["HotbarMax2"].Enabled := 1
	MainGui["HotbarMax3"].Enabled := 1
	MainGui["HotbarMax4"].Enabled := 1
	MainGui["HotbarMax5"].Enabled := 1
	MainGui["HotbarMax6"].Enabled := 1
	MainGui["HotbarMax7"].Enabled := 1
	MainGui["StickerStackCheck"].Enabled := 1
	if (StickerStackCheck = 1) {
		MainGui["SSILeft"].Enabled := 1
		MainGui["SSIRight"].Enabled := 1
		MainGui["SSMLeft"].Enabled := 1
		MainGui["SSMRight"].Enabled := 1
		MainGui["StickerStackTimer"].Enabled := 1
		MainGui["StickerStackItemHelp"].Enabled := 1
		MainGui["StickerStackModeHelp"].Enabled := 1
		MainGui["StickerStackSkinsHelp"].Enabled := 1
		if InStr(StickerStackItem, "Sticker") {
			MainGui["StickerStackHive"].Enabled := 1
			MainGui["StickerStackCub"].Enabled := 1
			MainGui["StickerStackVoucher"].Enabled := 1
		}
	}
	MainGui["StickerPrinterCheck"].Enabled := 1
	if (StickerPrinterCheck = 1) {
		MainGui["SPELeft"].Enabled := 1
		MainGui["SPERight"].Enabled := 1
	}
}
nm_TabQuestsLock(){
	global
	MainGui["PolarQuestCheck"].Enabled := 0
	MainGui["PolarQuestGatherInterruptCheck"].Enabled := 0
	MainGui["BuckoQuestCheck"].Enabled := 0
	MainGui["BuckoQuestGatherInterruptCheck"].Enabled := 0
	MainGui["RileyQuestCheck"].Enabled := 0
	MainGui["RileyQuestGatherInterruptCheck"].Enabled := 0
	MainGui["HoneyQuestCheck"].Enabled := 0
	MainGui["BlackQuestCheck"].Enabled := 0
	MainGui["BrownQuestCheck"].Enabled := 0
	MainGui["QuestGatherMins"].Enabled := 0
	MainGui["QuestBoostCheck"].Enabled := 0
	MainGui["QGRBLeft"].Enabled := 0
	MainGui["QGRBRight"].Enabled := 0
}
nm_TabQuestsUnLock(){
	global
	MainGui["PolarQuestCheck"].Enabled := 1
	MainGui["PolarQuestGatherInterruptCheck"].Enabled := 1
	MainGui["BuckoQuestCheck"].Enabled := 1
	MainGui["BuckoQuestGatherInterruptCheck"].Enabled := 1
	MainGui["RileyQuestCheck"].Enabled := 1
	MainGui["RileyQuestGatherInterruptCheck"].Enabled := 1
	MainGui["HoneyQuestCheck"].Enabled := 1
	MainGui["BlackQuestCheck"].Enabled := 1
	MainGui["BrownQuestCheck"].Enabled := 1
	MainGui["QuestGatherMins"].Enabled := 1
	MainGui["QuestBoostCheck"].Enabled := 1
	MainGui["QGRBLeft"].Enabled := 1
	MainGui["QGRBRight"].Enabled := 1
}
nm_TabPlantersLock(){
	global
	MainGui["PlanterMode"].Enabled := 0
	;planters+
	MainGui["TimersButton"].Enabled := 0
	MainGui["NPLeft"].Enabled := 0
	MainGui["NPRight"].Enabled := 0
	Loop 5 {
		MainGui["NP" A_Index "Left"].Enabled := 0
		MainGui["NP" A_Index "Right"].Enabled := 0
	}
	MainGui["N1MinPercentUpDown"].Enabled := 0
	MainGui["N2MinPercentUpDown"].Enabled := 0
	MainGui["N3MinPercentUpDown"].Enabled := 0
	MainGui["N4MinPercentUpDown"].Enabled := 0
	MainGui["N5MinPercentUpDown"].Enabled := 0
	MainGui["MaxAllowedPlanters"].Enabled := 0
	MainGui["AutomaticHarvestInterval"].Enabled := 0
	MainGui["HarvestFullGrown"].Enabled := 0
	MainGui["gotoPlanterField"].Enabled := 0
	MainGui["gatherFieldSipping"].Enabled := 0
	MainGui["ConvertFullBagHarvest"].Enabled := 0
	MainGui["GatherPlanterLoot"].Enabled := 0
	MainGui["HarvestInterval"].Enabled := 0
	MainGui["PlasticPlanterCheck"].Enabled := 0
	MainGui["CandyPlanterCheck"].Enabled := 0
	MainGui["BlueClayPlanterCheck"].Enabled := 0
	MainGui["RedClayPlanterCheck"].Enabled := 0
	MainGui["TackyPlanterCheck"].Enabled := 0
	MainGui["PesticidePlanterCheck"].Enabled := 0
	MainGui["HeatTreatedPlanterCheck"].Enabled := 0
	MainGui["HydroponicPlanterCheck"].Enabled := 0
	MainGui["PetalPlanterCheck"].Enabled := 0
	MainGui["PlanterOfPlentyCheck"].Enabled := 0
	MainGui["PaperPlanterCheck"].Enabled := 0
	MainGui["TicketPlanterCheck"].Enabled := 0
	MainGui["DandelionFieldCheck"].Enabled := 0
	MainGui["SunflowerFieldCheck"].Enabled := 0
	MainGui["MushroomFieldCheck"].Enabled := 0
	MainGui["BlueFlowerFieldCheck"].Enabled := 0
	MainGui["CloverFieldCheck"].Enabled := 0
	MainGui["SpiderFieldCheck"].Enabled := 0
	MainGui["StrawberryFieldCheck"].Enabled := 0
	MainGui["BambooFieldCheck"].Enabled := 0
	MainGui["PineappleFieldCheck"].Enabled := 0
	MainGui["StumpFieldCheck"].Enabled := 0
	MainGui["CactusFieldCheck"].Enabled := 0
	MainGui["PumpkinFieldCheck"].Enabled := 0
	MainGui["PineTreeFieldCheck"].Enabled := 0
	MainGui["RoseFieldCheck"].Enabled := 0
	MainGui["MountainTopFieldCheck"].Enabled := 0
	MainGui["CoconutFieldCheck"].Enabled := 0
	MainGui["PepperFieldCheck"].Enabled := 0
	;manual
	MainGui["MHILeft"].Enabled := 0
	MainGui["MHIRight"].Enabled := 0
	Static ManualPlantersControls := ["MPageLeft", "MPageRight", "MSlot1Left", "MSlot1Right", "MSlot2Left", "MSlot2Right", "MSlot3Left", "MSlot3Right"
	, "MPuffModeA", "MPuffMode1", "MPuffMode2", "MPuffMode3", "MPuffModeHelp", "MPlanterGatherA", "MPlanterGather1", "MPlanterGather2", "MPlanterGather3", "MPlanterGatherHelp", "MConvertFullBagHarvest", "MGatherPlanterLoot"
	, "MSlot1Cycle1Planter", "MSlot1Cycle2Planter", "MSlot1Cycle3Planter", "MSlot1Cycle4Planter", "MSlot1Cycle5Planter", "MSlot1Cycle6Planter", "MSlot1Cycle7Planter", "MSlot1Cycle8Planter", "MSlot1Cycle9Planter"
	, "MSlot1Cycle1Field", "MSlot1Cycle2Field", "MSlot1Cycle3Field", "MSlot1Cycle4Field", "MSlot1Cycle5Field", "MSlot1Cycle6Field", "MSlot1Cycle7Field", "MSlot1Cycle8Field", "MSlot1Cycle9Field"
	, "MSlot1Cycle1Glitter", "MSlot1Cycle2Glitter", "MSlot1Cycle3Glitter", "MSlot1Cycle4Glitter", "MSlot1Cycle5Glitter", "MSlot1Cycle6Glitter", "MSlot1Cycle7Glitter", "MSlot1Cycle8Glitter", "MSlot1Cycle9Glitter"
	, "MSlot1Cycle1AutoFull", "MSlot1Cycle2AutoFull", "MSlot1Cycle3AutoFull", "MSlot1Cycle4AutoFull", "MSlot1Cycle5AutoFull", "MSlot1Cycle6AutoFull", "MSlot1Cycle7AutoFull", "MSlot1Cycle8AutoFull", "MSlot1Cycle9AutoFull"
	, "MSlot2Cycle1Planter", "MSlot2Cycle2Planter", "MSlot2Cycle3Planter", "MSlot2Cycle4Planter", "MSlot2Cycle5Planter", "MSlot2Cycle6Planter", "MSlot2Cycle7Planter", "MSlot2Cycle8Planter", "MSlot2Cycle9Planter"
	, "MSlot2Cycle1Field", "MSlot2Cycle2Field", "MSlot2Cycle3Field", "MSlot2Cycle4Field", "MSlot2Cycle5Field", "MSlot2Cycle6Field", "MSlot2Cycle7Field", "MSlot2Cycle8Field", "MSlot2Cycle9Field"
	, "MSlot2Cycle1Glitter", "MSlot2Cycle2Glitter", "MSlot2Cycle3Glitter", "MSlot2Cycle4Glitter", "MSlot2Cycle5Glitter", "MSlot2Cycle6Glitter", "MSlot2Cycle7Glitter", "MSlot2Cycle8Glitter", "MSlot2Cycle9Glitter"
	, "MSlot2Cycle1AutoFull", "MSlot2Cycle2AutoFull", "MSlot2Cycle3AutoFull", "MSlot2Cycle4AutoFull", "MSlot2Cycle5AutoFull", "MSlot2Cycle6AutoFull", "MSlot2Cycle7AutoFull", "MSlot2Cycle8AutoFull", "MSlot2Cycle9AutoFull"
	, "MSlot3Cycle1Planter", "MSlot3Cycle2Planter", "MSlot3Cycle3Planter", "MSlot3Cycle4Planter", "MSlot3Cycle5Planter", "MSlot3Cycle6Planter", "MSlot3Cycle7Planter", "MSlot3Cycle8Planter", "MSlot3Cycle9Planter"
	, "MSlot3Cycle1Field", "MSlot3Cycle2Field", "MSlot3Cycle3Field", "MSlot3Cycle4Field", "MSlot3Cycle5Field", "MSlot3Cycle6Field", "MSlot3Cycle7Field", "MSlot3Cycle8Field", "MSlot3Cycle9Field"
	, "MSlot3Cycle1Glitter", "MSlot3Cycle2Glitter", "MSlot3Cycle3Glitter", "MSlot3Cycle4Glitter", "MSlot3Cycle5Glitter", "MSlot3Cycle6Glitter", "MSlot3Cycle7Glitter", "MSlot3Cycle8Glitter", "MSlot3Cycle9Glitter"
	, "MSlot3Cycle1AutoFull", "MSlot3Cycle2AutoFull", "MSlot3Cycle3AutoFull", "MSlot3Cycle4AutoFull", "MSlot3Cycle5AutoFull", "MSlot3Cycle6AutoFull", "MSlot3Cycle7AutoFull", "MSlot3Cycle8AutoFull", "MSlot3Cycle9AutoFull"]
	For v in ManualPlantersControls
		MainGui[v].Enabled := 0
}
nm_TabPlantersUnLock(){
	global
	MainGui["PlanterMode"].Enabled := 1
	;planters+
	MainGui["TimersButton"].Enabled := 1
	MainGui["NPLeft"].Enabled := 1
	MainGui["NPRight"].Enabled := 1
	MainGui["NP1Left"].Enabled := 1
	MainGui["NP1Right"].Enabled := 1
	nm_NectarPriority()
	MainGui["N1MinPercentUpDown"].Enabled := 1
	MainGui["N2MinPercentUpDown"].Enabled := 1
	MainGui["N3MinPercentUpDown"].Enabled := 1
	MainGui["N4MinPercentUpDown"].Enabled := 1
	MainGui["N5MinPercentUpDown"].Enabled := 1
	MainGui["MaxAllowedPlanters"].Enabled := 1
	MainGui["AutomaticHarvestInterval"].Enabled := 1
	MainGui["HarvestFullGrown"].Enabled := 1
	MainGui["gotoPlanterField"].Enabled := 1
	MainGui["gatherFieldSipping"].Enabled := 1
	MainGui["ConvertFullBagHarvest"].Enabled := 1
	MainGui["GatherPlanterLoot"].Enabled := 1
	MainGui["HarvestInterval"].Enabled := 1
	MainGui["PlasticPlanterCheck"].Enabled := 1
	MainGui["CandyPlanterCheck"].Enabled := 1
	MainGui["BlueClayPlanterCheck"].Enabled := 1
	MainGui["RedClayPlanterCheck"].Enabled := 1
	MainGui["TackyPlanterCheck"].Enabled := 1
	MainGui["PesticidePlanterCheck"].Enabled := 1
	MainGui["HeatTreatedPlanterCheck"].Enabled := 1
	MainGui["HydroponicPlanterCheck"].Enabled := 1
	MainGui["PetalPlanterCheck"].Enabled := 1
	MainGui["PlanterOfPlentyCheck"].Enabled := 1
	MainGui["PaperPlanterCheck"].Enabled := 1
	MainGui["TicketPlanterCheck"].Enabled := 1
	MainGui["DandelionFieldCheck"].Enabled := 1
	MainGui["SunflowerFieldCheck"].Enabled := 1
	MainGui["MushroomFieldCheck"].Enabled := 1
	MainGui["BlueFlowerFieldCheck"].Enabled := 1
	MainGui["CloverFieldCheck"].Enabled := 1
	MainGui["SpiderFieldCheck"].Enabled := 1
	MainGui["StrawberryFieldCheck"].Enabled := 1
	MainGui["BambooFieldCheck"].Enabled := 1
	MainGui["PineappleFieldCheck"].Enabled := 1
	MainGui["StumpFieldCheck"].Enabled := 1
	MainGui["CactusFieldCheck"].Enabled := 1
	MainGui["PumpkinFieldCheck"].Enabled := 1
	MainGui["PineTreeFieldCheck"].Enabled := 1
	MainGui["RoseFieldCheck"].Enabled := 1
	MainGui["MountainTopFieldCheck"].Enabled := 1
	MainGui["CoconutFieldCheck"].Enabled := 1
	MainGui["PepperFieldCheck"].Enabled := 1
	;manual
	MainGui["MHILeft"].Enabled := 1
	MainGui["MHIRight"].Enabled := 1
	MainGui["MSlot1Cycle1Planter"].Enabled := 1
	MainGui["MPuffModeA"].Enabled := 1
	MainGui["MPuffModeHelp"].Enabled := 1
	MainGui["MPlanterGatherA"].Enabled := 1
	MainGui["MPlanterGatherHelp"].Enabled := 1
	MainGui["MConvertFullBagHarvest"].Enabled := 1
	MainGui["MGatherPlanterLoot"].Enabled := 1
	mp_UpdatePage()
	mp_UpdateControls()
}
nm_TabStatusLock(){
	MainGui["StatusLogReverse"].Enabled := 0
	MainGui["ResetTotalStats"].Enabled := 0
	MainGui["WebhookGUI"].Enabled := 0
}
nm_TabStatusUnLock(){
	MainGui["StatusLogReverse"].Enabled := 1
	MainGui["ResetTotalStats"].Enabled := 1
	MainGui["WebhookGUI"].Enabled := 1
}
nm_TabSettingsLock(){
	global
	MainGui["GuiTheme"].Enabled := 0
	MainGui["GuiTransparencyUpDown"].Enabled := 0
	MainGui["AlwaysOnTop"].Enabled := 0
	MainGui["KeyDelay"].Enabled := 0
	MainGui["MoveSpeedNum"].Enabled := 0
	MainGui["RMLeft"].Enabled := 0
	MainGui["RMRight"].Enabled := 0
	MainGui["MMLeft"].Enabled := 0
	MainGui["MMRight"].Enabled := 0
	MainGui["STLeft"].Enabled := 0
	MainGui["STRight"].Enabled := 0
	MainGui["CBLeft"].Enabled := 0
	MainGui["CBRight"].Enabled := 0
	MainGui["CMLeft"].Enabled := 0
	MainGui["CMRight"].Enabled := 0
	MainGui["ConvertMins"].Enabled := 0
	MainGui["DisableToolUse"].Enabled := 0
	MainGui["AnnounceGuidingStar"].Enabled := 0
	MainGui["HideErrors"].Enabled := 0
	MainGui["NewWalk"].Enabled := 0
	MainGui["HiveSlot"].Enabled := 0
	MainGui["HiveBees"].Enabled := 0
	MainGui["HiveBeesHelp"].Enabled := 0
	MainGui["PrivServer"].Enabled := 0
	MainGui["PublicFallback"].Enabled := 0
	MainGui["ResetFieldDefaultsButton"].Enabled := 0
	MainGui["ResetAllButton"].Enabled := 0
	MainGui["TestReconnectButton"].Enabled := 0
	MainGui["ReconnectMethodHelp"].Enabled := 0
	MainGui["ReconnectInterval"].Enabled := 0
	MainGui["ReconnectHour"].Enabled := 0
	MainGui["ReconnectMin"].Enabled := 0
	MainGui["ReconnectTimeHelp"].Enabled := 0
	MainGui["PublicFallbackHelp"].Enabled := 0
	MainGui["RefreshDetectedApplication"].Enabled := 0
	MainGui["DetectedApplicationHelp"].Enabled := 0
	MainGui["NewWalkHelp"].Enabled := 0
	MainGui["ClaimMethodHelp"].Enabled := 0
	MainGui["RCLeft"].Enabled := 0
	MainGui["RCRight"].Enabled := 0
}
nm_TabSettingsUnLock(){
	global
	MainGui["GuiTheme"].Enabled := 1
	MainGui["GuiTransparencyUpDown"].Enabled := 1
	MainGui["AlwaysOnTop"].Enabled := 1
	MainGui["KeyDelay"].Enabled := 1
	MainGui["MoveSpeedNum"].Enabled := 1
	MainGui["RMLeft"].Enabled := 1
	MainGui["RMRight"].Enabled := 1
	MainGui["MMLeft"].Enabled := 1
	MainGui["MMRight"].Enabled := 1
	MainGui["STLeft"].Enabled := 1
	MainGui["STRight"].Enabled := 1
	MainGui["CBLeft"].Enabled := 1
	MainGui["CBRight"].Enabled := 1
	MainGui["CMLeft"].Enabled := 1
	MainGui["CMRight"].Enabled := 1
	if (ConvertBalloon="every")
		MainGui["ConvertMins"].Enabled := 1
	MainGui["DisableToolUse"].Enabled := 1
	MainGui["AnnounceGuidingStar"].Enabled := 1
	MainGui["HideErrors"].Enabled := 1
	MainGui["NewWalk"].Enabled := 1
	MainGui["HiveSlot"].Enabled := 1
	MainGui["HiveBees"].Enabled := 1
	MainGui["HiveBeesHelp"].Enabled := 1
	MainGui["PrivServer"].Enabled := 1
	MainGui["PublicFallback"].Enabled := 1
	MainGui["ResetFieldDefaultsButton"].Enabled := 1
	MainGui["ResetAllButton"].Enabled := 1
	MainGui["TestReconnectButton"].Enabled := 1
	MainGui["ReconnectMethodHelp"].Enabled := 1
	MainGui["ReconnectInterval"].Enabled := 1
	MainGui["ReconnectHour"].Enabled := 1
	MainGui["ReconnectMin"].Enabled := 1
	MainGui["ReconnectTimeHelp"].Enabled := 1
	MainGui["PublicFallbackHelp"].Enabled := 1
	MainGui["RefreshDetectedApplication"].Enabled := 1
	MainGui["DetectedApplicationHelp"].Enabled := 1
	MainGui["NewWalkHelp"].Enabled := 1
	MainGui["ClaimMethodHelp"].Enabled := 1
	MainGui["RCLeft"].Enabled := 1
	MainGui["RCRight"].Enabled := 1
}
nm_TabMiscLock(){
	MainGui["BasicEggHatcherButton"].Enabled := 0
	MainGui["BitterberryFeederButton"].Enabled := 0
	MainGui["GenerateBeeListButton"].Enabled := 0
	MainGui["BSSCalculatorsButton"].Enabled := 0
	MainGui["AutoClickerGUI"].Enabled := 0
	MainGui["RobloxFPSButton"].Enabled := 0
	MainGui["HotkeyGUI"].Enabled := 0
	MainGui["DebugLogGUI"].Enabled := 0
	MainGui["AutoStartManagerGUI"].Enabled := 0
	MainGui["NightAnnouncementGUI"].Enabled := 0
	MainGui["ReportBugButton"].Enabled := 0
	MainGui["MakeSuggestionButton"].Enabled := 0
	MainGui["AutoMutatorButton"].Enabled := 0
}
nm_TabMiscUnLock(){
	MainGui["BasicEggHatcherButton"].Enabled := 1
	MainGui["BitterberryFeederButton"].Enabled := 1
	MainGui["GenerateBeeListButton"].Enabled := 1
	MainGui["BSSCalculatorsButton"].Enabled := 1
	MainGui["AutoClickerGUI"].Enabled := 1
	MainGui["RobloxFPSButton"].Enabled := 1
	MainGui["HotkeyGUI"].Enabled := 1
	MainGui["DebugLogGUI"].Enabled := 1
	MainGui["AutoStartManagerGUI"].Enabled := 1
	MainGui["NightAnnouncementGUI"].Enabled := 1
	MainGui["ReportBugButton"].Enabled := 1
	MainGui["MakeSuggestionButton"].Enabled := 1
	MainGui["AutoMutatorButton"].Enabled := 1
}
;update config
nm_saveConfig(GuiCtrl, *){
	global
	switch GuiCtrl.Type, 0 {
		case "DDL":
		%GuiCtrl.Name% := GuiCtrl.Text
		default: ; "CheckBox", "Edit", "UpDown", "Slider"
		%GuiCtrl.Name% := GuiCtrl.Value
	}
	IniWrite %GuiCtrl.Name%, "settings\nm_config.ini", GuiCtrl.Section, GuiCtrl.Name
}

;link buttons
DiscordLink(*){
	nm_RunDiscord("invite/xbkXjwWh8U")
}
nm_DonateLink(*){
	run '"https://www.paypal.com/donate/?hosted_button_id=9KN7JHBCTAU8U&no_recurring=0&currency_code=USD"'
}
GitHubRepoLink(*){
	Run "https://github.com/NatroTeam/NatroMacro"
}
GitHubReleaseLink(*){
	Run "https://github.com/NatroTeam/NatroMacro/releases"
}
nm_RunDiscord(path){
	static cmd := Buffer(512), init := (DllCall("shlwapi\AssocQueryString", "Int",0, "Int",1, "Str","discord", "Str","open", "Ptr",cmd.Ptr, "IntP",512),
		DllCall("Shell32\SHEvaluateSystemCommandTemplate", "Ptr",cmd.Ptr, "PtrP",&pEXE:=0,"Ptr",0,"PtrP",&pPARAMS:=0))
	, exe := (pEXE > 0) ? StrGet(pEXE) : ""
	, params := (pPARAMS > 0) ? StrGet(pPARAMS) : ""
	, appenabled := (StrLen(exe) > 0)

	Run appenabled ? ('"' exe '" ' StrReplace(params, "%1", "discord://-/" path)) : ('"https://discord.com/' path '"')
}

;(used to update GUI with info fetched from GitHub)
AsyncHttpRequest(method, url, func?, headers?)
{
	req := ComObject("Msxml2.XMLHTTP")
	req.open(method, url, true)
	if IsSet(headers)
		for h, v in headers
			req.setRequestHeader(h, v)
	IsSet(func) && (req.onreadystatechange := func.Bind(req))
	req.send()
}

;current field up/down
nm_currentFieldUp(*){
	global CurrentField, CurrentFieldNum
	if(CurrentFieldNum=1) { ;wrap around to bottom
		if(FieldName3!="None") {
			CurrentFieldNum:=3
			CurrentField:=FieldName3
		} else if (FieldName2!="None") {
			CurrentFieldNum:=2
			CurrentField:=FieldName2
		} else {
			CurrentFieldNum:=1
			CurrentField:=FieldName1
		}
	} else if(CurrentFieldNum=2) {
		CurrentFieldNum:=1
		CurrentField:=FieldName1
	} else if(CurrentFieldNum=3) {
		CurrentFieldNum:=2
		CurrentField:=FieldName2
	}
	MainGui["CurrentField"].Text := CurrentField
	IniWrite CurrentFieldNum, "settings\nm_config.ini", "Gather", "CurrentFieldNum"
}
nm_currentFieldDown(*){
	global CurrentField, CurrentFieldNum
	if(CurrentFieldNum=1) {
		if(FieldName2!="None") {
			CurrentFieldNum:=2
			CurrentField:=FieldName2
		} else { ;default to 1
			CurrentFieldNum:=1
			CurrentField:=FieldName1
		}
	} else if(CurrentFieldNum=2) {
		if(FieldName3!="None") {
			CurrentFieldNum:=3
			CurrentField:=FieldName3
		} else { ;default to 1
			CurrentFieldNum:=1
			CurrentField:=FieldName1
		}
	} else if(CurrentFieldNum=3) {
		CurrentFieldNum:=1
		CurrentField:=FieldName1
	}
	MainGui["CurrentField"].Text := CurrentField
	IniWrite CurrentFieldNum, "settings\nm_config.ini", "Gather", "CurrentFieldNum"
}

;error balloon tip (used to show info on incorrect inputs)
nm_ShowErrorBalloonTip(Ctrl, Title, Text){
	EBT := Buffer(4 * A_PtrSize, 0)
	NumPut("UInt", 4 * A_PtrSize
		, "Ptr", StrPtr(Title)
		, "Ptr", StrPtr(Text)
		, "UInt", 3, EBT)
	DllCall("SendMessage", "UPtr", Ctrl.Hwnd, "UInt", 0x1503, "Ptr", 0, "Ptr", EBT.Ptr, "Ptr")
}

;cursor changing
SetCursor(name:=0){
    global CUSTOM_CURSOR
    static cursor_types := Map(
		"IDC_APPSTARTING", 32650,
		"IDC_ARROW", 32512,
		"IDC_CROSS", 32515,
		"IDC_HAND", 32649,
		"IDC_HELP", 32651,
		"IDC_IBEAM", 32513,
		"IDC_NO", 32648,
		"IDC_SIZEALL", 32646,
		"IDC_SIZENESW", 32643,
		"IDC_SIZENWSE", 32642,
		"IDC_SIZEWE", 32644,
		"IDC_SIZENS", 32645,
		"IDC_UPARROW", 32516,
		"IDC_WAIT", 32514
	)

	if !name {
        CUSTOM_CURSOR := 0
		DllCall("SetCursor", "Ptr", 0)
        return
    }
    CUSTOM_CURSOR := 1

    if !cursor_types.Has(name)
        throw Error("Invalid cursor type. see https://learn.microsoft.com/en-us/windows/win32/menurc/about-cursors")

	HCURSOR := DllCall("LoadCursor", "Ptr", 0, "uint", cursor_types[name])
	DllCall("SetCursor", "Ptr", HCURSOR)
}

;text control positioning functions
CenterText(Text1, Text2, Font, w:=260)
{
	w1 := TextExtent(Text1.Text, Font), w2 := TextExtent(Text2.Text, Font)
	Text1.Move(x1 := (w - w1 - w2)//2, , w1), Text2.Move(x1 + w1, , w2)
	Text1.Redraw(), Text2.Redraw()
}
TextExtent(text, textCtrl)
{
	hDC := DllCall("GetDC", "Ptr", textCtrl.Hwnd, "Ptr")
	hFold := DllCall("SelectObject", "Ptr", hDC, "Ptr", SendMessage(0x31, , , textCtrl), "Ptr")
	nSize := Buffer(8)
	DllCall("GetTextExtentPoint32", "Ptr", hDC, "Str", text, "Int", StrLen(text), "Ptr", nSize)
	DllCall("SelectObject", "Ptr", hDC, "Ptr", hFold)
	DllCall("ReleaseDC", "Ptr", textCtrl.Hwnd, "Ptr", hDC)
	return NumGet(nSize, 0, "UInt")
}
;miscellaneous functions
ValidateNumber(&var, default := 0) => IsNumber(var) ? var : (var := default)
ValidateInt(&var, default := 0) => IsInteger(var) ? var : (var := default)

;stats/status
nm_setStats(){
	global
	local rundelta:=0, gatherdelta:=0, convertdelta:=0, TotalStatsString, SessionStatsString

	if (MacroState=2) {
		rundelta:=(nowUnix()-MacroStartTime)
		if(GatherStartTime > 0)
			gatherdelta:=(nowUnix()-GatherStartTime)
		if(ConvertStartTime > 0)
			convertdelta:=(nowUnix()-ConvertStartTime)
	}

	TotalStatsString :=
	(
		"Runtime: " DurationFromSeconds(TotalRuntime+rundelta) "
		Gather: " DurationFromSeconds(TotalGatherTime+gatherdelta) "
		Convert: " DurationFromSeconds(TotalConvertTime+convertdelta) "
		ViciousKills=" TotalViciousKills "
		BossKills=" TotalBossKills "
		BugKills=" TotalBugKills "
		PlantersCollected=" TotalPlantersCollected "
		QuestsComplete=" TotalQuestsComplete "
		Disconnects=" TotalDisconnects
	)

	SessionStatsString :=
	(
		"Runtime: " DurationFromSeconds(SessionRuntime+rundelta) "
		Gather: " DurationFromSeconds(SessionGatherTime+gatherdelta) "
		Convert: " DurationFromSeconds(SessionConvertTime+convertdelta) "
		ViciousKills=" SessionViciousKills "
		BossKills=" SessionBossKills "
		BugKills=" SessionBugKills "
		PlantersCollected=" SessionPlantersCollected "
		QuestsComplete=" SessionQuestsComplete "
		Disconnects=" SessionDisconnects
	)

	MainGui["TotalStats"].Text := TotalStatsString
	MainGui["SessionStats"].Text := SessionStatsString
}
nm_setStatus(newState:=0, newObjective:=0){
	global state, objective, StatusLogReverse, DebugLogEnabled
	static statuslog:=[], status_number:=0

	if ((DebugLogEnabled = 1) && (statuslog.Length = 0) && FileExist("settings\debug_log.txt")) {
		txt := FileOpen("settings\debug_log.txt", "r"), c := f := 0
		while ((c < 15) && !f && (A_Index < 100))
			txt.Seek(- (((p := (A_Index * 128)) > txt.Length) ? (f := txt.Length) : p), 2), log := txt.Read(), StrReplace(log, "`n", , , &c)
		txt.Close()
		Loop Parse SubStr(RTrim(log, "`r`n"), f ? 1 : InStr(log, "`n", , , Max(c - 15, 1)) + 1), "`n", "`r"
			statuslog.Push(SubStr(A_LoopField, 8))
	}

	if (newState != "Detected") {
		if(newState)
			state:=newState
		if(newObjective)
			objective:=newObjective
	}
	stateString := ((newState ? newState : state) . ": " . (newObjective ? newObjective : objective))

	statuslog.Push("[" A_Hour ":" A_Min ":" A_Sec "] " (InStr(stateString, "`n") ? SubStr(stateString, 1, InStr(stateString, "`n")-1) : stateString))
	statuslog.RemoveAt(1,(statuslog.Length>15) ? statuslog.Length-15 : 0), len:=statuslog.Length
	statuslogtext:=""
	for k,v in statuslog
		i := ((StatusLogReverse) ? len+1-k : k), statuslogtext .= (((A_Index>1) ? "`r`n" : "") statuslog[i])

	try {
		MainGui["state"].Text := stateString
		MainGui["statuslog"].Text := statuslogtext
	}

	; update status
	DetectHiddenWindows 1
	if (newState != "Detected") {
		num := ((state = "Gathering") && !InStr(objective, "Ended")) ? 1 : ((state = "Converting") && !InStr(objective, "Refreshed") && !InStr(objective, "Emptied")) ? 2 : 0
		if (num != status_number) {
			status_number := num
			if WinExist("StatMonitor.ahk ahk_class AutoHotkey")
				try PostMessage 0x5554, status_number, 60 * A_Min + A_Sec
			if WinExist("background.ahk ahk_class AutoHotkey")
				try PostMessage 0x5555, status_number, nowUnix()
		}
	}
	if WinExist("Status.ahk ahk_class AutoHotkey")
		try SendMessage 0xC2, 0, StrPtr("[" A_MM "/" A_DD "][" A_Hour ":" A_Min ":" A_Sec "] " stateString)
	DetectHiddenWindows 0
}
nm_updateAction(action){
	global CurrentAction, PreviousAction
	if(CurrentAction!=action){
		PreviousAction:=CurrentAction
		CurrentAction:=action
	}
}
nm_PlanterDetection()
{
	static pBMProgressStart, pBMProgressEnd, pBMRemain

	;defines the bitmaps via hex color
	if !(IsSet(pBMProgressStart) && IsSet(pBMProgressEnd) && IsSet(pBMRemain))
	{
		pBMProgressStart := Gdip_CreateBitmap(1,8)
		pGraphics := Gdip_GraphicsFromImage(pBMProgressStart), Gdip_GraphicsClear(pGraphics, 0xff86d570), Gdip_DeleteGraphics(pGraphics)
		pBMProgressEnd := Gdip_CreateBitmap(1,2)
		pGraphics := Gdip_GraphicsFromImage(pBMProgressEnd), Gdip_GraphicsClear(pGraphics, 0xff86d570), Gdip_DeleteGraphics(pGraphics)
		pBMRemain := Gdip_CreateBitmap(1,8)
		pGraphics := Gdip_GraphicsFromImage(pBMRemain), Gdip_GraphicsClear(pGraphics, 0xff567848), Gdip_DeleteGraphics(pGraphics)
	}

	ActivateRoblox()
	GetRobloxClientPos()
	pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY "|" windowWidth "|" windowHeight)

	if ((sPlanterStart := Gdip_ImageSearch(pBMScreen, pBMProgressStart, &PStart, , , , , , , 5)) = 1) {
		x := SubStr(PStart, 1, InStr(PStart, ",")-1), y := SubStr(PStart, InStr(PStart, ",")+1)
		sPlanterEnd := Gdip_ImageSearch(pBMScreen, pBMProgressEnd, &PEnd, x, y, , y+2, , , 8)
		sPBarEnd := Gdip_ImageSearch(pBMScreen, pBMRemain, &PBarEnd, x, y, , y+8, , , 8)
	}

	Gdip_DisposeImage(pBMScreen)

	if !((sPlanterStart = 0) || (sPlanterEnd = 0) || (sPBarEnd = 0))
	{
		cx2 := SubStr(PEnd, 1, InStr(PEnd, ",")-1)+1, dx2 := SubStr(PBarEnd, 1, InStr(PBarEnd, ",")-1)+1
		PlanterBarRemain := Round((dx2-cx2)/(dx2-x)*100, 2)
		PlanterBarProgress := (cx2-x)/(dx2-x)
		return PlanterBarProgress
	}
	else
		return 0
}
nm_PlanterTimeUpdate(FieldName, SetStatus := 1)
{
	global
	local i, field, k, v, r:=0, PlanterGrowTime, PlanterBarProgress, CurrentPlanterBarProgress, NewPlanterBarProgress, VerifiedPlanterBarProgress

	Loop 3
	{
		i := A_Index
		if ((((PlanterMode = 2) && HarvestFullGrown) || ((PlanterMode = 1) && (PlanterHarvestFull%i% = "Full"))) && (PlanterField%i% = FieldName))
		{
			field := StrReplace(FieldName, " ")
			for k,v in %field%Planters
			{
				if (v[1] = PlanterName%i%)
				{
					PlanterGrowTime := v[4]
					break
				}
			}

			sendinput "{" RotUp " 4}"
			Sleep 200

			; get prior PlanterBarProgress bounds for comparison
			CurrentPlanterBarProgress := 1 - ((PlanterHarvestTime%i% - nowUnix()) / 3600 / PlanterGrowTime)  ; PlanterBarProgress0

			Loop 20
			{
				if (((PlanterBarProgress := nm_PlanterDetection()) > 0) && PlanterBarProgress <= 1)
				{
					; if new estimate within +/-10%, update
					if (Abs(PlanterBarProgress - CurrentPlanterBarProgress) <= 0.10)
					{
						PlanterHarvestTime%i% := nowUnix() + Round((1 - PlanterBarProgress) * PlanterGrowTime * 3600)
						IniWrite PlanterHarvestTime%i%, "settings\nm_config.ini", "Planters", "PlanterHarvestTime" i
						(SetStatus) && nm_setStatus("Detected", PlanterName%i% "`nField: " FieldName " - Est. Progress: " Round(PlanterBarProgress*100) "%")
						;NewPlanterBarProgress := PlanterBarProgress  ; variable only needed here for testing status update
						break
					}
					else ; if new estimate not within +/-10%, screenshot again
					{
						NewPlanterBarProgress := PlanterBarProgress  ; PlanterBarProgress1

						sleep 2000

						sendinput "{" RotRight " 2}"
						sleep 100
						PlanterBarProgress := nm_PlanterDetection()
						sendinput "{" RotLeft " 2}"
						sleep 100

						; if second screenshot within +/-10% of first, update
						if ((PlanterBarProgress > 0) && (PlanterBarProgress <= 1) && (Abs(PlanterBarProgress - NewPlanterBarProgress) <= 0.10))
						{
							VerifiedPlanterBarProgress := PlanterBarProgress  ; PlanterBarProgress2, variable only needed for testing status update
							PlanterBarProgress := (NewPlanterBarProgress + PlanterBarProgress) / 2

							PlanterHarvestTime%i% := nowUnix() + Round((1 - PlanterBarProgress) * PlanterGrowTime * 3600)
							IniWrite PlanterHarvestTime%i%, "settings\nm_config.ini", "Planters", "PlanterHarvestTime" i
							(SetStatus) && nm_setStatus("Detected", PlanterName%i% "`nField: " FieldName " - Est. Progress: " Round(PlanterBarProgress*100) "%")
							break
						}
					}
				}

				Sleep 100
				sendinput "{" ZoomOut "}"
				if (A_Index = 10)
				{
					sendinput "{" RotLeft " 2}"
					r := 1
				}
			}
			sendinput "{" RotDown " 4}" ((r = 1) ? "{" RotRight " 2}" : "")
			Sleep 500
		}
	}
}

nm_imgSearch(fileName,v,aim := "full", trans:="none"){
	GetRobloxClientPos()
	;xi := 0
	;yi := 0
	;ww := windowWidth
	;wh := windowHeight
	xi:=(aim="actionbar") ? windowWidth//4 : (aim="highright") ? windowWidth//2 : (aim="right") ? windowWidth//2 : (aim="center") ? windowWidth//4 : (aim="lowright") ? windowWidth//2 : 0
	yi:=(aim="low") ? windowHeight//2 : (aim="actionbar") ? (windowHeight//4)*3 : (aim="center") ? windowHeight//4 : (aim="lowright") ? windowHeight//2 : (aim="quest") ? 150 : 0
	ww:=(aim="actionbar") ? xi*3 : (aim="highleft") ? windowWidth//2 : (aim="left") ? windowWidth//2 : (aim="center") ? xi*3 : (aim="quest" || aim="questbrown") ? 310 : windowWidth
	wh:=(aim="high") ? windowHeight//2 : (aim="highright") ? windowHeight//2 : (aim="highleft") ? windowHeight//2 : (aim="buff") ? 150 : (aim="abovebuff") ? 30 : (aim="center") ? yi*3 : (aim="quest") ? Max(560, windowHeight-100) : (aim="questbrown") ? windowHeight//2 : windowHeight
	if DirExist(A_WorkingDir "\nm_image_assets")
	{
		try result := ImageSearch(&FoundX, &FoundY, windowX + xi, windowY + yi, windowX + ww, windowY + wh, "*" v ((trans != "none") ? (" *Trans" trans) : "") " " A_WorkingDir "\nm_image_assets\" fileName)
		catch {
			nm_setStatus("Error", "Image file " filename " was not found in:`n" A_WorkingDir "\nm_image_assets\" fileName)
			Sleep 5000
			ProcessClose DllCall("GetCurrentProcessId")
		}
		if (result = 1)
			return [0,FoundX-windowX,FoundY-windowY]
		else
			return [1, 0, 0]
	} else {
		MsgBox "Folder location cannot be found:`n" A_WorkingDir "\nm_image_assets\"
		return [3, 0, 0]
	}
}
PostSubmacroMessage(submacro, args*){
	DetectHiddenWindows 1
	if WinExist(submacro ".ahk ahk_class AutoHotkey")
		try PostMessage(args*)
	DetectHiddenWindows 0
}
nm_Reset(checkAll:=1, wait:=2000, convert:=1, force:=0){
	global resetTime, youDied, KeyDelay, SC_E, SC_Esc, SC_R, SC_Enter, RotRight, RotLeft, RotUp, RotDown, ZoomOut, objective, AFBrollingDice, AFBuseGlitter, AFBuseBooster, currentField, HiveConfirmed, GameFrozenCounter, bitmaps
	;check for game frozen conditions
	if (GameFrozenCounter>=3) { ;3 strikes
		nm_setStatus("Detected", "Roblox Game Frozen, Restarting")
		CloseRoblox()
		GameFrozenCounter:=0
	}
	DisconnectCheck()
	nm_setShiftLock(0)
	nm_OpenMenu()
	if(youDied && !(instr(objective, "mondo") || CheckNight)){ ; add extra time if player died before reset expect when fighting bosses
		wait:=max(wait, 20000)
	}
	;mondo or coconut crab likely killed you here! skip over this field if possible
	if(youDied && (currentField="mountain top" || currentField="coconut"))
		nm_currentFieldDown()
	youDied:=0
	nm_AutoFieldBoost(currentField) ; start rolling dice in background() if needed

	; High priority interrupts. Will interrupt any reset not marked with the checkAll flag. Added to avoid infinite recursion
	if checkAll {
		nm_fieldBoostBooster()
		nm_Night()
	}
	if(force=1) {
		HiveConfirmed:=0
	}
	while (!HiveConfirmed) {
		;failsafe game frozen
		if(Mod(A_Index, 10) = 0) {
			nm_setStatus("Closing", "and Re-Open Roblox")
			CloseRoblox()
			DisconnectCheck()
			continue
		}
		DisconnectCheck()
		ActivateRoblox()
		nm_setShiftLock(0)
		nm_OpenMenu()

		hwnd := GetRobloxHWND()
		offsetY := GetYOffset(hwnd)
		;check that performance stats is disabled
		GetRobloxClientPos(hwnd)
		pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY+offsetY+36 "|" windowWidth "|24")
		if ((Gdip_ImageSearch(pBMScreen, bitmaps["perfmem"], &pos, , , , , 2, , 5) = 1)
		&& (Gdip_ImageSearch(pBMScreen, bitmaps["perfwhitefill"], , x := SubStr(pos, 1, (comma := InStr(pos, ",")) - 1), y := SubStr(pos, comma + 1), x + 17, y + 7, 2) = 0)) {
			if ((Gdip_ImageSearch(pBMScreen, bitmaps["perfcpu"], &pos, x + 17, y, , y + 7, 2) = 1)
			&& (Gdip_ImageSearch(pBMScreen, bitmaps["perfwhitefill"], , x := SubStr(pos, 1, (comma := InStr(pos, ",")) - 1), y := SubStr(pos, comma + 1), x + 17, y + 7, 2) = 0)) {
				if ((Gdip_ImageSearch(pBMScreen, bitmaps["perfgpu"], &pos, x + 17, y, , y + 7, 2) = 1)
				&& (Gdip_ImageSearch(pBMScreen, bitmaps["perfwhitefill"], , x := SubStr(pos, 1, (comma := InStr(pos, ",")) - 1), y := SubStr(pos, comma + 1), x + 17, y + 7, 2) = 0)) {
					Send "^{F7}"
				}
			}
		}
		Gdip_DisposeImage(pBMScreen)
		;check to make sure you are not in dialog before reset
		Loop 500
		{
			GetRobloxClientPos(hwnd)
			pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2-50 "|" windowY+2*windowHeight//3 "|100|" windowHeight//3)
			if (Gdip_ImageSearch(pBMScreen, bitmaps["dialog"], &pos, , , , , 10, , 3) != 1) {
				Gdip_DisposeImage(pBMScreen)
				break
			}
			Gdip_DisposeImage(pBMScreen)
			MouseMove windowX+windowWidth//2, windowY+2*windowHeight//3+SubStr(pos, InStr(pos, ",")+1)-15
			Click
			Sleep 150
		}
		MouseMove windowX+350, windowY+offsetY+100
		;check to make sure you are not in a yes/no prompt
		GetRobloxClientPos(hwnd)
		pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2-250 "|" windowY+windowHeight//2-52 "|500|150")
		if (Gdip_ImageSearch(pBMScreen, bitmaps["no"], &pos, , , , , 2, , 3) = 1) {
			MouseMove windowX+windowWidth//2-250+SubStr(pos, 1, InStr(pos, ",")-1), windowY+windowHeight//2-52+SubStr(pos, InStr(pos, ",")+1)
			Click
			MouseMove windowX+350, windowY+offsetY+100
		}
		Gdip_DisposeImage(pBMScreen)
		;check to make sure you are not in feed window on accident
		imgPos := nm_imgSearch("cancel.png",30)
		If (imgPos[1] = 0){
			MouseMove windowX+(imgPos[2]), windowY+(imgPos[3])
			Click
			MouseMove windowX+350, windowY+offsetY+100
		}
		;check to make sure you are not in blender screen
		BlenderSS := Gdip_BitmapFromScreen(windowX+windowWidth//2 - 275 "|" windowY+Floor(0.48*windowHeight) - 220 "|550|400")
		if (Gdip_ImageSearch(BlenderSS, bitmaps["CloseGUI"], , , , , , 5) > 0) {
			MouseMove windowX+windowWidth//2 - 250, windowY+Floor(0.48*windowHeight) - 200
			Sleep 150
			click
		}
		Gdip_DisposeImage(BlenderSS)
		;check to make sure you are not in sticker screen
		pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2 - 275 "|" windowY+4*windowHeight//10-178 "|56|56")
		if (Gdip_ImageSearch(pBMScreen, bitmaps["CloseGUI"], , , , , , 5) > 0) {
			MouseMove windowX+windowWidth//2 - 250, windowY+4*windowHeight//10 - 150
			sleep 150
			click
		}
		Gdip_DisposeImage(pBMScreen)
		;check to make sure you are not in shop before reset
		searchRet := nm_imgSearch("e_button.png",30,"high")
		If (searchRet[1] = 0) {
			loop 2 {
				shopG := nm_imgSearch("shop_corner_G.png",30,"right")
				shopR := nm_imgSearch("shop_corner_R.png",30,"right")
				If (shopG[1] = 0 || shopR[1] = 0) {
					sendinput "{" SC_E " down}"
					Sleep 100
					sendinput "{" SC_E " up}"
					Sleep 1000
				}
			}
		}
		;check to make sure there is not a window open
		searchRet := nm_imgSearch("close.png",30,"full")
		If (searchRet[1] = 0) {
			MouseMove windowX+searchRet[2],windowY+searchRet[3]
			click
			MouseMove windowX+350, windowY+offsetY+100
			Sleep 1000
		}
		;check to make sure there is no Memory Match
		nm_SolveMemoryMatch()

		nm_setStatus("Resetting", "Character " . Mod(A_Index, 10))
		MouseMove windowX+350, windowY+offsetY+100
		PrevKeyDelay:=A_KeyDelay
		SetKeyDelay 250+KeyDelay

		resetTime:=nowUnix()
		PostSubmacroMessage("background", 0x5554, 1, resetTime)

		;reset
		ActivateRoblox()
		GetRobloxClientPos()
		send "{" SC_Esc "}{" SC_R "}{" SC_Enter "}"
		n := 0
		while ((n < 2) && (A_Index <= 80)) {
			Sleep 100
			pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY "|" windowWidth "|50")
			n += ((Gdip_ImageSearch(pBMScreen, bitmaps["emptyhealth"], , , , , , 10) || nm_HealthBar()) = (n = 0))
			Gdip_DisposeImage(pBMScreen)
		}

		SetKeyDelay PrevKeyDelay

		; Nate's quick fix for laggy pcs - Will be removed soon
		Sleep 2000 + 1000 * A_Index

		; hive check
		if !atHive() && nm_DetectSpawn() {
			Sleep 500
			GetRobloxClientPos(hwnd)
			MouseMove windowX+350, windowY+offsetY+100
			send "{" ZoomOut " 8}"
			movement := nm_spawnMoveTo(slotMove[HiveSlot])
			nm_createWalk(movement)
			KeyWait "F14", "D T5 L"
			KeyWait "F14", "T20 L"
			nm_endWalk()
			sleep 500
			if atHive()
				HiveConfirmed := 1
		} else {
			nm_SetHiveCameraDirection(4)
		}
	}
	;convert
	(convert=1) && nm_convert()
	;ensure minimum delay has been met
	if((nowUnix()-resetTime)<wait) {
		remaining:=floor((wait-(nowUnix()-resetTime))/1000) ;seconds
		if(remaining>5){
			Sleep 1000
			nm_setStatus("Waiting", remaining . " Seconds")
			Sleep (remaining-1)*1000
		}
		else {
			Sleep (remaining*1000) ;miliseconds
		}
	}

	atHive() {
		ActivateRoblox()
		GetRobloxClientPos()
		pBMScreen := Gdip_BitmapFromScreen(windowX + windowWidth // 2 - 150 "|" windowY + GetYOffset() + 40 "|350|60")
		success := (Gdip_ImageSearch(pBMScreen, bitmaps["colhey"],,,,,,5) = 1)
		Gdip_DisposeImage(pBMScreen)

		return success
	}
}
nm_HealthBar() {
	local detection := 0
	static isDead(c) =>   ((((c) & 0x00FF0000 >= 0x004D0000) && ((c) & 0x00FF0000 <= 0x00830000)) ; 4D4D4D-blackBG|838383-whiteBG
						&& (((c) & 0x0000FF00 >= 0x00004D00) && ((c) & 0x0000FF00 <= 0x00008300))
						&& (((c) & 0x000000FF >= 0x0000004D) && ((c) & 0x000000FF <= 0x00000083)))
	GetRobloxClientPos()
	pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth-100 "|" windowY+24 "|50|20")
	if isDead(Gdip_GetPixel(pBMScreen, 25, 12))
		detection:=1
	Gdip_DisposeImage(pBMScreen)
	return detection
}
nm_ConfirmAtHive(){
	pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2-200 "|" windowY+offsetY "|400|125")
	if ((Gdip_ImageSearch(pBMScreen, bitmaps["makehoney"], , , , , , 2, , 2) = 1) || (Gdip_ImageSearch(pBMScreen, bitmaps["collectpollen"], , , , , , 2, , 2) = 1)){
		Gdip_DisposeImage(pBMScreen)
		return 1
	}
	Gdip_DisposeImage(pBMScreen)
	return 0
}
nm_DetectSpawn() { ; some of the code was from hive check, repurposing it here since it seems to reliably detect hive slots even when the stuff is really bad
    ActivateRoblox()
    GetRobloxClientPos()
    send "{" RotDown " 11}{" RotUp " 5}"
	loop 5
		send("{" ZoomIn "}"), Sleep(50)

	sconf := windowWidth**2//3200
    spawnConfirmed := 0

	loop 4 {
		sleep 250
		pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY "|" windowWidth "|" windowHeight//4), s := 0
		for i, k in bitmaps["spawn"] {
			s := Max(s, Gdip_ImageSearch(pBMScreen, k, , , , , , 5, , , sconf))
			if (s >= sconf) {
				Gdip_DisposeImage(pBMScreen)
				spawnConfirmed := 1
				break 2
			}
		}
		Gdip_DisposeImage(pBMScreen)
		sendinput "{" RotRight " 4}"
	}
	;rotate back
	Send "{" RotUp " 2}"
	loop 5
		send("{" ZoomOut "}"), Sleep(50)
	return spawnConfirmed
}
nm_detectHiveSlots() {
	static isUnclaimed(c) => ; only for day/night (detects red tint)
		(((c>>16)&0xFF) > (((c>>8)&0xFF) + 7))
		&& (((c>>16)&0xFF) > ((c & 0xFF) + 7))
	hwnd := GetRobloxHWND()
	GetRobloxClientPos(hwnd)
	ActivateRoblox()
	offsetsX := [0.9013, 0.7007, 0.4954, 0.3046, 0.1021, 0.0561], offsetsY := [0, 0, 0, 0, 0, 0.6985], detected := 0
	w := windowHeight*0.4*2, h := windowHeight*0.1
	loop 5
		send "{" RotUp "}{" ZoomIn "}"
	loop 4 {
		sleep(100), unclaimed := []
		pBMScreen := Gdip_BitmapFromScreen(windowX + (windowWidth//2) - (windowHeight*0.4) "|" windowY + (windowHeight//2) - (windowHeight*0.25) "|" w "|" h)
		loop 6 {
			val := isUnclaimed(Gdip_GetPixel(pBMScreen, w*offsetsX[A_Index], h*offsetsY[A_Index]))
			unclaimed.Push({HiveSlot:A_Index,Claimed:val ? "Empty" : "Claimed"}), detected += val
		}
		Gdip_DisposeImage(pBMScreen)
		if detected > 0
			break
		send "{" RotRight " 4}"
	}
	send "{" RotDown " 4}"
	loop 5
		send "{" ZoomOut "}"
	return unclaimed
}
nm_spawnMoveTo(moves) {
    script := ""
    for k in moves {
        dirs := (Type(k.dir) = "Array") ? k.dir : [k.dir]
        for dir in dirs
            script .= 'Send "{' %dir "Key"% ' down}"`n'
        script .= "Walk(" k.dist ")" "`n"
        for dir in dirs
            script .= 'Send "{' %dir "Key"% ' up}"`n'
    }
    return script
}
nm_SetHiveCameraDirection(rotations){
	global HiveConfirmed
	static hivedown := 0
	if hivedown
		sendinput "{" RotDown "}"
	region := windowX "|" windowY+3*windowHeight//4 "|" windowWidth "|" windowHeight//4
	sconf := windowWidth**2//3200
	loop (maxindex := 8/rotations*2) { ; 2 full rotations
		sleep 250+KeyDelay
		pBMScreen := Gdip_BitmapFromScreen(region), s := 0
		for i, k in bitmaps["hive"] {
			s := Max(s, Gdip_ImageSearch(pBMScreen, k, , , , , , 4, , , sconf))
			if (s >= sconf) {
				Gdip_DisposeImage(pBMScreen)
				HiveConfirmed := 1
				sendinput "{" RotRight " 4}" (hivedown ? ("{" RotUp "}") : "")
				Send "{" ZoomOut " 5}"
				return 1
			}
		}
		Gdip_DisposeImage(pBMScreen)
		sendinput "{" RotRight " " rotations "}" ((maxindex/2 = A_Index) ? ("{" ((hivedown := !hivedown) ? RotDown : RotUp) "}") : "")
	}
}
nm_setShiftLock(state, *){
	global bitmaps, SC_LShift, ShiftLockEnabled

	if !(hwnd := WinExist("Roblox ahk_exe RobloxPlayerBeta.exe")) ; Shift Lock is not supported on UWP app at the moment
		return

	ActivateRoblox()
	GetRobloxClientPos(hwnd)

	pBMScreen := Gdip_BitmapFromScreen(windowX+5 "|" windowY+windowHeight-54 "|50|50")

	switch (v := Gdip_ImageSearch(pBMScreen, bitmaps["shiftlock"], , , , , , 2))
	{
		; shift lock enabled - disable if needed
		case 1:
		if (state = 0)
		{
			send "{" SC_LShift "}"
			result := 0
		}
		else
			result := 1

		; shift lock disabled - enable if needed
		case 0:
		if (state = 1)
		{
			send "{" SC_LShift "}"
			result := 1
		}
		else
			result := 0
	}

	Gdip_DisposeImage(pBMScreen)
	return (ShiftLockEnabled := result)
}
; decision: "keep", 1; "replace", 2; "obtained", 3 // returns 0 - no prompt, 1 - prompt exists, 2 - no roblox window
nm_AmuletPrompt(decision:=0, type:=0, *){
	global bitmaps, ShiftLockEnabled

	Prev_ShiftLock := ShiftLockEnabled
	nm_setShiftLock(0)

	GetRobloxClientPos()
	if (windowWidth = 0)
		return 2
	else
		ActivateRoblox()

	pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2-250 "|" windowY "|500|" windowHeight)

	if (Gdip_ImageSearch(pBMScreen, bitmaps["keep"], &pos, , , , , 2, , 2) = 1)
	{
		switch decision, 0
		{
			case "keep",1:
			if type = "Ant" || type = "King Beetle" || type = "Shell"
				nm_setStatus("Keeping", type " Amulet")
			Gdip_DisposeImage(pBMScreen)
			loop 10
			{
				MouseMove windowX+350, windowY+offsetY+100
				pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2-250 "|" windowY "|500|" windowHeight)
				if (Gdip_ImageSearch(pBMScreen, bitmaps["keep"], &pos, , , , , 2, , 2) = 1)
				{
					MouseMove windowX+windowWidth//2-250+SubStr(pos, 1, InStr(pos, ",")-1)+10, windowY+SubStr(pos, InStr(pos, ",")+1)+10, 5
					Sleep 200
					Click
				}
				Gdip_DisposeImage(pBMScreen)
			}
			nm_setShiftLock(Prev_ShiftLock)
			return 1

			case "replace",2:
			MouseMove windowX+windowWidth//2-250+SubStr(pos, 1, InStr(pos, ",")-1)+190, windowY+SubStr(pos, InStr(pos, ",")+1)+10, 5
			Click
			Gdip_DisposeImage(pBMScreen)
			Loop 25
			{
				pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2-250 "|" windowY "|500|" windowHeight)
				if (Gdip_ImageSearch(pBMScreen, bitmaps["yes"], &pos, , , , , 2, , 2) = 1)
				{
					MouseMove windowX+windowWidth//2-250+SubStr(pos, 1, InStr(pos, ",")-1), windowY+SubStr(pos, InStr(pos, ",")+1), 5
					Click
					Gdip_DisposeImage(pBMScreen)
					break
				}
				Gdip_DisposeImage(pBMScreen)
				Sleep 100
			}
			nm_setShiftLock(Prev_ShiftLock)
			return 1

			case "obtained",3:
			nm_setStatus("Obtained", type " Amulet")
			Gdip_DisposeImage(pBMScreen)
			nm_setShiftLock(Prev_ShiftLock)
			return 1

			default:
			Gdip_DisposeImage(pBMScreen)
			nm_setShiftLock(Prev_ShiftLock)
			return 1
		}
	}
	else
	{
		Gdip_DisposeImage(pBMScreen)
		nm_setShiftLock(Prev_ShiftLock)
		return 0
	}
}
nm_FindItem(chosenItem, *) {
	global shiftLockEnabled, bitmaps
	static items := ["Cog", "Ticket", "SprinklerBuilder", "BeequipCase", "Gumdrops", "Coconut", "Stinger", "Snowflake", "MicroConverter", "Honeysuckle", "Whirligig", "FieldDice", "SmoothDice", "LoadedDice", "JellyBeans", "RedExtract", "BlueExtract", "Glitter", "Glue", "Oil", "Enzymes", "TropicalDrink", "PurplePotion", "SuperSmoothie", "MarshmallowBee", "Sprout", "MagicBean", "FestiveBean", "CloudVial", "NightBell", "BoxOFrogs", "AntPass", "BrokenDrive", "7ProngedCog", "RoboPass", "Translator", "SpiritPetal", "Present", "Treat", "StarTreat", "AtomicTreat", "SunflowerSeed", "Strawberry", "Pineapple", "Blueberry", "Bitterberry", "Neonberry", "MoonCharm", "GingerbreadBear", "AgedGingerbreadBear", "WhiteDrive", "RedDrive", "BlueDrive", "GlitchedDrive", "ComfortingVial", "InvigoratingVial", "MotivatingVial", "RefreshingVial", "SatisfyingVial", "PinkBalloon", "RedBalloon", "WhiteBalloon", "BlackBalloon", "SoftWax", "HardWax", "CausticWax", "SwirledWax", "Turpentine", "PaperPlanter", "TicketPlanter", "FestivePlanter", "PlasticPlanter", "CandyPlanter", "RedClayPlanter", "BlueClayPlanter", "TackyPlanter", "PesticidePlanter", "HeatTreatedPlanter", "HydroponicPlanter", "PetalPlanter", "ThePlanterOfPlenty", "BasicEgg", "SilverEgg", "GoldEgg", "DiamondEgg", "MythicEgg", "StarEgg", "GiftedSilverEgg", "GiftedGoldEgg", "GiftedDiamondEgg", "GiftedMythicEgg", "RoyalJelly", "StarJelly", "BumbleBeeEgg", "BumbleBeeJelly", "RageBeeJelly", "ShockedBeeJelly"]
	GetRobloxClientPos()
	DetectHiddenWindows 1
	if windowWidth == 0 {
		if WinExist("Status.ahk ahk_class AutoHotkey")
			sendMessage 0x5559
		DetectHiddenWindows 0
		return 0
	}
	Prev_ShiftLock := ShiftLockEnabled
	yOffset := GetYOffset()
	nm_setShiftLock(0)
	ActivateRoblox()
	if (nm_OpenMenu("itemmenu") = 0) {
		if WinExist("Status.ahk ahk_class AutoHotkey")
			SendMessage 0x5559,, 2
		DetectHiddenWindows 0
		nm_setShiftLock(Prev_ShiftLock)
		return 0
	}
	MouseMove windowX+46, windowY+yOffset+219
	Loop 60 {
		pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY+150 "|306|" windowHeight-300)
		if (Gdip_ImageSearch(pBMScreen, bitmaps[items[chosenitem]], &itemCoords,,,,,5)) {
			Gdip_DisposeImage(pBMScreen)
			break
		}
		for k,v in items {
			if (Gdip_ImageSearch(pBMScreen, bitmaps[v], , , , , , 5)) {
				Send "{Wheel" (k > chosenItem ? "Up" : "Down") " 1}"
				break
			}
			if A_Index = items.length
				Send "{WheelUp 1}"
		}
		Gdip_DisposeImage(pBMScreen)
		sleep 300
	}
	DetectHiddenWindows 1
	if !itemCoords
		WinExist("Status.ahk ahk_class AutoHotkey") ? SendMessage(0x5559, 0, 1, , , , , , 2000) : ""
	else
		WinExist("Status.ahk ahk_class AutoHotkey") ? SendMessage(0x5559, StrSplit(itemCoords,",")[2]+windowY+140, , , , , , , 2000) : ""
	sleep 1000
	DetectHiddenWindows 0
	nm_OpenMenu()
	nm_setShiftLock(Prev_ShiftLock)
}
nm_gotoRamp(){
	global FwdKey, RightKey, HiveSlot, state, objective, HiveConfirmed
	HiveConfirmed := 0

	movement :=
	(
	nm_Walk(5, FwdKey) "
	" nm_Walk(9.2*HiveSlot-4, RightKey)
	)

	nm_createWalk(movement)
	KeyWait "F14", "D T5 L"
	KeyWait "F14", "T60 L"
	nm_endWalk()
}
nm_gotoCannon(){
	global LeftKey, RightKey, FwdKey, BackKey, currentWalk, objective, SC_Space, bitmaps

	nm_setShiftLock(0)

	hwnd := GetRobloxHWND()
	offsetY := GetYOffset(hwnd)
	GetRobloxClientPos(hwnd)
	MouseMove windowX+350, windowY+offsetY+100

	success := 0
	Loop 10
	{
		movement :=
		(
		'Send "{' SC_Space ' down}{' RightKey ' down}"
		Sleep 100
		Send "{' SC_Space ' up}"
		Walk(2)
		Send "{' FwdKey ' down}"
		Walk(1.5)
		Send "{' FwdKey ' up}"'
		)
		nm_createWalk(movement)
		KeyWait "F14", "D T5 L"
		DllCall("GetSystemTimeAsFileTime","int64p",&s:=0)
		n := s, f := s+200000000
		while (n < f)
		{
			pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2-200 "|" windowY+offsetY "|400|125")
			if (Gdip_ImageSearch(pBMScreen, bitmaps["redcannon"], , , , , , 2, , 2) = 1)
			{
				success := 1, Gdip_DisposeImage(pBMScreen)
				break
			}
			Gdip_DisposeImage(pBMScreen)
			DllCall("GetSystemTimeAsFileTime","int64p",&n)
		}
		nm_endWalk()

		if (success = 1) ; check that cannon was not overrun, at the expense of a small delay
		{
			Loop 10
			{
				if (A_Index = 10)
				{
					success := 0
					break
				}
				Sleep 500
				pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2-200 "|" windowY+offsetY "|400|125")
				if (Gdip_ImageSearch(pBMScreen, bitmaps["redcannon"], , , , , , 2, , 2) = 1)
				{
					Gdip_DisposeImage(pBMScreen)
					break 2
				}
				else
				{
					movement := nm_Walk(1.5, LeftKey)
					nm_createWalk(movement)
					KeyWait "F14", "D T5 L"
					KeyWait "F14", "T5 L"
					nm_endWalk()
				}
				Gdip_DisposeImage(pBMScreen)
			}
		}

		if (success = 0)
		{
			obj := objective
			nm_Reset()
			nm_setStatus("Traveling", obj)
			nm_gotoRamp()
		}
	}
	if (success = 0) { ;game frozen close roblox
		nm_setStatus("Detected", "Roblox Game Frozen, Restarting")
		CloseRoblox()
	}
}
nm_findHiveSlot(){
	global FwdKey, LeftKey, BackKey, RightKey, RotLeft, RotRight, ZoomIn, ZoomOut, KeyDelay, HiveConfirmed, bitmaps

	hwnd := GetRobloxHWND()
	offsetY := GetYOffset(hwnd)
	GetRobloxClientPos(hwnd)
	MouseMove windowX+350, windowY+offsetY+100


	if nm_ConfirmAtHive()
		HiveConfirmed := 1
	else
	{
		; find hive slot
		DllCall("GetSystemTimeAsFileTime","int64p",&s:=0)
		n := s, f := s+150000000
		SendInput "{" LeftKey " down}"
		while (n < f)
		{
			if nm_ConfirmAtHive() {
				HiveConfirmed := 1
				break
			}
			DllCall("GetSystemTimeAsFileTime","int64p",&n)
		}
		SendInput "{" LeftKey " up}"
	}

	if (HiveConfirmed = 1) ; check that hive slot was not overrun, at the expense of a small delay
	{
		Loop 10
		{
			if (A_Index = 10)
			{
				HiveConfirmed := 0
				break
			}
			Sleep 500
			if nm_ConfirmAtHive() {
				nm_convert()
				break
			}
			else
			{
				movement := nm_Walk(1.5, RightKey)
				nm_createWalk(movement)
				KeyWait "F14", "D T5 L"
				KeyWait "F14", "T5 L"
				nm_endWalk()
			}
			Gdip_DisposeImage(pBMScreen)
		}
	}

	return HiveConfirmed
}
;//todo: add: 1. cooldown detection, set Last__ according to detected time, 2. remove double loop for going to collects unless cooldown could not be detected
nm_Collect(){
	global GatherFieldBoostedStart, LastGlitter, resetTime

	if (nm_NightInterrupt() || nm_MondoInterrupt() || nm_GatherBoostInterrupt())
		return

	;MACHINES
	nm_Clock()
	nm_Blender()
	nm_Ant()
	nm_RoboPass()

	;DISPENSERS
	nm_HoneyDis()
	nm_TreatDis()
	nm_BlueberryDis()
	nm_StrawberryDis()
	nm_CoconutDis()
	nm_GlueDis()
	nm_RoyalJellyDis()

	;BEESMAS
	if beesmasActive {
		nm_Stockings()
		nm_Feast()
		nm_GingerbreadHouse()
		nm_SnowMachine()
		nm_Candles()
		nm_Samovar()
		nm_LidArt()
		nm_GummyBeacon()
		nm_RBPDelevel()
		nm_MemoryMatch("Winter")
	}

	;MEMORY MATCH
	nm_MemoryMatch("Normal")
	nm_MemoryMatch("Mega")
	nm_MemoryMatch("Extreme")

	;OTHER
	nm_Honeystorm()
	nm_HoneyLB()
	nm_StickerPrinter()
}
nm_Clock(){
	global ClockCheck, LastClock
	if (ClockCheck && (nowUnix()-LastClock)>3600) { ;1 hour
		hwnd := GetRobloxHWND()
		offsetY := GetYOffset(hwnd)
		GetRobloxClientPos(hwnd)
		nm_updateAction("Collect")

		Loop 2 {
			nm_Reset()
			nm_setStatus("Traveling", "Wealth Clock" ((A_Index > 1) ? " (Attempt 2)" : ""))

			nm_gotoCollect("clock")

			searchRet := nm_imgSearch("e_button.png",30,"high")
			If (searchRet[1] = 0) {
				sendinput "{" SC_E " down}"
				Sleep 100
				sendinput "{" SC_E " up}"
				Sleep 500
				nm_setStatus("Collected", "Wealth Clock")
				break
			}
		}

		LastClock:=nowUnix()
		IniWrite LastClock, "settings\nm_config.ini", "Collect", "LastClock"
		if beesmasActive
			nm_Stockings(1)
	}
}
nm_KeyVars() {
	return
	(
	'
	FwdKey:="' FwdKey '"
	LeftKey:="' LeftKey '"
	BackKey:="' BackKey '"
	RightKey:="' RightKey '"
	RotLeft:="' RotLeft '"
	RotRight:="' RotRight '"
	RotUp:="' RotUp '"
	RotDown:="' RotDown '"
	ZoomIn:="' ZoomIn '"
	ZoomOut:="' ZoomOut '"
	SC_E:="' SC_E '"
	SC_R:="' SC_R '"
	SC_L:="' SC_L '"
	SC_Esc:="' SC_Esc '"
	SC_Enter:="' SC_Enter '"
	SC_LShift:="' SC_LShift '"
	SC_Space:="' SC_Space '"
	SC_1:="' SC_1 '"
	TCFBKey:="' TCFBKey '"
	AFCFBKey:="' AFCFBKey '"
	TCLRKey:="' TCLRKey '"
	AFCLRKey:="' AFCLRKey '"
	'
	)
}
nm_Walk(tiles, MoveKey1, MoveKey2:=0){ ; string form of the function which holds MoveKey1 (and optionally MoveKey2) down for 'tiles' tiles, not to be confused with the pure form in nm_createWalk below
	return
	(
	'Send "{' MoveKey1 ' down}' (MoveKey2 ? '{' MoveKey2 ' down}"' : '"') '
	Walk(' tiles ')
	Send "{' MoveKey1 ' up}' (MoveKey2 ? '{' MoveKey2 ' up}"' : '"')
	)
}
nm_createWalk(movement, name:="", vars:="") ; this function generates the 'walk' code and runs it for a given 'movement' (AHK code string), using movespeed correction if 'NewWalk' is enabled and legacy movement otherwise
{
	; F13 is used by 'natro_macro.ahk' to tell 'walk' to complete a cycle
	; F14 is held down by 'walk' to indicate that the cycle is in progress, then released when the cycle is finished
	; F16 can be used by any script to pause / unpause the walk script, when unpaused it will resume from where it left off

	DetectHiddenWindows 1 ; allow communication with walk script

	if WinExist("ahk_pid " currentWalk.pid " ahk_class AutoHotkey")
		nm_endWalk()

	script :=
	(
	'
	#SingleInstance Off
	#NoTrayIcon
	ProcessSetPriority("AboveNormal")
	KeyHistory 0
	ListLines 0
	OnExit(ExitFunc)

	#Include "%A_ScriptDir%\lib"
	#Include "Gdip_All.ahk"
	#Include "Gdip_ImageSearch.ahk"
	#Include "HyperSleep.ahk"
	#Include "Roblox.ahk"
	'
	)

	; #Include Walk.ahk performs most of the initialisation, i.e. creating bitmaps and storing the necessary functions
	; MoveSpeedNum must contain the exact in-game movespeed without buffs so the script can calculate the true base movespeed

	. (NewWalk ?
	(
	'
	#Include "Walk.ahk"

	movespeed := ' MoveSpeedNum '
	both            := (Mod(movespeed*1000, 1265) = 0) || (Mod(Round((movespeed+0.005)*1000), 1265) = 0)
	hasty_guard     := (both || Mod(movespeed*1000, 1100) < 0.00001)
	gifted_hasty    := (both || Mod(movespeed*1000, 1150) < 0.00001)
	base_movespeed  := round(movespeed / (both ? 1.265 : (hasty_guard ? 1.1 : (gifted_hasty ? 1.15 : 1))), 0)
	'
	) :
	(
	'
	(bitmaps := Map()).CaseSense := 0
	pToken := Gdip_Startup()
	Walk(param, *) => HyperSleep(4000/' MoveSpeedNum '*param)
	'
	))

	. (
	(
	'
	offsetY := ' GetYOffset() '

	' nm_KeyVars() '
	' vars '

	start()
	return

	nm_Walk(tiles, MoveKey1, MoveKey2:=0)
	{
		Send "{" MoveKey1 " down}" (MoveKey2 ? "{" MoveKey2 " down}" : "")
		' (NewWalk ? 'Walk(tiles)' : ('HyperSleep(4000/' MoveSpeedNum '*tiles)')) '
		Send "{" MoveKey1 " up}" (MoveKey2 ? "{" MoveKey2 " up}" : "")
	}

	F13::
		start(hk?)
		{
			Send "{F14 down}"
			' movement '
			Send "{F14 up}"
		}

	F16::
	{
		static key_states := Map(LeftKey,0, RightKey,0, FwdKey,0, BackKey,0, "LButton",0, "RButton",0, SC_E,0)
		if A_IsPaused
		{
			for k,v in key_states
				if (v = 1)
					Send "{" k " down}"
		}
		else
		{
			for k,v in key_states
			{
				key_states[k] := GetKeyState(k)
				Send "{" k " up}"
			}
		}
		Pause -1
	}

	ExitFunc(*)
	{
		Send "{' LeftKey ' up}{' RightKey ' up}{' FwdKey ' up}{' BackKey ' up}{' SC_Space ' up}{F14 up}{' SC_E ' up}"
		try Gdip_Shutdown(pToken)
	}
	'
	)) ; this is just ahk code, it will be executed as a new script

	shell := ComObject("WScript.Shell")
	exec := shell.Exec('"' exe_path64 '" /script /force *')
	exec.StdIn.Write(script), exec.StdIn.Close()

	if WinWait("ahk_class AutoHotkey ahk_pid " exec.ProcessID, , 2) {
		DetectHiddenWindows 0
		currentWalk.pid := exec.ProcessID, currentWalk.name := name
		return 1
	}
	else {
		DetectHiddenWindows 0
		return 0
	}
}
nm_endWalk() ; this function ends the walk script
{
	global currentWalk
	DetectHiddenWindows 1
	try WinClose "ahk_class AutoHotkey ahk_pid " currentWalk.pid
	DetectHiddenWindows 0
	currentWalk.pid := currentWalk.name := ""
	; if issues, we can check if closed, else kill and force keys up
}
nm_loot(length, reps, direction, tokenlink:=0){ ; length in tiles instead of ms (old)
	global FwdKey, LeftKey, BackKey, RightKey, KeyDelay, bitmaps

	movement :=
	(
	'
	loop ' reps ' {
		' nm_Walk(length, FwdKey) '
		' nm_Walk(1.5, %direction%Key) '
		' nm_Walk(length, BackKey) '
		' nm_Walk(1.5, %direction%Key) '
	}
	'
	)

	nm_createWalk(movement)
	KeyWait "F14", "D T5 L"

	if (tokenlink = 0) ; wait for pattern finish
		KeyWait "F14", "T" length*reps " L"
	else ; wait for token link or pattern finish
	{
		GetRobloxClientPos()
		Sleep 1000 ; primary delay, only accept token links after this
		DllCall("GetSystemTimeAsFileTime","int64p",&s:=0)
		n := s, f := s+length*reps*10000000 ; timeout at length * reps
		while ((n < f) && GetKeyState("F14"))
		{
			pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth-400 "|" windowY+windowHeight-400 "|400|400")
			if (Gdip_ImageSearch(pBMScreen, bitmaps["tokenlink"], , , , , , 50, , 7) = 1)
			{
				Gdip_DisposeImage(pBMScreen)
				break
			}
			Gdip_DisposeImage(pBMScreen)
			Sleep 50
			DllCall("GetSystemTimeAsFileTime","int64p",&n)
		}
	}
	nm_endWalk()
}
nm_convert(){
	global AFBrollingDice, AFBuseGlitter, AFBuseBooster, CurrentField, HiveConfirmed, EnzymesKey, LastEnzymes
		, ConvertStartTime, TotalConvertTime, SessionConvertTime
		, BackpackPercent, BackpackPercentFiltered
		, PFieldBoosted, GatherFieldBoosted, GatherFieldBoostedStart, LastGlitter, GlitterKey
		, GameFrozenCounter, LastConvertBalloon, ConvertBalloon, ConvertMins, HiveBees, ConvertGatherFlag

	if (nm_NightInterrupt() || nm_MondoInterrupt())
		return

	hwnd := GetRobloxHWND()
	offsetY := GetYOffset(hwnd)
	GetRobloxClientPos(hwnd)
	pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2-200 "|" windowY+offsetY+36 "|400|120")
	if ((HiveConfirmed = 0) || (state = "Converting") || (Gdip_ImageSearch(pBMScreen, bitmaps["e_button"], , , , , , 2, , 6) = 0)) {
		Gdip_DisposeImage(pBMScreen)
		return
	}
	if (Gdip_ImageSearch(pBMScreen, bitmaps["makehoney"], , , , , , 2, , 2) = 1) {
		SendInput "{" SC_E " down}"
		Sleep 100
		SendInput "{" SC_E " up}"
	}
	Gdip_DisposeImage(pBMScreen)
	ConvertStartTime:=nowUnix()
	inactiveHoney:=0
	ballooncomplete:=0
	;empty pack
	if (BackpackPercentFiltered > 0) {
		nm_setStatus("Converting", "Backpack")
		while (((BackpackConvertTime := nowUnix()-ConvertStartTime)<300) && (BackpackPercentFiltered>0)) { ;5 mins
			Sleep 1000
			nm_AutoFieldBoost(currentField)
			if(AFBuseGlitter || AFBuseBooster) {
				nm_setStatus("Interrupted", "AFB")
				return
			}
			if (disconnectcheck()) {
				return
			}
			if (PFieldBoosted && (nowUnix()-GatherFieldBoostedStart)>780 && (nowUnix()-GatherFieldBoostedStart)<900 && (nowUnix()-LastGlitter)>900 && GlitterKey!="none") {
				nm_setStatus("Interrupted", "Field Boosted")
				return
			}
			inactiveHoney := (nm_activeHoney() = 0) ? inactiveHoney + 1 : 0
			if (BackpackConvertTime>60 && inactiveHoney>30) {
				nm_setStatus("Interrupted", "Inactive Honey")
				GameFrozenCounter++
				return
			}
			GetRobloxClientPos(hwnd)
			pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2-200 "|" windowY+offsetY+36 "|" windowWidth//2+200 "|" windowHeight-offsetY-36)
			if (Gdip_ImageSearch(pBMScreen, bitmaps["makehoney"], , , , 400, 120, 2, , 2) = 1) {
				SendInput "{" SC_E " down}"
				Sleep 100
				SendInput "{" SC_E " up}"
			}
			if ((Gdip_ImageSearch(pBMScreen, bitmaps["e_button"], , , , 400, 120, 2, , 6) = 0)
				|| ((Gdip_ImageSearch(pBMScreen, bitmaps["hiveballoon"], , windowWidth//2, windowHeight-offsetY-36-400, , , 40, , 3) = 1) && (ballooncomplete:=1))) {
				Gdip_DisposeImage(pBMScreen)
				break
			}
			Gdip_DisposeImage(pBMScreen)
		}
		duration := DurationFromSeconds(BackpackConvertTime, "mm:ss")
		nm_setStatus("Converting", "Backpack Emptied`nTime: " duration)
	}
	;empty balloon
	if((ConvertBalloon="always") || (ConvertBalloon="Every" && (nowUnix() - LastConvertBalloon)>(ConvertMins*60)) || (ConvertBalloon="Gather" && (ConvertGatherFlag=1 || (nowUnix() - LastConvertBalloon)>2700))) {
		ConvertGatherFlag := 0
		;balloon check
		strikes:=0
		while ((strikes <= 5) && (A_Index <= 50)) {
			GetRobloxClientPos(hwnd)
			pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2-200 "|" windowY+offsetY+36 "|" windowWidth//2+200 "|" windowHeight-offsetY-36)
			if ((ballooncomplete = 1) || (Gdip_ImageSearch(pBMScreen, bitmaps["hiveballoon"], , windowWidth//2, windowHeight-offsetY-36-400, , , 40, , 3) = 1)) {
				Gdip_DisposeImage(pBMScreen)
				nm_setStatus("Converting", "Balloon Refreshed")
				IniWrite LastConvertBalloon:=nowUnix(), "settings\nm_config.ini", "Settings", "LastConvertBalloon"
				PostSubmacroMessage("background", 0x5554, 6, LastConvertBalloon)
				strikes := 10
				break
			}
			if (Gdip_ImageSearch(pBMScreen, bitmaps["e_button"], , , , 400, 120, 2, , 6) != 1)
				strikes++
			Gdip_DisposeImage(pBMScreen)
			Sleep 100
		}
		if (strikes <= 5) {
			BalloonStartTime:=nowUnix()
			inactiveHoney:=0
			nm_setStatus("Converting", "Balloon")
			while((BalloonConvertTime := nowUnix()-BalloonStartTime)<600) { ;10 mins
				nm_AutoFieldBoost(currentField)
				if(AFBuseGlitter || AFBuseBooster) {
					nm_setStatus("Interrupted", "AFB")
					return
				}
				inactiveHoney := (nm_activeHoney() = 0) ? inactiveHoney + 1 : 0
				if(((EnzymesKey!="none") && (!PFieldBoosted || (PFieldBoosted && GatherFieldBoosted))) && (nowUnix()-LastEnzymes)>600 && (inactiveHoney = 0)) {
					Send "{" EnzymesKey "}"
					LastEnzymes:=nowUnix()
					IniWrite LastEnzymes, "settings\nm_config.ini", "Boost", "LastEnzymes"
				}
				if (BalloonConvertTime>60 && inactiveHoney>30) {
					nm_setStatus("Interrupted", "Inactive Honey")
					GameFrozenCounter++
					return
				}
				if (disconnectcheck()) {
					return
				}
				if ((PFieldBoosted = 1) && (nowUnix()-GatherFieldBoostedStart)>780 && (nowUnix()-GatherFieldBoostedStart)<900 && (nowUnix()-LastGlitter)>900 && GlitterKey!="none") {
					nm_setStatus("Interrupted", "Field Boosted")
					return
				}
				GetRobloxClientPos(hwnd)
				if (Mod(A_Index, 30) = 0) {
					MouseMove windowX+windowWidth-30, windowY+offsetY+16
					click
				}
				pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2-200 "|" windowY+offsetY+36 "|" windowWidth//2+200 "|" windowHeight-offsetY-36)
				if (Gdip_ImageSearch(pBMScreen, bitmaps["makehoney"], , , , 400, 120, 2, , 2) = 1) {
					SendInput "{" SC_E " down}"
					Sleep 100
					SendInput "{" SC_E " up}"
				}
				if ((Gdip_ImageSearch(pBMScreen, bitmaps["e_button"], , , , 400, 120, 2, , 6) = 0)
					|| (Gdip_ImageSearch(pBMScreen, bitmaps["hiveballoon"], , windowWidth//2, windowHeight-offsetY-36-400, , , 40, , 3) = 1)) {
					Gdip_DisposeImage(pBMScreen)
					ballooncomplete:=1
					break
				}
				Gdip_DisposeImage(pBMScreen)
				Sleep 1000
			}
			if(ballooncomplete){
				duration := DurationFromSeconds(BalloonConvertTime, "mm:ss")
				nm_setStatus("Converting", "Balloon Refreshed`nTime: " duration)
				IniWrite LastConvertBalloon:=nowUnix(), "settings\nm_config.ini", "Settings", "LastConvertBalloon"
				PostSubmacroMessage("background", 0x5554, 6, LastConvertBalloon)
			}
		}
	}
	TotalConvertTime:=TotalConvertTime+(nowUnix()-ConvertStartTime)
	SessionConvertTime:=SessionConvertTime+(nowUnix()-ConvertStartTime)
	ConvertStartTime:=0
}
nm_setSprinkler(field, loc, dist){
	global FwdKey, LeftKey, BackKey, RightKey, SC_1, SC_Space, KeyDelay, SprinklerType, MoveSpeedNum

	if (SprinklerType = "None")
		return

	;field dimensions
	switch field, 0
	{
		case "sunflower":
		flen:=1250*dist/10
		fwid:=2000*dist/10

		case "dandelion":
		flen:=2500*dist/10
		fwid:=1000*dist/10

		case "mushroom":
		flen:=1250*dist/10
		fwid:=1750*dist/10

		case "blue flower":
		flen:=2750*dist/10
		fwid:=750*dist/10

		case "clover":
		flen:=2000*dist/10
		fwid:=1500*dist/10

		case "spider":
		flen:=2000*dist/10
		fwid:=2000*dist/10

		case "strawberry":
		flen:=1500*dist/10
		fwid:=2000*dist/10

		case "bamboo":
		flen:=3000*dist/10
		fwid:=1250*dist/10

		case "pineapple":
		flen:=1750*dist/10
		fwid:=3000*dist/10

		case "stump":
		flen:=1500*dist/10
		fwid:=1500*dist/10

		case "cactus","pumpkin":
		flen:=1500*dist/10
		fwid:=2500*dist/10

		case "pine tree":
		flen:=2500*dist/10
		fwid:=1750*dist/10

		case "rose":
		flen:=2500*dist/10
		fwid:=1500*dist/10

		case "mountain top":
		flen:=2250*dist/10
		fwid:=1500*dist/10

		case "pepper","coconut":
		flen:=1500*dist/10
		fwid:=2250*dist/10
	}

	MoveSpeedFactor:=round(18/MoveSpeedNum, 2)

	;move to start position
	if(InStr(loc, "Upper")){
		nm_Move(flen*MoveSpeedFactor, FwdKey)
	} else if(InStr(loc, "Lower")){
		nm_Move(flen*MoveSpeedFactor, BackKey)
	}
	if(InStr(loc, "Left")){
		nm_Move(fwid*MoveSpeedFactor, LeftKey)
	} else if(InStr(loc, "Right")){
		nm_Move(fwid*MoveSpeedFactor, RightKey)
	}
	if(loc="center")
		Sleep 1000
	;set sprinkler(s)
	if(SprinklerType="Supreme" || SprinklerType="Basic") {
		Send "{" SC_1 "}"
		return
	} else {
		nm_JumpSprinkler(1)
	}
	if(SprinklerType="Silver" || SprinklerType="Golden" || SprinklerType="Diamond") {
		if(InStr(loc, "Upper")){
			nm_Move(1000*MoveSpeedFactor, BackKey)
		} else {
			nm_Move(1000*MoveSpeedFactor, FwdKey)
		}
		DllCall("Sleep","UInt",500)
		nm_JumpSprinkler()
	}
	if(SprinklerType="Silver") {
		if(InStr(loc, "Upper")){
			nm_Move(1000*MoveSpeedFactor, FwdKey)
		} else {
			nm_Move(1000*MoveSpeedFactor, BackKey)
		}
	}
	if(SprinklerType="Golden" || SprinklerType="Diamond") {
		if(InStr(loc, "Left")){
			nm_Move(1000*MoveSpeedFactor, RightKey)
		} else {
			nm_Move(1000*MoveSpeedFactor, LeftKey)
		}
		DllCall("Sleep","UInt",500)
		nm_JumpSprinkler()
	}
	if(SprinklerType="Golden") {
		if(InStr(loc, "Upper")){
			if(InStr(loc, "Left")){
				nm_Move(1400*MoveSpeedFactor, FwdKey, LeftKey)
			} else {
				nm_Move(1400*MoveSpeedFactor, FwdKey, RightKey)
			}
		} else {
			if(InStr(loc, "Left")){
				nm_Move(1400*MoveSpeedFactor, BackKey, LeftKey)
			} else {
				nm_Move(1400*MoveSpeedFactor, BackKey, RightKey)
			}
		}
	}
	if(SprinklerType="Diamond") {
		if(InStr(loc, "Upper")){
			nm_Move(1000*MoveSpeedFactor, FwdKey)
		} else {
			nm_Move(1000*MoveSpeedFactor, BackKey)
		}
		DllCall("Sleep","UInt",500)
		nm_JumpSprinkler()
		if(InStr(loc, "Left")){
			nm_Move(1000*MoveSpeedFactor, LeftKey)
		} else {
			nm_Move(1000*MoveSpeedFactor, RightKey)
		}
	}
}
nm_JumpSprinkler(resetDelay := 0){
	static JumpDelay := 200
	if resetDelay
		JumpDelay := 200

	GetRobloxClientPos()
	success := 0
	Loop 3 {
		Send "{" SC_Space " down}"
		Sleep JumpDelay
		Send "{" SC_1 "}{" SC_Space " up}"
		Sleep 500
		pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth-356 "|" windowY+windowHeight-326 "|340|300")
		if (Gdip_ImageSearch(pBMScreen, bitmaps["standing"], , , , , , 20) = 1) { ; jumped too high
			JumpDelay := Max(JumpDelay - 50, 100)
		} else if (Gdip_ImageSearch(pBMScreen, bitmaps["thisclose"], , , , , , 20) = 1) { ; not high enough
			JumpDelay := Min(JumpDelay + 50, 500)
		} else {
			success := 1
		}
		Gdip_DisposeImage(pBMScreen)
		Sleep 600 - JumpDelay
		if (success = 1)
			break
	}

	return success
}
nm_fieldDriftCompensation(){
	global FwdKey, LeftKey, BackKey, RightKey, DisableToolUse

	GetRobloxClientPos()
	winUp := Floor(windowHeight / 2.14), winDown := Floor(windowHeight / 1.88)
	winLeft := Floor(windowWidth / 2.14), winRight := Floor(windowWidth / 1.88)

	hmove := vmove := 0
	if ((nm_LocateSprinkler(&x, &y) = 1) && !(x >= winLeft && x <= winRight && y >= winUp && y <= winDown)) {
		if (!DisableToolUse)
			click "down"
		if ((x < winleft) && (hmove := LeftKey))
			sendinput "{" LeftKey " down}"
		else if ((x > winRight) && (hmove := RightKey))
			sendinput "{" RightKey " down}"
		if ((y < winUp) && (vmove := FwdKey))
			sendinput "{" FwdKey " down}"
		else if ((y > winDown) && (vmove := BackKey))
			sendinput "{" BackKey " down}"
		while (hmove || vmove) {
			if (((hmove = LeftKey) && (x >= winLeft)) || ((hmove = RightKey) && (x <= winRight))) {
				sendinput "{" hmove " up}"
				hmove := ""
			}
			if (((vmove = FwdKey) && (y >= winUp)) || ((vmove = BackKey) && (y <= winDown))) {
				sendinput "{" vmove " up}"
				vmove := ""
			}
			Sleep 20
			if ((A_Index >= 300)) {
				sendinput "{" LeftKey " up}{" RightKey " up}{" FwdKey " up}{" BackKey " up}"
				break
			}
			if (nm_LocateSprinkler(&x, &y) = 0) {
				sendinput "{" LeftKey " up}{" RightKey " up}{" FwdKey " up}{" BackKey " up}"
				Loop 25 {
					Sleep 20
					if (nm_LocateSprinkler(&x, &y) = 1) {
						sendinput (hmove ? "{" hmove " down} " : "") (vmove ? "{" vmove " down} " : "")
						continue 2
					}
				}
				break
			}
		}
		click "up"
	}
}
nm_LocateSprinkler(&X:="", &Y:=""){ ; find client coordinates of approximately closest saturator to player/center
	global bitmaps, sprinklerImages
	n := sprinklerImages.Length

	hwnd := GetRobloxHWND()
	offsetY := GetYOffset(hwnd)
	GetRobloxClientPos(hwnd)
	pBMScreen := Gdip_BitmapFromScreen(windowX "|" (windowY + offsetY + 75) "|" (hWidth := windowWidth) "|" (hHeight := windowHeight - offsetY - 75) "|")

	Gdip_LockBits(pBMScreen, 0, 0, hWidth, hHeight, &hStride, &hScan, &hBitmapData, 1)
	hWidth := NumGet(hBitmapData, 0, "UInt"), hHeight := NumGet(hBitmapData, 4, "UInt")

	local n1width, n1height, n1Stride, n1Scan, n1BitmapData
		, n1width, n1height, n2Stride, n2Scan, n2BitmapData
		, n1width, n1height, n3Stride, n3Scan, n3BitmapData
	for i,k in sprinklerImages
	{
		Gdip_GetImageDimensions(bitmaps[k], &n%i%Width, &n%i%Height)
		Gdip_LockBits(bitmaps[k], 0, 0, n%i%Width, n%i%Height, &n%i%Stride, &n%i%Scan, &n%i%BitmapData)
		n%i%Width := NumGet(n%i%BitmapData, 0, "UInt"), n%i%Height := NumGet(n%i%BitmapData, 4, "UInt")
	}

	d := 11 ; divisions (odd positive integer such that w,h > n%i%Width,n%i%Height for all i<=n)
	m := d//2 ; midpoint of d (along with m + 1), used frequently in calculations
	v := 50 ; variation
	w := hWidth//d, h := hHeight//d

	; to search from centre (approximately), we will split the rectangle like a pinwheel configuration and search outwards (notice SearchDirection)
	Loop m + 1
	{
		if (A_Index = 1)
		{
			; initial rectangle (center)
			d1 := m, d2 := m + 1
			OuterX1 := d1 * w, OuterX2 := d2 * w
			OuterY1 := d1 * h, OuterY2 := d2 * h
			Loop n
				if (Gdip_MultiLockedBitsSearch(hStride, hScan, hWidth, hHeight, n%A_Index%Stride, n%A_Index%Scan, n%A_Index%Width, n%A_Index%Height, &pos, OuterX1, OuterY1, OuterX2-n%A_Index%Width+1, OuterY2-n%A_Index%Height+1, v, 1, 1) > 0)
					break 2
		}
		else
		{
			; upper-right
			dx1 := m + 2 - A_Index, dx2 := m + A_Index
			OuterX1 := dx1 * w, OuterX2 := dx2 * w
			dy1 := m + 1 - A_Index, dy2 := m + 2 - A_Index
			OuterY1 := dy1 * h, OuterY2 := dy2 * h
			Loop n
				if (Gdip_MultiLockedBitsSearch(hStride, hScan, hWidth, hHeight, n%A_Index%Stride, n%A_Index%Scan, n%A_Index%Width, n%A_Index%Height, &pos, OuterX1, OuterY1, OuterX2-n%A_Index%Width+1, OuterY2-n%A_Index%Height+1, v, 2, 1) > 0)
					break 2

			; lower-right
			dx1 := m - 1 + A_Index, dx2 := m + A_Index
			OuterX1 := dx1 * w, OuterX2 := dx2 * w
			dy1 := m + 2 - A_Index, dy2 := m + A_Index
			OuterY1 := dy1 * h, OuterY2 := dy2 * h
			Loop n
				if (Gdip_MultiLockedBitsSearch(hStride, hScan, hWidth, hHeight, n%A_Index%Stride, n%A_Index%Scan, n%A_Index%Width, n%A_Index%Height, &pos, OuterX1, OuterY1, OuterX2-n%A_Index%Width+1, OuterY2-n%A_Index%Height+1, v, 5, 1) > 0)
					break 2

			; lower-left
			dx1 := m + 1 - A_Index, dx2 := m - 1 + A_Index
			OuterX1 := dx1 * w, OuterX2 := dx2 * w
			dy1 := m - 1 + A_Index, dy2 := m + A_Index
			OuterY1 := dy1 * h, OuterY2 := dy2 * h
			Loop n
				if (Gdip_MultiLockedBitsSearch(hStride, hScan, hWidth, hHeight, n%A_Index%Stride, n%A_Index%Scan, n%A_Index%Width, n%A_Index%Height, &pos, OuterX1, OuterY1, OuterX2-n%A_Index%Width+1, OuterY2-n%A_Index%Height+1, v, 4, 1) > 0)
					break 2

			; upper-left
			dx1 := m + 1 - A_Index, dx2 := m + 2 - A_Index
			OuterX1 := dx1 * w, OuterX2 := dx2 * w
			dy1 := m + 1 - A_Index, dy2 := m - 1 + A_Index
			OuterY1 := dy1 * h, OuterY2 := dy2 * h
			Loop n
				if (Gdip_MultiLockedBitsSearch(hStride, hScan, hWidth, hHeight, n%A_Index%Stride, n%A_Index%Scan, n%A_Index%Width, n%A_Index%Height, &pos, OuterX1, OuterY1, OuterX2-n%A_Index%Width+1, OuterY2-n%A_Index%Height+1, v, 7, 1) > 0)
					break 2
		}
	}

	Gdip_UnlockBits(pBMScreen,&hBitmapData)
	for i,k in sprinklerImages
		Gdip_UnlockBits(bitmaps[k],&n%i%BitmapData)
	Gdip_DisposeImage(pBMScreen)

	if pos
	{
		x := SubStr(pos, 1, InStr(pos, ",") - 1), y := 75 + SubStr(pos, InStr(pos, ",") + 1)
		return 1
	}
	else
	{
		x := "", y := ""
		return 0
	}
}
;move function //todo: deprecated! replace throughout script with nm_Walk
nm_Move(MoveTime, MoveKey1, MoveKey2:="None"){
	PrevKeyDelay:=A_KeyDelay
	SetKeyDelay 5
	Send "{" MoveKey1 " down}"
	if(MoveKey2!="None")
		Send "{" MoveKey2 " down}"
	DllCall("Sleep","UInt",MoveTime)
	Send "{" MoveKey1 " up}"
	if(MoveKey2!="None")
		Send "{" MoveKey2 " up}"
	SetKeyDelay PrevKeyDelay
}
CloseRoblox()
{
	; if roblox exists, activate it and send Esc+L+Enter
	if (hwnd := GetRobloxHWND())
	{
		GetRobloxClientPos(hwnd)
		if (windowHeight >= 500) ; requirement for L to activate "Leave"
		{
			ActivateRoblox()
			PrevKeyDelay := A_KeyDelay
			SetKeyDelay 250+KeyDelay
			send "{" SC_Esc "}{" SC_L "}{" SC_Enter "}"
			SetKeyDelay PrevKeyDelay
		}
		try WinClose "Roblox"
		Sleep 500
		try WinClose "Roblox"
		Sleep 4500 ;Delay to prevent Roblox Error Code 264
	}
	; kill any remnant processes
	for p in ComObjGet("winmgmts:").ExecQuery("SELECT * FROM Win32_Process WHERE Name LIKE '%Roblox%' OR CommandLine LIKE '%ROBLOXCORPORATION%'")
		ProcessClose p.ProcessID
}
DisconnectCheck(testCheck := 0)
{
	global LastClock, LastGingerbread, HiveSlot, PrivServer, TotalDisconnects, SessionDisconnects, ReconnectMethod, PublicFallback, resetTime
		, PlanterName1, PlanterName2, PlanterName3, PlanterHarvestTime1, PlanterHarvestTime2, PlanterHarvestTime3
		, MacroState, ReconnectDelay
		, FallbackServer1, FallbackServer2, FallbackServer3, beesmasActive
	static ServerLabels := Map(0,"Public Server", 1,"Private Server", 2,"Fallback Server 1", 3,"Fallback Server 2", 4,"Fallback Server 3")

	; return if not disconnected or crashed
	ActivateRoblox()
	GetRobloxClientPos()
	if ((windowWidth > 0) && !WinExist("Roblox Crash")) {
		pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2 "|" windowY+windowHeight//2 "|200|80")
		if (Gdip_ImageSearch(pBMScreen, bitmaps["disconnected"], , , , , , 2) != 1) {
			Gdip_DisposeImage(pBMScreen)
			return 0
		}
		Gdip_DisposeImage(pBMScreen)
	}

	; end any residual movement and set reconnect start time
	Click "Up"
	nm_endWalk()
	ReconnectStart := nowUnix()
	nm_updateAction("Reconnect")

	; wait for any requested delay time (e.g. from remote control or daily reconnect)
	if (ReconnectDelay) {
		nm_setStatus("Waiting", ReconnectDelay " seconds before Reconnect")
		Sleep 1000*ReconnectDelay
		ReconnectDelay := 0
	}
	else if (MacroState = 2) {
		TotalDisconnects:=TotalDisconnects+1
		SessionDisconnects:=SessionDisconnects+1
		PostSubmacroMessage("StatMonitor", 0x5555, 6, 1)
		IniWrite TotalDisconnects, "settings\nm_config.ini", "Status", "TotalDisconnects"
		IniWrite SessionDisconnects, "settings\nm_config.ini", "Status", "SessionDisconnects"
		nm_setStatus("Disconnected", "Reconnecting")
	}

	; obtain link codes from Private Server and Fallback Server links
	PossibleServers := Map()
	for index,server in ["PrivServer", "FallbackServer1", "FallbackServer2", "FallbackServer3"] {
		if (%server% && (StrLen(%server%) > 0)) {
			(PossibleServers[index] := Map()).CaseSense := 0, PossibleServers[index]["link"] := %server% ;httplink used for browser reconnect
			if RegexMatch(%server%, "i)(?<=privateServerLinkCode=)(.{32})", &linkCode)
				PossibleServers[index]["code"] := linkCode[0], PossibleServers[index]["type"] := "LinkCode"
			else if RegexMatch(%server%, "i)(?<=share\?code=)(.{32})(?=&type=Server)", &ShareCode)
				PossibleServers[index]["code"] :=  ShareCode[0], PossibleServers[index]["type"] := "ShareCode"
			else
				nm_setStatus("Error", ServerLabels[index] " Invalid")
		}
	}
	; public server
	PossibleServers[0] := Map("type", "None", "code", "")

	; main reconnect loop
	usingBrowser := false
	Loop {
		;Decide Server
		server := ((A_Index <= 20) && PossibleServers.Has(n := (A_Index-1)//5 + 1)) ? n : ((PublicFallback = 0) && (n := ObjMinIndex(PossibleServers))) ? n : 0
		;tooltip(reconnect_debug := "server: " server "(" ServerLabels[server] " : " PossibleServers[server]["type"] "): [" A_Index "]`n" PossibleServers[server]["code"])
		;Wait For Success
		i := A_Index, success := 0
		Loop 5 {
			;Close browser tabs if browser was used
			if usingBrowser
				CloseBrowserTabs()
			usingBrowser := false
			;START
			switch (ReconnectMethod = "Browser") ? 0 : Mod(i, 5) {
				case 1,2:
				;Close Roblox
				CloseRoblox()
				;Run Server Deeplink
				nm_setStatus("Attempting", ServerLabels[server])
				RunDeeplink(PossibleServers[server]["type"], PossibleServers[server]["code"])

				case 3,4:
				;Run Server Deeplink (without closing)
				nm_setStatus("Attempting", ServerLabels[server])
				RunDeeplink(PossibleServers[server]["type"], PossibleServers[server]["code"])

				default:
				if server {
					;Close Roblox
					CloseRoblox()
					;Run Server Link (legacy method w/ browser)
					nm_setStatus("Attempting", ServerLabels[server] " (Browser)")
					RunBrowser(PossibleServers[server]["link"])
					usingBrowser := true
				} else {
					;Close Roblox
					(i = 1) && CloseRoblox()
					;Run Server Link (spam deeplink method)
					RunDeeplink()
				}
			}
			;STAGE 1 - wait for Roblox window
			Loop 240 {
				if GetRobloxHWND() {
					ActivateRoblox()
					nm_setStatus("Detected", "Roblox Open")
					break
				}
				if (A_Index = 240) {
					nm_setStatus("Error", "No Roblox Found`nRetry: " i)
					break 2
				}
				Sleep 1000 ; timeout 4 mins, wait for any Roblox update to finish
			}
			;STAGE 2 - wait for loading screen (or loaded game)
			Loop 180 {
				ActivateRoblox()
				if !GetRobloxClientPos() {
					nm_setStatus("Warning", "Disconnected during Reconnect")
					continue 2
				}
				pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY+30 "|" windowWidth "|" windowHeight-30)
				if (Gdip_ImageSearch(pBMScreen, bitmaps["loading"], , , , , 150, 4) = 1) {
					Gdip_DisposeImage(pBMScreen)
					nm_setStatus("Detected", "Game Open")
					break
				}
				if (Gdip_ImageSearch(pBMScreen, bitmaps["science"], , , , , 150, 2) = 1) {
					Gdip_DisposeImage(pBMScreen)
					nm_setStatus("Detected", "Game Loaded")
					success := 1
					break 2
				}
				if (Gdip_ImageSearch(pBMScreen, bitmaps["disconnected"], , , , , , 2) = 1) {
					Gdip_DisposeImage(pBMScreen)
					nm_setStatus("Warning", "Disconnected during Reconnect")
					continue 2
				}
				Gdip_DisposeImage(pBMScreen)
				if (A_Index = 180) {
					nm_setStatus("Error", "No BSS Found`nRetry: " i)
					break 2
				}
				Sleep 1000 ; timeout 3 mins, slow loading
			}
			;STAGE 3 - wait for loaded game
			Loop 180 {
				ActivateRoblox()
				if !GetRobloxClientPos() {
					nm_setStatus("Warning", "Disconnected during Reconnect")
					continue 2
				}
				pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY+30 "|" windowWidth "|" windowHeight-30)
				if ((Gdip_ImageSearch(pBMScreen, bitmaps["loading"], , , , , 150, 4) = 0) || (Gdip_ImageSearch(pBMScreen, bitmaps["science"], , , , , 150, 2) = 1)) {
					Gdip_DisposeImage(pBMScreen)
					nm_setStatus("Detected", "Game Loaded")
					success := 1
					break 2
				}
				if (Gdip_ImageSearch(pBMScreen, bitmaps["disconnected"], , , , , , 2) = 1) {
					Gdip_DisposeImage(pBMScreen)
					nm_setStatus("Warning", "Disconnected during Reconnect")
					continue 2
				}
				Gdip_DisposeImage(pBMScreen)
				if (A_Index = 180) {
					nm_setStatus("Error", "BSS Load Timeout`nRetry: " i)
					break 2
				}
				Sleep 1000 ; timeout 3 mins, slow loading
			}
		}

		;Successful Reconnect
		if (success = 1)
		{
			if usingBrowser
				CloseBrowserTabs(), Sleep(1000) ;addition sleep, prevent not tabbing back to roblox
			ActivateRoblox()
			GetRobloxClientPos()
			MouseMove windowX + windowWidth//2, windowY + windowHeight//2
			duration := DurationFromSeconds(ReconnectDuration := (nowUnix() - ReconnectStart), "mm:ss")
			nm_setStatus("Completed", "Reconnect`nTime: " duration " - Attempts: " i)
			Sleep 500

			LastClock:=nowUnix()
			IniWrite LastClock, "settings\nm_config.ini", "Collect", "LastClock"
			if (beesmasActive)
			{
				LastGingerbread += ReconnectDuration ? ReconnectDuration : 300
				IniWrite LastGingerbread, "settings\nm_config.ini", "Collect", "LastGingerbread"
			}
			Loop 3 {
				PlanterHarvestTime%A_Index% += PlanterName%A_Index% ? (ReconnectDuration ? ReconnectDuration : 300) : 0
				IniWrite PlanterHarvestTime%A_Index%, "settings\nm_config.ini", "Planters", "PlanterHarvestTime" A_Index
			}

			if (server > 1) ; swap PrivServer and FallbackServer - original PrivServer probably has an issue
			{
				n := server - 1
				temp := PrivServer, PrivServer := FallbackServer%n%, FallbackServer%n% := temp
				MainGui["PrivServer"].Value := PrivServer
				MainGui["FallbackServer" n].Value := FallbackServer%n%
				IniWrite PrivServer, "settings\nm_config.ini", "Settings", "PrivServer"
				IniWrite FallbackServer%n%, "settings\nm_config.ini", "Settings", "FallbackServer" n
				PostSubmacroMessage("Status", 0x5553, 10, 6)
			}
			PostSubmacroMessage("Status", 0x5552, 221, (server = 0))

			if (testCheck || (nm_claimHiveSlot() = 1))
				return 1
		}

		RunDeeplink(type:="", code:=""){
			switch type {
				case "LinkCode":
					try Run '"roblox://placeID=1537690962&linkcode=' code '"'
				case "ShareCode":
					try Run '"roblox://navigation/share_links?code=' code '&type=Server"'
				default:
					try Run '"roblox://placeID=1537690962"'
			}
		}

		RunBrowser(url){
			static cmd := Buffer(512), init := (DllCall("shlwapi\AssocQueryString", "Int",0, "Int",1, "Str","http", "Str","open", "Ptr",cmd.Ptr, "IntP",512),
			DllCall("Shell32\SHEvaluateSystemCommandTemplate", "Ptr",cmd.Ptr, "PtrP",&pEXE:=0,"Ptr",0,"PtrP",&pPARAMS:=0))
			, exe := (pEXE > 0) ? StrGet(pEXE) : ""
			, params := (pPARAMS > 0) ? StrGet(pPARAMS) : ""

			;seems like ShellRun is less consistent
			if ((StrLen(exe) > 0) && (StrLen(params) > 0)) {
				ShellRun(exe, StrReplace(params, "%1", url))
				;tooltip(reconnect_debug . "`nShellRun")
			}
			else {
				Run('"' url '"')
				;tooltip(reconnect_debug . "`nRun")
			}
		}

		CloseBrowserTabs(){
			for hwnd in WinGetList(,, "Program Manager")
			{
				p := WinGetProcessName("ahk_id " hwnd)
				if (InStr(p, "Roblox") || InStr(p, "AutoHotkey"))
					continue ; skip roblox and AHK windows
				title := WinGetTitle("ahk_id " hwnd)
				if (title = "")
					continue ; skip empty title windows
				s := WinGetStyle("ahk_id " hwnd)
				if ((s & 0x8000000) || !(s & 0x10000000))
					continue ; skip NoActivate and invisible windows
				s := WinGetExStyle("ahk_id " hwnd)
				if ((s & 0x80) || (s & 0x40000) || (s & 0x8))
					continue ; skip ToolWindow and AlwaysOnTop windows
				try
				{
					WinActivate "ahk_id " hwnd
					Sleep 500
					Send "^{w}"
				}
				break
			}
		}
	}
}
/*
ShellRun by Lexikos
	requires: AutoHotkey v1.1
	license: http://creativecommons.org/publicdomain/zero/1.0/
Credit for explaining this method goes to BrandonLive:
http://brandonlive.com/2008/04/27/getting-the-shell-to-run-an-application-for-you-part-2-how/

Shell.ShellExecute(File [, Arguments, Directory, Operation, Show])
http://msdn.microsoft.com/en-us/library/windows/desktop/gg537745
*/
;Note might have to use for deeplinking if we have roblox admin issues
ShellRun(prms*)
{
	shellWindows := ComObject("Shell.Application").Windows
	desktop := shellWindows.FindWindowSW(0, 0, 8, 0, 1) ; SWC_DESKTOP, SWFO_NEEDDISPATCH

	; Retrieve top-level browser object.
	tlb := ComObjQuery(desktop,
		"{4C96BE40-915C-11CF-99D3-00AA004AE837}", ; SID_STopLevelBrowser
		"{000214E2-0000-0000-C000-000000000046}") ; IID_IShellBrowser

	; IShellBrowser.QueryActiveShellView -> IShellView
	ComCall(15, tlb, "ptr*", sv := ComValue(13, 0)) ; VT_UNKNOWN

	; Define IID_IDispatch.
	NumPut("int64", 0x20400, "int64", 0x46000000000000C0, IID_IDispatch := Buffer(16))

	; IShellView.GetItemObject -> IDispatch (object which implements IShellFolderViewDual)
	ComCall(15, sv, "uint", 0, "ptr", IID_IDispatch, "ptr*", sfvd := ComValue(9, 0)) ; VT_DISPATCH

	; Get Shell object.
	shell := sfvd.Application

	; IShellDispatch2.ShellExecute
	shell.ShellExecute(prms*)
}
nm_claimHiveSlot(){
	global KeyDelay, FwdKey, RightKey, LeftKey, BackKey, ZoomOut, HiveSlot, HiveConfirmed, SC_E, SC_Esc, SC_R, SC_Enter, bitmaps
	GetBitmap() {
		pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2-200 "|" windowY+offsetY "|400|125")
		loop 20 {
			for , bitmap in bitmaps["FriendJoin"] {
				if (Gdip_ImageSearch(pBMScreen, bitmap, , , , , , 6) = 1) {
					Gdip_DisposeImage(pBMScreen)
					MouseMove windowX+windowWidth//2-3, windowY+24
					Click
					MouseMove windowX+350, windowY+offsetY+100
					Sleep 500
					pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2-200 "|" windowY+offsetY "|400|125")
				}
			}
		}
		return pBMScreen
	}

	DetectHiveslots := 1
	Loop 5
	{
		ActivateRoblox()
		hwnd := GetRobloxHWND()
		offsetY := GetYOffset(hwnd)
		GetRobloxClientPos(hwnd)
		MouseMove windowX+350, windowY+offsetY+100

		;reset
		if (A_Index > 1)
		{
			resetTime:=nowUnix()
			PostSubmacroMessage("background", 0x5554, 1, resetTime)
			ActivateRoblox()
			PrevKeyDelay := A_KeyDelay
			SetKeyDelay 250+KeyDelay
			send "{" SC_Esc "}{" SC_R "}{" SC_Enter "}"
			SetKeyDelay PrevKeyDelay
			n := 0
			while ((n < 2) && (A_Index <= 80))
			{
				Sleep 100
				GetRobloxClientPos(hwnd)
				pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY "|" windowWidth "|50")
				n += (Gdip_ImageSearch(pBMScreen, bitmaps["emptyhealth"], , , , , , 10) = (n = 0))
				Gdip_DisposeImage(pBMScreen)
			}
			Sleep 1000
		}

		; detect unclaimed hive slots.
		if DetectHiveslots {
			preferred := (ClaimMethod = "Detect") ? 0 : HiveSlot
			if ClaimMethod = "Detect" {
				slots := nm_detectHiveSlots()
				for i, slot in slots {
					if (HiveSlot = slot.HiveSlot && slot.Claimed = "Empty") {
						preferred := HiveSlot
						break
					}
				}

				if (!preferred) {
					for i, slot in slots {
						if (slot.Claimed = "Empty") {
							preferred := slot.HiveSlot
							break
						}
					}
				}
			}
			if (preferred) {
				movement := nm_spawnMoveTo(slotMove[preferred])
				nm_createWalk(movement)
				KeyWait "F14", "D T5 L"
				KeyWait "F14", "T20 L"
				nm_endWalk()
				sleep 500
				pBMScreen := GetBitmap()
				if (Gdip_ImageSearch(pBMScreen, bitmaps["claimhive"], , , , , , 2, , 6) = 1) {
					Gdip_DisposeImage(pBMScreen)
					Send "{" SC_E " down}"
					sleep 100
					Send "{" SC_E " up}"
					HiveConfirmed := 1
					HiveSlot := preferred
					MainGui["HiveSlot"].Text := HiveSlot
					IniWrite HiveSlot, "settings\nm_config.ini", "Settings", "HiveSlot"
					nm_setStatus("Claimed", "Hive Slot " HiveSlot)
					MouseMove windowX+350, windowY+offsetY+100
					return 1
				}
				Gdip_DisposeImage(pBMScreen)
			}
			DetectHiveslots := 0
			continue
		}

		; old system

		;go to slot 1
		Sleep 500
		GetRobloxClientPos(hwnd)
		MouseMove windowX+350, windowY+offsetY+100
		send "{" ZoomOut " 8}"

		movement :=
		(
		'Send "{' RightKey ' down}"
		Walk(4)
		Send "{' FwdKey ' down}"
		Walk(20)
		Send "{' RightKey ' up}{' FwdKey ' up}"'
		)
		nm_createWalk(movement)
		KeyWait "F14", "D T5 L"
		KeyWait "F14", "T20 L"
		nm_endWalk()

		;check slots 1 to old HiveSlot
		slots := Map()
		movement := nm_Walk(9.2, LeftKey)
		Loop HiveSlot
		{
			if (A_Index > 1)
			{
				nm_createWalk(movement)
				KeyWait "F14", "D T5 L"
				KeyWait "F14", "T20 L"
				nm_endWalk()
			}

			Sleep 500
			pBMScreen := GetBitmap()
			if (Gdip_ImageSearch(pBMScreen, bitmaps["claimhive"], , , , , , 2, , 6) = 1)
				slots[A_Index] := 1
			Gdip_DisposeImage(pBMScreen)
		}

		if (slots.Has(HiveSlot) && (slots[HiveSlot] = 1))
			break
		else
		{
			if ((slot := ObjMinIndex(slots)) > 0)
			{
				movement := nm_Walk((HiveSlot - slot) * 9.2, RightKey)
				nm_createWalk(movement)
				KeyWait "F14", "D T5 L"
				KeyWait "F14", "T20 L"
				nm_endWalk()

				Sleep 500
				pBMScreen := GetBitmap()
				if (Gdip_ImageSearch(pBMScreen, bitmaps["claimhive"], , , , , , 2, , 6) = 1) {
					Gdip_DisposeImage(pBMScreen)
					HiveSlot := slot
					break
				}
				Gdip_DisposeImage(pBMScreen)
			}
			else {
				Loop (6 - HiveSlot)
				{
					nm_createWalk(movement)
					KeyWait "F14", "D T5 L"
					KeyWait "F14", "T20 L"
					nm_endWalk()

					Sleep 500
					pBMScreen := GetBitmap()
					if (Gdip_ImageSearch(pBMScreen, bitmaps["claimhive"], , , , , , 2, , 6) = 1) {
						Gdip_DisposeImage(pBMScreen)
						HiveSlot += A_Index
						break 2
					}
					Gdip_DisposeImage(pBMScreen)
				}
			}
		}

		nm_setStatus("Failed", "Claim Hive Slot" ((A_Index > 1) ? (" (Attempt " A_Index ")") : ""))
		if (A_Index = 5)
			return 0
	}

	SendInput "{" SC_E " down}"
	Sleep 100
	SendInput "{" SC_E " up}"
	HiveConfirmed := 1
	;update hive slot
	MainGui["HiveSlot"].Text := HiveSlot
	IniWrite HiveSlot, "settings\nm_config.ini", "Settings", "HiveSlot"
	nm_setStatus("Claimed", "Hive Slot " HiveSlot)
	MouseMove windowX+350, windowY+offsetY+100

	return 1
}
nm_activeHoney(){
	global HiveBees, GameFrozenCounter
	if (hwnd := GetRobloxHWND()) {
		GetRobloxClientPos(hwnd)
		offsetY := GetYOffset(hwnd)
		x1 := windowX + windowWidth//2 - 90
		y1 := windowY + offsetY
		try
			result := PixelSearch(&bx2, &by2, x1, y1, x1+70, y1+34, 0xFFE280, 20)
		catch
			result := 0
		if (result = 1){
			GameFrozenCounter:=0
			return 1
		} else {
			if(HiveBees<25){
				x1 := windowX + windowWidth//2 + 210
				y1 := windowY + offsetY
				try
					result := PixelSearch(&bx2, &by2, x1, y1, x1+70, y1+34, 0xFFFFFF, 20)
				catch
					result := 0
				return result
			} else {
				return 0
			}
		}
	} else {
		return 0
	}
}
nm_searchForE(){
	global FwdKey, LeftKey, BackKey, RightKey, RotLeft, RotRight, bitmaps

	movement :=
	(
	'
	Loop 8
	{
		i := A_Index
		Loop 2
		{
			Send "{' FwdKey ' down}"
			Walk(3*i)
			Send "{' FwdKey ' up}{' RotRight ' 2}"
		}
	}
	'
	)
	nm_createWalk(movement)
	KeyWait "F14", "D T5 L"

	hwnd := GetRobloxHWND()
	offsetY := GetYOffset(hwnd)
	GetRobloxClientPos(hwnd)
	MouseMove windowX+350, windowY+offsetY+100
	success := 0
	DllCall("GetSystemTimeAsFileTime","int64p",&s:=0)
	n := s, f := s+90*10000000 ; 90 second timeout
	while (n < f && GetKeyState("F14"))
	{
		pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2-200 "|" windowY+offsetY+36 "|200|120")
		if (Gdip_ImageSearch(pBMScreen, bitmaps["e_button"], , , , , , 2, , 6) = 1)
		{
			success := 1, Gdip_DisposeImage(pBMScreen)
			break
		}
		Gdip_DisposeImage(pBMScreen)
		DllCall("GetSystemTimeAsFileTime","int64p",&n)
	}
	nm_endWalk()

	if (success = 1) ; check that planter was not overrun, at the expense of a small delay
	{
		Loop 10
		{
			if (A_Index = 10)
			{
				success := 0
				break
			}
			Sleep 500
			pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2-200 "|" windowY+offsetY+36 "|200|120")
			if (Gdip_ImageSearch(pBMScreen, bitmaps["e_button"], , , , , , 2, , 6) = 1)
			{
				Gdip_DisposeImage(pBMScreen)
				break
			}
			else
			{
				movement := nm_Walk(1.5, BackKey)
				nm_createWalk(movement)
				KeyWait "F14", "D T5 L"
				KeyWait "F14", "T5 L"
				nm_endWalk()
			}
			Gdip_DisposeImage(pBMScreen)
		}
	}
	return success
}
nm_boostBypassCheck() => 0 ; always returns 0 for now: no field boost bypass implemented
nm_Night(){
	global CheckNight

	if CheckNight != 1
		return

	if !nm_confirmNight()
		return CheckNight := 0

	nm_NightMemoryMatch()
	nm_ViciousBee()
	CheckNight := 0
}

nm_confirmNight()
{
	isNight := 0
	nm_Reset(0, 0, 0)
	nm_setStatus("Confirming", "Night")
	ActivateRoblox()
	GetRobloxClientPos()

	Send "{" RotUp " 10}"

	loop 7
		Send("{" ZoomOut "}"), Sleep(25)

	pBMArea := Gdip_BitmapFromScreen(windowX+300 "|" windowY+windowHeight//2+50 "|" windowWidth-600 "|" windowHeight//2-50) ; searches bottom middle of the screen with offset

	for key, bitmap in bitmaps["confirm_night"]
		if Gdip_ImageSearch(pBMArea, bitmap) = 1
			isNight := 1

	Gdip_DisposeImage(pBMArea)
	Send "{" RotDown " 4}"

	if isNight
		nm_SetStatus("Confirmed", "Night")
	else
		nm_SetStatus("Aborting", "Not night")

	return isNight
}
nm_NightInterrupt() => CheckNight=1 && ((NightMemoryMatchCheck && (nowUnix()-LastNightMemoryMatch)>28800) || !(StingerCheck=0 || (StingerDailyBonusCheck=1 && (VBStart-VBLastKilled)<79200)))

nm_hotbar(boost:=0){
	global state, fieldOverrideReason, GatherStartTime, ActiveHotkeys, bitmaps
		, HotbarMax2, HotbarMax3, HotbarMax4, HotbarMax5, HotbarMax6, HotbarMax7
		, LastHotkey2, LastHotkey3, LastHotkey4, LastHotkey5, LastHotkey6, LastHotkey7
		, beesmasActive, QuestBoostCheck
	;whileNames:=["Always", "Attacking", "Gathering", "At Hive"]
	;ActiveHotkeys.push([val, slot, HBSecs, LastHotkey%slot%])
	for key, val in ActiveHotkeys {
		;ActiveLen:=ActiveHotkeys.Length
		;temp1:=ActiveHotkeys[1][1]
		;temp2:=ActiveHotkeys[key][2]
		;temp3:=ActiveHotkeys[key][3]
		;temp4:=ActiveHotkeys[key][4]
		;always
		if(ActiveHotkeys[key][1]="Always" && (nowUnix()-ActiveHotkeys[key][4])>ActiveHotkeys[key][3]) {
			HotkeyNum:=ActiveHotkeys[key][2]
			send "{sc00" HotkeyNum+1 "}"
			LastHotkeyN:=nowUnix()
			IniWrite LastHotkeyN, "settings\nm_config.ini", "Boost", "LastHotkey" HotkeyNum
			ActiveHotkeys[key][4]:=LastHotkeyN
			break
		}
		;attacking
		else if(state="Attacking" && ActiveHotkeys[key][1]="Attacking" && (nowUnix()-ActiveHotkeys[key][4])>ActiveHotkeys[key][3]) {
			HotkeyNum:=ActiveHotkeys[key][2]
			send "{sc00" HotkeyNum+1 "}"
			LastHotkeyN:=nowUnix()
			IniWrite LastHotkeyN, "settings\nm_config.ini", "Boost", "LastHotkey" HotkeyNum
			ActiveHotkeys[key][4]:=LastHotkeyN
			break
		}
		;gathering
		else if(state="Gathering" && (fieldOverrideReason!="Quest" || (QuestBoostCheck = 1 && fieldOverrideReason="Quest")) && ActiveHotkeys[key][1]="Gathering" && (nowUnix()-ActiveHotkeys[key][4])>ActiveHotkeys[key][3]) {
			HotkeyNum:=ActiveHotkeys[key][2]
			send "{sc00" HotkeyNum+1 "}"
			LastHotkeyN:=nowUnix()
			IniWrite LastHotkeyN, "settings\nm_config.ini", "Boost", "LastHotkey" HotkeyNum
			ActiveHotkeys[key][4]:=LastHotkeyN
			break
		}
		;GatherStart
		else if(state="Gathering" && (fieldOverrideReason="None" || fieldOverrideReason="Boost" || (QuestBoostCheck = 1 && fieldOverrideReason="Quest")) && (nowUnix()-GatherStartTime)<10 && ActiveHotkeys[key][1]="GatherStart" && (nowUnix()-ActiveHotkeys[key][4])>ActiveHotkeys[key][3]) {
			HotkeyNum:=ActiveHotkeys[key][2]
			send "{sc00" HotkeyNum+1 "}"
			LastHotkeyN:=nowUnix()
			IniWrite LastHotkeyN, "settings\nm_config.ini", "Boost", "LastHotkey" HotkeyNum
			if(ActiveHotkeys[key][3]<=10) {
				ActiveHotkeys[key][4]:=LastHotkeyN+10
			} else {
				ActiveHotkeys[key][4]:=LastHotkeyN
			}
			break
		}
		;at hive
		else if(state="Converting" && ActiveHotkeys[key][1]="At Hive" && (nowUnix()-ActiveHotkeys[key][4])>ActiveHotkeys[key][3]) {
			HotkeyNum:=ActiveHotkeys[key][2]
			send "{sc00" HotkeyNum+1 "}"
			LastHotkeyN:=nowUnix()
			IniWrite LastHotkeyN, "settings\nm_config.ini", "Boost", "LastHotkey" HotkeyNum
			ActiveHotkeys[key][4]:=LastHotkeyN
			break
		}
		;snowflake
		else if(beesmasActive && (ActiveHotkeys[key][1]="Snowflake") && (nowUnix()-ActiveHotkeys[key][4])>ActiveHotkeys[key][3]) {
			GetRobloxClientPos()
			offsetY := GetYOffset()
			;check that roblox window exists
			if (windowWidth > 0) {
				pBMArea := Gdip_BitmapFromScreen(windowX "|" windowY+offsetY+30 "|" windowWidth "|50")
				;check that: science buff visible and e button not visible (buffs not obscured)
				if ((Gdip_ImageSearch(pBMArea, bitmaps["science"]) = 1) && (Gdip_ImageSearch(pBMArea, bitmaps["e_button"]) = 0)) {
					if (Gdip_ImageSearch(pBMArea, bitmaps["snowflake_identifier"], &pos, , 20, , , , , 7) = 1) {
						;detect current snowflake buff amount
						x := SubStr(pos, 1, InStr(pos, ",")-1)

						(digits := Map()).Default := ""
						Loop 10
						{
							n := 10-A_Index
							if ((n = 1) || (n = 3))
								continue
							Gdip_ImageSearch(pBMArea, bitmaps["buffdigit" n], &list, x-32, 15, x-8, 50, 1, , 5, 5, , "`n")
							Loop Parse list, "`n"
								if (A_Index & 1)
									digits[Integer(A_LoopField)] := n
						}
						for m,n in [1,3]
						{
							Gdip_ImageSearch(pBMArea, bitmaps["buffdigit" n], &list, x-32, 15, x-8, 50, 1, , 5, 5, , "`n")
							Loop Parse list, "`n"
							{
								if (A_Index & 1)
								{
									if (((n = 1) && (digits[A_LoopField - 5] = 4)) || ((n = 3) && (digits[A_LoopField - 1] = 8)))
										continue
									digits[Integer(A_LoopField)] := n
								}
							}
						}
						num := ""
						for m,n in digits
							num .= n
					}
					else
						num := 0

					Gdip_DisposeImage(pBMArea)
					HotkeyNum:=ActiveHotkeys[key][2]
					;use snowflake if detected snowflake buff is below user selected maximum (num = "" implies 100% or indeterminate)
					if ((num != "") && (num < HotbarMax%HotkeyNum%)) {
						send "{sc00" HotkeyNum+1 "}"
						LastHotkeyN:=nowUnix()
						IniWrite LastHotkeyN, "settings\nm_config.ini", "Boost", "LastHotkey" HotkeyNum
						ActiveHotkeys[key][4]:=LastHotkeyN
						break
					}
				}
				Gdip_DisposeImage(pBMArea)
			}
		}
	}
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PATH FUNCTIONS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
nm_createPath(path) => nm_createWalk(path, , nm_PathVars())
nm_PathVars(){
	return
	(
	'
	HiveSlot:=' HiveSlot '
	MoveMethod:="' MoveMethod '"
	HiveBees:=' HiveBees '
	KeyDelay:=' KeyDelay '

	CoordMode "Mouse", "Screen"
	CoordMode "Pixel", "Screen"

	nm_gotoRamp() {
		nm_Walk(5, FwdKey)
		nm_Walk(9.2*HiveSlot-4, RightKey)
	}

	nm_gotoCannon() {
		static pBMCannon := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAABsAAAAMAQMAAACpyVQ1AAAABlBMVEUAAAD3//lCqWtQAAAAAXRSTlMAQObYZgAAAEdJREFUeAEBPADD/wDAAGBgAMAAYGAA/gBgYAD+AGBgAMAAYGAAwABgYADAAGBgAMAAYGAAwABgYADAAGBgAMAAYGAAwABgYDdgEn1l8cC/AAAAAElFTkSuQmCC")

		hwnd := GetRobloxHWND()
		GetRobloxClientPos(hwnd)
		SendEvent "{Click " windowX+350 " " windowY+offsetY+100 " 0}"

		success := 0
		Loop 10
		{
			Send "{" SC_Space " down}{" RightKey " down}"
			Sleep 100
			Send "{" SC_Space " up}"
			nm_Walk(2, RightKey)
			nm_Walk(1.5, FwdKey, RightKey)
			Send "{" RightKey " down}"

			DllCall("GetSystemTimeAsFileTime","int64p",&s:=0)
			n := s, f := s+100000000
			while (n < f)
			{
				pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2-200 "|" windowY+offsetY "|400|125")
				if (Gdip_ImageSearch(pBMScreen, pBMCannon, , , , , , 2, , 2) = 1)
				{
					success := 1, Gdip_DisposeImage(pBMScreen)
					break
				}
				Gdip_DisposeImage(pBMScreen)
				DllCall("GetSystemTimeAsFileTime","int64p",&n)
			}
			Send "{" RightKey " up}"

			if (success = 1) ; check that cannon was not overrun, at the expense of a small delay
			{
				Loop 10
				{
					if (A_Index = 10)
					{
						success := 0
						break
					}
					Sleep 500
					pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2-200 "|" windowY+offsetY "|400|125")
					if (Gdip_ImageSearch(pBMScreen, pBMCannon, , , , , , 2, , 2) = 1)
					{
						Gdip_DisposeImage(pBMScreen)
						break 2
					}
					else
						nm_Walk(1.5, LeftKey)
					Gdip_DisposeImage(pBMScreen)
				}
			}

			if (success = 0)
			{
				nm_Reset()
				nm_gotoRamp()
			}
		}
		if (success = 0)
			ExitApp
	}

	nm_Reset()
	{
		static hivedown := 0
		static pBMR := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAACgAAAAGCAAAAACUM4P3AAAAAnRSTlMAAHaTzTgAAAAXdEVYdFNvZnR3YXJlAFBob3RvRGVtb24gOS4wzRzYMQAAAyZpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADw/eHBhY2tldCBiZWdpbj0n77u/JyBpZD0nVzVNME1wQ2VoaUh6cmVTek5UY3prYzlkJz8+Cjx4OnhtcG1ldGEgeG1sbnM6eD0nYWRvYmU6bnM6bWV0YS8nIHg6eG1wdGs9J0ltYWdlOjpFeGlmVG9vbCAxMi40NCc+CjxyZGY6UkRGIHhtbG5zOnJkZj0naHR0cDovL3d3dy53My5vcmcvMTk5OS8wMi8yMi1yZGYtc3ludGF4LW5zIyc+CgogPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9JycKICB4bWxuczpleGlmPSdodHRwOi8vbnMuYWRvYmUuY29tL2V4aWYvMS4wLyc+CiAgPGV4aWY6UGl4ZWxYRGltZW5zaW9uPjQwPC9leGlmOlBpeGVsWERpbWVuc2lvbj4KICA8ZXhpZjpQaXhlbFlEaW1lbnNpb24+NjwvZXhpZjpQaXhlbFlEaW1lbnNpb24+CiA8L3JkZjpEZXNjcmlwdGlvbj4KCiA8cmRmOkRlc2NyaXB0aW9uIHJkZjphYm91dD0nJwogIHhtbG5zOnRpZmY9J2h0dHA6Ly9ucy5hZG9iZS5jb20vdGlmZi8xLjAvJz4KICA8dGlmZjpJbWFnZUxlbmd0aD42PC90aWZmOkltYWdlTGVuZ3RoPgogIDx0aWZmOkltYWdlV2lkdGg+NDA8L3RpZmY6SW1hZ2VXaWR0aD4KICA8dGlmZjpPcmllbnRhdGlvbj4xPC90aWZmOk9yaWVudGF0aW9uPgogIDx0aWZmOlJlc29sdXRpb25Vbml0PjI8L3RpZmY6UmVzb2x1dGlvblVuaXQ+CiAgPHRpZmY6WFJlc29sdXRpb24+OTYvMTwvdGlmZjpYUmVzb2x1dGlvbj4KICA8dGlmZjpZUmVzb2x1dGlvbj45Ni8xPC90aWZmOllSZXNvbHV0aW9uPgogPC9yZGY6RGVzY3JpcHRpb24+CjwvcmRmOlJERj4KPC94OnhtcG1ldGE+Cjw/eHBhY2tldCBlbmQ9J3InPz77yGiWAAAAI0lEQVR42mNUYyAOMDJggOUMDAyRmAqXMxAHmBiobjWxngEAj7gC+wwAe1AAAAAASUVORK5CYII=")

		(bitmaps:=Map()).CaseSense := 0
		#include "%A_ScriptDir%\nm_image_assets\reset\bitmaps.ahk"

		success := 0
		hwnd := GetRobloxHWND()
		GetRobloxClientPos(hwnd)
		SendEvent "{Click " windowX+350 " " windowY+offsetY+100 " 0}"

		Loop 10
		{
			DetectHiddenWindows 1
			if WinExist("background.ahk ahk_class AutoHotkey") {
				PostMessage 0x5554, 1, DateDiff(A_NowUTC, "19700101000000", "Seconds")
			}
			DetectHiddenWindows 0
			ActivateRoblox()
			GetRobloxClientPos(hwnd)
			SetKeyDelay 250+KeyDelay
			SendEvent "{" SC_Esc "}{" SC_R "}{" SC_Enter "}"
			SetKeyDelay 100+KeyDelay

			n := 0
			while ((n < 2) && (A_Index <= 80))
			{
				Sleep 100
				pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY "|" windowWidth "|50")
				n += (Gdip_ImageSearch(pBMScreen, pBMR, , , , , , 10) = (n = 0))
				Gdip_DisposeImage(pBMScreen)
			}
			Sleep 1000

			if hivedown
				Send "{" RotDown "}"
			region := windowX "|" windowY+3*windowHeight//4 "|" windowWidth "|" windowHeight//4
			sconf := windowWidth**2//3200
			Loop 4 {
				sleep 250
				pBMScreen := Gdip_BitmapFromScreen(region), s := 0
				for i, k in bitmaps["hive"] {
					s := Max(s, Gdip_ImageSearch(pBMScreen, k, , , , , , 4, , , sconf))
					if (s >= sconf) {
						Gdip_DisposeImage(pBMScreen)
						success := 1
						Send "{" RotRight " 4}"
						if hivedown
							Send "{" RotUp "}"
						SendEvent "{" ZoomOut " 5}"
						break 3
					}
				}
				Gdip_DisposeImage(pBMScreen)
				Send "{" RotRight " 4}"
				if (A_Index = 2)
				{
					if hivedown := !hivedown
						Send "{" RotDown "}"
					else
						Send "{" RotUp "}"
				}
			}
		}
		for k,v in bitmaps["hive"]
			Gdip_DisposeImage(v)
		if (success = 0)
			ExitApp
	}
	'
	)
}
nm_gotoField(location){
	global HiveConfirmed:=0
	path := paths["gtf"][StrReplace(location, " ")]

	nm_setShiftLock(0)

	nm_createPath(path)
	KeyWait "F14", "D T5 L"
	KeyWait "F14", "T120 L"
	nm_endWalk()
}
nm_walkFrom(field){
	path := paths["wf"][StrReplace(field, " ")]

	nm_setShiftLock(0)

	nm_createPath(path)
	KeyWait "F14", "D T5 L"
	nm_setStatus("Traveling", "Hive")
	KeyWait "F14", "T120 L"
	nm_endWalk()
}
nm_gotoPlanter(location, waitEnd := 1){
	global HiveConfirmed:=0
	path := paths["gtp"][StrReplace(location, " ")]

	nm_setShiftLock(0)

	nm_createPath(path)
	KeyWait "F14", "D T5 L"
	if WaitEnd
	{
		KeyWait "F14", "T120 L"
		nm_endWalk()
	}
}
nm_gotoCollect(location, waitEnd := 1){
	global HiveConfirmed:=0
	path := paths["gtc"][StrReplace(location, " ")]

	nm_setShiftLock(0)

	nm_createPath(path)
	KeyWait "F14", "D T5 L"
	if waitEnd
	{
		KeyWait "F14", "T120 L"
		nm_endWalk()
	}
}
nm_gotoBooster(booster){
	global HiveConfirmed:=0
	path := paths["gtb"][booster]

	nm_setShiftLock(0)

	nm_createPath(path)
	KeyWait "F14", "D T5 L"
	KeyWait "F14", "T120 L"
	nm_endWalk()
}
nm_gotoQuestgiver(giver){
	path := paths["gtq"][giver]
	nm_setShiftLock(0)
	success:=0
	Loop 2
	{
		nm_Reset()

		global HiveConfirmed := 0

		nm_setStatus("Traveling", "Questgiver: " giver)

		nm_createPath(path)
		KeyWait "F14", "D T5 L"
		KeyWait "F14", "T120 L"
		nm_endWalk()

		Loop 2
		{
			Sleep 500
			searchRet := nm_imgSearch("e_button.png",30,"high")
			If (searchRet[1] = 0) {
				success:=1
				SendInput "{" SC_E " down}"
				Sleep 100
				SendInput "{" SC_E " up}"
				Sleep 2000
				hwnd := GetRobloxHWND()
				offsetY := GetYOffset(hwnd)
				Loop 500
				{
					GetRobloxClientPos(hwnd)
					pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2-50 "|" windowY+2*windowHeight//3 "|100|" windowHeight//3)
					if (Gdip_ImageSearch(pBMScreen, bitmaps["dialog"], &pos, , , , , 10, , 3) != 1) {
						Gdip_DisposeImage(pBMScreen)
						break
					}
					Gdip_DisposeImage(pBMScreen)
					MouseMove windowX+windowWidth//2, windowY+2*windowHeight//3+SubStr(pos, InStr(pos, ",")+1)-15
					Click
					Sleep 150
				}
				MouseMove windowX+350, windowY+offsetY+100
			}
		}

		global QuestGatherField:="None"
		if(success)
			return
	}
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; TIMER FUNCTIONS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
getout(*){
	global
	nm_saveGUIPos()
	nm_endWalk()
	DetectHiddenWindows 1
	try IniWrite !!WinExist("PlanterTimers.ahk ahk_class AutoHotkey"), "settings\nm_config.ini", "Planters", "TimersOpen"
	CloseScripts()
	try Gdip_Shutdown(pToken)
	DllCall(A_WorkingDir "\nm_image_assets\Styles\USkin.dll\USkinExit")
}

Background(){
	;auto field boost
	if (AFBrollingDice && state!="Disconnected")
		nm_fieldBoostDice()
	;use/check hotbar boosts
	if PFieldBoosted {
		nm_hotbar(1)
	} else {
		nm_hotbar()
	}
	;bug death check
	if(state="Gathering" || state="Searching" || (nm_NightInterrupt() && state="Attacking"))
		nm_bugDeathCheck()
	;stats
	nm_setStats()
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; HOTKEYS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;START MACRO
/**
 * Force start: errors/info are suppressed.
 * RC start: errors/info are sent to status instead of msgboxes.
 */
start(*){
	global
	UnlockStartButton() => (MainGui["StartButton"].Enabled := 1, Hotkey(StartHotkey, "On"), nm_LockTabs(0), nm_setStatus("Error", "Incorrect Roblox Configuration"))

	SetKeyDelay 100+KeyDelay
	nm_LockTabs()
	MainGui["StartButton"].Enabled := 0
	Hotkey StartHotkey, "Off"
	nm_setStatus("Begin", "Macro")

	;//todo: make startup errors an array

	if !ForceStart {
		robloxtype := nm_DetectRobloxType()
		if RemoteStart && (robloxtype = RobloxTypes.UWP || robloxtype = RobloxTypes.NotFound) {
			nm_setStatus("Error","Unable to start macro. Invalid Roblox installation detected. Please install Roblox from https://www.roblox.com/download")
			return UnlockStartButton()
		} else {
			if robloxtype = RobloxTypes.UWP {
				MsgBox "UWP Roblox installation is detected, Natro Macro currently does not support it.`nPlease install Roblox from https://www.roblox.com/download", "UWP Roblox Detected", 0x40010 " T60"
				return UnlockStartButton()
			}
			if robloxtype = RobloxTypes.NotFound {
				MsgBox "Unable to detect a Roblox installation.`nPlease install Roblox from https://www.roblox.com/download", "Roblox Not Found", 0x40010 " T60"
				return UnlockStartButton()
			}
		}

		if !RemoteStart && !ForceStart {
			if nm_MsgBoxIncorrectRobloxSettings()
				(MainGui["StartButton"].Enabled := 1, Hotkey(StartHotkey, "On"), nm_LockTabs(0))
		}

		;Touchscreen WARNING @ start
		if ((DllCall("GetSystemMetrics", "int", 94)) & 0x40 && DllCall("GetSystemMetrics", "int", 95) >= 2) {
			if RemoteStart {
				nm_setStatus("Error", "Touchscreen enabled, please disable it for the macro to function correctly.")
			} else {
				MsgBox "
				(
				It seems like you have Touchscreen enabled. This means the macro will NOT reset your character properly!

				To fix this:
				Press Win+S and type in 'Device Manager' -> Right-click 'HID-compliant touch screen' -> Under 'Human Interface Devices', select 'Disable Device' -> Restart your PC.
				)", "WARNING!!", 0x1030 " T60"
			}
		}


		;Auto Field Boost WARNING @ start
		;nm_SetStatus("Debug", "AFB" AutoFieldBoostActive " RC" RemoteStart " Force" ForceStart)
		if AutoFieldBoostActive {
			local futureDice  := (AFBDiceEnable ? (AFBDiceLimitEnable ? (AFBDiceLimit-AFBdiceUsed) : 'All') : 'None')
			local futureGlitter  := (AFBGlitterEnable ? (AFBGlitterLimitEnable ? (AFBGlitterLimit-AFBglitterUsed) : 'All') : 'None')
			if !RemoteStart {
				MsgBox
				(
				"Automatic Field Boost is ACTIVATED.
				------------------------------------------------------------------------------------
				If you continue the following quantity of items can be used:
				Dice: " futureDice "
				Glitter: " futureGlitter "

				HIGHLY RECOMMENDED:
				Disable any non-essential tasks such as quests, bug runs, stingers, etc. Any time away from your gathering field can result in the loss of your field boost."
				), "WARNING!!", 257 " T30"
			} else {
				nm_setstatus("Warning","Automatic Field Boost is ACTIVATED.`nIf you continue the following quantity of items can be used`nDice: " futureGlitter "`nGlitter: " futureGlitter)
			}
		}
		;Field drift compensation warning
		;if gathering in a field with FDC on and without supreme set in settings, warn user
		if (FDCWarn = 1 && SprinklerType != "Supreme") {
			local Driftablefields := []
			Loop 3 {
				if (FieldName%A_Index% != "None" && FieldName%A_Index% && FieldDriftCheck%A_Index%)
					Driftablefields.Push(A_Index)
			}
			if (Driftablefields.Length > 0){
				; humanize text
				local formattedfields := "field" (Driftablefields.Length > 1 ? "s" : "") " "
				local index, field
				for index, field in Driftablefields {
					formattedfields .= field " (" FieldName%field% ")" ((index < Driftablefields.Length) ? (index = Driftablefields.Length-1 ? ", and " : ", ") : "")
				}

				if !RemoteStart {
					MsgBox
					(
					"You have Field Drift Compensation enabled for gathering " formattedfields ". However, you do not have supreme saturator as your sprinkler type set in settings.
					Please note that Field Drift Compensation requires you to own the Supreme saturator, as it searches for the blue pixel."
					), "Field Drift Compensation", 0x1040 " T30"
					if (MsgBox("Would you like to disable this warning for the future?", "Field Drift Compensation", 0x1124 " T30") = "Yes")
						IniWrite (FDCWarn := 0), "settings\nm_config.ini", "Settings", "FDCWarn"
				} else
					nm_setStatus("Warning","`nField Drift Compensation is enabled for gathering " formattedfields " without supreme saturator. This means that you may run out of the fields easily in these fields.")
			}
		}
		;Sticker Warning
		if ((StickerStackCheck = 1) && InStr(StickerStackItem, "Sticker")) { ;Warns user about stickers
			if !RemoteStart
				Msgbox(
				(
					"You have enabled the Sticker option for Sticker Stack!
					Consider trading all of your valuable stickers to alternative account, to ensure that you do not lose any valuable stickers."
					(((StickerStackHive + StickerStackCub + StickerStackVoucher > 0) ?
						(
						"`n`nEXTRA WARNING!!
						You have enabled the donation of:" ((StickerStackHive = 1) ? "`n- Hive Skins" : "") ((StickerStackCub = 1) ? "`n- Cub Skins" : "") ((StickerStackVoucher = 1) ? "`n- Vouchers" : "") "
						Make sure this is correct because the macro WILL use them!"
						))
					: "")
				), "Sticker Stack", 0x1040 " T30")
			else
				nm_setStatus("Warning",
					(StickerStackHive + StickerStackCub > 0) ? ("`nSticker Stack is enabled. Unwanted stickers may be donated.`nYou have also enabled **VALUABLE STICKERS:**"
					(StickerStackHive ? "`n- **__Hive Skins__**" : "")
					(StickerStackCub ? "`n- **__Cub Skins__**" : "")
					(StickerStackVoucher ? "`n- **__Vouchers__**" : ""))
				: "")
		}
		;Guid star Warning
		if AnnounceGuidingStar
			if !RemoteStart
				nm_AnnounceGuidWarn(MainGui["AnnounceGuidingStar"])
			else
				nm_setStatus("Warning","`nAnnounce Guiding Star is enabled. Make sure you are in a private server.")
	}
	ActivateRoblox()
	disconnectCheck()
	nm_setShiftLock(0)
	offsetY := GetYOffset((hRoblox := GetRobloxHWND()), &offsetfail)

	;addition warnings after roblox window is confirmed
	if !ForceStart {
		;check UIPI
		try PostMessage 0x100, 0x7, 0, , "ahk_id " hRoblox
		catch {
			if !RemoteStart
				MsgBox "
				(
				Your Roblox window is run as admin, but the macro is not!
				This means the macro will be unable to send any inputs to Roblox.
				You must either reinstall Roblox without administrative rights, or run Natro Macro as admin!

				NOTE: It is recommended to stop the macro now, as this issue also causes hotkeys to not work while Roblox is active."
				)", "WARNING!!", 0x1030 " T60"
			else
				nm_setStatus("Error","`nRoblox is run as admin, but the macro is not. The macro cannot work in this state.")
		}
		try PostMessage 0x101, 0x7, 0xC0000000, , "ahk_id " hRoblox
		if (offsetfail = 1)
			if !RemoteStart
				MsgBox "
				(
				Unable to detect in-game GUI offset!
				This means the macro will NOT work correctly!

				There are a few reasons why this can happen, including:
				- Incorrect graphics settings
				- Your 'Experience Language' is not set to English
				- Something is covering the top of your Roblox window

				Join our Discord server for support and our Knowledge Base post on this topic (Unable to detect in-game GUI offset)!
				)", "WARNING!!", 0x1030 " T60"
			else
				nm_setStatus("Error","`nUnable to detect in-game GUI offset! Please check that all of your settings are correct.")
	}
	nm_OpenMenu()
	MouseMove windowX+350, windowY+offsetY+100
	DetectHiddenWindows 1
	MacroState:=2
	if WinExist("Status.ahk ahk_class AutoHotkey")
		try PostMessage 0x5552, 23, MacroState
	if WinExist("Heartbeat.ahk ahk_class AutoHotkey")
		try PostMessage 0x5552, 23, MacroState
	if WinExist("background.ahk ahk_class AutoHotkey")
		try PostMessage 0x5552, 23, MacroState
	DetectHiddenWindows 0
	;set stats
	MacroStartTime:=nowUnix()
	global PausedRuntime:=0
	nm_ResetSessionStats()
	global CurrentField
	global RecentFBoost:="None"
	global QuestGatherField:="None"
	global BugDeathCheckLockout:=0
	global AFBrollingDice:=0
	global AFBuseGlitter:=0
	global AFBuseBooster:=0
	global QuestLadybugs:=0
	global QuestRhinoBeetles:=0
	global QuestSpider:=0
	global QuestMantis:=0
	global QuestScorpions:=0
	global QuestWerewolf:=0
	global BuckoRhinoBeetles:=0
	global BuckoMantis:=0
	global RileyLadybugs:=0
	global RileyScorpions:=0
	global RileyAll:=0
	global GatherFieldBoosted:=0
	global GatherFieldBoostedStart:=nowUnix()-3600
	global ConvertGatherFlag:=0
	CurrentField := MainGui["CurrentField"].Text
	;set ActiveHotkeys[]
	global ActiveHotkeys:=[]
	;set hotbar values for actions handled by nm_hotbar()
	whileNames:=["Always", "Attacking", "Gathering", "At Hive", "GatherStart"]
	for key, val in whileNames {
		loop 6 {
			slot:=A_Index+1
			if(HotbarWhile%slot%=val) {
				;calculate seconds
				HBSecs:=HotbarTime%slot%
				;set array values
				last:=LastHotkey%slot%
				ActiveHotkeys.push([val, slot, HBSecs, last])
			}
		}
	}
	;special hotbar cases
	;MicroConverterKey
	global MicroConverterKey
	MicroConverterKey:="None"
	loop 6 {
		slot:=A_Index+1
		if(HotbarWhile%slot%="Microconverter") {
			MicroConverterKey:="sc00" slot+1
			break
		}
	}
	;WhirligigKey
	global WhirligigKey
	WhirligigKey:="None"
	loop 6 {
		slot:=A_Index+1
		if(HotbarWhile%slot%="Whirligig") {
			WhirligigKey:="sc00" slot+1
			break
		}
	}
	;EnzymesKey
	global EnzymesKey
	EnzymesKey:="None"
	loop 6 {
		slot:=A_Index+1
		if(HotbarWhile%slot%="Enzymes") {
			EnzymesKey:="sc00" slot+1
			break
		}
	}
	;GlitterKey
	global GlitterKey
	GlitterKey:="None"
	loop 6 {
		slot:=A_Index+1
		if(HotbarWhile%slot%="Glitter") {
			GlitterKey:="sc00" slot+1
			break
		}
	}
	;Snowflake
	loop 6 {
		slot:=A_Index+1
		if(HotbarWhile%slot%="Snowflake") {
			ActiveHotkeys.push(["Snowflake", slot, HotbarTime%slot%, LastHotkey%slot%])
			break
		}
	}
	;start ancillary macros
	try run
	(
	'"' exe_path32 '" /script "' A_WorkingDir '\submacros\background.ahk" "' 0 '" "' 0 '" "' StingerCheck '" "' 0 '" '
	'"' AnnounceGuidingStar '" "' ReconnectInterval '" "' ReconnectHour '" "' ReconnectMin '" "' EmergencyBalloonPingCheck '" "' ConvertBalloon '" "' NightMemoryMatchCheck '" "' 0 '"'
	)
	;(re)start stat monitor
	global SessionTotalHoney, HoneyAverage
	if (discordCheck && (((discordMode = 0) && RegExMatch(webhook, "i)^https:\/\/(canary\.|ptb\.)?(discord|discordapp)\.com\/api\/webhooks\/([\d]+)\/([a-z0-9_-]+)$"))
		|| ((discordMode = 1) && (ReportChannelCheck = 1) && (ReportChannelID || MainChannelID))))
		run '"' exe_path64 '" /script "' A_WorkingDir '\submacros\StatMonitor.ahk" "' VersionID '"'
	;start main loop
	nm_setStatus("Begin", "Main Loop")
	nm_Start()
}
;STOP MACRO
stop(*){
	global
	try {
		Hotkey StopHotkey, "Off"
		Hotkey PauseHotkey, "Off"
		Hotkey StartHotkey, "Off"
	}
	nm_endWalk()
	sendinput "{" FwdKey " up}{" BackKey " up}{" LeftKey " up}{" RightKey " up}{" SC_Space " up}"
	Click "Up"
	if(MacroState) {
		TotalRuntime:=TotalRuntime+(nowUnix()-MacroStartTime)
		SessionRuntime:=SessionRuntime+(nowUnix()-MacroStartTime)
		if(!GatherStartTime)
			GatherStartTime:=nowUnix()
		TotalGatherTime:=TotalGatherTime+(nowUnix()-GatherStartTime)
		SessionGatherTime:=SessionGatherTime+(nowUnix()-GatherStartTime)
		if(!ConvertStartTime)
			ConvertStartTime:=nowUnix()
		TotalConvertTime:=TotalConvertTime+(nowUnix()-ConvertStartTime)
		SessionConvertTime:=SessionConvertTime+(nowUnix()-ConvertStartTime)
	}
	IniWrite TotalRuntime, "settings\nm_config.ini", "Status", "TotalRuntime"
	IniWrite SessionRuntime, "settings\nm_config.ini", "Status", "SessionRuntime"
	IniWrite TotalGatherTime, "settings\nm_config.ini", "Status", "TotalGatherTime"
	IniWrite SessionGatherTime, "settings\nm_config.ini", "Status", "SessionGatherTime"
	IniWrite TotalConvertTime, "settings\nm_config.ini", "Status", "TotalConvertTime"
	IniWrite SessionConvertTime, "settings\nm_config.ini", "Status", "SessionConvertTime"
	nm_setStatus("End", "Macro")
	DetectHiddenWindows 1
	MacroState:=0
	Reload
	Sleep 10000
}
;PAUSE MACRO
nm_Pause(*){
	global
	if(state="startup")
		return
	if(A_IsPaused) {
		nm_LockTabs()
		ActivateRoblox()
		DetectHiddenWindows 1
		if WinExist("ahk_class AutoHotkey ahk_pid " currentWalk.pid)
			Send "{F16}"
		else
		{
			if(FwdKeyState)
				sendinput "{" FwdKey " down}"
			if(BackKeyState)
				sendinput "{" BackKey " down}"
			if(LeftKeyState)
				sendinput "{" LeftKey " down}"
			if(RightKeyState)
				sendinput "{" RightKey " down}"
			if(SpaceKeyState)
				sendinput "{" SC_Space " down}"
		}
		MacroState:=2
		if WinExist("Status.ahk ahk_class AutoHotkey")
			try PostMessage 0x5552, 23, MacroState
		if WinExist("Heartbeat.ahk ahk_class AutoHotkey")
			try PostMessage 0x5552, 23, MacroState
		if WinExist("background.ahk ahk_class AutoHotkey")
			try PostMessage 0x5552, 23, MacroState
		youDied:=0
		;manage runtimes
		MacroStartTime:=nowUnix()
		GatherStartTime:=nowUnix()
		DetectHiddenWindows 0
		nm_setStatus(PauseState, PauseObjective)
	} else {
		if (ShowOnPause = 1)
			WinActivate "ahk_id " MainGui.Hwnd
		DetectHiddenWindows 1
		if WinExist("ahk_class AutoHotkey ahk_pid " currentWalk.pid)
			Send "{F16}"
		else
		{
			FwdKeyState:=GetKeyState(FwdKey), BackKeyState:=GetKeyState(BackKey), LeftKeyState:=GetKeyState(LeftKey), RightKeyState:=GetKeyState(RightKey), SpaceKeyState:=GetKeyState(SC_Space)
			sendinput "{" FwdKey " up}{" BackKey " up}{" LeftKey " up}{" RightKey " up}{" SC_Space " up}"
			Click "Up"
		}
		MacroState:=1
		if WinExist("Status.ahk ahk_class AutoHotkey")
			try PostMessage 0x5552, 23, MacroState
		if WinExist("Heartbeat.ahk ahk_class AutoHotkey")
			try PostMessage 0x5552, 23, MacroState
		if WinExist("background.ahk ahk_class AutoHotkey")
			try PostMessage 0x5552, 23, MacroState
		PauseState:=state
		PauseObjective:=objective
		;manage runtimes
		TotalRuntime:=TotalRuntime+(nowUnix()-MacroStartTime)
		PausedRuntime:=PausedRuntime+(nowUnix()-MacroStartTime)
		SessionRuntime:=SessionRuntime+(nowUnix()-MacroStartTime)
		if(GatherStartTime) {
			TotalGatherTime:=TotalGatherTime+(nowUnix()-GatherStartTime)
			SessionGatherTime:=SessionGatherTime+(nowUnix()-GatherStartTime)
		}
		IniWrite TotalRuntime, "settings\nm_config.ini", "Status", "TotalRuntime"
		DetectHiddenWindows 0
		nm_setStatus("Paused", "Press " PauseHotkey " to Continue")
		nm_LockTabs(0)
	}
	Pause -1
}
;AUTOCLICKER
autoclicker(*){
	global ClickDuration, ClickDelay
	static toggle:=0
	toggle := !toggle

	for var, default in Map("ClickDuration", 50, "ClickDelay", 10)
		if !IsNumber(%var%)
			%var% := default

	while ((ClickMode || (A_Index <= ClickCount)) && toggle) {
		sendinput "{click down}"
		sleep ClickDuration
		sendinput "{click up}"
		sleep ClickDelay
	}
	toggle := 0
}
;TIMERS
timers(*) => ba_showPlanterTimers()

nm_WM_COPYDATA(wParam, lParam, *){
	Critical
	global LastGuid, PMondoGuid, MondoAction, MondoBuffCheck, currentWalk, FwdKey, BackKey, LeftKey, RightKey, SC_Space
	StringAddress := NumGet(lParam + 2*A_PtrSize, "Ptr")  ; Retrieves the CopyDataStruct's lpData member.
	StringText := StrGet(StringAddress)  ; Copy the string out of the structure.
	if(wParam=1){ ;guiding star detected
		nm_setStatus("Detected", "Guiding Star in " . StringText)
		;pause
		DetectHiddenWindows 1
		if WinExist("ahk_class AutoHotkey ahk_pid " currentWalk.pid)
			Send "{F16}"
		else
		{
			FwdKeyState:=GetKeyState(FwdKey)
			BackKeyState:=GetKeyState(BackKey)
			LeftKeyState:=GetKeyState(LeftKey)
			RightKeyState:=GetKeyState(RightKey)
			SpaceKeyState:=GetKeyState(SC_Space)
			PauseState:=state
			PauseObjective:=objective
			sendinput "{" FwdKey " up}{" BackKey " up}{" LeftKey " up}{" RightKey " up}{" SC_Space " up}"
			click "up"
		}
		;Announce Guiding Star
		;calculate mins
		GSMins:=SubStr("0" Mod(A_Min+10, 60), -2)
		Sleep 200
		Send "{Text}/<<Guiding Star>> in " StringText " until __:" GSMins "`n"
		sleep 250
		;set LastGuid
		LastGuid:=nowUnix()
		IniWrite LastGuid, "settings\nm_config.ini", "Boost", "LastGuid"
		if(PMondoGuid && MondoBuffCheck && MondoAction="Guid") {
			nm_mondo()
			DetectHiddenWindows 0
			return 0
		} else {
			if WinExist("ahk_class AutoHotkey ahk_pid " currentWalk.pid)
				Send "{F16}"
			else
			{
				if(FwdKeyState)
					sendinput "{" FwdKey " down}"
				if(BackKeyState)
					sendinput "{" BackKey " down}"
				if(LeftKeyState)
					sendinput "{" LeftKey " down}"
				if(RightKeyState)
					sendinput "{" RightKey " down}"
				if(SpaceKeyState)
					sendinput "{" SC_Space " down}"
			}
		}
		DetectHiddenWindows 0
	}
	else {
		InStr(StringText, ": ") ? nm_setStatus(SubStr(StringText, 1, InStr(StringText, ": ")-1), SubStr(StringText, InStr(StringText, ": ")+2)) : nm_setStatus(StringText)
	}
	return 0
}
nm_ForceLabel(wParam, *){
	Critical
	switch wParam
	{
		case 1:
		if (MainGui["StartButton"].Enabled = 1){
			global RemoteStart := 1
			SetTimer start, -500
		}

		case 2:
		nm_pause()

		case 3:
		stop()
	}
	return 0
}
nm_ForceReconnect(wParam, *){
	Critical
	global ReconnectDelay := wParam
	nm_endWalk()
	CloseRoblox()
	return 0
}
nm_sendHeartbeat(*){
	Critical
	PostSubmacroMessage("Heartbeat", 0x5556, 1)
	return 0
}
nm_backgroundEvent(wParam, lParam, *){
	Critical
	global youDied, BackpackPercent, BackpackPercentFiltered, FieldGuidDetected, HasPopStar, PopStarActive, CheckNight
	static arr:=["youDied", 0, 0, "BackpackPercent", "BackpackPercentFiltered", "FieldGuidDetected", "HasPopStar", "PopStarActive"]
	var := arr[wParam], %var% := lParam
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
	nm_UpdateGUIVar(var)
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
	nm_UpdateGUIVar(var)
	return 0
}
nm_UpdateGUIVar(var)
{
	global
	local k, z, num

	try
		MainGui[var]
	catch
		k := ""
	else
		k := var

	switch k, 0
	{
		case "FieldPatternSize1", "FieldPatternSize2", "FieldPatternSize3":
		MainGui[k].Text := %k%
		MainGui[k "UpDown"].Value := FieldPatternSizeArr[%k%]

		case "FieldUntilPack1", "FieldUntilPack2", "FieldUntilPack3", "FieldBoosterMins":
		MainGui[k].Text := %k%
		MainGui[k "UpDown"].Value := %k%//5

		case "FieldName1":
		MainGui[k].Text := %k%
		nm_FieldSelect1(1)

		case "FieldName2":
		MainGui[k].Text := %k%
		nm_FieldSelect2(1)

		case "FieldName3":
		MainGui[k].Text := %k%
		nm_FieldSelect3(1)

		case "FieldPattern1", "FieldPattern2", "FieldPattern3":
		MainGui[k].Text := %k%

		case "FieldBooster1", "FieldBooster2", "FieldBooster3":
		MainGui[k].Text := %k%
		nm_FieldBooster()

		case "HotbarWhile2", "HotbarWhile3", "HotbarWhile4", "HotbarWhile5", "HotbarWhile6", "HotbarWhile7":
		MainGui[k].Text := %k%
		nm_HotbarWhile()

		case "KingBeetleAmuletMode", "ShellAmuletMode":
		MainGui[k].Value := %k%
		nm_saveAmulet(MainGui[k])

		case "HotbarTime2", "HotbarTime3", "HotbarTime4", "HotbarTime5", "HotbarTime6", "HotbarTime7":
		MainGui[k].Value := %k%
		nm_HotbarWhile()

		Case "SnailTime":
		MainGui["SnailTimeUpDown"].Value := (SnailTime = "Kill") ? 4 : SnailTime//5
		nm_SnailTime()

		Case "ChickTime":
		MainGui["ChickTimeUpDown"].Value := (ChickTime = "Kill") ? 4 : ChickTime//5
		nm_ChickTime()

		case "InputSnailHealth":
		MainGui["SnailHealthEdit"].Value := Round(30000000*InputSnailHealth/100)
		MainGui["SnailHealthText"].SetFont("c" Format("0x{1:02x}{2:02x}{3:02x}", Round(Min(3*(100-InputSnailHealth), 150)), Round(Min(3*InputSnailHealth, 150)), 0)), MainGui["SnailHealthText"].Redraw()
		MainGui["SnailHealthText"].Text := InputSnailHealth "%"

		case "InputChickHealth":
		MainGui["ChickHealthText"].SetFont("c" Format("0x{1:02x}{2:02x}{3:02x}", Round(Min(3*(100-InputChickHealth), 150)), Round(Min(3*InputChickHealth, 150)), 0)), MainGui["ChickHealthText"].Redraw()
		MainGui["ChickHealthText"].Text := InputChickHealth "%"

		case "MondoAction":
		MainGui[k].Text := %k%
		nm_MondoAction()

		case "":
		k := var
		switch k, 0
		{
			case "BlenderItem1", "BlenderItem2", "BlenderItem3":
			MainGui[k "Picture"].Value := hBitmapsSB[%k%] ? ("HBITMAP:*" hBitmapsSB[%k%]) : ""
			z := SubStr(k, -1)
			MainGui["BlenderAdd" z].Text := (BlenderItem%z% = "None") ? "Add" : "Clear"

			case "BlenderIndex1", "BlenderIndex2", "BlenderIndex3":
			Num := SubStr(k, -1)
			local BlenderData1, BlenderData2, BlenderData3
			BlenderData%Num% := MainGui["BlenderData" Num].Text
			MainGui["BlenderData" Num].Text := StrReplace(BlenderData%Num%, SubStr(BlenderData%Num%, InStr(BlenderData%Num%, " ") + 1), "[" ((%k% = "Infinite") ? "∞" : %k%) "]")

			case "BlenderAmount1", "BlenderAmount2", "BlenderAmount3":
			Num := SubStr(k, -1)
			local BlenderData1, BlenderData2, BlenderData3
			BlenderData%Num% := MainGui["BlenderData" Num].Text
			MainGui["BlenderData" Num].Text := StrReplace(BlenderData%Num%, SubStr(BlenderData%Num%, 1, InStr(BlenderData%Num%, " ") - 1), "(" %k% ")")

			case "ShrineItem1", "ShrineItem2":
			MainGui[k "Picture"].Value := hBitmapsSB[%k%] ? ("HBITMAP:*" hBitmapsSB[%k%]) : ""
			z := SubStr(k, -1)
			MainGui["ShrineAdd" z].Text := (ShrineItem%z% = "None") ? "Add" : "Clear"

			case "ShrineIndex1", "ShrineIndex2":
			Num := SubStr(k, -1)
			local ShrineData1, ShrineData2, ShrineData3
			ShrineData%Num% := MainGui["ShrineData" Num].Text
			MainGui["ShrineData" Num].Text := StrReplace(ShrineData%Num%, SubStr(ShrineData%Num%, InStr(ShrineData%Num%, " ") + 1), "[" ((%k% = "Infinite") ? "∞" : %k%) "]")

			case "ShrineAmount1", "ShrineAmount2":
			Num := SubStr(k, -1)
			local ShrineData1, ShrineData2, ShrineData3
			ShrineData%Num% := MainGui["ShrineData" Num].Text
			MainGui["ShrineData" Num].Text := StrReplace(ShrineData%Num%, SubStr(ShrineData%Num%, 1, InStr(ShrineData%Num%, " ") - 1), "(" %k% ")")

			case "StickerStackMode":
			nm_StickerStackMode()
		}

		default:
		switch MainGui[k].Type, 0
		{
			case "DDL", "Text":
			MainGui[k].Text := %k%
			default: ; "CheckBox", "Edit", "UpDown", "Slider"
			MainGui[k].Value := %k%
		}
	}
}

