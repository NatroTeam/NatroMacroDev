#Include BloomMovement.ahk

; Scanning never sends input. Pending detours run at a movement polling point.
class BloomGather {
    __New() {
        this.busy := false, this.pending := 0, this.previous := 0, this.nextTrip := 0
        this.view := "", this.chroma := 0
        this.timer := ObjBindMethod(this, "Scan")
    }

    Start() {
        SetTimer(this.timer, 500)
    }

    Scan(*) {
        if this.busy || A_TickCount < this.nextTrip || !GetKeyState("F14")
            return
        hwnd := GetRobloxHWND()
        if !hwnd || !WinActive("ahk_id " hwnd) {
            this.pending := this.previous := 0
            return
        }
        try {
            WinGetClientPos(&x, &y, &w, &h, "ahk_id " hwnd)
            if w <= 0 || h <= 0
                return
            context := hwnd "|" w "|" h
            if !this.chroma
                this.chroma := Chroma(A_ScriptDir "/lib/ChromaAhk.dll")
            if context != this.view {
                this.pending := this.previous := 0
                result := this.chroma.SetActiveConfig(pd_GetChromaConfigBase(h))
                if result.status
                    throw Error(result.error)
                this.view := context
            }
            loc := pd_LocatePointsFromClient(this.chroma, x, y, w, h)
            if !pd_IsLocateStatusOk(loc.status)
                return
            target := pd_FindNearestToOrigin(loc.points, (w - 1) / 2, (h - 1) / 2)
            if !target.found || target.d2 > (h * 0.22)**2 {
                this.pending := this.previous := 0
                return
            }
            if IsObject(this.previous) && (target.x - this.previous.x)**2 + (target.y - this.previous.y)**2 < (h * 0.12)**2
                this.pending := {x: target.x, y: target.y, hwnd: hwnd, w: w, h: h, time: A_TickCount}
            this.previous := target
        } catch {
            this.pending := this.previous := 0
            this.nextTrip := A_TickCount + 5000
        }
    }

    Poll() {
        global FwdKey, BackKey, LeftKey, RightKey
        if this.busy || !IsObject(this.pending)
            return 0
        target := this.pending, this.pending := 0
        if A_TickCount - target.time > 750 || !pd_CheckView(target.hwnd, target.w, target.h)
            return 0
        if GetKeyState("RButton") || GetKeyState("Space")
            return 0
        this.busy := true, held := []
        DllCall("QueryPerformanceCounter", "Int64*", &begin := 0)
        try {
            for key in [FwdKey, BackKey, LeftKey, RightKey] {
                if GetKeyState(key) {
                    held.Push(key)
                    Send "{" key " up}"
                }
            }
            this.Visit(target)
        } catch {
            this.nextTrip := A_TickCount + 5000
        } finally {
            for key in [FwdKey, BackKey, LeftKey, RightKey]
                Send "{" key " up}"
            if !pd_CheckView(target.hwnd, target.w, target.h)
                ExitApp 0
            for key in held
                Send "{" key " down}"
            this.pending := this.previous := 0
            this.nextTrip := Max(this.nextTrip, A_TickCount + 15000)
            this.busy := false
        }
        DllCall("QueryPerformanceCounter", "Int64*", &finish := 0)
        return finish - begin
    }

    Visit(target) {
        hwnd := target.hwnd, w := target.w, h := target.h
        WinGetClientPos(&x, &y, , , "ahk_id " hwnd)
        ox := Round((w - 1) / 2), oy := Round((h - 1) / 2)
        loc := pd_LocatePointsFromClient(this.chroma, x, y, w, h)
        match := pd_FindNearestToTarget(loc.points, target.x, target.y, h * 0.1)
        if !pd_IsLocateStatusOk(loc.status) || !match.found
            return
        Sleep 60
        loc := pd_LocatePointsFromClient(this.chroma, x, y, w, h)
        confirmed := pd_FindNearestToTarget(loc.points, match.x, match.y, Max(3, h * 0.006))
        if !pd_IsLocateStatusOk(loc.status) || !confirmed.found
            return
        calib := pd_CalibrateVectors(this.chroma, x, y, w, h, 3, confirmed.x, confirmed.y, ox, oy)
        if !calib.ready
            return
        loc := pd_LocatePointsFromClient(this.chroma, x, y, w, h)
        match := pd_FindNearestToTarget(loc.points, confirmed.x, confirmed.y, Max(3, h * 0.006))
        if !pd_IsLocateStatusOk(loc.status) || !match.found
            return
        offset := pd_BloomOffset(match.x, match.y, ox, oy, calib.vfX, calib.vfY, calib.vrX, calib.vrY)
        if Abs(offset.fwd) + Abs(offset.right) > 10
            return
        trip := pd_ApproachBloom(this.chroma, hwnd, x, y, w, h, match.x, match.y, ox, oy, calib.vfX, calib.vfY, calib.vrX, calib.vrY)
        if trip.arrived {
            Sleep 250
            pd_CollectPetals(hwnd, w, h)
        }
        if !trip.interrupted
            pd_ReturnFromBloom(trip.route, hwnd, w, h)
    }
}

pd_PatternSleep(ms) {
    if ms < 0
        Sleep ms
    else
        HyperSleep(ms)
}
