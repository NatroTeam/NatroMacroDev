DllCall(DllCall("GetProcAddress"
    , "Ptr", DllCall("LoadLibrary", "Str", A_WorkingDir "\nm_image_assets\Styles\USkin.dll")
    , "AStr", "USkinInit", "Ptr")
    , "Int", 0, "Int", 0, "AStr", A_WorkingDir "\nm_image_assets\styles\MacLion3.msstyles")
PrinterItem1 := "MythicEgg", PrinterItem2 := "GoldEgg", PrinterItem3 := "SilverEgg"
PrinterAmount1 := 10, PrinterAmount2 := 4, PrinterAmount3 := "infinite", PrinterTimer1 := "01:30:00", PrinterTimer2 := "01:30:00", PrinterTimer3 := "01:30:00"
TraySetIcon(".\nm_image_assets\auryn.ico")
pToken := Gdip_Startup()
stickerPBM := Map()
#Include nm_image_assets\gui\stickerprinter_bitmaps.ahk
(stickerPB := Map()).CaseSense := true
for x, y in stickerPBM
    stickerPB[x] := Gdip_CreateHBITMAPFromBitmap(y), Gdip_DisposeImage(y)
stickerPBM := unset
nm_stickerPrinterGUI() {
    global PrinterAmount1, PrinterAmount2, PrinterAmount3, PrinterItem1, PrinterItem2, PrinterItem3, PrinterTimer1, PrinterTimer2, PrinterTimer3
    static eggs := ["BasicEgg", "SilverEgg", "GiftedSilverEgg", "GoldEgg", "GiftedGoldEgg", "DiamondEgg", "GiftedDiamondEgg", "MythicEgg", "GiftedMythicEgg", "StarEgg"]
    printerEggIndex := 1, AddEggIndex := 0, AddEggInfiniteCheck := false, AddEggAmount := 1
    (StickerPrinterGUI := Gui(, "Sticker Printer")).Show("w190 h120")
    xp := 0
    loop 3 {
        StickerPrinterGUI.Add("Button", "x" (xp += 5) " y90 w30 h20 Hidden vRemoveButton" A_Index, "-").OnEvent("Click", DecreaseAmount)
        StickerPrinterGUI.Add("Button", "xp yp w60 hp Hidden vAddItemButton" A_Index, "Add").OnEvent("Click", AddItem)
        StickerPrinterGUI.Add("Text", "xp y10 w60 Center Hidden vItemCount" A_Index, "( " PrinterAmount%A_Index% " )")
        StickerPrinterGUI.Add("Text", "xp y115 w60 Center vPrinterTimer" A_Index, PrinterTimer%A_Index%)
        StickerPrinterGUI.Add("Pic", "xp+3.5 y30 w53 h58 +BackgroundTrans +0xE vStickerPrinterEgg" A_Index, "HBITMAP:*" stickerPB[PrinterItem%A_Index%])
        StickerPrinterGUI.Add("Button", "x" (xp += 30) " y90 w30 h20 Hidden vAddButton" A_Index, "+").OnEvent("Click", IncreaseAmount), xp += 30
    }
    StickerPrinterGUI.Add("Text", "x5 y10 w40 h15 vBackButton Hidden", "← Back").OnEvent("Click", (*) => switchMode(0))
    StickerPrinterGUI.Add("Pic", "x23.5 y35 w53 h58 +BackgroundTrans +0xE vStickerPrinterEggAdd Hidden", "HBITMAP:*" stickerPB["BasicEgg"])
    StickerPrinterGUI.Add("Button", "x3.5 y65 w15 h17 vAddEggLeft Hidden", "<").OnEvent("Click", ChangeEgg.Bind(-1))
    StickerPrinterGUI.Add("Button", "x81.5 y65 w15 h17 vAddEggRight Hidden", ">").OnEvent("Click", ChangeEgg.Bind(1))
    StickerPrinterGUI.Add("Button", "x23.5 y100 w53 h20 vAddEggButton Hidden", "Add").OnEvent("Click", AddEgg)
    StickerPrinterGUI.Add("Text", "x99 y0 w2 h130 0x7 vDiscriminator Hidden", "")
    StickerPrinterGUI.Add("CheckBox", "x110 y9 h20 vInfiniteCheck Hidden", "Infinite").OnEvent("Click", (*) => (AddEggInfiniteCheck := !AddEggInfiniteCheck, StickerPrinterGUI["PrinterAmountEdit"].enabled := !AddEggInfiniteCheck))
    StickerPrinterGUI.Add("GroupBox", "x106 y-2 w90 h66 vamountGB Hidden Right", "Amount")
    StickerPrinterGUI.Add("GroupBox", "x106 yp+64 w90 hp vPrinterItems Hidden Right", "Timer")
    StickerPrinterGUI.Add("Text", "x110 y36 vPrinterAmountText Hidden", "Amount:")
    StickerPrinterGUI.Add("Edit", "xp+42 yp-2.5 w41 h20 vPrinterAmountEdit Hidden", "1")
    StickerPrinterGUI.Add("UpDown", "xp+20 yp w10 h20 vPrinterAmountUpDown Hidden Range1-999")
    StickerPrinterGUI.Add("Checkbox", "x110 y77 vDailyCheck hidden", "Daily").OnEvent("Click", (*) => (StickerPrinterGUI['StickerPrinterTimeUD'].enabled := !StickerPrinterGUI['DailyCheck'].value, StickerPrinterGUI['StickerPrinterTimeUD'].value := 270, changeUpDn(StickerPrinterGUI['StickerPrinterTimeUD'])))
    StickerPrinterGUI.Add("Text", "x110 y100 w70 vStickerPrinterTime hidden", "01:30:00")
    StickerPrinterGUI.Add("UpDown", "xp+20 Range0-270 yp vStickerPrinterTimeUD").OnEvent("Change", changeUpDn), changeUpDn(StickerPrinterGUI["StickerPRinterTimeUD"])
    switchMode 0
    switchMode(mode := 0) {
        static controls0 := ["AddButton1", "AddButton2", "AddButton3", "RemoveButton1", "RemoveButton2", "RemoveButton3", "AddItemButton1", "AddItemButton2", "AddItemButton3", "ItemCount1", "ItemCount2", "ItemCount3", "PrinterTimer1", "PrinterTimer2", "PrinterTimer3", "StickerPrinterEgg1", "StickerPrinterEgg2", "StickerPrinterEgg3"],
            controls1 := ["BackButton", "StickerPrinterEggAdd", "AddEggLeft", "AddEggRight", "AddEggButton", "Discriminator", "amountGB", "InfiniteCheck", "PrinterItems", "PrinterAmountText", "PrinterAmountEdit", "PrinterAmountUpDown", "DailyCheck", "StickerPrinterTime", "StickerPRinterTimeUD"]
        switch mode {
            case 0:
                for i in controls1
                    StickerPrinterGUI[i].visible := false
                loop 3 {
                    if PrinterItem%A_Index% {
                        StickerPrinterGUI["StickerPrinterEgg" A_Index].visible := true, StickerPrinterGUI["StickerPrinterEgg" A_Index].value := "HBITMAP:*" stickerPB[PrinterItem%A_Index%]
                        StickerPrinterGUI["AddButton" A_Index].visible := StickerPrinterGUI["ItemCount" A_Index].visible := StickerPrinterGUI["RemoveButton" A_Index].visible := true
                        StickerPrinterGUI["AddButton" A_Index].enabled := !(PrinterAmount%A_Index% = "infinite")
                        StickerPrinterGUI["AddItemButton" A_Index].visible := false
                        StickerPrinterGUI["PrinterTimer" A_Index].visible := true
                    }
                    else {
                        StickerPrinterGUI["StickerPrinterEgg" A_Index].visible := false
                        StickerPrinterGUI["AddButton" A_Index].visible := StickerPrinterGUI["ItemCount" A_Index].visible := StickerPrinterGUI["RemoveButton" A_Index].visible := false
                        StickerPrinterGUI["AddItemButton" A_Index].visible := true
                    }
                }
            case 1:
                for i in controls0
                    StickerPrinterGUI[i].visible := false
                for i in controls1
                    StickerPrinterGUI[i].visible := true
        }
    }
    ChangeEgg(direction, *) {
        printerEggIndex := Mod(printerEggIndex + direction, eggs.Length) || eggs.Length
        StickerPrinterGUI["StickerPrinterEggAdd"].value := "HBITMAP:*" stickerPB[eggs[printerEggIndex]]
    }
    IncreaseAmount(control, *) {
        global PrinterAmount1, PrinterAmount2, PrinterAmount3
        index := SubStr(control.name, -1)
        amount := GetKeyState("Control") || GetKeyState("Shift") ? 10 : 1
        StickerPrinterGUI["ItemCount" index].Text := "( " (PrinterAmount%(index)% := PrinterAmount%(index)% +amount) " )"
    }
    AddEgg(*) {
        PrinterItem%(AddEggIndex)% := eggs[printerEggIndex]
        StickerPrinterGUI["StickerPrinterEgg" AddEggIndex].value := "HBITMAP:*" stickerPB[PrinterItem%(AddEggIndex)%]
        StickerPrinterGUI["ItemCount" AddEggIndex].Text := "( " (PrinterAmount%(AddEggIndex)% := AddEggInfiniteCheck ? "infinite" : StickerPrinterGUI["PrinterAmountEdit"].value) " )"
        StickerPrinterGUI["PrinterTimer" AddEggIndex].value := FormatTimeFromSeconds(PrinterTimer%AddEggIndex% := changeUpDn(StickerPrinterGUI["StickerPRinterTimeUD"]))
        switchMode 0
    }
    changeUpDn(UpDn, *) {
        seconds := 5400 + UpDn.Value * 300
        StickerPrinterGUI["StickerPrinterTime"].value:= FormatTimeFromSeconds(seconds)
        return seconds
    }
    FormatTimeFromSeconds(seconds) {
        return Format("{:02}:{:02}:{:02}", Mod(seconds // 3600, 24) || 24, Mod(seconds // 60, 60), Mod(seconds, 60))
    }
    DecreaseAmount(control, *) {
        index := SubStr(control.name, -1)
        if PrinterAmount%(index)% = "infinite" {
            StickerPrinterGUI["AddButton" index].visible := StickerPrinterGUI["ItemCount" index].visible := StickerPrinterGUI["RemoveButton" index].visible := false
            StickerPrinterGUI["AddItemButton" index].visible := true
            PrinterItem%(index)% := ""
            StickerPrinterGUI["StickerPrinterEgg" index].visible := false
            StickerPrinterGUI["PrinterTimer" index].visible := false
            return
        }
        amount := GetKeyState("Control") ? PrinterAmount%(index)% : GetKeyState("Shift") ? 10 : 1
        StickerPrinterGUI["ItemCount" index].Text := "( " (PrinterAmount%(index)% := Max(PrinterAmount%(index)% -amount, 0)) " )"
        if !PrinterAmount%(index)% {
            StickerPrinterGUI["AddButton" index].visible := StickerPrinterGUI["ItemCount" index].visible := StickerPrinterGUI["RemoveButton" index].visible := false
            StickerPrinterGUI["AddItemButton" index].visible := true
            PrinterItem%(index)% := ""
            StickerPrinterGUI["StickerPrinterEgg" index].visible := false
            StickerPrinterGUI["PrinterTimer" index].visible := false
        }
    }
    AddItem(control, *) {
        AddEggIndex := SubStr(control.name, -1), printerEggIndex := 1, AddEggInfiniteCheck := false, AddEggAmount := "1"
        StickerPrinterGUI["InfiniteCheck"].value := 0
        StickerPrinterGUI["PrinterAmountEdit"].value := "1"
        StickerPrinterGUI["PrinterAmountEdit"].enabled := true
        StickerPrinterGUI["StickerPrinterEggAdd"].value := "HBITMAP:*" stickerPB["BasicEgg"]
        switchMode 1
    }
}
nm_stickerPrinterGUI()

#SingleInstance Force
#Include lib\Gdip_All.ahk

^p::{
    Gdip_SetBitmapToClipboard(Gdip_BitmapFromHWND(WinExist("A")))
}