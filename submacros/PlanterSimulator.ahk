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

PS_Current := false, PS_Running := false, PS_Plot := false, PS_DetailsGui := false, PS_ChartToken := 0
OnExit(PS_ExitChart)
PS_Gui := Gui("+Resize +MinSize860x620", "Planter simulator")
PS_Gui.BackColor := "F3F6F7"
PS_Gui.SetFont("s10 c243E43", "Segoe UI")
PS_Gui.AddText("x24 y16 w520 h36 vTitle", "Planter simulator").SetFont("s22 Bold")
PS_Gui.AddText("x24 y55 w680 h24 vSetup c65767E", "Preview the planter settings saved in your macro.")
PS_Gui.AddButton("x780 y20 w70 h34 vCancel Hidden", "Cancel").OnEvent("Click", PS_Cancel)
PS_Gui.AddButton("x870 y20 w150 h34 vRun Default", "Run simulation").OnEvent("Click", PS_Start)
PS_Gui["Run"].SetFont("Bold")
PS_Gui.AddText("x24 y89 w90 h20 vDurationLabel c65767E", "DURATION")
PS_Gui.AddDropDownList("x24 y111 w110 vDays Choose1", ["14 days", "30 days", "90 days"])
PS_Gui.AddText("x154 y113 w300 h24 vTravelCaption c65767E", "Travel: automatic per field")
PS_Gui.AddButton("x690 y106 w116 h32 vDetails Disabled", "Run details").OnEvent("Click", PS_Details)
PS_Gui.AddButton("x816 y106 w116 h32 vCsv Disabled", "Export CSV").OnEvent("Click", PS_Csv)
for index, label in ["ALL FLOORS TOGETHER", "COLLECTIONS / DAY", "BUILDUP", "TRAVEL / DAY"] {
    PS_Gui.AddText("x24 y158 w200 h88 BackgroundFFFFFF vCard" index)
    PS_Gui.AddText("x36 y168 w180 h18 BackgroundFFFFFF c6B7C83 vLabel" index, label).SetFont("s9")
    PS_Gui.AddText("x36 y187 w180 h35 BackgroundFFFFFF vMetric" index, "—").SetFont("s23 Bold")
    PS_Gui.AddText("x36 y224 w180 h18 BackgroundFFFFFF c6B7C83 vHint" index, "Run to preview").SetFont("s9")
}
PS_Gui.AddText("x24 y258 w900 h24 vVerdict c52686F", "Start from zero nectar. See which nectars build up and which fall below their buffers.")
PS_Gui.AddDropDownList("x24 y294 w232 vPeriod Choose1", ["Buildup + maintenance", "Buildup: first five days", "Maintenance: final three days", "Entire run"]).OnEvent("Change", PS_Redraw)
PS_Gui.AddText("x272 y298 w440 h22 vChartCaption c65767E", "All selected nectars · independent 0–100% axes")
PS_Gui.AddButton("x800 y289 w132 h32 vView Disabled", "Expand charts").OnEvent("Click", PS_View)
PS_Gui.AddPicture("x24 y334 w960 h400 +0xE vChart")
PS_Gui.OnEvent("Size", PS_Layout)
PS_Gui.OnEvent("Close", (*) => ExitApp())
PS_Gui.OnEvent("Escape", PS_Cancel)
try PS_SetupText(PS_Config())
MonitorGetWorkArea(MonitorGetPrimary(), &workLeft, &workTop, &workRight, &workBottom)
PS_Gui.Show("w" Max(860, Min(1120, Floor((workRight-workLeft-48)/(A_ScreenDPI/96))))
    " h" Max(620, Min(860, Floor((workBottom-workTop-70)/(A_ScreenDPI/96)))))

PS_SetupText(config) {
    global PS_Gui
    PS_Gui["Setup"].Text := Format("{} planter types  ·  {} fields  ·  {} slots  ·  {}% buffer", config.types.Count, config.fields.Count, config.capacity, config.buffer)
}

