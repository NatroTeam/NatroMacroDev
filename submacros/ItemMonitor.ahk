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
; #Include "Discord.ahk"

(bitmaps := Map()).CaseSense := 0
pToken := Gdip_Startup()
#Include "..\nm_image_assets\offset\bitmaps.ahk"
#Include "..\nm_image_assets\itemmonitor\bitmaps.ahk"

SetWorkingDir A_ScriptDir "\.."
CoordMode "Mouse", "Screen"
CoordMode "Pixel", "Screen"
SendMode "Event"

NatroVersionID := "0.0.1", versionID := "0.1-T"
w := 4000, h := 1100
Query_Total := 0, TotalItemsDetected := 0, ReportInterval := 3600000
CollectedItems := Map(), LastDetectionTime := Map(), LastDetectedValue := Map(), ItemTimeline := Map()
StartTime := A_Now, LastReportTime := A_TickCount

; obtain os
os_version := "cant detect os"
for objItem in ComObjGet("winmgmts:").ExecQuery("SELECT * FROM Win32_OperatingSystem")
	os_version := Trim(StrReplace(StrReplace(StrReplace(StrReplace(objItem.Caption, "Microsoft"), "Майкрософт"), "مايكروسوفت"), "微软"))

const_regions := Map("ItemMonitor", {x: 3000, y: 600, h: 450, w: 950, title: "ItemMonitor v" versionID}, "This Hour", {x: 3000, y: 50, h: 500, w: 950, title: "This Hour"}, "Items Gained", {x: 50, y: 50, h: 1000, w: 2900, title: "Items Gained"})
graph_regions := Map("Timeline", {x: 150, y: 890, w: 2770, h: 120})

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
    global pBM, G, versionID, const_regions, graph_regions, Graphing, NatroVersionID, CollectedItems, Query_Total, TotalItemsDetected, StartTime, os_version, w, h, ItemTimeline
    pBMReport := Gdip_CloneBitmapArea(pBM, 0, 0, w, h), GReport := Gdip_GraphicsFromImage(pBMReport), Gdip_SetSmoothingMode(GReport, 4), Gdip_SetInterpolationMode(GReport, 7)
    region := graph_regions["Timeline"], maxValue := 0, maxTimelineValue := 0

    pPen := Gdip_CreatePen(0x40c0c0f0, 2)
    Loop 61
        i := A_Index - 1, x := region.x + (region.w * i / 60), (Mod(i, 10) = 0) ? (Gdip_DrawLine(GReport, pPen, x, region.y, x, region.y + region.h), Gdip_DrawLine(GReport, pPen, x, region.y + region.h, x, region.y + region.h + 45), Gdip_TextToGraphics(GReport, FormatTime(DateAdd(A_Now, (i - 60) * 60, "Seconds"), "HH:mm"), "s20 Center Bold cffFFFFFF x" (x - 40) " y" (region.y + region.h + 50) " w80", "Segoe UI")) : Gdip_DrawLine(GReport, pPen, x, region.y + region.h, x, region.y + region.h + 25)
    Gdip_DrawLine(GReport, pPen, region.x, region.y + region.h / 2, region.x + region.w, region.y + region.h / 2), Gdip_DeletePen(pPen)

    if (CollectedItems.Count > 0)
    {
        filteredItems := Map()
        for itemName, quantity in CollectedItems
            if (itemName != "Honey" && itemName != "Treat")
                filteredItems[itemName] := quantity
        maxValue := filteredItems.Count > 0 ? maxX(filteredItems) : 0
        
        pPen := Gdip_CreatePen(0x40c0c0f0, 2)
        Gdip_TextToGraphics(GReport, FormatNumber(maxValue), "s18 Right Bold cffFFFFFF x" (region.x - 105) " y" (region.y - 10) " w90", "Segoe UI")
        Gdip_TextToGraphics(GReport, FormatNumber(maxValue // 2), "s18 Right Bold cffFFFFFF x" (region.x - 105) " y" (region.y + region.h / 2 - 10) " w90", "Segoe UI")
        Gdip_TextToGraphics(GReport, "0", "s18 Right Bold cffFFFFFF x" (region.x - 70) " y" (region.y + region.h - 10) " w60", "Segoe UI"), Gdip_DeletePen(pPen)
    }

    maxTimelineValue := ItemTimeline.Count > 0 ? maxX(ItemTimeline) : 0

    if (maxTimelineValue > 0)
    {
        barWidth := region.w / 60
        Loop 60
        {
            minute := A_Index - 1, count := ItemTimeline.Has(minute) ? ItemTimeline[minute] : 0
            if count > 0
                x := region.x + (barWidth * minute), barHeight := (region.h * count / maxTimelineValue), y := region.y + region.h - barHeight, pBrush := Gdip_BrushCreateSolid(0xFF00FF00), Gdip_FillRectangle(GReport, pBrush, x + 2, y, barWidth - 4, barHeight), Gdip_DeleteBrush(pBrush), pPen := Gdip_CreatePen(0xFF00AA00, 1), Gdip_DrawRectangle(GReport, pPen, x + 2, y, barWidth - 4, barHeight), Gdip_DeletePen(pPen)
        }
    }

    region := const_regions["This Hour"], pBrush := Gdip_BrushCreateSolid(0xff201e20), Gdip_FillRoundedRectangle(GReport, pBrush, region.x + 5, region.y + 60, region.w - 10, region.h - 65, 15), Gdip_DeleteBrush(pBrush)

    if (CollectedItems.Count > 0)
    {
        sortedItems := []
        for itemName, quantity in CollectedItems
        {
            if (itemName != "Honey" && itemName != "Treat")
                sortedItems.Push({name: itemName, qty: quantity})
        }
        QuickSort(sortedItems, "qty")

        colors := Map(1, 0xFFFFD700, 2, 0xFFC0C0C0, 3, 0xFFCD7F32), cardWidth := 280, cardHeight := 360, spacing := 20, totalWidth := (cardWidth * 3) + (spacing * 2), startX := region.x + (region.w - totalWidth) / 2, startY := region.y + 80
        order := [2, 1, 3]

        Loop Min(3, sortedItems.Length)
        {
            rank := A_Index, displayPos := order[rank], item := sortedItems[rank], cardX := startX + (displayPos - 1) * (cardWidth + spacing)
            pBrush := Gdip_BrushCreateSolid(0xff2a2a2a), Gdip_FillRoundedRectangle(GReport, pBrush, cardX, startY, cardWidth, cardHeight, 15), Gdip_DeleteBrush(pBrush)
            pPen := Gdip_CreatePen(colors[rank], 3), Gdip_DrawRoundedRectangle(GReport, pPen, cardX, startY, cardWidth, cardHeight, 15), Gdip_DeletePen(pPen)
            iconSize := 100, iconX := cardX + (cardWidth - iconSize) / 2, iconY := startY + 40
            Gdip_DrawImage(GReport, Graphing.Has("pBM" item.name) ? Graphing["pBM" item.name] : Graphing["pBMNoImage"], iconX, iconY, iconSize, iconSize)
            
            nameSize := 26, nameMaxWidth := cardWidth - 20
            Loop {
                pos := Gdip_TextToGraphics(GReport, item.name, "s" nameSize " Bold c00ffffff x0 y0", "Segoe UI")
                textWidth := SubStr(pos, InStr(pos, "|", , , 2)+1, InStr(pos, "|", , , 3)-InStr(pos, "|", , , 2)-1)
                if (textWidth <= nameMaxWidth || nameSize <= 14)
                    break
                nameSize -= 2
            }
            Gdip_TextToGraphics(GReport, item.name, "s" nameSize " Center Bold cffFFFFFF x" cardX " y" (startY + 150) " w" cardWidth, "Segoe UI")
            Gdip_TextToGraphics(GReport, "+" FormatNumber(item.qty), "s32 Center Bold cff00ff00 x" cardX " y" (startY + 190) " w" cardWidth, "Segoe UI")
            Gdip_TextToGraphics(GReport, "#" rank, "s64 Center Bold cff" SubStr(Format("{:08X}", colors[rank]), 3) " x" cardX " y" (startY + 240) " w" cardWidth, "Segoe UI")
        }
    }

    region := const_regions["ItemMonitor"], pBrush := Gdip_BrushCreateSolid(0xff201e20), Gdip_FillRoundedRectangle(GReport, pBrush, region.x + 5, region.y + 60, region.w - 10, region.h - 65, 15), Gdip_DeleteBrush(pBrush)
    lineHeight := 50, startY := region.y + 70, uptimeSeconds := DateDiff(A_Now, StartTime, "Seconds"), uptimeStr := Format("{:02}:{:02}:{:02}", uptimeSeconds // 3600, Mod(uptimeSeconds // 60, 60), Mod(uptimeSeconds, 60))
    eggData := (Random(1, 1) = 1) ? EasterEgg() : ""
    lines := ["Total Items Detected: " TotalItemsDetected, "Queries Per Sec: " (uptimeSeconds > 0 ? Format("{:.2f}", Query_Total / uptimeSeconds) : "0"), eggData ? eggData.text : "Image Size: " w "x" h, "Uptime: " uptimeStr]
    for i, t in lines
    {
        if (i = 3 && eggData)
        {
            fontSize := 32, maxWidth := region.w - 40
            loop
            {
                pos := Gdip_TextToGraphics(GReport, t, "s" fontSize " Center Bold c00ffffff x0 y0", "Segoe UI")
                textWidth := SubStr(pos, InStr(pos, "|", , , 2)+1, InStr(pos, "|", , , 3)-InStr(pos, "|", , , 2)-1)
                if (textWidth <= maxWidth || fontSize <= 16)
                    break
                fontSize -= 2
            }
            textX := region.x + (region.w - textWidth) / 2
            pBrush := Gdip_CreateLinearGrBrushFromRect(textX, startY + (i - 1) * lineHeight, textWidth, fontSize, 0x00000000, 0x00000000, 0)
            Gdip_SetLinearGrBrushPresetBlend(pBrush, [0.0, 1], eggData.colors)
            pPen := Gdip_CreatePenFromBrush(pBrush, 1)
            Gdip_DrawOrientedString(GReport, t, "Segoe UI", fontSize, 1, textX, startY + (i - 1) * lineHeight, textWidth, fontSize, 0, pBrush, pPen)
            Gdip_DeletePen(pPen), Gdip_DeleteBrush(pBrush)
        }
        else
            Gdip_TextToGraphics(GReport, t, "s32 Center Bold cffC0C0C0 x" (region.x + 20) " y" (startY + (i - 1) * lineHeight) " w" (region.w - 40), "Segoe UI")
    }
    Gdip_TextToGraphics(GReport, os_version, "s32 Center Bold cff00d4ff x" (region.x + 20) " y" (startY + lines.Length * lineHeight) " w" (region.w - 40), "Segoe UI")
    
    yPos := startY + (lines.Length + 1) * lineHeight
    pos := Gdip_TextToGraphics(GReport, "By prodbyichigo, Myurius", "s32 Bold c00ffffff x0 y0", "Segoe UI"), totalWidth := SubStr(pos, InStr(pos, "|", , , 2)+1, InStr(pos, "|", , , 3)-InStr(pos, "|", , , 2)-1), startX := region.x + (region.w - totalWidth) / 2
    pos := Gdip_TextToGraphics(GReport, "By ", "s32 Left Bold cffC0C0C0 x" startX " y" yPos, "Segoe UI"), currentX := SubStr(pos, 1, InStr(pos, "|", , , 1)-1) + SubStr(pos, InStr(pos, "|", , , 2)+1, InStr(pos, "|", , , 3)-InStr(pos, "|", , , 2)-1)
    
    pos := Gdip_TextToGraphics(GReport, "prodbyichigo,", "s32 Bold c00ffffff x0 y0", "Segoe UI")
    nameWidth := SubStr(pos, InStr(pos, "|", , , 2)+1, InStr(pos, "|", , , 3)-InStr(pos, "|", , , 2)-1)
    pBrush := Gdip_CreateLinearGrBrushFromRect(currentX, yPos, nameWidth, 32, 0x00000000, 0x00000000, 0)
    Gdip_SetLinearGrBrushPresetBlend(pBrush, [0.0, 1], [0xff6466B9, 0xffC182FC])
    pPen := Gdip_CreatePenFromBrush(pBrush, 1)
    Gdip_DrawOrientedString(GReport, "prodbyichigo,", "Segoe UI", 32, 1, currentX, yPos, nameWidth, 32, 0, pBrush, pPen)
    Gdip_DeletePen(pPen), Gdip_DeleteBrush(pBrush)
    currentX += nameWidth
    
    Gdip_TextToGraphics(GReport, " Myurius", "s32 Left Bold cff9900ff x" currentX " y" yPos, "Segoe UI")

    logoY := yPos + 45, logoSize := 40, gap := 1
    pos := Gdip_TextToGraphics(GReport, "discord.gg/natromacro", "s32 Bold c00ffffff x0 y0", "Segoe UI"), linkWidth := SubStr(pos, InStr(pos, "|", , , 2)+1, InStr(pos, "|", , , 3)-InStr(pos, "|", , , 2)-1)
    pos := Gdip_TextToGraphics(GReport, "Natro v" NatroVersionID, "s32 Bold c00ffffff x0 y0", "Segoe UI"), verWidth := SubStr(pos, InStr(pos, "|", , , 2)+1, InStr(pos, "|", , , 3)-InStr(pos, "|", , , 2)-1)
    totalWidth := linkWidth + gap + logoSize + gap + verWidth, startX := region.x + (region.w - totalWidth) / 2
    Gdip_TextToGraphics(GReport, "discord.gg/natromacro", "s32 Left Bold Underline cff3366cc x" startX " y" (logoY + (logoSize-32)/2), "Segoe UI")
    Gdip_DrawImage(GReport, Graphing["pBMNatroLogo"], startX + linkWidth + gap, logoY + 5, logoSize, logoSize)
    Gdip_TextToGraphics(GReport, "Natro v" NatroVersionID, "s32 Left Bold cffb47bd1 x" (startX + linkWidth + gap + logoSize + gap) " y" (logoY + (logoSize-32)/2), "Segoe UI")

    region := const_regions["Items Gained"], cardWidth := 200, cardHeight := 220, cardPadding := 30, cardsPerRow := Floor((region.w - cardPadding * 2) / (cardWidth + cardPadding)), cardStartX := region.x + cardPadding, cardStartY := region.y + 80, col := 0, row := 0
    for itemName, quantity in CollectedItems
    {
        cardX := cardStartX + col * (cardWidth + cardPadding), cardY := cardStartY + row * (cardHeight + cardPadding)
        pPen := Gdip_CreatePen(0xff282628, 3), Gdip_DrawRoundedRectangle(GReport, pPen, cardX, cardY, cardWidth, cardHeight, 15), Gdip_DeletePen(pPen)
        pBrush := Gdip_BrushCreateSolid(0xff323232), Gdip_FillRoundedRectangle(GReport, pBrush, cardX, cardY, cardWidth, cardHeight, 15), Gdip_DeleteBrush(pBrush)
        imageSize := 100, imageX := cardX + (cardWidth - imageSize) / 2, imageY := cardY + 50
        Gdip_DrawImage(GReport, Graphing.Has("pBM" itemName) ? Graphing["pBM" itemName] : Graphing["pBMNoImage"], imageX, imageY, imageSize, imageSize)
        
        nameSize := 24, nameMaxWidth := cardWidth - 20
        Loop {
            pos := Gdip_TextToGraphics(GReport, itemName, "s" nameSize " Bold c00ffffff x0 y0", "Segoe UI")
            textWidth := SubStr(pos, InStr(pos, "|", , , 2)+1, InStr(pos, "|", , , 3)-InStr(pos, "|", , , 2)-1)
            if (textWidth <= nameMaxWidth || nameSize <= 12)
                break
            nameSize -= 2
        }
        Gdip_TextToGraphics(GReport, itemName, "s" nameSize " Bold cffC0C0C0 x" cardX " y" (cardY + 10) " w" cardWidth " Center", "Segoe UI")
        Gdip_TextToGraphics(GReport, "+" FormatNumber(quantity), "s32 Bold cff36cb36 x" cardX " y" (cardY + 150) " w" cardWidth " Center", "Segoe UI")
        col++, (col >= cardsPerRow) ? (col := 0, row++) : 0
    }
 
    Gdip_SetBitmapToClipboard(pBMReport), Gdip_DeleteGraphics(GReport), Gdip_DisposeImage(pBMReport)
}

DetectItems()
{
    global CollectedItems, Stream, Enumeration, LastDetectionTime, LastDetectedValue, Query_Total, ItemTimeline, StartTime
    static QuickDetectionWindow := 6000

    pBMHaystack := IsolateHaystack(CreateHaystack()), Query_Total++, x := ""

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
    Eggs := Map()
    Eggs["Send concrete proof!"] := "Common"
    Eggs["Why am I making so little?"] := "Common"
    Eggs["Natro so broke :weary:"] := "Uncommon"
    Eggs["uwuru was here"] := "Rare"
    Eggs["Will money_mountain EVER get admin?"] := "Very Rare"
    Eggs["Move in silence... Only speak when it is time to say checkmate."] := "Very Rare"
    Eggs["777,777!"] := "Very Rare"
    Eggs["There is a 0.000000001% chance you'll see this message"] := "Mythic"
    Eggs["discord.gg/natromacro -> 1258920032218644580"] := "Legendary"
    Eggs["BRING BACK CHASE!"] := "Legendary"
    Eggs["tophal you ARE moderation"] := "Legendary"
    Eggs["I gave the owner a handshake."] := "Legendary"
    Eggs["iDTuezQ (/): no appeal - Permanent"] := "Mythic"
    Eggs["Mod abuse? Who are you gonna tell? The mods?"] := "Mythic"
    Eggs["Lost my 118 day wordle streak I hope all of you lose it too"] := "Mythic"
    Eggs["I'm secretly gay but nobody will see this"] := "Legendary"
    Eggs["your free trial of natro macro has expired..."] := "Common"
    Eggs["men ruin everything /j"] := "Uncommon"
    Eggs["You were banned from Natro Macro. Reason: ````````"] := "Rare"
    Eggs["Give me ur email"] := "Uncommon"
    Eggs["I'll overthrow whoever #1 is at right now."] := "Rare"
    Eggs['"one thing was untrue, just one"'] := "Very Rare"
    Eggs["SP The Wizard..."] := "Legendary"
    Eggs["rahh 10t a day mixed hive"] := "Legendary"
    Eggs["anyone else love pumpkin pie"] := "Legendary"
    Eggs["what if instead of admin-chat it was freaky-chat"] := "Mythic"
    Eggs["probs get petal wand then tbh"] := "Very Rare"
    Eggs["ME FLEXING MY TOP 1 WEEKLY LB SPOT"] := "Very Rare"
    Eggs["OMG NATRO SHIRT ARRIVED"] := "Mythic"
    Eggs["GETRICH12345"] := "Mythic"
    Eggs["my macro walks but doesn't talk"] := "Rare"
    Eggs["Is Natro Macro 13+?"] := "Rare"
    Eggs["nature macro..."] := "Legendary"
    Eggs["jmao"] := "Legendary"
    
    colors := Map(
        "Common", [0xffffffff, 0xffA0A0A8],
        "Uncommon", [0xff5CDB5C, 0xff3B873B],
        "Rare", [0xff4A9EFF, 0xff2B5F99],
        "Very Rare", [0xffB24BFF, 0xff6B2D99],
        "Legendary", [0xffFFD700, 0xffFF8C00],
        "Mythic", [0xffFF1493, 0xff8B008B]
    )
    
    r := Map("Common",100,"Uncommon",50,"Rare",25,"Very Rare",10,"Legendary",8,"Mythic",3)
    t := 0
    for m, x in Eggs
        t += r[x]
    v := Random(1, t), w := 0
    for m, x in Eggs
        if v <= w += r[x]
            return {text: m, rarity: x, colors: colors[x]}
}

TestItemReport()
{
    global CollectedItems, ItemTimeline, StartTime, TotalItemsDetected
    CollectedItems.Clear(), ItemTimeline.Clear(), StartTime := DateAdd(A_Now, -60, "Minutes"), TotalItemsDetected := 0
    allItems := ["Honey", "Blueberry", "SunflowerSeed", "Strawberry", "Pineapple", "Treat", "Ticket", "Moon Charm", "Royal Jelly", "Magic Bean", "Soft Wax", "Blue Extract", "Red Extract", "Enzyme", "Oil", "Gumdrops", "Star Jelly", "Loaded Dice", "Micro-Converter", "Honeysuckle", "Field Dice", "Tropical Drink", "Bitterberry", "Super Smoothie"]
    Loop 60
    {
        minuteSlot := A_Index - 1, itemsThisMinute := (minuteSlot < 20) ? Random(10, 25) : (minuteSlot < 45) ? Random(25, 50) : Random(15, 35)
        ItemTimeline.Has(minuteSlot) ? 0 : ItemTimeline[minuteSlot] := 0
        Loop itemsThisMinute
            r := Random(1, 100), item := (r <= 30) ? "Honey" : (r <= 50) ? "Blueberry" : (r <= 65) ? "Strawberry" : (r <= 78) ? "SunflowerSeed" : (r <= 88) ? "Pineapple" : (r <= 93) ? allItems[Random(6, 10)] : allItems[Random(11, allItems.Length)], CollectedItems[item] := (CollectedItems.Has(item) ? CollectedItems[item] : 0) + 1, ItemTimeline[minuteSlot]++, TotalItemsDetected++
    }
    SendItemReport(), totalItems := 0
    ToolTip("Created"), Sleep(2000), ToolTip()
}

;; Prep complete - Uncomment to exec on begin ;;
loop
    DetectItems(), (A_TickCount - LastReportTime >= ReportInterval) ? (SendItemReport(), CollectedItems.Clear(), ItemTimeline.Clear(), StartTime := A_Now, LastReportTime := A_TickCount) : 0, ToolTip(A_TickCount)

F2::Pause
F3::Reload
F4::TestItemReport()
F5::SendItemReport()
F6::Gdip_SetBitmapToClipboard(IsolateHaystack(CreateHaystack()))
F8::{
    counts := Map()
    total := 10000
    
    loop total
    {
        quote := EasterEgg()
        counts[quote] := (counts.Has(quote) ? counts[quote] : 0) + 1
    }
    
    output := "Easter Egg Rarity Test (" total " samples):`n`n"
    for quote, count in counts
        output .= count " (" Round(count/total*100, 2) "%) - " quote "`n"
    
    MsgBox(output)
}
f9::{
    loop
    {
        loop 5
        {
            Tooltip 5 - A_Index
            Sleep(1000)
        }
        SendItemReport()
    }
}