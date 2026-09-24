; Native full-run chart shared by the simulator and PNG export.
PC_Layout(width, height, count) {
    return {left: 114, top: 48, plotWidth: width-134, rowHeight: (height-76)/Max(1, count)}
}

PC_Report(world, view := 1) {
    report := {left: 0, right: world.finish, built: 0, builtAt: 0, covered: [], all: 0, collections: 0, travel: 0}
    for _, group in world.groups {
        report.covered.Push(0)
        if (group.firstBuilt >= 0)
            report.built++, report.builtAt := Max(report.builtAt, group.firstBuilt)
    }
    boundary := report.built = world.groups.Length ? report.builtAt : world.finish
    if (view = 2)
        report.right := boundary
    else if (view = 3)
        report.left := boundary
    report.span := report.right-report.left
    if !report.span
        return report
    for _, segment in world.segments {
        left := Max(report.left, segment[1]), right := Min(report.right, segment[2]), span := right-left
        if (span <= 0)
            continue
        allGood := span
        for index, group in world.groups {
            value := Max(0, segment[3][index]-(left-segment[1])/864)
            floor := PN_Bounds(0, group.minimum, group.buffer).lower
            good := Min(span, Max(0, (value-floor)*864))
            report.covered[index] += good, allGood := Min(allGood, good)
        }
        report.all += allGood
        if (segment.Length >= 4 && (segment[4] = "Place" || segment[4] = "Collect"))
            report.travel += span
    }
    if world.HasOwnProp("collections")
        for _, collection in world.collections
            if (collection.at > report.left && collection.at <= report.right)
                report.collections++
    return report
}

PC_Metrics(world, report) {
    days := report.span/86400
    return [days ? Format("{:.1f}%", report.all*100/report.span) : "—",
        days ? Format("{:.1f}", report.collections/days) : "—",
        report.built = world.groups.Length ? Format("{:.1f} h", report.builtAt/3600) : report.built " / " world.groups.Length,
        days ? Format("{:.1f} min", report.travel/60/days) : "—"]
}

PC_DrawMetrics(g, width, values) {
    labels := ["ALL FLOORS TOGETHER", "COLLECTIONS / DAY", "BUILT TO TARGET", "TRAVEL / DAY"]
    colors := [0xFF168577, 0xFF3985B6, 0xFF8461B8, 0xFFB78324]
    column := (width-24)/4
    for index, label in labels {
        x := (index-1)*(column+8)
        PC_Fill(g, 0xFFFFFFFF, x, 0, column, 62)
        PC_Fill(g, colors[index], x, 12, 3, 38)
        PC_Text(g, label, x+12, 8, column-24, 16, 8, "FF6A7E89")
        PC_Text(g, values[index], x+12, 26, column-24, 27, 17, "FF243E43", "Bold")
    }
}

PC_Color(nectar) {
    static colors := Map("Comforting", 0xFF19877C, "Motivating", 0xFF8461B8,
        "Satisfying", 0xFFB78324, "Refreshing", 0xFF3985B6, "Invigorating", 0xFFB45E7F)
    return colors.Has(nectar) ? colors[nectar] : 0xFF19877C
}

PC_Text(g, text, x, y, width, height, size := 12, color := "FF52616D", style := "") {
    Gdip_TextToGraphics(g, text, "x" x " y" y " w" width " h" height " s" size " c" color " r4 NoWrap " style, "Segoe UI", width, height)
}

PC_Line(g, color, width, x1, y1, x2, y2, dash := 0) {
    pen := Gdip_CreatePen(color, width)
    if !pen
        throw Error("Could not allocate chart pen.")
    try {
        if dash
            DllCall("gdiplus\GdipSetPenDashStyle", "Ptr", pen, "Int", dash)
        Gdip_DrawLine(g, pen, x1, y1, x2, y2)
    } finally Gdip_DeletePen(pen)
}

PC_Fill(g, color, x, y, width, height) {
    brush := Gdip_BrushCreateSolid(color)
    if !brush
        throw Error("Could not allocate chart fill.")
    try Gdip_FillRectangle(g, brush, x, y, width, height)
    finally Gdip_DeleteBrush(brush)
}

