; Polar, Bucko and Riley publish quest state only after a complete, consistent read.
nm_ReadQuest(giver, quests) {
    nm_setShiftLock(0)
    nm_OpenMenu("questlog")
    try {
        reader := QuestReader(giver, quests)
        result := reader.Read()
        if result.state = "unreadable"
            nm_setStatus("Quest", giver " quest could not be read; keeping the last result")
        return result
    } catch as err {
        nm_setStatus("Quest", giver " quest could not be read: " err.Message)
        return {state: "unreadable"}
    }
}

class QuestReader {
    __New(giver, quests) {
        this.images := Map(), this.bitmap := 0, this.quests := quests
        this.markers := giver = "Polar" ? ["polar_bear", "polar_bear2", "polar_bear3"]
            : giver = "Bucko" ? ["bucko", "bucko2"] : ["riley", "riley2"]
        this.hwnd := GetRobloxHWND()
        GetRobloxClientPos(this.hwnd)
        this.width := windowWidth, this.height := windowHeight
        this.top := GetYOffset(this.hwnd) + 150, this.bottom := this.height - 20
        if this.width < 350 || this.bottom - this.top < 200
            throw Error("Quest panel is too small")
    }

    __Delete() {
        if this.HasOwnProp("bitmap") && this.bitmap
            Gdip_DisposeImage(this.bitmap)
        if this.HasOwnProp("images")
            for name, bitmap in this.images
                Gdip_DisposeImage(bitmap)
    }

    Capture() {
        global bitmaps
        if !this.hwnd || !WinActive("ahk_id " this.hwnd)
            throw Error("Roblox is not active")
        GetRobloxClientPos(this.hwnd)
        if windowWidth != this.width || windowHeight != this.height
            throw Error("Roblox was resized")
        MouseMove windowX + 350, windowY + GetYOffset(this.hwnd) + 100
        if this.bitmap
            Gdip_DisposeImage(this.bitmap), this.bitmap := 0
        this.bitmap := Gdip_BitmapFromScreen(windowX "|" windowY "|310|" this.height)
        if !this.bitmap
            throw Error("Quest capture failed")
        if Gdip_ImageSearch(this.bitmap, bitmaps["questlog"], , 0, this.top - 78, 310, this.top + 2, 2) != 1
            throw Error("Quest panel is not open")
    }

    Find(name, top, bottom, variation := 5) {
        if !this.images.Has(name) {
            bitmap := Gdip_CreateBitmapFromFile(A_WorkingDir "\nm_image_assets\" name ".png")
            if !bitmap
                throw Error("Missing quest image: " name)
            this.images[name] := bitmap
        }
        top := Max(this.top, top), bottom := Min(this.bottom, bottom)
        if bottom <= top
            return 0
        result := Gdip_ImageSearch(this.bitmap, this.images[name], &point, 0, top, 306, bottom, variation)
        if result < 0
            throw Error("Quest image search failed")
        if result = 1 {
            xy := StrSplit(point, ",")
            return {x: xy[1] + 0, y: xy[2] + 0}
        }
        return 0
    }

    ReadPage() {
        global QuestBarSize, QuestBarGapSize, QuestBarInset
        marker := 0
        for name in this.markers {
            marker := this.Find(name, this.top, this.bottom, 50)
            if marker
                break
        }
        if !marker
            return {state: "missing"}
        gap := this.Find("questbargap", marker.y, marker.y + 45)
        if !gap
            return {state: "unreadable"}
        title := ""
        for variation in [5, 10, 25, 50, 100] {
            matches := []
            for name in this.quests
                if this.Find(name, gap.y - 30, gap.y, variation)
                    matches.Push(name)
            if matches.Length > 1
                return {state: "unreadable"}
            if matches.Length = 1 {
                title := matches[1]
                break
            }
        }
        if title = ""
            return {state: "unreadable"}
        rows := [], incomplete := false
        for objective in this.quests[title] {
            y := gap.y + QuestBarSize * (objective[1] - 1)
            if y < this.top || y + QuestBarSize > this.bottom
                return {state: "clipped"}
            rowGap := this.Find("questbargap", y, y + QuestBarGapSize)
            if !rowGap || Abs(rowGap.y - y) > 2
                return {state: "unreadable"}
            samples := []
            for dy in [5, 20, 34]
                samples.Push(Gdip_GetPixel(this.bitmap, QuestBarInset + 6, rowGap.y + QuestBarGapSize + dy) & 0xFFFFFF)
            state := this.Classify(samples)
            if state = "unreadable"
                return {state: "unreadable"}
            rows.Push(state)
            incomplete := incomplete || state = "incomplete"
        }
        return {state: "ready", title: title, rows: rows, incomplete: incomplete}
    }

    static Classify(samples) {
        complete := 0, incomplete := 0
        for color in samples {
            if this.Near(color, 0xF46C55, 8) || this.Near(color, 0x6EFF60, 8)
                incomplete += 1
            else if this.Near(color, 0x8BF48B, 12)
                complete += 1
        }
        if incomplete >= 2 && !complete
            return "incomplete"
        if complete >= 2 && !incomplete
            return "complete"
        return "unreadable"
    }

    Classify(samples) => QuestReader.Classify(samples)

    static Near(color, expected, tolerance) {
        for shift in [0, 8, 16]
            if Abs(((color >> shift) & 255) - ((expected >> shift) & 255)) > tolerance
                return false
        return true
    }

    Confirm(result) {
        Sleep 120
        this.Capture()
        next := this.ReadPage()
        if next.state != "ready" || next.title != result.title || next.rows.Length != result.rows.Length
            return {state: "unreadable"}
        for i, state in result.rows
            if state != next.rows[i]
                return {state: "unreadable"}
        return next
    }

    Scroll(direction) {
        before := Gdip_CloneBitmapArea(this.bitmap, 0, this.top, 306, this.bottom - this.top)
        if !before
            throw Error("Quest scroll capture failed")
        try {
            GetRobloxClientPos(this.hwnd)
            MouseMove windowX + 30, windowY + this.top + 50
            Sleep 50
            SendEvent "{Wheel" direction "}"
            Sleep 200
            this.Capture()
            after := Gdip_CloneBitmapArea(this.bitmap, 0, this.top, 306, this.bottom - this.top)
            if !after
                throw Error("Quest scroll capture failed")
            try result := Gdip_ImageSearch(after, before)
            finally Gdip_DisposeImage(after)
            if result < 0
                throw Error("Quest scroll comparison failed")
            return result != 1
        } finally Gdip_DisposeImage(before)
    }

    Read() {
        this.Capture()
        Loop 2 {
            result := this.ReadPage()
            if result.state = "ready" {
                confirmed := this.Confirm(result)
                if confirmed.state = "ready"
                    return confirmed
            } else {
                Sleep 120
                this.Capture()
            }
        }
        if GetKeyState("F14")
            return {state: "unreadable"}
        stable := 0
        Loop 100 {
            stable := this.Scroll("Up") ? 0 : stable + 1
            if stable >= 2
                break
        }
        if stable < 2
            return {state: "unreadable"}
        stable := 0, sawQuest := false
        Loop 150 {
            result := this.ReadPage()
            sawQuest := sawQuest || result.state != "missing"
            if result.state = "ready" {
                confirmed := this.Confirm(result)
                if confirmed.state = "ready"
                    return confirmed
            }
            if stable >= 2
                return {state: sawQuest ? "unreadable" : "absent"}
            stable := this.Scroll("Down") ? 0 : stable + 1
        }
        return {state: "unreadable"}
    }
}