PS_Layout(gui, state, *) {
    if (state = -1)
        return
    gui.GetClientPos(,, &width, &height)
    gui["Run"].Move(width-174, 20, 150, 34)
    gui["Cancel"].Move(width-252, 20, 70, 34)
    gui["Title"].Move(,, width-304)
    gui["Setup"].Move(,, width-48)
    compact := height < 740
    gui["DurationLabel"].Visible := !compact
    gui["Days"].Move(, compact ? 91 : 111)
    gui["TravelCaption"].Move(, compact ? 94 : 113)
    gui["Details"].Move(width-268, compact ? 86 : 106, 116, 32)
    gui["Csv"].Move(width-140, compact ? 86 : 106, 116, 32)
    cardWidth := (width-84)/4
    Loop 4 {
        x := 24+(A_Index-1)*(cardWidth+12)
        gui["Card" A_Index].Move(x, compact ? 130 : 158, cardWidth, compact ? 70 : 88)
        gui["Label" A_Index].Move(x+12, compact ? 140 : 168, cardWidth-24)
        gui["Metric" A_Index].Move(x+12, compact ? 159 : 187, cardWidth-24)
        gui["Hint" A_Index].Move(x+12, 224, cardWidth-24)
        gui["Hint" A_Index].Visible := !compact
    }
    gui["Verdict"].Move(, compact ? 212 : 258, width-48)
    gui["Period"].Move(, compact ? 246 : 294)
    gui["View"].Move(width-156, compact ? 241 : 289, 132, 32)
    gui["ChartCaption"].Move(, compact ? 250 : 298, width-452)
    chartTop := compact ? 286 : 334
    gui["Chart"].Move(24, chartTop, width-48, height-chartTop-20)
    SetTimer PS_Redraw, -100
}

PS_Start(*) {
    global PS_Gui, PS_Current, PS_Running, PS_Plot, PS_DetailsGui
    try {
        days := [14, 30, 90][PS_Gui["Days"].Value]
        config := PS_Config()
        world := PS_World(config, days)
    } catch as err {
        MsgBox err.Message, "Cannot simulate settings", "Icon!"
        return
    }
    if PS_Plot
        PS_CloseChart(PS_Plot)
    if PS_DetailsGui {
        PS_DetailsGui.Destroy()
        PS_DetailsGui := false
    }
    PS_Current := world, PS_Running := true
    PS_SetupText(config)
    Loop 4 {
        PS_Gui["Metric" A_Index].Text := "—"
        PS_Gui["Hint" A_Index].Text := "Simulation running"
    }
    for _, name in ["Run", "Days", "View", "Csv", "Details", "Period"]
        PS_Gui[name].Enabled := false
    PS_Gui["Cancel"].Visible := true
    PS_Gui["Run"].Text := "Running 0%"
    PS_Gui["Verdict"].Text := "Building your preview from zero nectar…"
    PS_Redraw()
    SetTimer PS_Tick, 15
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
        PS_Gui["Run"].Text := "Running " Floor(100*world.now/world.finish) "%"
        if world.completed {
            PS_Stop()
            PS_Results(world)
        }
    } catch as err {
        if (world != PS_Current)
            return
        PS_Stop()
        PS_Gui["Verdict"].Text := "The run could not finish. Your settings have not been changed."
        MsgBox err.Message, "Simulation could not finish", "Icon!"
    }
}

PS_Stop() {
    global PS_Gui, PS_Running
    PS_Running := false
    SetTimer PS_Tick, 0
    for _, name in ["Run", "Days", "Period"]
        PS_Gui[name].Enabled := true
    PS_Gui["Cancel"].Visible := false
    PS_Gui["Run"].Text := "Run simulation"
}

PS_Cancel(*) {
    global PS_Gui, PS_Current, PS_Running
    if !PS_Running
        return
    PS_Stop()
    PS_Gui["Verdict"].Text := "Run cancelled. Run again to see complete results."
    Loop 4
        PS_Gui["Hint" A_Index].Text := "No completed result"
}

PS_Results(world) {
    global PS_Gui
    window := world.finish-world.warmup, days := window/86400
    built := 0, latest := 0, gaps := 0, coverageSum := 0, lowestCoverage := 101, lowestNectar := ""
    for _, group in world.groups {
        coverage := group.covered*100/window, coverageSum += coverage
        if (coverage < lowestCoverage)
            lowestCoverage := coverage, lowestNectar := group.nectar
        if (group.firstBuilt >= 0)
            built++, latest := Max(latest, group.firstBuilt)
        if (world.Metrics(group).below > 0.001)
            gaps++
    }
    PS_Gui["Metric1"].Text := Format("{:.2f}%", world.covered*100/window)
    PS_Gui["Hint1"].Text := "All selected nectars at once"
    PS_Gui["Metric2"].Text := Format("{:.2f}", world.maintenanceCollections/days)
    PS_Gui["Hint2"].Text := "Measured after day 7"
    PS_Gui["Metric3"].Text := built = world.groups.Length ? Format("{:.1f} h", latest/3600) : built " / " world.groups.Length
    PS_Gui["Hint3"].Text := built = world.groups.Length ? "Each nectar reached 97%" : "Nectars that reached 97%"
    PS_Gui["Metric4"].Text := Format("{:.1f} min", (world.maintenanceWork["Place"]+world.maintenanceWork["Collect"])/60/days)
    PS_Gui["Hint4"].Text := "Placement + collection travel"
    if !gaps
        verdict := "Every selected nectar stayed above its lower floor after day 7."
    else
        verdict := Format("Individual floor coverage: average {:.1f}% · lowest {:.1f}% ({}).",
            coverageSum/world.groups.Length, lowestCoverage, lowestNectar)
    PS_Gui["Verdict"].Text := verdict
    for _, name in ["View", "Csv", "Details"]
        PS_Gui[name].Enabled := true
    PS_Gui["Period"].Choose(1)
    PS_Redraw()
}

