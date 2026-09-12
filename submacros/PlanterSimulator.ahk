#Requires AutoHotkey v2.0
#SingleInstance Force
#NoTrayIcon
#Include "%A_ScriptDir%\..\lib"
#Include "PlanterData.ahk"
#Include "PlanterNectarMath.ahk"
#Include "PlanterPolicyMath.ahk"
#Include "PlanterTiming.ahk"
#Include "PlanterAllocation.ahk"
#Include "PlanterSimulation.ahk"
#Include "PlanterPlanner.ahk"
#Include "Gdip_All.ahk"
#Include "PlanterCharts.ahk"

SetWorkingDir A_ScriptDir "\.."
PS_Fields := Map("Comforting", ComfortingFields, "Motivating", MotivatingFields,
    "Satisfying", SatisfyingFields, "Refreshing", RefreshingFields, "Invigorating", InvigoratingFields)
PS_Tables := Map()
for nectar, fields in PS_Fields
    for _, field in fields {
        key := StrReplace(field, " ")
        PS_Tables[field] := %key%Planters
    }

PS_Current := false, PS_Running := false, PS_ChartToken := 0, PS_Days := 14
PS_Buttons := Map(), PS_Hover := 0
OnExit(PS_ExitChart)
OnMessage(0x2B, PS_DrawButton)
OnMessage(0x200, PS_ButtonHover)
OnMessage(0x2A3, PS_ButtonLeave)
PS_Gui := Gui("+Resize +MinSize680x480", "Planter simulator")
PS_Gui.BackColor := "F1F5F8"
PS_Gui.SetFont("s9 c243E43", "Segoe UI")
PS_Gui.AddText("x0 y0 w740 h82 vHeader Background102735")
PS_Gui.AddText("x18 y13 w430 h28 vTitle Background102735 cFFFFFF", "Planter simulator").SetFont("s18 Bold")
PS_Gui.AddText("x18 y52 w490 h18 vSetup Background102735 cA9BDC8", "Uses your saved macro settings").SetFont("s8")
PS_Button("x508 y12 w86 h32 vCsv Disabled", "Export CSV", "secondary").OnEvent("Click", PS_Csv)
PS_Button("x606 y12 w116 h32 vRun", "Run simulation", "primary").OnEvent("Click", PS_Start)
for index, days in [14, 30, 90]
    PS_Button("x" 542+(index-1)*62 " y51 w56 h24 vDays" days, days " days", "duration", days).OnEvent("Click", PS_Duration)
PS_AccentColors := ["168577", "3985B6", "8461B8", "B78324"]
for index, label in ["ALL FLOORS TOGETHER", "COLLECTIONS / DAY", "BUILT TO TARGET", "TRAVEL / DAY"] {
    PS_Gui.AddText("x14 y94 w172 h62 vCard" index " BackgroundFFFFFF")
    PS_Gui.AddText("x14 y106 w3 h38 vAccent" index " Background" PS_AccentColors[index])
    PS_Gui.AddText("x26 y102 w148 h16 vLabel" index " BackgroundFFFFFF c6A7E89", label).SetFont("s8")
    PS_Gui.AddText("x26 y120 w148 h27 vMetric" index " BackgroundFFFFFF", "—").SetFont("s17 Bold")
}
PS_Gui.AddPicture("x14 y168 w712 h338 +0xE vChart")
PS_Gui.OnEvent("Size", PS_Layout)
PS_Gui.OnEvent("Close", (*) => ExitApp())
PS_Gui.OnEvent("Escape", PS_Cancel)
try PS_SetupText(PS_Config())
MonitorGetWorkArea(MonitorGetPrimary(), &workLeft, &workTop, &workRight, &workBottom)
PS_Gui.Show("w" Max(680, Min(740, Floor((workRight-workLeft-32)/(A_ScreenDPI/96))))
    " h" Max(480, Min(520, Floor((workBottom-workTop-54)/(A_ScreenDPI/96)))))
PS_Gui["Run"].Focus()

PS_SetupText(config) {
    global PS_Gui
    PS_Gui["Setup"].Text := Format("{} types  ·  {} fields  ·  {} slots  ·  {}% buffer", config.types.Count, config.fields.Count, config.capacity, config.buffer)
}

