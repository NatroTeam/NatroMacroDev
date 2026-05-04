#Requires AutoHotkey v2.0

global settingsConfigLoc := "features\All\Quests\nm_settings_config.ini"

;this is this features GUI lines-of-code used to calculate loading progress
SettingsFeatureProgressVolume := 108
;this is the running total of all macro features included in the load progress metric
LoadingProgressVolume := LoadingProgressVolume+SettingsFeatureProgressVolume

nm_SettingsTab(*) {
	global
	TabCtrl.UseTab("Settings")
	MainGui.SetFont("w700")
	MainGui.Add("GroupBox", "x5 y25 w160 h65", "Gui")
	MainGui.Add("GroupBox", "x5 y95 w160 h65", "Hive")
	MainGui.Add("GroupBox", "x5 y165 w160 h70", "Reset")
	MainGui.Add("GroupBox", "x170 y25 w160 h35", "Input")
	MainGui.Add("GroupBox", "x170 y65 w160 h170", "Reconnect")
	MainGui.Add("GroupBox", "x335 y25 w160 h165", "Character")
	MainGui.Add("GroupBox", "x335 y190 w160 h45", "Updates")
	MainGui.SetFont("s8 cDefault Norm", "Tahoma")

	;gui settings
	MainGui.Add("CheckBox", "x10 y73 Disabled vAlwaysOnTop Checked" AlwaysOnTop, "Always On Top").OnEvent("Click", nm_AlwaysOnTop)
	MainGui.Add("Text", "x10 y40 w70 +BackgroundTrans", "GUI Theme:")
	StylesList := []
	Loop Files A_WorkingDir "\nm_image_assets\Styles\*.msstyles"
		StylesList.Push(StrReplace(A_LoopFileName, ".msstyles"))
	(GuiCtrl := MainGui.Add("DropDownList", "x75 y34 w72 h100 vGuiTheme Disabled", StylesList)).Text := GuiTheme, GuiCtrl.OnEvent("Change", nm_guiThemeSelect)
	MainGui.Add("Text", "x10 y57 w100 +BackgroundTrans", "GUI Transparency:")
	MainGui.Add("Text", "x104 y57 w20 +Center +BackgroundTrans vGuiTransparency", GuiTransparency)
	MainGui.Add("UpDown", "xp+22 yp-1 h16 -16 Range0-14 vGuiTransparencyUpDown Disabled", GuiTransparency//5).OnEvent("Change", nm_guiTransparencySet)
	SetLoadingProgress(29)

	;hive settings
	MainGui.Add("Text", "x10 y110 w60 +BackgroundTrans", "Hive Slot:")
	MainGui.SetFont("s6")
	MainGui.Add("Text", "x61 y112 w60 +BackgroundTrans", "(6-5-4-3-2-1)")
	MainGui.SetFont("s8 cDefault Norm", "Tahoma")
	MainGui.Add("Text", "x110 y109 w34 h16 0x201 +Center")
	(GuiCtrl := MainGui.Add("UpDown", "Range1-6 vHiveSlot Disabled", HiveSlot)).Section := "Settings", GuiCtrl.OnEvent("Change", nm_saveConfig)
	MainGui.Add("Text", "x10 y125 w110 +BackgroundTrans", "My Hive Has:")
	MainGui.Add("Edit", "x75 y124 w18 h16 Limit2 number vHiveBees Disabled", ValidateInt(&HiveBees, 50)).OnEvent("Change", nm_HiveBees)
	MainGui.Add("Text", "x98 y125 w110 +BackgroundTrans", "Bees")
	MainGui.Add("Button", "x150 y124 w10 h15 vHiveBeesHelp Disabled", "?").OnEvent("Click", nm_HiveBeesHelp)
	MainGui.Add("Text", "x9 y142 w110 +BackgroundTrans", "Claim Method: ")
	MainGui.Add("Text", "x92 yp w48 vClaimMethod +Center +BackgroundTrans", ClaimMethod)
	MainGui.Add("Button", "x80 yp w12 h15 vCMLeft Disabled", "<").OnEvent("Click", nm_ClaimMethod)
	MainGui.Add("Button", "x139 yp w12 h15 vCMRight Disabled", ">").OnEvent("Click", nm_ClaimMethod)
	MainGui.Add("Button", "x150 yp w10 h15 vClaimMethodHelp Disabled", "?").OnEvent("Click", nm_ClaimMethodHelp)

	;reset settings
	MainGui.Add("Button", "x20 y183 w130 h22 vResetFieldDefaultsButton Disabled", "Reset Field Defaults").OnEvent("Click", nm_ResetFieldDefaultGUI)
	MainGui.Add("Button", "x20 y207 w130 h22 vResetAllButton Disabled", "Reset All Settings").OnEvent("Click", nm_ResetConfig)

	;input settings
	MainGui.Add("Text", "x178 y41 w100 +BackgroundTrans", "Add Key Delay (ms):")
	MainGui.Add("Text", "x278 y39 w47 h18 0x201")
	MainGui.Add("UpDown", "Range0-9999 vKeyDelay Disabled", KeyDelay).OnEvent("Change", nm_saveKeyDelay)

	;reconnect settings
	MainGui.Add("Button", "x248 y64 w40 h16 vTestReconnectButton Disabled", "Test").OnEvent("Click", nm_testReconnect)
	MainGui.Add("Text", "x178 y82 +BackgroundTrans", "Private Server Link:")
	MainGui.Add("Edit", "x176 yp+13 w148 h16 vPrivServer Disabled", PrivServer).OnEvent("Change", nm_ServerLink)
	MainGui.Add("Text", "x178 yp+21 +BackgroundTrans", "Join Method:")
	MainGui.Add("Text", "x254 yp w48 vReconnectMethod +Center +BackgroundTrans", ReconnectMethod)
	MainGui.Add("Button", "xp-12 yp-1 w12 h15 vRMLeft Disabled", "<").OnEvent("Click", nm_ReconnectMethod)
	MainGui.Add("Button", "xp+59 yp w12 h15 vRMRight Disabled", ">").OnEvent("Click", nm_ReconnectMethod)
	MainGui.Add("Button", "x315 yp w10 h15 vReconnectMethodHelp Disabled", "?").OnEvent("Click", nm_ReconnectMethodHelp)
	MainGui.Add("Text", "x178 yp+18 +BackgroundTrans", "Daily Reconnect (optional):")
	MainGui.Add("Text", "x178 yp+17 +BackgroundTrans", "Reconnect every")
	MainGui.Add("Edit", "x264 yp-2 w18 h15 Number Limit2 vReconnectInterval Disabled", ValidateInt(&ReconnectInterval, "")).OnEvent("Change", nm_setReconnectInterval)
	MainGui.Add("Text", "x287 yp+1 +BackgroundTrans", "hours")
	MainGui.Add("Text", "x196 yp+18 +BackgroundTrans", "starting at")
	MainGui.Add("Edit", "x250 yp w18 h15 Number Limit2 vReconnectHour Disabled", IsInteger(ReconnectHour) ? SubStr("0" ReconnectHour, -2) : "").OnEvent("Change", nm_setReconnectHour)
	MainGui.Add("Edit", "x275 yp w18 h15 Number Limit2 vReconnectMin Disabled", IsInteger(ReconnectMin) ? SubStr("0" ReconnectMin, -2) : "").OnEvent("Change", nm_setReconnectMin)
	MainGui.SetFont("w1000 s11")
	MainGui.Add("Text", "x269 yp-2 +BackgroundTrans", ":")
	MainGui.SetFont("s6 w700")
	MainGui.Add("Text", "x295 yp+5 +BackgroundTrans", "UTC")
	MainGui.SetFont("s8 cDefault Norm", "Tahoma")
	MainGui.Add("Button", "x315 yp-2 w10 h15 vReconnectTimeHelp Disabled", "?").OnEvent("Click", nm_ReconnectTimeHelp)
	(GuiCtrl := MainGui.Add("CheckBox", "x176 yp+17 w132 h15 vPublicFallback Disabled Checked" PublicFallback, "Fallback to Public Server")).Section := "Settings", GuiCtrl.OnEvent("Click", nm_saveConfig)
	MainGui.Add("Button", "x315 yp w10 h15 vPublicFallbackHelp Disabled", "?").OnEvent("Click", nm_PublicFallbackHelp)
	MainGui.Add("Text", "x178 yp+16 w200 h15 +BackgroundTrans", "Detected Roblox:")
	MainGui.Add("Button", "x178 yp+15 w45 h15 vRefreshDetectedApplication Disabled", "Refresh").OnEvent("Click", nm_UpdateDetectedApplication)
	MainGui.Add("Text", "x226 yp w85 h15 vDetectedApplicationText +BackgroundTrans", StrReplace(nm_DetectRobloxType(), " (Web)"))
	MainGui.Add("Button", "x315 yp w10 h15 vDetectedApplicationHelp Disabled", "?").OnEvent("Click", nm_DetectedApplicationHelp)
	nm_UpdateDetectedApplication()

	;character settings
	MainGui.Add("Text", "x345 y40 w110 +BackgroundTrans", "Movement Speed:")
	MainGui.SetFont("s6")
	MainGui.Add("Text", "x345 y55 w80 +right +BackgroundTrans", "(WITHOUT HASTE)")
	MainGui.SetFont("s8 cDefault Norm", "Tahoma")
	MainGui.Add("Edit", "x438 y43 w43 r1 limit5 vMoveSpeedNum Disabled", MoveSpeedNum).OnEvent("Change", nm_moveSpeed)
	(GuiCtrl := MainGui.Add("CheckBox", "x345 y68 w125 h15 vNewWalk Disabled Checked" NewWalk, "MoveSpeed Correction")).Section := "Settings", GuiCtrl.OnEvent("Click", nm_saveConfig)
	MainGui.Add("Button", "x475 y68 w10 h15 vNewWalkHelp Disabled", "?").OnEvent("Click", nm_NewWalkHelp)
	MainGui.Add("Text", "x338 y90 w85 +Center +BackgroundTrans", "Move Method:")
	MainGui.Add("Text", "x434 yp w48 vMoveMethod +Center +BackgroundTrans", MoveMethod)
	MainGui.Add("Button", "x422 y89 w12 h16 vMMLeft Disabled", "<").OnEvent("Click", nm_MoveMethod)
	MainGui.Add("Button", "x480 y89 w12 h16 vMMRight Disabled", ">").OnEvent("Click", nm_MoveMethod)
	MainGui.Add("Text", "x338 y111 w85 +Center +BackgroundTrans", "Sprinkler Type:")
	MainGui.Add("Text", "x434 yp w48 vSprinklerType +Center +BackgroundTrans", SprinklerType)
	MainGui.Add("Button", "x422 y110 w12 h16 vSTLeft Disabled", "<").OnEvent("Click", nm_SprinklerType)
	MainGui.Add("Button", "x480 y110 w12 h16 vSTRight Disabled", ">").OnEvent("Click", nm_SprinklerType)
	MainGui.Add("Text", "x338 y132 w85 +Center +BackgroundTrans", "Convert Balloon:")
	MainGui.Add("Text", "x434 yp w48 vConvertBalloon +Center +BackgroundTrans", ConvertBalloon)
	MainGui.Add("Button", "x422 y131 w12 h16 vCBLeft Disabled", "<").OnEvent("Click", nm_ConvertBalloon)
	MainGui.Add("Button", "x480 y131 w12 h16 vCBRight Disabled", ">").OnEvent("Click", nm_ConvertBalloon)
	MainGui.Add("Text", "x370 y147 w110 +BackgroundTrans", "\____\___")
	(GuiCtrl := MainGui.Add("Edit", "x422 y150 w30 h18 number Limit3 vConvertMins Disabled", ValidateInt(&ConvertMins, 30))).Section := "Settings", GuiCtrl.OnEvent("Change", nm_saveConfig)
	MainGui.Add("Text", "x456 y152", "Mins")
	(GuiCtrl := MainGui.Add("CheckBox", "x345 y171 vDisableToolUse Disabled Checked" DisableToolUse, "Disable Tool Use")).Section := "Settings", GuiCtrl.OnEvent("Click", nm_saveConfig)

	;update settings
	MainGui.Add("Text", "x340 y210 w110 +BackgroundTrans", "Release Channel:")
	MainGui.Add("Text", "x443 yp w35 vReleaseChannel +BackgroundTrans +Center" , ReleaseChannel)
	MainGui.Add("Button", "xp-16 yp w12 h16 vRCLeft Disabled", "<").OnEvent("Click", nm_ReleaseChannel)
	MainGui.Add("Button", "xp+52 yp wp hp vRCRight Disabled", ">").OnEvent("Click", nm_ReleaseChannel)
	CurrentLoadProgress:=CurrentLoadProgress+SettingsFeatureProgressVolume
	SetLoadingProgress(floor(CurrentLoadProgress/LoadingProgressVolume*100))
}
nm_guiThemeSelect(*){
	GuiTheme := MainGui["GuiTheme"].Text
	IniWrite GuiTheme, "settings\nm_config.ini", "Settings", "GuiTheme"
	reload
	Sleep 10000
}
nm_guiTransparencySet(*){
	global GuiTransparency
	MainGui["GuiTransparency"].Text := GuiTransparency := MainGui["GuiTransparencyUpDown"].Value * 5
	IniWrite GuiTransparency, "settings\nm_config.ini", "Settings", "GuiTransparency"
	WinSetTransparent 255-floor(GuiTransparency*2.55), MainGui
}
nm_AlwaysOnTop(*){
	global
	IniWrite (AlwaysOnTop := MainGui["AlwaysOnTop"].Value), "settings\nm_config.ini", "Settings", "AlwaysOnTop"
	MainGui.Opt((AlwaysOnTop ? "+" : "-") "AlwaysOnTop")
}
nm_HiveBees(GuiCtrl, *){
	global HiveBees
	p := EditGetCurrentCol(GuiCtrl)
	NewHiveBees := GuiCtrl.Value

	if (IsInteger(NewHiveBees) && (NewHiveBees > 50)) ; contains char other than digit, or more than 50
	{
		GuiCtrl.Value := HiveBees
		SendMessage 0xB1, p-2, p-2, GuiCtrl
		nm_ShowErrorBalloonTip(GuiCtrl, "Unacceptable Number", "You cannot enter a number above 50!")
	}
	else
	{
		HiveBees := NewHiveBees
		IniWrite HiveBees, "settings\nm_config.ini", "Settings", "HiveBees"
	}
}
nm_HiveBeesHelp(*){
	MsgBox "
	(
	DESCRIPTION:
	Enter the number of Bees you have in your Hive.
	This doesn't have to be exactly the same as your in-game amount, but the macro will use this value to determine whether it can travel to the 35 Bee Zone, use the Red Cannon, etc.

	NOTE:
	Lowering this number will increase the time your character waits at hive after converting or before going to battle.
	If you notice that your bees don't finish converting or haven't recovered to fight mobs, reduce this value but keep it above 35 to enable access to all areas in the map.
	)", "Hive Bees", 0x40000
}
nm_AnnounceGuidWarn(GuiCtrl, *){
	global AnnounceGuidingStar
	if GuiCtrl.Value = 0
		IniWrite (AnnounceGuidingStar := 0), "settings\nm_config.ini", "Settings", "AnnounceGuidingStar"
	else {
		if (MsgBox("
		(
		WARNING:
		There have been reports of players getting warned on Roblox for using this feature. It is recommended to only enable when using private servers.
		There is still a chance of being warned, or potentially banned, even in private servers. Use at your own risk.

		DESCRIPTION:
		When enabled, the macro will send a message to the Roblox chat reading <<Guiding Star in (field) until __:mm>> when the "Guiding star in (field)" text is detected on the bottom right of your screen.

		Pressing "Cancel" will disable this feature.
		)", "Announce Guiding Star", 0x40031)="Ok")
			IniWrite (GuiCtrl.Value := AnnounceGuidingStar := 1), "settings\nm_config.ini", "Settings", "AnnounceGuidingStar"
		 else
			IniWrite (GuiCtrl.Value := AnnounceGuidingStar := 0), "settings\nm_config.ini", "Settings", "AnnounceGuidingStar"
	}
}
nm_HideErrorsWarn(GuiCtrl, *){
	global HideErrors
	if GuiCtrl.Value = 1 {
		IniWrite(1, "settings\nm_config.ini", "Settings", "HideErrors")
		Msgbox("The macro will now restart to apply this change.", "Restarting to apply changes", 0x40040)
	} else {
		if (MsgBox("
		(
		WARNING:
		Disabling this feature will make all errors appear.
		This may cause the macro to freeze or behave unpredictably.

		You should only disable this if you understand what you're doing or if you're instructed to by someone who does.

		DESCRIPTION:
		When this feature is disabled, any error will be shown instead of being automatically hidden and skipped.

		The macro will restart to apply the changes.

		Pressing "Cancel" will leave this feature enabled.
		)", "Hide Errors", 0x40031)="Ok")
			IniWrite(0, "settings\nm_config.ini", "Settings", "HideErrors")
		else {
			GuiCtrl.Value := 1
			return
		}
	}
	stop()
}
nm_ResetConfig(*){
	if (MsgBox("
	(
	Are you sure you want to reset ALL Natro settings?
	This will set all settings (Gather, Planters, Boost, Quests, etc.) to the default AND reset all timers (Collect/Kill, Planters, etc.), as if you freshly started the macro.

	If you want to proceed, click 'Yes'. Backup your 'settings' folder if you're unsure.
	)", "Reset Settings", 0x40034 " Owner" MainGui.Hwnd) = "Yes")
	{
		DirDelete A_WorkingDir "\settings"
		return stop()
	}
}

nm_testReconnect(*){
	CloseRoblox()
	if (DisconnectCheck(1) = 1)
		MsgBox "Success!", "Reconnect Test", 0x1000
}
/**
 * @see {https://devforum.roblox.com/t/parsing-deeplink-information-from-a-private-server-link-with-the-newer-format/3464724}
 * @see {https://devforum.roblox.com/t/improved-private-server-links/2628225/49}
 */
nm_ServerLink(GuiCtrl, *){
	global PrivServer, FallbackServer1, FallbackServer2, FallbackServer3
	ValidShareCode := link := 0
	p := EditGetCurrentCol(GuiCtrl)
	k := GuiCtrl.Name
	str := Trim(GuiCtrl.Value)
	RegExMatch(str, "i)roblox\.com\/([a-z]{2}\/)?games\/1537690962\/?([^\/]*)\?privateServerLinkCode=(?<code>[a-z0-9]{32})", &NewPrivLink) ; not too sure if LinkCode can have letters but better safe than sorry
	RegExMatch(str, "i)roblox\.com\/share\?code=(?<code>[a-f0-9]{32})&type=Server", &NewShareCode)


	if NewShareCode { ; fetch link
		SetCursor("IDC_APPSTARTING")
		link := "https://www.roblox.com/share?code=" NewShareCode.code "&type=Server"
		wr := ComObject("WinHttp.WinHttpRequest.5.1")
		wr.Open("GET", link, 1)
		wr.Send()

		if !(wr.WaitForResponse(3000)) || wr.Status != 200 || !InStr(wr.ResponseText, "roblox:start_place_id") ; roblox:start_place_id is not present if the link is invalid
			return failed("Failed to fetch link", "The link could not be fetched. Make sure you are using a valid Share Code link and that you copied the entire link.`r`n`r`nIt's also possible that roblox is down.")

		if !InStr(wr.ResponseText, 'content="1537690962"') ; All share code links contain a meta tag: <meta name="roblox:start_place_id" content="1537690962">. this is the BSS gameID
			return failed("Invalid Share Code", "Your link is not for Bee Swarm Simulator by Onett.")

		SetCursor()
		success(link)
	} else if NewPrivLink {
		link := "https://www.roblox.com/games/1537690962/?privateServerLinkCode=" NewPrivLink.code
		success(link)
	} else if StrLen(str) = 0 { ; removing link
		success("")
	} else {
		failed("Invalid Private Server Link", "Make sure your link is:`r`n- copied correctly and completely`r`n- for Bee Swarm Simulator by Onett")
	}

	failed(title, reason) {
		SendMessage(0xB1, p-2, p-2, GuiCtrl)
		GuiCtrl.Value := %k%
		nm_ShowErrorBalloonTip(GuiCtrl, title, reason)
	}
	success(newlink) {
		GuiCtrl.Value := %k% := newlink

		IniWrite %k%, "settings\nm_config.ini", "Settings", k

		if (k = "PrivServer") ;night announcement
			PostSubmacroMessage("Status", 0x5553, 10, 6)
	}
}
nm_ReconnectMethod(GuiCtrl, *){
	global ReconnectMethod
	static val := ["Deeplink", "Browser"], l := val.Length

	if (ReconnectMethod = "Deeplink")
	{
		if (MsgBox("
		(
		Setting Join Method to 'Browser' is not recommended!

		Even if you have a problem with the 'Deeplink' method, fixing it is a much better option than using the 'Browser' method.
		Read [?] for more information!

		Are you sure you want to change this?
		)", "Join Method", 0x1034 " T60 Owner" MainGui.Hwnd) = "Yes")
			i := 1
		else
			return
	}
	else
		i := 2

	i := (ReconnectMethod = "Deeplink") ? 1 : 2

	MainGui["ReconnectMethod"].Text := ReconnectMethod := val[(GuiCtrl.Name = "RMRight") ? (Mod(i, l) + 1) : (Mod(l + i - 2, l) + 1)]
	IniWrite ReconnectMethod, "settings\nm_config.ini", "Settings", "ReconnectMethod"
}
nm_ClaimMethod(GuiCtrl, *){
	global ClaimMethod
	static val := ["Detect", "To Slot"], l := val.Length

	if (ClaimMethod = "To Slot")
	{
		if (MsgBox("
		(
		Using 'Detect' might have the possiblity to incorrectly detect hive slots if the red arrows are being blocked by something. The most common example is a tool, such as Tide Popper.

		Are you sure you want to use 'Detect'?
		)", "Claim Hive Method", 0x1034 " T60 Owner" MainGui.Hwnd) = "Yes")
			i := 1
		else
			return
	}
	else
		i := 2

	i := (ClaimMethod = "Detect") ? 1 : 2

	MainGui["ClaimMethod"].Text := ClaimMethod := val[(GuiCtrl.Name = "CMRight") ? (Mod(i, l) + 1) : (Mod(l + i - 2, l) + 1)]
	IniWrite ClaimMethod, "settings\nm_config.ini", "Settings", "ClaimMethod"
}
nm_setReconnectInterval(GuiCtrl, *){
	global ReconnectInterval
	p := EditGetCurrentCol(GuiCtrl)
	NewReconnectInterval := GuiCtrl.Value

	if (IsNumber(NewReconnectInterval) && ((NewReconnectInterval = 0) || ((Mod(24, NewReconnectInterval) != 0) && NewReconnectInterval))) ; not a factor of 24 or 0
	{
		GuiCtrl.Value := ReconnectInterval
		SendMessage 0xB1, p-2, p-2, GuiCtrl
		nm_ShowErrorBalloonTip(GuiCtrl, "Unacceptable Number", "Reconnect Interval must be a factor of 24!`r`nThese are: 1, 2, 3, 4, 6, 8, 12, 24.")
	}
	else
	{
		ReconnectInterval := NewReconnectInterval
		IniWrite ReconnectInterval, "settings\nm_config.ini", "Settings", "ReconnectInterval"
	}
}
nm_setReconnectHour(GuiCtrl, *){
	global ReconnectHour
	p := EditGetCurrentCol(GuiCtrl)
	NewReconnectHour := GuiCtrl.Value

	if (IsNumber(NewReconnectHour) && (NewReconnectHour > 23)) ; not between 00 and 24
	{
		GuiCtrl.Value := ReconnectHour
		SendMessage 0xB1, p-2, p-2, GuiCtrl
		nm_ShowErrorBalloonTip(GuiCtrl, "Unacceptable Number", "Reconnect Hour must be between 00 and 23!")
	}
	else
	{
		ReconnectHour := NewReconnectHour
		IniWrite ReconnectHour, "settings\nm_config.ini", "Settings", "ReconnectHour"
	}
}
nm_setReconnectMin(GuiCtrl, *){
	global ReconnectMin
	p := EditGetCurrentCol(GuiCtrl)
	NewReconnectMin := GuiCtrl.Value

	if (IsNumber(NewReconnectMin) && (NewReconnectMin > 59)) ; not between 00 and 59
	{
		GuiCtrl.Value := ReconnectMin
		SendMessage 0xB1, p-2, p-2, GuiCtrl
		nm_ShowErrorBalloonTip(GuiCtrl, "Unacceptable Number", "Reconnect Minute must be between 00 and 59!")
	}
	else
	{
		ReconnectMin := NewReconnectMin
		IniWrite ReconnectMin, "settings\nm_config.ini", "Settings", "ReconnectMin"
	}
}
nm_ReconnectMethodHelp(*){ ; join method information
	MsgBox "
	(
	DESCRIPTION:
	This option lets you choose between 'Deeplink' and 'Browser' reconnect methods.

	'Deeplink' is the recommended method: it's faster (skips the browser step completely) and works with the Roblox Store app.
	It can also join BSS directly without the need for a redirecting game like BSS Rejoin. You can search "Roblox Developer Deeplinking" online for more info.

	'Browser' should only be used when 'Deeplink' does not work.
	This is the old/legacy method of reconnecting: it can have inconsistencies between browsers (e.g. failure to close tabs, Roblox not logged in)
	and you will not be able to join a public server directly ('Deeplink' is forced when joining public servers).
	)", "Join Method", 0x40000
}
nm_ClaimMethodHelp(*){ ; join method information
	MsgBox "
	(
	DESCRIPTION:
	This option lets you choose between 'Detect' and 'To Slot' Hive Claiming.

	'To Slot' is the more reliable option out of the bunch, this will go straight to the set hive slot without any concern as to if it's claimed or not.
	This is the best choice if you are in a private server.

	'Detect' is only recommended if you are playing in a public server for speed.
	It won't work if the red arrows pointing to unclaimed hive slots are covered, which can happen with tools like Tide Popper or Dark Scythe.
	)", "Claim Method", 0x40000
}
nm_ReconnectTimeHelp(*){
	global ReconnectHour, ReconnectMin, ReconnectInterval
	hhmmUTC := FormatTime(A_NowUTC, "HH:mm")
	hhmmLOC := FormatTime(A_Now, "HH:mm")
	s := DateDiff(A_Now, A_NowUTC, "S")
	o := Buffer(256), DllCall("GetDurationFormatEx"
		, "Ptr", 0
		, "UInt", 0
		, "Ptr", 0
		, "Int64", Abs(s)*10000000
		, "WStr", ((s>=0)?"+":"-") "hh:mm"
		, "Ptr", o.Ptr
		, "Int", 256), o := StrGet(o)

	if((!ReconnectHour && ReconnectHour!=0) || (!ReconnectMin && ReconnectMin!=0) || (Mod(24, ReconnectInterval) != 0)) {
		ReconnectTimeString:="`n<Invalid Time>"
	} else {
		ReconnectTimeString:=""
		Loop 24//ReconnectInterval {
			time := "19700101" SubStr("0" Mod(ReconnectHour+ReconnectInterval*(A_Index-1), 24), -2) SubStr("0" Mod(ReconnectMin, 60), -2) "00"
			hhmmReconnectUTC := FormatTime(time, "HH:mm")
			time := DateAdd(time, s, "S")
			hhmmReconnectLOC := FormatTime(time, "HH:mm")
			ReconnectTimeString.="`n" hhmmReconnectUTC " UTC = Local Time: " hhmmReconnectLOC
		}
	}

	MsgBox
	(
	"DEFINITION:
	UTC is the time standard commonly used across the world.
	The world's timing centers have agreed to keep their time scales closely synchronized - or coordinated - therefore the name Coordinated Universal Time.

	Why use UTC?
	This allows all players on the same server to enter the same time value into the GUI regardless of the local timezone.

	TIME NOW:
	Local Time: " hhmmLOC " (UTC" o " hours) = UTC Time: " hhmmUTC "

	RECONNECT TIMES: " ReconnectTimeString
	), "Coordinated Universal Time (UTC)", 0x40000 " Owner" MainGui.Hwnd
}
nm_PublicFallbackHelp(*){ ; public fallback information
	MsgBox "
	(
	DESCRIPTION:
	When this option is enabled, the macro will revert to attempting to join a Public Server if your Server Link failed three times.
	Otherwise, it will keep trying the Server Link you entered above until it succeeds.
	)", "Public Server Fallback", 0x40000
}
nm_UpdateDetectedApplication(*){	; detected roblox link type
	local robloxtype := nm_DetectRobloxType()
	MainGui["DetectedApplicationText"].Text := robloxtype

	if robloxtype = RobloxTypes.NotFound || robloxtype = RobloxTypes.UWP
		MainGui["DetectedApplicationText"].SetFont("c0xAA0000")
	else
		MainGui["DetectedApplicationText"].SetFont("c0x0000FF")
}
nm_DetectedApplicationHelp(*){ ; detected application information
	MsgBox "
	(
	DESCRIPTION:
	This shows if you are using Web or UWP Roblox.
	If you have multiple Roblox versions installed (including bootstrappers such as Bloxstrap), these are added to the 'roblox' link type.

	IMPORTANT:
	Natro Macro currently does not support UWP Roblox due to a recent update!
	)", "Detected Application", 0x40000
}
nm_FPSUnlockerHelp(*) {
    MsgBox "
    (
    "UWP" or "Web" Roblox refers to the difference between the Microsoft Store version (UWP) and the Roblox Player downloaded from the official website.
    You must use the web version, as the macro currently does not support UWP version.

To reset your Roblox framerate cap without the macro, follow these steps:

1. Open Roblox and join any game/server
2. Open settings (ESC)
3. Change Maximum Frame Rate to a different value

    The macro is able to do this by interacting with the launcher's XML file (GlobalSettings_*.xml).
    That file does not contain any personal data, and the macro never sends or shares your information externally.
    )", "FPS Unlocker", 0x40000
}
nm_moveSpeed(GuiCtrl, *){
	global MoveSpeedNum
	p := EditGetCurrentCol(GuiCtrl)
	NewMoveSpeed := GuiCtrl.Value
	StrReplace(NewMoveSpeed, ".", , , &n)

	if (NewMoveSpeed ~= "[^\d\.]" || (n > 1)) ; contains char other than digit or dpt, or more than 1 dpt
	{
		GuiCtrl.Value := MoveSpeedNum
		SendMessage 0xB1, p-2, p-2, GuiCtrl
	}
	else
	{
		MoveSpeedNum := NewMoveSpeed
		IniWrite MoveSpeedNum, "settings\nm_config.ini", "Settings", "MoveSpeedNum"
	}
}
nm_NewWalkHelp(*){ ; movespeed correction information
	MsgBox "
	(
	DESCRIPTION:
	When this option is enabled, the macro will detect your Haste, Bear Morph, Coconut Haste, Haste+, Oil and Super Smoothie values real-time.
	Using this information, it will calculate the distance you have moved and use that for more accurate movements.
	If working as intended, this option will dramatically reduce drift and make Traveling anywhere in game much more accurate.

	IMPORTANT:
	If you have this option enabled, make sure your 'Movement Speed' is EXACTLY as shown in BSS Settings menu without haste or other temporary buffs (e.g. write 33.6 as 33.6 without any rounding).
	Also, it is ESSENTIAL that your Display Scale is 100%, otherwise the buffs will not be detected properly.
	)", "MoveSpeed Correction", 0x40000
}
nm_MoveMethod(GuiCtrl, *){
	global MoveMethod
	static val := ["Walk", "Cannon"], l := val.Length

	i := (MoveMethod = "Walk") ? 1 : 2

	MainGui["MoveMethod"].Text := MoveMethod := val[(GuiCtrl.Name = "MMRight") ? (Mod(i, l) + 1) : (Mod(l + i - 2, l) + 1)]
	IniWrite MoveMethod, "settings\nm_config.ini", "Settings", "MoveMethod"
}
nm_SprinklerType(GuiCtrl, *){
	global SprinklerType
	static val := ["None", "Basic", "Silver", "Golden", "Diamond", "Supreme"], l := val.Length

	switch SprinklerType, 0
	{
		case "None":
		i := 1
		case "Basic":
		i := 2
		case "Silver":
		i := 3
		case "Golden":
		i := 4
		case "Diamond":
		i := 5
		default:
		i := 6
	}

	MainGui["SprinklerType"].Text := SprinklerType := val[(GuiCtrl.Name = "STRight") ? (Mod(i, l) + 1) : (Mod(l + i - 2, l) + 1)]
	IniWrite SprinklerType, "settings\nm_config.ini", "Settings", "SprinklerType"
}
nm_ConvertBalloon(GuiCtrl, *){
	global ConvertBalloon
	static val := ["Never", "Every", "Always", "Gather"], l := val.Length

	i := (ConvertBalloon = "Never") ? 1 : (ConvertBalloon = "Every") ? 2 : (ConvertBalloon = "Always") ? 3 : 4

	MainGui["ConvertBalloon"].Text := ConvertBalloon := val[(GuiCtrl.Name = "CBRight") ? (Mod(i, l) + 1) : (Mod(l + i - 2, l) + 1)]
	MainGui["ConvertMins"].Enabled := (ConvertBalloon = "Every")
	IniWrite ConvertBalloon, "settings\nm_config.ini", "Settings", "ConvertBalloon"
}
nm_ReleaseChannel(GuiCtrl, *){
	global ReleaseChannel
	static val := ["Stable", "Beta"], l := val.Length

	if (ReleaseChannel = "Stable"){ ; change to beta
		if MsgBox(
		(
		'
		WARNING:
		Switching to the beta release channel may expose your macro to more bugs than normal. This can cause your macro to function unexpectedly.

		You will need to restart the macro to fetch beta updates (if any exist)

		Only enable this feature if you know what you are doing!
		'
		), "Release Channel", 0x40031) != "Ok"
			return
	}

	i := (ReleaseChannel = "Stable") ? 1 : 2

	MainGui["ReleaseChannel"].Text := ReleaseChannel := val[(GuiCtrl.Name = "RCRight") ? (Mod(i, l) + 1) : (Mod(l + i - 2, l) + 1)]
	IniWrite ReleaseChannel, "settings\nm_config.ini", "Settings", "ReleaseChannel"
}