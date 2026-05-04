#Requires AutoHotkey v2.0

global plantersConfigLoc := "features\All\Quests\nm_planters_config.ini"

;this is this features GUI lines-of-code used to calculate loading progress
PlantersFeatureProgressVolume := (PlantersFeature) ? 197 : 0
;this is the running total of all macro features included in the load progress metric
LoadingProgressVolume := (PlantersFeature) ? LoadingProgressVolume+PlantersFeatureProgressVolume : LoadingProgressVolume

nm_PlantersTab(*) {
	global
	TabCtrl.UseTab("Planters")
	MainGui.Add("Slider", "x364 y24 w130 h19 vPlanterMode Range0-2 AltSubmit Thick16 TickInterval1 Page1 Disabled", PlanterMode).OnEvent("Change", ba_PlanterSwitch)
	MainGui.Add("Text", "x366 y43 h20 cRed +Center +BackgroundTrans", "OFF")
	MainGui.Add("Text", "x410 y43 h20 c0xFF9200 +Center +BackgroundTrans", "MANUAL")
	MainGui.Add("Text", "x478 y43 h20 cGreen +Center +BackgroundTrans", "+")

	;Planters+
	hidden := ((PlanterMode = 2) ? "" : " Hidden")

	MainGui.Add("Text", "x23 y27 w40 h20 +BackgroundTrans vTextPresets" hidden, "Presets:")
	MainGui.Add("Text", "x+14 yp w40 vNPreset +Center +BackgroundTrans" hidden, NPreset)
	MainGui.Add("Button", "xp-12 yp-1 w12 h16 vNPLeft Disabled" hidden, "<").OnEvent("Click", nm_NectarPreset)
	MainGui.Add("Button", "xp+51 yp w12 h16 vNPRight Disabled" hidden, ">").OnEvent("Click", nm_NectarPreset)

	MainGui.Add("Text", "x18 y47 w80 h20 +center +BackgroundTrans vTextNP" hidden, "Nectar Priority")
	MainGui.Add("Text", "x104 y47 w47 h30 +center +BackgroundTrans vTextMin" hidden, "Min %")
	MainGui.Add("Text", "x10 y62 w137 h1 0x7 vTextLine1" hidden)
	MainGui.Add("Text", "x10 y70 +BackgroundTrans vText1" hidden, 1)
	MainGui.Add("Text", "x10 yp+20 +BackgroundTrans vText2" hidden, 2)
	MainGui.Add("Text", "x10 yp+20 +BackgroundTrans vText3" hidden, 3)
	MainGui.Add("Text", "x10 yp+20 +BackgroundTrans vText4" hidden, 4)
	MainGui.Add("Text", "x10 yp+20 +BackgroundTrans vText5" hidden, 5)

	MainGui.Add("Text", "x32 y70 w64 vN1priority +Center +BackgroundTrans Section" hidden, N1priority)
	MainGui.Add("Button", "xp-12 yp-1 w12 h16 vNP1Left Disabled" hidden, "<").OnEvent("Click", nm_NectarPriority)
	MainGui.Add("Button", "xp+75 yp w12 h16 vNP1Right Disabled" hidden, ">").OnEvent("Click", nm_NectarPriority)
	MainGui.Add("Text", "xs ys+20 w64 vN2priority +Center +BackgroundTrans" hidden, N2priority)
	MainGui.Add("Button", "xp-12 yp-1 w12 h16 vNP2Left Disabled" hidden, "<").OnEvent("Click", nm_NectarPriority)
	MainGui.Add("Button", "xp+75 yp w12 h16 vNP2Right Disabled" hidden, ">").OnEvent("Click", nm_NectarPriority)
	MainGui.Add("Text", "xs ys+40 w64 vN3priority +Center +BackgroundTrans" hidden, N3priority)
	MainGui.Add("Button", "xp-12 yp-1 w12 h16 vNP3Left Disabled" hidden, "<").OnEvent("Click", nm_NectarPriority)
	MainGui.Add("Button", "xp+75 yp w12 h16 vNP3Right Disabled" hidden, ">").OnEvent("Click", nm_NectarPriority)
	MainGui.Add("Text", "xs ys+60 w64 vN4priority +Center +BackgroundTrans" hidden, N4priority)
	MainGui.Add("Button", "xp-12 yp-1 w12 h16 vNP4Left Disabled" hidden, "<").OnEvent("Click", nm_NectarPriority)
	MainGui.Add("Button", "xp+75 yp w12 h16 vNP4Right Disabled" hidden, ">").OnEvent("Click", nm_NectarPriority)
	MainGui.Add("Text", "xs ys+80 w64 vN5priority +Center +BackgroundTrans" hidden, N5priority)
	MainGui.Add("Button", "xp-12 yp-1 w12 h16 vNP5Left Disabled" hidden, "<").OnEvent("Click", nm_NectarPriority)
	MainGui.Add("Button", "xp+75 yp w12 h16 vNP5Right Disabled" hidden, ">").OnEvent("Click", nm_NectarPriority)

	MainGui.Add("Text", "x113 y70 w12 vN1minPercent +Center Section" hidden, N1minPercent)
	MainGui.Add("UpDown", "xp+14 yp-1 h16 -16 Range1-9 vN1minPercentUpDown Disabled" hidden, N1minPercent//10).OnEvent("Change", nm_NectarMinPercent)
	MainGui.Add("Text", "xs ys+20 w12 vN2minPercent +Center" hidden, N2minPercent)
	MainGui.Add("UpDown", "xp+14 yp-1 h16 -16 Range1-9 vN2minPercentUpDown Disabled" hidden, N2minPercent//10).OnEvent("Change", nm_NectarMinPercent)
	MainGui.Add("Text", "xs ys+40 w12 vN3minPercent +Center" hidden, N3minPercent)
	MainGui.Add("UpDown", "xp+14 yp-1 h16 -16 Range1-9 vN3minPercentUpDown Disabled" hidden, N3minPercent//10).OnEvent("Change", nm_NectarMinPercent)
	MainGui.Add("Text", "xs ys+60 w12 vN4minPercent +Center" hidden, N4minPercent)
	MainGui.Add("UpDown", "xp+14 yp-1 h16 -16 Range1-9 vN4minPercentUpDown Disabled" hidden, N4minPercent//10).OnEvent("Change", nm_NectarMinPercent)
	MainGui.Add("Text", "xs ys+80 w12 vN5minPercent +Center" hidden, N5minPercent)
	MainGui.Add("UpDown", "xp+14 yp-1 h16 -16 Range1-9 vN5minPercentUpDown Disabled" hidden, N5minPercent//10).OnEvent("Change", nm_NectarMinPercent)
	SetLoadingProgress(floor((CurrentLoadProgress+49)/LoadingProgressVolume*100))

	MainGui.Add("Text", "x10 y171 w137 h1 0x7 vTextLine2" hidden)
	MainGui.Add("Text", "x5 y178 w70 h20 +right +BackgroundTrans vTextHarvest" hidden, "Harvest Every")
	MainGui.Add("CheckBox", "x103 y194 w40 vAutomaticHarvestInterval Disabled Checked" AutomaticHarvestInterval hidden, "Auto").OnEvent("Click", ba_AutoHarvestSwitch_)
	MainGui.Add("CheckBox", "x28 y194 vHarvestFullGrown Disabled Checked" HarvestFullGrown hidden, "Full Grown").OnEvent("Click", ba_HarvestFullGrownSwitch_)
	MainGui.Add("CheckBox", "x2 y211 w150 h13 vgotoPlanterField Disabled Checked" gotoPlanterField hidden, "Only Gather in Planter Field").OnEvent("Click", ba_gotoPlanterFieldSwitch_)
	MainGui.Add("CheckBox", "x2 y224 w150 h13 vgatherFieldSipping Disabled Checked" gatherFieldSipping hidden, "Gather Field Nectar Sipping").OnEvent("Click", ba_gatherFieldSippingSwitch_)
	MainGui.Add("Text", "x80 y178 w32 h20 cRed vAutoText +BackgroundTrans" (((PlanterMode = 2) && AutomaticHarvestInterval) ? "" : " Hidden"), "[Auto]")
	MainGui.Add("Text", "x80 y178 w32 h20 cRed vFullText +BackgroundTrans" (((PlanterMode = 2) && HarvestFullGrown) ? "" : " Hidden"), "[Full]")
	GuiCtrl := MainGui.Add("Edit", "x80 y174 w32 h20 limit2 Number vHarvestInterval Disabled" (((PlanterMode = 2) && !HarvestFullGrown && !AutomaticHarvestInterval) ? "" : " Hidden"), ValidateNumber(&HarvestInterval, 2))
	GuiCtrl.OnEvent("Change", ba_harvestInterval)
	MainGui.Add("Text", "x115 y178 w70 h20 +BackgroundTrans vTextHours" hidden, "Hours")
	MainGui.Add("Text", "x10 y209 w137 h1 0x7 vTextLine3" hidden)
	MainGui.Add("Button", "x261 y24 w96 h18 -Wrap vTimersButton Disabled" hidden, " Show Timers (" TimersHotkey ")").OnEvent("Click", ba_showPlanterTimers)
	MainGui.Add("Text", "x147 y28 w1 h182 0x7 vTextLine4" hidden)
	MainGui.Add("Text", "x147 y27 w108 h20 +Center +BackgroundTrans vTextAllowedPlanters" hidden, "Allowed Planters")
	MainGui.Add("Text", "x255 y43 w100 h20 +Center +BackgroundTrans vTextAllowedFields" hidden, "Allowed Fields")
	MainGui.Add("Text", "x147 y42 w108 h1 0x7 vTextLine5" hidden)

	(GuiCtrl := MainGui.Add("CheckBox", "x152 y45 vPlasticPlanterCheck Disabled Checked" PlasticPlanterCheck hidden, "Plastic")).Section := "Planters", GuiCtrl.OnEvent("Click", nm_saveConfig)
	(GuiCtrl := MainGui.Add("CheckBox", "xp yp+14 vCandyPlanterCheck Disabled Checked" CandyPlanterCheck hidden, "Candy")).Section := "Planters", GuiCtrl.OnEvent("Click", nm_saveConfig)
	(GuiCtrl := MainGui.Add("CheckBox", "xp yp+14 vBlueClayPlanterCheck Disabled Checked" BlueClayPlanterCheck hidden, "Blue Clay")).Section := "Planters", GuiCtrl.OnEvent("Click", nm_saveConfig)
	(GuiCtrl := MainGui.Add("CheckBox", "xp yp+14 vRedClayPlanterCheck Disabled Checked" RedClayPlanterCheck hidden, "Red Clay")).Section := "Planters", GuiCtrl.OnEvent("Click", nm_saveConfig)
	(GuiCtrl := MainGui.Add("CheckBox", "xp yp+14 vTackyPlanterCheck Disabled Checked" TackyPlanterCheck hidden, "Tacky")).Section := "Planters", GuiCtrl.OnEvent("Click", nm_saveConfig)
	(GuiCtrl := MainGui.Add("CheckBox", "xp yp+14 vPesticidePlanterCheck Disabled Checked" PesticidePlanterCheck hidden, "Pesticide")).Section := "Planters", GuiCtrl.OnEvent("Click", nm_saveConfig)
	(GuiCtrl := MainGui.Add("CheckBox", "xp yp+14 vHeatTreatedPlanterCheck Disabled Checked" HeatTreatedPlanterCheck hidden, "Heat-Treated")).Section := "Planters", GuiCtrl.OnEvent("Click", nm_saveConfig)
	(GuiCtrl := MainGui.Add("CheckBox", "xp yp+14 vHydroponicPlanterCheck Disabled Checked" HydroponicPlanterCheck hidden, "Hydroponic")).Section := "Planters", GuiCtrl.OnEvent("Click", nm_saveConfig)
	(GuiCtrl := MainGui.Add("CheckBox", "xp yp+14 vPetalPlanterCheck Disabled Checked" PetalPlanterCheck hidden, "Petal")).Section := "Planters", GuiCtrl.OnEvent("Click", nm_saveConfig)
	(GuiCtrl := MainGui.Add("CheckBox", "xp yp+14 w100 h13 vPlanterOfPlentyCheck Disabled Checked" PlanterOfPlentyCheck hidden, "Planter of Plenty")).Section := "Planters", GuiCtrl.OnEvent("Click", nm_saveConfig)
	(GuiCtrl := MainGui.Add("CheckBox", "xp yp+14 vPaperPlanterCheck Disabled Checked" PaperPlanterCheck hidden, "Paper")).Section := "Planters", GuiCtrl.OnEvent("Click", nm_saveConfig)
	(GuiCtrl := MainGui.Add("CheckBox", "xp yp+14 vTicketPlanterCheck Disabled Checked" TicketPlanterCheck hidden, "Ticket")).Section := "Planters", GuiCtrl.OnEvent("Click", nm_saveConfig)

	MainGui.Add("Text", "x155 y217 w80 h20 +BackgroundTrans vTextMax" hidden, "Max Planters")
	MainGui.Add("Text", "x222 y217 w24 vMaxAllowedPlantersText" hidden)
	MainGui.Add("UpDown", "vMaxAllowedPlanters Range0-3 Disabled" hidden, MaxAllowedPlanters).OnEvent("Change", ba_maxAllowedPlantersSwitch)
	MainGui.Add("Text", "x255 y28 w1 h204 0x7 vTextLine6" hidden)
	MainGui.Add("Text", "x255 y58 w240 h1 0x7 vTextLine7" hidden)

	MainGui.SetFont("s7")
	MainGui.Add("Text", "x250 y61 w100 h20 +Center +BackgroundTrans vTextZone1" hidden, "-- starting zone --")
	MainGui.Add("Text", "x250 y142 w100 h20 +Center +BackgroundTrans vTextZone2" hidden, "-- 5 bee zone --")
	MainGui.Add("Text", "x250 y195 w100 h20 +Center +BackgroundTrans vTextZone3" hidden, "-- 10 bee zone --")
	MainGui.Add("Text", "x375 y61 w100 h20 +Center +BackgroundTrans vTextZone4" hidden, "-- 15 bee zone --")
	MainGui.Add("Text", "x375 y128 w100 h20 +Center +BackgroundTrans vTextZone5" hidden, "-- 25 bee zone --")
	MainGui.Add("Text", "x375 y153 w100 h20 +Center +BackgroundTrans vTextZone6" hidden, "-- 35 bee zone --")

	MainGui.SetFont("s8 cDefault Norm", "Tahoma")
	(GuiCtrl := MainGui.Add("CheckBox", "x258 y72 vDandelionFieldCheck Disabled Checked" DandelionFieldCheck hidden, "Dandelion (COM)")).Section := "Planters", GuiCtrl.OnEvent("Click", nm_saveConfig)
	(GuiCtrl := MainGui.Add("CheckBox", "xp y86 vSunflowerFieldCheck Disabled Checked" SunflowerFieldCheck hidden, "Sunflower (SAT)")).Section := "Planters", GuiCtrl.OnEvent("Click", nm_saveConfig)
	(GuiCtrl := MainGui.Add("CheckBox", "xp y100 vMushroomFieldCheck Disabled Checked" MushroomFieldCheck hidden, "Mushroom (MOT)")).Section := "Planters", GuiCtrl.OnEvent("Click", nm_saveConfig)
	(GuiCtrl := MainGui.Add("CheckBox", "xp y114 vBlueFlowerFieldCheck Disabled Checked" BlueFlowerFieldCheck hidden, "Blue Flower (REF)")).Section := "Planters", GuiCtrl.OnEvent("Click", nm_saveConfig)
	(GuiCtrl := MainGui.Add("CheckBox", "xp y128 vCloverFieldCheck Disabled Checked" CloverFieldCheck hidden, "Clover (INV)")).Section := "Planters", GuiCtrl.OnEvent("Click", nm_saveConfig)
	(GuiCtrl := MainGui.Add("CheckBox", "xp y153 vSpiderFieldCheck Disabled Checked" SpiderFieldCheck hidden, "Spider (MOT)")).Section := "Planters", GuiCtrl.OnEvent("Click", nm_saveConfig)
	(GuiCtrl := MainGui.Add("CheckBox", "xp y167 vStrawberryFieldCheck Disabled Checked" StrawberryFieldCheck hidden, "Strawberry (REF)")).Section := "Planters", GuiCtrl.OnEvent("Click", nm_saveConfig)
	(GuiCtrl := MainGui.Add("CheckBox", "xp y181 vBambooFieldCheck Disabled Checked" BambooFieldCheck hidden, "Bamboo (COM)")).Section := "Planters", GuiCtrl.OnEvent("Click", nm_saveConfig)
	(GuiCtrl := MainGui.Add("CheckBox", "xp y206 w93 h13 vPineappleFieldCheck Disabled Checked" PineappleFieldCheck hidden, "Pineapple (SAT)")).Section := "Planters", GuiCtrl.OnEvent("Click", nm_saveConfig)
	(GuiCtrl := MainGui.Add("CheckBox", "xp y220 vStumpFieldCheck Disabled Checked" StumpFieldCheck hidden, "Stump (MOT)")).Section := "Planters", GuiCtrl.OnEvent("Click", nm_saveConfig)
	(GuiCtrl := MainGui.Add("CheckBox", "xp+122 y72 vCactusFieldCheck Disabled Checked" CactusFieldCheck hidden, "Cactus (INV)")).Section := "Planters", GuiCtrl.OnEvent("Click", nm_saveConfig)
	(GuiCtrl := MainGui.Add("CheckBox", "xp y86 vPumpkinFieldCheck Disabled Checked" PumpkinFieldCheck hidden, "Pumpkin (SAT)")).Section := "Planters", GuiCtrl.OnEvent("Click", nm_saveConfig)
	(GuiCtrl := MainGui.Add("CheckBox", "xp y100 vPineTreeFieldCheck Disabled Checked" PineTreeFieldCheck hidden, "Pine Tree (COM)")).Section := "Planters", GuiCtrl.OnEvent("Click", nm_saveConfig)
	(GuiCtrl := MainGui.Add("CheckBox", "xp y114 vRoseFieldCheck Disabled Checked" RoseFieldCheck hidden, "Rose (MOT)")).Section := "Planters", GuiCtrl.OnEvent("Click", nm_saveConfig)
	(GuiCtrl := MainGui.Add("CheckBox", "xp y139 vMountainTopFieldCheck Disabled Checked" MountainTopFieldCheck hidden, "Mountain Top (INV)")).Section := "Planters", GuiCtrl.OnEvent("Click", nm_saveConfig)
	(GuiCtrl := MainGui.Add("CheckBox", "xp y164 vCoconutFieldCheck Disabled Checked" CoconutFieldCheck hidden, "Coconut (REF)")).Section := "Planters", GuiCtrl.OnEvent("Click", nm_saveConfig)
	(GuiCtrl := MainGui.Add("CheckBox", "xp y178 vPepperFieldCheck Disabled Checked" PepperFieldCheck hidden, "Pepper (INV)")).Section := "Planters", GuiCtrl.OnEvent("Click", nm_saveConfig)

	MainGui.Add("Text", "x354 y196 w144 h36 0x7 vTextBox1" hidden)
	(GuiCtrl := MainGui.Add("CheckBox", "x358 y200 w138 h13 vConvertFullBagHarvest Disabled Checked" ConvertFullBagHarvest hidden, "Convert Full Bag Harvest")).Section := "Planters", GuiCtrl.OnEvent("Click", nm_saveConfig)
	(GuiCtrl := MainGui.Add("CheckBox", "x358 y216 w138 h13 vGatherPlanterLoot Disabled Checked" GatherPlanterLoot hidden, "Gather Planter Loot")).Section := "Planters", GuiCtrl.OnEvent("Click", nm_saveConfig)
	SetLoadingProgress(floor((CurrentLoadProgress+118)/LoadingProgressVolume*100))

	;Manual Planters
	MPlanterList := ["", "Plastic", "Candy", "Blue Clay", "Red Clay", "Tacky", "Pesticide", "Heat Treated", "Hydroponic", "Petal", "Planter of Plenty", "Paper", "Ticket"]
	(MFieldList := [""]).Push(fieldnamelist*)
	hidden := ((PlanterMode = 1) ? "" : " Hidden")

	; Headers
	MainGui.Add("Text", "x67 y23 w92 +BackgroundTrans +Center vMHeader1Text" hidden, "Cycle #1")
	MainGui.Add("Text", "xp+96 yp wp +BackgroundTrans +Center vMHeader2Text" hidden, "Cycle #2")
	MainGui.Add("Text", "xp+96 yp wp +BackgroundTrans +Center vMHeader3Text" hidden, "Cycle #3")

	Loop 3 {
		i := A_Index
		MainGui.Add("Text", ((i = 1) ? "x5 y40" : "xs ys+29") " +Center Section vMSlot" i "PlanterText" hidden, "S" i " Planters:")
		Loop 9 {
			hiddenPlanter := (((PlanterMode == 1) && (A_Index < 4)) ? "" : " Hidden")
			(GuiCtrl := MainGui.Add("DropDownList", "x" (x := (Mod(A_Index, 3) = 1) ? "s+62" : "p+50") " ys-3 w92 vMSlot" i "Cycle" A_Index "Planter Disabled" hiddenPlanter, MPlanterList)).OnEvent("Change", mp_SaveConfig)
			if MSlot%i%Cycle%A_Index%Planter
				GuiCtrl.Text := MSlot%i%Cycle%A_Index%Planter
			x := (x = "p+50") ? "p" : x
			(GuiCtrl := MainGui.Add("DropDownList", "x" x " ys+17 w92 vMSlot" i "Cycle" A_Index "Field Disabled" hiddenPlanter, MFieldList)).OnEvent("Change", mp_SaveConfig)
			if MSlot%i%Cycle%A_Index%Field
				GuiCtrl.Text := MSlot%i%Cycle%A_Index%Field
			MainGui.Add("CheckBox", "x" x " ys+41 w46 vMSlot" i "Cycle" A_Index "Glitter Disabled" hiddenPlanter " Checked" MSlot%i%Cycle%A_Index%Glitter, "Glitter").OnEvent("Click", mp_SaveConfig)
			x := (Mod(A_Index, 3) = 1) ? "s+108" : "p+46"
			(GuiCtrl := MainGui.Add("DropDownList", "x" x " ys+38 w46 vMSlot" i "Cycle" A_Index "AutoFull Disabled" hiddenPlanter, ["Full", "Timed"])).OnEvent("Change", mp_SaveConfig)
			GuiCtrl.Text := MSlot%i%Cycle%A_Index%AutoFull
		}
		MainGui.Add("Text", "xs ys+20 +Center Section vMSlot" i "FieldText" hidden, "S" i " Fields:")
		MainGui.Add("Text", "xs ys+20 +Center Section vMSlot" i "SettingsText" hidden, "S" i " Settings:")
		if (i < 3)
			MainGui.Add("Text", "xs ys+22 w350 h1 0x7 vMSlot" i "SeparatorLine" hidden)
	}

	; page movement
	MainGui.Add("Text", "x360 y63 vMPageNumberText" hidden, "Page " (MPageIndex := 1))
	MainGui.Add("Button", "xp+36 y63 w11 h14 vMPageLeft Disabled" hidden, "<").OnEvent("Click", mp_UpdatePage)
	MainGui.Add("Button", "xp+13 y63 w11 h14 vMPageRight Disabled" hidden, ">").OnEvent("Click", mp_UpdatePage)
	MainGui.Add("Text", "x360 y80 h1 w60 0x7 vMPagesSeparatorLine" hidden)


	MainGui.Add("Text", "x371 y82 +BackgroundTrans Section +center vMCurrentCycle" hidden, "Current`nCycle:")
	Loop 3 {
		MainGui.Add("Text", ((A_Index = 1) ? "x428 y63" : "x428 ys+16") " w200 +BackgroundTrans Section vMSlot" A_Index "CycleText" hidden, "Slot " A_Index ": ")
		MainGui.Add("Text", ((A_Index = 1) ? "x476 y63" : "x476 ys") " w200 +BackgroundTrans Section vMSlot" A_Index "CycleNo" hidden, PlanterManualCycle%A_Index%)
		MainGui.Add("Button", "x462 ys w11 h14 +Center vMSlot" A_Index "Left Disabled" hidden, "<").OnEvent("Click", mp_Slot%A_Index%ChangeLeft)
		MainGui.Add("Button", "x484 ys w11 h14 +Center vMSlot" A_Index "Right Disabled" hidden, ">").OnEvent("Click", mp_Slot%A_Index%ChangeRight)
	}

	MainGui.Add("Text", "x355 y23 h215 w1 0x7 vMSectionSeparatorLine" hidden)
	MainGui.Add("Text", "x355 y58 h1 w150 0x7 vMSliderSeparatorLine" hidden)
	SetLoadingProgress(floor((CurrentLoadProgress+170)/LoadingProgressVolume*100))

	; disable automatic harvest
	MainGui.Add("Text", "x355 y112 h1 w150 0x7 Section vMPuffModeSeparatorLine" hidden)
	MainGui.Add("CheckBox", "xs+5 ys+4 w150 h16 vMPuffModeA Section Disabled Checked" MPuffModeA hidden, "Disable Auto-Harvest").OnEvent("Click", mp_MPuffMode)
	MainGui.Add("Text", "xs+16 ys+16 vMPuffModeText " hidden, "Slots:")
	MainGui.Add("CheckBox", "xs+46 yp-1 w24 h16 vMPuffMode1 Disabled Checked" MPuffMode1 hidden, 1).OnEvent("Click", mp_SaveConfig)
	MainGui.Add("CheckBox", "xs+70 yp w24 h16 vMPuffMode2 Disabled Checked" MPuffMode2 hidden, 2).OnEvent("Click", mp_SaveConfig)
	MainGui.Add("CheckBox", "xs+95 yp w24 h16 vMPuffMode3 Disabled Checked" MPuffMode3 hidden, 3).OnEvent("Click", mp_SaveConfig)
	MainGui.Add("Button", "x484 yp+1 w11 h14 vMPuffModeHelp Disabled" hidden, "?").OnEvent("Click", nm_MPuffModeHelp)

	; gather in planter field and slots
	MainGui.Add("Text", "x355 y149 h1 w156 0x7 Section vMGatherSeparatorLine" hidden)
	MainGui.Add("CheckBox", "xs+5 ys+4 w150 h16 vMPlanterGatherA Section Disabled Checked" MPlanterGatherA hidden, "Gather in Planter Fields").OnEvent("Click", mp_MPlanterGatherSwitch_)
	MainGui.Add("Text", "xs+16 ys+16 vMPlanterGatherText " hidden, "Slots:")
	MainGui.Add("CheckBox", "xs+46 yp-1 w24 h16 vMPlanterGather1 Disabled Checked" MPlanterGather1 hidden, 1).OnEvent("Click", mp_SaveConfig)
	MainGui.Add("CheckBox", "xs+70 yp w24 h16 vMPlanterGather2 Disabled Checked" MPlanterGather2 hidden, 2).OnEvent("Click", mp_SaveConfig)
	MainGui.Add("CheckBox", "xs+95 yp w24 h16 vMPlanterGather3 Disabled Checked" MPlanterGather3 hidden, 3).OnEvent("Click", mp_SaveConfig)
	MainGui.Add("Button", "x484 yp+1 w11 h14 vMPlanterGatherHelp Disabled" hidden, "?").OnEvent("Click", nm_MPlanterGatherHelp)

	; harvest every interval
	MainGui.Add("Text", "x355 y186 h1 w150 0x7 Section vMHarvestSeparatorLine" hidden)
	MainGui.Add("CheckBox", "x360 ys+4 w138 h13 vMConvertFullBagHarvest Disabled Checked" MConvertFullBagHarvest hidden, "Convert Full Bag Harvest").OnEvent("Click", mp_SaveConfig)
	MainGui.Add("CheckBox", "x373 ys+19 w138 h13 vMGatherPlanterLoot Disabled Checked" MGatherPlanterLoot hidden, "Gather Planter Loot").OnEvent("Click", mp_SaveConfig)
	MainGui.Add("Text", "xs+6 ys+34 vMHarvestText Section" hidden, "Harvest every")
	MainGui.Add("Text", "xs+65 ys w48 vMHarvestInterval +Center +BackgroundTrans " hidden, MHarvestInterval)
	MainGui.Add("Button", "x471 ys w11 h14 vMHILeft Disabled" hidden, "<").OnEvent("Click", nm_MHarvestInterval)
	MainGui.Add("Button", "x484 ys w11 h14 vMHIRight Disabled" hidden, ">").OnEvent("Click", nm_MHarvestInterval)
	CurrentLoadProgress:=CurrentLoadProgress+PlantersFeatureProgressVolume
	SetLoadingProgress(floor(CurrentLoadProgress/LoadingProgressVolume*100))
}
ba_planterSwitch(*){
	global
	static PlantersPlusControls := ["N1Priority","N2Priority","N3Priority","N4Priority","N5Priority"
		,"N1MinPercent","N2MinPercent","N3MinPercent","N4MinPercent","N5MinPercent"
		,"N1MinPercentUpDown","N2MinPercentUpDown","N3MinPercentUpDown","N4MinPercentUpDown","N5MinPercentUpDown"
		,"DandelionFieldCheck","SunflowerFieldCheck","MushroomFieldCheck","BlueFlowerFieldCheck","CloverFieldCheck","SpiderFieldCheck","StrawberryFieldCheck","BambooFieldCheck"
		,"PineappleFieldCheck","StumpFieldCheck","PumpkinFieldCheck","PineTreeFieldCheck","RoseFieldCheck","MountainTopFieldCheck","CactusFieldCheck","CoconutFieldCheck","PepperFieldCheck"
		,"Text1","Text2","Text3","Text4","Text5"
		,"TextLine1","TextLine2","TextLine3","TextLine4","TextLine5","TextLine6","TextLine7"
		,"TextZone1","TextZone2","TextZone3","TextZone4","TextZone5","TextZone6"
		,"NPreset","TextPresets","TextNp","TextMin"
		,"PlasticPlanterCheck","CandyPlanterCheck","BlueClayPlanterCheck","RedClayPlanterCheck","TackyPlanterCheck","PesticidePlanterCheck"
		,"HeatTreatedPlanterCheck","HydroponicPlanterCheck","PetalPlanterCheck","PlanterOfPlentyCheck","PaperPlanterCheck","TicketPlanterCheck"
		,"TextHarvest","HarvestFullGrown","gotoPlanterField","gatherFieldSipping","TextHours","TextMax","MaxAllowedPlanters","MaxAllowedPlantersText"
		,"TextAllowedPlanters","TextAllowedFields","TimersButton","AutomaticHarvestInterval","ConvertFullBagHarvest","GatherPlanterLoot","TextBox1"
		,"NPLeft","NPRight","NP1Left","NP1Right","NP2Left","NP2Right","NP3Left","NP3Right","NP4Left","NP4Right","NP5Left","NP5Right"]
	, ManualPlantersControls := ["MHeader1Text","MHeader2Text","MHeader3Text"
		,"MSlot1PlanterText","MSlot1FieldText","MSlot1SettingsText","MSlot1SeparatorLine"
		,"MSlot2PlanterText","MSlot2FieldText","MSlot2SettingsText","MSlot2SeparatorLine"
		,"MSlot3PlanterText","MSlot3FieldText","MSlot3SettingsText"
		,"MSectionSeparatorLine","MSliderSeparatorLine"
		,"MSlot1CycleText","MSlot1CycleNo","MSlot1Left","MSlot1Right","MSlot2CycleText","MSlot2CycleNo","MSlot2Left","MSlot2Right","MSlot3CycleText","MSlot3CycleNo","MSlot3Left","MSlot3Right"
		,"MCurrentCycle","MHarvestText","MHarvestInterval","MHarvestSeparatorLine","MPageLeft","MPageNumberText","MPageRight", "MPagesSeparatorLine"
		,"MPuffModeSeparatorLine","MPuffModeHelp","MPuffModeText","MPuffModeA","MPuffMode1","MPuffMode2","MPuffMode3"
		,"MGatherSeparatorLine","MPlanterGatherHelp","MPlanterGatherText","MPlanterGatherA","MPlanterGather1","MPlanterGather2","MPlanterGather3","MConvertFullBagHarvest","MGatherPlanterLoot"
		,"MHILeft","MHIRight"]
	, ManualPlantersOptions := ["Planter","Field","Glitter","AutoFull"]
	local i, c, k, v

	PlanterMode := MainGui["PlanterMode"].Value
	MainGui["PlanterMode"].Enabled := 0

	for i,c in [0,1] ; hide first, then show
	{
		if (((i = 1) && (PlanterMode != 2)) || ((i = 2) && (PlanterMode = 2))) ; hide/show all planters+ controls
		{
			for k,v in PlantersPlusControls
				MainGui[v].Visible := c
			MainGui[HarvestFullGrown ? "FullText" : AutomaticHarvestInterval ? "AutoText" : "HarvestInterval"].Visible := c
		}

		if (((i = 1) && (PlanterMode != 1)) || ((i = 2) && (PlanterMode = 1))) ; hide/show all manual planters controls
		{
			for k,v in ManualPlantersControls
				MainGui[v].Visible := c
			Loop 3
			{
				i := A_Index
				for k,v in ManualPlantersOptions
					Loop 3
						MainGui["MSlot" A_Index "Cycle" (3 * (MPageIndex - 1) + i) v].Visible := c
			}
		}
	}

	; handle MaxAllowedPlanters
	MaxAllowedPlanters := MainGui["MaxAllowedPlanters"].Value
	if ((PlanterMode = 2) && (MaxAllowedPlanters = 0)) {
		MaxAllowedPlanters:=3
		IniWrite MaxAllowedPlanters, "settings\nm_config.ini", "Planters", "MaxAllowedPlanters"
		MainGui["MaxAllowedPlanters"].Value := 3
	}

	; handle PlanterTimers window
	if (PlanterMode = 0)
	{
		DetectHiddenWindows 1
		if WinExist("PlanterTimers.ahk ahk_class AutoHotkey")
			WinClose
		DetectHiddenWindows 0
	}

	IniWrite PlanterMode, "settings\nm_config.ini", "Planters", "PlanterMode"
	MainGui["PlanterMode"].Enabled := 1
}
ba_showPlanterTimers(*){
	global TimerGuiTransparency, TimerX, TimerY
	DetectHiddenWindows 1
	if WinExist("PlanterTimers.ahk ahk_class AutoHotkey")
		WinClose
	else
		Run '"' exe_path32 '" /script "' A_WorkingDir '\submacros\PlanterTimers.ahk"'
	DetectHiddenWindows 0
}
;Manual Planters
mp_UpdatePage(GuiCtrl?, *)
{
	Static ManualPlantersOptions := ["Planter","Field","Glitter","AutoFull"], LastPageIndex := 1

	Global MPageIndex += IsSet(GuiCtrl) ? ((GuiCtrl.Name = "MPageLeft") ? -1 : 1) : 0

	MainGui["MPageLeft"].Enabled := (MPageIndex != 1)
	MainGui["MPageRight"].Enabled := (MPageIndex != 3)

	If IsSet(GuiCtrl) {
		MainGui["MPageNumberText"].Text := "Page " MPageIndex

		Loop 3 {
			MainGui["MHeader" A_Index "Text"].Text := "Cycle #" ((MPageIndex - 1) * 3 + A_Index)
			i := A_Index
			for v in ManualPlantersOptions {
				Loop 3 {
					MainGui["MSlot" A_Index "Cycle" (3 * (LastPageIndex - 1) + i) v].Visible := 0
					MainGui["MSlot" A_Index "Cycle" (3 * (MPageIndex - 1) + i) v].Visible := 1
				}
			}
		}

		LastPageIndex := MPageIndex
	}
}

mp_UpdateControls() {
	global
	local i, j

	Loop 3 {
		i := A_Index
		Loop 9 {
			MainGui["MSlot" i "Cycle" A_Index "Planter"].Text := (MSlot%i%Cycle%A_Index%Planter ? MSlot%i%Cycle%A_Index%Planter : "")
			MainGui["MSlot" i "Cycle" A_Index "Field"].Text := (MSlot%i%Cycle%A_Index%Field ? MSlot%i%Cycle%A_Index%Field : "")
			MainGui["MSlot" i "Cycle" A_Index "Glitter"].Value := MSlot%i%Cycle%A_Index%Glitter
			MainGui["MSlot" i "Cycle" A_Index "AutoFull"].Text := MSlot%i%Cycle%A_Index%AutoFull
		}
	}

	Loop 3 {
		i := A_Index
		Loop 9 {
			j := A_Index - 1
			If (A_Index != 1)
				MainGui["MSlot" i "Cycle" A_Index "Planter"].Enabled := (MSlot%i%Cycle%j%Field ? 1 : 0)
			MainGui["MSlot" i "Cycle" A_Index "Field"].Enabled := (MSlot%i%Cycle%A_Index%Planter ? 1 : 0)
			MainGui["MSlot" i "Cycle" A_Index "Glitter"].Enabled := (MSlot%i%Cycle%A_Index%Field ? 1 : 0)
			MainGui["MSlot" i "Cycle" A_Index "AutoFull"].Enabled := (MSlot%i%Cycle%A_Index%Field ? 1 : 0)
		}
		j := A_Index - 1
		If (i > 1)
			MainGui["MSlot" i "Cycle1Planter"].Enabled := (MSlot%j%Cycle1Field ? 1 : 0)
	}

	MainGui["MPlanterGather1"].Enabled := (MPlanterGatherA ? 1 : 0)
	MainGui["MPlanterGather2"].Enabled := (MPlanterGatherA ? 1 : 0)
	MainGui["MPlanterGather3"].Enabled := (MPlanterGatherA ? 1 : 0)

	MainGui["MPuffMode1"].Enabled := (MPuffModeA ? 1 : 0)
	MainGui["MPuffMode2"].Enabled := (MPuffModeA ? 1 : 0)
	MainGui["MPuffMode3"].Enabled := (MPuffModeA ? 1 : 0)

	mp_UpdateCycles()

}

mp_SaveConfig(*) {
	global
	local i, j
	global MSlot1Cycle1Planter, MSlot1Cycle2Planter, MSlot1Cycle3Planter, MSlot1Cycle4Planter, MSlot1Cycle5Planter, MSlot1Cycle6Planter, MSlot1Cycle7Planter, MSlot1Cycle8Planter, MSlot1Cycle9Planter
	, MSlot1Cycle1Field, MSlot1Cycle2Field, MSlot1Cycle3Field, MSlot1Cycle4Field, MSlot1Cycle5Field, MSlot1Cycle6Field, MSlot1Cycle7Field, MSlot1Cycle8Field, MSlot1Cycle9Field
	, MSlot1Cycle1Glitter, MSlot1Cycle2Glitter, MSlot1Cycle3Glitter, MSlot1Cycle4Glitter, MSlot1Cycle5Glitter, MSlot1Cycle6Glitter, MSlot1Cycle7Glitter, MSlot1Cycle8Glitter, MSlot1Cycle9Glitter
	, MSlot1Cycle1AutoFull, MSlot1Cycle2AutoFull, MSlot1Cycle3AutoFull, MSlot1Cycle4AutoFull, MSlot1Cycle5AutoFull, MSlot1Cycle6AutoFull, MSlot1Cycle7AutoFull, MSlot1Cycle8AutoFull, MSlot1Cycle9AutoFull
	, MSlot2Cycle1Planter, MSlot2Cycle2Planter, MSlot2Cycle3Planter, MSlot2Cycle4Planter, MSlot2Cycle5Planter, MSlot2Cycle6Planter, MSlot2Cycle7Planter, MSlot2Cycle8Planter, MSlot2Cycle9Planter
	, MSlot2Cycle1Field, MSlot2Cycle2Field, MSlot2Cycle3Field, MSlot2Cycle4Field, MSlot2Cycle5Field, MSlot2Cycle6Field, MSlot2Cycle7Field, MSlot2Cycle8Field, MSlot2Cycle9Field
	, MSlot2Cycle1Glitter, MSlot2Cycle2Glitter, MSlot2Cycle3Glitter, MSlot2Cycle4Glitter, MSlot2Cycle5Glitter, MSlot2Cycle6Glitter, MSlot2Cycle7Glitter, MSlot2Cycle8Glitter, MSlot2Cycle9Glitter
	, MSlot2Cycle1AutoFull, MSlot2Cycle2AutoFull, MSlot2Cycle3AutoFull, MSlot2Cycle4AutoFull, MSlot2Cycle5AutoFull, MSlot2Cycle6AutoFull, MSlot2Cycle7AutoFull, MSlot2Cycle8AutoFull, MSlot2Cycle9AutoFull
	, MSlot3Cycle1Planter, MSlot3Cycle2Planter, MSlot3Cycle3Planter, MSlot3Cycle4Planter, MSlot3Cycle5Planter, MSlot3Cycle6Planter, MSlot3Cycle7Planter, MSlot3Cycle8Planter, MSlot3Cycle9Planter
	, MSlot3Cycle1Field, MSlot3Cycle2Field, MSlot3Cycle3Field, MSlot3Cycle4Field, MSlot3Cycle5Field, MSlot3Cycle6Field, MSlot3Cycle7Field, MSlot3Cycle8Field, MSlot3Cycle9Field
	, MSlot3Cycle1Glitter, MSlot3Cycle2Glitter, MSlot3Cycle3Glitter, MSlot3Cycle4Glitter, MSlot3Cycle5Glitter, MSlot3Cycle6Glitter, MSlot3Cycle7Glitter, MSlot3Cycle8Glitter, MSlot3Cycle9Glitter
	, MSlot3Cycle1AutoFull, MSlot3Cycle2AutoFull, MSlot3Cycle3AutoFull, MSlot3Cycle4AutoFull, MSlot3Cycle5AutoFull, MSlot3Cycle6AutoFull, MSlot3Cycle7AutoFull, MSlot3Cycle8AutoFull, MSlot3Cycle9AutoFull

	Loop 3 {
		i := A_Index
		Loop 9 {
			MSlot%i%Cycle%A_Index%Planter := MainGui["MSlot" i "Cycle" A_Index "Planter"].Text
			MSlot%i%Cycle%A_Index%Field := MainGui["MSlot" i "Cycle" A_Index "Field"].Text
			MSlot%i%Cycle%A_Index%Glitter := MainGui["MSlot" i "Cycle" A_Index "Glitter"].Value
			MSlot%i%Cycle%A_Index%AutoFull := MainGui["MSlot" i "Cycle" A_Index "AutoFull"].Text
		}
	}

	MPuffModeA := MainGui["MPuffModeA"].Value
	MPuffMode1 := MainGui["MPuffMode1"].Value
	MPuffMode2 := MainGui["MPuffMode2"].Value
	MPuffMode3 := MainGui["MPuffMode3"].Value

	MPlanterGatherA := MainGui["MPlanterGatherA"].Value
	MPlanterGather1 := MainGui["MPlanterGather1"].Value
	MPlanterGather2 := MainGui["MPlanterGather2"].Value
	MPlanterGather3 := MainGui["MPlanterGather3"].Value

	MConvertFullBagHarvest := MainGui["MConvertFullBagHarvest"].Value
	MGatherPlanterLoot := MainGui["MGatherPlanterLoot"].Value

	Loop 3 {
		i := A_Index
		Loop 9 {
			j := A_Index - 1
			If (A_Index != 1)
				MSlot%i%Cycle%A_Index%Planter := MSlot%i%Cycle%j%Field ? MSlot%i%Cycle%A_Index%Planter : ""
			MSlot%i%Cycle%A_Index%Field := MSlot%i%Cycle%A_Index%Planter ? MSlot%i%Cycle%A_Index%Field : ""
			MSlot%i%Cycle%A_Index%Glitter := MSlot%i%Cycle%A_Index%Field ? MSlot%i%Cycle%A_Index%Glitter : 0
			MSlot%i%Cycle%A_Index%AutoFull := MSlot%i%Cycle%A_Index%Field ? MSlot%i%Cycle%A_Index%AutoFull : "Timed"
		}
		j := A_Index + 1
		If (i < 3)
			MSlot%j%Cycle1Planter := MSlot%i%Cycle1Field ? MSlot%j%Cycle1Planter : ""
	}

	Loop 3 {
		i := A_Index
		Loop 9 {
			IniWrite MSlot%i%Cycle%A_Index%Planter, "settings\manual_planters.ini", "Slot " i, "MSlot" i "Cycle" A_Index "Planter"
			IniWrite MSlot%i%Cycle%A_Index%Field, "settings\manual_planters.ini", "Slot " i, "MSlot" i "Cycle" A_Index "Field"
			IniWrite MSlot%i%Cycle%A_Index%Glitter, "settings\manual_planters.ini", "Slot " i, "MSlot" i "Cycle" A_Index "Glitter"
			IniWrite MSlot%i%Cycle%A_Index%AutoFull, "settings\manual_planters.ini", "Slot " i, "MSlot" i "Cycle" A_Index "AutoFull"
		}
	}

	IniWrite MPuffModeA, "settings\nm_config.ini", "Planters", "MPuffModeA"
	IniWrite MPuffMode1, "settings\nm_config.ini", "Planters", "MPuffMode1"
	IniWrite MPuffMode2, "settings\nm_config.ini", "Planters", "MPuffMode2"
	IniWrite MPuffMode3, "settings\nm_config.ini", "Planters", "MPuffMode3"
	IniWrite MPlanterGatherA, "settings\nm_config.ini", "Planters", "MPlanterGatherA"
	IniWrite MPlanterGather1, "settings\nm_config.ini", "Planters", "MPlanterGather1"
	IniWrite MPlanterGather2, "settings\nm_config.ini", "Planters", "MPlanterGather2"
	IniWrite MPlanterGather3, "settings\nm_config.ini", "Planters", "MPlanterGather3"
	IniWrite MConvertFullBagHarvest, "settings\nm_config.ini", "Planters", "MConvertFullBagHarvest"
	IniWrite MGatherPlanterLoot, "settings\nm_config.ini", "Planters", "MGatherPlanterLoot"

	mp_UpdateControls()

}

mp_UpdateCycles() {
	global
	local i
	global MSlot1MaxCycle, MSlot2MaxCycle, MSlot3MaxCycle

	Loop 3 {
		i := A_Index, MSlot%A_Index%MaxCycle := 9
		Loop 9 {
			If (!MSlot%i%Cycle%A_Index%Field) {
				MSlot%i%MaxCycle := Max(A_Index - 1, 1)
				break
			}
		}

		PlanterManualCycle%i% := Min(MSlot%i%MaxCycle, PlanterManualCycle%i%)
		IniWrite PlanterManualCycle%i%, "settings\nm_config.ini", "Planters", "PlanterManualCycle" i

		MainGui["MSlot" i "Left"].Enabled := (PlanterManualCycle%i% != 1)
		MainGui["MSlot" i "Right"].Enabled := (PlanterManualCycle%i% < MSlot%i%MaxCycle)
		MainGui["MSlot" i "CycleNo"].Text := PlanterManualCycle%i%
	}
}

mp_Slot1ChangeLeft(*) {
	Global PlanterManualCycle1 -= 1
	mp_UpdateCycles()
}

mp_Slot1ChangeRight(*) {
	Global PlanterManualCycle1 += 1
	mp_UpdateCycles()
}

mp_Slot2ChangeLeft(*) {
	Global PlanterManualCycle2 -= 1
	mp_UpdateCycles()
}

mp_Slot2ChangeRight(*) {
	Global PlanterManualCycle2 += 1
	mp_UpdateCycles()
}

mp_Slot3ChangeLeft(*) {
	Global PlanterManualCycle3 -= 1
	mp_UpdateCycles()
}

mp_Slot3ChangeRight(*) {
	Global PlanterManualCycle3 += 1
	mp_UpdateCycles()
}
mp_MPuffMode(*){
	global
	MPuffModeA := MainGui["MPuffModeA"].Value
	if(MPuffModeA) {
		MainGui["MPuffModeA"].Value := 0
		if (MsgBox("
		(
		Enabling 'Disable auto harvest' will cause the macro NOT to harvest the planter when ready.

		Instead, it will 'hold' the full-grown planter until you harvest it either manually or through remote control.
		This option is designed for users trying to grow smoking planters for puffshroom runs, and allows you to check before harvesting.
		More information on how to use this feature is available in the 'Disable auto harvest' ? Help button.

		Do you wish to proceed with disabling auto harvest?
		)", "WARNING!", 1) = "Ok")
		{
			MainGui["MPuffModeA"].Value := 1
		} else {
			MainGui["MPuffModeA"].Value := 0
		}
	}
	mp_SaveConfig()
}
mp_MPlanterGatherSwitch_(*){
	global MPlanterGatherA
	MPlanterGatherA := MainGui["MPlanterGatherA"].Value
	if(MPlanterGatherA) {
		MainGui["MPlanterGatherA"].Value := 0
		if (MsgBox("
		(
		You have selected to "Gather only in planter field".

		Seleting this option will cause the macro to IGNORE the gathering fields specified in the Gather tab, and gather ONLY in planter fields for the slots you select using this option instead.

		This option can result in faster planter growth depending on your polar power, but will also result in less pollen/honey collection overall.
		More information on how to use this feature is available in the 'Gather in planter field' ? Help button.

		Do you wish to proceed with gathering in planter field?
		)", "WARNING!", 1) = "Ok")
		{
			MainGui["MPlanterGatherA"].Value := 1
		} else {
			MainGui["MPlanterGatherA"].Value := 0
		}
	}
	mp_SaveConfig()
}
nm_MPuffModeHelp(*){ ; disable auto harvest information for manual planters
	MsgBox "
	(
	DESCRIPTION:
	This option is designed for users trying to grow smoking planters for puffshrooms.
	Enabling it for a planter slot will cause the macro NOT to harvest the planter.
	Instead, it will 'hold' the planter until you harvest and clear it either manually or through remote control.
	This allows you to check whether it is smoking before harvesting.

	To use this feature:
	- Choose which slots to disable auto harvest for, depending on how many planters you wish to use for puffshrooms versus loot or nectar.
	- If you have set up a Discord webhook and would like a ping and screenshot of the planter when full grown, select Planter Progress in Natro Status tab > Change Discord Settings.
	- When ready, either:
	 - harvest manually in game, clear the planter in the Planter Timers pop-up (F5), and move to next cycle by pressing + in the planter tab
	 - or do nothing if the planter is smoking and you wish to keep holding it.
	- If you turn off 'Disable Auto Harvest' or switch to Planters Plus mode, the macro will harvest any planters marked holding or smoking.

	Advanced options:
	If you have set up remote control, after receiving a ping you can also optionally set your planter to smoking to help you keep track, or release from hold and plant next using these commands:
	- ?planter smoking [1][2][3]
	- ?planter harvest [1][2][3]
	See these planter commands and your planter status using ?planter

	See our Discord server for more details on how to set up and use webhook or remote control!
	)", "Disable auto harvest", 0x40000
}
nm_MPlanterGatherHelp(*){ ; gather in planter field information for manual planters
	MsgBox "
	(
	DESCRIPTION:
	Gather in planter field will enable you to gather only in the fields where planters are placed, instead of the fields selected in your gather tab.
	You can choose which planter slots you wish to gather in. If you choose more than one planter slot to gather in, the macro will rotate between each selected slot.
	If there are no slots available for planter gather (none selected, none with planters, or all 'holding' if 'disable auto harvest' mode is also selected), the macro will revert to gathering in the fields specified in the gather tab.
	)", "Gather in planter field", 0x40000
}
nm_MHarvestInterval(GuiCtrl, *){
	global MHarvestInterval
	static val := ["30 mins", "1 hour", "2 hours", "3 hours", "4 hours", "5 hours", "6 hours"], l := val.Length

	switch MHarvestInterval, 0
	{
		case "30 mins":
		i := 1
		case "1 hour":
		i := 2
		default:
		i := 3
		case "3 hours":
		i := 4
		case "4 hours":
		i := 5
		case "5 hours":
		i := 6
		case "6 hours":
		i := 7
	}

	MainGui["MHarvestInterval"].Text := MHarvestInterval := val[(GuiCtrl.Name = "MHIRight") ? (Mod(i, l) + 1) : (Mod(l + i - 2, l) + 1)]
	IniWrite MHarvestInterval, "settings\manual_planters.ini", "General", "MHarvestInterval"
}
;Planters~
nm_NectarPreset(GuiCtrl, *){
	global
	static val := ["Custom", "Blue", "Red", "White"], l := val.Length
	local i

	i := (NPreset = "Custom") ? 1 : (NPreset = "Blue") ? 2 : (NPreset = "Red") ? 3 : 4

	MainGui["NPreset"].Text := NPreset := val[(GuiCtrl.Name = "NPRight") ? (Mod(i, l) + 1) : (Mod(l + i - 2, l) + 1)]
	IniWrite NPreset, "settings\nm_config.ini", "Planters", "NPreset"

	switch NPreset, 0
	{
		case "Blue":
		MainGui["n1Priority"].Text := n1Priority := "Comforting"
		MainGui["n2Priority"].Text := n2Priority := "Motivating"
		MainGui["n3Priority"].Text := n3Priority := "Satisfying"
		MainGui["n4Priority"].Text := n4Priority := "Refreshing"
		MainGui["n5Priority"].Text := n5Priority := "Invigorating"
		nm_NectarPriority()
		MainGui["n1minPercent"].Text := 70, MainGui["n1minPercentUpDown"].Value := 7 ;COM
		MainGui["n2minPercent"].Text := 80, MainGui["n2minPercentUpDown"].Value := 8 ;MOT
		MainGui["n3minPercent"].Text := 80, MainGui["n3minPercentUpDown"].Value := 8 ;SAT
		MainGui["n4minPercent"].Text := 80, MainGui["n4minPercentUpDown"].Value := 8 ;REF
		MainGui["n5minPercent"].Text := 40, MainGui["n5minPercentUpDown"].Value := 4 ;INV
		;COM
		MainGui["DandelionFieldCheck"].Value := 1
		MainGui["BambooFieldCheck"].Value := 0
		MainGui["PineTreeFieldCheck"].Value := 1
		;MOT
		MainGui["MushroomFieldCheck"].Value := 0
		MainGui["SpiderFieldCheck"].Value := 1
		MainGui["RoseFieldCheck"].Value := 1
		MainGui["StumpFieldCheck"].Value := 0
		;SAT
		MainGui["SunflowerFieldCheck"].Value := 1
		MainGui["PineappleFieldCheck"].Value := 1
		MainGui["PumpkinFieldCheck"].Value := 0
		;REF
		MainGui["BlueFlowerFieldCheck"].Value := 1
		MainGui["StrawberryFieldCheck"].Value := 1
		MainGui["CoconutFieldCheck"].Value := 0
		;INV
		MainGui["CloverFieldCheck"].Value := 1
		MainGui["CactusFieldCheck"].Value := 1
		MainGui["MountainTopFieldCheck"].Value := 0
		MainGui["PepperFieldCheck"].Value := 1

		case "Red":
		MainGui["n1Priority"].Text := n1Priority := "Invigorating"
		MainGui["n2Priority"].Text := n2Priority := "Refreshing"
		MainGui["n3Priority"].Text := n3Priority := "Motivating"
		MainGui["n4Priority"].Text := n4Priority := "Satisfying"
		MainGui["n5Priority"].Text := n5Priority := "Comforting"
		nm_NectarPriority()
		MainGui["n1minPercent"].Text := 70, MainGui["n1minPercentUpDown"].Value := 7 ;INV
		MainGui["n2minPercent"].Text := 80, MainGui["n2minPercentUpDown"].Value := 8 ;REF
		MainGui["n3minPercent"].Text := 80, MainGui["n3minPercentUpDown"].Value := 8 ;MOT
		MainGui["n4minPercent"].Text := 80, MainGui["n4minPercentUpDown"].Value := 8 ;SAT
		MainGui["n5minPercent"].Text := 40, MainGui["n5minPercentUpDown"].Value := 4 ;COM
		;INV
		MainGui["CloverFieldCheck"].Value := 0
		MainGui["CactusFieldCheck"].Value := 1
		MainGui["MountainTopFieldCheck"].Value := 0
		MainGui["PepperFieldCheck"].Value := 1
		;REF
		MainGui["BlueFlowerFieldCheck"].Value := 1
		MainGui["StrawberryFieldCheck"].Value := 1
		MainGui["CoconutFieldCheck"].Value := 0
		;MOT
		MainGui["MushroomFieldCheck"].Value := 0
		MainGui["SpiderFieldCheck"].Value := 1
		MainGui["RoseFieldCheck"].Value := 1
		MainGui["StumpFieldCheck"].Value := 0
		;SAT
		MainGui["SunflowerFieldCheck"].Value := 1
		MainGui["PineappleFieldCheck"].Value := 1
		MainGui["PumpkinFieldCheck"].Value := 1
		;COM
		MainGui["DandelionFieldCheck"].Value := 1
		MainGui["BambooFieldCheck"].Value := 1
		MainGui["PineTreeFieldCheck"].Value := 1

		case "White":
		MainGui["n1Priority"].Text := n1Priority := "Satisfying"
		MainGui["n2Priority"].Text := n2Priority := "Motivating"
		MainGui["n3Priority"].Text := n3Priority := "Refreshing"
		MainGui["n4Priority"].Text := n4Priority := "Comforting"
		MainGui["n5Priority"].Text := n5Priority := "Invigorating"
		nm_NectarPriority()
		MainGui["n1minPercent"].Text := 70, MainGui["n1minPercentUpDown"].Value := 7 ;SAT
		MainGui["n2minPercent"].Text := 80, MainGui["n2minPercentUpDown"].Value := 8 ;MOT
		MainGui["n3minPercent"].Text := 80, MainGui["n3minPercentUpDown"].Value := 8 ;REF
		MainGui["n4minPercent"].Text := 80, MainGui["n4minPercentUpDown"].Value := 8 ;COM
		MainGui["n5minPercent"].Text := 40, MainGui["n5minPercentUpDown"].Value := 4 ;INV
		;SAT
		MainGui["SunflowerFieldCheck"].Value := 1
		MainGui["PineappleFieldCheck"].Value := 1
		MainGui["PumpkinFieldCheck"].Value := 0
		;MOT
		MainGui["MushroomFieldCheck"].Value := 0
		MainGui["SpiderFieldCheck"].Value := 1
		MainGui["RoseFieldCheck"].Value := 1
		MainGui["StumpFieldCheck"].Value := 0
		;REF
		MainGui["BlueFlowerFieldCheck"].Value := 1
		MainGui["StrawberryFieldCheck"].Value := 1
		MainGui["CoconutFieldCheck"].Value := 0
		;COM
		MainGui["DandelionFieldCheck"].Value := 1
		MainGui["BambooFieldCheck"].Value := 1
		MainGui["PineTreeFieldCheck"].Value := 1
		;INV
		MainGui["CloverFieldCheck"].Value := 1
		MainGui["CactusFieldCheck"].Value := 1
		MainGui["MountainTopFieldCheck"].Value := 0
		MainGui["PepperFieldCheck"].Value := 1
	}
	ba_saveConfig_()
}
nm_NectarPriority(GuiCtrl?, *){
	global
	static val := ["None", "Comforting", "Refreshing", "Satisfying", "Motivating", "Invigorating"]
	local i, l, index, n, j, arr := []

	switch IsSet(GuiCtrl) ? GuiCtrl.Name : ""
	{
		case "NP2Left", "NP2Right":
		index := 2
		case "NP3Left", "NP3Right":
		index := 3
		case "NP4Left", "NP4Right":
		index := 4
		case "NP5Left", "NP5Right":
		index := 5
		default:
		index := 1
	}

	for k,v in val
	{
		if (k > 1)
			Loop (index - 1)
				if (v = N%A_Index%priority)
					continue 2
		arr.Push(v)
	}
	l := arr.Length

	switch N%index%priority, 0
	{
		case arr[1]:
		i := 1
		case arr[2]:
		i := 2
		case arr[3]:
		i := 3
		case arr[4]:
		i := 4
		case arr[5]:
		i := 5
		default:
		i := l
	}

	MainGui["N" index "priority"].Text := N%index%priority := arr[IsSet(GuiCtrl) ? ((GuiCtrl.Name = "NP" index "Right") ? Mod(i, l) + 1 : Mod(l + i - 2, l) + 1) : i]

	Loop 5 {
		n := A_Index
		Loop (n - 1) {
			if (N%n%priority = N%A_Index%priority) {
				MainGui["N" n "priority"].Text := N%n%priority := "None"
				if IsSet(GuiCtrl)
					IniWrite N%n%priority, "settings\nm_config.ini", "Planters", "N" n "priority"
			}
		}
		if (N%n%priority = "None") {
			Loop (5 - n) {
				j := n + A_Index
				MainGui["NP" j "Left"].Enabled := 0
				MainGui["NP" j "Right"].Enabled := 0
				MainGui["N" j "MinPercentUpDown"].Enabled := 0
				if (N%j%priority != "None") {
					MainGui["N" j "priority"].Text := N%j%priority := "None"
					if IsSet(GuiCtrl)
						IniWrite N%j%priority, "settings\nm_config.ini", "Planters", "N" j "priority"
				}
			}
			break
		} else if (A_Index < 5) {
			j := n + 1
			MainGui["NP" j "Left"].Enabled := 1
			MainGui["NP" j "Right"].Enabled := 1
			MainGui["N" j "MinPercentUpDown"].Enabled := 1
		}
	}

	if IsSet(GuiCtrl) {
		IniWrite N%index%priority, "settings\nm_config.ini", "Planters", "N" index "priority"
		if (NPreset != "Custom") {
			MainGui["NPreset"].Text := (NPreset := "Custom")
			IniWrite NPreset, "settings\nm_config.ini", "Planters", "NPreset"
		}
	}
}
nm_NectarMinPercent(GuiCtrl, *){
	global
	local k
	MainGui[k := StrReplace(GuiCtrl.Name, "UpDown")].Text := %k% := GuiCtrl.Value * 10
	IniWrite %k%, "settings\nm_config.ini", "Planters", k
	if (NPreset != "Custom") {
		MainGui["NPreset"].Text := NPreset := "Custom"
		IniWrite NPreset, "settings\nm_config.ini", "Planters", "NPreset"
	}
}
ba_harvestInterval(*){
	global HarvestInterval
	HarvestInterval := MainGui["HarvestInterval"].Value
	if HarvestInterval is number
	{
		if HarvestInterval>0
		{
			HarvestInterval:=HarvestInterval
			ba_saveConfig_()
		} else {
			MainGui["HarvestInterval"].Value := HarvestInterval
		}
	} else {
		MainGui["HarvestInterval"].Value := HarvestInterval
	}
}
ba_HarvestFullGrownSwitch_(*){
	global HarvestFullGrown
	HarvestFullGrown := MainGui["HarvestFullGrown"].Value
	if(HarvestFullGrown) {
		MainGui["HarvestInterval"].Visible := 0
		MainGui["AutoText"].Visible := 0
		MainGui["FullText"].Visible := 1
		MainGui["AutomaticHarvestInterval"].Value := 0
	} else {
		MainGui["HarvestInterval"].Visible := 1
		MainGui["FullText"].Visible := 0
		MainGui["AutoText"].Visible := 0
	}
	ba_saveConfig_()
}
ba_AutoHarvestSwitch_(*){
	global AutomaticHarvestInterval
	AutomaticHarvestInterval := MainGui["AutomaticHarvestInterval"].Value
	if(AutomaticHarvestInterval) {
		MainGui["HarvestInterval"].Visible := 0
		MainGui["FullText"].Visible := 0
		MainGui["AutoText"].Visible := 1
		MainGui["HarvestFullGrown"].Value := 0
	} else {
		MainGui["HarvestInterval"].Visible := 1
		MainGui["FullText"].Visible := 0
		MainGui["AutoText"].Visible := 0
	}
	ba_saveConfig_()
}
ba_gotoPlanterFieldSwitch_(*){
	global gotoPlanterField
	GotoPlanterField := MainGui["GotoPlanterField"].Value
	if(GotoPlanterField){
		MainGui["GotoPlanterField"].Value := 0
		if (MsgBox("
		(
		You have selected to "Only Gather in Planter Field".

		I understand that by selecting this option will cause the macro to IGNORE the gathering fields specified in the Main tab.

		Enabling this option will make you gather in a field that contains a planter as selected by Planters+ instead.

		I understand that this option will result in gathering Nectar much faster but will also result in less pollen/honey collection overall.
		)", "WARNING!!", 1) = "Ok")
		{
			MainGui["GotoPlanterField"].Value := 1
		} else {
			MainGui["GotoPlanterField"].Value := 0
		}
	}
	ba_saveConfig_()
}
ba_gatherFieldSippingSwitch_(*){
	global GatherFieldSipping
	GatherFieldSipping := MainGui["GatherFieldSipping"].Value
	if(GatherFieldSipping){
		MainGui["GatherFieldSipping"].Value := 0
		if (MsgBox("
		(
		You have selected to "Gather Field Nectar Sipping".

		This option will force planters to always be placed in your current gathering field if you need the nectar type that field provides.
		This is done regardless of the allowed field selections.
		This will allow your bees to sip from the planter and greatly increase the amount of nectar gained.
		)", "INFORMATION", 1) = "Ok")
		{
			MainGui["GatherFieldSipping"].Value := 1
		} else {
			MainGui["GatherFieldSipping"].Value := 0
		}
	}
	ba_saveConfig_()
}
ba_maxAllowedPlantersSwitch(*){
	global
	MaxAllowedPlanters := MainGui["MaxAllowedPlanters"].Value
	if(MaxAllowedPlanters=0){
		MainGui["PlanterMode"].Value := 1
		ba_planterSwitch()
	} else {
		MainGui["PlanterMode"].Value := 2
	}
	ba_saveConfig_()
}
ba_saveConfig_(*){ ;//todo: needs replacing!
	global
	nPreset := MainGui["nPreset"].Text
	n1priority := MainGui["n1priority"].Text
	n2priority := MainGui["n2priority"].Text
	n3priority := MainGui["n3priority"].Text
	n4priority := MainGui["n4priority"].Text
	n5priority := MainGui["n5priority"].Text
	n1minPercent := MainGui["n1minPercent"].Text
	n2minPercent := MainGui["n2minPercent"].Text
	n3minPercent := MainGui["n3minPercent"].Text
	n4minPercent := MainGui["n4minPercent"].Text
	n5minPercent := MainGui["n5minPercent"].Text
	HarvestInterval := MainGui["HarvestInterval"].Value
	AutomaticHarvestInterval := MainGui["AutomaticHarvestInterval"].Value
	HarvestFullGrown := MainGui["HarvestFullGrown"].Value
	GotoPlanterField := MainGui["GotoPlanterField"].Value
	GatherFieldSipping := MainGui["GatherFieldSipping"].Value
	ConvertFullBagHarvest := MainGui["ConvertFullBagHarvest"].Value
	GatherPlanterLoot := MainGui["GatherPlanterLoot"].Value
	PlasticPlanterCheck := MainGui["PlasticPlanterCheck"].Value
	CandyPlanterCheck := MainGui["CandyPlanterCheck"].Value
	BlueClayPlanterCheck := MainGui["BlueClayPlanterCheck"].Value
	RedClayPlanterCheck := MainGui["RedClayPlanterCheck"].Value
	TackyPlanterCheck := MainGui["TackyPlanterCheck"].Value
	PesticidePlanterCheck := MainGui["PesticidePlanterCheck"].Value
	HeatTreatedPlanterCheck := MainGui["HeatTreatedPlanterCheck"].Value
	HydroponicPlanterCheck := MainGui["HydroponicPlanterCheck"].Value
	PetalPlanterCheck := MainGui["PetalPlanterCheck"].Value
	PaperPlanterCheck := MainGui["PaperPlanterCheck"].Value
	TicketPlanterCheck := MainGui["TicketPlanterCheck"].Value
	PlanterOfPlentyCheck := MainGui["PlanterOfPlentyCheck"].Value
	BambooFieldCheck := MainGui["BambooFieldCheck"].Value
	BlueFlowerFieldCheck := MainGui["BlueFlowerFieldCheck"].Value
	CactusFieldCheck := MainGui["CactusFieldCheck"].Value
	CloverFieldCheck := MainGui["CloverFieldCheck"].Value
	CoconutFieldCheck := MainGui["CoconutFieldCheck"].Value
	DandelionFieldCheck := MainGui["DandelionFieldCheck"].Value
	MountainTopFieldCheck := MainGui["MountainTopFieldCheck"].Value
	MushroomFieldCheck := MainGui["MushroomFieldCheck"].Value
	PepperFieldCheck := MainGui["PepperFieldCheck"].Value
	PineTreeFieldCheck := MainGui["PineTreeFieldCheck"].Value
	PineappleFieldCheck := MainGui["PineappleFieldCheck"].Value
	PumpkinFieldCheck := MainGui["PumpkinFieldCheck"].Value
	RoseFieldCheck := MainGui["RoseFieldCheck"].Value
	SpiderFieldCheck := MainGui["SpiderFieldCheck"].Value
	StrawberryFieldCheck := MainGui["StrawberryFieldCheck"].Value
	StumpFieldCheck := MainGui["StumpFieldCheck"].Value
	SunflowerFieldCheck := MainGui["SunflowerFieldCheck"].Value
	PlanterMode := MainGui["PlanterMode"].Value
	MaxAllowedPlanters := MainGui["MaxAllowedPlanters"].Value
	IniWrite nPreset, "settings\nm_config.ini", "Planters", "nPreset"
	IniWrite n1priority, "settings\nm_config.ini", "Planters", "n1priority"
	IniWrite n2priority, "settings\nm_config.ini", "Planters", "n2priority"
	IniWrite n3priority, "settings\nm_config.ini", "Planters", "n3priority"
	IniWrite n4priority, "settings\nm_config.ini", "Planters", "n4priority"
	IniWrite n5priority, "settings\nm_config.ini", "Planters", "n5priority"
	IniWrite n1minPercent, "settings\nm_config.ini", "Planters", "n1minPercent"
	IniWrite n2minPercent, "settings\nm_config.ini", "Planters", "n2minPercent"
	IniWrite n3minPercent, "settings\nm_config.ini", "Planters", "n3minPercent"
	IniWrite n4minPercent, "settings\nm_config.ini", "Planters", "n4minPercent"
	IniWrite n5minPercent, "settings\nm_config.ini", "Planters", "n5minPercent"
	IniWrite PlasticPlanterCheck, "settings\nm_config.ini", "Planters", "PlasticPlanterCheck"
	IniWrite CandyPlanterCheck, "settings\nm_config.ini", "Planters", "CandyPlanterCheck"
	IniWrite BlueClayPlanterCheck, "settings\nm_config.ini", "Planters", "BlueClayPlanterCheck"
	IniWrite RedClayPlanterCheck, "settings\nm_config.ini", "Planters", "RedClayPlanterCheck"
	IniWrite TackyPlanterCheck, "settings\nm_config.ini", "Planters", "TackyPlanterCheck"
	IniWrite PesticidePlanterCheck, "settings\nm_config.ini", "Planters", "PesticidePlanterCheck"
	IniWrite HeatTreatedPlanterCheck, "settings\nm_config.ini", "Planters", "HeatTreatedPlanterCheck"
	IniWrite HydroponicPlanterCheck, "settings\nm_config.ini", "Planters", "HydroponicPlanterCheck"
	IniWrite PetalPlanterCheck, "settings\nm_config.ini", "Planters", "PetalPlanterCheck"
	IniWrite PaperPlanterCheck, "settings\nm_config.ini", "Planters", "PaperPlanterCheck"
	IniWrite TicketPlanterCheck, "settings\nm_config.ini", "Planters", "TicketPlanterCheck"
	IniWrite PlanterOfPlentyCheck, "settings\nm_config.ini", "Planters", "PlanterOfPlentyCheck"
	IniWrite BambooFieldCheck, "settings\nm_config.ini", "Planters", "BambooFieldCheck"
	IniWrite BlueFlowerFieldCheck, "settings\nm_config.ini", "Planters", "BlueFlowerFieldCheck"
	IniWrite CactusFieldCheck, "settings\nm_config.ini", "Planters", "CactusFieldCheck"
	IniWrite CloverFieldCheck, "settings\nm_config.ini", "Planters", "CloverFieldCheck"
	IniWrite CoconutFieldCheck, "settings\nm_config.ini", "Planters", "CoconutFieldCheck"
	IniWrite DandelionFieldCheck, "settings\nm_config.ini", "Planters", "DandelionFieldCheck"
	IniWrite MountainTopFieldCheck, "settings\nm_config.ini", "Planters", "MountainTopFieldCheck"
	IniWrite MushroomFieldCheck, "settings\nm_config.ini", "Planters", "MushroomFieldCheck"
	IniWrite PepperFieldCheck, "settings\nm_config.ini", "Planters", "PepperFieldCheck"
	IniWrite PineTreeFieldCheck, "settings\nm_config.ini", "Planters", "PineTreeFieldCheck"
	IniWrite PineappleFieldCheck, "settings\nm_config.ini", "Planters", "PineappleFieldCheck"
	IniWrite PumpkinFieldCheck, "settings\nm_config.ini", "Planters", "PumpkinFieldCheck"
	IniWrite RoseFieldCheck, "settings\nm_config.ini", "Planters", "RoseFieldCheck"
	IniWrite SpiderFieldCheck, "settings\nm_config.ini", "Planters", "SpiderFieldCheck"
	IniWrite StrawberryFieldCheck, "settings\nm_config.ini", "Planters", "StrawberryFieldCheck"
	IniWrite StumpFieldCheck, "settings\nm_config.ini", "Planters", "StumpFieldCheck"
	IniWrite SunflowerFieldCheck, "settings\nm_config.ini", "Planters", "SunflowerFieldCheck"
	IniWrite PlanterMode, "settings\nm_config.ini", "Planters", "PlanterMode"
	IniWrite MaxAllowedPlanters, "settings\nm_config.ini", "Planters", "MaxAllowedPlanters"
	IniWrite HarvestInterval, "settings\nm_config.ini", "Planters", "HarvestInterval"
	IniWrite AutomaticHarvestInterval, "settings\nm_config.ini", "Planters", "AutomaticHarvestInterval"
	IniWrite HarvestFullGrown, "settings\nm_config.ini", "Planters", "HarvestFullGrown"
	IniWrite GotoPlanterField, "settings\nm_config.ini", "Planters", "GotoPlanterField"
	IniWrite GatherFieldSipping, "settings\nm_config.ini", "Planters", "GatherFieldSipping"
	IniWrite ConvertFullBagHarvest, "settings\nm_config.ini", "Planters", "ConvertFullBagHarvest"
	IniWrite GatherPlanterLoot, "settings\nm_config.ini", "Planters", "GatherPlanterLoot"
}
nm_importManualPlanters()
{
	global
	local ManualPlanters := Map()

	ManualPlanters["General"] := Map("MHarvestInterval", "2 hours")

	ManualPlanters["Slot 1"] := Map("MSlot1Cycle1Planter", ""
		, "MSlot1Cycle2Planter", ""
		, "MSlot1Cycle3Planter", ""
		, "MSlot1Cycle4Planter", ""
		, "MSlot1Cycle5Planter", ""
		, "MSlot1Cycle6Planter", ""
		, "MSlot1Cycle7Planter", ""
		, "MSlot1Cycle8Planter", ""
		, "MSlot1Cycle9Planter", ""
		, "MSlot1Cycle1Field", ""
		, "MSlot1Cycle2Field", ""
		, "MSlot1Cycle3Field", ""
		, "MSlot1Cycle4Field", ""
		, "MSlot1Cycle5Field", ""
		, "MSlot1Cycle6Field", ""
		, "MSlot1Cycle7Field", ""
		, "MSlot1Cycle8Field", ""
		, "MSlot1Cycle9Field", ""
		, "MSlot1Cycle1Glitter", 0
		, "MSlot1Cycle2Glitter", 0
		, "MSlot1Cycle3Glitter", 0
		, "MSlot1Cycle4Glitter", 0
		, "MSlot1Cycle5Glitter", 0
		, "MSlot1Cycle6Glitter", 0
		, "MSlot1Cycle7Glitter", 0
		, "MSlot1Cycle8Glitter", 0
		, "MSlot1Cycle9Glitter", 0
		, "MSlot1Cycle1AutoFull", "Timed"
		, "MSlot1Cycle2AutoFull", "Timed"
		, "MSlot1Cycle3AutoFull", "Timed"
		, "MSlot1Cycle4AutoFull", "Timed"
		, "MSlot1Cycle5AutoFull", "Timed"
		, "MSlot1Cycle6AutoFull", "Timed"
		, "MSlot1Cycle7AutoFull", "Timed"
		, "MSlot1Cycle8AutoFull", "Timed"
		, "MSlot1Cycle9AutoFull", "Timed")

	ManualPlanters["Slot 2"] := Map("MSlot2Cycle1Planter", ""
		, "MSlot2Cycle2Planter", ""
		, "MSlot2Cycle3Planter", ""
		, "MSlot2Cycle4Planter", ""
		, "MSlot2Cycle5Planter", ""
		, "MSlot2Cycle6Planter", ""
		, "MSlot2Cycle7Planter", ""
		, "MSlot2Cycle8Planter", ""
		, "MSlot2Cycle9Planter", ""
		, "MSlot2Cycle1Field", ""
		, "MSlot2Cycle2Field", ""
		, "MSlot2Cycle3Field", ""
		, "MSlot2Cycle4Field", ""
		, "MSlot2Cycle5Field", ""
		, "MSlot2Cycle6Field", ""
		, "MSlot2Cycle7Field", ""
		, "MSlot2Cycle8Field", ""
		, "MSlot2Cycle9Field", ""
		, "MSlot2Cycle1Glitter", 0
		, "MSlot2Cycle2Glitter", 0
		, "MSlot2Cycle3Glitter", 0
		, "MSlot2Cycle4Glitter", 0
		, "MSlot2Cycle5Glitter", 0
		, "MSlot2Cycle6Glitter", 0
		, "MSlot2Cycle7Glitter", 0
		, "MSlot2Cycle8Glitter", 0
		, "MSlot2Cycle9Glitter", 0
		, "MSlot2Cycle1AutoFull", "Timed"
		, "MSlot2Cycle2AutoFull", "Timed"
		, "MSlot2Cycle3AutoFull", "Timed"
		, "MSlot2Cycle4AutoFull", "Timed"
		, "MSlot2Cycle5AutoFull", "Timed"
		, "MSlot2Cycle6AutoFull", "Timed"
		, "MSlot2Cycle7AutoFull", "Timed"
		, "MSlot2Cycle8AutoFull", "Timed"
		, "MSlot2Cycle9AutoFull", "Timed")

	ManualPlanters["Slot 3"] := Map("MSlot3Cycle1Planter", ""
		, "MSlot3Cycle2Planter", ""
		, "MSlot3Cycle3Planter", ""
		, "MSlot3Cycle4Planter", ""
		, "MSlot3Cycle5Planter", ""
		, "MSlot3Cycle6Planter", ""
		, "MSlot3Cycle7Planter", ""
		, "MSlot3Cycle8Planter", ""
		, "MSlot3Cycle9Planter", ""
		, "MSlot3Cycle1Field", ""
		, "MSlot3Cycle2Field", ""
		, "MSlot3Cycle3Field", ""
		, "MSlot3Cycle4Field", ""
		, "MSlot3Cycle5Field", ""
		, "MSlot3Cycle6Field", ""
		, "MSlot3Cycle7Field", ""
		, "MSlot3Cycle8Field", ""
		, "MSlot3Cycle9Field", ""
		, "MSlot3Cycle1Glitter", 0
		, "MSlot3Cycle2Glitter", 0
		, "MSlot3Cycle3Glitter", 0
		, "MSlot3Cycle4Glitter", 0
		, "MSlot3Cycle5Glitter", 0
		, "MSlot3Cycle6Glitter", 0
		, "MSlot3Cycle7Glitter", 0
		, "MSlot3Cycle8Glitter", 0
		, "MSlot3Cycle9Glitter", 0
		, "MSlot3Cycle1AutoFull", "Timed"
		, "MSlot3Cycle2AutoFull", "Timed"
		, "MSlot3Cycle3AutoFull", "Timed"
		, "MSlot3Cycle4AutoFull", "Timed"
		, "MSlot3Cycle5AutoFull", "Timed"
		, "MSlot3Cycle6AutoFull", "Timed"
		, "MSlot3Cycle7AutoFull", "Timed"
		, "MSlot3Cycle8AutoFull", "Timed"
		, "MSlot3Cycle9AutoFull", "Timed")

	local k, v, i, j
	for k,v in ManualPlanters ; load the default values as globals, will be overwritten if a new value exists when reading
		for i,j in v
			%i% := j

	local inipath := A_WorkingDir "\settings\manual_planters.ini"

	if FileExist(inipath)
		nm_ReadIni(inipath)

	local ini := ""
	for k,v in ManualPlanters ; overwrite any existing .ini with updated one with all new keys and old values
	{
		ini .= "[" k "]`r`n"
		for i in v
			ini .= i "=" %i% "`r`n"
		ini .= "`r`n"
	}
	local file := FileOpen(inipath, "w-d")
	file.Write(ini), file.Close()
}

ba_planter(){
	global planternames
	global nectarnames
	global CurrentField
	global PlanterName1
	global PlanterName2
	global PlanterName3
	global PlanterField1
	global PlanterField2
	global PlanterField3
	global PlanterHarvestTime1
	global PlanterHarvestTime2
	global PlanterHarvestTime3
	global PlanterNectar1
	global PlanterNectar2
	global PlanterNectar3
	global PlanterEstPercent1
	global PlanterEstPercent2
	global PlanterEstPercent3
	global ComfortingFields, MotivatingFields, SatisfyingFields, RefreshingFields, InvigoratingFields
	global LastComfortingField, LastMotivatingField, LastSatisfyingField, LastRefreshingField, LastInvigoratingField
	global MaxAllowedPlanters
	global GotoPlanterField
	global GatherFieldSipping
	global LostPlanters
	global GatherFieldBoostedStart, LastGlitter
	global PlanterMode
	global HarvestInterval
	global HarvestFullGrown
	global n1priority
	global n2priority
	global n3priority
	global n4priority
	global n5priority
	global n1minPercent
	global n2minPercent
	global n3minPercent
	global n4minPercent
	global n5minPercent
	global PlasticPlanterCheck
	global CandyPlanterCheck
	global BlueClayPlanterCheck
	global RedClayPlanterCheck
	global TackyPlanterCheck
	global PesticidePlanterCheck
	global HeatTreatedPlanterCheck
	global HydroponicPlanterCheck
	global PetalPlanterCheck
	global PaperPlanterCheck
	global TicketPlanterCheck
	global PlanterOfPlentyCheck
	global BambooFieldCheck
	global BlueFlowerFieldCheck
	global CactusFieldCheck
	global CloverFieldCheck
	global CoconutFieldCheck
	global DandelionFieldCheck
	global MountainTopFieldCheck
	global MushroomFieldCheck
	global PepperFieldCheck
	global PineTreeFieldCheck
	global PineappleFieldCheck
	global PumpkinFieldCheck
	global RoseFieldCheck
	global SpiderFieldCheck
	global StrawberryFieldCheck
	global StumpFieldCheck
	global SunflowerFieldCheck
	global PlanterSS1, PlanterSS2, PlanterSS3
	global MPlanterHold1, MPlanterHold2, MPlanterHold3
	global MPlanterSmoking1, MPlanterSmoking2, MPlanterSmoking3
	Loop 3 {
		;reset manual planter disable auto harvest variables to 0
		if (PlanterMode = 2) {
			MPlanterHold%A_Index% := 0
			IniWrite MPlanterHold%A_Index%, "settings\nm_config.ini", "Planters", "MPlanterHold" A_Index
			MPlanterSmoking%A_Index% := 0
			IniWrite MPlanterSmoking%A_Index%, "settings\nm_config.ini", "Planters", "MPlanterSmoking" A_Index
		}
	}
	;skip over planters in this critical timeframe if AFB is active.  It helps avoid the loss of 4x field boost.
	global AFBrollingDice, AFBuseGlitter, AFBuseBooster, AutoFieldBoostActive, FieldLastBoosted, FieldLastBoostedBy, FieldBoostStacks, AutoFieldBoostRefresh, AFBFieldEnable, AFBDiceEnable, AFBGlitterEnable
	if(AutoFieldBoostActive && (FieldLastBoostedBy="dice") && (nowUnix()-FieldLastBoosted)>360 && (nowUnix()-FieldLastBoosted)<900) {
		return
	}
	if (PlanterMode != 2)
		return
	if (nm_NightInterrupt() || nm_MondoInterrupt() || nm_GatherBoostInterrupt())
		return

	; if enabled, take any/all planter screenshots before further planter actions
	If (PlanterSS1 || PlanterSS2 || PlanterSS3)
		nm_planterSS()

	nectars:=["n1", "n2", "n3", "n4", "n5"]
	;get current field nectar
	currentFieldNectar:="None"
	for i, val in nectarnames {
		for j, k in %val%Fields {
			if(CurrentField=k) {
				currentFieldNectar:=val
				break
			}
		}
	}
	Loop 2 {
		;re-optimize planters
		for key, value in nectars {
			;--- get nectar priority --
			varstring:=(value . "priority")
			currentNectar:=%varstring%
			if (currentNectar!="none") {
				estimatedNectarPercent:=0
				Loop 3 { ;3 max positions
					planterNectar:=PlanterNectar%A_Index%
					if (PlanterNectar=currentNectar) {
						estimatedNectarPercent:=estimatedNectarPercent+PlanterEstPercent%A_Index%
					}
				}
				nectarPercent:=ba_GetNectarPercent(currentnectar)
				;recover planters that are collecting same nectar as currentField AND are not placed in currentField
				if(currentNectar=currentFieldNectar && not HarvestFullGrown && GatherFieldSipping) {
					Loop 3 { ;3 max positions
						if(currentField!=PlanterField%A_Index% && currentFieldNectar=PlanterNectar%A_Index%) {
							temp1:=PlanterField%A_Index%
							PlanterHarvestTime%A_Index% := nowUnix()-1
							IniWrite PlanterHarvestTime%A_Index%, "settings\nm_config.ini", "Planters", "PlanterHarvestTime" A_Index
						}
					}
				}
				;recover planters that will overfill nectars
				if (AutomaticHarvestInterval && ((nectarPercent>99)||(nectarPercent>90 && (nectarPercent+estimatedNectarPercent)>110)||(nectarPercent+estimatedNectarPercent)>120)){
					Loop 3 { ;3 max positions
						planterNectar:=PlanterNectar%A_Index%
						if (PlanterNectar=currentNectar) {
							PlanterHarvestTime%A_Index% := nowUnix()-1
							IniWrite PlanterHarvestTime%A_Index%, "settings\nm_config.ini", "Planters", "PlanterHarvestTime" A_Index
						}
					}
				}
			} else {
				break
			}
		}
		;recover placed planters here
		Loop 3 {
			if((PlanterHarvestTime%A_Index% < nowUnix()) && (PlanterName%A_Index%!="None") && (PlanterField%A_Index%!="None")){
				i := A_Index
				Loop 5 {
					if (ba_harvestPlanter(i) = 1)
						break
					if (A_Index = 5) {
						nm_setStatus("Error", "Failed to harvest " PlanterName%i% " in " PlanterField%i% "!")
						;clear planter
						PlanterName%i% := "None"
						PlanterField%i% := "None"
						PlanterNectar%i% := "None"
						PlanterHarvestTime%i% := 2147483647
						PlanterEstPercent%i% := 0
						;write values to ini
						IniWrite "None", "settings\nm_config.ini", "Planters", "PlanterName" i
						IniWrite "None", "settings\nm_config.ini", "Planters", "PlanterField" i
						IniWrite "None", "settings\nm_config.ini", "Planters", "PlanterNectar" i
						IniWrite 2147483647, "settings\nm_config.ini", "Planters", "PlanterHarvestTime" i
						IniWrite 0, "settings\nm_config.ini", "Planters", "PlanterEstPercent" i
						break
					}
				}
			}
		}
	}
	;re-place planters here
	;--- determine max number of planters ---
	maxplanters:=0
	for key, value in planternames {
		maxplanters := maxplanters + %value%Check
	}
	maxplanters := min(MaxAllowedPlanters, maxplanters)
	if (maxplanters=0)
		return
	;determine number of placed planters
	plantersplaced:=0
	planterSlots:=[]
	Loop 3 {
		if(PlanterName%A_Index%="none")
			planterSlots.push(A_Index)
	}
	plantersplaced:=3-planterSlots.Length
	;temp1:=planterSlots[1]
	;temp2:=planterSlots[2]
	;temp3:=planterSlots[3]
	;temp4:=planterSlots.Length
	if(not planterSlots.Length)
		return
	;--- determine max number of nectars ---
	maxnectars:=0

	for key, value in nectars {
		if(%value%priority != "none")
			maxnectars:=maxnectars+1
	}
	if (maxnectars=0)
		return

	;//////// STAGE 1: Fill nectars to thresholds ///////////////
	;---- fill in priority order until all thresholds have been met
	for key, value in nectars {
		;--- get nectar priority --
		varstring:=(value . "priority")
		currentNectar:=%varstring%
		if (currentNectar = "None")
			continue
		nextPlanter:=[]
		;get maxNectarPlanters
		maxNectarPlanters:=0
		for ind, field in %currentNectar%Fields
		{
			tempfieldname := StrReplace(field, " ", "")
			if(%tempfieldname%FieldCheck)
				maxNectarPlanters:=maxNectarPlanters+1
		}
		;get nectarPlantersPlaced
		nectarPlantersPlaced:=0
		Loop 3{
			if(PlanterNectar%A_Index%=currentNectar)
				nectarPlantersPlaced:=nectarPlantersPlaced+1
		}
		if (currentNectar!="none") {
			planterSlots:=[]
			Loop 3 {
				if(PlanterName%A_Index%="none")
					planterSlots.push(A_Index)
			}
			for i, planterNum in planterSlots {
			;Loop 3 { ;3 max planters
			;temp1:=planterSlots[1]
			;temp2:=planterSlots[2]
			;temp3:=planterSlots[3]
			;temp4:=planterSlots.Length
				;--- determine max number of planters ---
				maxplanters:=0
				for x, y in planternames {
					maxplanters := maxplanters + %y%Check
				}

				maxplanters := min(MaxAllowedPlanters, maxplanters)
				;determine last and next fields
				if(currentNectar=currentFieldNectar && not GotoPlanterField && GatherFieldSipping){ ;always place planter in field you are collecting from
					lastnextfield:=ba_getlastfield(currentNectar)
					lastField:=lastNextField[1]
					nextField:=CurrentField
					maxNectarPlanters:=1
				} else {
					lastnextfield:=ba_getlastfield(currentNectar)
					lastField:=lastNextField[1]
					nextField:=lastNextField[2]
				}
				LostPlanters:=""
				nextPlanter:=ba_getNextPlanter(nextField)
				;there is an allowed field for this nectar and an available planter
				;temp1:=nextPlanter[1]
				if(nextField!="none" && nextPlanter[1]!="none" && plantersplaced<maxplanters && plantersplaced<MaxAllowedPlanters && nectarPlantersPlaced<maxNectarPlanters){
					;determine current nectar percent
					nectarPercent:=ba_GetNectarPercent(currentnectar)
					nectarMinPercent:=%value%minPercent
					estimatedNectarPercent:=0
					Loop 3 { ;3 max positions
						planterNectar:=PlanterNectar%A_Index%
						if (PlanterNectar=currentNectar) {
							estimatedNectarPercent:=estimatedNectarPercent+PlanterEstPercent%A_Index%
						}
					}
					;temp1:=nectarPercent + estimatedNectarPercent
					if(currentNectar=currentFieldNectar && estimatedNectarPercent>0){
						break
					}
					if (((nectarPercent + estimatedNectarPercent) < nectarMinPercent)){
						success:=-1, atField:=0
						while (success!=1 && nextField!="none" && nextPlanter[1]!="none") {
							success := ba_placePlanter(nextField, nextPlanter, planterNum, atField)
							switch success {
								case 1: ;planter placed successfully, break loop
								plantersplaced++
								nectarPlantersPlaced++
								ba_SavePlacedPlanter(nextField, nextPlanter, planterNum, currentNectar)
								break

								case 2: ;already a planter in this field, change field and try
								lastnextfield:=ba_getlastfield(currentNectar)
								lastField:=lastNextField[1]
								nextField:=lastNextField[2]
								nextPlanter:=ba_getNextPlanter(nextField)
								atField:=0
								LostPlanters:=""
								Last%currentnectar%Field := nextField
								IniWrite Last%currentnectar%Field, "settings\nm_config.ini", "Planters", "Last" currentnectar "Field"

								case 3: ;3 planters have been placed already, return
								nm_OpenMenu()
								return

								case 4: ;not in a field, try again
								atField:=0

								default: ;cannot find planter, try alternative planter in this field
								nextPlanter:=ba_getNextPlanter(nextField)
								if (nextPlanter[1]="none")
								{
									nm_endWalk()
									break
								}
								else
									atField:=1
							}
							if (A_Index = 10) {
								nm_setStatus("Error", "Failed to place planter in 10 tries!`nMaxAllowedPlanters has been reduced.")
								MaxAllowedPlanters:=max(0, MaxAllowedPlanters-1)
								MainGui["MaxAllowedPlanters"].Value := MaxAllowedPlanters
								IniWrite MaxAllowedPlanters, "settings\nm_config.ini", "Planters", "MaxAllowedPlanters"
								break
							}
						}
					} else {
						break
					}
				} else {
					break
				}
				;maximum planters have been placed. leave function
				if(plantersplaced=maxplanters || plantersplaced>=MaxAllowedPlanters) {
					nm_OpenMenu()
					return
				}
			}
		} else {
			break
		}
	}
	;//////// STAGE 2: All Nectars are at or will be above thresholds after harvested ///////////////
	;---- fill from lowest to highest nectar percent
	tempArray:=[]
	lowToHigh:=[] ;nectarname list
	sortstring:=""
	;create sort list
	for key, value in nectars {
		varstring:=(value . "priority")
		currentNectar:=%varstring%
		estimatedNectarPercent:=0
		Loop 3 {
			planterNectar:=PlanterNectar%A_Index%
			if (PlanterNectar=currentNectar) {
				estimatedNectarPercent:=estimatedNectarPercent+PlanterEstPercent%A_Index%
			}
		}
		if (currentNectar!="none") {
			nectarPercent:=ba_GetNectarPercent(currentnectar)+estimatedNectarPercent
			if(key>1)
				sortstring:=(sortstring . ";")
			sortstring:=(sortstring . nectarPercent . "," . value . "," . currentNectar)
		} else {
			break
		}
	}
	;sort list and re-extract nectars in low to high percent order
	sortstring := Sort(sortstring, "D;")
	tempArray := StrSplit(sortstring , ";")
	for i, val in tempArray {
		tempstring:=tempArray[A_Index]
		lowToHigh.InsertAt(A_Index, StrSplit(tempArray[A_Index], ","))
	}
	;temp1:=lowToHigh[1][3]
	;temp2:=lowToHigh[2][3]
	;temp3:=lowToHigh[3][3]
	;temp4:=lowToHigh[4][3]
	;temp5:=lowToHigh[5][3]
	for key, value in lowToHigh {
		currentNectar:=lowToHigh[key][3]
		if (currentNectar = "None")
			continue
		nextPlanter:=[]
		planterSlots:=[]
		;get maxNectarPlanters
		maxNectarPlanters:=0
		for ind, field in %currentNectar%Fields
		{
			tempfieldname := StrReplace(field, " ", "")
			if(%tempfieldname%FieldCheck)
				maxNectarPlanters:=maxNectarPlanters+1
		}
		;get nectarPlantersPlaced
		nectarPlantersPlaced:=0
		Loop 3{
			if(PlanterNectar%A_Index%=currentNectar)
				nectarPlantersPlaced:=nectarPlantersPlaced+1
		}
		Loop 3 {
			if(PlanterName%A_Index%="none")
				planterSlots.push(A_Index)
		}
		for i, planterNum in planterSlots {
		;Loop 3 {
			;--- determine max number of planters ---
			maxplanters:=0
			for x, y in planternames {
				maxplanters := maxplanters + %y%Check
			}
			maxplanters := min(MaxAllowedPlanters, maxplanters)
			;determine last and next fields
			if(currentNectar=currentFieldNectar && not GotoPlanterField && GatherFieldSipping){
				lastnextfield:=ba_getlastfield(currentNectar)
				lastField:=lastNextField[1]
				nextField:=CurrentField
				maxNectarPlanters:=1
			} else {
				lastnextfield:=ba_getlastfield(currentNectar)
				lastField:=lastNextField[1]
				nextField:=lastNextField[2]
			}
			LostPlanters:=""
			nextPlanter:=ba_getNextPlanter(nextField)
			;there is an allowed field for this nectar and an available planter
			if(nextField!="none" && nextPlanter[1]!="none" && plantersplaced<maxplanters && plantersplaced<MaxAllowedPlanters && nectarPlantersPlaced<maxNectarPlanters){
				;determine current nectar percent
				nectarPercent:=ba_GetNectarPercent(currentnectar)
				estimatedNectarPercent:=0
				Loop 3 {
					planterNectar:=PlanterNectar%A_Index%
					if (PlanterNectar=currentNectar) {
						estimatedNectarPercent:=estimatedNectarPercent+PlanterEstPercent%A_Index%
					}
				}
				;is the last element in the array
				if (key=lowToHigh.Length){
					success:=-1, atField:=0
					while (success!=1 && nextField!="none" && nextPlanter[1]!="none") {
						success := ba_placePlanter(nextField, nextPlanter, planterNum, atField)
						switch success {
							case 1: ;planter placed successfully, break loop
							plantersplaced++
							nectarPlantersPlaced++
							ba_SavePlacedPlanter(nextField, nextPlanter, planterNum, currentNectar)
							break

							case 2: ;already a planter in this field, change field and try
							lastnextfield:=ba_getlastfield(currentNectar)
							lastField:=lastNextField[1]
							nextField:=lastNextField[2]
							nextPlanter:=ba_getNextPlanter(nextField)
							atField:=0
							LostPlanters:=""
							Last%currentnectar%Field := nextField
							IniWrite Last%currentnectar%Field, "settings\nm_config.ini", "Planters", "Last" currentnectar "Field"

							case 3: ;3 planters have been placed already, return
							nm_OpenMenu()
							return

							case 4: ;not in a field, try again
							atField:=0

							default: ;cannot find planter, try alternative planter in this field
							nextPlanter:=ba_getNextPlanter(nextField)
							if (nextPlanter[1]="none")
							{
								nm_endWalk()
								break
							}
							else
								atField:=1
						}
						if (A_Index = 10) {
							nm_setStatus("Error", "Failed to place planter in 10 tries!`nMaxAllowedPlanters has been reduced.")
							MaxAllowedPlanters:=max(0, MaxAllowedPlanters-1)
							MainGui["MaxAllowedPlanters"].Value := MaxAllowedPlanters
							IniWrite MaxAllowedPlanters, "settings\nm_config.ini", "Planters", "MaxAllowedPlanters"
							break
						}
					}
				} else { ;is not the last element in the array
					temp:=lowToHigh[key+1][1]
					if ((nectarPercent + estimatedNectarPercent) <= lowToHigh[key+1][1]){
						success:=-1, atField:=0
						while (success!=1 && nextField!="none" && nextPlanter[1]!="none") {
							success := ba_placePlanter(nextField, nextPlanter, planterNum, atField)
							switch success {
								case 1: ;planter placed successfully, break loop
								plantersplaced++
								nectarPlantersPlaced++
								ba_SavePlacedPlanter(nextField, nextPlanter, planterNum, currentNectar)
								break

								case 2: ;already a planter in this field, change field and try
								lastnextfield:=ba_getlastfield(currentNectar)
								lastField:=lastNextField[1]
								nextField:=lastNextField[2]
								nextPlanter:=ba_getNextPlanter(nextField)
								atField:=0
								LostPlanters:=""
								Last%currentnectar%Field := nextField
								IniWrite Last%currentnectar%Field, "settings\nm_config.ini", "Planters", "Last" currentnectar "Field"

								case 3: ;3 planters have been placed already, return
								nm_OpenMenu()
								return

								case 4: ;not in a field, try again
								atField:=0

								default: ;cannot find planter, try alternative planter in this field
								nextPlanter:=ba_getNextPlanter(nextField)
								if (nextPlanter[1]="none")
								{
									nm_endWalk()
									break
								}
								else
									atField:=1
							}
							if (A_Index = 10) {
								nm_setStatus("Error", "Failed to place planter in 10 tries!`nMaxAllowedPlanters has been reduced.")
								MaxAllowedPlanters:=max(0, MaxAllowedPlanters-1)
								MainGui["MaxAllowedPlanters"].Value := MaxAllowedPlanters
								IniWrite MaxAllowedPlanters, "settings\nm_config.ini", "Planters", "MaxAllowedPlanters"
								break
							}
						}
					} else {
						break
					}
				}
			} else {
				break
			}
			;maximum planters have been placed. leave function
			if(plantersplaced=maxplanters || plantersplaced>=MaxAllowedPlanters) {
				nm_OpenMenu()
				return
			}
		}
	}
	;//////// STAGE 3: All Nectars are full? ///////////////
	;just place planters in priority order (this is a failsafe stage)
	for key, value in nectars {
		;--- get nectar priority --
		varstring:=(value . "priority")
		currentNectar:=%varstring%
		if (currentNectar = "None")
			continue
		nextPlanter:=[]
		;get maxNectarPlanters
		maxNectarPlanters:=0
		for ind, field in %currentNectar%Fields
		{
			tempfieldname := StrReplace(field, " ", "")
			if(%tempfieldname%FieldCheck)
				maxNectarPlanters:=maxNectarPlanters+1
		}
		;get nectarPlantersPlaced
		nectarPlantersPlaced:=0
		Loop 3{
			if(PlanterNectar%A_Index%=currentNectar)
				nectarPlantersPlaced:=nectarPlantersPlaced+1
		}
		if (currentNectar!="none") {
			planterSlots:=[]
			Loop 3 {
				if(PlanterName%A_Index%="none")
					planterSlots.push(A_Index)
			}
					for i, planterNum in planterSlots {
			;Loop 3 {
				;--- determine max number of planters ---
				maxplanters:=0
				for x, y in planternames {
					maxplanters := maxplanters + %y%Check
				}
				maxplanters := min(MaxAllowedPlanters, maxplanters)
				;determine last and next fields
				if(currentNectar=currentFieldNectar && not GotoPlanterField && GatherFieldSipping){
					lastnextfield:=ba_getlastfield(currentNectar)
					lastField:=lastNextField[1]
					nextField:=CurrentField
					maxNectarPlanters:=1
				} else {
					lastnextfield:=ba_getlastfield(currentNectar)
					lastField:=lastNextField[1]
					nextField:=lastNextField[2]
				}
				LostPlanters:=""
				nextPlanter:=ba_getNextPlanter(nextField)
				;there is an allowed field for this nectar and an available planter
				if(nextField!="none" && nextPlanter[1]!="none" && plantersplaced<maxplanters && plantersplaced<MaxAllowedPlanters && nectarPlantersPlaced<maxNectarPlanters){
					;determine current nectar percent
					nectarPercent:=ba_GetNectarPercent(currentnectar)
					estimatedNectarPercent:=0
					Loop 3 {
						planterNectar:=PlanterNectar%A_Index%
						if (PlanterNectar=currentNectar) {
							estimatedNectarPercent:=estimatedNectarPercent+PlanterEstPercent%A_Index%

						}
					}
					success:=-1, atField:=0
					while (success!=1 && nextField!="none" && nextPlanter[1]!="none") {
						success := ba_placePlanter(nextField, nextPlanter, planterNum, atField)
						switch success {
							case 1: ;planter placed successfully, break loop
							plantersplaced++
							nectarPlantersPlaced++
							ba_SavePlacedPlanter(nextField, nextPlanter, planterNum, currentNectar)
							break

							case 2: ;already a planter in this field, change field and try
							lastnextfield:=ba_getlastfield(currentNectar)
							lastField:=lastNextField[1]
							nextField:=lastNextField[2]
							nextPlanter:=ba_getNextPlanter(nextField)
							atField:=0
							LostPlanters:=""
							Last%currentnectar%Field := nextField
							IniWrite Last%currentnectar%Field, "settings\nm_config.ini", "Planters", "Last" currentnectar "Field"

							case 3: ;3 planters have been placed already, return
							nm_OpenMenu()
							return

							case 4: ;not in a field, try again
							atField:=0

							default: ;cannot find planter, try alternative planter in this field
							nextPlanter:=ba_getNextPlanter(nextField)
							if (nextPlanter[1]="none")
							{
								nm_endWalk()
								break
							}
							else
								atField:=1
						}
						if (A_Index = 10) {
							nm_setStatus("Error", "Failed to place planter in 10 tries!`nMaxAllowedPlanters has been reduced.")
							MaxAllowedPlanters:=max(0, MaxAllowedPlanters-1)
							MainGui["MaxAllowedPlanters"].Value := MaxAllowedPlanters
							IniWrite MaxAllowedPlanters, "settings\nm_config.ini", "Planters", "MaxAllowedPlanters"
							break
						}
					}
				} else {
					break
				}
				;maximum planters have been placed. leave function
				if(plantersplaced=maxplanters || plantersplaced>=MaxAllowedPlanters) {
					nm_OpenMenu()
					return
				}
			}
		} else {
			break
		}
	}
	nm_OpenMenu()
}
ba_GetNectarPercent(var){
	global nectarnames, totalCom, totalMot, totalRef, totalSat, totalInv
	static nectarcolors := Map("comforting",0x7E9EB3, "motivating",0x937DB3, "satisfying",0xB398A7, "refreshing",0x78B375, "invigorating",0xB35951)
	for key, value in nectarnames {
		if (var=value){
			nectarColor := nectarcolors[StrLower(var)]
			hwnd := GetRobloxHWND()
			offsetY := GetYOffset(hwnd)
			GetRobloxClientPos(hwnd)
			try
				result := PixelSearch(&bx2, &by2, windowX, windowY+offsetY+30, windowX+860, windowY+offsetY+150, nectarColor)
			catch
				result := 0
			If (result = 1) {
				nexty:=by2+1
				pixels:=1
				loop 38 {
					OutputVar := PixelGetColor(bx2, nexty)
					If (OutputVar=nectarColor) {
						nexty:=nexty+1
						pixels:=pixels+1
					} else {
						nectarpercent:=round(pixels/38*100, 0)
						break
					}
				}
			} else {
				nectarpercent:=0
			}
		}
	}
	if (nectarpercent=100)
		nectarpercent:=99.99
	total%SubStr(var, 1, 3)% := nectarpercent
	return nectarpercent
}
ba_getLastField(currentnectar){
	global ComfortingFields, RefreshingFields, SatisfyingFields, MotivatingFields, InvigoratingFields
		, LastComfortingField, LastRefreshingField, LastSatisfyingField, LastMotivatingField, LastInvigoratingField
		, BambooFieldCheck, BlueFlowerFieldCheck, CactusFieldCheck, CloverFieldCheck, CoconutFieldCheck, DandelionFieldCheck, MountainTopFieldCheck, MushroomFieldCheck
		, PepperFieldCheck, PineTreeFieldCheck, PineappleFieldCheck, PumpkinFieldCheck, RoseFieldCheck, SpiderFieldCheck, StrawberryFieldCheck, StumpFieldCheck, SunflowerFieldCheck
		, PlanterField1, PlanterField2, PlanterField3

	(arr := []).Length := 2, arr.Default := ""
	if (currentNectar = "None")
		return arr
	availablefields:=[]
	arr[1] := Last%currentnectar%Field
	;determine allowed fields
	for key, value in %currentnectar%Fields {
		tempfieldname := StrReplace(value, " ", "")
		if(%tempfieldname%FieldCheck && value!=PlanterField1 && value!=PlanterField2 && value!=PlanterField3)
			availablefields.Push(value)
	}
	arraylen:=availablefields.Length
	;no allowed fields exist for this nectar
	if(arraylen=0)
		arr[2] := "None"
	;find index of last nectar field
	for k, v in availablefields {
		;found index of last nectar field in availablefields
		if (v=Last%currentnectar%Field)
		{
			arr[2] := availablefields[Mod(k,arrayLen)+1]
			break
		}
	}
	if !arr[2]
		arr[1] := availablefields[1], arr[2] := availablefields.Has(2) ? availablefields[2] : availablefields[1]
	return arr
}
ba_getNextPlanter(nextfield){
	global BambooPlanters, BlueFlowerPlanters, CactusPlanters, CloverPlanters, CoconutPlanters, DandelionPlanters, MountainTopPlanters, MushroomPlanters, PepperPlanters
		, PineTreePlanters, PineapplePlanters, PumpkinPlanters, RosePlanters, SpiderPlanters, StrawberryPlanters, StumpPlanters, SunflowerPlanters
		, PlasticPlanterCheck, CandyPlanterCheck, BlueClayPlanterCheck, RedClayPlanterCheck, TackyPlanterCheck, PesticidePlanterCheck, HeatTreatedPlanterCheck
		, HydroponicPlanterCheck, PetalPlanterCheck, PaperPlanterCheck, TicketPlanterCheck, PlanterOfPlentyCheck
		, PlanterName1, PlanterName2, PlanterName3
	global LostPlanters
	;determine available planters
	tempFieldName := StrReplace(nextfield, " ", "")
	tempArrayName := (tempfieldname . "Planters")
	arrayLen:=IsSet(%tempfieldname%Planters) ? %tempfieldname%Planters.Length : 0
	nextPlanterName:="none"
	nextPlanterNectarBonus:=0
	nextPlanterGrowBonus:=0
	nextPlanterGrowTime:=0
	Loop arrayLen {
		tempPlanter:=Trim(%tempfieldname%Planters[A_Index][1])
		tempPlanterCheck:=%tempPlanter%Check
		if(tempPlanterCheck && tempPlanter!=PlanterName1 && tempPlanter!=PlanterName2 && tempPlanter!=PlanterName3)
		{
			if !InStr(LostPlanters, tempPlanter)
			{
				nextPlanterName:=%tempfieldname%Planters[A_Index][1]
				nextPlanterNectarBonus:=%tempfieldname%Planters[A_Index][2]
				nextPlanterGrowBonus:=%tempfieldname%Planters[A_Index][3]
				nextPlanterGrowTime:=%tempfieldname%Planters[A_Index][4]
				break
			}
		}
	}
	return [nextPlanterName, nextPlanterNectarBonus, nextPlanterGrowBonus, nextPlanterGrowTime]
}
ba_placePlanter(fieldName, planter, planterNum, atField:=0){
	global BambooFieldCheck, BlueFlowerFieldCheck, CactusFieldCheck, CloverFieldCheck, CoconutFieldCheck, DandelionFieldCheck, MountainTopFieldCheck, MushroomFieldCheck, PepperFieldCheck, PineTreeFieldCheck, PineappleFieldCheck, PumpkinFieldCheck, RoseFieldCheck, SpiderFieldCheck, StrawberryFieldCheck, StumpFieldCheck, SunflowerFieldCheck, MaxAllowedPlanters, LostPlanters, bitmaps

	nm_updateAction("Planters")

	nm_setShiftLock(0)

	planterName := planter[1]
	if (atField = 0)
	{
		nm_Reset()
		nm_OpenMenu("itemmenu")
		nm_setStatus("Traveling", (planterName . " (" . fieldName . ")"))
		nm_gotoPlanter(fieldName, 0)
	}

	planterPos := nm_InventorySearch(planterName, "up", 4)

	if (planterPos = 0) ; planter not in inventory
	{
		nm_setStatus("Missing", planterName)
		LostPlanters.=planterName
		ba_saveConfig_()
		return 0
	}
	else
	{
		GetRobloxClientPos()
		MouseMove windowX+planterPos[1], windowY+planterPos[2]
	}

	KeyWait "F14", "T120 L" ; wait for gotoPlanter finish
	nm_endWalk()

	nm_setStatus("Placing", planterName)
	hwnd := GetRobloxHWND()
	offsetY := GetYOffset(hwnd)
	Loop 10
	{
		GetRobloxClientPos(hwnd)
		pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY+offsetY+150 "|" windowWidth//2 "|" Max(480, windowHeight-offsetY-150))

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
						nm_setStatus("Missing", planterName)
						LostPlanters.=planterName
						ba_saveConfig_()
						return 0
					}
					else
					{
						Sleep 50
						Gdip_DisposeImage(pBMScreen)
						pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY+offsetY+150 "|" windowWidth//2 "|" Max(480, windowHeight-offsetY-150))
					}
				}
			}
		}

		if ((Gdip_ImageSearch(pBMScreen, bitmaps[planterName], &planterPos, , , 306, , 10, , 5) != 1) || (Gdip_ImageSearch(pBMScreen, bitmaps["yes"], , windowWidth//2-250, , , , 2, , 2) = 1)) {
			Gdip_DisposeImage(pBMScreen)
			break
		}
		Gdip_DisposeImage(pBMScreen)

		MouseClickDrag "Left", windowX+30, windowY+SubStr(planterPos, InStr(planterPos, ",")+1)+190, windowX+windowWidth//2, windowY+windowHeight//2, 5
		Sleep 200
	}
	Loop 50
	{
		GetRobloxClientPos(hwnd)
		loop 3 {
			pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2-250 "|" windowY+windowHeight//2-52 "|500|150")
			if (Gdip_ImageSearch(pBMScreen, bitmaps["yes"], &pos, , , , , 2, , 2) = 1) {
				MouseMove windowX+windowWidth//2-250+SubStr(pos, 1, InStr(pos, ",")-1), windowY+windowHeight//2-52+SubStr(pos, InStr(pos, ",")+1)
				Sleep 150
				Click
				sleep 100
				Gdip_DisposeImage(pBMScreen)
				MouseMove windowX+350, windowY+offsetY+100
				break 2
			}
			Gdip_DisposeImage(pBMScreen)
			Sleep 50 ; delay in case of lag
		}

		if (A_Index = 50) {
			nm_setStatus("Missing", planterName)
			LostPlanters.=planterName
			ba_saveConfig_()
			return 0
		}

		Sleep 100
	}

	Loop 10
	{
		Sleep 100
		imgPos := nm_imgSearch("3Planters.png",30,"lowright")
		If (imgPos[1] = 0){
			MaxAllowedPlanters:=max(0, MaxAllowedPlanters-1)
			MainGui["MaxAllowedPlanters"].Value := MaxAllowedPlanters
			nm_setStatus("Error", "3 Planters already placed!`nMaxAllowedPlanters has been reduced.")
			ba_saveConfig_()
			Sleep 500
			return 3
		}
		imgPos := nm_imgSearch("planteralready.png",30,"lowright")
		If (imgPos[1] = 0){
			return 2
		}
		imgPos := nm_imgSearch("standing.png",30,"lowright")
		If (imgPos[1] = 0){
			return 4
		}
	}
	return 1
}
ba_harvestPlanter(planterNum){
	global PlanterName1, PlanterName2, PlanterName3, PlanterField1, PlanterField2, PlanterField3, PlanterHarvestTime1, PlanterHarvestTime2, PlanterHarvestTime3, PlanterNectar1, PlanterNectar2, PlanterNectar3, PlanterEstPercent1, PlanterEstPercent2, PlanterEstPercent3, PlanterGlitterC1, PlanterGlitterC2, PlanterGlitterC3, PlanterGlitter1, PlanterGlitter2, PlanterGlitter3, BackKey, RightKey, objective, TotalPlantersCollected, SessionPlantersCollected, HarvestFullGrown, ConvertFullBagHarvest, GatherPlanterLoot, BackpackPercent, bitmaps, SC_E, HiveBees, PlanterHarvestNow1, PlanterHarvestNow2, PlanterHarvestNow3

	nm_updateAction("Planters")

	planterName:=PlanterName%planterNum%
	fieldName:=PlanterField%planterNum%
	nm_setShiftLock(0)
	nm_Reset(1, ((GatherPlanterLoot = 1) && ((fieldname = "Rose") || (fieldname = "Pine Tree") || (fieldname = "Pumpkin") || (fieldname = "Cactus") || (fieldname = "Spider"))) ? min(20000, (60-HiveBees)*1000) : 0)
	nm_setStatus("Traveling", planterName . " (" . fieldName . ")")
	nm_gotoPlanter(fieldName)
	nm_setStatus("Collecting", (planterName . " (" . fieldName . ")"))
	while ((A_Index <= 5) && !(findPlanter := (nm_imgSearch("e_button.png",10)[1] = 0)))
		Sleep 200
	if (findPlanter = 0) {
		nm_setStatus("Searching", (planterName . " (" . fieldName . ")"))
		findPlanter := nm_searchForE()
	}
	if (findPlanter = 0) {
		;check for phantom planter
		nm_setStatus("Checking", "Phantom Planter: " . planterName)
		ActivateRoblox()
		GetRobloxClientPos()

		nm_OpenMenu("itemmenu")
		planterPos := nm_InventorySearch(planterName, "up", 4)

		if (planterPos != 0) { ; found planter in inventory planter is a phantom
			nm_setStatus("Found", planterName . ". Clearing Data.")
			;reset values
			PlanterName%planterNum% := "None"
			PlanterField%planterNum% := "None"
			PlanterNectar%planterNum% := "None"
			PlanterHarvestTime%planterNum% := 2147483647
			PlanterEstPercent%planterNum% := 0
			PlanterGlitterC%planterNum% := 0
			PlanterGlitter%planterNum% := 0
			;write values to ini
			IniWrite "None", "settings\nm_config.ini", "Planters", "PlanterName" planterNum
			IniWrite "None", "settings\nm_config.ini", "Planters", "PlanterField" planterNum
			IniWrite "None", "settings\nm_config.ini", "Planters", "PlanterNectar" planterNum
			IniWrite 2147483647, "settings\nm_config.ini", "Planters", "PlanterHarvestTime" planterNum
			IniWrite 0, "settings\nm_config.ini", "Planters", "PlanterEstPercent" planterNum
			IniWrite PlanterGlitter%planterNum%, "settings\nm_config.ini", "Planters", "PlanterGlitter" planterNum
			IniWrite PlanterGlitterC%planterNum%, "settings\nm_config.ini", "Planters", "PlanterGlitterC" planterNum
			return 1
		}
		else
			return 0
	}
	else {
		SendInput "{" SC_E " down}"
		Sleep 100
		SendInput "{" SC_E " up}"

		hwnd := GetRobloxHWND()
		offsetY := GetYOffset(hwnd)
		Loop 50
		{
			GetRobloxClientPos(hwnd)
			pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2-200 "|" windowY+offsetY+36 "|200|120")
			if (Gdip_ImageSearch(pBMScreen, bitmaps["e_button"], , , , , , 2, , 6) = 0) {
				Gdip_DisposeImage(pBMScreen)
				break
			}
			Gdip_DisposeImage(pBMScreen)

			Sleep 100

			if (A_Index = 50)
				return 0
		}

		Sleep 50 ; wait for game to update frame
		GetRobloxClientPos(hwnd)
		if ((HarvestFullGrown = 1) && !PlanterHarvestNow%planterNum%) {
			loop 3 {
				pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2-250 "|" windowY+windowHeight//2-52 "|500|150")
				if (Gdip_ImageSearch(pBMScreen, bitmaps["no"], &pos, , , , , 2, , 3) = 1) {
					MouseMove windowX+windowWidth//2-250+SubStr(pos, 1, InStr(pos, ",")-1), windowY+windowHeight//2-52+SubStr(pos, InStr(pos, ",")+1)
					Sleep 150
					Click
					sleep 100
					MouseMove windowX+350, windowY+offsetY+100
					Gdip_DisposeImage(pBMScreen)
					nm_PlanterTimeUpdate(FieldName)
					return 1
				}
				Gdip_DisposeImage(pBMScreen)
			}
		}
		else {
			loop 3 {
				pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2-250 "|" windowY+windowHeight//2-52 "|500|150")
				if (Gdip_ImageSearch(pBMScreen, bitmaps["yes"], &pos, , , , , 2, , 2) = 1) {
					MouseMove windowX+windowWidth//2-250+SubStr(pos, 1, InStr(pos, ",")-1), windowY+windowHeight//2-52+SubStr(pos, InStr(pos, ",")+1)
					Sleep 150
					Click
					sleep 100
					MouseMove windowX+350, windowY+offsetY+100
					Gdip_DisposeImage(pBMScreen)
					If PlanterHarvestNow%planterNum%
						IniWrite 0, "settings\nm_config.ini", "Planters", "PlanterHarvestNow" planterNum
					break
				}
				Gdip_DisposeImage(pBMScreen)
				Sleep 50 ; delay in case of lag
			}
		}


		;reset values
		PlanterName%planterNum% := "None"
		PlanterField%planterNum% := "None"
		PlanterNectar%planterNum% := "None"
		PlanterHarvestTime%planterNum% := 2147483647
		PlanterEstPercent%planterNum% := 0
		PlanterGlitterC%planterNum% := 0
		PlanterGlitter%planterNum% := 0
		;write values to ini
		IniWrite "None", "settings\nm_config.ini", "Planters", "PlanterName" planterNum
		IniWrite "None", "settings\nm_config.ini", "Planters", "PlanterField" planterNum
		IniWrite "None", "settings\nm_config.ini", "Planters", "PlanterNectar" planterNum
		IniWrite 2147483647, "settings\nm_config.ini", "Planters", "PlanterHarvestTime" planterNum
		IniWrite 0, "settings\nm_config.ini", "Planters", "PlanterEstPercent" planterNum
		IniWrite PlanterGlitter%planterNum%, "settings\nm_config.ini", "Planters", "PlanterGlitter" planterNum
		IniWrite PlanterGlitterC%planterNum%, "settings\nm_config.ini", "Planters", "PlanterGlitterC" planterNum
		TotalPlantersCollected:=TotalPlantersCollected+1
		SessionPlantersCollected:=SessionPlantersCollected+1
		PostSubmacroMessage("StatMonitor", 0x5555, 4, 1)
		IniWrite TotalPlantersCollected, "settings\nm_config.ini", "Status", "TotalPlantersCollected"
		IniWrite SessionPlantersCollected, "settings\nm_config.ini", "Status", "SessionPlantersCollected"
		;gather loot
		if (GatherPlanterLoot = 1)
		{
			nm_setStatus("Looting", planterName . " Loot")
			Sleep 1000
			movement := nm_Walk(7, BackKey, RightKey)
			nm_createWalk(movement)
			KeyWait "F14", "D T5 L"
			KeyWait "F14", "T20 L"
			nm_endWalk()
			nm_loot(9, 5, "left")
		}
		if ((ConvertFullBagHarvest = 1) && (BackpackPercent >= 95))
		{
			; loot path end location for some fields prevents successful return to hive
			If (GatherPlanterLoot = 1) {
				If (fieldname = "Cactus") || (fieldname = "Sunflower") {
					sleep 200
					nm_Move(1500*round(18/MoveSpeedNum, 8), RightKey)
					sleep 200
				}
			}
			nm_walkFrom(fieldName)
			DisconnectCheck()
			nm_findHiveSlot()
		}
		return 1
	}
}
ba_SavePlacedPlanter(fieldName, planter, planterNum, nectar){
	global PlanterName1, PlanterName2, PlanterName3
		, PlanterField1, PlanterField2, PlanterField3
		, PlanterHarvestTime1, PlanterHarvestTime2, PlanterHarvestTime3
		, PlanterNectar1, PlanterNectar2, PlanterNectar3
		, PlanterEstPercent1, PlanterEstPercent2, PlanterEstPercent3
		, LastComfortingField, LastMotivatingField, LastSatisfyingField, LastRefreshingField, LastInvigoratingField, HarvestInterval
	global PlasticPlanterCheck, CandyPlanterCheck, BlueClayPlanterCheck, RedClayPlanterCheck, TackyPlanterCheck, PesticidePlanterCheck, HeatTreatedPlanterCheck
		, HydroponicPlanterCheck, PetalPlanterCheck, PaperPlanterCheck, TicketPlanterCheck, PlanterOfPlentyCheck
		, n1minPercent, n2minPercent, n3minPercent, n4minPercent, n5minPercent, AutomaticHarvestInterval, HarvestFullGrown
	;temp1:=planter[1]
	;temp2:=planter[2]
	;temp3:=planter[3]
	;temp4:=planter[4]
	;save placed planter to ini
	PlanterName%planterNum%:=planter[1]
	PlanterField%planterNum%:=fieldName
	PlanterNectar%planterNum%:=nectar
	PlanterNameN:=PlanterName%planterNum%
	PlanterFieldN:=PlanterField%planterNum%
	PlanterNectarN:=PlanterNectar%planterNum%
	Last%nectar%Field:=fieldname
	;calculate harvest time
	estimatedNectarPercent:=0
	Loop 3 { ;3 max positions
		planterNectar:=PlanterNectar%A_Index%
		if (PlanterNectar=nectar) {
			estimatedNectarPercent:=estimatedNectarPercent+PlanterEstPercent%A_Index%
		}
	}
	estimatedNectarPercent:=estimatedNectarPercent+ba_GetNectarPercent(nectar) ;projected nectar percent
	minPercent:=estimatedNectarPercent
	Loop 5{ ;5 nectar priorities
		if(n%A_Index%priority=nectar && minPercent<=n%A_Index%minPercent)
			minPercent:=n%A_Index%minPercent ; minPercent > estimatedNectarPercent
	}
	temp1:=minPercent-estimatedNectarPercent
	;timeToCap:=(max(0,(100-estimatedNectarPercent))*.24)/planter[2] ;hours
	timeToCap:=max(0.25,((max(0,(100-estimatedNectarPercent)/planter[2]))*.24)/planter[3]) ;hours
	if(planter[2]*planter[3]<1.2){ ;less than 20% overall bonus
		autoInterval:=min(timeToCap, 0.5)
	}
	;if((minPercent > estimatedNectarPercent) && ((minPercent-estimatedNectarPercent)>=5) && ((estimatedNectarPercent)<=100)){
	else if((minPercent > estimatedNectarPercent) && ((estimatedNectarPercent)<=90)){
		;autoInterval:=((minPercent-estimatedNectarPercent)*.24)/planter[2] ;hours
		if (estimatedNectarPercent>0) {
			bonusTime:=(100/estimatedNectarPercent)*planter[2]*planter[3]
			autoInterval:=(((minPercent-estimatedNectarPercent+bonusTime)/planter[2])*.24)/planter[3] ;hours
		} else {
			autoInterval:=planter[4] ;hours
		}

	} else { ;minPercent <= estimatedNectarPercent
		autoInterval:=timeToCap
	}
	;nec=planter[2]
	;gro=planter[3]
	if(AutomaticHarvestInterval) {
		planterHarvestInterval:=floor(min(planter[4], (autoInterval+autoInterval/(planter[2]*planter[3])), (timeToCap+timeToCap/(planter[2]*planter[3])))*60*60)
		PlanterHarvestTime%planterNum%:=nowUnix()+planterHarvestInterval
	} else if(HarvestFullGrown) {
		planterHarvestInterval:=floor(planter[4]*60*60)
		PlanterHarvestTime%planterNum%:=nowUnix()+planterHarvestInterval
	} else {
		;planterHarvestInterval:=floor(min(planter[4], HarvestInterval, (timeToCap+timeToCap/(planter[2]*planter[3])))*60*60)
		;planterHarvestInterval:=floor(min(planter[4], HarvestInterval)*60*60)
		;temp1:=planter[4]
		planterHarvestInterval:=floor(min(planter[4], HarvestInterval)*60*60)
		smallestHarvestInterval:=nowUnix()+planterHarvestInterval
		Loop 3 {
			if(PlanterHarvestTime%A_Index%>nowUnix() && PlanterHarvestTime%A_Index%<smallestHarvestInterval)
				smallestHarvestInterval:=PlanterHarvestTime%A_Index%
		}
		PlanterHarvestTime%planterNum%:=min(smallestHarvestInterval, nowUnix()+planterHarvestInterval)
		temp:=PlanterHarvestTime%planterNum%
	}
	;PlanterHarvestTime%planterNum%:=toUnix_()+planterHarvestInterval
	PlanterHarvestTimeN:=PlanterHarvestTime%planterNum%
	;PlanterEstPercent%planterNum%:=round((floor(min(planter[3], HarvestInterval)*60*60)*planter[2]-floor(min(planter[3], HarvestInterval)*60*60))/864, 1)
	PlanterEstPercent%planterNum%:=round((floor(planterHarvestInterval)*planter[2])/864, 1)
	PlanterEstPercentN:=PlanterEstPercent%planterNum%
	;save changes
	IniWrite PlanterNameN, "settings\nm_config.ini", "Planters", "PlanterName" planterNum
	IniWrite PlanterFieldN, "settings\nm_config.ini", "Planters", "PlanterField" planterNum
	IniWrite PlanterNectarN, "settings\nm_config.ini", "Planters", "PlanterNectar" planterNum

	;make all harvest times equal
	Loop 3 {
		if(not HarvestFullGrown && PlanterHarvestTime%A_Index% > PlanterHarvestTimeN && PlanterHarvestTime%A_Index% < PlanterHarvestTimeN + 600)
			IniWrite PlanterHarvestTimeN, "settings\nm_config.ini", "Planters", "PlanterHarvestTime" A_Index
		else if(A_Index=planterNum)
			IniWrite PlanterHarvestTimeN, "settings\nm_config.ini", "Planters", "PlanterHarvestTime" planterNum
	}

	IniWrite PlanterEstPercentN, "settings\nm_config.ini", "Planters", "PlanterEstPercent" planterNum
	IniWrite fieldname, "settings\nm_config.ini", "Planters", "Last" nectar "Field"
}

mp_Planter() { ;//todo: merge these manual planter functions as much as possible with Planters+ functions, lots of code duplication here!
	Global
	Local TimeElapsed, GlitterPos, field, i, k, v
	Global PlanterGlitter1, PlanterGlitter2, PlanterGlitter3, PlanterGlitterC1, PlanterGlitterC2, PlanterGlitterC3, PlanterHarvestFull1, PlanterHarvestFull2, PlanterHarvestFull3, PlanterSS1, PlanterSS2, PlanterSS3

	If (PlanterMode != 1)
		Return
	if (nm_NightInterrupt() || nm_MondoInterrupt() || nm_GatherBoostInterrupt())
		return

	; if enabled, take any/all planter screenshots before further planter actions
	If (PlanterSS1 || PlanterSS2 || PlanterSS3)
		nm_planterSS()

	Loop 2 {
		Loop 3 {
			If (!MSlot%A_Index%Cycle1Field)
				Continue
			; reset Release variable to 0 if planter slot empty
			If (PlanterField%A_Index% = "None") {
				PlanterHarvestNow%A_Index% := 0
				IniWrite PlanterHarvestNow%A_Index%, "settings\nm_config.ini", "Planters", "PlanterHarvestNow" A_Index
			}
			; reset Hold and Smoking variables to 0 if planter slot empty, disable auto harvest no longer selected, or user has set to Harvest Now with remote control
			If ((!MPuffModeA) || (!MPuffMode%A_Index%) || (PlanterField%A_Index% = "None")  || (PlanterHarvestNow%A_Index%)) {
				MPlanterHold%A_Index% := 0
				IniWrite MPlanterHold%A_Index%, "settings\nm_config.ini", "Planters", "MPlanterHold" A_Index
				MPlanterSmoking%A_Index% := 0
				IniWrite MPlanterSmoking%A_Index%, "settings\nm_config.ini", "Planters", "MPlanterSmoking" A_Index
			}
			If (PlanterHarvestTime%A_Index% > 2147483646 ) {
				mp_PlantPlanter(A_Index)
			} Else if (!MPlanterHold%A_Index% && (PlanterName%A_Index%!="None") && (PlanterField%A_Index%!="None")) {
				If (nowUnix() >= PlanterHarvestTime%A_Index%)
					mp_HarvestPlanter(A_Index)
				If (PlanterHarvestFull%A_Index% == "Full" && (nowUnix() - LastGlitter >= 900) && PlanterGlitterC%A_Index% && !PlanterGlitter%A_Index%) {
					i := A_Index, field := StrReplace(PlanterField%A_Index%, " ")
					for k,v in %field%Planters {
						if (v[1] = PlanterName%i%) {
							PlanterGrowTime := v[4]
							break
						}
					}
					If ((PlanterHarvestTime%A_Index% - nowUnix()) >= Round(3600 * PlanterGrowTime * 0.5)) {
						mp_UseGlitter(A_Index)
					}
				}
			}
		}
	}
}

nm_planterSS(){
	Global

	Loop 3 {
		If (PlanterSS%A_Index%) {
			nm_setShiftLock(0)
			nm_Reset(nm_Reset(1, ((PlanterField%A_Index% = "Rose") || (PlanterField%A_Index% = "Pine Tree") || (PlanterField%A_Index% = "Pumpkin") || (PlanterField%A_Index% = "Cactus") || (PlanterField%A_Index% = "Spider")) ? min(20000, (60-HiveBees)*1000) : 0))
			nm_setStatus("Traveling", PlanterName%A_Index% " (" PlanterField%A_Index% ")")
			nm_gotoPlanter(PlanterField%A_Index%, 1)

			sendinput "{" ZoomIn " 2}"

			; fields where the view is initially obstructed
			If ((PlanterField%A_Index% = "Rose") || (PlanterField%A_Index% = "Mountain Top")) {
				sleep 200
				sendinput "{" RotRight " 3}"
			}
			If ((PlanterField%A_Index% = "Bamboo") || (PlanterField%A_Index% = "Rose") || (PlanterField%A_Index% = "Cactus") || (PlanterField%A_Index% = "Mountain Top")) {
				loop 3 {
					sleep 200
					sendinput "{" ZoomOut " 2}"
				}
			}

			Sleep 2000
			nm_setStatus("Screenshot", (PlanterName%A_Index% . " (" . PlanterField%A_Index% . ")"))
			Sleep 2000

			PlanterSS%A_Index%:=0
			IniWrite 0, "settings\nm_config.ini", "Planters", "PlanterSS" A_Index
		}
	}
}

mp_PlantPlanter(PlanterIndex) {
	Global
	Local CycleIndex, MFieldName, MPlanterName, planterPos, pBMScreen, imgPos, field, k, v, hwnd
	Static MHarvestIntervalValue := Map("30 mins", 0.5
		, "1 hour", 1
		, "2 hours", 2
		, "3 hours", 3
		, "4 hours", 4
		, "5 hours", 5
		, "6 hours", 6)
	, MFieldNectars := Map("Dandelion", "Comforting"
		, "Bamboo", "Comforting"
		, "Pine Tree", "Comforting"
		, "Coconut", "Refreshing"
		, "Strawberry", "Refreshing"
		, "Blue Flower", "Refreshing"
		, "Pineapple", "Satisfying"
		, "Sunflower", "Satisfying"
		, "Pumpkin", "Satisfying"
		, "Stump", "Motivating"
		, "Spider", "Motivating"
		, "Mushroom", "Motivating"
		, "Rose", "Motivating"
		, "Pepper", "Invigorating"
		, "Mountain Top", "Invigorating"
		, "Clover", "Invigorating"
		, "Cactus", "Invigorating")

	nm_updateAction("Planters")

	Loop MSlot%PlanterIndex%MaxCycle {
		CycleIndex := PlanterManualCycle%PlanterIndex%
		MFieldName := MSlot%PlanterIndex%Cycle%CycleIndex%Field
		MPlanterName := (StrReplace(MSlot%PlanterIndex%Cycle%CycleIndex%Planter, " ") (MSlot%PlanterIndex%Cycle%CycleIndex%Planter = "Planter Of Plenty" ? "" : "Planter"))
		If (PlanterField1 = MFieldName || PlanterField2 = MFieldName || PlanterField3 = MFieldName || PlanterName1 = MPlanterName || PlanterName2 = MPlanterName || PlanterName3 = MPlanterName) {
			PlanterManualCycle%PlanterIndex% := Mod(PlanterManualCycle%PlanterIndex%, MSlot%PlanterIndex%MaxCycle) + 1
			mp_UpdateCycles()
		} Else
			Break
		If (A_Index = MSlot%PlanterIndex%MaxCycle)
			Return
	}

	nm_setShiftLock(0)

	nm_Reset()
	nm_OpenMenu("itemmenu")
	nm_setStatus("Traveling", MPlanterName " (" MFieldName ")")
	nm_gotoPlanter(MFieldName, 0)

	ActivateRoblox()
	GetRobloxClientPos()

	planterPos := nm_InventorySearch(MPlanterName, "up", 4) ;~ new function

	if (planterPos = 0) ; planter not in inventory
	{
		nm_setStatus("Missing", MPlanterName)
		return 0
	}
	else
		MouseMove windowX+planterPos[1], windowY+planterPos[2]

	KeyWait "F14", "T120 L" ; wait for gotoPlanter finish
	nm_endWalk()

	nm_setStatus("Placing", MPlanterName)
	hwnd := GetRobloxHWND()
	offsetY := GetYOffset(hwnd)
	Loop 10
	{
		GetRobloxClientPos(hwnd)
		pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY+offsetY+150 "|" windowWidth//2 "|" Max(480, windowHeight-offsetY-150))

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
						nm_setStatus("Missing", MPlanterName)
						return 0
					}
					else
					{
						Sleep 50
						Gdip_DisposeImage(pBMScreen)
						pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY+offsetY+150 "|" windowWidth//2 "|" Max(480, windowHeight-offsetY-150))
					}
				}
			}
		}

		if ((Gdip_ImageSearch(pBMScreen, bitmaps[MPlanterName], &planterPos, , , 306, , 10, , 5) != 1) || (Gdip_ImageSearch(pBMScreen, bitmaps["yes"], , windowWidth//2-250, , , , 2, , 2) = 1)) {
			Gdip_DisposeImage(pBMScreen)
			break
		}
		Gdip_DisposeImage(pBMScreen)

		MouseClickDrag "Left", windowX+30, windowY+SubStr(planterPos, InStr(planterPos, ",")+1)+190, windowX+windowWidth//2, windowY+windowHeight//2, 5
		Sleep 200
	}
	Loop 50
	{
		GetRobloxClientPos(hwnd)
		loop 3 {
			pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2-250 "|" windowY+windowHeight//2-52 "|500|150")
			if (Gdip_ImageSearch(pBMScreen, bitmaps["yes"], &pos, , , , , 2, , 2) = 1) {
				MouseMove windowX+windowWidth//2-250+SubStr(pos, 1, InStr(pos, ",")-1), windowY+windowHeight//2-52+SubStr(pos, InStr(pos, ",")+1)
				Sleep 150
				Click
				sleep 100
				Gdip_DisposeImage(pBMScreen)
				MouseMove windowX+350, windowY+offsetY+100
				break 2
			}
			Gdip_DisposeImage(pBMScreen)
			Sleep 50 ; delay in case of lag
		}

		if (A_Index = 50) {
			nm_setStatus("Missing", MPlanterName)
			return 0
		}

		Sleep 100
	}

	Loop 10
	{
		Sleep 100
		imgPos := nm_imgSearch("3Planters.png",30,"lowright")
		If (imgPos[1] = 0){
			nm_setStatus("Error", "3 Planters already placed!")
			Sleep 500
			return 3
		}
		imgPos := nm_imgSearch("planteralready.png",30,"lowright")
		If (imgPos[1] = 0){
			return 2
		}
		imgPos := nm_imgSearch("standing.png",30,"lowright")
		If (imgPos[1] = 0){
			return 4
		}
	}

	PlanterName%PlanterIndex% := MPlanterName
	PlanterField%PlanterIndex% := MFieldName
	PlanterNectar%PlanterIndex% := MFieldNectars[StrTitle(MFieldName)]
	PlanterGlitterC%PlanterIndex% := MSlot%PlanterIndex%Cycle%CycleIndex%Glitter
	PlanterGlitter%PlanterIndex% := 0
	if ((PlanterHarvestFull%PlanterIndex% := MSlot%PlanterIndex%Cycle%CycleIndex%AutoFull) = "Full") {
		field := StrReplace(PlanterField%PlanterIndex%, " ")
		for k,v in %field%Planters {
			if (v[1] = PlanterName%PlanterIndex%) {
				PlanterHarvestTime%PlanterIndex% := nowUnix() + Round(v[4] * 3600)
				break
			}
		}
	} else {
		PlanterHarvestTime%PlanterIndex% := nowUnix() + Integer(3600 * MHarvestIntervalValue[MHarvestInterval])
		Loop 3
			If (PlanterHarvestTime%A_Index% < PlanterHarvestTime%PlanterIndex% && PlanterHarvestTime%A_Index% > PlanterHarvestTime%PlanterIndex% - 300)
				PlanterHarvestTime%PlanterIndex% := PlanterHarvestTime%A_Index%
	}

	IniWrite PlanterName%PlanterIndex%, "settings\nm_config.ini", "Planters", "PlanterName" PlanterIndex
	IniWrite PlanterField%PlanterIndex%, "settings\nm_config.ini", "Planters", "PlanterField" PlanterIndex
	IniWrite PlanterNectar%PlanterIndex%, "settings\nm_config.ini", "Planters", "PlanterNectar" PlanterIndex
	IniWrite PlanterGlitter%PlanterIndex%, "settings\nm_config.ini", "Planters", "PlanterGlitter" PlanterIndex
	IniWrite PlanterGlitterC%PlanterIndex%, "settings\nm_config.ini", "Planters", "PlanterGlitterC" PlanterIndex
	IniWrite PlanterHarvestFull%PlanterIndex%, "settings\nm_config.ini", "Planters", "PlanterHarvestFull" PlanterIndex
	IniWrite PlanterHarvestTime%PlanterIndex%, "settings\nm_config.ini", "Planters", "PlanterHarvestTime" PlanterIndex

	If (nowUnix() - LastGlitter >= 900 && PlanterGlitterC%PlanterIndex% && !PlanterGlitter%PlanterIndex%)
		mp_UseGlitter(PlanterIndex, 1)

	return 1
}

mp_UseGlitter(PlanterIndex, atField:=0) {
	Global
	Local pBMScreen, glitterPos

	nm_setShiftLock(0)

	if (atField = 0) {
		nm_Reset()
		nm_OpenMenu("itemmenu")
		nm_setStatus("Traveling", "Glitter: " PlanterName%PlanterIndex% " (" PlanterField%PlanterIndex% ")")
		nm_gotoPlanter(PlanterField%PlanterIndex%, 0)
	}

	glitterPos := nm_InventorySearch("glitter")

	if (glitterPos = 0) ; glitter not in inventory
	{
		nm_setStatus("Missing", "Glitter")
		return 0
	}
	else
	{
		GetRobloxClientPos()
		MouseMove windowX+glitterPos[1], windowY+glitterPos[2]
	}

	KeyWait "F14", "T120 L" ; wait for gotoPlanter finish
	nm_endWalk()

	hwnd := GetRobloxHWND()
	offsetY := GetYOffset(hwnd)
	Loop 10
	{
		GetRobloxClientPos(hwnd)
		pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY+offsetY+150 "|" windowWidth//2 "|" Max(480, windowHeight-offsetY-150))

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
						nm_setStatus("Missing", "Glitter")
						return 0
					}
					else
					{
						Sleep 50
						Gdip_DisposeImage(pBMScreen)
						pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY+offsetY+150 "|306|" Max(480, windowHeight-offsetY-150))
					}
				}
			}
		}

		if ((Gdip_ImageSearch(pBMScreen, bitmaps["glitter"], &glitterPos, , , 306, , 10, , 5) != 1)) {
			Gdip_DisposeImage(pBMScreen)
			break
		}
		Gdip_DisposeImage(pBMScreen)

		MouseClickDrag "Left", windowX+30, windowY+SubStr(glitterPos, InStr(glitterPos, ",")+1)+190, windowX+windowWidth//2, windowY+windowHeight//2, 5
		Sleep 200
	}

	nm_setStatus("Boosted", "Glitter: " PlanterName%PlanterIndex%)
	LastGlitter:=nowUnix()
	IniWrite LastGlitter, "settings\nm_config.ini", "Boost", "LastGlitter"
	PlanterGlitter%PlanterIndex% := LastGlitter
	PlanterHarvestTime%PlanterIndex% := nowUnix() + Integer((PlanterHarvestTime%PlanterIndex% - nowUnix()) * 0.75)
	IniWrite PlanterGlitter%PlanterIndex%, "settings\nm_config.ini", "Planters", "PlanterGlitter" PlanterIndex
	IniWrite PlanterHarvestTime%PlanterIndex%, "settings\nm_config.ini", "Planters", "PlanterHarvestTime" PlanterIndex
}

mp_HarvestPlanter(PlanterIndex) {
	Global
	Local CycleIndex, MPlanterName, MFieldName, findPlanter, planterPos, pBMScreen, hwnd

	nm_updateAction("Planters")

	MPlanterName := PlanterName%PlanterIndex%
	MFieldName := PlanterField%PlanterIndex%

	nm_setShiftLock(0)
	nm_Reset(nm_Reset(1, ((MFieldName = "Rose") || (MFieldName = "Pine Tree") || (MFieldName = "Pumpkin") || (MFieldName = "Cactus") || (MFieldName = "Spider")) ? min(20000, (60-HiveBees)*1000) : 0))

	nm_setStatus("Traveling", MPlanterName . " (" . MFieldName . ")")
	nm_gotoPlanter(MFieldName)
	if ((!MPuffModeA) || (!MPuffMode%PlanterIndex%) || (PlanterHarvestNow%PlanterIndex%))
		nm_setStatus("Collecting", (MPlanterName . " (" . MFieldName . ")"))
	else
		nm_setStatus("Checking", (MPlanterName . " (" . MFieldName . ")"))
	while ((A_Index <= 5) && !(findPlanter := (nm_imgSearch("e_button.png",10)[1] = 0)))
		Sleep 200
	if (findPlanter = 0) {
		nm_setStatus("Searching", (MPlanterName . " (" . MFieldName . ")"))
		findPlanter := nm_searchForE()
	}
	if (findPlanter = 0) {
		;check for phantom planter
		nm_setStatus("Checking", "Phantom Planter: " . MPlanterName)

		planterPos := nm_InventorySearch(MPlanterName, "up", 4) ;~ new function

		if (planterPos != 0) { ; found planter in inventory planter is a phantom
			nm_setStatus("Found", MPlanterName . ". Clearing Data.")

			;reset disable auto harvest values if phantom planter
			PlanterHarvestNow%PlanterIndex% := 0
			IniWrite PlanterHarvestNow%PlanterIndex%, "settings\nm_config.ini", "Planters", "PlanterHarvestNow" PlanterIndex
			MPlanterSmoking%PlanterIndex% := 0
			IniWrite MPlanterSmoking%PlanterIndex%, "settings\nm_config.ini", "Planters", "MPlanterSmoking" PlanterIndex

			;reset values
			CycleIndex := PlanterManualCycle%PlanterIndex%
			if ((MPlanterName = (StrReplace(MSlot%PlanterIndex%Cycle%CycleIndex%Planter, " ") (MSlot%PlanterIndex%Cycle%CycleIndex%Planter = "Planter Of Plenty" ? "" : "Planter"))) && (MFieldName = MSlot%PlanterIndex%Cycle%CycleIndex%Field)) {
				PlanterManualCycle%PlanterIndex% := Mod(PlanterManualCycle%PlanterIndex%, MSlot%PlanterIndex%MaxCycle) + 1
				mp_UpdateCycles()
			}

			PlanterName%PlanterIndex% := "None"
			PlanterField%PlanterIndex% := "None"
			PlanterNectar%PlanterIndex% := "None"
			PlanterGlitterC%PlanterIndex% := 0
			PlanterGlitter%PlanterIndex% := 0
			PlanterHarvestFull%PlanterIndex% := ""
			PlanterHarvestTime%PlanterIndex% := 2147483647

			IniWrite PlanterName%PlanterIndex%, "settings\nm_config.ini", "Planters", "PlanterName" PlanterIndex
			IniWrite PlanterField%PlanterIndex%, "settings\nm_config.ini", "Planters", "PlanterField" PlanterIndex
			IniWrite PlanterNectar%PlanterIndex%, "settings\nm_config.ini", "Planters", "PlanterNectar" PlanterIndex
			IniWrite PlanterGlitter%PlanterIndex%, "settings\nm_config.ini", "Planters", "PlanterGlitter" PlanterIndex
			IniWrite PlanterGlitterC%PlanterIndex%, "settings\nm_config.ini", "Planters", "PlanterGlitterC" PlanterIndex
			IniWrite PlanterHarvestFull%PlanterIndex%, "settings\nm_config.ini", "Planters", "PlanterHarvestFull" PlanterIndex
			IniWrite PlanterHarvestTime%PlanterIndex%, "settings\nm_config.ini", "Planters", "PlanterHarvestTime" PlanterIndex
		}

		return 1
	}
	else if ((MPuffModeA = 1) && (MPuffMode%PlanterIndex% = 1) && (PlanterHarvestNow%PlanterIndex% != 1)) {
		; screenshot and set to hold instead of harvest, if auto harvest is disabled for the slot, and the user hasn't selected to release it by remote control
		Sleep 200 ; wait for game to update frame
		nm_PlanterTimeUpdate(MFieldName)
		sleep 1000
		If (nowUnix() >= PlanterHarvestTime%PlanterIndex%) {
			nm_setStatus("Holding", (MPlanterName . " (" . MFieldName . ")"))
			Sleep 2000
			MPlanterHold%PlanterIndex% := 1
			IniWrite MPlanterHold%PlanterIndex%, "settings\nm_config.ini", "Planters", "MPlanterHold" PlanterIndex
		}
		return 1
	}
	else {
		sendinput "{" SC_E " down}"
		Sleep 100
		sendinput "{" SC_E " up}"

		hwnd := GetRobloxHWND()
		offsetY := GetYOffset(hwnd)
		Loop 50
		{
			GetRobloxClientPos(hwnd)
			pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2-200 "|" windowY+offsetY+36 "|200|120")
			if (Gdip_ImageSearch(pBMScreen, bitmaps["e_button"], , , , , , 2, , 6) = 0) {
				Gdip_DisposeImage(pBMScreen)
				break
			}
			Gdip_DisposeImage(pBMScreen)

			Sleep 100

			if (A_Index = 50)
				return 0
		}

		Sleep 50 ; wait for game to update frame
		GetRobloxClientPos(hwnd)
		if ((PlanterHarvestFull%PlanterIndex% == "Full") && !PlanterHarvestNow%PlanterIndex%) {
			loop 3 {
				pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2-250 "|" windowY+windowHeight//2-52 "|500|150")
				if (Gdip_ImageSearch(pBMScreen, bitmaps["no"], &pos, , , , , 2, , 3) = 1) {
					MouseMove windowX+windowWidth//2-250+SubStr(pos, 1, InStr(pos, ",")-1), windowY+windowHeight//2-52+SubStr(pos, InStr(pos, ",")+1)
					Sleep 150
					Click
					sleep 100
					MouseMove windowX+350, windowY+offsetY+100
					If PlanterHarvestNow%PlanterIndex%
						IniWrite 0, "settings\nm_config.ini", "Planters", "PlanterHarvestNow" PlanterIndex
					Gdip_DisposeImage(pBMScreen)
					nm_PlanterTimeUpdate(MFieldName)
					return 2
				}
				Gdip_DisposeImage(pBMScreen)
				Sleep 50 ; delay in case of lag
			}
		}
		else {
			loop 3 {
				pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2-250 "|" windowY+windowHeight//2-52 "|500|150")
				if (Gdip_ImageSearch(pBMScreen, bitmaps["yes"], &pos, , , , , 2, , 2) = 1) {
					MouseMove windowX+windowWidth//2-250+SubStr(pos, 1, InStr(pos, ",")-1), windowY+windowHeight//2-52+SubStr(pos, InStr(pos, ",")+1)
					Sleep 150
					Click
					sleep 100
					Gdip_DisposeImage(pBMScreen)
					MouseMove windowX+350, windowY+offsetY+100
					break
				}
				Gdip_DisposeImage(pBMScreen)
				Sleep 50 ; delay in case of lag
			}
		}

		PlanterHarvestNow%PlanterIndex% := 0
		IniWrite PlanterHarvestNow%PlanterIndex%, "settings\nm_config.ini", "Planters", "PlanterHarvestNow" PlanterIndex
		MPlanterSmoking%PlanterIndex% := 0
		IniWrite MPlanterSmoking%PlanterIndex%, "settings\nm_config.ini", "Planters", "MPlanterSmoking" PlanterIndex

		;reset values
		CycleIndex := PlanterManualCycle%PlanterIndex%
		if ((MPlanterName = (StrReplace(MSlot%PlanterIndex%Cycle%CycleIndex%Planter, " ") (MSlot%PlanterIndex%Cycle%CycleIndex%Planter = "Planter Of Plenty" ? "" : "Planter"))) && (MFieldName = MSlot%PlanterIndex%Cycle%CycleIndex%Field)) {
			PlanterManualCycle%PlanterIndex% := Mod(PlanterManualCycle%PlanterIndex%, MSlot%PlanterIndex%MaxCycle) + 1
			mp_UpdateCycles()
		}

		PlanterName%PlanterIndex% := "None"
		PlanterField%PlanterIndex% := "None"
		PlanterNectar%PlanterIndex% := "None"
		PlanterGlitterC%PlanterIndex% := 0
		PlanterGlitter%PlanterIndex% := 0
		PlanterHarvestFull%PlanterIndex% := ""
		PlanterHarvestTime%PlanterIndex% := 2147483647

		IniWrite PlanterName%PlanterIndex%, "settings\nm_config.ini", "Planters", "PlanterName" PlanterIndex
		IniWrite PlanterField%PlanterIndex%, "settings\nm_config.ini", "Planters", "PlanterField" PlanterIndex
		IniWrite PlanterNectar%PlanterIndex%, "settings\nm_config.ini", "Planters", "PlanterNectar" PlanterIndex
		IniWrite PlanterGlitter%PlanterIndex%, "settings\nm_config.ini", "Planters", "PlanterGlitter" PlanterIndex
		IniWrite PlanterGlitterC%PlanterIndex%, "settings\nm_config.ini", "Planters", "PlanterGlitterC" PlanterIndex
		IniWrite PlanterHarvestFull%PlanterIndex%, "settings\nm_config.ini", "Planters", "PlanterHarvestFull" PlanterIndex
		IniWrite PlanterHarvestTime%PlanterIndex%, "settings\nm_config.ini", "Planters", "PlanterHarvestTime" PlanterIndex

		TotalPlantersCollected:=TotalPlantersCollected+1
		SessionPlantersCollected:=SessionPlantersCollected+1
		PostSubmacroMessage("StatMonitor", 0x5555, 4, 1)
		IniWrite TotalPlantersCollected, "settings\nm_config.ini", "Status", "TotalPlantersCollected"
		IniWrite SessionPlantersCollected, "settings\nm_config.ini", "Status", "SessionPlantersCollected"
		;gather loot
		if (MGatherPlanterLoot = 1)
			{
				nm_setStatus("Looting", MPlanterName . " Loot")
				Sleep 1000
				nm_Move(1500*round(18/MoveSpeedNum, 2), BackKey, RightKey)
				nm_loot(9, 5, "left")
			}
		if ((MConvertFullBagHarvest = 1) && (BackpackPercent >= 95))
		{
			; loot path end location for some fields prevents successful return to hive
			If (MGatherPlanterLoot = 1) {
				If (MFieldName = "Cactus") || (MFieldName = "Sunflower") {
					sleep 200
					nm_Move(1500*round(18/MoveSpeedNum, 6), RightKey)
					sleep 200
				}
			}
			;nm_setStatus("Holding", "Inside if MConvertFullBagHarvest=1 && BackpackPercent>=95 " (MPlanterName . " (" . MFieldName . ")")) ; //testing
			nm_walkFrom(MFieldName)
			DisconnectCheck()
			nm_findHiveSlot()
		}
		return 1
	}
}
