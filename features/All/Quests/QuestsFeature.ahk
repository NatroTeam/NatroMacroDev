#Requires AutoHotkey v2.0

global questsConfigLoc := "features\All\Quests\nm_quests_config.ini"

;this is this features GUI lines-of-code used to calculate loading progress
QuestsFeatureProgressVolume := (QuestsFeature) ? 48 : 0
;this is the running total of all macro features included in the load progress metric
LoadingProgressVolume := (QuestsFeature) ? LoadingProgressVolume+QuestsFeatureProgressVolume : LoadingProgressVolume

nm_QuestsTab(*) {
	global
	TabCtrl.UseTab("Quests")
	MainGui.SetFont("w700")
	MainGui.Add("GroupBox", "x5 y23 w150 h108", "Polar Bear")
	MainGui.Add("GroupBox", "x5 y131 w150 h38", "Honey Bee")
	MainGui.Add("GroupBox", "x5 y170 w150 h68", "Settings")
	MainGui.Add("GroupBox", "x160 y23 w165 h108", "Black Bear")
	MainGui.Add("GroupBox", "x160 y131 w165 h108", "Brown Bear")
	MainGui.Add("GroupBox", "x330 y23 w165 h108", "Bucko Bee")
	MainGui.Add("GroupBox", "x330 y131 w165 h108", "Riley Bee")

	petalQuestDisclaimer := Msgbox.Bind(
		"As of version 1.1.0, petal quests have been added to detection, but the macro will simply gather in the corresponding field, or the field with the highest concenctration of a specific petal color."
		. "`n`nIT IS EXPECTED THAT PETAL QUESTS TAKE A LONG TIME, especially high-tier quests like Riley/Bucko at 250+ quests completed"
		, "Petal Quest Warning", "Owner" MainGui.Hwnd)

	MainGui.SetFont("s8 cDefault Norm", "Tahoma")
	(GuiCtrl := MainGui.Add("CheckBox", "x80 y23 vPolarQuestCheck Disabled Checked" PolarQuestCheck, "Enable")).Section := "Quests", GuiCtrl.OnEvent("Click", nm_PolarQuestCheck)
	(GuiCtrl := MainGui.Add("CheckBox", "x15 y37 vPolarQuestGatherInterruptCheck Disabled Checked" PolarQuestGatherInterruptCheck, "Allow Gather Interrupt")).Section := "Quests", GuiCtrl.OnEvent("Click", nm_saveConfig)
	MainGui.Add("Text", "x8 y51 w145 h78 vPolarQuestProgress", StrReplace(PolarQuestProgress, "|", "`n"))

	(GuiCtrl := MainGui.Add("CheckBox", "x80 y131 vHoneyQuestCheck Disabled Checked" HoneyQuestCheck, "Enable")).Section := "Quests", GuiCtrl.OnEvent("Click", nm_saveConfig)
	MainGui.Add("Text", "x8 y145 w143 h20 vHoneyQuestProgress", StrReplace(HoneyQuestProgress, "|", "`n"))

	MainGui.Add("Text", "x8 y184 +BackgroundTrans", "Gather Limit:")
	MainGui.Add("Text", "x+4 y183 w36 h16 0x201 +Center")
	(GuiCtrl := MainGui.Add("UpDown", "Range1-999 vQuestGatherMins Disabled", QuestGatherMins)).Section := "Quests", GuiCtrl.OnEvent("Change", nm_saveConfig)
	MainGui.Add("Text", "x+4 y184 +BackgroundTrans", "Mins")
	MainGui.Add("Text", "x8 y201 +BackgroundTrans", "To Hive By:")
	MainGui.Add("Text", "x+18 yp w34 vQuestGatherReturnBy +Center +BackgroundTrans", QuestGatherReturnBy)
	MainGui.Add("Button", "xp-12 yp-1 w12 h16 vQGRBLeft Disabled", "<").OnEvent("Click", nm_QuestGatherReturnBy)
	MainGui.Add("Button", "xp+45 yp w12 h16 vQGRBRight Disabled", ">").OnEvent("Click", nm_QuestGatherReturnBy)
	(GuiCtrl := MainGui.Add("CheckBox", "x8 yp+18 vQuestBoostCheck Disabled Checked" QuestBoostCheck, "Use Boost Tab for Quests")).Section := "Quests", GuiCtrl.OnEvent("Click", nm_saveConfig)

	MainGui.Add("CheckBox", "x240 y23 vBlackQuestCheck Disabled Checked" BlackQuestCheck, "Enable").OnEvent("Click", nm_BlackQuestCheck)
	MainGui.Add("Text", "x163 y38 w158 h92 vBlackQuestProgress", StrReplace(BlackQuestProgress, "|", "`n"))

	(GuiCtrl := MainGui.Add("CheckBox", "x240 y131 vBrownQuestCheck Disabled Checked" BrownQuestCheck, "Enable")).Section := "Quests", GuiCtrl.OnEvent("Click", nm_saveConfig)
	MainGui.Add("Text", "x163 y146 w158 h92 vBrownQuestProgress", StrReplace(BrownQuestProgress, "|", "`n"))

	MainGui.Add("CheckBox", "x410 y23 vBuckoQuestCheck Disabled Checked" BuckoQuestCheck, "Enable").OnEvent("Click", nm_BuckoQuestCheck)
	MainGui.Add("CheckBox", "x340 y37 vBuckoQuestGatherInterruptCheck Disabled Checked" BuckoQuestGatherInterruptCheck, "Allow Gather Interrupt").OnEvent("Click", nm_BuckoQuestCheck)
	MainGui.Add("Text", "x333 y51 w158 h78 vBuckoQuestProgress", StrReplace(BuckoQuestProgress, "|", "`n"))

	MainGui.Add("CheckBox", "x410 y131 vRileyQuestCheck Disabled Checked" RileyQuestCheck, "Enable").OnEvent("Click", nm_RileyQuestCheck)
	MainGui.Add("CheckBox", "x340 y145 vRileyQuestGatherInterruptCheck Disabled Checked" RileyQuestGatherInterruptCheck, "Allow Gather Interrupt").OnEvent("Click", nm_RileyQuestCheck)
	MainGui.Add("Text", "x333 y159 w158 h78 vRileyQuestProgress", StrReplace(RileyQuestProgress, "|", "`n"))

	MainGui.SetFont("w700")
	MainGui.SetFont("s8 cDefault Norm", "Tahoma")
	CurrentLoadProgress:=CurrentLoadProgress+QuestsFeatureProgressVolume
	SetLoadingProgress(floor(CurrentLoadProgress/LoadingProgressVolume*100))
}
nm_BlackQuestCheck(*){
	global
	IniWrite (BlackQuestCheck := MainGui["BlackQuestCheck"].Value), "settings\nm_config.ini", "Quests", "BlackQuestCheck"
	if (BlackQuestCheck = 1)
		MsgBox "This option only works for the repeatable quests. You must first complete the main questline before this option will work properly.", "Black Bear Quest", "Owner" MainGui.Hwnd
}
nm_BuckoQuestCheck(*){
	global
	IniWrite (BuckoQuestCheck := MainGui["BuckoQuestCheck"].Value), "settings\nm_config.ini", "Quests", "BuckoQuestCheck"
	IniWrite (BuckoQuestGatherInterruptCheck := MainGui["BuckoQuestGatherInterruptCheck"].Value), "settings\nm_config.ini", "Quests", "BuckoQuestGatherInterruptCheck"
	if ((BuckoQuestCheck = 1) && (AntPassCheck = 0)) {
		IniWrite (MainGui["AntPassCheck"].Value := AntPassCheck := 1), "settings\nm_config.ini", "Collect", "AntPassCheck"
		IniWrite (MainGui["AntPassAction"].Text := AntPassAction := "Pass"), "settings\nm_config.ini", "Collect", "AntPassAction"
		MsgBox 'Ant Pass collection has been automatically enabled so the passes can be stockpiled for the "Picnic" quest.', "Bucko Bee Quest", "Owner" MainGui.Hwnd
	}
	if BuckoQuestCheck
		petalQuestDisclaimer()
}
nm_RileyQuestCheck(*){
	global
	IniWrite (RileyQuestCheck := MainGui["RileyQuestCheck"].Value), "settings\nm_config.ini", "Quests", "RileyQuestCheck"
	IniWrite (RileyQuestGatherInterruptCheck := MainGui["RileyQuestGatherInterruptCheck"].Value), "settings\nm_config.ini", "Quests", "RileyQuestGatherInterruptCheck"
	if ((RileyQuestCheck = 1) && (AntPassCheck = 0)) {
		IniWrite (MainGui["AntPassCheck"].Value := AntPassCheck := 1), "settings\nm_config.ini", "Collect", "AntPassCheck"
		IniWrite (MainGui["AntPassAction"].Text := AntPassAction := "Pass"), "settings\nm_config.ini", "Collect", "AntPassAction"
		MsgBox 'Ant Pass collection has been automatically enabled so the passes can be stockpiled for the "Picnic" quest.', "Riley Bee Quest", "Owner" MainGui.Hwnd
	}
	if RileyQuestCheck
		petalQuestDisclaimer()
}
nm_PolarQuestCheck(*){
	global
	IniWrite (PolarQuestCheck := MainGui["PolarQuestCheck"].Value), "settings\nm_config.ini", "Quests", "PolarQuestCheck"
	if (PolarQuestCheck = 1)
		petalQuestDisclaimer()
}
nm_QuestGatherReturnBy(GuiCtrl, *){
	global QuestGatherReturnBy
	static val := ["Walk", "Reset"], l := val.Length

	i := (QuestGatherReturnBy = "Walk") ? 1 : 2

	MainGui["QuestGatherReturnBy"].Text := QuestGatherReturnBy := val[(GuiCtrl.Name = "QGRBRight") ? (Mod(i, l) + 1) : (Mod(l + i - 2, l) + 1)]
	IniWrite QuestGatherReturnBy, "settings\nm_config.ini", "Quests", "QuestGatherReturnBy"
}