PS_Button(options, caption, kind, days := 0) {
    global PS_Gui, PS_Buttons
    control := PS_Gui.AddButton(options " +0xB", caption)
    control.SetFont(kind = "primary" ? "s9 Bold" : "s8")
    PS_Buttons[control.Hwnd] := {control: control, kind: kind, days: days}
    return control
}

PS_Duration(control, *) {
    global PS_Days, PS_Buttons, PS_Running
    if !PS_Running {
        PS_Days := PS_Buttons[control.Hwnd].days
        PS_RefreshButtons()
    }
}

PS_RefreshButtons() {
    global PS_Buttons
    for hwnd in PS_Buttons
        DllCall("user32\InvalidateRect", "Ptr", hwnd, "Ptr", 0, "Int", false)
}

PS_ButtonHover(wParam, lParam, message, hwnd) {
    global PS_Buttons, PS_Hover
    if (!PS_Buttons.Has(hwnd) || PS_Hover = hwnd)
        return
    previous := PS_Hover, PS_Hover := hwnd
    if previous
        DllCall("user32\InvalidateRect", "Ptr", previous, "Ptr", 0, "Int", false)
    DllCall("user32\InvalidateRect", "Ptr", hwnd, "Ptr", 0, "Int", false)
    tracking := Buffer(8+2*A_PtrSize, 0)
    NumPut("UInt", tracking.Size, "UInt", 2, "Ptr", hwnd, tracking)
    DllCall("user32\TrackMouseEvent", "Ptr", tracking)
}

PS_ButtonLeave(wParam, lParam, message, hwnd) {
    global PS_Hover
    if (PS_Hover = hwnd) {
        PS_Hover := 0
        DllCall("user32\InvalidateRect", "Ptr", hwnd, "Ptr", 0, "Int", false)
    }
}

PS_RGB(color) => ((color & 255) << 16) | (color & 0xFF00) | ((color >> 16) & 255)

PS_DrawButton(wParam, item, *) {
    global PS_Buttons, PS_Hover, PS_Days
    if (!item || NumGet(item, 0, "UInt") != 4)
        return
    offset := A_PtrSize = 8 ? 24 : 20
    hwnd := NumGet(item, offset, "Ptr")
    if !PS_Buttons.Has(hwnd)
        return
    entry := PS_Buttons[hwnd], state := NumGet(item, 16, "UInt")
    dc := NumGet(item, offset+A_PtrSize, "Ptr"), rect := item+offset+2*A_PtrSize
    left := NumGet(rect, 0, "Int"), top := NumGet(rect, 4, "Int")
    right := NumGet(rect, 8, "Int"), bottom := NumGet(rect, 12, "Int")
    primary := entry.kind = "primary", selected := entry.days && entry.days = PS_Days
    disabled := state & 4, pressed := state & 1, hot := hwnd = PS_Hover
    fill := primary ? 0x168577 : (selected ? 0x315363 : 0x102735)
    border := primary ? fill : (selected ? 0x57B9AF : 0x35515F)
    ink := 0xF5FAFC
    if disabled
        fill := 0x1D3441, border := 0x294450, ink := 0x8299A5
    else if pressed
        fill := primary ? 0x10695F : 0x3B606F
    else if hot
        fill := primary ? 0x20988A : 0x284856
    saved := DllCall("gdi32\SaveDC", "Ptr", dc, "Int"), back := 0, brush := 0, pen := 0
    if !saved
        return true
    try {
        back := DllCall("gdi32\CreateSolidBrush", "UInt", PS_RGB(0x102735), "Ptr")
        DllCall("user32\FillRect", "Ptr", dc, "Ptr", rect, "Ptr", back)
        brush := DllCall("gdi32\CreateSolidBrush", "UInt", PS_RGB(fill), "Ptr")
        pen := DllCall("gdi32\CreatePen", "Int", 0, "Int", Max(1, Round(A_ScreenDPI/96)), "UInt", PS_RGB(border), "Ptr")
        DllCall("gdi32\SelectObject", "Ptr", dc, "Ptr", brush)
        DllCall("gdi32\SelectObject", "Ptr", dc, "Ptr", pen)
        radius := Round(12*A_ScreenDPI/96)
        DllCall("gdi32\RoundRect", "Ptr", dc, "Int", left, "Int", top, "Int", right, "Int", bottom, "Int", radius, "Int", radius)
        font := SendMessage(0x31, 0, 0, hwnd)
        if font
            DllCall("gdi32\SelectObject", "Ptr", dc, "Ptr", font)
        DllCall("gdi32\SetBkMode", "Ptr", dc, "Int", 1)
        DllCall("gdi32\SetTextColor", "Ptr", dc, "UInt", PS_RGB(ink))
        DllCall("user32\DrawTextW", "Ptr", dc, "Str", entry.control.Text, "Int", -1, "Ptr", rect, "UInt", 0x825)
        if (!disabled && (state & 0x10) && !(state & 0x200)) {
            focus := Buffer(16), inset := Round(4*A_ScreenDPI/96)
            NumPut("Int", left+inset, "Int", top+inset, "Int", right-inset, "Int", bottom-inset, focus)
            DllCall("user32\DrawFocusRect", "Ptr", dc, "Ptr", focus)
        }
    } finally {
        if saved
            DllCall("gdi32\RestoreDC", "Ptr", dc, "Int", saved)
        for resource in [back, brush, pen]
            if resource
                DllCall("gdi32\DeleteObject", "Ptr", resource)
    }
    return true
}

