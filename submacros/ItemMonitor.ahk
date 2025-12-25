#Requires AutoHotkey v2.0
#SingleInstance Force

#Include "%A_ScriptDir%\..\lib"
#Include "Gdip_All.ahk"
#Include "Gdip_ImageSearch.ahk"
#Include "JSON.ahk"
#Include "Roblox.ahk"
#Include "DurationFromSeconds.ahk"
#Include "nowUnix.ahk"
#Include "Auxilliary.ahk"

pToken := Gdip_Startup()
(bitmaps := Map()).CaseSense := 0
#Include "..\nm_image_assets\offset\bitmaps.ahk"
#Include "..\nm_image_assets\itemmonitor\bitmaps.ahk"

SetWorkingDir A_ScriptDir "\.."
CoordMode "Mouse", "Screen"
CoordMode "Pixel", "Screen"
SendMode "Event"

versionID := "0.1"
w := 4000, h := 1100
QueryTotal := 0
TotalItemsDetected := 0
CollectedItems := Map()
LastDetectionTime := Map()
LastDetectedValue := Map()
ItemTimeline := Map()
NatroVersionID := "1.0.1"

if (!A_Args.Length > 0)
{
    Msgbox "This script is meant to be run by Natro Macro!"
    ExitApp()
}
else
    NatroVersionID := A_Args[1]

; obtain os
os_version := "cant detect os"
for objItem in ComObjGet("winmgmts:").ExecQuery("SELECT * FROM Win32_OperatingSystem")
	os_version := Trim(StrReplace(StrReplace(StrReplace(StrReplace(objItem.Caption, "Microsoft"), "Майкрософт"), "مايكروسوفت"), "微软"))

item_map := Map( ; item rarity map (ddetermins the ordder in which theyre displayed)
    "Blue Extract", "Consumable",
    "Blueberry", "Material",
    "Sunflower Seed", "Material",
    "Strawberry", "Material",
    "Pineapple", "Material",
    "Treat", "Material",
    "Moon Charm", "Material",
    "Royal Jelly", "Consumable",
    "Magic Bean", "Consumable",
    "Soft Wax", "Consumable",
    "Enzyme", "Consumable",
    "Oil", "Consumable",
    "Glue", "Consumable",
    "Star Jelly", "Consumable",
    "Loaded Dice", "Consumable",
    "Micro-Converter", "Consumable",
    "Honeysuckle", "Material",
    "Field Dice", "Consumable",
    "Bitterberry", "Material",
    "Super Smoothie", "Consumable",
    "Uwuru", "God",
    "Ticket", "Currency",
    "Honey", "Currency"
)

; Background card thingies
const_regions := Map(
    "ItemMonitor", {x: 3000, y: 600, h: 450, w: 950, title: "ItemMonitor v" versionID}
    , "This Hour", {x: 3000, y: 50, h: 500, w: 950, title: "This Hour"}
    , "Items Gained", {x: 50, y: 50, h: 1000, w: 2900, title: "Items Gained"}
)

graph_regions := Map("Timeline", {x: 150, y: 890, w: 2770, h: 120}) ; i might add smore stuff later so we'll leave this as a map

; Template Creation
; - Draw cards
; - Draw graph regions
; - Leave as pBM (Will be cloned to draw graphs)

pBM := Gdip_CreateBitmap(w, h)
G := Gdip_GraphicsFromImage(pBM)
Gdip_GraphicsClear(G, 0xff121212)
Gdip_SetSmoothingMode(G, 4)
Gdip_SetInterpolationMode(G, 7)
pBrush := Gdip_BrushCreateSolid(0xff121212), Gdip_FillRoundedRectangle(G, pBrush, -1, -1, w+1, h+1, 60), Gdip_DeleteBrush(pBrush)

for k, v in const_regions
{
    pPen := Gdip_CreatePen(0xff282628, 5),Gdip_DrawRoundedRectangle(G, pPen, v.x, v.y, v.w, v.h, 20), Gdip_DeletePen(pPen)
    pBrush := Gdip_BrushCreateSolid(0xff201e20), Gdip_FillRoundedRectangle(G, pBrush, v.x, v.y, v.w, v.h, 20), Gdip_DeleteBrush(pBrush)
    pBrush := Gdip_BrushCreateSolid(0xffffffff), Gdip_TextToGraphics(G, v.title, "s40 Bold cffffffff x" v.x " y" (v.y + 5) " w" v.w " Center", "Segoe UI", , ), Gdip_DeleteBrush(pBrush)
}

