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

PS_Current := false, PS_Running := false, PS_ChartToken := 0
OnExit(PS_ExitChart)
PS_Gui := Gui("+Resize +MinSize680x480", "Planter simulator")
PS_Gui.BackColor := "F7F9FA"
PS_Gui.SetFont("s9 c243E43", "Segoe UI")
PS_Gui.AddText("x16 y12 w400 h28 vTitle", "Planter simulator").SetFont("s17 Bold")
PS_Gui.AddButton("x566 y12 w84 h30 vCsv Disabled", "Export CSV").OnEvent("Click", PS_Csv)
PS_Gui.AddButton("x660 y12 w124 h30 vRun Default", "Run simulation").OnEvent("Click", PS_Start)
PS_Gui["Run"].SetFont("Bold")
PS_Gui.AddRadio("x16 y50 w72 h24 vDays14 Group Checked", "14 days")
PS_Gui.AddRadio("x94 y50 w72 h24 vDays30", "30 days")
PS_Gui.AddRadio("x172 y50 w72 h24 vDays90", "90 days")
PS_Gui.AddText("x260 y54 w524 h20 vSetup c687A80 Right", "Uses your saved macro settings")
for index, label in ["ALL FLOORS TOGETHER", "COLLECTIONS / DAY", "BUILT TO TARGET", "TRAVEL / DAY"] {
    PS_Gui.AddText("x16 y88 w180 h16 vLabel" index " c687A80", label).SetFont("s8")
    PS_Gui.AddText("x16 y105 w180 h28 vMetric" index, "—").SetFont("s18 Bold")
}
PS_Gui.AddPicture("x16 y146 w768 h398 +0xE vChart")
PS_Gui.OnEvent("Size", PS_Layout)
PS_Gui.OnEvent("Close", (*) => ExitApp())
PS_Gui.OnEvent("Escape", PS_Cancel)
try PS_SetupText(PS_Config())
MonitorGetWorkArea(MonitorGetPrimary(), &workLeft, &workTop, &workRight, &workBottom)
PS_Gui.Show("w" Max(680, Min(800, Floor((workRight-workLeft-32)/(A_ScreenDPI/96))))
    " h" Max(480, Min(560, Floor((workBottom-workTop-54)/(A_ScreenDPI/96)))))

PS_SetupText(config) {
    global PS_Gui
    PS_Gui["Setup"].Text := Format("{} types  ·  {} fields  ·  {} slots  ·  {}% buffer", config.types.Count, config.fields.Count, config.capacity, config.buffer)
}

PS_Layout(window, state, *) {
    if (state = -1)
        return
    window.GetClientPos(,, &width, &height)
    window["Run"].Move(width-140, 12, 124, 30)
    window["Csv"].Move(width-234, 12, 84, 30)
    window["Title"].Move(,, width-266)
    window["Setup"].Move(260, 54, width-276, 20)
    column := (width-68)/4
    Loop 4 {
        x := 16+(A_Index-1)*(column+12)
        window["Label" A_Index].Move(x, 88, column, 16)
        window["Metric" A_Index].Move(x, 105, column, 28)
    }
    window["Chart"].Move(16, 146, width-32, height-162)
    SetTimer PS_Redraw, -100
}

PS_Start(*) {
    global PS_Gui, PS_Current, PS_Running
    if PS_Running {
        PS_Cancel()
        return
    }
    try {
        days := PS_Gui["Days90"].Value ? 90 : (PS_Gui["Days30"].Value ? 30 : 14)
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