PS_Layout(window, state, *) {
    if (state = -1)
        return
    window.GetClientPos(,, &width, &height)
    window["Header"].Move(,, width, 82)
    window["Run"].Move(width-134, 12, 116, 32)
    window["Csv"].Move(width-232, 12, 86, 32)
    window["Title"].Move(,, width-268)
    window["Setup"].Move(,, width-244)
    for index, days in [14, 30, 90]
        window["Days" days].Move(width-198+(index-1)*62, 51, 56, 24)
    column := (width-52)/4
    Loop 4 {
        x := 14+(A_Index-1)*(column+8)
        window["Card" A_Index].Move(x, 94, column, 62)
        window["Accent" A_Index].Move(x, 106, 3, 38)
        window["Label" A_Index].Move(x+12, 102, column-24, 16)
        window["Metric" A_Index].Move(x+12, 120, column-24, 27)
    }
    window["Chart"].Move(14, 168, width-28, height-182)
    SetTimer PS_Redraw, -100
}

PS_Start(*) {
    global PS_Gui, PS_Current, PS_Running, PS_Days
    if PS_Running {
        PS_Cancel()
        return
    }
    try {
        days := PS_Days
        config := PS_Config()
        world := PS_World(config, days)
    } catch as err {
        MsgBox err.Message, "Cannot simulate settings", "Icon!"
        return
    }
    PS_Current := world, PS_Running := true
    world.planning.pulse := PS_Pulse.Bind(world)
    PS_SetupText(config)
    Loop 4
        PS_Gui["Metric" A_Index].Text := "—"
    for _, name in ["Days14", "Days30", "Days90", "Csv"]
        PS_Gui[name].Enabled := false
    PS_Gui["Run"].Text := "Cancel · 0%"
    PS_RefreshButtons()
    PS_Redraw()
    SetTimer PS_Tick, 15
}

PS_Pulse(world) {
    global PS_Current, PS_Running, PS_Gui
    static last := 0
    if (!PS_Running || world != PS_Current)
        throw Error("Simulation cancelled.")
    if (A_TickCount-last < 30)
        return
    last := A_TickCount
    text := "Cancel · " Floor(100*world.now/world.finish) "%"
    if (PS_Gui["Run"].Text != text)
        PS_Gui["Run"].Text := text
    Sleep(-1)
    if (!PS_Running || world != PS_Current)
        throw Error("Simulation cancelled.")
}

