;global gatherConfigLoc := "features\All\Gather\nm_gather_config.ini"
;global fieldConfigLoc := "features\All\Gather\field_config.ini"
global gatherConfigLoc := "settings\nm_config.ini"
global fieldConfigLoc := "settings\field_config.ini"

;this is this features GUI lines-of-code used to calculate loading progress
GatherFeatureProgressVolume := (GatherFeature) ? 160 : 0
;this is the running total of all macro features included in the load progress metric
LoadingProgressVolume := (GatherFeature) ? LoadingProgressVolume+GatherFeatureProgressVolume : LoadingProgressVolume



/*
nm_includeGatherFeature(*){
	global
	nm_importGatherConfig()
}

nm_importGatherConfig()
{
	global
	local config := Map() ; store default values, these are loaded initially

	config["Gather"] := Map("FieldName1", "Sunflower"
		, "FieldName2", "None"
		, "FieldName3", "None"
		, "FieldPattern1", "Squares"
		, "FieldPattern2", "Lines"
		, "FieldPattern3", "Lines"
		, "FieldPatternSize1", "M"
		, "FieldPatternSize2", "M"
		, "FieldPatternSize3", "M"
		, "FieldPatternReps1", 3
		, "FieldPatternReps2", 3
		, "FieldPatternReps3", 3
		, "FieldPatternShift1", 0
		, "FieldPatternShift2", 0
		, "FieldPatternShift3", 0
		, "FieldPatternInvertFB1", 0
		, "FieldPatternInvertFB2", 0
		, "FieldPatternInvertFB3", 0
		, "FieldPatternInvertLR1", 0
		, "FieldPatternInvertLR2", 0
		, "FieldPatternInvertLR3", 0
		, "FieldUntilMins1", 20
		, "FieldUntilMins2", 15
		, "FieldUntilMins3", 15
		, "FieldUntilPack1", 95
		, "FieldUntilPack2", 95
		, "FieldUntilPack3", 95
		, "FieldReturnType1", "Walk"
		, "FieldReturnType2", "Walk"
		, "FieldReturnType3", "Walk"
		, "FieldSprinklerLoc1", "Center"
		, "FieldSprinklerLoc2", "Center"
		, "FieldSprinklerLoc3", "Center"
		, "FieldSprinklerDist1", 10
		, "FieldSprinklerDist2", 10
		, "FieldSprinklerDist3", 10
		, "FieldRotateDirection1", "None"
		, "FieldRotateDirection2", "None"
		, "FieldRotateDirection3", "None"
		, "FieldRotateTimes1", 1
		, "FieldRotateTimes2", 1
		, "FieldRotateTimes3", 1
		, "FieldDriftCheck1", 1
		, "FieldDriftCheck2", 1
		, "FieldDriftCheck3", 1
		, "CurrentFieldNum", 1)


	local k, v, i, j
	for k,v in config ; load the default values as globals, will be overwritten if a new value exists when reading
		for i,j in v
			%i% := j

	;update default values with new ones read from any existing .ini
	;look for new modular files first.  For backwards compatibility: If they dont exist, look for original nm_config.ini file instead.
	local inipath := A_WorkingDir "\features\All\Gather\nm_gather_config.ini"
	local defaultinipath := A_WorkingDir "\settings\nm_config.ini"
	if FileExist(inipath) {
		nm_ReadIni(inipath)
	} else { ;look for original nm_config.ini file instead
		if FileExist(defaultinipath) { ; update default values with new ones read from original nm_config.ini
			for k,v in config
				nm_ReadIniSection(defaultinipath, k)
		}
	}

	local ini := ""
	for k,v in config ; overwrite any existing .ini with updated one with all new keys and old values
	{
		ini .= "[" k "]`r`n"
		for i in v
			ini .= i "=" %i% "`r`n"
		ini .= "`r`n"
	}

	local file := FileOpen(inipath, "w-d")
	file.Write(ini), file.Close()

}
*/
nm_GatherTab(*){
	global
	; GATHER TAB
	; ------------------------
	TabCtrl.UseTab("Gather") ; not needed since TabCtrl creation defaults to using first tab, but specified for readability
	MainGui.SetFont("w700 Underline")
	MainGui.Add("Text", "x0 y25 w126 +center +BackgroundTrans", "Gathering")
	MainGui.Add("Text", "x126 y25 w205 +center +BackgroundTrans", "Pattern")
	MainGui.Add("Text", "x331 y25 w83 +center +BackgroundTrans", "Until")
	MainGui.Add("Text", "x414 y25 w86 +center +BackgroundTrans", "Sprinkler")
	MainGui.SetFont("s8 cDefault Norm", "Tahoma")
	MainGui.Add("Text", "x2 y39 w124 +center +BackgroundTrans", "Field Rotation")
	MainGui.Add("Text", "x126 y25 w1 h206 0x7") ; 0x7 = SS_BLACKFRAME - faster drawing of lines since no text rendered
	MainGui.Add("Text", "x130 y39 w112 +center +BackgroundTrans", "Pattern Shape")
	MainGui.Add("Text", "x253 y39 w100 +BackgroundTrans", "Length")
	MainGui.Add("Text", "x295 y39 w100 +BackgroundTrans", "Width")
	MainGui.Add("Text", "x331 y25 w1 h206 0x7")
	MainGui.Add("Text", "x342 y39 w100 +BackgroundTrans", "Mins")
	MainGui.Add("Text", "x376 y39 w100 +BackgroundTrans", "Pack%")
	MainGui.Add("Text", "x412 y25 w1 h206 0x7")
	MainGui.Add("Text", "x423 y39 w100 +BackgroundTrans", "Start Location")
	MainGui.Add("Text", "x5 y53 w492 h2 0x7")
	MainGui.Add("Text", "xp y115 wp h1 0x7")
	MainGui.Add("Text", "xp yp+60 wp h1 0x7")
	MainGui.Add("Text", "xp yp+60 wp h1 0x7")
	MainGui.SetFont("w700")
	MainGui.Add("Text", "x4 y61 w10 +BackgroundTrans", "1:")
	MainGui.Add("Text", "xp yp+60 wp +BackgroundTrans", "2:")
	MainGui.Add("Text", "xp yp+60 wp +BackgroundTrans", "3:")
	MainGui.SetFont("s8 cDefault Norm", "Tahoma")
	(GuiCtrl := MainGui.Add("DropDownList", "x18 y57 w106 Disabled vFieldName1", fieldnamelist)).Text := FieldName1, GuiCtrl.OnEvent("Change", nm_FieldSelect1)
	(GuiCtrl := MainGui.Add("DropDownList", "xp yp+60 wp Disabled vFieldName2", ["None"])).Add(fieldnamelist), GuiCtrl.Text := FieldName2, GuiCtrl.OnEvent("Change", nm_FieldSelect2)
	(GuiCtrl := MainGui.Add("DropDownList", "xp yp+60 wp Disabled vFieldName3", ["None"])).Add(fieldnamelist), GuiCtrl.Text := FieldName3, GuiCtrl.OnEvent("Change", nm_FieldSelect3)
	SetLoadingProgress(floor((CurrentLoadProgress+29)/LoadingProgressVolume*100))
	hBM := Gdip_CreateHBITMAPFromBitmap(bitmaps["savefielddisabled"])
	MainGui.Add("Picture", "x2 y86 w18 h18 Disabled vSaveFieldDefault1", "HBITMAP:*" hBM).OnEvent("Click", nm_SaveFieldDefault)
	MainGui.Add("Picture", "xp yp+60 wp hp Disabled vSaveFieldDefault2", "HBITMAP:*" hBM).OnEvent("Click", nm_SaveFieldDefault)
	MainGui.Add("Picture", "xp yp+60 wp hp Disabled vSaveFieldDefault3", "HBITMAP:*" hBM).OnEvent("Click", nm_SaveFieldDefault)
	DllCall("DeleteObject", "ptr", hBM)

	(GuiCtrl := MainGui.Add("CheckBox", "x65 y83 w50 +Center Disabled vFieldDriftCheck1 Checked" FieldDriftCheck1, "Drift`nComp")).Section := "Gather", GuiCtrl.OnEvent("Click", nm_saveConfig)
	(GuiCtrl := MainGui.Add("CheckBox", "xp yp+60 wp +Center Disabled vFieldDriftCheck2 Checked" FieldDriftCheck2, "Drift`nComp")).Section := "Gather", GuiCtrl.OnEvent("Click", nm_saveConfig)
	(GuiCtrl := MainGui.Add("CheckBox", "xp yp+60 wp +Center Disabled vFieldDriftCheck3 Checked" FieldDriftCheck3, "Drift`nComp")).Section := "Gather", GuiCtrl.OnEvent("Click", nm_saveConfig)

	MainGui.Add("Button", "x115 y89 w9 h14 Disabled vFDCHelp1", "?").OnEvent("Click", nm_FDCHelp)
	MainGui.Add("Button", "xp yp+60 w9 h14 Disabled vFDCHelp2", "?").OnEvent("Click", nm_FDCHelp)
	MainGui.Add("Button", "xp yp+60 w9 h14 Disabled vFDCHelp3", "?").OnEvent("Click", nm_FDCHelp)

	MainGui.Add("Button", "x22 y82 h14 w40 Disabled vCopyGather1", "Copy").OnEvent("Click", nm_CopyGatherSettings)
	MainGui.Add("Button", "xp yp+15 hp wp Disabled vPasteGather1", "Paste").OnEvent("Click", nm_PasteGatherSettings)
	MainGui.Add("Button", "xp yp+45 hp wp Disabled vCopyGather2", "Copy").OnEvent("Click", nm_CopyGatherSettings)
	MainGui.Add("Button", "xp yp+15 hp wp Disabled vPasteGather2", "Paste").OnEvent("Click", nm_PasteGatherSettings)
	MainGui.Add("Button", "xp yp+45 hp wp Disabled vCopyGather3", "Copy").OnEvent("Click", nm_CopyGatherSettings)
	MainGui.Add("Button", "xp yp+15 hp wp Disabled vPasteGather3", "Paste").OnEvent("Click", nm_PasteGatherSettings)

	(GuiCtrl := MainGui.Add("DropDownList", "x129 y57 w112 Disabled vFieldPattern1", patternlist)).Text := FieldPattern1
	GuiCtrl.Section := "Gather", GuiCtrl.OnEvent("Change", nm_saveConfig)
	(GuiCtrl := MainGui.Add("DropDownList", "xp yp+60 wp Disabled vFieldPattern2", patternlist)).Text := FieldPattern2
	GuiCtrl.Section := "Gather", GuiCtrl.OnEvent("Change", nm_saveConfig)
	(GuiCtrl := MainGui.Add("DropDownList", "xp yp+60 wp Disabled vFieldPattern3", patternlist)).Text := FieldPattern3
	GuiCtrl.Section := "Gather", GuiCtrl.OnEvent("Change", nm_saveConfig)
	SetLoadingProgress(floor((CurrentLoadProgress+57)/LoadingProgressVolume*100))

	FieldPatternSizeArr := Map("XS",1, "S",2, "M",3, "L",4, "XL",5)
	MainGui.Add("Text", "x254 y60 h16 w12 0x201 +Center +BackgroundTrans vFieldPatternSize1", FieldPatternSize1)
	MainGui.Add("UpDown", "xp+14 yp h16 -16 Range1-5 Disabled vFieldPatternSize1UpDown", FieldPatternSizeArr[FieldPatternSize1]).OnEvent("Change", nm_FieldPatternSize)
	MainGui.Add("Text", "x254 yp+60 h16 w12 0x201 +Center +BackgroundTrans vFieldPatternSize2", FieldPatternSize2)
	MainGui.Add("UpDown", "xp+14 yp h16 -16 Range1-5 Disabled vFieldPatternSize2UpDown", FieldPatternSizeArr[FieldPatternSize2]).OnEvent("Change", nm_FieldPatternSize)
	MainGui.Add("Text", "x254 yp+60 h16 w12 0x201 +Center +BackgroundTrans vFieldPatternSize3", FieldPatternSize3)
	MainGui.Add("UpDown", "xp+14 yp h16 -16 Range1-5 Disabled vFieldPatternSize3UpDown", FieldPatternSizeArr[FieldPatternSize3]).OnEvent("Change", nm_FieldPatternSize)

	MainGui.Add("Text", "x294 y60 w28 h16 0x201 +Center")
	(GuiCtrl := MainGui.Add("UpDown", "Range1-9 Disabled vFieldPatternReps1", FieldPatternReps1)).Section := "Gather", GuiCtrl.OnEvent("Change", nm_saveConfig)
	MainGui.Add("Text", "xp yp+60 wp h16 0x201 +Center")
	(GuiCtrl := MainGui.Add("UpDown", "Range1-9 Disabled vFieldPatternReps2", FieldPatternReps2)).Section := "Gather", GuiCtrl.OnEvent("Change", nm_saveConfig)
	MainGui.Add("Text", "xp yp+60 wp h16 0x201 +Center")
	(GuiCtrl := MainGui.Add("UpDown", "Range1-9 Disabled vFieldPatternReps3", FieldPatternReps3)).Section := "Gather", GuiCtrl.OnEvent("Change", nm_saveConfig)

	(GuiCtrl := MainGui.Add("CheckBox", "x129 y82 Disabled vFieldPatternShift1 Checked" FieldPatternShift1, "Gather w/Shift-Lock")).Section := "Gather", GuiCtrl.OnEvent("Click", nm_saveConfig)
	(GuiCtrl := MainGui.Add("CheckBox", "xp yp+60 Disabled vFieldPatternShift2 Checked" FieldPatternShift2, "Gather w/Shift-Lock")).Section := "Gather", GuiCtrl.OnEvent("Click", nm_saveConfig)
	(GuiCtrl := MainGui.Add("CheckBox", "xp yp+60 Disabled vFieldPatternShift3 Checked" FieldPatternShift3, "Gather w/Shift-Lock")).Section := "Gather", GuiCtrl.OnEvent("Click", nm_saveConfig)

	MainGui.Add("Text", "x132 y97", "Invert:")
	MainGui.Add("Text", "xp yp+60", "Invert:")
	MainGui.Add("Text", "xp yp+60", "Invert:")
	(GuiCtrl := MainGui.Add("CheckBox", "x171 y97 Disabled vFieldPatternInvertFB1 Checked" FieldPatternInvertFB1, "F/B")).Section := "Gather", GuiCtrl.OnEvent("Click", nm_saveConfig)
	(GuiCtrl := MainGui.Add("CheckBox", "xp yp+60 Disabled vFieldPatternInvertFB2 Checked" FieldPatternInvertFB2, "F/B")).Section := "Gather", GuiCtrl.OnEvent("Click", nm_saveConfig)
	(GuiCtrl := MainGui.Add("CheckBox", "xp yp+60 Disabled vFieldPatternInvertFB3 Checked" FieldPatternInvertFB3, "F/B")).Section := "Gather", GuiCtrl.OnEvent("Click", nm_saveConfig)
	(GuiCtrl := MainGui.Add("CheckBox", "x208 y97 Disabled vFieldPatternInvertLR1 Checked" FieldPatternInvertLR1, "L/R")).Section := "Gather", GuiCtrl.OnEvent("Click", nm_saveConfig)
	(GuiCtrl := MainGui.Add("CheckBox", "xp yp+60 Disabled vFieldPatternInvertLR2 Checked" FieldPatternInvertLR2, "L/R")).Section := "Gather", GuiCtrl.OnEvent("Click", nm_saveConfig)
	(GuiCtrl := MainGui.Add("CheckBox", "xp yp+60 Disabled vFieldPatternInvertLR3 Checked" FieldPatternInvertLR3, "L/R")).Section := "Gather", GuiCtrl.OnEvent("Click", nm_saveConfig)
	SetLoadingProgress(floor((CurrentLoadProgress+86)/LoadingProgressVolume*100))
	MainGui.Add("Text", "x251 y79 +BackgroundTrans +Center", "Rotate Camera:")
	MainGui.Add("Text", "xp yp+60 +BackgroundTrans +Center", "Rotate Camera:")
	MainGui.Add("Text", "xp yp+60 +BackgroundTrans +Center", "Rotate Camera:")
	MainGui.Add("Text", "x258 y96 w31 +Center +BackgroundTrans vFieldRotateDirection1", FieldRotateDirection1)
	MainGui.Add("Button", "xp-12 yp-1 w12 h16 Disabled vFRD1Left", "<").OnEvent("Click", nm_FieldRotateDirection)
	MainGui.Add("Button", "xp+42 yp w12 h16 Disabled vFRD1Right", ">").OnEvent("Click", nm_FieldRotateDirection)
	MainGui.Add("Text", "x258 yp+61 w31 +Center +BackgroundTrans vFieldRotateDirection2", FieldRotateDirection2)
	MainGui.Add("Button", "xp-12 yp-1 w12 h16 Disabled vFRD2Left", "<").OnEvent("Click", nm_FieldRotateDirection)
	MainGui.Add("Button", "xp+42 yp w12 h16 Disabled vFRD2Right", ">").OnEvent("Click", nm_FieldRotateDirection)
	MainGui.Add("Text", "x258 yp+61 w31 +Center +BackgroundTrans vFieldRotateDirection3", FieldRotateDirection3)
	MainGui.Add("Button", "xp-12 yp-1 w12 h16 Disabled vFRD3Left", "<").OnEvent("Click", nm_FieldRotateDirection)
	MainGui.Add("Button", "xp+42 yp w12 h16 Disabled vFRD3Right", ">").OnEvent("Click", nm_FieldRotateDirection)

	MainGui.Add("Text", "x301 y95 w28 h16 0x201 +Center")
	(GuiCtrl := MainGui.Add("UpDown", "Range1-4 Disabled vFieldRotateTimes1", FieldRotateTimes1)).Section := "Gather", GuiCtrl.OnEvent("Change", nm_saveConfig)
	MainGui.Add("Text", "xp yp+60 wp h16 0x201 +Center")
	(GuiCtrl := MainGui.Add("UpDown", "Range1-4 Disabled vFieldRotateTimes2", FieldRotateTimes2)).Section := "Gather", GuiCtrl.OnEvent("Change", nm_saveConfig)
	MainGui.Add("Text", "xp yp+60 wp h16 0x201 +Center")
	(GuiCtrl := MainGui.Add("UpDown", "Range1-4 Disabled vFieldRotateTimes3", FieldRotateTimes3)).Section := "Gather", GuiCtrl.OnEvent("Change", nm_saveConfig)

	(GuiCtrl := MainGui.Add("Edit", "x334 y58 w36 h20 limit4 number Disabled vFieldUntilMins1", ValidateInt(&FieldUntilMins1, 10))).Section := "Gather", GuiCtrl.OnEvent("Change", nm_saveConfig)
	(GuiCtrl := MainGui.Add("Edit", "xp yp+60 wp h20 limit4 number Disabled vFieldUntilMins2", ValidateInt(&FieldUntilMins2, 10))).Section := "Gather", GuiCtrl.OnEvent("Change", nm_saveConfig)
	(GuiCtrl := MainGui.Add("Edit", "xp yp+60 wp h20 limit4 number Disabled vFieldUntilMins3", ValidateInt(&FieldUntilMins3, 10))).Section := "Gather", GuiCtrl.OnEvent("Change", nm_saveConfig)

	MainGui.Add("Text", "x375 y60 h16 w16 0x201 +Center +BackgroundTrans vFieldUntilPack1", FieldUntilPack1)
	MainGui.Add("UpDown", "xp+18 yp h16 -16 Range1-20 Disabled vFieldUntilPack1UpDown", FieldUntilPack1//5).OnEvent("Change", nm_FieldUntilPack)
	MainGui.Add("Text", "x375 yp+60 h16 w16 0x201 +Center +BackgroundTrans vFieldUntilPack2", FieldUntilPack2)
	MainGui.Add("UpDown", "xp+18 yp h16 -16 Range1-20 Disabled vFieldUntilPack2UpDown", FieldUntilPack2//5).OnEvent("Change", nm_FieldUntilPack)
	MainGui.Add("Text", "x375 yp+60 h16 w16 0x201 +Center +BackgroundTrans vFieldUntilPack3", FieldUntilPack3)
	MainGui.Add("UpDown", "xp+18 yp h16 -16 Range1-20 Disabled vFieldUntilPack3UpDown", FieldUntilPack3//5).OnEvent("Change", nm_FieldUntilPack)
	SetLoadingProgress(floor((CurrentLoadProgress+118)/LoadingProgressVolume*100))

	MainGui.Add("Text", "x327 y79 w93 +BackgroundTrans +Center", "To Hive By:")
	MainGui.Add("Text", "xp yp+60 wp +BackgroundTrans +Center", "To Hive By:")
	MainGui.Add("Text", "xp yp+60 wp +BackgroundTrans +Center", "To Hive By:")
	MainGui.Add("Text", "x356 y96 w33 +Center +BackgroundTrans vFieldReturnType1", FieldReturnType1)
	MainGui.Add("Button", "xp-16 yp-1 w12 h16 Disabled vFRT1Left", "<").OnEvent("Click", nm_FieldReturnType)
	MainGui.Add("Button", "xp+52 yp w12 h16 Disabled vFRT1Right", ">").OnEvent("Click", nm_FieldReturnType)
	MainGui.Add("Text", "x356 yp+61 w33 +Center +BackgroundTrans vFieldReturnType2", FieldReturnType2)
	MainGui.Add("Button", "xp-16 yp-1 w12 h16 Disabled vFRT2Left", "<").OnEvent("Click", nm_FieldReturnType)
	MainGui.Add("Button", "xp+52 yp w12 h16 Disabled vFRT2Right", ">").OnEvent("Click", nm_FieldReturnType)
	MainGui.Add("Text", "x356 yp+61 w33 +Center +BackgroundTrans vFieldReturnType3", FieldReturnType3)
	MainGui.Add("Button", "xp-16 yp-1 w12 h16 Disabled vFRT3Left", "<").OnEvent("Click", nm_FieldReturnType)
	MainGui.Add("Button", "xp+52 yp w12 h16 Disabled vFRT3Right", ">").OnEvent("Click", nm_FieldReturnType)

	MainGui.Add("Text", "x427 y61 w60 +Center +BackgroundTrans vFieldSprinklerLoc1", FieldSprinklerLoc1)
	MainGui.Add("Button", "xp-12 yp-1 w12 h16 Disabled vFSL1Left", "<").OnEvent("Click", nm_FieldSprinklerLoc)
	MainGui.Add("Button", "xp+71 yp w12 h16 Disabled vFSL1Right", ">").OnEvent("Click", nm_FieldSprinklerLoc)
	MainGui.Add("Text", "x427 yp+61 w60 +Center +BackgroundTrans vFieldSprinklerLoc2", FieldSprinklerLoc2)
	MainGui.Add("Button", "xp-12 yp-1 w12 h16 Disabled vFSL2Left", "<").OnEvent("Click", nm_FieldSprinklerLoc)
	MainGui.Add("Button", "xp+71 yp w12 h16 Disabled vFSL2Right", ">").OnEvent("Click", nm_FieldSprinklerLoc)
	MainGui.Add("Text", "x427 yp+61 w60 +Center +BackgroundTrans vFieldSprinklerLoc3", FieldSprinklerLoc3)
	MainGui.Add("Button", "xp-12 yp-1 w12 h16 Disabled vFSL3Left", "<").OnEvent("Click", nm_FieldSprinklerLoc)
	MainGui.Add("Button", "xp+71 yp w12 h16 Disabled vFSL3Right", ">").OnEvent("Click", nm_FieldSprinklerLoc)

	MainGui.Add("Text", "x415 y79 w86 +BackgroundTrans +Center", "Distance:")
	MainGui.Add("Text", "xp yp+60 wp +BackgroundTrans +Center", "Distance:")
	MainGui.Add("Text", "xp yp+60 wp +BackgroundTrans +Center", "Distance:")
	MainGui.Add("Text", "x440 y95 w32 h16 0x201 +Center")
	(GuiCtrl := MainGui.Add("UpDown", "Range1-10 Disabled vFieldSprinklerDist1", FieldSprinklerDist1)).Section := "Gather", GuiCtrl.OnEvent("Change", nm_saveConfig)
	MainGui.Add("Text", "xp yp+60 wp h16 0x201 +Center")
	(GuiCtrl := MainGui.Add("UpDown", "Range1-10 Disabled vFieldSprinklerDist2", FieldSprinklerDist2)).Section := "Gather", GuiCtrl.OnEvent("Change", nm_saveConfig)
	MainGui.Add("Text", "xp yp+60 wp h16 0x201 +Center")
	(GuiCtrl := MainGui.Add("UpDown", "Range1-10 Disabled vFieldSprinklerDist3", FieldSprinklerDist3)).Section := "Gather", GuiCtrl.OnEvent("Change", nm_saveConfig)
	CurrentLoadProgress:=CurrentLoadProgress+GatherFeatureProgressVolume
	SetLoadingProgress(floor(CurrentLoadProgress/LoadingProgressVolume*100))
}



nm_FieldSelect1(GuiCtrl?, *){
	global FieldName1, CurrentFieldNum, CurrentField
	if IsSet(GuiCtrl) {
		FieldName1 := MainGui["FieldName1"].Text
		nm_FieldDefaults(1)
		;IniWrite FieldName1, gatherConfigLoc, "Gather", "FieldName1"
		IniWrite FieldName1, gatherConfigLoc, "Gather", "FieldName1"
	}
	CurrentFieldNum:=1
	IniWrite CurrentFieldNum, gatherConfigLoc, "Gather", "CurrentFieldNum"
	MainGui["CurrentField"].Text := FieldName1
	CurrentField:=FieldName1
	nm_WebhookEasterEgg()
}
nm_FieldSelect2(GuiCtrl?, *){
	global
	local hBM
	if IsSet(GuiCtrl)
		FieldName2 := MainGui["FieldName2"].Text
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
		hBM := Gdip_CreateHBITMAPFromBitmap(bitmaps["savefield"])
		MainGui["SaveFieldDefault2"].Value := "HBITMAP:*" hBM
		DllCall("DeleteObject", "ptr", hBM)
	} else {
		FieldName1 := MainGui["FieldName1"].Text
		CurrentFieldNum:=1
		IniWrite CurrentFieldNum, gatherConfigLoc, "Gather", "CurrentFieldNum"
		MainGui["CurrentField"].Text := FieldName1
		CurrentField:=FieldName1
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
		MainGui["PasteGather3"].Enabled := 0
		MainGui["SaveFieldDefault2"].Enabled := 0
		hBM := Gdip_CreateHBITMAPFromBitmap(bitmaps["savefielddisabled"])
		MainGui["SaveFieldDefault2"].Value := "HBITMAP:*" hBM
		DllCall("DeleteObject", "ptr", hBM)
		MainGui["FieldName3"].Text := "None"
		MainGui["FieldName3"].Enabled := 0
		nm_fieldSelect3(1)
	}
	if IsSet(GuiCtrl) {
		nm_FieldDefaults(2)
		IniWrite FieldName2, gatherConfigLoc, "Gather", "FieldName2"
	}
	nm_WebhookEasterEgg()
}
nm_FieldSelect3(GuiCtrl?, *){
	global
	local hBM
	if IsSet(GuiCtrl)
		FieldName3 := MainGui["FieldName3"].Text
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
		hBM := Gdip_CreateHBITMAPFromBitmap(bitmaps["savefield"])
		MainGui["SaveFieldDefault3"].Value := "HBITMAP:*" hBM
		DllCall("DeleteObject", "ptr", hBM)
	} else {
		FieldName1 := MainGui["FieldName1"].Text
		CurrentFieldNum:=1
		IniWrite CurrentFieldNum, gatherConfigLoc, "Gather", "CurrentFieldNum"
		MainGui["CurrentField"].Text := FieldName1
		CurrentField:=FieldName1
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
		MainGui["SaveFieldDefault3"].Enabled := 0
		hBM := Gdip_CreateHBITMAPFromBitmap(bitmaps["savefielddisabled"])
		MainGui["SaveFieldDefault3"].Value := "HBITMAP:*" hBM
		DllCall("DeleteObject", "ptr", hBM)
	}
	if IsSet(GuiCtrl) {
		nm_FieldDefaults(3)
		IniWrite FieldName3, gatherConfigLoc, "Gather", "FieldName3"
	}
	nm_WebhookEasterEgg()
}
nm_FieldDefaults(num){
	global FieldDefault, FieldPatternSizeArr
		, FieldName1, FieldName2, FieldName3
		, FieldPattern1, FieldPattern2, FieldPattern3
		, FieldPatternSize1, FieldPatternSize2, FieldPatternSize3
		, FieldPatternReps1, FieldPatternReps2, FieldPatternReps3
		, FieldPatternShift1, FieldPatternShift2, FieldPatternShift3
		, FieldPatternInvertFB1, FieldPatternInvertFB2, FieldPatternInvertFB3
		, FieldPatternInvertLR1, FieldPatternInvertLR2, FieldPatternInvertLR3
		, FieldUntilMins1, FieldUntilMins2, FieldUntilMins3
		, FieldUntilPack1, FieldUntilPack2, FieldUntilPack3
		, FieldReturnType1, FieldReturnType2, FieldReturnType3
		, FieldSprinklerLoc1, FieldSprinklerLoc2, FieldSprinklerLoc3
		, FieldSprinklerDist1, FieldSprinklerDist2, FieldSprinklerDist3
		, FieldRotateDirection1, FieldRotateDirection2, FieldRotateDirection3
		, FieldRotateTimes1, FieldRotateTimes2, FieldRotateTimes3
		, FieldDriftCheck1, FieldDriftCheck2, FieldDriftCheck3
		, patternlist, disableSave:=1

	FieldName%num% := MainGui["FieldName" num].Text
	if(FieldName%num%="none") {
		FieldPattern%num%:="Lines"
		FieldPatternSize%num%:="M"
		FieldPatternReps%num%:=3
		FieldPatternShift%num%:=0
		FieldPatternInvertFB%num%:=0
		FieldPatternInvertLR%num%:=0
		FieldUntilMins%num%:=15
		FieldUntilPack%num%:=95
		FieldReturnType%num%:="Walk"
		FieldSprinklerLoc%num%:="Center"
		FieldSprinklerDist%num%:=10
		FieldRotateDirection%num%:="None"
		FieldRotateTimes%num%:=1
		FieldDriftCheck%num%:=1
	} else {
		FieldPattern%num%:=FieldDefault[FieldName%num%]["pattern"]
		FieldPatternSize%num%:=FieldDefault[FieldName%num%]["size"]
		FieldPatternReps%num%:=FieldDefault[FieldName%num%]["width"]
		FieldPatternShift%num%:=FieldDefault[FieldName%num%]["shiftlock"]
		FieldPatternInvertFB%num%:=FieldDefault[FieldName%num%]["invertFB"]
		FieldPatternInvertLR%num%:=FieldDefault[FieldName%num%]["invertLR"]
		FieldUntilMins%num%:=FieldDefault[FieldName%num%]["gathertime"]
		FieldUntilPack%num%:=FieldDefault[FieldName%num%]["percent"]
		FieldReturnType%num%:=FieldDefault[FieldName%num%]["convert"]
		FieldSprinklerLoc%num%:=FieldDefault[FieldName%num%]["sprinkler"]
		FieldSprinklerDist%num%:=FieldDefault[FieldName%num%]["distance"]
		FieldRotateDirection%num%:=FieldDefault[FieldName%num%]["camera"]
		FieldRotateTimes%num%:=FieldDefault[FieldName%num%]["turns"]
		FieldDriftCheck%num%:=FieldDefault[FieldName%num%]["drift"]
	}
	MainGui["FieldPattern" num].Text := FieldPattern%num%
	MainGui["FieldPatternSize" num].Text := FieldPatternSize%num%
	MainGui["FieldPatternSize" num "UpDown"].Value := FieldPatternSizeArr[FieldPatternSize%num%]
	MainGui["FieldPatternReps" num].Value := FieldPatternReps%num%
	MainGui["FieldPatternShift" num].Value := FieldPatternShift%num%
	MainGui["FieldPatternInvertFB" num].Value := FieldPatternInvertFB%num%
	MainGui["FieldPatternInvertLR" num].Value := FieldPatternInvertLR%num%
	MainGui["FieldUntilMins" num].Value := FieldUntilMins%num%
	MainGui["FieldUntilPack" num].Text := FieldUntilPack%num%
	MainGui["FieldUntilPack" num "UpDown"].Value := FieldUntilPack%num%//5
	MainGui["FieldReturnType" num].Text := FieldReturnType%num%
	MainGui["FieldSprinklerLoc" num].Text := FieldSprinklerLoc%num%
	MainGui["FieldSprinklerDist" num].Value := FieldSprinklerDist%num%
	MainGui["FieldRotateDirection" num].Text := FieldRotateDirection%num%
	MainGui["FieldRotateTimes" num].Value := FieldRotateTimes%num%
	MainGui["FieldDriftCheck" num].Value := FieldDriftCheck%num%
	IniWrite FieldPattern%num%, gatherConfigLoc, "Gather", "FieldPattern" num
	IniWrite FieldPatternSize%num%, gatherConfigLoc, "Gather", "FieldPatternSize" num
	IniWrite FieldPatternReps%num%, gatherConfigLoc, "Gather", "FieldPatternReps" num
	IniWrite FieldPatternShift%num%, gatherConfigLoc, "Gather", "FieldPatternShift" num
	IniWrite FieldPatternInvertFB%num%, gatherConfigLoc, "Gather", "FieldPatternInvertFB" num
	IniWrite FieldPatternInvertLR%num%, gatherConfigLoc, "Gather", "FieldPatternInvertLR" num
	IniWrite FieldUntilMins%num%, gatherConfigLoc, "Gather", "FieldUntilMins" num
	IniWrite FieldUntilPack%num%, gatherConfigLoc, "Gather", "FieldUntilPack" num
	IniWrite FieldReturnType%num%, gatherConfigLoc, "Gather", "FieldReturnType" num
	IniWrite FieldSprinklerLoc%num%, gatherConfigLoc, "Gather", "FieldSprinklerLoc" num
	IniWrite FieldSprinklerDist%num%, gatherConfigLoc, "Gather", "FieldSprinklerDist" num
	IniWrite FieldRotateDirection%num%, gatherConfigLoc, "Gather", "FieldRotateDirection" num
	IniWrite FieldRotateTimes%num%, gatherConfigLoc, "Gather", "FieldRotateTimes" num
	IniWrite FieldDriftCheck%num%, gatherConfigLoc, "Gather", "FieldDriftCheck" num
	disableSave:=0
}
nm_FDCHelp(*){
	MsgBox "
	(
	DESCRIPTION:
	Field Drift Compensation is a way to stop what we call field drift (AKA falling/running out of the field.)
	Enabling this checkbox will re-align you to your saturator every so often by searching for the neon blue pixel and moving towards it.

	Note that this feature requires The Supreme Saturator, otherwise you will drift more. If you would like more info, join our Discord.
	)", "Field Drift Compensation", 0x40000
}
nm_FieldPatternSize(GuiCtrl, *){
	global
	static arr := ["XS","S","M","L","XL"]
	local k
	MainGui[k := StrReplace(GuiCtrl.Name, "UpDown")].Text := %k% := arr[GuiCtrl.Value]
	IniWrite %k%, gatherConfigLoc, "Gather", k
}
nm_FieldRotateDirection(GuiCtrl, *){
	global
	static val := ["None", "Left", "Right"], l := val.Length
	local i, index

	switch GuiCtrl.Name, 0
	{
		case "FRD1Left", "FRD1Right":
		index := 1
		case "FRD2Left", "FRD2Right":
		index := 2
		case "FRD3Left", "FRD3Right":
		index := 3
	}

	i := (FieldRotateDirection%index% = "None") ? 1 : (FieldRotateDirection%index% = "Left") ? 2 : 3

	MainGui["FieldRotateDirection" index].Text := FieldRotateDirection%index% := val[(GuiCtrl.Name = "FRD" index "Right") ? (Mod(i, l) + 1) : (Mod(l + i - 2, l) + 1)]
	IniWrite FieldRotateDirection%index%, gatherConfigLoc, "Gather", "FieldRotateDirection" index
}
nm_FieldUntilPack(GuiCtrl, *){
	global
	local k
	MainGui[k := StrReplace(GuiCtrl.Name, "UpDown")].Text := %k% := GuiCtrl.Value * 5
	IniWrite %k%, gatherConfigLoc, "Gather", k
}
nm_FieldReturnType(GuiCtrl, *){
	global
	static val := ["Walk", "Reset"], l := val.Length
	local i, index

	switch GuiCtrl.Name, 0
	{
		case "FRT1Left", "FRT1Right":
		index := 1
		case "FRT2Left", "FRT2Right":
		index := 2
		case "FRT3Left", "FRT3Right":
		index := 3
	}

	i := (FieldReturnType%index% = "Walk") ? 1 : 2

	MainGui["FieldReturnType" index].Text := FieldReturnType%index% := val[(GuiCtrl.Name = "FRT" index "Right") ? (Mod(i, l) + 1) : (Mod(l + i - 2, l) + 1)]
	IniWrite FieldReturnType%index%, gatherConfigLoc, "Gather", "FieldReturnType" index
}
nm_FieldSprinklerLoc(GuiCtrl, *){
	global
	static val := ["Center", "Upper Left", "Upper", "Upper Right", "Right", "Lower Right", "Lower", "Lower Left", "Left"], l := val.Length
	local i, index

	switch GuiCtrl.Name, 0
	{
		case "FSL1Left", "FSL1Right":
		index := 1
		case "FSL2Left", "FSL2Right":
		index := 2
		case "FSL3Left", "FSL3Right":
		index := 3
	}

	switch FieldSprinklerLoc%index%, 0
	{
		case "Center":
		i := 1
		case "Upper Left":
		i := 2
		case "Upper":
		i := 3
		case "Upper Right":
		i := 4
		case "Right":
		i := 5
		case "Lower Right":
		i := 6
		case "Lower":
		i := 7
		case "Lower Left":
		i := 8
		default:
		i := 9
	}

	MainGui["FieldSprinklerLoc" index].Text := FieldSprinklerLoc%index% := val[(GuiCtrl.Name = "FSL" index "Right") ? (Mod(i, l) + 1) : (Mod(l + i - 2, l) + 1)]
	IniWrite FieldSprinklerLoc%index%, gatherConfigLoc, "Gather", "FieldSprinklerLoc" index
}
nm_SaveFieldDefault(GuiCtrl, *){
	global
	local i,k,v
	i := SubStr(GuiCtrl.Name, -1)
	if (FieldName%i% != "None")
	{
		if (MsgBox("Update " FieldName%i% " default settings with the currently selected settings? These will become the default settings when you change to this field.`n`n"
			. "The macro will use the updated settings when gathering for Quests/Planters.", "Change Field Defaults", 0x40044 " Owner" MainGui.Hwnd) = "Yes")
		{
			FieldDefault[FieldName%i%]["pattern"]:=FieldPattern%i%
			FieldDefault[FieldName%i%]["size"]:=FieldPatternSize%i%
			FieldDefault[FieldName%i%]["width"]:=FieldPatternReps%i%
			FieldDefault[FieldName%i%]["shiftlock"]:=FieldPatternShift%i%
			FieldDefault[FieldName%i%]["invertFB"]:=FieldPatternInvertFB%i%
			FieldDefault[FieldName%i%]["invertLR"]:=FieldPatternInvertLR%i%
			FieldDefault[FieldName%i%]["gathertime"]:=FieldUntilMins%i%
			FieldDefault[FieldName%i%]["percent"]:=FieldUntilPack%i%
			FieldDefault[FieldName%i%]["convert"]:=FieldReturnType%i%
			FieldDefault[FieldName%i%]["sprinkler"]:=FieldSprinklerLoc%i%
			FieldDefault[FieldName%i%]["distance"]:=FieldSprinklerDist%i%
			FieldDefault[FieldName%i%]["camera"]:=FieldRotateDirection%i%
			FieldDefault[FieldName%i%]["turns"]:=FieldRotateTimes%i%
			FieldDefault[FieldName%i%]["drift"]:=FieldDriftCheck%i%
			for k,v in FieldDefault[FieldName%i%]
				IniWrite v, fieldConfigLoc, FieldName%i%, k
		}
	}
}
nm_CopyGatherSettings(GuiCtrl, *){
	static q := Chr(34), ob := Chr(123), cb := Chr(125)
	local i := SubStr(GuiCtrl.Name, -1)
	A_Clipboard := ob q "Name" q ":" q FieldName%i% q ","
		. q "Pattern" q ":" q FieldPattern%i% q ","
		. q "DriftCheck" q ":" FieldDriftCheck%i% ","
		. q "PatternInvertFB" q ":" FieldPatternInvertFB%i% ","
		. q "PatternInvertLR" q ":" FieldPatternInvertLR%i% ","
		. q "PatternReps" q ":" FieldPatternReps%i% ","
		. q "PatternShift" q ":" FieldPatternShift%i% ","
		. q "PatternSize" q ":" q FieldPatternSize%i% q ","
		. q "ReturnType" q ":" q FieldReturnType%i% q ","
		. q "RotateDirection" q ":" q FieldRotateDirection%i% q ","
		. q "RotateTimes" q ":" FieldRotateTimes%i% ","
		. q "SprinklerDist" q ":" FieldSprinklerDist%i% ","
		. q "SprinklerLoc" q ":" q FieldSprinklerLoc%i% q ","
		. q "UntilMins" q ":" FieldUntilMins%i% ","
		. q "UntilPack" q ":" FieldUntilPack%i% cb
}
nm_PasteGatherSettings(GuiCtrl, *){
	global
	static validation := Map("DriftCheck", "^(0|1)$"
		, "PatternInvertFB", "^(0|1)$"
		, "PatternInvertLR", "^(0|1)$"
		, "PatternReps", "^[1-9]$"
		, "PatternShift", "^(0|1)$"
		, "PatternSize", "i)^(XS|S|M|L|XL)$"
		, "ReturnType", "i)^(Walk|Reset)$"
		, "RotateDirection", "i)^(None|Left|Right)$"
		, "RotateTimes", "^[1-4]$"
		, "SprinklerDist", "^([1-9]|10)$"
		, "SprinklerLoc", "i)^(Center|Upper Left|Upper|Upper Right|Right|Lower Right|Lower|Lower Left|Left)$"
		, "UntilMins", "^\d{1,4}$"
		, "UntilPack", "^(5|10|15|20|25|30|35|40|45|50|55|60|65|70|75|80|85|90|95|100)$"), q := Chr(34)
	local i := SubStr(GuiCtrl.Name, -1), obj, ctrl

	If (!RegExMatch(A_Clipboard, "^\s*\{.*\}\s*$")){
		MsgBox "Your String Format is incorrect!`nMake sure you also copy the " q "{" q " and the " q "}" q, "WARNING!!", 0x1030 " T60"
		Return
	}
	obj := json.parse(A_Clipboard)
	if obj.Has("Name") {
		if ObjHasValue(fieldnamelist, obj["Name"]) {
			FieldName%i% := obj["Name"]
			IniWrite obj["Name"], gatherConfigLoc, "Gather", "FieldName" i
			MainGui["FieldName" i].Text := FieldName%i%
		} else
			MsgBox "The Field Name you tried to import is NOT valid!`nMake sure you copied the string correctly.`nSpecific: " obj["Name"], "WARNING!!", 0x1030 " T60"
	}
	if obj.Has("Pattern") {
		if ObjHasValue(patternlist, obj["Pattern"]) {
			FieldPattern%i% := obj["Pattern"]
			IniWrite obj["Pattern"], gatherConfigLoc, "Gather", "FieldPattern" i
			MainGui["FieldPattern" i].Text := FieldPattern%i%
		} else
			MsgBox "The Pattern you tried to import is NOT valid!`nMake sure you copied the string correctly and have the pattern installed.`nSpecific: " obj["Pattern"], "WARNING!!", 0x1030 " T60"
	}
	for k,v in validation {
		if obj.Has(k) {
			if (obj[k] ~= v) {
				Field%k%%i% := obj[k]
				IniWrite obj[k], gatherConfigLoc, "Gather", "Field" k i
				ctrl := MainGui["Field" k i]
				switch ctrl.Type, 0 {
					case "DDL", "Text":
					ctrl.Text := obj[k]
					default:
					ctrl.Value := obj[k]
				}
			} else
				MsgBox "The item you tried to import is NOT valid!`nMake sure you copied the string correctly.`nSpecific: " k ":" obj[k], "WARNING!!", 0x1030 " T60"
		}
	}
	nm_FieldSelect%i%()
}
nm_WebhookEasterEgg(){
	global WebhookEasterEgg
	FieldName1 := MainGui["FieldName1"].Text
	FieldName2 := MainGui["FieldName2"].Text
	FieldName3 := MainGui["FieldName3"].Text
	if ((FieldName1 = FieldName2) && (FieldName2 = FieldName3))
	{
		If(MsgBox("You found an easter egg!`nEnable Rainbow Webhook?", , 0x1024 " Owner" MainGui.Hwnd) = "Yes")
			WebhookEasterEgg := 1
		else
			WebhookEasterEgg := 0
		IniWrite WebhookEasterEgg, gatherConfigLoc, "Status", "WebhookEasterEgg"
		PostSubmacroMessage("Status", 0x5552, 5, WebhookEasterEgg)
	}
}
/*
;update config
nm_saveGatherConfig(GuiCtrl, *){
	global
	switch GuiCtrl.Type, 0 {
		case "DDL":
		%GuiCtrl.Name% := GuiCtrl.Text
		default: ; "CheckBox", "Edit", "UpDown", "Slider"
		%GuiCtrl.Name% := GuiCtrl.Value
	}
	IniWrite %GuiCtrl.Name%, gatherConfigLoc, GuiCtrl.Section, GuiCtrl.Name
}
*/
nm_importFieldDefaults()
{
	global FieldDefault := Map()
	FieldDefault.CaseSense := 0

	FieldDefault["Sunflower"] := Map("pattern", "CornerXSnake"
		, "size", "M"
		, "width", 4
		, "camera", "None"
		, "turns", 1
		, "sprinkler", "Upper Left"
		, "distance", 8
		, "percent", 95
		, "gathertime", 10
		, "convert", "Walk"
		, "drift", 0
		, "shiftlock", 0
		, "invertFB", 0
		, "invertLR", 1)

	FieldDefault["Dandelion"] := Map("pattern", "CornerXSnake"
		, "size", "M"
		, "width", 6
		, "camera", "None"
		, "turns", 1
		, "sprinkler", "Upper Left"
		, "distance", 10
		, "percent", 95
		, "gathertime", 10
		, "convert", "Walk"
		, "drift", 0
		, "shiftlock", 0
		, "invertFB", 0
		, "invertLR", 1)

	FieldDefault["Mushroom"] := Map("pattern", "CornerXSnake"
		, "size", "M"
		, "width", 2
		, "camera", "None"
		, "turns", 1
		, "sprinkler", "Upper Left"
		, "distance", 8
		, "percent", 95
		, "gathertime", 10
		, "convert", "Walk"
		, "drift", 0
		, "shiftlock", 0
		, "invertFB", 0
		, "invertLR", 1)

	FieldDefault["Blue Flower"] := Map("pattern", "CornerXSnake"
		, "size", "M"
		, "width", 7
		, "camera", "Right"
		, "turns", 2
		, "sprinkler", "Center"
		, "distance", 1
		, "percent", 95
		, "gathertime", 10
		, "convert", "Walk"
		, "drift", 0
		, "shiftlock", 0
		, "invertFB", 0
		, "invertLR", 0)

	FieldDefault["Clover"] := Map("pattern", "Stationary"
		, "size", "S"
		, "width", 1
		, "camera", "None"
		, "turns", 1
		, "sprinkler", "Center"
		, "distance", 1
		, "percent", 95
		, "gathertime", 10
		, "convert", "Walk"
		, "drift", 0
		, "shiftlock", 0
		, "invertFB", 0
		, "invertLR", 0)

	FieldDefault["Spider"] := Map("pattern", "CornerXSnake"
		, "size", "M"
		, "width", 1
		, "camera", "None"
		, "turns", 1
		, "sprinkler", "Upper Left"
		, "distance", 6
		, "percent", 95
		, "gathertime", 10
		, "convert", "Walk"
		, "drift", 0
		, "shiftlock", 0
		, "invertFB", 0
		, "invertLR", 1)

	FieldDefault["Strawberry"] := Map("pattern", "CornerXSnake"
		, "size", "M"
		, "width", 1
		, "camera", "Right"
		, "turns", 2
		, "sprinkler", "Upper Right"
		, "distance", 6
		, "percent", 95
		, "gathertime", 10
		, "convert", "Walk"
		, "drift", 0
		, "shiftlock", 0
		, "invertFB", 0
		, "invertLR", 1)

	FieldDefault["Bamboo"] := Map("pattern", "CornerXSnake"
		, "size", "M"
		, "width", 3
		, "camera", "Left"
		, "turns", 2
		, "sprinkler", "Upper Left"
		, "distance", 4
		, "percent", 95
		, "gathertime", 10
		, "convert", "Walk"
		, "drift", 0
		, "shiftlock", 0
		, "invertFB", 0
		, "invertLR", 1)

	FieldDefault["Pineapple"] := Map("pattern", "CornerXSnake"
		, "size", "M"
		, "width", 1
		, "camera", "None"
		, "turns", 1
		, "sprinkler", "Upper Left"
		, "distance", 8
		, "percent", 95
		, "gathertime", 10
		, "convert", "Walk"
		, "drift", 0
		, "shiftlock", 0
		, "invertFB", 0
		, "invertLR", 1)

	FieldDefault["Stump"] := Map("pattern", "Stationary"
		, "size", "S"
		, "width", 1
		, "camera", "None"
		, "turns", 1
		, "sprinkler", "Center"
		, "distance", 1
		, "percent", 95
		, "gathertime", 10
		, "convert", "Walk"
		, "drift", 0
		, "shiftlock", 0
		, "invertFB", 0
		, "invertLR", 0)

	FieldDefault["Cactus"] := Map("pattern", "Stationary"
		, "size", "S"
		, "width", 1
		, "camera", "None"
		, "turns", 1
		, "sprinkler", "Center"
		, "distance", 1
		, "percent", 95
		, "gathertime", 10
		, "convert", "Walk"
		, "drift", 0
		, "shiftlock", 0
		, "invertFB", 0
		, "invertLR", 0)

	FieldDefault["Pumpkin"] := Map("pattern", "CornerXSnake"
		, "size", "M"
		, "width", 5
		, "camera", "Right"
		, "turns", 2
		, "sprinkler", "Right"
		, "distance", 8
		, "percent", 95
		, "gathertime", 10
		, "convert", "Walk"
		, "drift", 0
		, "shiftlock", 0
		, "invertFB", 0
		, "invertLR", 1)

	FieldDefault["Pine Tree"] := Map("pattern", "CornerXSnake"
		, "size", "M"
		, "width", 3
		, "camera", "Left"
		, "turns", 2
		, "sprinkler", "Upper Left"
		, "distance", 7
		, "percent", 95
		, "gathertime", 10
		, "convert", "Walk"
		, "drift", 0
		, "shiftlock", 0
		, "invertFB", 0
		, "invertLR", 0)

	FieldDefault["Rose"] := Map("pattern", "CornerXSnake"
		, "size", "M"
		, "width", 1
		, "camera", "Left"
		, "turns", 4
		, "sprinkler", "Lower Right"
		, "distance", 10
		, "percent", 95
		, "gathertime", 10
		, "convert", "Walk"
		, "drift", 0
		, "shiftlock", 0
		, "invertFB", 0
		, "invertLR", 1)

	FieldDefault["Mountain Top"] := Map("pattern", "CornerXSnake"
		, "size", "M"
		, "width", 3
		, "camera", "Left"
		, "turns", 4
		, "sprinkler", "Lower Left"
		, "distance", 5
		, "percent", 95
		, "gathertime", 10
		, "convert", "Walk"
		, "drift", 0
		, "shiftlock", 0
		, "invertFB", 0
		, "invertLR", 0)

	FieldDefault["Coconut"] := Map("pattern", "CornerXSnake"
		, "size", "M"
		, "width", 3
		, "camera", "Right"
		, "turns", 2
		, "sprinkler", "Right"
		, "distance", 6
		, "percent", 95
		, "gathertime", 10
		, "convert", "Walk"
		, "drift", 0
		, "shiftlock", 0
		, "invertFB", 0
		, "invertLR", 1)

	FieldDefault["Pepper"] := Map("pattern", "CornerXSnake"
		, "size", "M"
		, "width", 5
		, "camera", "None"
		, "turns", 1
		, "sprinkler", "Upper Right"
		, "distance", 7
		, "percent", 95
		, "gathertime", 10
		, "convert", "Walk"
		, "drift", 0
		, "shiftlock", 0
		, "invertFB", 0
		, "invertLR", 0)

	global StandardFieldDefault := ObjFullyClone(FieldDefault)

	inipath := A_WorkingDir "\" fieldConfigLoc

	if FileExist(inipath) ; update default values with new ones read from any existing .ini
		nm_LoadFieldDefaults()

	; reset pattern to default if not exist
	global FieldPattern1, FieldPattern2, FieldPattern3
	loop 3 {
		i := A_Index
		if (FieldName%i% != "None") {
			for pattern in patternlist
				if (pattern = FieldPattern%i%)
					continue 2
			FieldPattern%i% := FieldDefault[FieldName%i%]["pattern"]
		}
	}

	ini := ""
	for k,v in FieldDefault ; overwrite any existing .ini with updated one with all new keys and old values
	{
		ini .= "[" k "]`r`n"
		for i,j in v
			ini .= i "=" j "`r`n"
		ini .= "`r`n"
	}
	file := FileOpen(inipath, "w-d"), file.Write(ini), file.Close()
}

nm_LoadFieldDefaults()
{
	global FieldDefault

	ini := FileOpen(A_WorkingDir "\" fieldConfigLoc, "r"), str := ini.Read(), ini.Close()
	Loop Parse str, "`n", "`r" A_Space A_Tab
	{
		switch (c := SubStr(A_LoopField, 1, 1))
		{
			; ignore comments and section names
			case "[":
			s := SubStr(A_LoopField, 2, -1)

			case ";":
			continue

			default:
			if (p := InStr(A_LoopField, "="))
				k := SubStr(A_LoopField, 1, p-1), FieldDefault[s][k] := SubStr(A_LoopField, p+1)
		}
	}
}

nm_ResetFieldDefaultGUI(*){
	global
	local x,y,i,k,v,hBM
	GuiClose(*){
		if (IsSet(FieldDefaultGui) && IsObject(FieldDefaultGui))
			FieldDefaultGui.Destroy(), FieldDefaultGui := ""
	}
	GuiClose()
	FieldDefaultGui := Gui("+AlwaysOnTop -MinimizeBox +Owner" MainGui.Hwnd, "Reset Field Defaults")
	FieldDefaultGui.OnEvent("Close", GuiClose)
	FieldDefaultGui.SetFont("s9 cDefault Norm", "Tahoma")
	i := 0
	for k,v in StandardFieldDefault
	{
		i++
		x := 10+((i-1)//6)*110, y := 6+Mod(i-1, 6)*22
		FieldDefaultGui.Add("Button", "x" x " y" y " w100 h20 vResetFieldDefault" i, k).OnEvent("Click", nm_ResetFieldDefault)
	}
	i++
	x := 10+((i-1)//6)*110, y := 6+Mod(i-1, 6)*22
	hBM := Gdip_CreateHBITMAPFromBitmap(bitmaps["allfields"])
	FieldDefaultGui.Add("Picture", "x" x " y" y " w100 h20", "HBITMAP:*" hBM).OnEvent("Click", nm_ResetAllFieldDefaults)
	DllCall("DeleteObject", "ptr", hBM)
	FieldDefaultGui.Show("w330 h132")
}
nm_ResetFieldDefault(GuiCtrl, *){
	global FieldDefault, StandardFieldDefault
	n := SubStr(GuiCtrl.Name, 18) ; ResetFieldDefault
	for k,v in StandardFieldDefault
	{
		if (A_Index = n)
		{
			if (MsgBox(
			(
			"Reset " k " default settings to these standard settings?

			Pattern Shape: " v["pattern"] "
			Pattern Length: " v["size"] "
			Pattern Width: " v["width"] "
			Pattern Invert F/B: " (v["invertFB"] ? "Enabled" : "Disabled") "
			Pattern Invert L/R: " (v["invertLR"] ? "Enabled" : "Disabled") "
			Shift-Lock: " (v["shiftlock"] ? "Enabled" : "Disabled") "

			Until Mins: " v["gathertime"] "
			Until Pack: " v["percent"] "%
			To Hive By: " v["convert"] "

			Rotate Camera Direction: " v["camera"] "
			Rotate Camera Turns: " v["turns"] "

			Sprinkler Location: " v["sprinkler"] "
			Sprinkler Distance: " v["distance"]
			), "Reset Field Defaults", 0x40034 " Owner" MainGui.Hwnd) = "Yes")
			{
				FieldDefault[k]["pattern"]:=v["pattern"]
				FieldDefault[k]["size"]:=v["size"]
				FieldDefault[k]["width"]:=v["width"]
				FieldDefault[k]["shiftlock"]:=v["shiftlock"]
				FieldDefault[k]["invertFB"]:=v["invertFB"]
				FieldDefault[k]["invertLR"]:=v["invertLR"]
				FieldDefault[k]["gathertime"]:=v["gathertime"]
				FieldDefault[k]["percent"]:=v["percent"]
				FieldDefault[k]["convert"]:=v["convert"]
				FieldDefault[k]["sprinkler"]:=v["sprinkler"]
				FieldDefault[k]["distance"]:=v["distance"]
				FieldDefault[k]["camera"]:=v["camera"]
				FieldDefault[k]["turns"]:=v["turns"]
				FieldDefault[k]["drift"]:=v["drift"]
				for i,j in FieldDefault[k]
					IniWrite j, fieldConfigLoc, k, i
				MsgBox "Changed " k " field defaults back to their standard settings!", "Reset Field Defaults", 0x40040 " Owner" MainGui.Hwnd
			}

			break
		}
	}
}
nm_ResetAllFieldDefaults(*){
	global FieldDefault, StandardFieldDefault
	if (MsgBox("Are you sure you want to reset all field default settings to their standard settings?", "Reset Field Defaults", 0x40034 " Owner" MainGui.Hwnd) = "Yes")
	{
		if (MsgBox("ARE YOU SUPER DUPER SURE?", "Reset Field Defaults", 0x40034 " Owner" MainGui.Hwnd) = "Yes")
		{
			ini := ""
			for k,v in StandardFieldDefault
			{
				ini .= "[" k "]`r`n"
				for i,j in v
				{
					FieldDefault[k][i] := j
					ini .= i "=" j "`r`n"
				}
				ini .= "`r`n"
			}

			file := FileOpen(A_WorkingDir "\" fieldConfigLoc, "w-d"), file.Write(ini), file.Close()

			MsgBox "Changed all field defaults back to their standard settings!", "Reset Field Defaults", 0x40040 " Owner" MainGui.Hwnd
		}
	}
}
nm_gather(pattern, index, patternsize:="M", reps:=1, facingcorner:=0){
	if !patterns.Has(pattern) {
		global FieldPattern
		nm_setStatus("Error", "Pattern '" pattern "' does not exist!`nChanged back to '" (FieldPattern := pattern := StandardFieldDefault[FieldName]["pattern"]) "'")
		IniWrite FieldDefault[FieldName]["pattern"] := pattern, fieldConfigLoc, FieldName, "pattern"
	}

	size := (patternsize="XS") ? 0.25
		: (patternsize="S") ? 0.5
		: (patternsize="L") ? 1.5
		: (patternsize="XL") ? 2
		: 1 ; medium (default)

	DetectHiddenWindows 1
	if ((index = 1) || !WinExist("ahk_class AutoHotkey ahk_pid " currentWalk.pid))
		nm_createWalk(patterns[pattern], "pattern",
			(
			'
			size:=' size '
			reps:=' reps '
			facingcorner:=' facingcorner '

			FieldName:="' FieldName '"
			FieldPattern:="' FieldPattern '"
			FieldPatternSize:="' FieldPatternSize '"
			FieldPatternReps:=' FieldPatternReps '
			FieldPatternShift:=' FieldPatternShift '
			FieldPatternInvertFB:=' FieldPatternInvertFB '
			FieldPatternInvertLR:=' FieldPatternInvertLR '
			FieldUntilMins:=' FieldUntilMins '
			FieldUntilPack:=' FieldUntilPack '
			FieldReturnType:="' FieldReturnType '"
			FieldSprinklerLoc:="' FieldSprinklerLoc '"
			FieldSprinklerDist:=' FieldSprinklerDist '
			FieldRotateDirection:="' FieldRotateDirection '"
			FieldRotateTimes:=' FieldRotateTimes '
			FieldDriftCheck:=' FieldDriftCheck '
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
			'
			)
		) ; create / replace cycled walk script for this gather session
	else
		Send "{F13}" ; start new cycle
	DetectHiddenWindows 0

	if (KeyWait("F14", "D T5 L") = 0) ; wait for pattern start
		nm_endWalk()
}
nm_GoGather(){
	global youDied
		, TCFBKey, AFCFBKey, TCLRKey, AFCLRKey, FwdKey, LeftKey, BackKey, RightKey, RotLeft, RotRight, SC_E, KeyDelay
		, MoveMethod
		, CurrentFieldNum
		, objective
		, BackpackPercentFiltered
		, MicroConverterKey
		, WhirligigKey, PFieldBoosted, GlitterKey, GatherFieldBoosted, GatherFieldBoostedStart, LastGlitter, PMondoGuidComplete, LastGuid, PMondoGuid, PFieldGuidExtend, PFieldGuidExtendMins, PFieldBoostExtend, PPopStarExtend, HasPopStar, PopStarActive, FieldGuidDetected, ConvertGatherFlag
		, LastWhirligig
		, BoostChaserCheck, LastBlueBoost, LastRedBoost, LastMountainBoost, FieldBooster3, FieldBooster2, FieldBooster1, FieldDefault, LastMicroConverter, HiveConfirmed
		, FieldName1, FieldPattern1, FieldPatternSize1, FieldPatternReps1, FieldPatternShift1, FieldPatternInvertFB1, FieldPatternInvertLR1, FieldUntilMins1, FieldUntilPack1, FieldReturnType1, FieldSprinklerLoc1, FieldSprinklerDist1, FieldRotateDirection1, FieldRotateTimes1, FieldDriftCheck1
		, FieldName2, FieldPattern2, FieldPatternSize2, FieldPatternReps2, FieldPatternShift2, FieldPatternInvertFB2, FieldPatternInvertLR2, FieldUntilMins2, FieldUntilPack2, FieldReturnType2, FieldSprinklerLoc2, FieldSprinklerDist2, FieldRotateDirection2, FieldRotateTimes2, FieldDriftCheck2
		, FieldName3, FieldPattern3, FieldPatternSize3, FieldPatternReps3, FieldPatternShift3, FieldPatternInvertFB3, FieldPatternInvertLR3, FieldUntilMins3, FieldUntilPack3, FieldReturnType3, FieldSprinklerLoc3, FieldSprinklerDist3, FieldRotateDirection3, FieldRotateTimes3, FieldDriftCheck3
		, FieldName, FieldPattern, FieldPatternSize, FieldPatternReps, FieldPatternShift, FieldPatternInvertFB, FieldPatternInvertLR, FieldUntilMins, FieldUntilPack, FieldReturnType, FieldSprinklerLoc, FieldSprinklerDist, FieldRotateDirection, FieldRotateTimes, FieldDriftCheck
		, MondoBuffCheck, MondoAction, LastMondoBuff
		, PlanterMode, gotoPlanterField, MPlanterGatherA, MPlanterGather1, MPlanterGather2, MPlanterGather3, LastPlanterGatherSlot, MPlanterHold1, MPlanterHold2, MPlanterHold3, PlanterField1, PlanterField2, PlanterField3, PlanterHarvestTime1, PlanterHarvestTime2, PlanterHarvestTime3
		, QuestLadybugs, QuestRhinoBeetles, QuestSpider, QuestMantis, QuestScorpions, QuestWerewolf
		, GatherStartTime, TotalGatherTime, SessionGatherTime, ConvertStartTime, TotalConvertTime, SessionConvertTime
		, GameFrozenCounter
		, BlackQuestCheck, BrownQuestCheck, BuckoQuestCheck, RileyQuestCheck, PolarQuestCheck
		, BlackQuestComplete, BrownQuestComplete, BuckoQuestComplete, RileyQuestComplete, PolarQuestComplete

	;VICIOUS BEE
	if nm_NightInterrupt()
		return
	;MONDO
	if nm_MondoInterrupt()
		return
	if !(nm_GatherBoostInterrupt()){
		;BUGS GatherInterruptCheck
		if nm_BugrunInterrupt()
			return
		;BEESMAS GatherInterruptCheck
		if nm_BeesmasInterrupt()
			return
		;Memory Match
		if nm_MemoryMatchInterrupt()
			return
	}
	utc_min := FormatTime(A_NowUTC, "m")
	if(CurrentField="mountain top" && (utc_min>=0 && utc_min<15)) ;mondo dangerzone! skip over this field if possible
		nm_currentFieldDown()
	;FIELD OVERRIDES
	global fieldOverrideReason:="None"
	loop 1 {
		;boosted field override
		if(BoostChaserCheck){

			BoostChaserField:="None"
			blueBoosterFields		:=Map("PineTreeBoosterCheck","Pine Tree", "BambooBoosterCheck","Bamboo", "BlueFlowerBoosterCheck","Blue Flower", "StumpBoosterCheck","Stump")
			redBoosterFields		:=Map("RoseBoosterCheck","Rose", "StrawberryBoosterCheck","Strawberry", "MushroomBoosterCheck","Mushroom", "PepperBoosterCheck","Pepper")
			mountainBoosterfields	:=Map("CactusBoosterCheck","Cactus", "PumpkinBoosterCheck","Pumpkin", "PineappleBoosterCheck","Pineapple", "SpiderBoosterCheck","Spider", "CloverBoosterCheck","Clover", "DandelionBoosterCheck","Dandelion", "SunflowerBoosterCheck","Sunflower")
			coconutBoosterfields	:=Map("CoconutBoosterCheck","Coconut")
			otherFields				:=["Mountain Top"]

			loop 1 {
				for i, location in ["blue", "mountain", "red", "coconut"] {
					for k, v in %location%BoosterFields {
						if((nm_fieldBoostCheck(v, 1)) && (%k%)) {
							BoostChaserField:=v
							break
						}
					}
				}
				if(BoostChaserField!="none")
					break
				;other
				for key, value in otherFields {
					if(nm_fieldBoostCheck(value, 1)) {
						BoostChaserField:=value
						break
					}
				}
			}
			;set field override
			if(BoostChaserField!="none") {
				fieldOverrideReason:="Boost"
				FieldName:=BoostChaserField
				FieldPattern:=FieldDefault[BoostChaserField]["pattern"]
				FieldPatternSize:=FieldDefault[BoostChaserField]["size"]
				FieldPatternReps:=FieldDefault[BoostChaserField]["width"]
				FieldPatternShift:=FieldDefault[BoostChaserField]["shiftlock"]
				FieldPatternInvertFB:=FieldDefault[BoostChaserField]["invertFB"]
				FieldPatternInvertLR:=FieldDefault[BoostChaserField]["invertLR"]
				FieldUntilMins:=FieldDefault[BoostChaserField]["gathertime"]
				FieldUntilPack:=FieldDefault[BoostChaserField]["percent"]
				FieldReturnType:=FieldDefault[BoostChaserField]["convert"]
				FieldSprinklerLoc:=FieldDefault[BoostChaserField]["sprinkler"]
				FieldSprinklerDist:=FieldDefault[BoostChaserField]["distance"]
				FieldRotateDirection:=FieldDefault[BoostChaserField]["camera"]
				FieldRotateTimes:=FieldDefault[BoostChaserField]["turns"]
				FieldDriftCheck:=FieldDefault[BoostChaserField]["drift"]
				;start boosted timer here
				if ((nowUnix()-GatherFieldBoostedStart>900) && (nowUnix()-LastGlitter>900)) {
					GatherFieldBoostedStart:=nowUnix()
				}
				break
			}
		}
		;questing override
		if((BlackQuestCheck || BrownQuestCheck || BuckoQuestCheck || RileyQuestCheck || PolarQuestCheck) && (QuestGatherField && QuestGatherField!="None")){
			fieldOverrideReason:="Quest"
			thisfield:=QuestGatherField
			if(QuestGatherField=FieldName1) {
				FieldName:=QuestGatherField
				FieldPattern:=FieldPattern1
				FieldPatternSize:=FieldPatternSize1
				FieldPatternReps:=FieldPatternReps1
				FieldPatternShift:=FieldPatternShift1
				FieldPatternInvertFB:=FieldPatternInvertFB1
				FieldPatternInvertLR:=FieldPatternInvertLR1
				FieldUntilMins:=FieldUntilMins1
				FieldUntilPack:=FieldUntilPack1
				FieldReturnType:=QuestGatherReturnBy
				FieldRotateDirection:=FieldRotateDirection1
				FieldRotateTimes:=FieldRotateTimes1
				FieldSprinklerLoc:=FieldSprinklerLoc1
				FieldSprinklerDist:=FieldSprinklerDist1
				FieldDriftCheck:=FieldDriftCheck1
			} else {
				FieldName:=QuestGatherField
				FieldPattern:=FieldDefault[QuestGatherField]["pattern"]
				FieldPatternSize:=FieldDefault[QuestGatherField]["size"]
				FieldPatternReps:=FieldDefault[QuestGatherField]["width"]
				FieldPatternShift:=FieldDefault[QuestGatherField]["shiftlock"]
				FieldPatternInvertFB:=FieldDefault[QuestGatherField]["invertFB"]
				FieldPatternInvertLR:=FieldDefault[QuestGatherField]["invertLR"]
				FieldUntilMins:=QuestGatherMins
				FieldUntilPack:=FieldDefault[QuestGatherField]["percent"]
				FieldReturnType:=QuestGatherReturnBy
				FieldSprinklerLoc:=FieldDefault[QuestGatherField]["sprinkler"]
				FieldSprinklerDist:=FieldDefault[QuestGatherField]["distance"]
				FieldRotateDirection:=FieldDefault[QuestGatherField]["camera"]
				FieldRotateTimes:=FieldDefault[QuestGatherField]["turns"]
				FieldDriftCheck:=FieldDefault[QuestGatherField]["drift"]
			}
			break
		}
		;Gather in manual planters field override

		if((MPlanterGatherA) && (PlanterMode = 1)) {

			; define available planter gather slots/fields: selected by user for planter gather, with planter in field, and not 'holding at full grown'
			(eligible := []).Length := 3
			Loop 3 {
				if((MPlanterGather%A_Index%) && (PlanterField%A_Index% != "None") && (!MPlanterHold%A_Index%))
					eligible[A_Index] := planterField%A_Index%
			}

			if !(LastPlanterGatherSlot ~= "^(1|2|3)$")
				LastPlanterGatherSlot := 3

			; if at least one slot is available for planter gather, proceed, else revert to gather tab
			if (eligible.Has(1) || eligible.Has(2) || eligible.Has(3)) {

				; find next eligible field and slot
				if 		((eligible.Has(1)) && (((LastPlanterGatherSlot=1) && (!eligible.Has(2)) && (!eligible.Has(3))) || ((LastPlanterGatherSlot=2) && (!eligible.Has(3))) || (LastPlanterGatherSlot=3)))
						{
						LastPlanterGatherSlot:= 1
						field := PlanterField1
						}
				else if ((eligible.Has(2)) && (((LastPlanterGatherSlot=2) && (!eligible.Has(3)) && (!eligible.Has(1))) || ((LastPlanterGatherSlot=3) && (!eligible.Has(1))) || (LastPlanterGatherSlot=1)))
						{
						LastPlanterGatherSlot:= 2
						field := PlanterField2
						}
				else if ((eligible.Has(3)) && (((LastPlanterGatherSlot=3) && (!eligible.Has(1)) && (!eligible.Has(2))) || ((LastPlanterGatherSlot=1) && (!eligible.Has(2))) || (LastPlanterGatherSlot=2)))
						{
						LastPlanterGatherSlot:= 3
						field := PlanterField3
						}

				; set gather field and settings
				fieldOverrideReason:="Manual Planter"
				FieldName:=field
				FieldPattern:=FieldDefault[FieldName]["pattern"]
				FieldPatternSize:=FieldDefault[FieldName]["size"]
				FieldPatternReps:=FieldDefault[FieldName]["width"]
				FieldPatternShift:=FieldDefault[FieldName]["shiftlock"]
				FieldPatternInvertFB:=FieldDefault[FieldName]["invertFB"]
				FieldPatternInvertLR:=FieldDefault[FieldName]["invertLR"]
				FieldUntilMins:=FieldDefault[FieldName]["gathertime"]
				FieldUntilPack:=FieldDefault[FieldName]["percent"]
				FieldReturnType:=FieldDefault[FieldName]["convert"]
				FieldSprinklerLoc:=FieldDefault[FieldName]["sprinkler"]
				FieldSprinklerDist:=FieldDefault[FieldName]["distance"]
				FieldRotateDirection:=FieldDefault[FieldName]["camera"]
				FieldRotateTimes:=FieldDefault[FieldName]["turns"]
				FieldDriftCheck:=FieldDefault[FieldName]["drift"]
				MPlanterGatherDetectionTime:=0

				; write currentfield to file as LastPlanterGatherSlot, to read on next loop
				IniWrite LastPlanterGatherSlot, "settings\nm_config.ini", "Planters", "LastPlanterGatherSlot"

				break
			}

		}

		;Gather in planters+ field override
		if((gotoPlanterField) && (PlanterMode = 2)){
			Loop 3{
				inverseIndex:=(4-A_Index)
				If(PlanterField%inverseIndex%="dandelion" || PlanterField%inverseIndex%="sunflower" || PlanterField%inverseIndex%="mushroom" || PlanterField%inverseIndex%="blue flower" || PlanterField%inverseIndex%="clover" || PlanterField%inverseIndex%="strawberry" || PlanterField%inverseIndex%="spider" || PlanterField%inverseIndex%="bamboo" || PlanterField%inverseIndex%="pineapple" || PlanterField%inverseIndex%="stump" || PlanterField%inverseIndex%="cactus" || PlanterField%inverseIndex%="pumpkin" || PlanterField%inverseIndex%="pine tree" || PlanterField%inverseIndex%="rose" || PlanterField%inverseIndex%="mountain top" || PlanterField%inverseIndex%="pepper" || PlanterField%inverseIndex%="coconut"){
					fieldOverrideReason:="Planter"
					FieldName:=PlanterField%inverseIndex%
					FieldPattern:=FieldDefault[FieldName]["pattern"]
					FieldPatternSize:=FieldDefault[FieldName]["size"]
					FieldPatternReps:=FieldDefault[FieldName]["width"]
					FieldPatternShift:=FieldDefault[FieldName]["shiftlock"]
					FieldPatternInvertFB:=FieldDefault[FieldName]["invertFB"]
					FieldPatternInvertLR:=FieldDefault[FieldName]["invertLR"]
					FieldUntilMins:=FieldDefault[FieldName]["gathertime"]
					FieldUntilPack:=FieldDefault[FieldName]["percent"]
					FieldReturnType:=FieldDefault[FieldName]["convert"]
					FieldSprinklerLoc:=FieldDefault[FieldName]["sprinkler"]
					FieldSprinklerDist:=FieldDefault[FieldName]["distance"]
					FieldRotateDirection:=FieldDefault[FieldName]["camera"]
					FieldRotateTimes:=FieldDefault[FieldName]["turns"]
					FieldDriftCheck:=FieldDefault[FieldName]["drift"]
					break 2
				}
			}
		}
		FieldName:=FieldName%CurrentFieldNum%
		FieldPattern:=FieldPattern%CurrentFieldNum%
		FieldPatternSize:=FieldPatternSize%CurrentFieldNum%
		FieldPatternReps:=FieldPatternReps%CurrentFieldNum%
		FieldPatternShift:=FieldPatternShift%CurrentFieldNum%
		FieldPatternInvertFB:=FieldPatternInvertFB%CurrentFieldNum%
		FieldPatternInvertLR:=FieldPatternInvertLR%CurrentFieldNum%
		FieldUntilMins:=FieldUntilMins%CurrentFieldNum%
		FieldUntilPack:=FieldUntilPack%CurrentFieldNum%
		FieldReturnType:=FieldReturnType%CurrentFieldNum%
		FieldSprinklerLoc:=FieldSprinklerLoc%CurrentFieldNum%
		FieldSprinklerDist:=FieldSprinklerDist%CurrentFieldNum%
		FieldRotateDirection:=FieldRotateDirection%CurrentFieldNum%
		FieldRotateTimes:=FieldRotateTimes%CurrentFieldNum%
		FieldDriftCheck:=FieldDriftCheck%CurrentFieldNum%
	}
	nm_updateAction("Gather")
	;close all menus
	nm_OpenMenu()
	;reset
	if(fieldOverrideReason="None" || fieldOverrideReason="Boost") {
		nm_Reset(2)
		;check if gathering field is boosted
		blueBoosterFields:=["Pine Tree", "Bamboo", "Blue Flower", "Stump"]
		redBoosterFields:=["Rose", "Strawberry", "Mushroom", "Pepper"]
		mountainBoosterfields:=["Cactus", "Pumpkin", "Pineapple", "Spider", "Clover", "Dandelion", "Sunflower"]
		otherFields:=["Coconut", "Mountain Top"]
		loop 1 {
			GatherFieldBoosted:=0
			;blue
			for key, value in blueBoosterFields {
				if(nm_fieldBoostCheck(value, 3) && FieldName=value) {
					if((nowUnix()-GatherFieldBoostedStart)>2700 && nm_fieldBoostCheck(value, 0)) {
						GatherFieldBoostedStart:=nowUnix()
					}
					if((nowUnix()-GatherFieldBoostedStart)<1800) {
						GatherFieldBoosted:=1
						break
					}
				}
			}
			if(GatherFieldBoosted)
				break
			;mountain
			for key, value in mountainBoosterFields {
				if(nm_fieldBoostCheck(value, 3) && FieldName=value) {
					if((nowUnix()-GatherFieldBoostedStart)>2700  && nm_fieldBoostCheck(value, 0)) {
						GatherFieldBoostedStart:=nowUnix()
					}
					if((nowUnix()-GatherFieldBoostedStart)<1800) {
						GatherFieldBoosted:=1
						break
					}
				}
			}
			if(GatherFieldBoosted)
				break
			;red
			for key, value in redBoosterFields {
				if(nm_fieldBoostCheck(value, 3) && FieldName=value) {
					if((nowUnix()-GatherFieldBoostedStart)>2700  && nm_fieldBoostCheck(value, 0)) {
						GatherFieldBoostedStart:=nowUnix()
					}
					if((nowUnix()-GatherFieldBoostedStart)<1800) {
						GatherFieldBoosted:=1
						break
					}
				}
			}
			if(GatherFieldBoosted)
				break
			;other
			for key, value in otherFields {
				if(nm_fieldBoostCheck(value, 1) && FieldName=value) {
					if((nowUnix()-GatherFieldBoostedStart)>2700 && nm_fieldBoostCheck(value, 0)) {
						GatherFieldBoostedStart:=nowUnix()
					}
					if((nowUnix()-GatherFieldBoostedStart)<1800) {
						GatherFieldBoosted:=1
						break
					}
				}
			}
		}
	} else {
		nm_Reset()
	}
	nm_setStatus("Traveling", FieldName)
	;go to field
	nm_gotoField(FieldName)
	nm_autoFieldBoost(FieldName)
	nm_fieldBoostGlitter()
	nm_PlanterTimeUpdate(FieldName)
	field_limit := DurationFromSeconds(FieldUntilMins*60, "mm:ss")
	ConvertGatherFlag := 1
	if(fieldOverrideReason="None") {
		nm_setStatus("Gathering", FieldName (GatherFieldBoosted ? " - Boosted" : "") "`nLimit " field_limit " - " FieldPattern " - " FieldPatternSize " - " FieldSprinklerLoc " " FieldSprinklerDist)
	} else if(fieldOverrideReason="Quest") {
		if ((RotateQuest = "Polar") || (RotateQuest = "Black"))
			ConvertGatherFlag := 0
		if (IsSet(RotateQuest) && (%RotateQuest%QuestCheck = 1))
			nm_%RotateQuest%QuestProg()
		nm_setStatus("Gathering", RotateQuest . " " . fieldOverrideReason . " - " . FieldName "`nLimit " field_limit " - " FieldPattern " - " FieldPatternSize " - " FieldSprinklerLoc " " FieldSprinklerDist)
	} else {
		nm_setStatus("Gathering", fieldOverrideReason . " - " . FieldName "`nLimit " field_limit " - " FieldPattern " - " FieldPatternSize " - " FieldSprinklerLoc " " FieldSprinklerDist)
	}
	;set sprinkler
	nm_setSprinkler(FieldName, FieldSprinklerLoc, FieldSprinklerDist)
	;rotate
	if (FieldRotateDirection != "None") {
		direction:=FieldRotateDirection
		sendinput "{" Rot%direction% " " FieldRotateTimes "}"
	}
	;determine if facing corner
	FacingFieldCorner:=0
	if((FieldName="pine tree" && ((FieldSprinklerLoc="upper" || FieldSprinklerLoc="upper left") && FieldRotateDirection="left" && FieldRotateTimes=1)) || ((FieldName="pineapple" && (FieldSprinklerLoc="upper left" && FieldRotateDirection="left" && FieldRotateTimes=1))) || (FieldName="spider" && ((FieldSprinklerLoc="upper" || FieldSprinklerLoc="upper left") && FieldRotateDirection="left" && FieldRotateTimes=1))) {
		FacingFieldCorner:=1
	}
	;set direction keys
	;foward/back
	if(FieldPatternInvertFB){
		TCFBKey:=BackKey
		AFCFBKey:=FwdKey
	} else {
		TCFBKey:=FwdKey
		AFCFBKey:=BackKey
	}
	if(FieldPatternInvertLR){
		TCLRKey:=RightKey
		AFCLRKey:=LeftKey
	} else {
		TCLRKey:=LeftKey
		AFCLRKey:=RightKey
	}
	;set FDC switch
	FDCEnabled := (FieldDriftCheck && (FieldPattern != "Stationary"))

	;gather loop
	hwnd := GetRobloxHWND()
	offsetY := GetYOffset(hwnd)
	GetRobloxClientPos(hwnd)
	MouseMove windowX+350, windowY+offsetY+100
	inactiveHoney:=0
	bypass:=0
	interruptReason := ""
	GatherStartTime:=gatherStart:=nowUnix()
	if(FieldPatternShift) {
		nm_setShiftLock(1)
	}
	while(((nowUnix()-gatherStart)<(FieldUntilMins*60)) || (PFieldBoosted && (nowUnix()-GatherFieldBoostedStart)<840) || (PFieldBoostExtend && (nowUnix()-GatherFieldBoostedStart)<1800 && (nowUnix()-LastGlitter)<900) || (PFieldGuidExtend && FieldGuidDetected && (nowUnix()-gatherStart)<(FieldUntilMins*60+PFieldGuidExtend*60) && (nowUnix()-GatherFieldBoostedStart)>900 && (nowUnix()-LastGlitter)>900) || (PPopStarExtend && HasPopStar && PopStarActive)){
		if !fieldPatternShift
			MouseMove windowX+350, windowY+GetYOffset()+100
		if(!DisableToolUse)
			Click "Down"
		nm_gather(FieldPattern, A_Index, FieldPatternSize, FieldPatternReps, FacingFieldCorner)

		while ((GetKeyState("F14") && (A_Index <= 3600)) || (A_Index = 1)) { ; timeout 3m
			;use glitter
			if (Mod(A_Index, 20) = 1) { ; every 1s
				if(PFieldBoosted && (nowUnix()-GatherFieldBoostedStart)>525 && (nowUnix()-GatherFieldBoostedStart)<900 && (nowUnix()-LastGlitter)>900 && GlitterKey!="none" && fieldOverrideReason="None") { ;between 9 and 15 mins (-minus an extra 15 seconds)
					Send "{" GlitterKey "}"
					LastGlitter:=nowUnix()
					IniWrite LastGlitter, "settings\nm_config.ini", "Boost", "LastGlitter"
				}
				nm_autoFieldBoost(FieldName)
				nm_fieldBoostGlitter()
			}

			;high priority interrupts
			if (Mod(A_Index, 5) = 1) { ; every 250ms
				if DisconnectCheck() {
					interruptReason := "Disconnect"
					break
				}
				if youDied {
					interruptReason := "You Died!"
					break
				}
				if nm_NightInterrupt() {
					interruptReason := "Night"
					break
				}
			}
			if (Mod(A_Index, 20) = 1) { ; every 1s
				;full backpack
				if (BackpackPercentFiltered>=(FieldUntilPack-2)) {
					if((BackpackPercentFiltered>=(FieldUntilPack < 90 ? 98 : FieldUntilPack-2)) && ((nowUnix()-LastMicroConverter)>30) && ((MicroConverterKey!="none" && !PFieldBoosted) || (MicroConverterKey!="none" && PFieldBoosted && GatherFieldBoosted))) { ;30 seconds cooldown
						Send "{" MicroConverterKey "}"
						LastMicroConverter:=nowUnix()
						IniWrite LastMicroConverter, "settings\nm_config.ini", "Boost", "LastMicroConverter"
					} else if ((nowUnix()-LastMicroConverter)>10) {
						interruptReason := "Backpack exceeds " .  FieldUntilPack . " percent"
						;use glitter early if boosted and close to glitter time
						if(PFieldBoosted && (nowUnix()-GatherFieldBoostedStart)>600 && (nowUnix()-GatherFieldBoostedStart)<900 && (nowUnix()-LastGlitter)>900 && GlitterKey!="none" && (fieldOverrideReason="None" || fieldOverrideReason="Boost")){ ;between 10 and 15 mins
							Send "{" GlitterKey "}"
							LastGlitter:=nowUnix()
							IniWrite LastGlitter, "settings\nm_config.ini", "Boost", "LastGlitter"
						}
						break
					}
				}
				;inactive honey
				if (BackpackPercentFiltered<FieldUntilPack) {
					inactiveHoney := (nm_activeHoney() = 0) ? inactiveHoney + 1 : 0
					if (inactiveHoney>30) {
						interruptReason := "Inactive Honey"
						GameFrozenCounter++
						break
					}
				}
				;boost is over
				if (fieldOverrideReason="Boost" && (nowUnix()-GatherFieldBoostedStart>900) && (nowUnix()-LastGlitter>900)) {
					interruptReason := "Boost Over"
					break
				}
				;mondo
				if nm_MondoInterrupt(){
					interruptReason := "Mondo"
					if (PMondoGuidComplete)
						PMondoGuidComplete:=0
					break
				}
			}
			if (Mod(A_Index, 100) = 1) { ; every 5s
				;quest interrupts
				if ((fieldOverrideReason="Quest") && IsSet(RotateQuest) && (%RotateQuest%QuestCheck = 1)) {
					nm_%RotateQuest%QuestProg()
					if(FieldPatternShift) {
						nm_setShiftLock(1)
					}
					;interrupt if
					if (thisfield!=QuestGatherField || %RotateQuest%QuestComplete){ ;change fields or this field is complete
						interruptReason := "Next Quest Step"
						break
					}
				}
			}

			;low priority interrupts
			if (Mod(A_Index, 20) = 1) {
				;continue if boosted
				if nm_GatherBoostInterrupt()
					continue
				;Manual planter gather interrupt
				if ((fieldOverrideReason="Manual Planter") && (PlanterMode = 1) && (MPlanterGatherA)) {
					;update current field planter progress every 2 minutes during planter gather
					If ((nowUnix()-MPlanterGatherDetectionTime)>120) {
						nm_PlanterTimeUpdate(FieldName, 0)
						MPlanterGatherDetectionTime := nowUnix()
					}
					;interrupt if
					if (((nowUnix() >= PlanterHarvestTime1) && (eligible.Has(1))) || ((nowUnix() >= PlanterHarvestTime2) && (eligible.Has(2))) || ((nowUnix() >= PlanterHarvestTime3) && (eligible.Has(3)))) {
						interruptReason := "Planter Harvest"
						break
					}
				}
				if nm_BugrunInterrupt() {
					interruptReason := "Kill Bugs"
					break
				}
				if nm_BeesmasInterrupt() {
					interruptReason := "Beesmas Machine"
					break
				}
				if nm_MemoryMatchInterrupt() {
					interruptReason := "Memory Match"
					break
				}
			}
			Sleep 50
		}

		Click "Up"
		if interruptReason {
			bypass := (interruptReason ~= "i)Disconnect|You Died!|Night|Inactive Honey")
			if (!bypass && InStr(patterns[FieldPattern], ";@NoInterrupt"))
				KeyWait "F14", "T180 L"
			break
		}
		(FDCEnabled) && nm_fieldDriftCompensation()
	}
	nm_endWalk()

	; set gather ended status
	gatherDuration := DurationFromSeconds(nowUnix()-gatherStart, "mm:ss")
	nm_setStatus("Gathering", "Ended`nTime " gatherDuration " - " (interruptReason ? (InStr(interruptReason, "Backpack exceeds") ? "Bag Limit" : interruptReason) : "Time Limit") " - Return: " FieldReturnType)

	if(GatherStartTime) {
		TotalGatherTime:=TotalGatherTime+(nowUnix()-GatherStartTime)
		SessionGatherTime:=SessionGatherTime+(nowUnix()-GatherStartTime)
	}
	GatherStartTime:=0
	nm_setShiftLock(0)
	if(bypass = 0){
		;rotate back
		if (FieldRotateDirection != "None") {
			direction:=(FieldRotateDirection = "left") ? "right" : "left"
			sendinput "{" Rot%direction% " " FieldRotateTimes "}"
		}
		;close quest log if necessary
		nm_OpenMenu()
		;check any planter progress
		nm_PlanterTimeUpdate(FieldName)
		;whirligig
		if (WhirligigKey!="None" && (nowUnix()-LastWhirligig)>180
		&& (!PFieldBoosted || (PFieldBoosted && GatherFieldBoosted))){
			WhirligigReturn()
		} else if(FieldReturnType="walk") { ;walk back
			nm_walkFrom(FieldName)
			DisconnectCheck()
			;Honey Wreath
			if BeesmasActive && ((interruptReason = "") || InStr(interruptReason, "Backpack exceeds"))
				nm_Wreath()
			nm_findHiveSlot()
		} ;reset back otherwise
	}
	nm_currentFieldDown()
	utc_min := FormatTime(A_NowUTC, "m")
	if(CurrentField="mountain top" && (utc_min>=0 && utc_min<15)) ;mondo dangerzone! skip over this field if possible
		nm_currentFieldDown()

	WhirligigReturn(){
		pBMScreen := Gdip_BitmapFromScreen(WindowX+WindowWidth*0.5-260 "|" WindowY+WindowHeight-101 "|" 75*7 "|" 66) ;hotbar
		if (Gdip_ImageSearch(pBMScreen,bitmaps["whirligigslot"], , , , , , 10, ,3) = 1) {
			Gdip_DisposeImage(pBMScreen)
			Send "{" WhirligigKey "}"
			sleep(2000) ; make sure the player is on the ground

			Send "{ " RotDown " 10}{ " RotUp " 7}{" ZoomIn " 10}"

			if !nm_SetHiveCameraDirection(1)
				nm_setStatus("Warning", "Unable to confirm hive!")

			LastWhirligig:=nowUnix()
			IniWrite LastWhirligig, "settings\nm_config.ini", "Boost", "LastWhirligig"
			nm_convert() ;convert all pollen, then reset if needed.
		} else {
			nm_setStatus("Warning", "No Whirligigs")
			Gdip_DisposeImage(pBMScreen)
		}
	}
}