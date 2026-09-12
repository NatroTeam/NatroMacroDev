; Native nectar charts shared by the simulator dashboard and expanded view.
PC_Layout(width, height, count, overview) {
    columns := overview ? 2 : 1, gap := 36, left := 156, right := 20
    return {left: left, top: 62, gap: gap, columns: columns,
        plotWidth: (width-left-right-gap*(columns-1))/columns,
        rowHeight: (height-94)/Max(1, count)}
}

PC_Windows(world, mode) {
    if (mode = 1)
        return [[0, Min(world.finish, 72*3600), "BUILDUP", "First 72 hours"],
            [Max(0, world.finish-72*3600), world.finish, "MAINTENANCE", "Final 72 hours"]]
    if (mode = 2)
        return [[0, Min(world.finish, 120*3600), "BUILDUP", "First five days"]]
    if (mode = 3)
        return [[Max(0, world.finish-72*3600), world.finish, "MAINTENANCE", "Final 72 hours"]]
    return [[0, world.finish, "FULL RUN", "Hours since simulation start"]]
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

PC_Render(world, mode, width, height, scale := 1) {
    bitmap := 0, g := 0
    try {
        bitmap := Gdip_CreateBitmap(Round(width*scale), Round(height*scale))
        if !bitmap
            throw Error("Could not allocate chart image.")
        g := Gdip_GraphicsFromImage(bitmap)
        if !g
            throw Error("Could not draw chart image.")
        Gdip_GraphicsClear(g, 0xFFFFFFFF)
        Gdip_ScaleWorldTransform(g, scale, scale)
        Gdip_SetSmoothingMode(g, 4)
        if !world {
            PC_Text(g, "Your nectar, over time", 40, height/2-32, width-80, 36, 23, "FF233A41", "Center Bold")
            PC_Text(g, "Run a simulation to see buildup and maintenance together.", 40, height/2+10, width-80, 26, 13, "FF667781", "Center")
        } else {
            layout := PC_Layout(width, height, world.groups.Length, mode = 1)
            windows := PC_Windows(world, mode)
            PC_Line(g, 0xFFD87770, 1.2, 16, 17, 32, 17, 1)
            PC_Text(g, "Lower floor", 38, 8, 102, 21, 11)
            PC_Line(g, 0xFF9CA8AC, 1, 16, 38, 32, 38, 2)
            PC_Text(g, "Your minimum", 38, 29, 110, 21, 11)
            for col, window in windows {
                x := layout.left+(col-1)*(layout.plotWidth+layout.gap)
                PC_Text(g, window[3], x, 7, layout.plotWidth, 20, 12, "FF243E43", "Bold")
                PC_Text(g, window[4], x, 29, layout.plotWidth, 20, 11)
            }
            for index, group in world.groups {
                y := layout.top+(index-1)*layout.rowHeight
                plotHeight := layout.rowHeight-16, floor := PN_Bounds(0, group.minimum, group.buffer).lower
                color := PC_Color(group.nectar)
                PC_Text(g, group.nectar, 16, y+Max(0, (plotHeight-34)/2), 123, 18, 13, Format("{:08X}", color), "Bold")
                PC_Text(g, Format("Floor {:g}%", floor), 16, y+Max(0, (plotHeight-34)/2)+18, 123, 16, 11)
                for col, window in windows {
                    left := window[1], right := window[2]
                    x := layout.left+(col-1)*(layout.plotWidth+layout.gap), w := layout.plotWidth
                    PC_Fill(g, 0x0FD87770, x, y+plotHeight*(1-floor/100), w, plotHeight*floor/100)
                    Loop 4 {
                        gx := x+w*(A_Index-1)/3
                        PC_Line(g, 0xFFEDF1F2, 1, gx, y, gx, y+plotHeight)
                    }
                    for _, pct in [0, 50, 100]
                        PC_Line(g, 0xFFE7ECEE, 1, x, y+plotHeight*(1-pct/100), x+w, y+plotHeight*(1-pct/100))
                    PC_Text(g, "100", x-28, y-6, 23, 16, 9, "FF87949B", "Right")
                    PC_Text(g, "0", x-28, y+plotHeight-9, 23, 16, 9, "FF87949B", "Right")
                    points := []
                    for _, point in PS_ChartPoints(world, index, left, right)
                        points.Push([x+w*(point[1]-left)/(right-left), y+plotHeight*(1-point[2]/100)])
                    if (points.Length > 1) {
                        area := points.Clone()
                        area.InsertAt(1, [points[1][1], y+plotHeight])
                        area.Push([points[-1][1], y+plotHeight])
                        brush := Gdip_BrushCreateSolid((color & 0xFFFFFF) | 0x19000000)
                        pen := Gdip_CreatePen(color, 1.7)
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
                        Loop 4
                            PC_Text(g, Format("{:g} h", (left+(right-left)*(A_Index-1)/3)/3600),
                                x+w*(A_Index-1)/3-28, y+plotHeight+8, 56, 22, 10, "FF6F7F87", "Center")
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