PS_Tick() {
    global PS_Gui, PS_Current, PS_Running
    world := PS_Current, started := A_TickCount
    try {
        Loop 8 {
            if (!PS_Running || world != PS_Current)
                return
            world.Step()
            if (world.completed || A_TickCount-started > 30)
                break
        }
        if (!PS_Running || world != PS_Current)
            return
        PS_Pulse(world)
        if world.completed {
            PS_Stop()
            PS_Results(world)
        }
    } catch as err {
        if (!PS_Running || world != PS_Current)
            return
        PS_Stop()
        MsgBox err.Message, "Simulation could not finish", "Icon!"
    }
}

PS_Stop() {
    global PS_Gui, PS_Running, PS_Current
    PS_Running := false
    PS_Current.planning.pulse := false
    SetTimer PS_Tick, 0
    for _, name in ["Days14", "Days30", "Days90"]
        PS_Gui[name].Enabled := true
    PS_Gui["Run"].Text := "Run simulation"
    PS_RefreshButtons()
}

PS_Cancel(*) {
    global PS_Running
    if PS_Running
        PS_Stop()
}

PS_Results(world) {
    global PS_Gui
    window := world.finish-world.warmup, days := window/86400
    built := 0, latest := 0
    for _, group in world.groups
        if (group.firstBuilt >= 0)
            built++, latest := Max(latest, group.firstBuilt)
    PS_Gui["Metric1"].Text := Format("{:.1f}%", world.covered*100/window)
    PS_Gui["Metric2"].Text := Format("{:.1f}", world.maintenanceCollections/days)
    PS_Gui["Metric3"].Text := built = world.groups.Length ? Format("{:.1f} h", latest/3600) : built " / " world.groups.Length
    PS_Gui["Metric4"].Text := Format("{:.1f} min", (world.maintenanceWork["Place"]+world.maintenanceWork["Collect"])/60/days)
    PS_Gui["Csv"].Enabled := true
    PS_RefreshButtons()
    PS_Redraw()
}

PS_RenderPicture(picture, world) {
    global PS_ChartToken
    if !PS_ChartToken
        PS_ChartToken := Gdip_Startup()
    if !PS_ChartToken
        throw Error("Windows could not start the chart renderer.")
    picture.GetPos(,, &width, &height)
    if (width < 300 || height < 160)
        return
    bitmap := PC_Render(world, width, height, A_ScreenDPI/96)
    try {
        SetImage(picture.Hwnd, bitmap)
        bitmap := 0
    } finally {
        if bitmap
            DeleteObject(bitmap)
    }
}

PS_Redraw(*) {
    global PS_Gui, PS_Current
    try PS_RenderPicture(PS_Gui["Chart"], PS_Current && PS_Current.completed ? PS_Current : false)
    catch as err
        MsgBox err.Message, "Could not draw simulated chart", "Icon!"
}

PS_ExitChart(*) {
    global PS_Gui, PS_ChartToken
    SetTimer PS_Redraw, 0
    if IsSet(PS_Gui)
        try SetImage(PS_Gui["Chart"].Hwnd, 0)
    if PS_ChartToken
        Gdip_Shutdown(PS_ChartToken)
}

PS_Value(section, key, fallback := "") => section.Has(key) ? section[key] : fallback

PS_IniSnapshot(path) {
    text := FileRead(path), sections := Map(), section := false
    sections.CaseSense := "Off"
    for _, raw in StrSplit(text, "`n", "`r") {
        line := Trim(raw, " `t" Chr(0xFEFF))
        if (!line || SubStr(line, 1, 1) = ";")
            continue
        if RegExMatch(line, "^\[([^\]]+)\]$", &match) {
            section := Map(), section.CaseSense := "Off"
            sections[match[1]] := section
        } else if (section && (pos := InStr(line, "=")))
            section[Trim(SubStr(line, 1, pos-1))] := Trim(SubStr(line, pos+1))
    }
    return sections
}

PS_Number(section, key, fallback, low, high) {
    value := PS_Value(section, key, fallback)
    if (!IsNumber(value) || value < low || value > high || value != Floor(value))
        throw Error("Invalid setting: " key ". Choose a value in the macro and try again.")
    return Number(value)
}

