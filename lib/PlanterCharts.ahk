; Native buildup and maintenance charts for the simulator.
PC_Layout(width, height, count) {
    return {left: 114, top: 48, gap: 32,
        plotWidth: (width-160)/2, rowHeight: (height-76)/Max(1, count)}
}

PC_Windows(world) {
    return [[0, Min(world.finish, 72*3600), "BUILDUP", "First 72 hours"],
        [Max(0, world.finish-72*3600), world.finish, "MAINTENANCE", "Final 72 hours"]]
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

PC_Render(world, width, height, scale := 1) {
    bitmap := 0, g := 0
    try {
        bitmap := Gdip_CreateBitmap(Round(width*scale), Round(height*scale))
        if !bitmap
            throw Error("Could not allocate chart image.")
        g := Gdip_GraphicsFromImage(bitmap)
        if !g
            throw Error("Could not draw chart image.")
        Gdip_GraphicsClear(g, 0xFFF1F5F8)
        Gdip_ScaleWorldTransform(g, scale, scale)
        Gdip_SetSmoothingMode(g, 4)
        panel := Gdip_BrushCreateSolid(0xFFFFFFFF)
        if !panel
            throw Error("Could not allocate chart panel.")
        try Gdip_FillRoundedRectanglePath(g, panel, 0, 0, width, height, 10)
        finally Gdip_DeleteBrush(panel)
        if !world {
            PC_Text(g, "Your nectar, over time", 40, height/2-25, width-80, 28, 16, "FF233A41", "Center Bold")
            PC_Text(g, "Run a simulation to see buildup and maintenance together.", 40, height/2+9, width-80, 22, 10, "FF667781", "Center")
        } else {
            layout := PC_Layout(width, height, world.groups.Length)
            windows := PC_Windows(world)
            PC_Line(g, 0xFFD87770, 1.2, 10, 14, 24, 14, 1)
            PC_Text(g, "Lower floor", 30, 6, 80, 18, 10)
            PC_Line(g, 0xFF9CA8AC, 1, 10, 33, 24, 33, 2)
            PC_Text(g, "Minimum", 30, 25, 80, 18, 10)
            for col, window in windows {
                x := layout.left+(col-1)*(layout.plotWidth+layout.gap)
                PC_Text(g, window[3], x, 5, layout.plotWidth, 18, 10, "FF243E43", "Bold")
                PC_Text(g, window[4], x, 23, layout.plotWidth, 18, 9)
            }
            for index, group in world.groups {
                y := layout.top+(index-1)*layout.rowHeight
                plotHeight := layout.rowHeight-14, floor := PN_Bounds(0, group.minimum, group.buffer).lower
                color := PC_Color(group.nectar)
                PC_Text(g, group.nectar, 10, y+Max(0, (plotHeight-30)/2), 80, 16, 11, Format("{:08X}", color), "Bold")
                PC_Text(g, Format("{:.0f}% above floor", group.covered*100/(world.finish-world.warmup)),
                    10, y+Max(0, (plotHeight-30)/2)+16, 80, 14, 9)
                for col, window in windows {
                    left := window[1], right := window[2]
                    x := layout.left+(col-1)*(layout.plotWidth+layout.gap), w := layout.plotWidth
                    PC_Fill(g, 0x08D87770, x, y+plotHeight*(1-floor/100), w, plotHeight*floor/100)
                    Loop 4 {
                        gx := x+w*(A_Index-1)/3
                        PC_Line(g, 0xFFEDF1F2, 1, gx, y, gx, y+plotHeight)
                    }
                    for _, pct in [0, 50, 100]
                        PC_Line(g, 0xFFE7ECEE, 1, x, y+plotHeight*(1-pct/100), x+w, y+plotHeight*(1-pct/100))
                    PC_Text(g, "100", x-24, y-5, 20, 14, 9, "FF87949B", "Right")
                    PC_Text(g, "0", x-24, y+plotHeight-8, 20, 14, 9, "FF87949B", "Right")
                    points := []
                    for _, point in PS_ChartPoints(world, index, left, right)
                        points.Push([x+w*(point[1]-left)/(right-left), y+plotHeight*(1-point[2]/100)])
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
                        Loop 4 {
                            tick := A_Index
                            PC_Text(g, Format("{:g} h", (left+(right-left)*(A_Index-1)/3)/3600),
                                x+w*(tick-1)/3-(tick = 1 ? 0 : tick = 4 ? 56 : 28), y+plotHeight+6, 56, 18, 9,
                                "FF6F7F87", tick = 1 ? "" : tick = 4 ? "Right" : "Center")
                        }
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