PC_Render(world, width, height, scale := 1, view := 1, includeStats := false) {
    bitmap := 0, g := 0, report := world ? PC_Report(world, view) : false
    try {
        bitmap := Gdip_CreateBitmap(Round(width*scale), Round((height+(includeStats && world ? 74 : 0))*scale))
        if !bitmap
            throw Error("Could not allocate chart image.")
        g := Gdip_GraphicsFromImage(bitmap)
        if !g
            throw Error("Could not draw chart image.")
        Gdip_GraphicsClear(g, 0xFFF1F5F8)
        Gdip_ScaleWorldTransform(g, scale, scale)
        Gdip_SetSmoothingMode(g, 4)
        if (includeStats && world) {
            PC_DrawMetrics(g, width, PC_Metrics(world, report))
            Gdip_TranslateWorldTransform(g, 0, 74)
        }
        panel := Gdip_BrushCreateSolid(0xFFFFFFFF)
        if !panel
            throw Error("Could not allocate chart panel.")
        try Gdip_FillRoundedRectanglePath(g, panel, 0, 0, width, height, 10)
        finally Gdip_DeleteBrush(panel)
        if !world {
            PC_Text(g, "Your nectar, over time", 40, height/2-25, width-80, 28, 16, "FF233A41", "Center Bold")
            PC_Text(g, "Run a simulation to see the complete timeline.", 40, height/2+9, width-80, 22, 10, "FF667781", "Center")
        } else if !report.span {
            PC_Text(g, "No maintenance period yet", 40, height/2-25, width-80, 28, 16, "FF233A41", "Center Bold")
            PC_Text(g, "Every enabled nectar must first reach its upper buffer target.", 40, height/2+9, width-80, 22, 10, "FF667781", "Center")
        } else {
            layout := PC_Layout(width, height, world.groups.Length)
            x := layout.left, w := layout.plotWidth
            PC_Line(g, 0xFFD87770, 1.2, 10, 14, 24, 14, 1)
            PC_Text(g, "Lower floor", 30, 6, 80, 18, 10)
            PC_Line(g, 0xFF9CA8AC, 1, 10, 33, 24, 33, 2)
            PC_Text(g, "Minimum", 30, 25, 80, 18, 10)
            PC_Text(g, view = 2 ? "BUILDUP" : view = 3 ? "MAINTENANCE" : "ALL PHASES", x, 5, w, 18, 10, "FF243E43", "Bold")
            PC_Text(g, Format("{:g}–{:g} h · Stats cover this period", report.left/3600, report.right/3600), x, 23, w, 18, 9)
            for index, group in world.groups {
                y := layout.top+(index-1)*layout.rowHeight
                plotHeight := layout.rowHeight-14, floor := PN_Bounds(0, group.minimum, group.buffer).lower
                color := PC_Color(group.nectar)
                PC_Text(g, group.nectar, 10, y+Max(0, (plotHeight-30)/2), 80, 16, 11, Format("{:08X}", color), "Bold")
                PC_Text(g, Format("{:.0f}% above floor", report.covered[index]*100/report.span),
                    10, y+Max(0, (plotHeight-30)/2)+16, 80, 14, 9)
                PC_Fill(g, 0x08D87770, x, y+plotHeight*(1-floor/100), w, plotHeight*floor/100)
                Loop 5 {
                    gx := x+w*(A_Index-1)/4
                    PC_Line(g, 0xFFEDF1F2, 1, gx, y, gx, y+plotHeight)
                }
                for _, pct in [0, 50, 100]
                    PC_Line(g, 0xFFE7ECEE, 1, x, y+plotHeight*(1-pct/100), x+w, y+plotHeight*(1-pct/100))
                PC_Text(g, "100", x-24, y-5, 20, 14, 9, "FF87949B", "Right")
                PC_Text(g, "0", x-24, y+plotHeight-8, 20, 14, 9, "FF87949B", "Right")
                points := []
                for _, point in PC_Points(world, index, report.left, report.right)
                    points.Push([x+w*(point[1]-report.left)/report.span, y+plotHeight*(1-point[2]/100)])
                if (points.Length > 1) {
                    area := points.Clone()
                    area.InsertAt(1, [points[1][1], y+plotHeight])
                    area.Push([points[-1][1], y+plotHeight])
                    brush := Gdip_BrushCreateSolid((color & 0xFFFFFF) | 0x12000000)
                    pen := Gdip_CreatePen(color, 1.5)
                    try {
                        if (!brush || !pen)
                            throw Error("Could not allocate nectar curve resources.")
                        Gdip_SetClipRect(g, x, y, w, plotHeight)
                        Gdip_FillPolygon(g, brush, area)
                        if Gdip_DrawLines(g, pen, points)
                            throw Error("Could not draw nectar curve.")
                    } finally {
                        Gdip_ResetClip(g)
                        if brush
                            Gdip_DeleteBrush(brush)
                        if pen
                            Gdip_DeletePen(pen)
                    }
                }
                PC_Line(g, 0xFF9CA8AC, 1, x, y+plotHeight*(1-group.minimum/100), x+w, y+plotHeight*(1-group.minimum/100), 2)
                PC_Line(g, 0xFFD87770, 1.1, x, y+plotHeight*(1-floor/100), x+w, y+plotHeight*(1-floor/100), 1)
                if (index = world.groups.Length)
                    Loop 5 {
                        tick := A_Index
                        PC_Text(g, Format("{:g} h", (report.left+report.span*(tick-1)/4)/3600),
                            x+w*(tick-1)/4-(tick = 1 ? 0 : tick = 5 ? 56 : 28), y+plotHeight+6, 56, 18, 9,
                            "FF6F7F87", tick = 1 ? "" : tick = 5 ? "Right" : "Center")
                    }
            }
        }
        native := Gdip_CreateHBITMAPFromBitmap(bitmap)
        if !native
            throw Error("Could not display chart image.")
        return native
    } finally {
        if g
            Gdip_DeleteGraphics(g)
        if bitmap
            Gdip_DisposeImage(bitmap)
    }
}

PC_SavePng(native, path) {
    if !native
        throw Error("Run a simulation before saving its chart.")
    bitmap := Gdip_CreateBitmapFromHBITMAP(native)
    if !bitmap
        throw Error("Could not read the displayed chart.")
    try {
        if Gdip_SaveBitmapToFile(bitmap, path)
            throw Error("Could not save the PNG file.")
    } finally Gdip_DisposeImage(bitmap)
}

PC_Points(world, index, left, right) {
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
        if (segment[1] >= right) {
            if (segment[1] = right)
                points.Push([right, segment[3][index]])
            break
        }
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
    if (right = world.now && points.Length)
        points.Push([right, world.groups[index].level])
    return points
}
