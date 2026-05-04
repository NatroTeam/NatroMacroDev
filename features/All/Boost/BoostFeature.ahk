#Requires AutoHotkey v2.0

global boostConfigLoc := "features\All\CollectKill\nm_boost_config.ini"

;this is this features GUI lines-of-code used to calculate loading progress
BoostsFeatureProgressVolume := (BoostsFeature) ? 103 : 0
;this is the running total of all macro features included in the load progress metric
LoadingProgressVolume := (BoostsFeature) ? LoadingProgressVolume+BoostsFeatureProgressVolume : LoadingProgressVolume


nm_BoostTab(*) {
	global
	TabCtrl.UseTab("Boost")
	;boosters
	MainGui.SetFont("w700")
	MainGui.Add("GroupBox", "x10 y25 w285 h72", "Field Boost")
	MainGui.Add("GroupBox", "x10 y97 w285 h138", "Hotbar Slots")
	MainGui.SetFont("s8 cDefault Norm", "Tahoma")

	;field booster
	MainGui.Add("Text", "x15 y40 +BackgroundTrans Section", "1:")
	MainGui.Add("Text", "x+14 yp w50 vFieldBooster1 +Center +BackgroundTrans", FieldBooster1)
	MainGui.Add("Button", "xp-12 yp-1 w12 h16 vFB1Left Disabled", "<").OnEvent("Click", nm_FieldBooster)
	MainGui.Add("Button", "xp+61 yp w12 h16 vFB1Right Disabled", ">").OnEvent("Click", nm_FieldBooster)
	MainGui.Add("Text", "xs ys+18 +BackgroundTrans", "2:")
	MainGui.Add("Text", "x+14 yp w50 vFieldBooster2 +Center +BackgroundTrans", FieldBooster2)
	MainGui.Add("Button", "xp-12 yp-1 w12 h16 vFB2Left Disabled", "<").OnEvent("Click", nm_FieldBooster)
	MainGui.Add("Button", "xp+61 yp w12 h16 vFB2Right Disabled", ">").OnEvent("Click", nm_FieldBooster)
	MainGui.Add("Text", "xs ys+36 +BackgroundTrans", "3:")
	MainGui.Add("Text", "x+14 yp w50 vFieldBooster3 +Center +BackgroundTrans", FieldBooster3)
	MainGui.Add("Button", "xp-12 yp-1 w12 h16 vFB3Left Disabled", "<").OnEvent("Click", nm_FieldBooster)
	MainGui.Add("Button", "xp+61 yp w12 h16 vFB3Right Disabled", ">").OnEvent("Click", nm_FieldBooster)
	MainGui.Add("Text", "x120 y35 left +BackgroundTrans", "Separate By:")
	MainGui.Add("Text", "xp+3 y+1 w12 vFieldBoosterMins +Center", FieldBoosterMins)
	MainGui.Add("UpDown", "xp+14 yp-1 h16 -16 Range0-12 vFieldBoosterMinsUpDown Disabled", FieldBoosterMins//5).OnEvent("Change", nm_FieldBoosterMins)
	MainGui.Add("Text", "xp+20 yp+1 w100 left +BackgroundTrans", "Mins")
	MainGui.Add("CheckBox", "x109 y67 +center vBoostChaserCheck Disabled Checked" BoostChaserCheck, "Gather in`nBoosted Field").OnEvent("Click", nm_BoostChaserCheck)
	MainGui.Add("Button", "x200 y65 w90 h30 vBoostedFieldSelectButton Disabled", "Select Boosted Gather Fields").OnEvent("Click", nm_BoostedFieldSelectButton)
	MainGui.SetFont("w700")

	;shrine
	MainGui.Add("GroupBox", "x300 y25 w192 h105", "Wind Shrine")
	MainGui.SetFont("s8 cDefault Norm", "Tahoma")
	loop 2 {
		xCoords := 246 + (86 * A_Index)
		MainGui.Add("Button", "x" xCoords " y107 w40 h13 vShrineAdd" A_Index " Disabled", (ShrineItem%A_Index% = "None") ? "Add" : "Clear").OnEvent("Click", ba_setShrineData)
		MainGui.Add("Picture", "x" xCoords " y61 h40 w40 vShrineItem" A_Index "Picture +BackgroundTrans +0xE"
			, (ShrineItem%A_Index% = "None") ? "" : hBitmapsSB[ShrineItem%A_index%] ? ("HBITMAP:*" hBitmapsSB[ShrineItem%A_index%]) : "")
		MainGui.Add("Text", "x" (237 + (86 * A_index)) " y41 w60 +Center vShrineData" A_index, "(" ShrineAmount%A_Index% ") [" ((ShrineIndex%A_index% = "Infinite") ? "∞" : ShrineIndex%A_index%) "]")
	}
	ShrineAdd := 0
	MainGui.Add("Text", "x426 y108 w41 h16 +Center +0x200 vShrineAmountNum Hidden")
	MainGui.Add("UpDown", "vShrineAmount Range1-999 Hidden", 1)
	MainGui.Add("Text", "x430 y89 vShrineAmountText Hidden", "Amount")
	MainGui.Add("Text", "x430 y33 vShrineRepeatText Hidden", "Repeat")
	MainGui.SetFont("w700 underline")
	MainGui.Add("Text", "x327 y41 w80 vshrinetitle1 Hidden", "Add Item")
	MainGui.SetFont("s8 cDefault Norm", "Tahoma")
	MainGui.Add("Text", "x302 y57 w103 h1 vShrineline1 Hidden 0x7")
	MainGui.Add("Text", "x404 y32 w1 h97 vShrineline2 Hidden 0x7")
	MainGui.Add("Text", "x405 y47 w83 h1 vShrineline3 Hidden 0x7")
	MainGui.Add("Text", "x405 y104 w83 h1 vShrineline4 Hidden 0x7")
	MainGui.Add("Text", "x426 y69 w41 h16 +Center +0x200 vShrineIndexNum Hidden")
	MainGui.Add("UpDown", "vShrineIndex Range1-999 Hidden", 1)
	MainGui.Add("CheckBox", "x422 y52 w60 vShrineIndexOption Hidden", "Infinite").OnEvent("Click", nm_ShrineIndexOption)
	MainGui.Add("Picture", "x331 y63 w40 h40 vShrineItem Hidden +0xE")
	MainGui.Add("Button", "x307 y78 w18 h18 vShrineLeft Hidden", "<").OnEvent("Click", ba_AddShrineItemButton)
	MainGui.Add("Button", "x380 y78 w18 h18 vShrineRight Hidden", ">").OnEvent("Click", ba_AddShrineItemButton)
	MainGui.Add("Button", "x313 y108 w80 h16 +Center vShrineAddSlot Hidden").OnEvent("Click", ba_AddShrineItem)
	SetLoadingProgress(floor((CurrentLoadProgress+57)/LoadingProgressVolume*100))

	;hotbar
	Loop 6
	{
		i := A_Index + 1
		MainGui.Add("Text", "x15 y" (95 + 20 * A_Index) " w10 +BackgroundTrans", i ":")
		(GuiCtrl := MainGui.Add("DropDownList", "x25 y" (92 + 20 * A_Index) " w80 vHotbarWhile" i " Disabled", hotbarwhilelist)).Text := HotbarWhile%i%, GuiCtrl.OnEvent("Change", nm_HotbarWhile)
		MainGui.Add("Text", "x113 y" (95 + 20 * A_Index) " cRed vHBOffText" i, "<-- OFF")
		MainGui.Add("Text", "x106 y" (95 + 20 * A_Index) " w120 vHBText" i " Hidden")
		MainGui.Add("Text", "x108 y" (95 + 20 * A_Index) " w62 vHBTimeText" i " +Center Hidden").OnEvent("Click", nm_HotbarEditTime)
		MainGui.Add("UpDown", "x170 y" (94 + 20 * A_Index) " w10 h16 -16 Range1-99999 vHotbarTime" i " Hidden Disabled", HotbarTime%i%).OnEvent("Change", nm_HotbarTimeUpDown)
		MainGui.Add("Text", "x188 y" (94 + 20 * A_Index) " w62 vHBConditionText" i " +Center Hidden")
		(GuiCtrl := MainGui.Add("UpDown", "x250 y" (94 + 20 * A_Index) " w10 h16 -16 Range1-100 vHotbarMax" i " Hidden Disabled", HotbarMax%i%)).Section := "Boost", GuiCtrl.OnEvent("Change", nm_hotbarMaxUpDown)
	}
	nm_HotbarWhile()
	MainGui.Add("Button", "x200 y34 w90 h30 vAutoFieldBoostButton Disabled", (AutoFieldBoostActive ? "Auto Field Boost`n[ON]" : "Auto Field Boost`n[OFF]")).OnEvent("Click", nm_autoFieldBoostGui)
	MainGui.SetFont("w700")
	MainGui.SetFont("s8 cDefault Norm", "Tahoma")

	;stickers
	MainGui.SetFont("w700")
	MainGui.Add("GroupBox", "x300 y130 w192 h105", "Stickers")
	MainGui.SetFont("s8 cDefault Norm", "Tahoma")
	MainGui.Add("CheckBox", "x305 yp+16 vStickerStackCheck Disabled Checked" StickerStackCheck, "Sticker Stack").OnEvent("Click", nm_StickerStackCheck)
	MainGui.Add("Text", "xp+6 yp+13 +BackgroundTrans", "\__")
	MainGui.Add("Text", "x+0 yp+4 w36 +Center +BackgroundTrans Section", "Timer:")
	MainGui.Add("Text", "x+12 yp w" ((StickerStackMode = 0) ? 85 : 68) " vStickerStackModeText +Center +BackgroundTrans", (StickerStackMode = 0) ? "Detect" : hmsFromSeconds(StickerStackTimer)).OnEvent("Click", nm_StickerStackModeText)
	MainGui.Add("Button", "xp-12 yp-1 w12 h16 vSSMLeft Disabled", "<").OnEvent("Click", nm_StickerStackMode)
	MainGui.Add("Button", "xp+96 yp w12 h16 vSSMRight Disabled", ">").OnEvent("Click", nm_StickerStackMode)
	MainGui.Add("UpDown", "xp-18 yp h16 -16 Range900-86400 vStickerStackTimer Disabled Hidden" (StickerStackMode = 0), StickerStackTimer).OnEvent("Change", nm_StickerStackTimer)
	MainGui.Add("Button", "xp+36 yp+1 w12 h14 vStickerStackModeHelp Disabled", "?").OnEvent("Click", nm_StickerStackModeHelp)
	MainGui.Add("Text", "xs yp+17 w36 +Center +BackgroundTrans", "Item:")
	MainGui.Add("Text", "x+12 yp w85 vStickerStackItem +Center +BackgroundTrans", StickerStackItem)
	MainGui.Add("Button", "xp-12 yp-1 w12 h16 vSSILeft Disabled", "<").OnEvent("Click", nm_StickerStackItem)
	MainGui.Add("Button", "xp+96 yp w12 h16 vSSIRight Disabled", ">").OnEvent("Click", nm_StickerStackItem)
	MainGui.Add("Button", "xp+18 yp+1 w12 h14 vStickerStackItemHelp Disabled", "?").OnEvent("Click", nm_StickerStackItemHelp)
	MainGui.Add("Text", "xs-27 yp+17 w36 +Center +BackgroundTrans", "Skins:")
	MainGui.Add("CheckBox", "x332 yp vStickerStackHive Disabled Checked" StickerStackHive, "Hive").OnEvent("Click", nm_StickerStackSkins)
	MainGui.Add("CheckBox", "x375 yp vStickerStackCub Disabled Checked" StickerStackCub, "Cub").OnEvent("Click", nm_StickerStackSkins)
	MainGui.Add("CheckBox", "x416 yp w36 vStickerStackVoucher Disabled Checked" StickerStackVoucher, "Voucher").OnEvent("Click", nm_StickerStackSkins)
	MainGui.Add("Button", "xs+150 yp w12 h14 vStickerStackSkinsHelp Disabled", "?").OnEvent("Click", nm_StickerStackSkinsHelp)
	MainGui.Add("CheckBox", "x305 yp+19 w86 h13 vStickerPrinterCheck Disabled Checked" StickerPrinterCheck, "Sticker Printer").OnEvent("Click", nm_StickerPrinterCheck)
	MainGui.Add("Text", "x+0 yp w24 +Center +BackgroundTrans", "Egg:")
	MainGui.Add("Text", "x+12 yp w48 vStickerPrinterEgg +Center +BackgroundTrans", StickerPrinterEgg)
	MainGui.Add("Button", "xp-12 yp-1 w12 h16 vSPELeft Disabled", "<").OnEvent("Click", nm_StickerPrinterEgg)
	MainGui.Add("Button", "xp+59 yp w12 h16 vSPERight Disabled", ">").OnEvent("Click", nm_StickerPrinterEgg)
	CurrentLoadProgress:=CurrentLoadProgress+BoostsFeatureProgressVolume
	SetLoadingProgress(floor(CurrentLoadProgress/LoadingProgressVolume*100))
}

nm_FieldBooster(GuiCtrl?, *){
	global
	static val := ["None", "Blue", "Red", "Mountain"]
	local i, l, index, n, j, arr := []

	switch IsSet(GuiCtrl) ? GuiCtrl.Name : "", 0
	{
		case "FB2Left", "FB2Right":
		index := 2
		case "FB3Left", "FB3Right":
		index := 3
		default:
		index := 1
	}

	for k,v in val
	{
		if (k > 1)
			Loop (index - 1)
				if (v = FieldBooster%A_Index%)
					continue 2
		arr.Push(v)
	}
	l := arr.Length

	switch FieldBooster%index%, 0
	{
		case arr[1]:
		i := 1
		case arr[2]:
		i := 2
		case arr[3]:
		i := 3
		default:
		i := l
	}

	MainGui["FieldBooster" index].Text := (FieldBooster%index% := arr[IsSet(GuiCtrl) ? ((GuiCtrl.Name = "FB" index "Right") ? (Mod(i, l) + 1) : (Mod(l + i - 2, l) + 1)) : i])

	Loop 3 {
		n := A_Index
		Loop (n - 1) {
			if (FieldBooster%n% = FieldBooster%A_Index%) {
				MainGui["FieldBooster" n].Text := FieldBooster%n% := "None"
				if IsSet(GuiCtrl)
					IniWrite FieldBooster%n%, "settings\nm_config.ini", "Boost", "FieldBooster" n
			}
		}
		if (FieldBooster%n% = "None") {
			Loop (3 - n) {
				j := n + A_Index
				MainGui["FB" j "Left"].Enabled := 0
				MainGui["FB" j "Right"].Enabled := 0
				if (FieldBooster%j% != "None") {
					MainGui["FieldBooster" j].Text := FieldBooster%j% := "None"
					if IsSet(GuiCtrl)
						IniWrite FieldBooster%j%, "settings\nm_config.ini", "Boost", "FieldBooster" j
				}
			}
			break
		} else if (n < 3) {
			j := n + 1
			MainGui["FB" j "Left"].Enabled := 1
			MainGui["FB" j "Right"].Enabled := 1
		}
	}

	if IsSet(GuiCtrl)
		IniWrite FieldBooster%index%, "settings\nm_config.ini", "Boost", "FieldBooster" index
}
nm_FieldBoosterMins(*){
	global FieldBoosterMins
	MainGui["FieldBoosterMins"].Text := FieldBoosterMins := MainGui["FieldBoosterMinsUpDown"].Value * 5
	IniWrite FieldBoosterMins, "settings\nm_config.ini", "Boost", "FieldBoosterMins"
}
nm_HotbarWhile(GuiCtrl?, *){
	global HotbarWhile2, HotbarWhile3, HotbarWhile4, HotbarWhile5, HotbarWhile6, HotbarWhile7
		, HotbarTime2, HotbarTime3, HotbarTime4, HotbarTime5, HotbarTime6, HotbarTime7
		, HotbarMax2, HotbarMax3, HotbarMax4, HotbarMax5, HotbarMax6, HotbarMax7
		, hHB2, hHB3, hHB4, hHB5, hHB6, hHB7
		, PFieldBoosted, hotbarwhilelist, beesmasActive, MainGui

	Loop 6 {
		i := A_Index + 1
		if (!IsSet(GuiCtrl) || (GuiCtrl.Name = "HotbarWhile" i)) {
			HotbarWhile%i% := MainGui["HotbarWhile" i].Text
			switch HotbarWhile%i%, 0
			{
				case "microconverter":
				MainGui["HBText" i].Text := PFieldBoosted ? "@ Boosted" : "@ Full Pack"
				MainGui["HotbarTime" i].Visible := 0
				MainGui["HBTimeText" i].Visible := 0
				MainGui["HBConditionText" i].Visible := 0
				MainGui["HotbarMax" i].Visible := 0
				MainGui["HBText" i].Visible := 1

				case "whirligig":
				MainGui["HBText" i].Text := PFieldBoosted ? "@ Boosted" : "@ Hive Return"
				MainGui["HotbarTime" i].Visible := 0
				MainGui["HBTimeText" i].Visible := 0
				MainGui["HBConditionText" i].Visible := 0
				MainGui["HotbarMax" i].Visible := 0
				MainGui["HBText" i].Visible := 1

				case "enzymes":
				MainGui["HBText" i].Text := PFieldBoosted ? "@ Boosted" : "@ Converting Balloon"
				MainGui["HotbarTime" i].Visible := 0
				MainGui["HBTimeText" i].Visible := 0
				MainGui["HBConditionText" i].Visible := 0
				MainGui["HotbarMax" i].Visible := 0
				MainGui["HBText" i].Visible := 1

				case "glitter":
				MainGui["HBText" i].Text := "@ Boosted"
				MainGui["HotbarTime" i].Visible := 0
				MainGui["HBTimeText" i].Visible := 0
				MainGui["HBConditionText" i].Visible := 0
				MainGui["HotbarMax" i].Visible := 0
				MainGui["HBText" i].Visible := 1

				case "snowflake":
				if (beesmasActive = 0)
				{
					if IsSet(GuiCtrl)
					{
						MsgBox "This option is only available during Beesmas!", "Snowflake", 0x1030
						HotbarWhile%i% := "Never"
						MainGui["HotbarWhile" i].Text := "Never"
						MainGui["HotbarTime" i].Visible := 0
						MainGui["HBTimeText" i].Visible := 0
						MainGui["HBConditionText" i].Visible := 0
						MainGui["HotbarMax" i].Visible := 0
						MainGui["HBText" i].Visible := 0
					}
				}
				else
				{
					HotbarMax%i% := MainGui["HotbarMax" i].Value
					HotbarTime%i% := MainGui["HotbarTime" i].Value
					MainGui["HBConditionText" i].Text := "Until: " HotbarMax%i% "%"
					MainGui["HBTimeText" i].Text := hmsFromSeconds(HotbarTime%i%)
					MainGui["HBText" i].Visible := 0
					MainGui["HotbarTime" i].Visible := 1
					MainGui["HBTimeText" i].Visible := 1
					MainGui["HBConditionText" i].Visible := 1
					MainGui["HotbarMax" i].Visible := 1
				}

				case "never":
				MainGui["HotbarTime" i].Visible := 0
				MainGui["HBTimeText" i].Visible := 0
				MainGui["HBConditionText" i].Visible := 0
				MainGui["HotbarMax" i].Visible := 0
				MainGui["HBText" i].Visible := 0

				default:
				HotbarTime%i% := MainGui["HotbarTime" i].Value
				MainGui["HBTimeText" i].Text := hmsFromSeconds(HotbarTime%i%)
				MainGui["HBConditionText" i].Visible := 0
				MainGui["HotbarMax" i].Visible := 0
				MainGui["HBText" i].Visible := 0
				MainGui["HotbarTime" i].Visible := 1
				MainGui["HBTimeText" i].Visible := 1
			}
			IniWrite HotbarWhile%i%, "settings\nm_config.ini", "Boost", "HotbarWhile" i
		}
	}
}
nm_HotbarTimeUpDown(GuiCtrl, *){
	global
	local i := SubStr(GuiCtrl.Name, -1)
	HotbarTime%i% := MainGui["HotbarTime" i].Value
	MainGui["HBTimeText" i].Text := hmsFromSeconds(HotbarTime%i%)
	IniWrite HotbarTime%i%, "settings\nm_config.ini", "Boost", "HotbarTime" i
}
nm_HotbarEditTime(GuiCtrl, *){
	global HotbarTime2, HotbarTime3, HotbarTime4, HotbarTime5, HotbarTime6, HotbarTime7
	MainGui.Opt("+OwnDialogs")
	i := SubStr(GuiCtrl.Name, -1)
	time := InputBox("Enter the number of seconds (1-99999) to wait between each use of Hotbar " i ":", "Hotbar Slot Time", "T30").Value
	if (time ~= "i)^\d{1,5}$")
	{
		MainGui["HotbarTime" i].Value := HotbarTime%i% := time
		MainGui["HBTimeText" i].Text := hmsFromSeconds(HotbarTime%i%)
		IniWrite HotbarTime%i%, "settings\nm_config.ini", "Boost", "HotbarTime" i
	}
	else if (time != "")
		MsgBox "You must enter a valid number of seconds between 1 and 99999!", "Hotbar Slot Time", 0x40030 " T20"
}
nm_hotbarMaxUpDown(GuiCtrl, *){
	global
	local i := SubStr(GuiCtrl.Name, -1)
	MainGui["HBConditionText" i].Text := "Until: " GuiCtrl.Value "%"
	IniWrite (HotbarMax%i% := GuiCtrl.Value), "settings\nm_config.ini", "Boost", "HotbarMax" i
}
nm_ShrineIndexOption(*) {
	global ShrineIndexOption, ShrineIndex
	ShrineIndexOption := MainGui["ShrineIndexOption"].Value
	if(ShrineIndexOption)
		MainGui["ShrineIndex"].Enabled := 0
	else
		MainGui["ShrineIndex"].Enabled := 1
}
ba_setShrineData(GuiCtrl, *){
	global
	local i := SubStr(GuiCtrl.Name, -1)
	static uiList := ["ShrineItem", "ShrineLeft", "ShrineRight", "ShrineAddSlot", "ShrineAmountText", "ShrineAmount"
		, "ShrineAmountNum", "ShrineRepeatText", "ShrineIndexOption", "ShrineIndexNum", "ShrineIndex"
		, "shrineline1", "shrinetitle1", "shrineline2", "shrineline3", "shrineline4"]

	if (ShrineItem%i% = "None") {
		ShrineaddIndex := i, ShrineAdd := i
		loop 2 {
			MainGui["ShrineAdd" A_Index].Visible := 0
			MainGui["ShrineData" A_Index].Visible := 0
			MainGui["ShrineItem" A_Index "Picture"].Visible := 0
		}

		MainGui["ShrineAmount"].Value := ShrineAmount%i%
		MainGui["ShrineIndex"].Value := ((ShrineIndex%i% != "Infinite" && ShrineIndex%i% != "∞") ? ShrineIndex%i% : 1)
		ba_AddShrineItemButton()
		MainGui["ShrineIndexOption"].Value := 0
		MainGui["ShrineIndex"].Enabled := 1
		MainGui["ShrineAddSlot"].Text := "Add to Slot " shrineaddIndex

		For ui in uiList
			MainGui[ui].Visible := 1
	} else {
		ShrineItem%i% := "None", ShrineAmount%i% := 0, ShrineIndex%i% := 1

		IniWrite "None", "settings\nm_config.ini", "Shrine", "ShrineItem" i
		IniWrite 0, "settings\nm_config.ini", "Shrine", "ShrineAmount" i
		IniWrite 1, "settings\nm_config.ini", "Shrine", "ShrineIndex" i

		MainGui["ShrineAdd" i].Text := ((ShrineItem%i% = "None" || ShrineItem%i% = "") ? "Add" : "Clear")
		MainGui["ShrineData" i].Text := "(" ShrineAmount%i% ") [" ((ShrineIndex%i% = "Infinite") ? "∞" : ShrineIndex%i%) "]"

		MainGui["ShrineItem" i "Picture"].Value := ""
	}
}
ba_AddShrineItemButton(GuiCtrl?, *){
	global AddShrineItem, ShrineAdd, hBitmapsSB
	static items := ["RedExtract", "BlueExtract", "BlueBerry", "Pineapple", "StrawBerry"
		, "Sunflower", "Enzymes", "Oil", "Glue", "TropicalDrink", "Gumdrops", "MoonCharms"
		, "Glitter", "StarJelly", "PurplePotion", "CloudVial", "AntPass", "SoftWax"
		, "HardWax", "SwirledWax", "CausticWax", "FieldDice", "SmoothDice", "LoadedDice", "Turpentine"], i := 0, h := 0

	if (h != ShrineAdd)
		i := 0, h := ShrineAdd
	i := Mod(items.Length + i + (IsSet(GuiCtrl) ? ((GuiCtrl.Name = "ShrineLeft") ? -1 : 1) : 0), items.Length), AddShrineItem := items[i+1]
	SetImage(MainGui["ShrineItem"].Hwnd, hBitmapsSB[AddShrineItem])
}
ba_AddShrineItem(*){
	global
	local ShrineIndex, ShrineAmount, ShrineIndexOption, ShrineIndex
	static uiList := ["ShrineItem", "ShrineLeft", "ShrineRight", "ShrineAddSlot", "ShrineAmountText", "ShrineAmount"
		, "ShrineAmountNum", "ShrineRepeatText", "ShrineIndex", "ShrineIndexOption", "ShrineIndexNum", "ShrineIndex"
		, "shrineline1", "shrinetitle1", "shrineline2", "shrineline3", "shrineline4"]

	ShrineIndex := MainGui["ShrineIndex"].Value
	ShrineAmount := MainGui["ShrineAmount"].Value
	ShrineIndexOption := MainGui["ShrineIndexOption"].Value
	ShrineIndex := ((ShrineIndexOption) ? "Infinite" : ShrineIndex)

	IniWrite (ShrineItem%ShrineaddIndex% := AddShrineItem), "settings\nm_config.ini", "Shrine", "ShrineItem" ShrineaddIndex
	IniWrite (ShrineIndex%ShrineaddIndex% := ShrineIndex), "settings\nm_config.ini", "Shrine", "ShrineIndex" ShrineaddIndex
	IniWrite (ShrineAmount%ShrineaddIndex% := ShrineAmount), "settings\nm_config.ini", "Shrine", "ShrineAmount" ShrineaddIndex

	MainGui["ShrineItem" ShrineaddIndex "Picture"].Value := hBitmapsSB[ShrineItem%ShrineaddIndex%] ? ("HBITMAP:*" hBitmapsSB[ShrineItem%ShrineaddIndex%]) : ""
	MainGui["ShrineData" ShrineaddIndex].Text := "(" ShrineAmount%ShrineaddIndex% ") [" ((ShrineIndex%ShrineaddIndex% = "Infinite") ? "∞" : ShrineIndex%ShrineaddIndex%) "]"
	MainGui["ShrineAdd" ShrineaddIndex].Text := ((AddShrineItem = "None" || AddShrineItem = "") ? "Add" : "Clear")

	For ui in uiList
		MainGui[ui].Visible := 0
	loop 2 {
		MainGui["ShrineAdd" A_Index].Visible := 1
		MainGui["ShrineData" A_Index].Visible := 1
		MainGui["ShrineItem" A_Index "Picture"].Visible := 1
	}
	ShrineAdd := 0
}
nm_StickerStackCheck(*){
	global
	local c
	StickerStackCheck := MainGui["StickerStackCheck"].Value
	c := (StickerStackCheck = 1)
	MainGui["SSILeft"].Enabled := c
	MainGui["SSIRight"].Enabled := c
	MainGui["SSMLeft"].Enabled := c
	MainGui["SSMRight"].Enabled := c
	MainGui["StickerStackTimer"].Enabled := c
	MainGui["StickerStackItemHelp"].Enabled := c
	MainGui["StickerStackModeHelp"].Enabled := c
	MainGui["StickerStackSkinsHelp"].Enabled := c
	if (((c = 1) && InStr(StickerStackItem, "Sticker")) || (c = 0)) {
		MainGui["StickerStackHive"].Enabled := c
		MainGui["StickerStackCub"].Enabled := c
		MainGui["StickerStackVoucher"].Enabled := c
	}
	IniWrite StickerStackCheck, "settings\nm_config.ini", "Boost", "StickerStackCheck"
}
nm_StickerStackItem(GuiCtrl, *){
	global StickerStackItem
	static val := ["Tickets", "Sticker", "Sticker+Tickets"], l := val.Length

	if (StickerStackItem = "Tickets")
	{
		if (msgbox("Consider trading all of your valuable stickers to alternative account, to ensure that you do not lose any valuable stickers. Are you sure you want to use Stickers?", "Sticker Stack", 0x1034 " T60 Owner" MainGui.Hwnd) = "Yes")
			i := 1
		else
			return
	}
	else
		i := (StickerStackItem = "Sticker") ? 2 : 3

	MainGui["StickerStackItem"].Text := StickerStackItem := val[(GuiCtrl.Name = "SSIRight") ? (Mod(i, l) + 1) : (Mod(l + i - 2, l) + 1)]
	MainGui["StickerStackHive"].Enabled := MainGui["StickerStackCub"].Enabled := MainGui["StickerStackVoucher"].Enabled := (InStr(StickerStackItem, "Sticker") > 0)
	IniWrite StickerStackItem, "settings\nm_config.ini", "Boost", "StickerStackItem"
}
nm_StickerStackMode(GuiCtrl?, *){
	global StickerStackMode

	if IsSet(GuiCtrl)
		StickerStackMode := (StickerStackMode != 1)

	if (StickerStackMode = 0) {
		MainGui["StickerStackModeText"].Move(, , 85), MainGui["StickerStackModeText"].Redraw(), MainGui["StickerStackModeText"].Text := "Detect"
		MainGui["StickerStackTimer"].Visible := 0
	} else {
		MainGui["StickerStackModeText"].Move(, , 68), MainGui["StickerStackModeText"].Redraw(), MainGui["StickerStackModeText"].Text := hmsFromSeconds(StickerStackTimer)
		MainGui["StickerStackTimer"].Visible := 1
	}

	IniWrite StickerStackMode, "settings\nm_config.ini", "Boost", "StickerStackMode"
}
nm_StickerStackTimer(*){
	global StickerStackTimer
	StickerStackTimer := MainGui["StickerStackTimer"].Value
	MainGui["StickerStackModeText"].Opt("-Redraw"), MainGui["StickerStackModeText"].Text := hmsFromSeconds(StickerStackTimer), MainGui["StickerStackModeText"].Opt("+Redraw")
	IniWrite StickerStackTimer, "settings\nm_config.ini", "Boost", "StickerStackTimer"
}
nm_StickerStackModeText(*){
	global StickerStackMode, StickerStackTimer
	if (StickerStackMode = 1) {
		if IsInteger(time := InputBox("Enter the number of seconds (900-86400) to wait between each use of the Sticker Stack:", "Sticker Stack Timer", "T60").Value)
		{
			if ((time >= 900) && (time <= 86400)) {
				MainGui["StickerStackTimer"].Value := StickerStackTimer := time
				MainGui["StickerStackModeText"].Text := hmsFromSeconds(StickerStackTimer)
				IniWrite StickerStackTimer, "settings\nm_config.ini", "Boost", "StickerStackTimer"
			} else {
				msgbox "You must enter an integer between 900 and 86400!", "Sticker Stack Timer", 0x40030 " T20"
			}
		} else {
			msgbox "You must enter an integer!", "Sticker Stack Timer", 0x40030 " T20"
		}
	}
}
nm_StickerStackSkins(GuiCtrl, *){
	global
	%GuiCtrl.Name% := GuiCtrl.Value
	if (%GuiCtrl.Name% = 1) {
		%GuiCtrl.Name% := GuiCtrl.Value := 0
		if (msgbox("You have enabled the use of " StrReplace(GuiCtrl.Name, "StickerStack") . (GuiCtrl.Name != "StickerStackVoucher" ? " Skins":"s") " on the Sticker Stack!`nAre you sure you want to enable this?", "WARNING!!", 0x40034 " T60") = "Yes")
			%GuiCtrl.Name% := GuiCtrl.Value := 1
	}
	IniWrite GuiCtrl.Value, "settings\nm_config.ini", "Boost", GuiCtrl.Name
}
nm_StickerStackItemHelp(*){
	msgbox "
	(
	Choose the item you prefer to use for activating the Sticker Stack!

	'Tickets' is the default option: it will use the 25 Tickets option to activate the boost.

	'Sticker' is an option if you want to stack your Stickers. It will always use your first Sticker if there is one, otherwise it will stop using the Sticker Stack.

	'Sticker+Tickets' is an option that uses all of your Stickers first, then uses your Tickets once you have run out of Stickers.
	)", "Sticker Stack Item", 0x40000 " T60"
}
nm_StickerStackModeHelp(*){
	msgbox "
	(
	Choose how long you want to wait between each Sticker Stack boost!

	'Detect' is the default option: it will detect the time each boost lasts and will go back to activate the Sticker Stack when it's over.

	The other option is a custom timer, you can set it to any value between 15 minutes and 24 hours, the macro will activate Sticker Stack at this time interval.

	NOTE: If you change from a custom timer to 'Detect', the macro will still use your custom timer for the time until your next visit to the Sticker Stack.
	)", "Sticker Stack Timer", 0x40000 " T60"
}
nm_StickerStackSkinsHelp(*){
	msgbox "
	(
	Choose which Stickers you want to stack on the Sticker Stack.

	If 'Hive' is checked, the macro will donate Hive Skins to the Sticker Stack after all normal Stickers have been used up. Otherwise, these will not be used.

	If 'Cub' is checked, the macro will donate Cub Skins to the Sticker Stack after all normal Stickers and Hive Skins (if enabled) have been used up. Otherwise, these will not be used.

	If 'Voucher' is checked, the macro will donate Vouchers to the Sticker Stack after all normal Stickers, Hive Skins, and Cubs (if enabled) have been used up. Otherwise, these will not be used.

	)", "Sticker Stack Skins", 0x40000 " T60"
}
nm_StickerPrinterCheck(*){
	global
	StickerPrinterCheck := MainGui["StickerPrinterCheck"].Value
	MainGui["SPELeft"].Enabled := MainGui["SPERight"].Enabled := (StickerPrinterCheck = 1)
	IniWrite StickerPrinterCheck, "settings\nm_config.ini", "Collect", "StickerPrinterCheck"
}
nm_StickerPrinterEgg(GuiCtrl, *){
	global StickerPrinterEgg
	static val := ["Basic", "Silver", "Gold", "Diamond", "Mythic"], l := val.Length

	switch StickerPrinterEgg, 0
	{
		case "Basic":
		i := 1
		case "Silver":
		i := 2
		case "Gold":
		i := 3
		case "Diamond":
		i := 4
		default:
		i := 5
	}

	MainGui["StickerPrinterEgg"].Text := StickerPrinterEgg := val[(GuiCtrl.Name = "SPERight") ? (Mod(i, l) + 1) : (Mod(l + i - 2, l) + 1)]
	IniWrite StickerPrinterEgg, "settings\nm_config.ini", "Collect", "StickerPrinterEgg"
}
nm_BoostChaserCheck(*){
	global BoostChaserCheck, AutoFieldBoostActive
	IniWrite (BoostChaserCheck := MainGui["BoostChaserCheck"].Value), "settings\nm_config.ini", "Boost", "BoostChaserCheck"
	;disable AutoFieldBoost (mutually exclusive features)
	if (BoostChaserCheck = 1) {
		(IsSet(AFBGui) && IsObject(AFBGui)) && (AFBGui["AutoFieldBoostActive"].Value := AutoFieldBoostActive := 0)
		IniWrite 0, "settings\nm_config.ini", "Boost", "AutoFieldBoostActive"
		MainGui["AutoFieldBoostButton"].Text := "Auto Field Boost`n[OFF]"
	}
}
nm_BoostedFieldSelectButton(*){
	global
	local GuiCtrl
	GuiClose(*){
		if (IsSet(BoostedFieldSelectGui) && IsObject(BoostedFieldSelectGui))
			BoostedFieldSelectGui.Destroy(), BoostedFieldSelectGui := ""
	}
	GuiClose()
	BoostedFieldSelectGui := Gui("+AlwaysOnTop -MinimizeBox +Owner" MainGui.Hwnd, "Select boosted gather fields")
	BoostedFieldSelectGui.OnEvent("Close", GuiClose)
	BoostedFieldSelectGui.Add("Text", "x9 y10", "
	(
	This option allows you to select which fields to gather in, if boosted.
	If the free field booster boosts a field that is not selected here,
	the macro will ignore it and continue with other tasks.
	)")
	BoostedFieldSelectGui.SetFont("Norm")
	BoostedFieldSelectGui.Add("Text", "x10 y54", "Blue")
	(GuiCtrl := BoostedFieldSelectGui.Add("CheckBox", "xp-2 yp+18 vBlueFlowerBoosterCheck Checked" BlueFlowerBoosterCheck, "Blue Flower")).Section := "Boost", GuiCtrl.OnEvent("Click", nm_saveConfig)
	(GuiCtrl := BoostedFieldSelectGui.Add("CheckBox", "xp yp+14 vBambooBoosterCheck Checked" BambooBoosterCheck, "Bamboo")).Section := "Boost", GuiCtrl.OnEvent("Click", nm_saveConfig)
	(GuiCtrl := BoostedFieldSelectGui.Add("CheckBox", "xp yp+14 vPineTreeBoosterCheck Checked" PineTreeBoosterCheck, "Pine Tree")).Section := "Boost", GuiCtrl.OnEvent("Click", nm_saveConfig)
	(GuiCtrl := BoostedFieldSelectGui.Add("CheckBox", "xp yp+14 vStumpBoosterCheck Checked" StumpBoosterCheck, "Stump")).Section := "Boost", GuiCtrl.OnEvent("Click", nm_saveConfig)

	BoostedFieldSelectGui.Add("Text", "x10 y138", "Other")
	(GuiCtrl := BoostedFieldSelectGui.Add("CheckBox", "xp-2 yp+18 vCoconutBoosterCheck Checked" CoconutBoosterCheck, "Coconut")).Section := "Boost", GuiCtrl.OnEvent("Click", nm_coconutBoosterCheck)

	BoostedFieldSelectGui.Add("Text", "x134 y54", "Mountain top")
	(GuiCtrl := BoostedFieldSelectGui.Add("CheckBox", "xp-2 yp+18 vDandelionBoosterCheck Checked" DandelionBoosterCheck, "Dandelion")).Section := "Boost", GuiCtrl.OnEvent("Click", nm_saveConfig)
	(GuiCtrl := BoostedFieldSelectGui.Add("CheckBox", "xp yp+14 vSunflowerBoosterCheck Checked" SunflowerBoosterCheck, "Sunflower")).Section := "Boost", GuiCtrl.OnEvent("Click", nm_saveConfig)
	(GuiCtrl := BoostedFieldSelectGui.Add("CheckBox", "xp yp+14 vCloverBoosterCheck Checked" CloverBoosterCheck, "Clover")).Section := "Boost", GuiCtrl.OnEvent("Click", nm_saveConfig)
	(GuiCtrl := BoostedFieldSelectGui.Add("CheckBox", "xp yp+14 vSpiderBoosterCheck Checked" SpiderBoosterCheck, "Spider")).Section := "Boost", GuiCtrl.OnEvent("Click", nm_saveConfig)
	(GuiCtrl := BoostedFieldSelectGui.Add("CheckBox", "xp yp+14 vPineappleBoosterCheck Checked" PineappleBoosterCheck, "Pineapple")).Section := "Boost", GuiCtrl.OnEvent("Click", nm_saveConfig)
	(GuiCtrl := BoostedFieldSelectGui.Add("CheckBox", "xp yp+14 vCactusBoosterCheck Checked" CactusBoosterCheck, "Cactus")).Section := "Boost", GuiCtrl.OnEvent("Click", nm_saveConfig)
	(GuiCtrl := BoostedFieldSelectGui.Add("CheckBox", "xp yp+14 vPumpkinBoosterCheck Checked" PumpkinBoosterCheck, "Pumpkin")).Section := "Boost", GuiCtrl.OnEvent("Click", nm_saveConfig)

	BoostedFieldSelectGui.Add("Text", "x256 y54", "Red")
	(GuiCtrl := BoostedFieldSelectGui.Add("CheckBox", "xp-2 yp+18 vMushroomBoosterCheck Checked" MushroomBoosterCheck, "Mushroom")).Section := "Boost", GuiCtrl.OnEvent("Click", nm_saveConfig)
	(GuiCtrl := BoostedFieldSelectGui.Add("CheckBox", "xp yp+14 vStrawberryBoosterCheck Checked" StrawberryBoosterCheck, "Strawberry")).Section := "Boost", GuiCtrl.OnEvent("Click", nm_saveConfig)
	(GuiCtrl := BoostedFieldSelectGui.Add("CheckBox", "xp yp+14 vRoseBoosterCheck Checked" RoseBoosterCheck, "Rose")).Section := "Boost", GuiCtrl.OnEvent("Click", nm_saveConfig)
	(GuiCtrl := BoostedFieldSelectGui.Add("CheckBox", "xp yp+14 vPepperBoosterCheck Checked" PepperBoosterCheck, "Pepper")).Section := "Boost", GuiCtrl.OnEvent("Click", nm_saveConfig)
	BoostedFieldSelectGui.Show("w335 h175")
}
nm_coconutBoosterCheck(*){
	global CoconutBoosterCheck, CoconutDisCheck, BoostChaserCheck
	BoostedFieldSelectGui.Opt("+OwnDialogs")
	IniWrite (CoconutBoosterCheck := BoostedFieldSelectGui["CoconutBoosterCheck"].Value), "settings\nm_config.ini", "Boost", "CoconutBoosterCheck"
	if(BoostChaserCheck && CoconutBoosterCheck) {
		MainGui["CoconutDisCheck"].Value := CoconutDisCheck := 1
		IniWrite 1, "settings\nm_config.ini", "Collect", "CoconutDisCheck"
		msgbox "Coconut Dispenser collection has been automatically enabled in the Collect Tab. This will allow the macro to boost and gather in coconut field every four hours.", "Coconut Dispenser Enabled!"
	}
}
nm_autoFieldBoostGui(*){
	global
	local GuiCtrl
	GuiClose(*){
		if (IsSet(AFBGui) && IsObject(AFBGui))
			AFBGui.Destroy(), AFBGui := ""
	}
	GuiClose()
	AFBGui := Gui("+AlwaysOnTop -MinimizeBox +Owner" MainGui.Hwnd, "Auto Field Boost Settings")
	AFBGui.OnEvent("Close", GuiClose)
	AFBGui.SetFont("s8 cDefault Norm", "Tahoma")
	AFBGui.Add("CheckBox", "x5 y5 vAutoFieldBoostActive Checked" AutoFieldBoostActive, "Activate Automatic Field Boost for Gathering Field:").OnEvent("Click", nm_autoFieldBoostCheck)
	AFBGui.SetFont("w800 cBlue")
	AFBGui.Add("Text", "x270 y5 left vAFBcurrentField", currentField)
	AFBGui.SetFont("s8 cDefault Norm", "Tahoma")
	AFBGui.Add("Button", "x20 y22 w120 h15", "What does this do?").OnEvent("Click", nm_AFBHelpButton)
	AFBGui.Add("Text", "x5 y42 w355 h1 0x7")
	AFBGui.Add("Text", "x20 y48", "Re-Buff Field Boost Every:")
	(GuiCtrl := AFBGui.Add("DropDownList", "x147 y46 w45 h150 vAutoFieldBoostRefresh", [8,8.5,9,9.5,10,10.5,11,11.5,12,12.5,13,13.5,14,14.5,15])).Text := AutoFieldBoostRefresh
	GuiCtrl.Section := "Boost", GuiCtrl.OnEvent("Change", nm_saveConfig)
	AFBGui.Add("Text", "x195 y48", "Minutes")
	AFBGui.Add("Button", "x5 y48 w10 h15", "?").OnEvent("Click", nm_AFBRebuffHelpButton)
	AFBGui.Add("Text", "x20 y70 +BackgroundTrans", "Use")
	AFBGui.Add("Text", "x5 y86 w355 h1 0x7")
	AFBGui.SetFont("s10")
	AFBGui.Add("Button", "x5 y90 w10 h15", "?").OnEvent("Click", nm_AFBDiceEnableHelpButton)
	AFBGui.Add("CheckBox", "x20 y90 vAFBDiceEnable Checked" AFBDiceEnable, "Dice:").OnEvent("Click", nm_AFBDiceEnableCheck)
	AFBGui.Add("Button", "x5 y113 w10 h15", "?").OnEvent("Click", nm_AFBGlitterEnableHelpButton)
	AFBGui.Add("CheckBox", "x20 y113 vAFBGlitterEnable Checked" AFBGlitterEnable, "Glitter:").OnEvent("Click", nm_AFBGlitterEnableCheck)
	AFBGui.Add("Button", "x5 y136 w10 h15", "?").OnEvent("Click", nm_AFBFieldEnableHelpButton)
	(GuiCtrl := AFBGui.Add("CheckBox", "x20 y136 vAFBFieldEnable Checked" AFBFieldEnable, "Free Field Boosters")).Section := "Boost", GuiCtrl.OnEvent("Click", nm_saveConfig)
	AFBGui.SetFont("s8 cDefault Norm", "Tahoma")
	AFBGui.Add("Text", "x80 y70 +BackgroundTrans", "Hotbar Slot")
	(GuiCtrl := AFBGui.Add("DropDownList", "x80 y88 w50 h120 vAFBDiceHotbar Disabled" (!AFBDiceEnable), ["None",2,3,4,5,6,7])).Text := AFBDiceHotbar, GuiCtrl.Section := "Boost", GuiCtrl.OnEvent("Change", nm_saveConfig)
	(GuiCtrl := AFBGui.Add("DropDownList", "x80 y110 w50 h120 vAFBGlitterHotbar Disabled" (!AFBGlitterEnable), ["None",2,3,4,5,6,7])).Text := AFBGlitterHotbar, GuiCtrl.Section := "Boost", GuiCtrl.OnEvent("Change", nm_saveConfig)
	AFBGui.Add("Text", "x160 y73 +BackgroundTrans", "|")
	AFBGui.Add("Text", "x160 y83 +BackgroundTrans", "|")
	AFBGui.Add("Text", "x160 y93 +BackgroundTrans", "|")
	AFBGui.Add("Text", "x160 y103 +BackgroundTrans", "|")
	AFBGui.Add("Text", "x160 y113 +BackgroundTrans", "|")
	AFBGui.Add("Text", "x160 y123 +BackgroundTrans", "|")
	AFBGui.Add("Text", "x160 y133 +BackgroundTrans", "|")
	AFBGui.Add("Text", "x160 y143 +BackgroundTrans", "|")
	AFBGui.Add("Text", "x160 y153 +BackgroundTrans", "|")
	AFBGui.Add("Text", "x160 y163 +BackgroundTrans", "|")
	AFBGui.Add("Button", "x170 y70 w10 h15", "?").OnEvent("Click", nm_AFBDeactivationLimitsHelpButton)
	AFBGui.Add("Text", "x185 y70 cRED +BackgroundTrans", "DEACTIVATION LIMITS:")
	AFBGui.Add("Text", "x298 y42 +BackgroundTrans", "Reset Used:")
	AFBGui.Add("Button", "x318 y55 w40 h15", "Dice").OnEvent("Click", nm_resetUsedDice)
	AFBGui.Add("Button", "x318 y70 w40 h15", "Glitter").OnEvent("Click", nm_resetUsedGlitter)
	;AFBGui.Add("Text", "x155 y40 +BackgroundTrans", "Set Limits")
	AFBGui.Add("Button", "x170 y90 w10 h15", "?").OnEvent("Click", nm_AFBDiceLimitEnableHelpButton)
	(GuiCtrl := AFBGui.Add("DropDownList", "x185 y88 w50 h120 vAFBDiceLimitEnableSel Disabled" (!AFBDiceEnable), ["Limit", "None"])).Text := AFBDiceLimitEnable ? "Limit" : "None", GuiCtrl.OnEvent("Change", nm_AFBDiceLimitEnable)
	AFBGui.Add("Button", "x170 y113 w10 h15", "?").OnEvent("Click", nm_AFBGlitterLimitEnableHelpButton)
	(GuiCtrl := AFBGui.Add("DropDownList", "x185 y110 w50 h120 vAFBGlitterLimitEnableSel Disabled" (!AFBGlitterEnable), ["Limit", "None"])).Text := AFBGlitterLimitEnable ? "Limit" : "None", GuiCtrl.OnEvent("Change", nm_AFBGlitterLimitEnable)
	AFBGui.Add("Button", "x170 y156 w10 h15", "?").OnEvent("Click", nm_AFBHoursLimitEnableHelpButton)
	(GuiCtrl := AFBGui.Add("DropDownList", "x185 y152 w50 h120 vAFBHoursLimitEnableSel", ["Limit", "None"])).Text := AFBHoursLimitEnable ? "Limit" : "None", GuiCtrl.OnEvent("Change", nm_AFBHoursLimitEnable)
	AFBGui.Add("Text", "x240 y90 +BackgroundTrans", "to")
	AFBGui.Add("Text", "x305 y90 +BackgroundTrans", "Dice Used")
	AFBGui.Add("Text", "x240 y113 +BackgroundTrans", "to")
	AFBGui.Add("Text", "x305 y113 +BackgroundTrans", "Glitter Used")
	AFBGui.Add("Text", "x240 y156 +BackgroundTrans", "to")
	AFBGui.Add("Text", "x305 y156 +BackgroundTrans", "Hours")
	(GuiCtrl := AFBGui.Add("Edit", "x255 y88 w45 h20 limit6 number vAFBDiceLimit Disabled" (!AFBDiceLimitEnable || !AFBDiceEnable), AFBDiceLimit)).Section := "Boost", GuiCtrl.OnEvent("Change", nm_saveConfig)
	(GuiCtrl := AFBGui.Add("Edit", "x255 y110 w45 h20 limit6 number vAFBGlitterLimit Disabled" (!AFBGlitterLimitEnable || !AFBGlitterEnable), AFBGlitterLimit)).Section := "Boost", GuiCtrl.OnEvent("Change", nm_saveConfig)
	AFBGui.Add("Text", "x185 y136 +BackgroundTrans", "Deactivate Field Boosting After:")
	(GuiCtrl := AFBGui.Add("Edit", "x255 y152 w45 h20 limit6 Number vAFBHoursLimit Disabled" (!AFBHoursLimitEnable), AFBHoursLimit)).Section := "Boost", GuiCtrl.OnEvent("Change", nm_saveConfig)
	;AFBGui.Add("Text", "x5 y123 +BackgroundTrans", "________________________________________________________")
	AFBGui.Show("w360 h170")
}
nm_AFBHelpButton(*){
	MsgBox "
	(
	PURPOSE:
	This option will use the selected Dice, Glitter, and Field Boosters automatically to build and maintain a field boost for your current gathering field (as defined in the Main tab).

	THIS DOES NOT:
	* quickly build your boost multiplier up to x4.  If this is what you want then it is best to manually do this before using this feature.
	* use items from your inventory.  You must include the Dice and Glitter on your hotbar and make sure the slots match the settings.

	HOW IT WORKS:
	This field boost will be Re-buffed at the interval defined in the settings.
	It will use the items that are selected in the following priority:
	1) Free Field Booster, 2) Dice, 3) Glitter.
	The Dice and Glitter item uses will be alternated so it can stack field boosts.
	If there are any deactivation limits set, this option will disable itself once both the Dice and Glitter or the Hours limits have been reached.

	RECOMMENDATIONS:
	It is highly recommended to disable all other macro options except your gathering field.
	This will ensure you are actually benefiting from the use of your materials!

	Please reference the various "?" buttons for additional information.
	)", "Auto Field Boost Description"
}
nm_AFBRebuffHelpButton(*){
	MsgBox "This setting defines the time interval between each Field Boost buff.", "Re-Buff Field Boost"
}
nm_AFBDiceEnableHelpButton(*){
	MsgBox "
	(
	This setting indicates if you would like to use Field Dice (NOT Smooth or Loaded) to boost your current gathering field.
	The Hotbar Slot indicates which slot on your hotbar contains these dice.

	These Dice will be re-rolled until your your gathering field is boosted.
	If Glitter is also selected the macro will alternate between using Dice and Glitter so it will stack Field Boost multipliers.

	CAUTION!!
	This can use up a lot of dice quickly!
	If you would like to limit the number of dice used for this, then make sure to set a limit for them in the DEACTIVATION LIMITS.
	)", "Enable Dice Use"
}
nm_AFBGlitterEnableHelpButton(*){
	MsgBox "
	(
	This setting indicates if you would like to use Glitter to boost your current gathering field.
	The Hotbar Slot indicates which slot on your hotbar contains these dice.

	The macro will only attempt to use Glitter if you are currently in the field.
	If Dice is also selected the macro will alternate between using Dice and Glitter so it will stack Field Boost multipliers.
	)", "Enable Glitter Use"
}
nm_AFBFieldEnableHelpButton(*){
	MsgBox "
	(
	This setting indicates if you would like to use the Free Field Boosters (Blue, Red, or Mountain Top) to boost your current gathering field.

	The macro will determine which Field Booster applies for your current gathering field and will use the Free Field Booster first if it available.
	If this does not boost your gathering field, the macro will use Dice or Glitter instead (if enabled in settings).
	)", "Enable Free Field Booster Use"
}
nm_AFBDeactivationLimitsHelpButton(*){
	MsgBox "
	(
	These settings are limits that you can set to deactivate (turn off) Auto Field Boost.

	If any of the limits defined are met, then Auto Field Boost will be deactivated.
	)", "Deactivation Limits"
}
nm_AFBDiceLimitEnableHelpButton(*){
	MsgBox "
	(
	The setting of "Limit" will cause Auto Field Boost to become deactivated (turned off) after the specified total number of dice are used.

	The setting of "None" indicates that there is no Dice use limit.
	The macro will continue to use Dice for as long as Auto Field Boost is enabled.

	NOTE:
	The counter for the used Dice is reset each time you activate Auto Field Boost, enable Dice, or press the Reset Used: 'Dice' button.
	)", "Dice Limit Deactivation"
}
nm_AFBGlitterLimitEnableHelpButton(*){
	MsgBox "
	(
	The setting of "Limit" will cause Auto Field Boost to become deactivated (turned off) after the specified total number of Glitter are used.

	The setting of "None" indicates that there is no Glitter use limit.
	The macro will continue to use Glitter for as long as Auto Field Boost is enabled.

	NOTE:
	The counter for the used Glitter is reset each time you activate Auto Field Boost, enable Glitter, or press the Reset Used: 'Glitter' button.
	)", "Glitter Limit Deactivation"
}
nm_AFBHoursLimitEnableHelpButton(*){
	MsgBox "
	(
	The setting of "Limit" will cause Auto Field Boost to become deactivated (turned off) after the specified total number of Hours have elapsed since starting the macro.

	The setting of "None" indicates that there is no Hours limit.
	The macro will continue use Dice and/or Glitter (if enabled in settings) for as long as Auto Field Boost is enabled.

	NOTE:
	The counter for the elapsed Hours is reset each time you stop the macro (F3).
	)", "Hours Limit Deactivation"
}
nm_resetUsedDice(*){
	global AFBdiceUsed:=0
	IniWrite AFBdiceUsed, "settings\nm_config.ini", "Boost", "AFBdiceUsed"
}
nm_resetUsedGlitter(*){
	global AFBglitterUsed:=0
	IniWrite 0, "settings\nm_config.ini", "Boost", "AFBglitterUsed"
}
nm_autoFieldBoostCheck(*){
	global
	if ((AutoFieldBoostActive := AFBGui["AutoFieldBoostActive"].Value) = 1) {
		if (MsgBox("
		(
		You have selected to "Activate Automatic Field Boost".

		If no DEACTIVATION LIMITS are set then this option will continue to use the selected items until they are completely gone.

		Please make ABSOLUTELY SURE that the settings you have selected are correct!
		)", "WARNING!!", 1) = "Ok")
		{
			AFBGui["AutoFieldBoostActive"].Value := AutoFieldBoostActive := 1
			IniWrite AFBdiceUsed:=0, "settings\nm_config.ini", "Boost", "AFBdiceUsed"
			IniWrite AFBglitterUsed:=0, "settings\nm_config.ini", "Boost", "AFBglitterUsed"
			MainGui["BoostChaserCheck"].Value := BoostChaserCheck := 0
			IniWrite 0, "settings\nm_config.ini", "Boost", "BoostChaserCheck"
		} else {
			AFBGui["AutoFieldBoostActive"].Value := AutoFieldBoostActive := 0
			MainGui["AutoFieldBoostButton"].Text := "Auto Field Boost`n[OFF]"
		}
	}
	IniWrite AutoFieldBoostActive, "settings\nm_config.ini", "Boost", "AutoFieldBoostActive"
	MainGui["AutoFieldBoostButton"].Text := AutoFieldBoostActive ? "Auto Field Boost`n[ON]" : "Auto Field Boost`n[OFF]"
}
nm_AFBDiceEnableCheck(*){
	global
	AFBDiceEnable := AFBGui["AFBDiceEnable"].Value
	AFBDiceLimitEnableSel := AFBGui["AFBDiceLimitEnableSel"].Text
	if(not AFBDiceEnable){
		AFBGui["AFBDiceHotbar"].Enabled := 0
		AFBGui["AFBDiceLimitEnableSel"].Enabled := 0
		AFBGui["AFBDiceLimit"].Enabled := 0
	} else {
		AFBGui["AFBDiceHotbar"].Enabled := 1
		AFBGui["AFBDiceLimitEnableSel"].Enabled := 1
		AFBGui["AFBDiceLimit"].Enabled := (AFBDiceLimitEnableSel="Limit")
		IniWrite AFBdiceUsed:=0, "settings\nm_config.ini", "Boost", "AFBdiceUsed"
	}
	IniWrite AFBDiceEnable, "settings\nm_config.ini", "Boost", "AFBDiceEnable"
}
nm_AFBGlitterEnableCheck(*){
	global
	AFBGlitterEnable := AFBGui["AFBGlitterEnable"].Value
	AFBGlitterLimitEnableSel := AFBGui["AFBGlitterLimitEnableSel"].Text
	if(not AFBGlitterEnable){
		AFBGui["AFBGlitterHotbar"].Enabled := 0
		AFBGui["AFBGlitterLimitEnableSel"].Enabled := 0
		AFBGui["AFBGlitterLimit"].Enabled := 0
	} else {
		AFBGui["AFBGlitterHotbar"].Enabled := 1
		AFBGui["AFBGlitterLimitEnableSel"].Enabled := 1
		AFBGui["AFBGlitterLimit"].Enabled := (AFBGlitterLimitEnableSel="Limit")
		IniWrite AFBglitterUsed:=0, "settings\nm_config.ini", "Boost", "AFBGlitterUsed"
	}
	IniWrite AFBGlitterEnable, "settings\nm_config.ini", "Boost", "AFBGlitterEnable"
}
nm_AFBDiceLimitEnable(*){
	global
	AFBDiceLimitEnableSel := AFBGui["AFBDiceLimitEnableSel"].Text
	IniWrite (AFBGui["AFBDiceLimit"].Enabled := (AFBDiceLimitEnableSel="Limit")), "settings\nm_config.ini", "Boost", "AFBDiceLimitEnable"
}
nm_AFBGlitterLimitEnable(*){
	global
	AFBGlitterLimitEnableSel := AFBGui["AFBGlitterLimitEnableSel"].Text
	IniWrite (AFBGui["AFBGlitterLimit"].Enabled := (AFBGlitterLimitEnableSel="Limit")), "settings\nm_config.ini", "Boost", "AFBGlitterLimitEnable"
}
nm_AFBHoursLimitEnable(*){
	global
	AFBHoursLimitEnableSel := AFBGui["AFBHoursLimitEnableSel"].Text
	IniWrite (AFBGui["AFBHoursLimit"].Enabled := (AFBHoursLimitEnableSel="Limit")), "settings\nm_config.ini", "Boost", "AFBHoursLimitEnable"
}
;//todo: pending rewrite of detections?
nm_Boost(){
	if(nm_NightInterrupt() || nm_MondoInterrupt())
		return

	nm_StickerStack()

	if ((QuestBoostCheck = 0) && QuestGatherField && (QuestGatherField != "None"))
		return
	try
		if (nm_PBoost() = 1)
			return
	nm_shrine()
	nm_toAnyBooster()
}
nm_StickerStack(){
	global StickerStackCheck, LastStickerStack, StickerStackItem, StickerStackMode, StickerStackTimer, StickerStackHive, StickerStackCub, StickerStackVoucher, SC_E, bitmaps

	if (StickerStackCheck && (nowUnix()-LastStickerStack)>StickerStackTimer) {
		loop 2 {
			nm_Reset()
			nm_setStatus("Traveling", "Sticker Stack" ((A_Index > 1) ? " (Attempt 2)" : ""))

			nm_gotoCollect("stickerstack")
			GetRobloxClientPos()

			searchRet := nm_imgSearch("e_button.png",30,"high")
			If (searchRet[1] = 0) {
				sendinput "{" SC_E " down}"
				Sleep 100
				sendinput "{" SC_E " up}"
				sleep 500 ;//todo: wait for GUI with timeout instead of fixed time

				; detect stack boost time
				pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2-275 "|" windowY+4*windowHeight//10 "|550|220")
				Loop 1 {
					if (Gdip_ImageSearch(pBMScreen, bitmaps["stickerstackdigits"][")"], &pos, 275, , , 45, 20) = 1) {
						x := SubStr(pos, 1, InStr(pos, ",")-1)
						(digits := Map()).Default := ""
						Loop 10 {
							n := 10-A_Index
							Gdip_ImageSearch(pBMScreen, bitmaps["stickerstackdigits"][n], &pos, x, , , 45, 20, , , 4, , "`n")
							Loop Parse pos, "`n"
								if (A_Index & 1)
									digits[Integer(A_LoopField)] := n
						}

						num := ""
						for x,y in digits
							num .= y

						if ((StrLen(num) = 4) && (SubStr(num, 4) = "0")) { ; check valid time before updating
							nm_setStatus("Detected", "Stack Boost Time: " hmsFromSeconds(time := 60 * SubStr(num, 1, 2) + SubStr(num, 3)))
							if (StickerStackMode = 0)
								StickerStackTimer := time
							break
						}
					}
					nm_setStatus("Error", "Unable to detect Stack Boost time!")
				}

				; check if sticker is available to donate
				if (InStr(StickerStackItem, "Sticker") && (((Gdip_ImageSearch(pBMScreen, bitmaps["stickernormal"], &pos, , , 275, , 25) = 1) && (stack := "Sticker"))
					|| ((Gdip_ImageSearch(pBMScreen, bitmaps["stickernormalalt"], &pos, , , 275, , 25) = 1) && (stack := "Sticker"))
					|| ((StickerStackHive = 1) && (Gdip_ImageSearch(pBMScreen, bitmaps["stickerhive"], &pos, , , 275, , 25) = 1) && (stack := "Hive Skin"))
					|| ((StickerStackCub = 1) && (Gdip_ImageSearch(pBMScreen, bitmaps["stickercub"], &pos, , , 275, , 25) = 1) && (stack := "Cub Skin"))
					|| ((StickerStackVoucher = 1) && (Gdip_ImageSearch(pBMScreen, bitmaps["stickervoucher"], &pos, , , 275, , 25) = 1) && (stack := "Voucher")))) {
					nm_setStatus("Stacking", stack)
					MouseMove windowX+windowWidth//2-275+SubStr(pos, 1, InStr(pos, ",")-1)+26, windowY+4*windowHeight//10+SubStr(pos, InStr(pos, ",")+1)-10 ; select sticker
					if (StickerStackMode = 0)
						StickerStackTimer += 10
				} else if InStr(StickerStackItem, "Tickets") {
					nm_setStatus("Stacking", stack := "Tickets")
					MouseMove windowX+windowWidth//2+105, windowY+4*windowHeight//10-78 ; select tickets
				} else { ; StickerStackItem = "Sticker", and nosticker was found or error
					nm_setStatus("Error", "No Stickers left to stack!`nSticker Stack has been disabled.")
					StickerStackCheck := 0
					Sleep 500
					sendinput "{" SC_E " down}"
					Sleep 100
					sendinput "{" SC_E " up}"
					break
				}
				Sleep 100
				Click
				Gdip_DisposeImage(pBMScreen)

				i := 0
				loop 16 {
					sleep 250
					pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2-250 "|" windowY+windowHeight//2-52 "|500|150")
					if (Gdip_ImageSearch(pBMScreen, bitmaps["yes"], &pos, , , , , 2, , 2) = 1) {
						MouseMove windowX+windowWidth//2-250+SubStr(pos, 1, InStr(pos, ",")-1)-50, windowY+windowHeight//2-52+SubStr(pos, InStr(pos, ",")+1)
						sleep 150
						Click
						sleep 100
						; voucher separate for aesthetic
						if ((++i >= 4) && !InStr(stack, "Skin") && !(stack="Voucher")) { ; Yes/No prompt appeared too many times, assume this is not a regular sticker
							Gdip_DisposeImage(pBMScreen)
							nm_setStatus("Error", "Yes/No appeared too many times!")
							Sleep 500
							sendinput "{" SC_E " down}"
							Sleep 100
							sendinput "{" SC_E " up}"
							break 2
						}
					} else if (i > 0) {
						Gdip_DisposeImage(pBMScreen)
						break
					} else if (A_Index = 16) {
						Gdip_DisposeImage(pBMScreen)
						nm_setStatus("Error", "No Tickets left to use!`nSticker Stack has been disabled.")
						StickerStackCheck := 0
						Sleep 500
						sendinput "{" SC_E " down}"
						Sleep 100
						sendinput "{" SC_E " up}"
						break 2
					}
					Gdip_DisposeImage(pBMScreen)
				}
				Sleep 2000
				nm_SetStatus("Collected", "Sticker Stack")
				break
			}
		}
		if (StickerStackCheck = 1) {
			LastStickerStack:=nowUnix()
			IniWrite LastStickerStack, "settings\nm_config.ini", "Boost", "LastStickerStack"
			if (StickerStackMode = 0) {
				MainGui["StickerStackTimer"].Value := StickerStackTimer
				IniWrite StickerStackTimer, "settings\nm_config.ini", "Boost", "StickerStackTimer"
			}
		}
	}
}
nm_shrine(){
	global GatherFieldBoostedStart, LastGlitter, LastShrine, ShrineCheck, ShrineItem1, ShrineItem2, ShrineAmount1, ShrineAmount2, ShrineIndex1, ShrineIndex2, ShrineRot

	nm_ShrineRotation() ; make sure ShrineRot hasnt changed
	if (ShrineCheck && (nowUnix()-LastShrine)>3600) { ;1 hour
		loop 2 {
			z := A_Index
			nm_Reset()
			nm_setStatus("Traveling", "Wind Shrine" ((A_Index > 1) ? " (Attempt 2)" : ""))

			nm_gotoCollect("WindShrine")

			searchRet := nm_imgSearch("e_button.png",30,"high")
			If (searchRet[1] = 0) {
				sendinput "{" SC_E " down}"
				Sleep 100
				sendinput "{" SC_E " up}"
				Sleep (2000+KeyDelay)

				GetRobloxClientPos(hwnd := GetRobloxHWND())
				MouseMove windowX+windowWidth//2, windowY+Floor(0.74*windowHeight) - 5 ;dialog
				sleep 150
				Click
				sleep 300
				Loop {
					sleep 150
					pBMScreen := Gdip_BitmapFromScreen(WindowX+Floor(0.515*windowWidth)-250 "|" windowY+Floor(0.535*windowHeight)-100 "|500|300")
					Donation := %("ShrineItem" ShrineRot)%

					if (Gdip_ImageSearch(pBMScreen, Shrine[Donation], , , , , , 2, , 4) > 0) {
						sleep 200
						MouseMove windowX+Floor(0.515*windowWidth)+157, windowY+Floor(0.535*windowHeight)+40 ; add more of x item
						sleep 150
						While (A_index < ShrineAmount%ShrineRot%) {
							Click
							sleep 35
						}
						sleep 300
						MouseMove windowX+Floor(0.515*windowWidth)-72, windowY+Floor(0.535*windowHeight)+116 ; donate button
						Gdip_DisposeImage(pBMScreen)
						sleep 150
						Click
						sleep 2000
						GetRobloxClientPos(hwnd)
						Loop 500 {
							pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2-50 "|" windowY+2*windowHeight//3 "|100|" windowHeight//3)
							if (Gdip_ImageSearch(pBMScreen, bitmaps["dialog"], &pos, , , , , 10, , 3) != 1) {
								Gdip_DisposeImage(pBMScreen)
								break
							}
							Gdip_DisposeImage(pBMScreen)
							MouseMove windowX+windowWidth//2, windowY+2*windowHeight//3+SubStr(pos, InStr(pos, ",")+1)-15
							Click
							sleep 150
						}
						sleep 500
						gatherloot :=
						(
							nm_Walk(7, RightKey, FwdKey) "
							" nm_Walk(10, FwdKey) "
							" nm_Walk(10, FwdKey, RightKey) "
							" nm_Walk(7, BackKey) "
							" nm_Walk(2, RightKey) "
							" nm_Walk(3.75, BackKey) "
							" nm_Walk(3, LeftKey) "
							loop 4 {
							" nm_Walk(5, LeftKey) "
							" nm_Walk(1.5, BackKey) "
							" nm_Walk(5, RightKey) "
							" nm_Walk(1.5, BackKey) "
							}
							loop 2 {
							" nm_Walk(15, LeftKey) "
							" nm_Walk(1, FwdKey) "
							" nm_Walk(15, RightKey) "
							" nm_Walk(1, FwdKey) "
							}
							" nm_Walk(15, LeftKey) "
							loop 4 {
							" nm_Walk(1.5, FwdKey) "
							" nm_Walk(5, RightKey) "
							" nm_Walk(1.5, FwdKey) "
							" nm_Walk(5, LeftKey) "
							}"
						)
						nm_createWalk(gatherloot)
						KeyWait "F14", "D T5 L"
						KeyWait "F14", "T60 L"
						nm_endWalk()
						nm_SetStatus("Collected", "Wind Shrine")

						if (ShrineIndex%ShrineRot% != "Infinite")  {
							ShrineIndex%shrineRot%-- ;subtract from shrineindex for looping only if its a number
							MainGui["ShrineData" ShrineRot].Text := "(" ShrineAmount%ShrineRot% ") [" ((ShrineIndex%ShrineRot% = "Infinite") ? "∞" : ShrineIndex%ShrineRot%) "]"
							IniWrite ShrineIndex%ShrineRot%, "settings\nm_config.ini", "Shrine", "ShrineIndex" ShrineRot
						}
						ShrineRot := Mod(ShrineRot, 2) + 1 ; determine Shrinerot
						nm_ShrineRotation()

						break 2
					} else {
						MouseMove windowX+Floor(0.515*windowWidth)+157, WindowY+Floor(0.535*windowHeight)-45
						sleep 150
						click
						Gdip_DisposeImage(pBMScreen)
						if (A_Index = 60) {
							if (z = 2)
								nm_setStatus("Failed", "Wind shrine")
							break
						}
						sleep 100
					}
				}
			}
		}
		LastShrine := nowUnix()
		IniWrite LastShrine, "settings\nm_config.ini", "Shrine", "LastShrine"
		IniWrite ShrineRot, "settings\nm_config.ini", "Shrine", "ShrineRot"
	}
}
nm_ShrineRotation() {
	global ShrineRot, ShrineItem1, ShrineItem2, ShrineCheck, ShrineIndex1, ShrineIndex2
	loop {
		if ((ShrineItem%ShrineRot% != "None" && ShrineItem%ShrineRot% != "") && (ShrineIndex%ShrineRot% = "Infinite" || ShrineIndex%ShrineRot% > 0)) {
			ShrineCheck := 1
			IniWrite 1, "settings\nm_config.ini", "Shrine", "ShrineCheck"
			break
		} else {
			ShrineRot := Mod(ShrineRot, 2) + 1
			if (A_Index = 3) {
				if (ShrineCheck) {
					ShrineCheck := 0
					IniWrite 0, "settings\nm_config.ini", "Shrine", "ShrineCheck"
					nm_setStatus("Confirmed", "No more items to rotate through. Turning shrine off")
				}
				break
			}
		}
	}
}
nm_toAnyBooster(){
	global LastBooster

	; prioritise coconut every 4 hours if enabled
	if((BoostChaserCheck && CoconutBoosterCheck && CoconutDisCheck) && (BoosterCooldown("coconut") && LastBoosterCheck()))
		nm_updateAction("Booster"), nm_toBooster("coconut")

	; other
	eligible := [], available := 0
	while(A_Index < 4 && (FieldBooster%A_Index%!="none" || QuestBlueBoost || QuestRedBoost))
	{
		i := A_Index
		for name in ["Red", "Blue", "Mountain"]
		{
			if (FieldBooster%i% = name) || ((name = "Red" || name = "Blue") && Quest%name%Boost)
			{
				loop 2
					if eligible.Length >= A_Index && eligible[A_Index][1] = name
						continue 2

				if BoosterCooldown(name) && LastBoosterCheck()
					eligible.Push([name, "available"]), available++
				else
					eligible.Push([name, "unavailable"])
			}
		}
	}
	; ensure rotation through all available boosters, even if earlier one comes off cool-down
	if available > 0
	{
		loop 1
		{
			if IsSet(LastBooster)
			{
				loop eligible.Length
				{
					i := A_Index
					if eligible[i][1] = LastBooster
					{
						loop eligible.Length
						{
							i := (i < eligible.Length) ? i+1 : 1
							if eligible[i][2] = "available"
							{
								next := eligible[i][1]
								break 3
							}
						}
						break
					}
				}
			}
			; otherwise default to first available, for session start and as failsafe
			loop eligible.Length
				if eligible[A_Index][2] = "available"
				{
					next := eligible[A_Index][1]
					break 2
				}
		}
		LastBooster := next
		nm_updateAction("Booster"), nm_toBooster(next)
	}
	LastBoosterCheck() => ((nowUnix()-max(LastBlueBoost, LastRedBoost, LastMountainBoost, (BoostChaserCheck && CoconutBoosterCheck && CoconutDisCheck) ? LastCoconutDis : 1))>(FieldBoosterMins*60))
	BoosterCooldown(booster) => (booster = "coconut" ? ((nowUnix()-LastCoconutDis)>14400) : (nowUnix()-Last%booster%Boost)>2700)
}
nm_toBooster(location){
	global LastBlueBoost, LastRedBoost, LastMountainBoost, LastCoconutDis, RecentFBoost
	static blueBoosterFields:=["Pine Tree", "Bamboo", "Blue Flower", "Stump"], redBoosterFields:=["Rose", "Strawberry", "Mushroom", "Pepper"], mountainBoosterfields:=["Cactus", "Pumpkin", "Pineapple", "Spider", "Clover", "Dandelion", "Sunflower"], coconutBoosterfields:=["Coconut"]

	Loop 2 {
		nm_Reset(AFBuseBooster ? 1 : 0)
		nm_setStatus("Traveling", ((location="Mountain") ? "Mountain Top Booster" : StrTitle(location) " Field Booster") . ((A_Index=2) ? " (Attempt 2)" : ""))
		(location="coconut") ? (nm_gotoCollect("coconutdis")) : (nm_gotoBooster(location))
		if (nm_imgSearch("e_button.png",30,"high")[1] = 0) {
			sendinput "{" SC_E " down}"
			Sleep 100
			sendinput "{" SC_E " up}"
			Sleep 1000
			If (location = "coconut")
				LastCoconutDis:=nowUnix(), IniWrite(LastCoconutDis, "settings\nm_config.ini", "Collect", "LastCoconutDis")
			else
				Last%location%Boost:=nowUnix(), IniWrite(Last%location%Boost, "settings\nm_config.ini", "Collect", "Last" location "Boost")

			nm_createWalk((location = "mountain") ? nm_Walk(8, LeftKey) : (location = "red") ? nm_Walk(8, BackKey) : nm_Walk(8, RightKey))
			KeyWait "F14", "D T5 L"
			KeyWait "F14", "T10 L"
			nm_endWalk()
			if location = "red"
				nm_Move(2000*round(18/MoveSpeedNum, 3), FwdKey, RightKey) ; red needs additional steps to avoid the leaderboard area
			Loop 10 {
				for k,v in %location%BoosterFields {
					if nm_fieldBoostCheck(v, 1)
					{
						nm_setStatus("Boosted", v), RecentFBoost := v
						break 2
					}

				}

				sleep 200
				If A_Index = 10
					nm_setStatus("Failed", "Could not find field boost!")
			}
			break
		}
		else if (A_Index = 2)
		{
			If (location = "coconut") {
				LastCoconutDis:=nowUnix()-7200
				IniWrite LastCoconutDis, "settings\nm_config.ini", "Collect", "LastCoconutDis"
			} else {
				Last%location%Boost:=nowUnix()-1500
				IniWrite Last%location%Boost, "settings\nm_config.ini", "Collect", "Last" location "Boost"
			}
		}
	}
}

;;;;;;;;; START AFB
nm_AutoFieldBoost(fieldName){
	global FieldBooster, AFBrollingDice, AFBuseGlitter, AFBuseBooster, serverStart, AutoFieldBoostActive
		, FieldLastBoosted, FieldLastBoostedBy, FieldBoostStacks, AutoFieldBoostRefresh, AFBHoursLimitEnable
		, AFBHoursLimit, AFBFieldEnable, AFBDiceEnable, AFBGlitterEnable, MainGui, AFBGui
		, LastBlueBoost, LastRedBoost, LastMountainBoost

	if(not AutoFieldBoostActive)
		return
	if(AFBHoursLimitEnable && (nowUnix()-serverStart)>(AFBHoursLimit*60*60)){
		MainGui["AutoFieldBoostButton"].Text := "Auto Field Boost`n[OFF]"
		try AFBGui["AutoFieldBoostActive"].Value := 0
		IniWrite AutoFieldBoostActive := 0, "settings\nm_config.ini", "Boost", "AutoFieldBoostActive"
		return
	}

	if(not AFBrollingDice && ((nowUnix()-FieldLastBoosted)>(AutoFieldBoostRefresh*60) || (nowUnix()-FieldLastBoosted)<0)){ ;refresh period exceeded
		;check for field boost stack reset
		if((nowUnix()-FieldLastBoosted)>=(15*60)){ ;longer than 15 mins since last boost buff
			IniWrite FieldBoostStacks:=0, "settings\nm_config.ini", "Boost", "FieldBoostStacks"
			IniWrite FieldLastBoostedBy:="None", "settings\nm_config.ini", "Boost", "FieldLastBoostedBy"
		}
		;free booster first
		if(AFBFieldEnable){
			;determine which booster applies
			if((booster := FieldBooster[StrLower(fieldName)].booster)!="none") {
				boosterTimer := Last%booster%Boost
				if (nowUnix() - boosterTimer > 2700){
					AFBuseBooster:=1
				}
			}
		}
		;dice next
		if(AFBDiceEnable && not AFBrollingDice && (FieldLastBoostedBy="none" || FieldLastBoostedBy="glitter" || FieldLastBoostedBy="bbooster" || FieldLastBoostedBy="rbooster" || FieldLastBoostedBy="mbooster"
			|| (FieldLastBoostedBy="dice" && not AFBGlitterEnable))) {
			AFBrollingDice:=1
			nm_setStatus(0, "Boosting Field: Dice")
		}
		;glitter next
		if(AFBGlitterEnable && not AFBrollingDice && (FieldLastBoostedBy="none" || FieldLastBoostedBy="dice" || FieldLastBoostedBy="bbooster" || FieldLastBoostedBy="rbooster" || FieldLastBoostedBy="mbooster")) {
			nm_setStatus(0, "Boosting Field: Glitter")
			AFBuseGlitter:=1
		}

	} else { ;refresh period NOT exceeded
		return
	}
}
nm_fieldBoostCheck(fieldName, variant:=0){

	GetRobloxClientPos(hwnd:=GetRobloxHWND())
	pBMScreen:=Gdip_BitmapFromScreen(windowX "|" windowY + GetYOffset(hwnd) + 36 "|" windowWidth "|" 38)
	loop Floor(windowWidth/38) ; flooring because you won't have half of an icon
	{
		ico:=(A_Index-1)*38
		if (Gdip_ImageSearch(pBMScreen, bitmaps["boost"][StrReplace(fieldName, " ") variant],,ico,,ico+38,,(variant=1 || variant=0) ? 35 : 50)) ; testing tighter variation
		{ ; check with original 30 not 35
			p:=PixelGetColor(ico+windowX, windowY+GetYOffset(hwnd)+73)
			if ((p & 0xFF0000 >= 0xa60000) && (p & 0xFF0000 <= 0xcf0000)) ; a6b2b8-blackBG|cfdbe1-whiteBG
			&& ((p & 0x00FF00 >= 0x00b200) && (p & 0x00FF00 <= 0x00db00))
			&& ((p & 0x0000FF >= 0x0000b8) && (p & 0x0000FF <= 0x0000e1))
				continue ; winds: keep searching, winds and booster may both have boosted the field
			else if ((p & 0xFF0000 >= 0xb80000) && (p & 0xFF0000 <= 0xe10000)) ; b8a43a-blackBG|e1cd63-whiteBG
				&& ((p & 0x00FF00 >= 0x00a400) && (p & 0x00FF00 <= 0x00cd00))
				&& ((p & 0x0000FF >= 0x00003a) && (p & 0x0000FF <= 0x000063))
				{
					Gdip_DisposeImage(pBMScreen)
					return 1 ; booster
				}
		}
	}
	Gdip_DisposeImage(pBMScreen)
	return 0

}
nm_fieldBoostBooster(){
	global CurrentField, FieldBooster, AFBuseBooster, FieldLastBoosted, FieldBoostStacks, FieldLastBoostedBy, FieldNextBoostedBy, AFBFieldEnable, AFBDiceEnable, AFBGlitterEnable, FieldBoostStacks
	if (!AFBuseBooster)
		return
	nm_setStatus(0, "Boosting Field: Booster")
	booster := FieldBooster[StrLower(CurrentField)].booster
	if(booster="blue") {
		boosterName:="bbooster"
		nm_toBooster("blue")
	}
	else if(booster="red") {
		boosterName:="rbooster"
		nm_toBooster("red")
	}
	else if(booster="mountain") {
		boosterName:="mbooster"
		nm_toBooster("mountain")
	}
	AFBuseBooster:=0
	Sleep 5000
	;check if gathering field was boosted
	if(nm_fieldBoostCheck(CurrentField)) {
		nm_setStatus(0, "Field was Boosted: Booster")
		FieldLastBoosted:=nowUnix()
		FieldLastBoostedBy:=boosterName
		IniWrite FieldLastBoosted, "settings\nm_config.ini", "Boost", "FieldLastBoosted"
		IniWrite FieldLastBoostedBy, "settings\nm_config.ini", "Boost", "FieldLastBoostedBy"
		FieldBoostStacks:=FieldBoostStacks+FieldBooster[StrLower(CurrentField)].stacks
		IniWrite FieldBoostStacks, "settings\nm_config.ini", "Boost", "FieldBoostStacks"
		if(FieldBoostStacks>4)
			return
	}
	;determine next boost item
	;is it dice?
	if(AFBDiceEnable && (FieldLastBoostedBy="bbooster" || FieldLastBoostedBy="rbooster" || FieldLastBoostedBy="mbooster"|| FieldLastBoostedBy="glitter" || (FieldLastBoostedBy="dice" && not AFBGlitterEnable))) {
		FieldNextBoostedBy:="dice"
		IniWrite FieldNextBoostedBy, "settings\nm_config.ini", "Boost", "FieldNextBoostedBy"
	}
	;is it glitter?
	else if(AFBGlitterEnable && (FieldLastBoostedBy="dice" || ((FieldLastBoostedBy="bbooster" || FieldLastBoostedBy="rbooster" || FieldLastBoostedBy="mbooster")|| not AFBDiceEnable) || (FieldLastBoostedBy="glitter" && not AFBDiceEnable))) {
		FieldNextBoostedBy:="glitter"
		IniWrite FieldNextBoostedBy, "settings\nm_config.ini", "Boost", "FieldNextBoostedBy"
	}
	;is it booster?
	else if(AFBFieldEnable && not AFBDiceEnable && not AFBGlitterEnable) {
		FieldNextBoostedBy:=boosterName
		IniWrite FieldNextBoostedBy, "settings\nm_config.ini", "Boost", "FieldNextBoostedBy"
	}
}
nm_fieldBoostDice(){
	global AFBrollingDice, AFBdiceUsed, AFBDiceLimit, AFBDiceLimitEnable, CurrentField, FieldBooster, boostTimer
		, FieldLastBoosted, FieldLastBoostedBy, FieldNextBoostedBy, FieldBoostStacks, AutoFieldBoostRefresh
		, AFBFieldEnable, AFBDiceEnable, AFBGlitterEnable, AFBDiceHotbar, MainGui, AFBGui
	if(not nm_fieldBoostCheck(CurrentField)) {
		send "{sc00" AFBDiceHotbar+1 "}"
		AFBdiceUsed:=AFBdiceUsed+1
		IniWrite AFBdiceUsed, "settings\nm_config.ini", "Boost", "AFBdiceUsed"
		if(AFBDiceLimitEnable && AFBdiceUsed >= AFBDiceLimit) {
			AFBrollingDice:=0
			try AFBGui["AFBDiceEnable"].Value := 0
			IniWrite AFBDiceEnable := 0, "settings\nm_config.ini", "Boost", "AFBDiceEnable"
		}
		if(not AFBGlitterEnable and not AFBDiceEnable){
			try AFBGui["AutoFieldBoostActive"].Value := 0
			MainGui["AutoFieldBoostButton"].Text := "Auto Field Boost`n[OFF]"
			IniWrite AutoFieldBoostActive := 0, "settings\nm_config.ini", "Boost", "AutoFieldBoostActive"
		}
	} else {
		AFBrollingDice:=0
		nm_setStatus(0, "Field was Boosted: Dice")
		if(FieldLastBoostedBy!="dice" || FieldBoostStacks=0) {
			FieldBoostStacks:=FieldBoostStacks+1
			FieldLastBoostedBy:="dice"
			IniWrite FieldLastBoostedBy, "settings\nm_config.ini", "Boost", "FieldLastBoostedBy"
			IniWrite FieldBoostStacks, "settings\nm_config.ini", "Boost", "FieldBoostStacks"
		}
		FieldLastBoosted:=nowUnix()
		IniWrite FieldLastBoosted, "settings\nm_config.ini", "Boost", "FieldLastBoosted"
		;determine next boost item
		;is it booster?
		booster := FieldBooster[StrLower(CurrentField)].booster
		if(booster="blue") {
			boosterName:="bbooster"
			boostTimer := LastBlueBoost
		}
		else if(booster="red") {
			boosterName:="rbooster"
			boostTimer := LastRedBoost
		}
		else if(booster="mountain") {
			boosterName:="mbooster"
			boostTimer := LastMountainBoost
		}
		if(AFBFieldEnable && (nowUnix()-boostTimer)>(3600-AutoFieldBoostRefresh*60)) {
			FieldNextBoostedBy:=boosterName
			IniWrite FieldNextBoostedBy, "settings\nm_config.ini", "Boost", "FieldNextBoostedBy"
		}
		;is it glitter?
		else if(AFBGlitterEnable) {
			FieldNextBoostedBy:="glitter"
			IniWrite FieldNextBoostedBy, "settings\nm_config.ini", "Boost", "FieldNextBoostedBy"
		}
		;is it dice?
		else if(not AFBGlitterEnable) {
			FieldNextBoostedBy:="dice"
			IniWrite FieldNextBoostedBy, "settings\nm_config.ini", "Boost", "FieldNextBoostedBy"
		}
	}
}
nm_fieldBoostGlitter(){
	global AFBuseGlitter, AFBglitterUsed, CurrentField, FieldBooster, boostTimer, FieldLastBoosted, FieldLastBoostedBy, FieldNextBoostedBy, FieldBoostStacks
		, AutoFieldBoostRefresh, AFBFieldEnable, AFBDiceEnable, AFBGlitterEnable, AFBdiceHotbar, AFBGlitterHotbar, AFBGlitterLimit, AFBGlitterLimitEnable
	if(not AFBuseGlitter)
		return
	send "{sc00" AFBGlitterHotbar+1 "}"
	Sleep 2000
	;check if gathering field was boosted
	if(nm_fieldBoostCheck(CurrentField)) {
		nm_setStatus(0, "Field was Boosted: Glitter")
		AFBglitterUsed:=AFBglitterUsed+1
		IniWrite AFBglitterUsed, "settings\nm_config.ini", "Boost", "AFBglitterUsed"
		if(AFBGlitterLimitEnable && AFBglitterUsed >= AFBglitterLimit) {
			try AFBGui["AFBGlitterEnable"].Value := 0
			IniWrite AFBGlitterEnable := 0, "settings\nm_config.ini", "Boost", "AFBGlitterEnable"
		}
		if(not AFBGlitterEnable and not AFBDiceEnable){
			try AFBGui["AutoFieldBoostActive"].Value := 0
			MainGui["AutoFieldBoostButton"].Text := "Auto Field Boost`n[OFF]"
			IniWrite AutoFieldBoostActive := 0, "settings\nm_config.ini", "Boost", "AutoFieldBoostActive"
		}
		AFBuseGlitter:=0
		FieldLastBoosted:=nowUnix()
		FieldLastBoostedBy:="glitter"
		IniWrite FieldLastBoosted, "settings\nm_config.ini", "Boost", "FieldLastBoosted"
		IniWrite FieldLastBoostedBy, "settings\nm_config.ini", "Boost", "FieldLastBoostedBy"
		FieldBoostStacks:=FieldBoostStacks+1
		IniWrite FieldBoostStacks, "settings\nm_config.ini", "Boost", "FieldBoostStacks"
		;determine next boost item
		;is it booster?
		booster := FieldBooster[StrLower(CurrentField)].booster
		if(booster="blue") {
			boosterName:="bbooster"
			boostTimer := LastBlueBoost
		}
		else if(booster="red") {
			boosterName:="rbooster"
			boostTimer := LastRedBoost
		}
		else if(booster="mountain") {
			boosterName:="mbooster"
			boostTimer := LastMountainBoost
		}
		if(AFBFieldEnable && (nowUnix()-boostTimer)>(3600-AutoFieldBoostRefresh*60)) {
			FieldNextBoostedBy:=boosterName
			IniWrite FieldNextBoostedBy, "settings\nm_config.ini", "Boost", "FieldNextBoostedBy"
		}
		;is it dice?
		else if(AFBDiceEnable) {
			FieldNextBoostedBy:="dice"
			IniWrite FieldNextBoostedBy, "settings\nm_config.ini", "Boost", "FieldNextBoostedBy"
		}
		;is it glitter?
		else if(not AFBDiceEnable) {
			FieldNextBoostedBy:="glitter"
			IniWrite FieldNextBoostedBy, "settings\nm_config.ini", "Boost", "FieldNextBoostedBy"
		}

	}
}
;;;;;;;;; END AFB