;quest functions //todo: pending rewrite: lots of code duplication and inefficiencies!
nm_QuestRotate(){
	global QuestGatherField, RotateQuest, BlackQuestCheck, BlackQuestComplete, LastBlackQuest, BrownQuestCheck, BuckoQuestCheck, BuckoQuestComplete, RileyQuestCheck, RileyQuestComplete, HoneyQuestCheck, PolarQuestCheck, GatherFieldBoostedStart, LastGlitter, MondoBuffCheck, PMondoGuid, LastGuid, MondoAction, LastMondoBuff, bitmaps

	if ((BlackQuestCheck=0) && (BrownQuestCheck=0) && (BuckoQuestCheck=0) && (RileyQuestCheck=0) && (HoneyQuestCheck=0) && (PolarQuestCheck=0))
		return
	if (nm_NightInterrupt() || nm_MondoInterrupt() || nm_GatherBoostInterrupt())
		return

	;open quest log
	nm_OpenMenu("questlog")

	;polar bear quest
	nm_PolarQuest()

	if (QuestGatherField = "None") {
		;black bear quest first
		nm_BlackQuest()

		;black bear quest is complete but not yet time to turn in, move onto next quest
		if(BlackQuestCheck=0 || (BlackQuestComplete && (nowUnix()-LastBlackQuest)<3600)) {
			;bucko quest
			nm_BuckoQuest()
			if(BuckoQuestCheck=0 || BuckoQuestComplete=2) {
				nm_RileyQuest()
			}
		}
	}

	if (QuestGatherField = "None") {
		;all previous quests did not set a QuestGatherField, so check brown bear quest
		nm_BrownQuest()
	}

	;honey bee quest
	nm_HoneyQuest()
}
nm_HoneyQuest(){
	global HoneyStart
	global HoneyQuestCheck
	global HoneyQuestProgress
	global HoneyQuestComplete:=1
	global QuestBarSize
	global QuestBarGapSize
	global QuestBarInset
	global state, bitmaps
	if(!HoneyQuestCheck)
		return
	nm_setShiftLock(0)
	nm_OpenMenu("questlog")

	hwnd := GetRobloxHWND()
	offsetY := GetYOffset(hwnd)
	;search for honey quest
	Loop 70
	{
		Qfound:=nm_imgSearch("honeyhunt.png",50,"quest")
		if (Qfound[1]=0) {
			if (A_Index > 1)
				Gdip_DisposeImage(pBMLog)
			break
		}

		ActivateRoblox()
		switch A_Index
		{
			case 1:
			GetRobloxClientPos(hwnd)
			MouseMove windowX+30, windowY+offsetY+200, 5
			Loop 50 ; scroll all the way up
			{
				MouseMove windowX+30, windowY+offsetY+200, 5
				sendinput "{WheelUp}"
				Sleep 50
			}
			pBMLog := Gdip_BitmapFromScreen(windowX+30 "|" windowY+offsetY+180 "|30|400")

			default:
			GetRobloxClientPos(hwnd)
			MouseMove windowX+30, windowY+offsetY+200, 5
			sendinput "{WheelDown}"
			Sleep 500 ; wait for scroll to finish
			pBMScreen := Gdip_BitmapFromScreen(windowX+30 "|" windowY+offsetY+180 "|30|400")
			if (Gdip_ImageSearch(pBMScreen, pBMLog, , , , , , 50) = 1) { ; end of quest log
				Gdip_DisposeImage(pBMLog), Gdip_DisposeImage(pBMScreen)
				break
			}
			Gdip_DisposeImage(pBMLog), pBMLog := Gdip_CloneBitmap(pBMScreen), Gdip_DisposeImage(pBMScreen)
		}
	}
	Sleep 500

	if(Qfound[1]=0){
		;locate exact bottom of quest title bar coordinates
		;titlebar = 30 pixels high
		;quest objective bar spacing = 10 pixels
		;quest objective bar height = 40 pixels
		GetRobloxClientPos(hwnd)
		MouseMove windowX+350, windowY+offsetY+100
		xi := windowX
		yi := windowY+Qfound[3]
		ww := windowX+306
		wh := windowY+windowHeight
		fileName:="questbargap.png"
		if DirExist(A_WorkingDir "\nm_image_assets")
		{
			try result := ImageSearch(&FoundX, &FoundY, xi, yi, ww, wh, "*5 " A_WorkingDir "\nm_image_assets\" fileName)
			catch {
				nm_setStatus("Error", "Image file " filename " was not found in:`n" A_WorkingDir "\nm_image_assets\" fileName)
				Sleep 5000
				ProcessClose DllCall("GetCurrentProcessId")
			}
		} else {
			MsgBox "Folder location cannot be found:`n" A_WorkingDir "\nm_image_assets\"
		}
		HoneyStart:=(result = 1) ? [0, FoundX-windowX, FoundY-windowY] : [1, 0, 0]
		;Update Honey quest progress in GUI
		honeyProgress:=""
		;also set next steps
		questbarColor := PixelGetColor(windowX+QuestBarInset+10, windowY+HoneyStart[3]+QuestBarGapSize+5)
		;temp%A_Index%:=questbarColor
		if((questbarColor=0xF46C55) || (questbarColor=0x6EFF60)) {
			HoneyQuestComplete:=0
			completeness:="Incomplete"
		}
		;border color, white (titlebar), black (text)
		else if((questbarColor!=0x96C3DE) && (questbarColor!=0xE5F0F7) && (questbarColor!=0x1B2A35)) {
			HoneyQuestComplete:=1
			completeness:="Complete"
		} else {
			completeness:="Unknown"
		}
		honeyProgress:=("Honey Tokens: " . completeness)
		IniWrite honeyProgress, "settings\nm_config.ini", "Quests", "HoneyQuestProgress"
		MainGui["HoneyQuestProgress"].Text := StrReplace(honeyProgress, "|", "`n")
	}
	if(HoneyQuestComplete)
	{
		nm_updateAction("Quest")
		nm_gotoQuestgiver("Honey")
		nm_setStatus("Starting", "Honey Quest: Honey Hunt")
	}
}
nm_PolarQuestProg(){
	global PolarQuestCheck
	global PolarBear
	global PolarQuest
	global PolarStart
	global PolarQuestProgress
	global QuestGatherField:="None"
	global QuestGatherFieldSlot:=0
	global PolarQuestComplete:=1
	global QuestLadybugs
	global QuestRhinoBeetles
	global QuestSpider
	global QuestMantis
	global QuestScorpions
	global QuestWerewolf
	global QuestBarSize
	global QuestBarGapSize
	global QuestBarInset
	global state, bitmaps
	if(!PolarQuestCheck)
		return
	nm_setShiftLock(0)
	nm_OpenMenu("questlog")

	hwnd := GetRobloxHWND()
	offsetY := GetYOffset(hwnd)
	;search for polar quest
	Loop 70
	{
		Qfound:=nm_imgSearch("polar_bear.png",50,"quest")
		if (Qfound[1]=0) {
			if (A_Index > 1)
				Gdip_DisposeImage(pBMLog)
			break
		}

		Qfound:=nm_imgSearch("polar_bear2.png",50,"quest")
		if (Qfound[1]=0) {
			if (A_Index > 1)
				Gdip_DisposeImage(pBMLog)
			break
		}

		Qfound:=nm_imgSearch("polar_bear3.png",50,"quest")
		if (Qfound[1]=0) {
			if (A_Index > 1)
				Gdip_DisposeImage(pBMLog)
			break
		}

		ActivateRoblox()
		switch A_Index
		{
			case 1:
			GetRobloxClientPos(hwnd)
			MouseMove windowX+30, windowY+offsetY+200, 5
			Loop 50 ; scroll all the way up
			{
				MouseMove windowX+30, windowY+offsetY+200, 5
				sendinput "{WheelUp}"
				Sleep 50
			}
			pBMLog := Gdip_BitmapFromScreen(windowX+30 "|" windowY+offsetY+180 "|30|400")

			default:
			GetRobloxClientPos(hwnd)
			MouseMove windowX+30, windowY+offsetY+200, 5
			sendinput "{WheelDown}"
			Sleep 500 ; wait for scroll to finish
			pBMScreen := Gdip_BitmapFromScreen(windowX+30 "|" windowY+offsetY+180 "|30|400")
			if (Gdip_ImageSearch(pBMScreen, pBMLog, , , , , , 50) = 1) { ; end of quest log
				Gdip_DisposeImage(pBMLog), Gdip_DisposeImage(pBMScreen)
				break
			}
			Gdip_DisposeImage(pBMLog), pBMLog := Gdip_CloneBitmap(pBMScreen), Gdip_DisposeImage(pBMScreen)
		}
	}
	Sleep 500

	if(Qfound[1]=0){
		;locate exact bottom of quest title bar coordinates
		;titlebar = 30 pixels high
		;quest objective bar spacing = 10 pixels
		;quest objective bar height = 40 pixels
		GetRobloxClientPos(hwnd)
		MouseMove windowX+350, windowY+offsetY+100
		xi := windowX
		yi := windowY+Qfound[3]
		ww := windowX+306
		wh := windowY+windowHeight
		fileName:="questbargap.png"
		if DirExist(A_WorkingDir "\nm_image_assets")
		{
			try result := ImageSearch(&FoundX, &FoundY, xi, yi, ww, wh, "*5 " A_WorkingDir "\nm_image_assets\" fileName)
			catch {
				nm_setStatus("Error", "Image file " filename " was not found in:`n" A_WorkingDir "\nm_image_assets\" fileName)
				Sleep 5000
				ProcessClose DllCall("GetCurrentProcessId")
			}
		} else {
			MsgBox "Folder location cannot be found:`n" A_WorkingDir "\nm_image_assets\"
		}
		PolarStart:=(result = 1) ? [0, FoundX-windowX, FoundY-windowY] : [1, 0, 0]
		;determine Quest name
		xi := windowX
		yi := windowY+PolarStart[3]-30
		ww := windowX+306
		wh := windowY+PolarStart[3]
		for key, value in PolarBear {
			filename:=(key . ".png")
			try
				result := ImageSearch(&FoundX, &FoundY, xi, yi, ww, wh, "*10 nm_image_assets\" fileName)
			catch
				result := 0
			if(result = 1) {
				PolarQuest:=key
				questSteps:=PolarBear[key].Length
				;make sure full quest is visible
				loop 5 {
					found:=0
					NextY:=windowY+PolarStart[3]
					loop questSteps {
						try
							result := ImageSearch(&FoundX, &FoundY, windowX+QuestBarInset, NextY, windowX+QuestBarInset+300, NextY+QuestBarGapSize, "*5 nm_image_assets\questbargap.png")
						catch
							result := 0
						if(result = 1) {
							NextY:=NextY+QuestBarSize
							found:=found+1
						} else {
							break
						}
					}
					if(found<questSteps) {
						MouseMove windowX+30, windowY+offsetY+225
						Sleep 50
						Send "{WheelDown 1}"
						Sleep 50
						PolarStart[3]-=150
						Sleep 500
					} else {
						break 2
					}
				}
				break
			}
		}
		;Update Polar quest progress in GUI
		;also set next steps
		QuestGatherField:="None"
		QuestGatherFieldSlot:=0
		newLine:="|"
		polarProgress:=""
		num:=PolarBear[PolarQuest].Length
		loop num {
			action:=PolarBear[PolarQuest][A_Index][2]
			where:=PolarBear[PolarQuest][A_Index][3]
			questbarColor := PixelGetColor(windowX+QuestBarInset+10, windowY+QuestBarSize*(PolarBear[PolarQuest][A_Index][1]-1)+PolarStart[3]+QuestBarGapSize+5)
			if((questbarColor=0xF46C55) || (questbarColor=0x6EFF60)) {
				PolarQuestComplete:=0
				completeness:="Incomplete"
				if(action="kill"){
					Quest%where%:=1
				}
				else if (action="collect" && QuestGatherField="none") {
					QuestGatherField:=where
					QuestGatherFieldSlot:=PolarBear[PolarQuest][A_Index][1]
				}
			}
			;border color, white (titlebar), black (text)
			else if((questbarColor!=0x96C3DE) && (questbarColor!=0xE5F0F7) && (questbarColor!=0x1B2A35)) {
				completeness:="Complete"
				if(action="kill"){
					Quest%where%:=0
				}
			} else {
				completeness:="Unknown"
			}
			if(A_Index=1)
				polarProgress:=(PolarQuest . newline . action . " " . (where = "None" ? "Any" : where) . ": " . completeness)
			else
				polarProgress:=(polarProgress . newline . action . " " . (where = "None" ? "Any" : where) . ": " . completeness)
		}
		IniWrite polarProgress, "settings\nm_config.ini", "Quests", "PolarQuestProgress"
		MainGui["PolarQuestProgress"].Text := StrReplace(polarProgress, "|", "`n")
		if(QuestLadybugs=0 && QuestRhinoBeetles=0 && QuestSpider=0 && QuestMantis=0 && QuestScorpions=0 && QuestWerewolf=0 && QuestGatherField="None"){
			PolarQuestComplete:=1
		}
	}
}
nm_PolarQuest(){
	global PolarQuestCheck, PolarQuest, PolarQuestComplete, QuestGatherField, QuestLadybugs, QuestRhinoBeetles, QuestSpider, QuestMantis, QuestScorpions, QuestWerewolf, LastBugrunLadybugs, LastBugrunRhinoBeetles, LastBugrunSpider, LastBugrunMantis, LastBugrunScorpions, LastBugrunWerewolf, MonsterRespawnTime, RotateQuest, TotalQuestsComplete, SessionQuestsComplete
	if(!PolarQuestCheck)
		return
	nm_setShiftLock(0)
	RotateQuest:="Polar"
	nm_PolarQuestProg()
	if(PolarQuestComplete = 1) {
		nm_updateAction("Quest")
		nm_gotoQuestgiver("Polar")
		nm_PolarQuestProg()
		if(!PolarQuestComplete){
			nm_setStatus("Starting", "Polar Quest: " . PolarQuest)
			TotalQuestsComplete:=TotalQuestsComplete+1
			SessionQuestsComplete:=SessionQuestsComplete+1
			PostSubmacroMessage("StatMonitor", 0x5555, 5, 1)
			IniWrite TotalQuestsComplete, "settings\nm_config.ini", "Status", "TotalQuestsComplete"
			IniWrite SessionQuestsComplete, "settings\nm_config.ini", "Status", "SessionQuestsComplete"
		}
	}
	;do quest stuff
	if(PolarQuestComplete != 1) {
		if ((QuestLadybugs && (nowUnix()-LastBugrunLadybugs)>floor(330*(1-(MonsterRespawnTime?MonsterRespawnTime:0)*0.01))) || (QuestRhinoBeetles && (nowUnix()-LastBugrunRhinoBeetles)>floor(330*(1-(MonsterRespawnTime?MonsterRespawnTime:0)*0.01))) || (QuestSpider && (nowUnix()-LastBugrunSpider)>floor(1830*(1-(MonsterRespawnTime?MonsterRespawnTime:0)*0.01))) || (QuestMantis && (nowUnix()-LastBugrunMantis)>floor(1230*(1-(MonsterRespawnTime?MonsterRespawnTime:0)*0.01))) || (QuestScorpions && (nowUnix()-LastBugrunScorpions)>floor(1230*(1-(MonsterRespawnTime?MonsterRespawnTime:0)*0.01))) || (QuestWerewolf && (nowUnix()-LastBugrunWerewolf)>floor(3600*(1-(MonsterRespawnTime?MonsterRespawnTime:0)*0.01)))){
			nm_Bugrun()
		}
		if nm_NightInterrupt()
			return
		nm_PolarQuestProg()
		if(PolarQuestComplete) {
			nm_updateAction("Quest")
			nm_gotoQuestgiver("Polar")
			nm_PolarQuestProg()
			if(!PolarQuestComplete){
				nm_setStatus("Starting", "Polar Quest: " . PolarQuest)
				TotalQuestsComplete:=TotalQuestsComplete+1
				SessionQuestsComplete:=SessionQuestsComplete+1
				PostSubmacroMessage("StatMonitor", 0x5555, 5, 1)
				IniWrite TotalQuestsComplete, "settings\nm_config.ini", "Status", "TotalQuestsComplete"
				IniWrite SessionQuestsComplete, "settings\nm_config.ini", "Status", "SessionQuestsComplete"
			}
		}
	}
}
nm_RileyQuestProg(){
	global RileyQuestCheck, RileyBee, RileyQuest, RileyStart, HiveBees, FieldName1, LastAntPass, LastRedBoost, RileyLadybugs, RileyScorpions, RileyAll
	global QuestGatherField:="None"
	global QuestGatherFieldSlot:=0
	global RileyQuestComplete:=1
	global RileyQuestProgress
	global QuestAnt:=0
	global QuestRedBoost:=0
	global QuestFeed:="None"
	global QuestBarSize
	global QuestBarGapSize
	global QuestBarInset
	global state
	global LastBugrunLadybugs, MonsterRespawnTime, LastBugrunScorpions, bitmaps
	if(!RileyQuestCheck)
		return
	nm_setShiftLock(0)
	nm_OpenMenu("questlog")

	hwnd := GetRobloxHWND()
	offsetY := GetYOffset(hwnd)
	;search for riley quest
	Loop 70
	{
		Qfound:=nm_imgSearch("riley.png",50,"quest")
		if (Qfound[1]=0) {
			if (A_Index > 1)
				Gdip_DisposeImage(pBMLog)
			break
		}

		Qfound:=nm_imgSearch("riley2.png",50,"quest")
		if (Qfound[1]=0) {
			if (A_Index > 1)
				Gdip_DisposeImage(pBMLog)
			break
		}

		ActivateRoblox()
		switch A_Index
		{
			case 1:
			GetRobloxClientPos(hwnd)
			MouseMove windowX+30, windowY+offsetY+200, 5
			Loop 50 ; scroll all the way up
			{
				MouseMove windowX+30, windowY+offsetY+200, 5
				sendinput "{WheelUp}"
				Sleep 50
			}
			pBMLog := Gdip_BitmapFromScreen(windowX+30 "|" windowY+offsetY+180 "|30|400")

			default:
			GetRobloxClientPos(hwnd)
			MouseMove windowX+30, windowY+offsetY+200, 5
			sendinput "{WheelDown}"
			Sleep 500 ; wait for scroll to finish
			pBMScreen := Gdip_BitmapFromScreen(windowX+30 "|" windowY+offsetY+180 "|30|400")
			if (Gdip_ImageSearch(pBMScreen, pBMLog, , , , , , 50) = 1) { ; end of quest log
				Gdip_DisposeImage(pBMLog), Gdip_DisposeImage(pBMScreen)
				break
			}
			Gdip_DisposeImage(pBMLog), pBMLog := Gdip_CloneBitmap(pBMScreen), Gdip_DisposeImage(pBMScreen)
		}
	}
	Sleep 500

	if(Qfound[1]=0){
		;locate exact bottom of quest title bar coordinates
		;titlebar = 30 pixels high
		;quest objective bar spacing = 10 pixels
		;quest objective bar height = 40 pixels
		GetRobloxClientPos(hwnd)
		MouseMove windowX+350, windowY+offsetY+100
		xi := windowX
		yi := windowY+Qfound[3]
		ww := windowX+306
		wh := windowY+windowHeight
		fileName:="questbargap.png"
		if DirExist(A_WorkingDir "\nm_image_assets")
		{
			try result := ImageSearch(&FoundX, &FoundY, xi, yi, ww, wh, "*5 " A_WorkingDir "\nm_image_assets\" fileName)
			catch {
				nm_setStatus("Error", "Image file " filename " was not found in:`n" A_WorkingDir "\nm_image_assets\" fileName)
				Sleep 5000
				ProcessClose DllCall("GetCurrentProcessId")
			}
		} else {
			MsgBox "Folder location cannot be found:`n" A_WorkingDir "\nm_image_assets\"
		}
		RileyStart:=(result = 1) ? [0, FoundX-windowX, FoundY-windowY] : [1, 0, 0]
		;determine Quest name
		xi := windowX
		yi := windowY+RileyStart[3]-30
		ww := windowX+306
		wh := windowY+RileyStart[3]
		for key, value in RileyBee {
			filename:=(key . ".png")
			try
				result := ImageSearch(&FoundX, &FoundY, xi, yi, ww, wh, "*100 nm_image_assets\" fileName)
			catch
				result := 0
			if(result = 1) {
				RileyQuest:=key
				questSteps:=RileyBee[key].Length
				;make sure full quest is visible
				loop 5 {
					found:=0
					NextY:=windowY+RileyStart[3]
					loop questSteps {
						try
							result := ImageSearch(&FoundX, &FoundY, windowX+QuestBarInset, NextY, windowX+QuestBarInset+300, NextY+QuestBarGapSize, "*5 nm_image_assets\questbargap.png")
						catch
							result := 0
						if(result = 1) {
							NextY:=NextY+QuestBarSize
							found:=found+1
						} else {
							break
						}
					}
					if(found<questSteps) {
						MouseMove windowX+30, windowY+offsetY+225
						Sleep 50
						Send "{WheelDown 1}"
						Sleep 50
						RileyStart[3]-=150
						Sleep 500
					} else {
						break 2
					}
				}
				break
			}
		}
		;Update Riley quest progress in GUI
		;also set next steps
		QuestGatherField:="None"
		QuestGatherFieldSlot:=0
		QuestRedAnyField:=0
		RileyLadybugs:=0
		RileyScorpions:=0
		RileyAll:=0
		newLine:="|"
		rileyProgress:=""
		num:=RileyBee[RileyQuest].Length
		loop num {
			action:=RileyBee[RileyQuest][A_Index][2]
			where:=RileyBee[RileyQuest][A_Index][3]
			questbarColor := PixelGetColor(windowX+QuestBarInset+10, windowY+QuestBarSize*(RileyBee[RileyQuest][A_Index][1]-1)+RileyStart[3]+QuestBarGapSize+5)
			if((questbarColor=0xF46C55) || (questbarColor=0x6EFF60)) {
				RileyQuestComplete:=0
				completeness:="Incomplete"
				if(action="kill"){
					Riley%where%:=1
				}
				else if (action="collect" && QuestGatherField="none") {
					;red, blue, white, any
					if(where="red"){
						if(HiveBees>=35){
							where:="Pepper"
						} else if(HiveBees>=15){
							where:="Rose"
						} else if (HiveBees>=5) {
							where:="Strawberry"
						} else {
							where:="Mushroom"
						}
					} else if (where="blue") {
						if(HiveBees>=15){
							where:="Pine Tree"
						} else if (HiveBees>=5) {
							where:="Bamboo"
						} else {
							where:="Blue Flower"
						}
					} else if (where="white") {
						if (HiveBees>=10) {
							where:="Pineapple"
						} else if (HiveBees>=5) {
							where:="Spider"
						} else {
							where:="Sunflower"
						}
					} else if (where="any") {
						;where:=FieldName1
						where:="None"
						QuestRedAnyField:=1
					}
					QuestGatherField:=where
					QuestGatherFieldSlot:=RileyBee[RileyQuest][A_Index][1]
				}
				else if(action="get"){ ;Ant, RedBoost
					if(where="ant") {
						QuestAnt:=1
					}
					else if(where="RedBoost"){
						QuestRedBoost:=1
					}
				}
				else if(action="feed"){ ;Strawberries
					QuestFeed:=where
				}
			}
			;border color, white (titlebar), black (text)
			else if((questbarColor!=0x96C3DE) && (questbarColor!=0xE5F0F7) && (questbarColor!=0x1B2A35)) {
				completeness:="Complete"
			} else {
				completeness:="Unknown"
			}
			if(A_Index=1)
				rileyProgress:=(RileyQuest . newline . action . " " . (where = "None" ? "Any" : where) . ": " . completeness)
			else
				rileyProgress:=(rileyProgress . newline . action . " " . (where = "None" ? "Any" : where) . ": " . completeness)
		}
		IniWrite rileyProgress, "settings\nm_config.ini", "Quests", "RileyQuestProgress"
		MainGui["RileyQuestProgress"].Text := StrReplace(rileyProgress, "|", "`n")
		if(RileyLadybugs=0 && RileyScorpions=0 && RileyAll=0 && QuestGatherField="None" && QuestAnt=0 && QuestRedBoost=0 && QuestFeed="None" && QuestRedAnyField=0){
			RileyQuestComplete:=1
		} else { ;check if all doable things are done and everything else is on cooldown
			if(QuestGatherField!="None" || (QuestAnt && (nowUnix()-LastAntPass)<7200) || (RileyLadybugs && (nowUnix()-LastBugrunLadybugs)<floor(330*(1-(MonsterRespawnTime?MonsterRespawnTime:0)*0.01))) || (RileyScorpions && (nowUnix()-LastBugrunScorpions)<floor(1230*(1-(MonsterRespawnTime?MonsterRespawnTime:0)*0.01)))) { ;there is at least one thing no longer on cooldown
				RileyQuestComplete:=0
			} else {
				RileyQuestComplete:=2
			}
		}
	}
}
nm_RileyQuest(){
	global RileyQuestCheck, RileyQuestComplete, RileyQuest, RotateQuest, QuestGatherField, QuestAnt, QuestRedBoost, QuestFeed, LastBugrunLadybugs, LastBugrunRhinoBeetles, LastBugrunSpider, LastBugrunMantis, LastBugrunScorpions, LastBugrunWerewolf, MonsterRespawnTime, RileyLadybugs, RileyScorpions, TotalQuestsComplete, SessionQuestsComplete
	if(!RileyQuestCheck)
		return
	RotateQuest:="Riley"
	nm_RileyQuestProg()
	if(RileyQuestComplete=1) {
		nm_updateAction("Quest")
		nm_gotoQuestgiver("Riley")
		nm_RileyQuestProg()
		if(RileyQuestComplete!=1){
			nm_setStatus("Starting", "Riley Quest: " . RileyQuest)
			TotalQuestsComplete:=TotalQuestsComplete+1
			SessionQuestsComplete:=SessionQuestsComplete+1
			PostSubmacroMessage("StatMonitor", 0x5555, 5, 1)
			IniWrite TotalQuestsComplete, "settings\nm_config.ini", "Status", "TotalQuestsComplete"
			IniWrite SessionQuestsComplete, "settings\nm_config.ini", "Status", "SessionQuestsComplete"
		}
	}
	if(RileyQuestComplete!=1){
		if(QuestFeed!="none") {
			nm_updateAction("Quest")
			nm_feed(QuestFeed)
		}
		if(QuestAnt)
			nm_Collect()
		if(QuestRedBoost)
			nm_ToAnyBooster()
		if((RileyLadybugs && (nowUnix()-LastBugrunLadybugs)>floor(330*(1-(MonsterRespawnTime?MonsterRespawnTime:0)*0.01))) || (RileyScorpions && (nowUnix()-LastBugrunScorpions)>floor(1230*(1-(MonsterRespawnTime?MonsterRespawnTime:0)*0.01)))) {
			nm_Bugrun()
		}
		if nm_NightInterrupt()
			return
		nm_RileyQuestProg()
		if(RileyQuestComplete=1) {
			nm_gotoQuestgiver("Riley")
			nm_RileyQuestProg()
			if(!RileyQuestComplete){
				nm_setStatus("Starting", "Riley Quest: " . RileyQuest)
				TotalQuestsComplete:=TotalQuestsComplete+1
				SessionQuestsComplete:=SessionQuestsComplete+1
				PostSubmacroMessage("StatMonitor", 0x5555, 5, 1)
				IniWrite TotalQuestsComplete, "settings\nm_config.ini", "Status", "TotalQuestsComplete"
				IniWrite SessionQuestsComplete, "settings\nm_config.ini", "Status", "SessionQuestsComplete"
			}
		}
	}
}
nm_BuckoQuestProg(){
	global BuckoQuestCheck, BuckoBee, BuckoQuest, BuckoStart, HiveBees, FieldName1, LastAntPass, LastBlueBoost, BuckoRhinoBeetles, BuckoMantis
	global QuestGatherField:="None"
	global QuestGatherFieldSlot:=0
	global BuckoQuestComplete:=1
	global BuckoQuestProgress
	global QuestAnt:=0
	global QuestBlueBoost:=0
	global QuestFeed:="None"
	global QuestBarSize
	global QuestBarGapSize
	global QuestBarInset
	global state
	global MonsterRespawnTime, LastBugrunRhinoBeetles, LastBugrunMantis, bitmaps
	if(!BuckoQuestCheck)
		return
	nm_setShiftLock(0)
	nm_OpenMenu("questlog")

	hwnd := GetRobloxHWND()
	offsetY := GetYOffset(hwnd)
	;search for bucko quest
	Loop 70
	{
		Qfound:=nm_imgSearch("bucko.png",50,"quest")
		if (Qfound[1]=0) {
			if (A_Index > 1)
				Gdip_DisposeImage(pBMLog)
			break
		}

		Qfound:=nm_imgSearch("bucko2.png",50,"quest")
		if (Qfound[1]=0) {
			if (A_Index > 1)
				Gdip_DisposeImage(pBMLog)
			break
		}

		ActivateRoblox()
		switch A_Index
		{
			case 1:
			GetRobloxClientPos(hwnd)
			MouseMove windowX+30, windowY+offsetY+200, 5
			Loop 50 ; scroll all the way up
			{
				MouseMove windowX+30, windowY+offsetY+200, 5
				sendinput "{WheelUp}"
				Sleep 50
			}
			pBMLog := Gdip_BitmapFromScreen(windowX+30 "|" windowY+offsetY+180 "|30|400")

			default:
			GetRobloxClientPos(hwnd)
			MouseMove windowX+30, windowY+offsetY+200, 5
			sendinput "{WheelDown}"
			Sleep 500 ; wait for scroll to finish
			pBMScreen := Gdip_BitmapFromScreen(windowX+30 "|" windowY+offsetY+180 "|30|400")
			if (Gdip_ImageSearch(pBMScreen, pBMLog, , , , , , 50) = 1) { ; end of quest log
				Gdip_DisposeImage(pBMLog), Gdip_DisposeImage(pBMScreen)
				break
			}
			Gdip_DisposeImage(pBMLog), pBMLog := Gdip_CloneBitmap(pBMScreen), Gdip_DisposeImage(pBMScreen)
		}
	}
	Sleep 500

	if(Qfound[1]=0){
		;locate exact bottom of quest title bar coordinates
		;titlebar = 30 pixels high
		;quest objective bar spacing = 10 pixels
		;quest objective bar height = 40 pixels
		GetRobloxClientPos(hwnd)
		MouseMove windowX+350, windowY+offsetY+100
		xi := windowX
		yi := windowY+Qfound[3]
		ww := windowX+306
		wh := windowY+windowHeight
		fileName:="questbargap.png"
		if DirExist(A_WorkingDir "\nm_image_assets")
		{
			try result := ImageSearch(&FoundX, &FoundY, xi, yi, ww, wh, "*5 " A_WorkingDir "\nm_image_assets\" fileName)
			catch {
				nm_setStatus("Error", "Image file " filename " was not found in:`n" A_WorkingDir "\nm_image_assets\" fileName)
				Sleep 5000
				ProcessClose DllCall("GetCurrentProcessId")
			}
		} else {
			MsgBox "Folder location cannot be found:`n" A_WorkingDir "\nm_image_assets\"
		}
		BuckoStart:=(result = 1) ? [0, FoundX-windowX, FoundY-windowY] : [1, 0, 0]
		;determine Quest name
		xi := windowX
		yi := windowY+BuckoStart[3]-30
		ww := windowX+306
		wh := windowY+BuckoStart[3]
		for key, value in BuckoBee {
			filename:=(key . ".png")
			try
				result := ImageSearch(&FoundX, &FoundY, xi, yi, ww, wh, "*100 nm_image_assets\" fileName)
			catch
				result := 0
			if(result = 1) {
				BuckoQuest:=key
				questSteps:=BuckoBee[key].Length
				;make sure full quest is visible
				loop 5 {
					found:=0
					NextY:=windowY+BuckoStart[3]
					loop questSteps {
						try
							result := ImageSearch(&FoundX, &FoundY, windowX+QuestBarInset, NextY, windowX+QuestBarInset+300, NextY+QuestBarGapSize, "*5 nm_image_assets\questbargap.png")
						catch
							result := 0
						if(result = 1) {
							NextY:=NextY+QuestBarSize
							found:=found+1
						} else {
							break
						}
					}
					if(found<questSteps) {
						MouseMove windowX+30, windowY+offsetY+225
						Sleep 50
						Send "{WheelDown 1}"
						Sleep 50
						BuckoStart[3]-=150
						Sleep 500
					} else {
						break 2
					}
				}
				break
			}
		}
		;Update Bucko quest progress in GUI
		;also set next steps
		BuckoRhinoBeetles:=0
		BuckoMantis:=0
		QuestGatherField:="None"
		QuestGatherFieldSlot:=0
		QuestBlueAnyField:=0
		QuestAnt:=0
		newLine:="|"
		buckoProgress:=""
		num:=BuckoBee[BuckoQuest].Length
		loop num {
			action:=BuckoBee[BuckoQuest][A_Index][2]
			where:=BuckoBee[BuckoQuest][A_Index][3]
			questbarColor := PixelGetColor(windowX+QuestBarInset+10, windowY+QuestBarSize*(BuckoBee[BuckoQuest][A_Index][1]-1)+BuckoStart[3]+QuestBarGapSize+5)
			if((questbarColor=0xF46C55) || (questbarColor=0x6EFF60)) {
				BuckoQuestComplete:=0
				completeness:="Incomplete"
				if(action="kill"){
					Bucko%where%:=1
				}
				else if (action="collect" && QuestGatherField="none") {
					;red, blue, white, any
					if(where="red"){
						if(HiveBees>=35){
							where:="Pepper"
						} else if(HiveBees>=15){
							where:="Rose"
						} else if (HiveBees>=5) {
							where:="Strawberry"
						} else {
							where:="Mushroom"
						}
					} else if (where="blue") {
						if(HiveBees>=15){
							where:="Pine Tree"
						} else if (HiveBees>=5) {
							where:="Bamboo"
						} else {
							where:="Blue Flower"
						}
					} else if (where="white") {
						if (HiveBees>=10) {
							where:="Pineapple"
						} else if (HiveBees>=5) {
							where:="Spider"
						} else {
							where:="Sunflower"
						}
					} else if (where="any") {
						;where:=FieldName1
						where:="None"
						QuestBlueAnyField:=1
					}
					QuestGatherField:=where
					QuestGatherFieldSlot:=BuckoBee[BuckoQuest][A_Index][1]
				}
				else if(action="get"){ ;Ant, BlueBoost
					if(where="ant") {
						QuestAnt:=1
					}
					else if(where="BlueBoost"){
						QuestBlueBoost:=1
					}
				}
				else if(action="feed"){ ;Blueberries
					QuestFeed:=where
				}
			}
			;border color, white (titlebar), black (text)
			else if((questbarColor!=0x96C3DE) && (questbarColor!=0xE5F0F7) && (questbarColor!=0x1B2A35)) {
				completeness:="Complete"
			} else {
				completeness:="Unknown"
			}
			if(A_Index=1)
				buckoProgress:=(BuckoQuest . newline . action . " " . (where = "None" ? "Any" : where) . ": " . completeness)
			else
				buckoProgress:=(buckoProgress . newline . action . " " . (where = "None" ? "Any" : where) . ": " . completeness)
		}
		IniWrite buckoProgress, "settings\nm_config.ini", "Quests", "BuckoQuestProgress"
		MainGui["BuckoQuestProgress"].Text := StrReplace(buckoProgress, "|", "`n")
		if(BuckoRhinoBeetles=0 && BuckoMantis=0 && QuestGatherField="None" && QuestAnt=0 && QuestBlueBoost=0 && QuestFeed="None" && QuestBlueAnyField=0) {
				BuckoQuestComplete:=1
			} else { ;check if all doable things are done and everything else is on cooldown
				if(QuestGatherField!="None" || (QuestAnt && (nowUnix()-LastAntPass)<7200) || (BuckoRhinoBeetles && (nowUnix()-LastBugrunRhinoBeetles)<floor(330*(1-(MonsterRespawnTime?MonsterRespawnTime:0)*0.01))) || (BuckoMantis && (nowUnix()-LastBugrunMantis)<floor(1230*(1-(MonsterRespawnTime?MonsterRespawnTime:0)*0.01)))) { ;there is at least one thing no longer on cooldown
					BuckoQuestComplete:=0
				} else {
					BuckoQuestComplete:=2
				}
			}
	}
}
nm_BuckoQuest(){
	global BuckoQuestCheck, BuckoQuestComplete, BuckoQuest, RotateQuest, QuestGatherField, QuestAnt, QuestBlueBoost, QuestFeed, LastBugrunLadybugs, LastBugrunRhinoBeetles, LastBugrunSpider, LastBugrunMantis, LastBugrunScorpions, LastBugrunWerewolf, MonsterRespawnTime, BuckoRhinoBeetles, BuckoMantis, TotalQuestsComplete, SessionQuestsComplete
	if(!BuckoQuestCheck)
		return
	RotateQuest:="Bucko"
	nm_BuckoQuestProg()
	if(BuckoQuestComplete=1) {
		nm_updateAction("Quest")
		nm_gotoQuestgiver("Bucko")
		nm_BuckoQuestProg()
		if(BuckoQuestComplete!=1){
			nm_setStatus("Starting", "Bucko Quest: " . BuckoQuest)
			TotalQuestsComplete:=TotalQuestsComplete+1
			SessionQuestsComplete:=SessionQuestsComplete+1
			PostSubmacroMessage("StatMonitor", 0x5555, 5, 1)
			IniWrite TotalQuestsComplete, "settings\nm_config.ini", "Status", "TotalQuestsComplete"
			IniWrite SessionQuestsComplete, "settings\nm_config.ini", "Status", "SessionQuestsComplete"
		}
	}
	if(BuckoQuestComplete!=1){
		if(QuestFeed!="none") {
			nm_updateAction("Quest")
			nm_feed(QuestFeed)
		}
		if(QuestAnt)
			nm_Collect()
		if(QuestBlueBoost)
			nm_ToAnyBooster()
		if((BuckoRhinoBeetles && (nowUnix()-LastBugrunRhinoBeetles)>floor(330*(1-(MonsterRespawnTime?MonsterRespawnTime:0)*0.01))) || (BuckoMantis && (nowUnix()-LastBugrunMantis)>floor(1230*(1-(MonsterRespawnTime?MonsterRespawnTime:0)*0.01)))) {
			nm_Bugrun()
		}
		if nm_NightInterrupt()
			return
		nm_BuckoQuestProg()
		if(BuckoQuestComplete=1) {
			nm_gotoQuestgiver("Bucko")
			nm_BuckoQuestProg()
			if(!BuckoQuestComplete){
				nm_setStatus("Starting", "Bucko Quest: " . BuckoQuest)
				TotalQuestsComplete:=TotalQuestsComplete+1
				SessionQuestsComplete:=SessionQuestsComplete+1
				PostSubmacroMessage("StatMonitor", 0x5555, 5, 1)
				IniWrite TotalQuestsComplete, "settings\nm_config.ini", "Status", "TotalQuestsComplete"
				IniWrite SessionQuestsComplete, "settings\nm_config.ini", "Status", "SessionQuestsComplete"
			}
		}
	}
}
nm_BlackQuestProg(){
	global BlackQuestCheck, BlackBear, BlackQuest, BlackStart, HiveBees, FieldName1
	global QuestGatherField:="None"
	global QuestGatherFieldSlot:=0
	global BlackQuestComplete:=1
	global BlackQuestProgress
	global QuestBarSize
	global QuestBarGapSize
	global QuestBarInset
	global state, bitmaps
	if(!BlackQuestCheck)
		return
	nm_setShiftLock(0)
	nm_OpenMenu("questlog")

	hwnd := GetRobloxHWND()
	offsetY := GetYOffset(hwnd)
	;search for black quest
	Loop 70
	{
		Qfound:=nm_imgSearch("black_bear.png",50,"quest")
		if (Qfound[1]=0) {
			if (A_Index > 1)
				Gdip_DisposeImage(pBMLog)
			break
		}

		Qfound:=nm_imgSearch("black_bear2.png",50,"quest")
		if (Qfound[1]=0) {
			if (A_Index > 1)
				Gdip_DisposeImage(pBMLog)
			break
		}

		Qfound:=nm_imgSearch("black_bear3.png",50,"quest")
		if (Qfound[1]=0) {
			if (A_Index > 1)
				Gdip_DisposeImage(pBMLog)
			break
		}

		Qfound:=nm_imgSearch("black_bear4.png",50,"quest")
		if (Qfound[1]=0) {
			if (A_Index > 1)
				Gdip_DisposeImage(pBMLog)
			break
		}

		Qfound:=nm_imgSearch("black_bear5.png",50,"quest")
		if (Qfound[1]=0) {
			if (A_Index > 1)
				Gdip_DisposeImage(pBMLog)
			break
		}

		Qfound:=nm_imgSearch("black_bear6.png",50,"quest")
		if (Qfound[1]=0) {
			if (A_Index > 1)
				Gdip_DisposeImage(pBMLog)
			break
		}

		ActivateRoblox()
		switch A_Index
		{
			case 1:
			GetRobloxClientPos(hwnd)
			MouseMove windowX+30, windowY+offsetY+200, 5
			Loop 50 ; scroll all the way up
			{
				MouseMove windowX+30, windowY+offsetY+200, 5
				sendinput "{WheelUp}"
				Sleep 50
			}
			pBMLog := Gdip_BitmapFromScreen(windowX+30 "|" windowY+offsetY+180 "|30|400")

			default:
			GetRobloxClientPos(hwnd)
			MouseMove windowX+30, windowY+offsetY+200, 5
			sendinput "{WheelDown}"
			Sleep 500 ; wait for scroll to finish
			pBMScreen := Gdip_BitmapFromScreen(windowX+30 "|" windowY+offsetY+180 "|30|400")
			if (Gdip_ImageSearch(pBMScreen, pBMLog, , , , , , 50) = 1) { ; end of quest log
				Gdip_DisposeImage(pBMLog), Gdip_DisposeImage(pBMScreen)
				break
			}
			Gdip_DisposeImage(pBMLog), pBMLog := Gdip_CloneBitmap(pBMScreen), Gdip_DisposeImage(pBMScreen)
		}
	}
	Sleep 500

	if(Qfound[1]=0){
		;locate exact bottom of quest title bar coordinates
		;titlebar = 30 pixels high
		;quest objective bar spacing = 10 pixels
		;quest objective bar height = 40 pixels
		GetRobloxClientPos(hwnd)
		MouseMove windowX+350, windowY+offsetY+100
		xi := windowX
		yi := windowY+Qfound[3]
		ww := windowX+306
		wh := windowY+windowHeight
		fileName:="questbargap.png"
		if DirExist(A_WorkingDir "\nm_image_assets")
		{
			try result := ImageSearch(&FoundX, &FoundY, xi, yi, ww, wh, "*5 " A_WorkingDir "\nm_image_assets\" fileName)
			catch {
				nm_setStatus("Error", "Image file " filename " was not found in:`n" A_WorkingDir "\nm_image_assets\" fileName)
				Sleep 5000
				ProcessClose DllCall("GetCurrentProcessId")
			}
		} else {
			MsgBox "Folder location cannot be found:`n" A_WorkingDir "\nm_image_assets\"
		}
		BlackStart:=(result = 1) ? [0, FoundX-windowX, FoundY-windowY] : [1, 0, 0]
		;determine Quest name
		xi := windowX
		yi := windowY+BlackStart[3]-30
		ww := windowX+306
		wh := windowY+BlackStart[3]
		for key, value in BlackBear {
			filename:=(key . ".png")
			try
				result := ImageSearch(&FoundX, &FoundY, xi, yi, ww, wh, "*100 nm_image_assets\" fileName)
			catch
				result := 0
			if(result = 1) {
				BlackQuest:=key
				questSteps:=BlackBear[key].Length
				;make sure full quest is visible
				loop 5 {
					found:=0
					NextY:=windowY+BlackStart[3]
					loop questSteps {
						try
							result := ImageSearch(&FoundX, &FoundY, windowX+QuestBarInset, NextY, windowX+QuestBarInset+300, NextY+QuestBarGapSize, "*5 nm_image_assets\questbargap.png")
						catch
							result := 0
						if(result = 1) {
							NextY:=NextY+QuestBarSize
							found:=found+1
						} else {
							break
						}
					}
					if(found<questSteps) {
						MouseMove windowX+30, windowY+offsetY+225
						Sleep 50
						Send "{WheelDown 1}"
						Sleep 50
						BlackStart[3]-=150
						Sleep 500
					} else {
						break 2
					}
				}
				Break
			}
		}
		;Update Black quest progress in GUI
		;also set next steps
		QuestGatherField:="None"
		QuestGatherFieldSlot:=0
		QuestBlackAnyField:=0
		newLine:="|"
		blackProgress:=""
		num:=BlackBear[BlackQuest].Length
		loop num {
			action:=BlackBear[BlackQuest][A_Index][2]
			where:=BlackBear[BlackQuest][A_Index][3]
			questbarColor := PixelGetColor(windowX+QuestBarInset+10, windowY+QuestBarSize*(BlackBear[BlackQuest][A_Index][1]-1)+BlackStart[3]+QuestBarGapSize+5)
			if((questbarColor=0xF46C55) || (questbarColor=0x6EFF60)) {
				BlackQuestComplete:=0
				completeness:="Incomplete"
				;red, blue, white, any
				if(where="red"){
					if(HiveBees>=35){
						where:="Pepper"
					} else if(HiveBees>=15){
						where:="Rose"
					} else if (HiveBees>=5) {
						where:="Strawberry"
					} else {
						where:="Mushroom"
					}
				} else if (where="blue") {
					if(HiveBees>=15){
						where:="Pine Tree"
					} else if (HiveBees>=5) {
						where:="Bamboo"
					} else {
						where:="Blue Flower"
					}
				} else if (where="white") {
					if (HiveBees>=10) {
						where:="Pineapple"
					} else if (HiveBees>=5) {
						where:="Spider"
					} else {
						where:="Sunflower"
					}
				} else if (where="any") {
					;where:=FieldName1
					where:="None"
					QuestBlackAnyField:=1
				}
				if(QuestGatherField="None") {
					QuestGatherField:=where
					QuestGatherFieldSlot:=BlackBear[BlackQuest][A_Index][1]
				}
			}
			;border color, white (titlebar), black (text)
			else if((questbarColor!=0x96C3DE) && (questbarColor!=0xE5F0F7) && (questbarColor!=0x1B2A35)) {
				completeness:="Complete"
				if(action="kill"){
					Quest%where%:=0
				}
			} else {
				completeness:="Unknown"
			}
			if(A_Index=1)
				blackProgress:=(BlackQuest . newline . action . " " . (where = "None" ? "Any" : where) . ": " . completeness)
			else
				blackProgress:=(blackProgress . newline . action . " " . (where = "None" ? "Any" : where) . ": " . completeness)
		}
		IniWrite blackProgress, "settings\nm_config.ini", "Quests", "BlackQuestProgress"
		MainGui["BlackQuestProgress"].Text := StrReplace(blackProgress, "|", "`n")
		if(QuestGatherField="None" && QuestBlackAnyField=0) {
			BlackQuestComplete:=1
		}
	}
}
nm_BlackQuest(){
	global BlackQuestCheck, BlackQuestComplete, BlackQuest, LastBlackQuest, RotateQuest, QuestGatherField, TotalQuestsComplete, SessionQuestsComplete
	if(!BlackQuestCheck)
		return
	RotateQuest:="Black"
	nm_BlackQuestProg()
	if(BlackQuestComplete && (nowUnix()-LastBlackQuest)>3600) {
		nm_updateAction("Quest")
		nm_gotoQuestgiver("Black")
		nm_BlackQuestProg()
		if(!BlackQuestComplete){
			nm_setStatus("Starting", "Black Bear Quest: " . BlackQuest)
			TotalQuestsComplete:=TotalQuestsComplete+1
			SessionQuestsComplete:=SessionQuestsComplete+1
			PostSubmacroMessage("StatMonitor", 0x5555, 5, 1)
			IniWrite TotalQuestsComplete, "settings\nm_config.ini", "Status", "TotalQuestsComplete"
			IniWrite SessionQuestsComplete, "settings\nm_config.ini", "Status", "SessionQuestsComplete"
		}
		LastBlackQuest:=nowUnix()
		IniWrite LastBlackQuest, "settings\nm_config.ini", "Quests", "LastBlackQuest"
	}
}
nm_BrownQuestProg(){
	global BrownQuestCheck, BrownQuest, BrownStart, HiveBees, FieldName1
	global QuestGatherField:="None"
	global QuestGatherFieldSlot:=0
	global BrownQuestComplete:=1
	global BrownQuestProgress
	global QuestBarSize
	global QuestBarGapSize
	global QuestBarInset
	global state, bitmaps
	if(!BrownQuestCheck)
		return
	nm_setShiftLock(0)
	nm_OpenMenu("questlog")

	hwnd := GetRobloxHWND()
	offsetY := GetYOffset(hwnd)
	;2 scrolls
	Loop 3 {
		;search for brown quest
		; if possible, move quest to top half of screen, to ensure quest tasks not cut off
		aim := ["questbrown", "quest"]
		loop aim.Length
		{
			i := A_Index
			Loop 70
			{
				n := A_Index
				loop 5
				{
					Qfound:=nm_imgSearch("brown_bear" A_Index ".png",50,aim[i])
					if (Qfound[1]=0) {
						if (n > 1)
							Gdip_DisposeImage(pBMLog)
						break 3
					}
				}

				ActivateRoblox()
				switch A_Index
				{
					case 1:
					GetRobloxClientPos(hwnd)
					MouseMove windowX+30, windowY+offsetY+200, 5
					Loop 50 ; scroll all the way up
					{
						MouseMove windowX+30, windowY+offsetY+200, 5
						sendinput "{WheelUp}"
						Sleep 50
					}
					pBMLog := Gdip_BitmapFromScreen(windowX+30 "|" windowY+offsetY+180 "|30|400")

					default:
					GetRobloxClientPos(hwnd)
					MouseMove windowX+30, windowY+offsetY+200, 5
					sendinput "{WheelDown}"
					Sleep 500 ; wait for scroll to finish
					pBMScreen := Gdip_BitmapFromScreen(windowX+30 "|" windowY+offsetY+180 "|30|400")
					if (Gdip_ImageSearch(pBMScreen, pBMLog, , , , , , 50) = 1) { ; end of quest log
						Gdip_DisposeImage(pBMLog), Gdip_DisposeImage(pBMScreen)
						if i = 2
							break 2
						else
							continue 2 ; if not detected in top half, search rest
					}
					Gdip_DisposeImage(pBMLog), pBMLog := Gdip_CloneBitmap(pBMScreen), Gdip_DisposeImage(pBMScreen)
				}
			}
		}
		Sleep 500

		if(Qfound[1]=0){
			;locate exact bottom of quest title bar coordinates
			;titlebar = 30 pixels high
			;quest objective bar spacing = 10 pixels
			;quest objective bar height = 40 pixels
			GetRobloxClientPos(hwnd)
			MouseMove windowX+350, windowY+offsetY+100
			xi := windowX
			yi := windowY+Qfound[3]
			ww := windowX+306
			wh := windowY+windowHeight
			fileName:="questbargap.png"
			if DirExist(A_WorkingDir "\nm_image_assets\")
			{
				try result := ImageSearch(&FoundX, &FoundY, xi, yi, ww, wh, "*5 " A_WorkingDir "\nm_image_assets\" fileName)
				catch {
					nm_setStatus("Error", "Image file " filename " was not found in:`n" A_WorkingDir "\nm_image_assets\" fileName)
					Sleep 5000
					ProcessClose DllCall("GetCurrentProcessId")
				}
			} else {
				MsgBox "Folder location cannot be found:`n" A_WorkingDir "\nm_image_assets\"
			}
			BrownStart:=(result = 1) ? [0, FoundX-windowX, FoundY-windowY] : [1, 0, 0]
			;determine Quest objecives
			static objectiveList := Map("dandelion","Dand", "sunflower","Sunf", "mushroom","Mush", "blueflower","Bluf", "clover","Clove"
				, "strawberry","Straw", "spider","Spide", "bamboo","Bamb", "pineapple","Pinap", "stump","Stump"
				, "cactus","Cact", "pumpkin","Pump", "pinetree","Pine"
				, "rose","Rose", "mountaintop","Mount", "pepper","Pepp", "coconut","Coco"
				, "redpollen","Red", "bluepollen","Blue", "whitepollen","White")
			objectives := []

			GetRobloxClientPos(hwnd)
			while ((objectives.Length < 4) && (A_Index <= 5)) { ; maximum 4 objectives
				objectivePos := objectives.Length * QuestBarSize, objectiveSize := 0
				pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY+BrownStart[3]+QuestBarGapSize+objectivePos "|304|" QuestBarSize-QuestBarGapSize)

				if (Gdip_ImageSearch(pBMScreen, bitmaps["questbarinset"], , , , 6, , 5) = 1) {
					for size in [16,15,14,18,17] { ; in approximate order of probability
						if (Gdip_ImageSearch(pBMScreen, bitmaps["s" size "collect"], , 6, , , , 30) = 1) {
							objectiveSize := size
							break
						}
					}

					if (objectiveSize = 0)
						objectives.Push("unknown")
					else {
						for k in objectiveList {
							for v in objectives ; if objective already exists, cannot be duplicated
								if (k = v)
									continue 2
							if (bitmaps.Has("s" objectiveSize k) && (Gdip_ImageSearch(pBMScreen, bitmaps["s" objectiveSize k], , 6, , , , 30) = 1))
								objectives.Push(k)
						}
					}
				} else {
					;//todo: replace this with proper questlog endpoint detection (similar to inventory) to determine if quest is cut off or not, instead of next quest title (which may not exist)
					if ((Gdip_ImageSearch(pBMScreen, bitmaps["questbartitle"], , , , 6, , 5) = 1) || (Gdip_ImageSearch(pBMScreen, bitmaps["questbartitlebeesmas"], , , , 6, , 5) = 1)) {
						Gdip_DisposeImage(pBMScreen)
						break ; end of quest reached confirmed, since there is a quest below
					}

					;//todo: detect if scrollbar is already at end before scrolling, or how much has scrolled instead of fixed 150. every quest needs this, should be in rewrite
					Gdip_DisposeImage(pBMScreen)
					; scroll, but only if the questgiver name is in the lower part of the screen
					if (yi > (wh - (windowHeight//2))) {
						MouseMove windowX+30, windowY+offsetY+200, 5
						Sleep 50
						sendinput "{WheelDown 1}" ; to allow for tasks not on screen, if applicable
						Sleep 500 ; wait for scroll to finish
					}
					continue 2
				}

				Gdip_DisposeImage(pBMScreen)
			}
			break
		} else {
			return
		}
	}

	;Update Brown quest progress in GUI
	;also set next steps
	QuestGatherField:="None"
	QuestGatherFieldSlot:=0
	QuestGatherObjective:=""
	newLine:="|"
	brownProgress:=""
	BrownQuest:=(objectives.Length = 1) ? "Solo" : ""
	for i,obj in objectives {
		action:="Collect"
		; decide field (where)
		;//todo: make this into a function for use in other quest functions
		switch obj {
			case "redpollen":
			if(HiveBees>=35){
				where:="Pepper"
			} else if(HiveBees>=15){
				where:="Rose"
			} else if (HiveBees>=5) {
				where:="Strawberry"
			} else {
				where:="Mushroom"
			}

			case "bluepollen":
			if(HiveBees>=15){
				where:="Pine Tree"
			} else if (HiveBees>=5) {
				where:="Bamboo"
			} else {
				where:="Blue Flower"
			}

			case "whitepollen":
			if (HiveBees>=10) {
				where:="Pineapple"
			} else if (HiveBees>=5) {
				where:="Spider"
			} else {
				where:="Sunflower"
			}

			case "blueflower":
			where:="Blue Flower"

			case "pinetree":
			where:="Pine Tree"

			case "mountaintop":
			where:="Mountain Top"

			default:
			where:=StrTitle(obj) ; title case, capitalise first letter
		}

		questbarColor := PixelGetColor(windowX+QuestBarInset+10, windowY+QuestBarSize*(i-1)+BrownStart[3]+QuestBarGapSize+5)
		if((questbarColor=0xF46C55) || (questbarColor=0x6EFF60)) {
			BrownQuestComplete:=0
			completeness:="Incomplete"
			if(QuestGatherField="None" || InStr(QuestGatherObjective, "pollen")) { ; override colour pollen if there is an incomplete field objective
				QuestGatherField:=where
				QuestGatherFieldSlot:=i
				QuestGatherObjective:=obj
			}
		}
		;border color, white (titlebar), black (text)
		else if((questbarColor!=0x96C3DE) && (questbarColor!=0xE5F0F7) && (questbarColor!=0x1B2A35)) {
			completeness:="Complete"
		} else {
			completeness:="Unknown"
		}
		BrownQuest .= "-" . ((obj = "unknown") ? "Unknown" : objectiveList[obj])
		brownProgress .= newline . action . " " . where . ": " . completeness
	}
	brownProgress := (BrownQuest := LTrim(BrownQuest, "-")) . brownProgress

	IniWrite brownProgress, "settings\nm_config.ini", "Quests", "BrownQuestProgress"
	MainGui["BrownQuestProgress"].Text := StrReplace(brownProgress, "|", "`n")
	if(QuestGatherField="None") {
		BrownQuestComplete:=1
	}
}
nm_BrownQuest(){
	global BrownQuestCheck, BrownQuestComplete, BrownQuest, LastBrownQuest, RotateQuest, QuestGatherField, TotalQuestsComplete, SessionQuestsComplete
	if(!BrownQuestCheck)
		return
	RotateQuest:="Brown"
	nm_BrownQuestProg()
	if(BrownQuestComplete && (nowUnix()-LastBrownQuest)>3600) {
		nm_updateAction("Quest")
		nm_gotoQuestgiver("Brown")
		nm_BrownQuestProg()
		if(!BrownQuestComplete){
			nm_setStatus("Starting", "Brown Bear Quest: " . BrownQuest)
			TotalQuestsComplete:=TotalQuestsComplete+1
			SessionQuestsComplete:=SessionQuestsComplete+1
			PostSubmacroMessage("StatMonitor", 0x5555, 5, 1)
			IniWrite TotalQuestsComplete, "settings\nm_config.ini", "Status", "TotalQuestsComplete"
			IniWrite SessionQuestsComplete, "settings\nm_config.ini", "Status", "SessionQuestsComplete"
		}
		LastBrownQuest:=nowUnix()
		IniWrite LastBrownQuest, "settings\nm_config.ini", "Quests", "LastBrownQuest"
	}
}
nm_Feed(food){
	global bitmaps
	nm_setShiftLock(0)
	nm_Reset(0,0,0,1)
	nm_setStatus("Feeding", food)
	;feed
	nm_InventorySearch(food)
	hwnd := GetRobloxHWND()
	offsetY := GetYOffset(hwnd)
	Loop 10
	{
		GetRobloxClientPos(hwnd)
		pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY+offsetY+150 "|" (54*windowWidth)//100-50 "|" Max(480, windowHeight-offsetY-150))

		if (A_Index = 1)
		{
			; wait for red vignette effect to disappear
			Loop 40
			{
				if (Gdip_ImageSearch(pBMScreen, bitmaps["item"], , , , 6, , 2) = 1)
					break
				else
				{
					if (A_Index = 40)
					{
						Gdip_DisposeImage(pBMScreen)
						nm_setStatus("Missing", food)
						return 0
					}
					else
					{
						Sleep 50
						Gdip_DisposeImage(pBMScreen)
						pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY+offsetY+150 "|" (54*windowWidth)//100-50 "|" Max(480, windowHeight-offsetY-150))
					}
				}
			}
		}

		if ((Gdip_ImageSearch(pBMScreen, bitmaps[food], &pos, , , 306, , 10, , 5) != 1) || (Gdip_ImageSearch(pBMScreen, bitmaps["feed"], , (54*windowWidth)//100-300, , , , 2, , 2) = 1)) {
			Gdip_DisposeImage(pBMScreen)
			break
		}
		Gdip_DisposeImage(pBMScreen)

		MouseClickDrag "Left", windowX+30, windowY+SubStr(pos, InStr(pos, ",")+1)+190, windowX+windowWidth//2, windowY+41*windowHeight//100-10*(A_Index-1), 5
		Sleep 500
	}
	Loop 20 {
		Sleep 100
		pBMScreen := Gdip_BitmapFromScreen(windowX+(54*windowWidth)//100-300 "|" windowY+offsetY+(46*windowHeight)//100-59 "|250|100")
		if (Gdip_ImageSearch(pBMScreen, bitmaps["feed"], &pos, , , , , 2, , 2) = 1) {
			Gdip_DisposeImage(pBMScreen)
			MouseMove windowX+(54*windowWidth)//100-300+SubStr(pos, 1, InStr(pos, ",")-1)+140, windowY+offsetY+(46*windowHeight)//100-59+SubStr(pos, InStr(pos, ",")+1)+5 ; Number
			Sleep 100
			Click
			Sleep 100
			Send "{Text}100"
			Sleep 1000
			MouseMove windowX+(54*windowWidth)//100-300+SubStr(pos, 1, InStr(pos, ",")-1), windowY+offsetY+(46*windowHeight)//100-59+SubStr(pos, InStr(pos, ",")+1) ; Feed
			Sleep 100
			Click
			nm_setStatus("Completed", "Feed " food)
			break
		} else {
			Gdip_DisposeImage(pBMScreen)
			if (A_Index = 20) {
				MouseMove windowX+(54*windowWidth)//100-300+SubStr(pos, 1, InStr(pos, ",")-1), windowY+offsetY+(46*windowHeight)//100-59+SubStr(pos, InStr(pos, ",")+1)+64 ; Cancel
				Sleep 100
				Click
				nm_setStatus("Failed", "Feed " food)
			}
		}
	}
	MouseMove windowX+350, windowY+offsetY+100
	;close inventory
	nm_OpenMenu()
}
nm_bugDeathCheck(){
	global objective, TotalBugKills, SessionBugKills, LastBugrunLadybugs, LastBugrunRhinoBeetles, LastBugrunSpider, LastBugrunMantis, LastBugrunScorpions, LastBugrunWerewolf, BugDeathCheckLockout, BugrunLadybugsCheck, BugrunRhinoBeetlesCheck, BugrunMantisCheck, BugrunWerewolfCheck
	if(BugDeathCheckLockout && (nowUnix() - BugDeathCheckLockout)>20)
		BugDeathCheckLockout:=0
	if(BugDeathCheckLockout)
		return
	;ladybugs
	if(InStr(objective,"strawberry") || InStr(objective,"mushroom") || InStr(objective,"clover")) {
		searchRet := nm_imgSearch("ladybug.png",30,"lowright")
		If (searchRet[1] = 0) {
			BugDeathCheckLockout:=nowUnix()
			LastBugrunLadybugs:=nowUnix()
			IniWrite LastBugrunLadybugs, "settings\nm_config.ini", "Collect", "LastBugrunLadybugs"
			TotalBugKills:=TotalBugKills+1
			SessionBugKills:=SessionBugKills+1
			PostSubmacroMessage("StatMonitor", 0x5555, 3, 1)
			IniWrite TotalBugKills, "settings\nm_config.ini", "Status", "TotalBugKills"
			IniWrite SessionBugKills, "settings\nm_config.ini", "Status", "SessionBugKills"
		}
	}
	;rhino beetles
	else if(InStr(objective,"blue flower") || InStr(objective,"bamboo")) {
		searchRet := nm_imgSearch("rhino.png",30,"lowright")
		If (searchRet[1] = 0) {
			BugDeathCheckLockout:=nowUnix()
			LastBugrunRhinoBeetles:=nowUnix()
			IniWrite LastBugrunRhinoBeetles, "settings\nm_config.ini", "Collect", "LastBugrunRhinoBeetles"
			if(InStr(objective,"bamboo")) {
				TotalBugKills:=TotalBugKills+2
				SessionBugKills:=SessionBugKills+2
				PostSubmacroMessage("StatMonitor", 0x5555, 3, 2)
			} else {
				TotalBugKills:=TotalBugKills+1
				SessionBugKills:=SessionBugKills+1
				PostSubmacroMessage("StatMonitor", 0x5555, 3, 1)
			}
			IniWrite TotalBugKills, "settings\nm_config.ini", "Status", "TotalBugKills"
			IniWrite SessionBugKills, "settings\nm_config.ini", "Status", "SessionBugKills"
		}
	}
	;spider
	else if(InStr(objective,"spider")) {
		searchRet := nm_imgSearch("spider.png",30,"lowright")
		If (searchRet[1] = 0) {
			BugDeathCheckLockout:=nowUnix()
			LastBugrunSpider:=nowUnix()
			IniWrite LastBugrunSpider, "settings\nm_config.ini", "Collect", "LastBugrunSpider"
			TotalBugKills:=TotalBugKills+1
			SessionBugKills:=SessionBugKills+1
			PostSubmacroMessage("StatMonitor", 0x5555, 3, 1)
			IniWrite TotalBugKills, "settings\nm_config.ini", "Status", "TotalBugKills"
			IniWrite SessionBugKills, "settings\nm_config.ini", "Status", "SessionBugKills"
		}
	}
	;mantis/rhino beetle
	else if(InStr(objective,"pineapple")) {
		searchRet := nm_imgSearch("mantis.png",30,"lowright")
		If (searchRet[1] = 0) {
			BugDeathCheckLockout:=nowUnix()
			LastBugrunMantis:=nowUnix()
			IniWrite LastBugrunMantis, "settings\nm_config.ini", "Collect", "LastBugrunMantis"
			TotalBugKills:=TotalBugKills+1
			SessionBugKills:=SessionBugKills+1
			PostSubmacroMessage("StatMonitor", 0x5555, 3, 1)
			IniWrite TotalBugKills, "settings\nm_config.ini", "Status", "TotalBugKills"
			IniWrite SessionBugKills, "settings\nm_config.ini", "Status", "SessionBugKills"
		}
		searchRet := nm_imgSearch("rhino.png",30,"lowright")
		If (searchRet[1] = 0) {
			if(!BugrunMantisCheck)
				BugDeathCheckLockout:=nowUnix()
			LastBugrunRhinoBeetles:=nowUnix()
			IniWrite LastBugrunRhinoBeetles, "settings\nm_config.ini", "Collect", "LastBugrunRhinoBeetles"
			TotalBugKills:=TotalBugKills+1
			SessionBugKills:=SessionBugKills+1
			PostSubmacroMessage("StatMonitor", 0x5555, 3, 1)
			IniWrite TotalBugKills, "settings\nm_config.ini", "Status", "TotalBugKills"
			IniWrite SessionBugKills, "settings\nm_config.ini", "Status", "SessionBugKills"
		}
	}
	;mantis/werewolf
	else if(InStr(objective,"pine tree")) {
		searchRet := nm_imgSearch("mantis.png",30,"lowright")
		If (searchRet[1] = 0) {
			BugDeathCheckLockout:=nowUnix()
			LastBugrunMantis:=nowUnix()
			IniWrite LastBugrunMantis, "settings\nm_config.ini", "Collect", "LastBugrunMantis"
			TotalBugKills:=TotalBugKills+2
			SessionBugKills:=SessionBugKills+2
			PostSubmacroMessage("StatMonitor", 0x5555, 3, 2)
			IniWrite TotalBugKills, "settings\nm_config.ini", "Status", "TotalBugKills"
			IniWrite SessionBugKills, "settings\nm_config.ini", "Status", "SessionBugKills"
		}
		searchRet := nm_imgSearch("werewolf.png",30,"lowright")
		If (searchRet[1] = 0) {
			BugDeathCheckLockout:=nowUnix()
			LastBugrunWerewolf:=nowUnix()
			IniWrite LastBugrunWerewolf, "settings\nm_config.ini", "Collect", "LastBugrunWerewolf"
			TotalBugKills:=TotalBugKills+1
			SessionBugKills:=SessionBugKills+1
			PostSubmacroMessage("StatMonitor", 0x5555, 3, 1)
			IniWrite TotalBugKills, "settings\nm_config.ini", "Status", "TotalBugKills"
			IniWrite SessionBugKills, "settings\nm_config.ini", "Status", "SessionBugKills"
		}
	}
	;werewolf
	else if(InStr(objective,"pumpkin") || InStr(objective,"cactus")) {
		searchRet := nm_imgSearch("werewolf.png",30,"lowright")
		If (searchRet[1] = 0) {
			BugDeathCheckLockout:=nowUnix()
			LastBugrunWerewolf:=nowUnix()
			IniWrite LastBugrunWerewolf, "settings\nm_config.ini", "Collect", "LastBugrunWerewolf"
			TotalBugKills:=TotalBugKills+1
			SessionBugKills:=SessionBugKills+1
			PostSubmacroMessage("StatMonitor", 0x5555, 3, 1)
			IniWrite TotalBugKills, "settings\nm_config.ini", "Status", "TotalBugKills"
			IniWrite SessionBugKills, "settings\nm_config.ini", "Status", "SessionBugKills"
		}
	}
	;scorpions
	else if(InStr(objective,"rose")) {
		searchRet := nm_imgSearch("scorpion.png",30,"lowright")
		If (searchRet[1] = 0) {
			BugDeathCheckLockout:=nowUnix()
			LastBugrunScorpions:=nowUnix()
			IniWrite LastBugrunScorpions, "settings\nm_config.ini", "Collect", "LastBugrunScorpions"
			TotalBugKills:=TotalBugKills+1
			SessionBugKills:=SessionBugKills+1
			PostSubmacroMessage("StatMonitor", 0x5555, 3, 1)
			IniWrite TotalBugKills, "settings\nm_config.ini", "Status", "TotalBugKills"
			IniWrite SessionBugKills, "settings\nm_config.ini", "Status", "SessionBugKills"
		}
	}
}