for k, v in graph_regions
{
    pBrush := Gdip_BrushCreateSolid(0x20201e20), Gdip_FillRoundedRectangle(G, pBrush, v.x, v.y, v.w, v.h, 20), Gdip_DeleteBrush(pBrush)
    pPen := Gdip_CreatePen(0x40c0c0f0, 5), Gdip_DrawRoundedRectangle(G, pPen, v.x, v.y, v.w, v.h, 20), Gdip_DeletePen(pPen)
    pPen := Gdip_CreatePen(0x40c0c0f0, 2)
    Gdip_DeletePen(pPen)
}

SendItemReport()
{
    global pBM, G, versionID, const_regions, graph_regions, Graphing, NatroVersionID
    global CollectedItems, QueryTotal, TotalItemsDetected, StartTime, os_version, w, h
    global ItemTimeline, item_map
    
    pBMReport := Gdip_CloneBitmap(pBM)
    GReport := Gdip_GraphicsFromImage(pBMReport)
    Gdip_SetSmoothingMode(GReport, 4)
    Gdip_SetInterpolationMode(GReport, 7)

    ; [1] Timeline 

    region := graph_regions["Timeline"]
    maxValue := 0
    maxTimelineValue := 0
    
    pPen := Gdip_CreatePen(0x40c0c0f0, 2)
    Loop 61
    {
        i := A_Index - 1
        x := region.x + (region.w * i / 60)
        
        if (Mod(i, 10) = 0)
        {
            Gdip_DrawLine(GReport, pPen, x, region.y, x, region.y + region.h)
            Gdip_DrawLine(GReport, pPen, x, region.y + region.h, x, region.y + region.h + 45)
            timeText := FormatTime(DateAdd(A_Now, (i - 60) * 60, "Seconds"), "HH:mm")
            Gdip_TextToGraphics(GReport, timeText, "s20 Center Bold cffFFFFFF x" (x - 40) " y" (region.y + region.h + 50) " w80", "Segoe UI")
        }
        else
            Gdip_DrawLine(GReport, pPen, x, region.y + region.h, x, region.y + region.h + 25)
    }
    
    Gdip_DrawLine(GReport, pPen, region.x, region.y + region.h / 2, region.x + region.w, region.y + region.h / 2)
    Gdip_DeletePen(pPen)
    
    if (CollectedItems.Count > 0)
    {
        filteredItems := Map()
        for itemName, quantity in CollectedItems
        {
            if (itemName != "Honey" && itemName != "Treat")
                filteredItems[itemName] := quantity
        }
        
        maxValue := filteredItems.Count > 0 ? maxX(filteredItems) : 0
        
        pPen := Gdip_CreatePen(0x40c0c0f0, 2)
        Gdip_TextToGraphics(GReport, FormatNumber(maxValue), "s18 Right Bold cffFFFFFF x" (region.x - 105) " y" (region.y - 10) " w90", "Segoe UI")
        Gdip_TextToGraphics(GReport, FormatNumber(maxValue // 2), "s18 Right Bold cffFFFFFF x" (region.x - 105) " y" (region.y + region.h / 2 - 10) " w90", "Segoe UI")
        Gdip_TextToGraphics(GReport, "0", "s18 Right Bold cffFFFFFF x" (region.x - 70) " y" (region.y + region.h - 10) " w60", "Segoe UI")
        Gdip_DeletePen(pPen)
    }
    
    maxTimelineValue := ItemTimeline.Count > 0 ? maxX(ItemTimeline) : 0
    
    if (maxTimelineValue > 0)
    {
        barWidth := region.w / 60
        Loop 60
        {
            minute := A_Index - 1
            count := ItemTimeline.Has(minute) ? ItemTimeline[minute] : 0
            
            if (count > 0)
            {
                x := region.x + (barWidth * minute)
                barHeight := (region.h * count / maxTimelineValue)
                y := region.y + region.h - barHeight
                
                pBrush := Gdip_BrushCreateSolid(0xFF00FF00)
                Gdip_FillRectangle(GReport, pBrush, x + 2, y, barWidth - 4, barHeight)
                Gdip_DeleteBrush(pBrush)
                
                pPen := Gdip_CreatePen(0xFF00AA00, 1)
                Gdip_DrawRectangle(GReport, pPen, x + 2, y, barWidth - 4, barHeight)
                Gdip_DeletePen(pPen)
            }
        }
    }

    ;[2] Last hour
    
    region := const_regions["This Hour"]
    pBrush := Gdip_BrushCreateSolid(0xff201e20)
    Gdip_FillRoundedRectangle(GReport, pBrush, region.x + 5, region.y + 60, region.w - 10, region.h - 65, 15)
    Gdip_DeleteBrush(pBrush)
    
    if (CollectedItems.Count > 0)
    {
        sortedItems := []
        for itemName, quantity in CollectedItems
        {
            if (itemName != "Honey" && itemName != "Treat")
                sortedItems.Push({name: itemName, qty: quantity})
        }
        QuickSort(sortedItems, "qty")
        
        colors := Map(1, 0xFFFFD700, 2, 0xFFC0C0C0, 3, 0xFFCD7F32)
        cardWidth := 280
        cardHeight := 360
        spacing := 20
        totalWidth := (cardWidth * 3) + (spacing * 2)
        startX := region.x + (region.w - totalWidth) / 2
        startY := region.y + 80
        order := [1, 2, 3]
        
        Loop Min(3, sortedItems.Length)
        {
            rank := A_Index
            displayPos := order[rank]
            item := sortedItems[rank]
            cardX := startX + (displayPos - 1) * (cardWidth + spacing)
            
            pBrush := Gdip_BrushCreateSolid(0xff2a2a2a)
            Gdip_FillRoundedRectangle(GReport, pBrush, cardX, startY, cardWidth, cardHeight, 15)
            Gdip_DeleteBrush(pBrush)
            
            pPen := Gdip_CreatePen(colors[rank], 3)
            Gdip_DrawRoundedRectangle(GReport, pPen, cardX, startY, cardWidth, cardHeight, 15)
            Gdip_DeletePen(pPen)
            
            iconSize := 100
            iconX := cardX + (cardWidth - iconSize) / 2
            iconY := startY + 40
            itemImage := Graphing.Has("pBM" item.name) ? Graphing["pBM" item.name] : Graphing["pBMNoImage"]
            Gdip_DrawImage(GReport, itemImage, iconX, iconY, iconSize, iconSize)
            
            nameSize := 26
            nameMaxWidth := cardWidth - 20
            Loop
            {
                pos := Gdip_TextToGraphics(GReport, item.name, "s" nameSize " Bold c00ffffff x0 y0", "Segoe UI")
                textWidth := SubStr(pos, InStr(pos, "|", , , 2)+1, InStr(pos, "|", , , 3)-InStr(pos, "|", , , 2)-1)
                if (textWidth <= nameMaxWidth || nameSize <= 14)
                    break
                nameSize -= 2
            }
            
            Gdip_TextToGraphics(GReport, item.name, "s" nameSize " Center Bold cffFFFFFF x" cardX " y" (startY + 150) " w" cardWidth, "Segoe UI")
            Gdip_TextToGraphics(GReport, "+" FormatNumber(item.qty), "s32 Center Bold cff00ff00 x" cardX " y" (startY + 190) " w" cardWidth, "Segoe UI")
            Gdip_TextToGraphics(GReport, "#" rank, "s60 Center Bold cff" SubStr(Format("{:08X}", colors[rank]), 3) " x" cardX " y" (startY + 240) " w" cardWidth, "Segoe UI")
        }
    }

    ; [3] ItemMonitor
    
    region := const_regions["ItemMonitor"]
    pBrush := Gdip_BrushCreateSolid(0xff201e20)
    Gdip_FillRoundedRectangle(GReport, pBrush, region.x + 5, region.y + 60, region.w - 10, region.h - 65, 15)
    Gdip_DeleteBrush(pBrush)
    
    lineHeight := 50
    startY := region.y + 70
    uptimeSeconds := DateDiff(A_Now, StartTime, "Seconds")
    uptimeStr := Format("{:02}:{:02}:{:02}", uptimeSeconds // 3600, Mod(uptimeSeconds // 60, 60), Mod(uptimeSeconds, 60))
    eggData := (Random(1, 1000) = 1) ? EasterEgg() : ""
    
    yPos := startY
    pos := Gdip_TextToGraphics(GReport, "By prodbyichigo & Myurius", "s32 Bold c00ffffff x0 y0", "Segoe UI")
    totalWidth := SubStr(pos, InStr(pos, "|", , , 2)+1, InStr(pos, "|", , , 3)-InStr(pos, "|", , , 2)-1)
    startX := region.x + (region.w - totalWidth) / 2
    
    pos := Gdip_TextToGraphics(GReport, "By ", "s32 Left Bold cffC0C0C0 x" startX " y" yPos, "Segoe UI")
    currentX := SubStr(pos, 1, InStr(pos, "|", , , 1)-1) + SubStr(pos, InStr(pos, "|", , , 2)+1, InStr(pos, "|", , , 3)-InStr(pos, "|", , , 2)-1)
    
    pos := Gdip_TextToGraphics(GReport, "prodbyichigo ", "s32 Bold c00ffffff x0 y0", "Segoe UI")
    ichigoWidth := SubStr(pos, InStr(pos, "|", , , 2)+1, InStr(pos, "|", , , 3)-InStr(pos, "|", , , 2)-1)
    pBrush := Gdip_CreateLinearGrBrushFromRect(currentX, yPos, ichigoWidth, 32, 0x00000000, 0x00000000, 0)
    Gdip_SetLinearGrBrushPresetBlend(pBrush, [0.0, 1], [0xff0080FF, 0xffFF0000])
    pPen := Gdip_CreatePenFromBrush(pBrush, 1)
    Gdip_DrawOrientedString(GReport, "prodbyichigo ", "Segoe UI", 32, 1, currentX, yPos, ichigoWidth, 32, 0, pBrush, pPen)
    Gdip_DeletePen(pPen)
    Gdip_DeleteBrush(pBrush)
    currentX += ichigoWidth
    
    Gdip_TextToGraphics(GReport, "&", "s32 Left Bold cffC0C0C0 x" currentX " y" yPos, "Segoe UI")
    pos := Gdip_TextToGraphics(GReport, " & ", "s32 Bold c00ffffff x0 y0", "Segoe UI")
    ampWidth := SubStr(pos, InStr(pos, "|", , , 2)+1, InStr(pos, "|", , , 3)-InStr(pos, "|", , , 2)-1)
    currentX += ampWidth
    
    Gdip_TextToGraphics(GReport, "Myurius", "s32 Left Bold cff9900ff x" currentX - 8 " y" yPos, "Segoe UI")
    
    yPos += lineHeight
    queriesPerSec := (uptimeSeconds > 0) ? Format("{:.2f}", QueryTotal / uptimeSeconds) : "0"
    imageSizeText := eggData ? eggData.text : ("Image Size: " w "x" h)
    lines := [
        "Total Items Detected: " TotalItemsDetected,
        "Queries Per Sec: " queriesPerSec,
        "Uptime: " uptimeStr,
        os_version,
        imageSizeText
    ]
    
    Loop lines.Length
    {
        i := A_Index
        t := lines[i]
        
        if (i = 5 && eggData)
        {
            fontSize := 32
            maxWidth := region.w - 40
            Loop
            {
                pos := Gdip_TextToGraphics(GReport, t, "s" fontSize " Center Bold c00ffffff x0 y0", "Segoe UI")
                textWidth := SubStr(pos, InStr(pos, "|", , , 2)+1, InStr(pos, "|", , , 3)-InStr(pos, "|", , , 2)-1)
                if (textWidth <= maxWidth || fontSize <= 16)
                    break
                fontSize -= 2
            }
            
            textX := region.x + (region.w - textWidth) / 2
            pBrush := Gdip_CreateLinearGrBrushFromRect(textX, yPos + (i - 1) * lineHeight, textWidth, fontSize, 0x00000000, 0x00000000, 0)
            Gdip_SetLinearGrBrushPresetBlend(pBrush, [0.0, 1], eggData.colors)
            pPen := Gdip_CreatePenFromBrush(pBrush, 1)
            Gdip_DrawOrientedString(GReport, t, "Segoe UI", fontSize, 1, textX, yPos + (i - 1) * lineHeight, textWidth, fontSize, 0, pBrush, pPen)
            Gdip_DeletePen(pPen)
            Gdip_DeleteBrush(pBrush)
        }
        else
        {
            colorCode := (i = 4) ? "cff00d4ff" : "cffC0C0C0"
            Gdip_TextToGraphics(GReport, t, "s32 Center Bold " colorCode " x" (region.x + 20) " y" (yPos + (i - 1) * lineHeight) " w" (region.w - 40), "Segoe UI")
        }
    }
    
    logoY := yPos + (lines.Length * lineHeight)
    logoSize := 40
    gap := 1
    
    pos := Gdip_TextToGraphics(GReport, "discord.gg/natromacro", "s32 Bold c00ffffff x0 y0", "Segoe UI")
    linkWidth := SubStr(pos, InStr(pos, "|", , , 2)+1, InStr(pos, "|", , , 3)-InStr(pos, "|", , , 2)-1)
    
    pos := Gdip_TextToGraphics(GReport, "Natro v" NatroVersionID, "s32 Bold c00ffffff x0 y0", "Segoe UI")
    verWidth := SubStr(pos, InStr(pos, "|", , , 2)+1, InStr(pos, "|", , , 3)-InStr(pos, "|", , , 2)-1)
    
    totalWidth := linkWidth + gap + logoSize + gap + verWidth
    startX := region.x + (region.w - totalWidth) / 2
    
    Gdip_TextToGraphics(GReport, "discord.gg/natromacro", "s32 Left Bold Underline cff3366cc x" startX " y" (logoY + (logoSize-32)/2), "Segoe UI")
    Gdip_DrawImage(GReport, Graphing["pBMNatroLogo"], startX + linkWidth + gap, logoY + 5, logoSize, logoSize)
    Gdip_TextToGraphics(GReport, "Natro v" NatroVersionID, "s32 Left Bold cffb47bd1 x" (startX + linkWidth + gap + logoSize + gap) " y" (logoY + (logoSize-32)/2), "Segoe UI")

    ; [4] Items Gained
    
    region := const_regions["Items Gained"]
    cardWidth := 200
    cardHeight := 220
    cardPadding := 30
    cardsPerRow := Floor((region.w - cardPadding * 2) / (cardWidth + cardPadding))
    cardStartX := region.x + cardPadding
    cardStartY := region.y + 80
    col := 0
    row := 0
    
    groupedItems := Map("Currency", [], "Material", [], "Consumable", [])
    for itemName, quantity in CollectedItems
    {
        category := item_map.Has(itemName) ? item_map[itemName] : "Material"
        groupedItems[category].Push({name: itemName, qty: quantity})
    }
    
    for category, items in groupedItems
        QuickSort(items, "qty")
    
    sortedItems := []
    for category in ["Currency", "Material", "Consumable"]
    {
        for item in groupedItems[category]
            sortedItems.Push(item)
    }
    
    for item in sortedItems
    {
        cardX := cardStartX + col * (cardWidth + cardPadding)
        cardY := cardStartY + row * (cardHeight + cardPadding)
        
        pPen := Gdip_CreatePen(0xff282628, 3)
        Gdip_DrawRoundedRectangle(GReport, pPen, cardX, cardY, cardWidth, cardHeight, 15)
        Gdip_DeletePen(pPen)
        
        pBrush := Gdip_BrushCreateSolid(0xff323232)
        Gdip_FillRoundedRectangle(GReport, pBrush, cardX, cardY, cardWidth, cardHeight, 15)
        Gdip_DeleteBrush(pBrush)
        
        imageSize := 100
        imageX := cardX + (cardWidth - imageSize) / 2
        imageY := cardY + 50
        itemImage := Graphing.Has("pBM" item.name) ? Graphing["pBM" item.name] : Graphing["pBMNoImage"]
        Gdip_DrawImage(GReport, itemImage, imageX, imageY, imageSize, imageSize)
        
        nameSize := 24
        nameMaxWidth := cardWidth - 20
        Loop
        {
            pos := Gdip_TextToGraphics(GReport, item.name, "s" nameSize " Bold c00ffffff x0 y0", "Segoe UI")
            textWidth := SubStr(pos, InStr(pos, "|", , , 2)+1, InStr(pos, "|", , , 3)-InStr(pos, "|", , , 2)-1)
            if (textWidth <= nameMaxWidth || nameSize <= 12)
                break
            nameSize -= 2
        }
        
        Gdip_TextToGraphics(GReport, item.name, "s" nameSize " Bold cffC0C0C0 x" cardX " y" (cardY + 10) " w" cardWidth " Center", "Segoe UI")
        Gdip_TextToGraphics(GReport, "+" FormatNumber(item.qty), "s32 Bold cff36cb36 x" cardX " y" (cardY + 150) " w" cardWidth " Center", "Segoe UI")
        
        col++
        if (col >= cardsPerRow)
        {
            col := 0
            row++
        }
    }

    ; [5] Discord
    
	webhook := IniRead("settings\nm_config.ini", "Status", "webhook")
	bottoken := IniRead("settings\nm_config.ini", "Status", "bottoken")
	discordMode := IniRead("settings\nm_config.ini", "Status", "discordMode")
	ReportChannelID := IniRead("settings\nm_config.ini", "Status", "ReportChannelID")
	if (StrLen(ReportChannelID) < 17)
		ReportChannelID := IniRead("settings\nm_config.ini", "Status", "MainChannelID")

	try
	{
		chars := "0|1|2|3|4|5|6|7|8|9|a|b|c|d|e|f|g|h|i|j|k|l|m|n|o|p|q|r|s|t|u|v|w|x|y|z"
		chars := Sort(chars, "D| Random")
		boundary := SubStr(StrReplace(chars, "|"), 1, 12)
		hData := DllCall("GlobalAlloc", "UInt", 0x2, "UPtr", 0, "Ptr")
		DllCall("ole32\CreateStreamOnHGlobal", "Ptr", hData, "Int", 0, "PtrP", &pStream:=0, "UInt")

		str :=
		(
		'
		------------------------------' boundary '
		Content-Disposition: form-data; name="payload_json"
		Content-Type: application/json

		{
			"embeds": [{
				"title": "**[' A_Hour ':' A_Min ':00] Hourly Report**",
				"color": "14052794",
				"image": {"url": "attachment://file.png"}
			}]
		}
		------------------------------' boundary '
		Content-Disposition: form-data; name="files[0]"; filename="file.png"
		Content-Type: image/png

		'
		)

		utf8 := Buffer(length := StrPut(str, "UTF-8") - 1), StrPut(str, utf8, length, "UTF-8")
		DllCall("shlwapi\IStream_Write", "Ptr", pStream, "Ptr", utf8.Ptr, "UInt", length, "UInt")

		pFileStream := Gdip_SaveBitmapToStream(pBMReport)
		DllCall("shlwapi\IStream_Size", "Ptr", pFileStream, "UInt64P", &size:=0, "UInt")
		DllCall("shlwapi\IStream_Reset", "Ptr", pFileStream, "UInt")
		DllCall("shlwapi\IStream_Copy", "Ptr", pFileStream, "Ptr", pStream, "UInt", size, "UInt")
		ObjRelease(pFileStream)

		str :=
		(
		'

		------------------------------' boundary '--
		'
		)

		utf8 := Buffer(length := StrPut(str, "UTF-8") - 1), StrPut(str, utf8, length, "UTF-8")
		DllCall("shlwapi\IStream_Write", "Ptr", pStream, "Ptr", utf8.Ptr, "UInt", length, "UInt")
		ObjRelease(pStream)

		pData := DllCall("GlobalLock", "Ptr", hData, "Ptr")
		size := DllCall("GlobalSize", "Ptr", pData, "UPtr")

		retData := ComObjArray(0x11, size)
		pvData := NumGet(ComObjValue(retData), 8 + A_PtrSize, "Ptr")
		DllCall("RtlMoveMemory", "Ptr", pvData, "Ptr", pData, "Ptr", size)

		DllCall("GlobalUnlock", "Ptr", hData)
		DllCall("GlobalFree", "Ptr", hData, "Ptr")
		contentType := "multipart/form-data; boundary=----------------------------" boundary

		wr := ComObject("WinHttp.WinHttpRequest.5.1")
		wr.Option[9] := 2720
		wr.Open("POST", (discordMode = 0) ? webhook : ("https://discord.com/api/v10/channels/" ReportChannelID "/messages"), 0)
		if (discordMode = 1)
		{
			wr.SetRequestHeader("User-Agent", "DiscordBot (AHK, " A_AhkVersion ")")
			wr.SetRequestHeader("Authorization", "Bot " bottoken)
		}
		wr.SetRequestHeader("Content-Type", contentType)
		wr.SetTimeouts(0, 60000, 120000, 30000)
		wr.Send(retData)
	}
    catch as e
    {
        message := "**[" A_Hour ":" A_Min ":" A_Sec "]**`n"
        . "**Failed to send Item Report!**`n"
        . "Exception Properties:`n"
        . ">>> What: " e.what "`n"
        . "File: " e.file "`n"
        . "Line: " e.line "`n"
        . "Message: " e.message "`n"
        . "Extra: " e.extra
        message := StrReplace(StrReplace(message, "\", "\\"), "`n", "\n")
        
        postdata := '
        (
        {
            "embeds": [{
                "description": "' message '",
                "color": "15085139"
            }]
        }
        )'
    }
    
    Gdip_DeleteGraphics(GReport)
    Gdip_DisposeImage(pBMReport)
}
DetectItems()
{
    global CollectedItems, Stream, Enumeration, LastDetectionTime, LastDetectedValue, QueryTotal, ItemTimeline, StartTime
    static QuickDetectionWindow := 6000 ; incase this needs to be changed later or something, itll remain a variable

    pBMHaystack := IsolateHaystack(CreateHaystack()), QueryTotal++, x := ""

    for k, v in Stream["Items"]
    {
        if Gdip_ImageSearch(pBMHaystack, Stream["Items"][k])
        {
            x := k
            break
        }
    }
    if (!x || !(pBMDigits := IsolateDigits(pBMHaystack, Stream["Items"][x])))
        return Gdip_DisposeImage(pBMHaystack)
    n := DetectDigits(pBMDigits), Gdip_DisposeImage(pBMDigits), Gdip_DisposeImage(pBMHaystack), currentTime := A_TickCount
    amount := (LastDetectionTime.Has(x) && (currentTime - LastDetectionTime[x] < QuickDetectionWindow)) ? Max(0, n - LastDetectedValue[x]) : n
    if (amount > 0)
        CollectedItems[x] := (CollectedItems.Has(x) ? CollectedItems[x] : 0) + amount, minuteSlot := DateDiff(A_Now, StartTime, "Seconds") // 60, ItemTimeline[minuteSlot] := (ItemTimeline.Has(minuteSlot) ? ItemTimeline[minuteSlot] : 0) + amount
    LastDetectionTime[x] := currentTime, LastDetectedValue[x] := n
}

CreateHaystack()
{
    global windowX, windowWidth, windowY, windowHeight
    GetRobloxClientPos()
    
    chdc := CreateCompatibleDC(), hbm := CreateDIBSection(349, 49, chdc), obm := SelectObject(chdc, hbm), hhdc := GetDC()
    BitBlt(chdc, 0, 0, 349, 49, hhdc, windowX + windowWidth - 349, windowY + windowHeight - 49), ReleaseDC(hhdc)
    pBitmap := Gdip_CreateBitmapFromHBITMAP(hbm), SelectObject(chdc, obm)
    DeleteObject(hbm), DeleteDC(hhdc), DeleteDC(chdc)
    
    return pBitmap
}

IsolateHaystack(pBMHaystack)
{
    global Stream
    if (!Gdip_ImageSearch(pBMHaystack, Stream["ItemBanner"]))
        return pBMHaystack
    Gdip_ImageSearch(pBMHaystack, Stream["ItemBanner"], &Output, , , , , , , 2), Gdip_ImageSearch(pBMHaystack, Stream["ItemBanner"], &Output2, , , , , , , 4), CoordDelim := StrSplit(Output, ','), CoordDelim2 := StrSplit(Output2, ',')
    return Gdip_CloneBitmapArea(pBMHaystack, CoordDelim[1], CoordDelim2[2], CoordDelim2[1] - CoordDelim[1], CoordDelim[2] - CoordDelim2[2])
}

IsolateDigits(pBMHaystack, pBitmapMatch)
{
    global Enumeration
    
    plusPos := ""
    itemPos := ""
    
    if (!Gdip_ImageSearch(pBMHaystack, Enumeration["+"], &plusPos, , , , , , , 6) || !plusPos)
        return 0
    
    if (!Gdip_ImageSearch(pBMHaystack, pBitmapMatch, &itemPos) || !itemPos)
        return 0
    
    plusCoords := StrSplit(plusPos, ",")
    itemCoords := StrSplit(itemPos, ",")
    
    if (plusCoords.Length < 2 || itemCoords.Length < 2)
        return 0
    
    Gdip_GetImageDimensions(Enumeration["+"], &plusW, &plusH)
    Gdip_GetImageDimensions(pBMHaystack, &w, &h)
    
    digitX := Integer(plusCoords[1]) + plusW
    digitWidth := Integer(itemCoords[1]) - digitX
    
    if (digitWidth <= 0 || digitX < 0 || digitX >= w)
        return 0
    
    return Gdip_CloneBitmapArea(pBMHaystack, digitX, 0, digitWidth, h)
}

DetectDigits(pBMHaystackIsolated)
{
    global Enumeration
    
    Gdip_GetImageDimensions(pBMHaystackIsolated, &w, &h)
    
    (digits := Map()).Default := ""
    
    loop 10
    {
        n := 10 - A_Index
        if ((n = 1) || (n = 3))
            continue
        
        Gdip_ImageSearch(pBMHaystackIsolated, Enumeration["Digits"][n], &list := "", 0, 0, w, h, 1, , 6, 5, , "`n")
        Loop Parse list, "`n"
            if (A_Index & 1)
                digits[Integer(A_LoopField)] := n
    }

    for n in [1, 3]
    {
        Gdip_ImageSearch(pBMHaystackIsolated, Enumeration["Digits"][n], &list := "", 0, 0, w, h, 1, , 6, 5, , "`n")
        loop Parse list, "`n"
        {
            if (A_Index & 1)
            {
                x := Integer(A_LoopField)
                if (((n = 1) && (digits[x - 5] = 4)) || ((n = 3) && (digits[x - 1] = 8)))
                    continue
                digits[x] := n
            }
        }
    }

    num := ""
    for x, y in digits
        num .= y
    
    return num ? Integer(num) : 0
}

EasterEgg()
{
    e := Map("RIP SDo6+", 6, "Send concrete proof!",1,"Why am I making so little?",1,"Natro so broke :weary:",2,"uwuru was here",3,"Will money_mountain EVER get admin?",4,"Move in silence... Only speak when it is time to say checkmate.",4,"777,777!",4,"There is a 0.000000001% chance you'll see this message",6,"discord.gg/natromacro -> 1258920032218644580",5,"BRING BACK CHASE!",5,"tophal you ARE moderation",5,"I gave the owner a handshake.",5,"iDTuezQ (/): no appeal - Permanent",6,"Mod abuse? Who are you gonna tell? The mods?",6,"Lost my 118 day wordle streak I hope all of you lose it too",6,"I'm secretly gay but nobody will see this",5,"your free trial of natro macro has expired...",1,"men ruin everything /j",2,"You were banned from Natro Macro. Reason: ````````",3,"Give me ur email",2,"I'll overthrow whoever #1 is at right now.",3,'"one thing was untrue, just one"',4,"SP The Wizard...",5,"rahh 10t a day mixed hive",5,"anyone else love pumpkin pie",5,"what if instead of admin-chat it was freaky-chat",6,"probs get petal wand then tbh",4,"ME FLEXING MY TOP 1 WEEKLY LB SPOT",4,"OMG NATRO SHIRT ARRIVED",6,"GETRICH12345",6,"my macro walks but doesn't talk",3,"Is Natro Macro 13+?",3,"nature macro...",5,"jmao",5)
    c := Map(1,[0xffffffff,0xffA0A0A8],2,[0xff5CDB5C,0xff3B873B],3,[0xff4A9EFF,0xff2B5F99],4,[0xffB24BFF,0xff6B2D99],5,[0xffFFD700,0xffFF8C00],6,[0xffFF1493,0xff8B008B])
    r := Map(1,100,2,50,3,25,4,10,5,8,6,3), t := 0
    for m, x in e
        t += r[x]
    v := Random(1, t), w := 0
    for m, x in e
        if v <= w += r[x]
            return {text: m, colors: c[x]}
}

; ▰▰▰▰▰
; MAIN LOOP
; ▰▰▰▰▰
; startup finished, set start time
StartTime := A_Now

; set emergency switches in case of time error
last_report := time := 0
time_value := 0

; indefinite loop of detection and reporting
loop
{
	DetectItems()

	; check time for hourly report
	DllCall("GetSystemTimeAsFileTime", "int64p", &time)
	time_value := (60*A_Min+A_Sec)

	; send report every hour
	if ((time_value = 0) || (last_report && time > last_report + 35980000000))
	{
		SendItemReport()
		CollectedItems.Clear()
		ItemTimeline.Clear()
		DllCall("GetSystemTimeAsFileTime", "int64p", &time)
		last_report := time
	}
}