PS_Config() {
    global PS_Fields, PS_Tables
    snapshot := PS_IniSnapshot("settings\nm_config.ini")
    if !snapshot.Has("Planters")
        throw Error("Open the macro and select Adaptive Planters settings first.")
    settings := snapshot["Planters"], gather := snapshot.Has("Gather") ? snapshot["Gather"] : Map()
    timingRecords := snapshot.Has("PlanterTiming") ? snapshot["PlanterTiming"] : Map()
    config := {groups: [], capacity: PS_Number(settings, "MaxAllowedPlanters", 3, 0, 3),
        buffer: PS_Number(settings, "PlanterBuffer", 10, 0, 20), types: Map(), fields: Map()}
    sipping := PS_Number(settings, "GatherFieldSipping", 0, 0, 1)
    planterGather := PS_Number(settings, "GotoPlanterField", 0, 0, 1)
    currentField := PS_Value(gather, "FieldName" PS_Number(gather, "CurrentFieldNum", 1, 1, 3), "Sunflower")
    seen := Map()
    Loop 5 {
        name := PS_Value(settings, "n" A_Index "priority", "None")
        if (name = "None")
            break
        if (!PS_Fields.Has(name) || seen.Has(name))
            throw Error("Nectar priorities must be valid and unique. Update them in the macro.")
        seen[name] := true
        group := {nectar: name, minimum: PS_Number(settings, "n" A_Index "minPercent", 70, 1, 100),
            buffer: config.buffer, priority: A_Index, candidates: [], sippingField: sipping && !planterGather ? currentField : ""}
        for _, field in PS_Fields[name] {
            key := StrReplace(field, " ")
            if !PS_Number(settings, key "FieldCheck", 0, 0, 1)
                continue
            config.fields[field] := true
            timing := PT_TimingEstimate(PS_Value(timingRecords, key "_Travel"))
            for _, stats in PS_Tables[field] {
                if !PS_Number(settings, stats[1] "Check", 0, 0, 1)
                    continue
                config.types[stats[1]] := true
                group.candidates.Push({field: field, planter: stats.Clone(), delay: timing.seconds,
                    lead: timing.seconds, dispatchLead: PT_TravelDispatch(timing), tail: 0})
            }
        }
        config.groups.Push(group)
    }
    if !config.groups.Length
        throw Error("Select at least one nectar priority in Adaptive Planters.")
    return config
}

PS_ChartPoints(world, index, left, right) {
    points := [], lo := 1, hi := world.segments.Length+1
    while (lo < hi) {
        mid := Floor((lo+hi)/2)
        if (world.segments[mid][2] <= left)
            lo := mid+1
        else
            hi := mid
    }
    Loop world.segments.Length-lo+1 {
        segment := world.segments[lo+A_Index-1]
        if (segment[1] >= right)
            break
        a := Max(left, segment[1]), b := Min(right, segment[2])
        if (b <= a)
            continue
        value := segment[3][index]
        points.Push([a, Max(0, value-(a-segment[1])/864)])
        zeroAt := segment[1]+value*864
        if (zeroAt > a && zeroAt < b)
            points.Push([zeroAt, 0])
        points.Push([b, Max(0, value-(b-segment[1])/864)])
    }
    return points
}

PS_Write(path, text) {
    file := FileOpen(path, "w", "UTF-8")
    try file.Write(text)
    finally file.Close()
}

PS_Csv(*) {
    global PS_Current
    if (!PS_Current || !PS_Current.completed)
        return
    path := FileSelect("S16", "Planter collections.csv", "Export simulated collections", "CSV (*.csv)")
    if !path
        return
    text := "Hours,Nectar,Field,Planter,GrowthHours,GrowthPercent,NectarGained,Before,After,Phase,Slot,Minimum,LowerFloor,DeficitBeforeHarvest`r`n"
    for _, row in PS_Current.collections
        text .= Format("{:.6f},{},{},{},{:.6f},{:.3f},{:.6f},{:.6f},{:.6f},{},{},{},{},{:.6f}`r`n", row.at/3600, row.nectar, row.field,
            row.name, row.age/3600, Min(100, 100*row.age/row.full), row.amount, row.before, row.after, row.phase, row.slot,
            row.minimum, row.floor, Max(0, row.floor-row.before))
    try PS_Write(path, text)
    catch as err
        MsgBox err.Message, "Could not export simulation", "Icon!"
}