PS_Details(*) {
    global PS_Current, PS_DetailsGui, PS_Gui
    if (!PS_Current || !PS_Current.completed)
        return
    if PS_DetailsGui {
        PS_DetailsGui.Show()
        return
    }
    world := PS_Current, window := world.finish-world.warmup
    detailsWindow := Gui("+Owner" PS_Gui.Hwnd, "Simulation details")
    PS_DetailsGui := detailsWindow
    detailsWindow.BackColor := "F3F6F7", detailsWindow.SetFont("s10 c243E43", "Segoe UI")
    tabs := detailsWindow.AddTab3("x16 y16 w870 h490", ["Nectar results", "Settings and assumptions"])
    tabs.UseTab(1)
    detailsWindow.AddText("x32 y57 w825 h25", "Maintenance metrics cover day 7 through day " world.finish/86400 ". Buildup starts at zero.")
    list := detailsWindow.AddListView("x32 y94 w830 r6 -Multi", ["Nectar", "Min / floor", "Built by", "Floor coverage", "Below floor", "Lowest", "Longest dip"])
    for index, width in [112, 104, 96, 115, 104, 92, 125]
        list.ModifyCol(index, width)
    for _, group in world.groups {
        metric := world.Metrics(group)
        list.Add(, group.nectar, Format("{:g}% / {:g}%", group.minimum, PN_Bounds(0, group.minimum, group.buffer).lower),
            group.firstBuilt < 0 ? "Not reached" : Format("{:.1f} h", group.firstBuilt/3600),
            Format("{:.2f}%", group.covered*100/window), Format("{:.1f} h", metric.below/3600),
            Format("{:.1f}%", group.lowest), Format("{:.1f} h", metric.longest/3600))
    }
    counts := "Collections over the full run: " world.collections.Length "`r`n`r`n"
    for name, count in world.counts
        counts .= StrReplace(name, "Planter") ": " count "`r`n"
    detailsWindow.AddEdit("x32 y283 w830 h200 ReadOnly -Wrap", counts)
    tabs.UseTab(2)
    detailsWindow.AddEdit("x32 y62 w830 h420 ReadOnly", PS_SettingsText(world))
    tabs.UseTab()
    detailsWindow.OnEvent("Close", PS_CloseDetails)
    detailsWindow.OnEvent("Escape", PS_CloseDetails)
    detailsWindow.Show("w902 h522")
}

PS_CloseDetails(*) {
    global PS_DetailsGui
    if PS_DetailsGui
        PS_DetailsGui.Destroy()
    PS_DetailsGui := false
}

PS_RenderPicture(picture, world, mode) {
    global PS_ChartToken
    if !PS_ChartToken
        PS_ChartToken := Gdip_Startup()
    if !PS_ChartToken
        throw Error("Windows could not start the chart renderer.")
    picture.GetPos(,, &width, &height)
    if (width < 300 || height < 160)
        return
    bitmap := PC_Render(world, mode, width, height, A_ScreenDPI/96)
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
    try PS_RenderPicture(PS_Gui["Chart"], PS_Current && PS_Current.completed ? PS_Current : false, PS_Gui["Period"].Value)
    catch as err {
        PS_Gui["Verdict"].Text := "The chart could not be drawn. Run details and CSV results are still available."
        MsgBox err.Message, "Could not draw simulated chart", "Icon!"
    }
}

PS_View(*) {
    global PS_Current, PS_Plot, PS_Gui
    if (!PS_Current || !PS_Current.completed)
        return
    if PS_Plot {
        PS_Plot.gui.Show()
        return
    }
    chartWindow := Gui("+Resize +MinSize800x500 +Owner" PS_Gui.Hwnd, "Nectar charts")
    chartWindow.BackColor := "F3F6F7", chartWindow.SetFont("s10 c243E43", "Segoe UI")
    chartWindow.AddDropDownList("x20 y18 w248 vPeriod Choose1", ["Buildup + maintenance", "Buildup: first five days", "Maintenance: final three days", "Entire run"]).OnEvent("Change", PS_DrawExpanded)
    chartWindow.AddText("x290 y22 w470 h24", "Every selected nectar · lower floors shown in red")
    picture := chartWindow.AddPicture("x20 y62 w1040 h680 +0xE")
    PS_Plot := {gui: chartWindow, picture: picture, world: PS_Current}
    chartWindow.OnEvent("Size", PS_ExpandLayout)
    chartWindow.OnEvent("Close", PS_CloseChart.Bind(PS_Plot))
    chartWindow.OnEvent("Escape", PS_CloseChart.Bind(PS_Plot))
    MonitorGetWorkArea(MonitorGetPrimary(), &l, &t, &r, &b)
    chartWindow.Show("w" Max(800, Min(1280, Floor((r-l-48)/(A_ScreenDPI/96)))) " h" Max(500, Min(900, Floor((b-t-70)/(A_ScreenDPI/96)))))
}

PS_ExpandLayout(gui, state, *) {
    global PS_Plot
    if (state = -1 || !PS_Plot)
        return
    gui.GetClientPos(,, &width, &height)
    PS_Plot.picture.Move(20, 62, width-40, height-82)
    SetTimer PS_DrawExpanded, -100
}

PS_DrawExpanded(*) {
    global PS_Plot
    if !PS_Plot
        return
    try PS_RenderPicture(PS_Plot.picture, PS_Plot.world, PS_Plot.gui["Period"].Value)
    catch as err
        MsgBox err.Message, "Could not draw simulated chart", "Icon!"
}

PS_CloseChart(plot, *) {
    global PS_Plot
    SetTimer PS_DrawExpanded, 0
    if plot.picture
        SetImage(plot.picture.Hwnd, 0)
    plot.gui.Destroy()
    if (PS_Plot = plot)
        PS_Plot := false
}

PS_ExitChart(*) {
    global PS_Plot, PS_Gui, PS_ChartToken
    SetTimer PS_Redraw, 0
    if PS_Plot
        PS_CloseChart(PS_Plot)
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
        buffer: PS_Number(settings, "PlanterBuffer", 10, 0, 20), timings: Map(), types: Map(), fields: Map(), warnings: []}
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
            config.timings[field] := timing
            for _, stats in PS_Tables[field] {
                if !PS_Number(settings, stats[1] "Check", 0, 0, 1)
                    continue
                config.types[stats[1]] := true
                group.candidates.Push({field: field, planter: stats.Clone(), delay: timing.seconds,
                    lead: timing.seconds, dispatchLead: PT_TravelDispatch(timing), tail: 0})
            }
        }
        if !group.candidates.Length
            config.warnings.Push(name " has no enabled field/planter combination.")
        config.groups.Push(group)
    }
    if !config.groups.Length
        throw Error("Select at least one nectar priority in Adaptive Planters.")
    if !config.capacity
        config.warnings.Push("No planter slots are enabled.")
    if (config.types.Has("PaperPlanter") || config.types.Has("TicketPlanter"))
        config.warnings.Push("Paper/Ticket stock is treated as unlimited; usage is counted below and in the CSV.")
    if (sipping || planterGather)
        config.warnings.Push("Gathering bonuses are excluded. Sipping preference holds the selected gathering field fixed (" currentField ").")
    if !PS_Number(settings, "AdaptivePlanterGatherInterrupt", 1, 0, 1)
        config.warnings.Push("Harvest interrupt is disabled. Real collection delays may exceed this preview's timing.")
    return config
}

PS_TimingText(estimate) {
    return estimate.seconds " s (" (estimate.learned ? "learned, " : "fallback, ") estimate.samples " samples)"
}

PS_SettingsText(world) {
    config := world.config
    text := config.types.Count " usable planter types / " config.fields.Count " usable fields across selected nectars / " config.capacity " slots.`r`n"
    text .= "Buffer: " config.buffer "% relative. Nectar readings use the same HUD-sized steps as the live macro. Travel time: automatic per field.`r`n"
    text .= "Uses the first valid timing immediately, then the median of the latest 3 samples. The same travel time is used for placing and collecting; fallback is 90 seconds with no valid samples. Inventory, planter interactions, loot, pre-route reset/setup and extra padding are excluded.`r`n"
    text .= "Selection balances coverage, prolonged gaps, and placement/collection travel. Small coverage gains must justify their travel cost; limited setups can still have gaps.`r`n"
    text .= "Uses base growth tables and starts with zero nectar and empty slots. Learned growth, extra nectar, failures, and interruptions are excluded.`r`n"
    text .= "All floors together measures every selected nectar above its floor at the same time. Individual coverage and longest gaps are shown in Nectar results. Compare these with collections and travel: a dip alone does not make a setup worse.`r`n"
    text .= "Maintenance window: day 7 through day " world.finish/86400 ". All coverage refers to selected nectars.`r`n"
    for _, warning in config.warnings
        text .= warning "`r`n"
    text .= "Shared destination-field travel times:`r`n"
    for field, timing in config.timings
        text .= field ": " PS_TimingText(timing) "`r`n"
    return text
}

PS_ChartPoints(world, index, left, right) {
    points := []
    for _, segment in world.segments {
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
