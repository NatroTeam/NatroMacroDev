pd_CheckView(hwnd, clientW, clientH) {
	if (!hwnd || GetRobloxHWND() != hwnd || !WinActive("ahk_id " hwnd))
		return false
	width := 0, height := 0
	try WinGetClientPos(, , &width, &height, "ahk_id " hwnd)
	return (width = clientW && height = clientH)
}

pd_Walk(tiles, key, secondKey, hwnd, clientW, clientH) {
	while (tiles > 0.001) {
		if !pd_CheckView(hwnd, clientW, clientH)
			return false
		step := Min(3, tiles)
		nm_Walk(step, key, secondKey)
		tiles -= step
	}
	return pd_CheckView(hwnd, clientW, clientH)
}

pd_BloomOffset(targetX, targetY, originX, originY, vfX, vfY, vrX, vrY) {
	dx := originX - targetX, dy := originY - targetY
	det := vfX * vrY - vfY * vrX
	return {fwd: (dx * vrY - dy * vrX) / det, right: (vfX * dy - vfY * dx) / det}
}

pd_ApproachBloom(chromaObj, hwnd, clientX, clientY, clientW, clientH,
	targetX, targetY, originX, originY, vfX, vfY, vrX, vrY) {
	global FwdKey, BackKey, LeftKey, RightKey
	trip := {arrived: false, interrupted: false, route: []}
	if !pd_IsCalibrationUsable(vfX, vfY, vrX, vrY)
		return trip
	heldKey := ""
	try {
	Loop 12 {
		offset := pd_BloomOffset(targetX, targetY, originX, originY, vfX, vfY, vrX, vrY)
		if (Max(Abs(offset.fwd), Abs(offset.right)) <= 0.5) {
			trip.arrived := true
			return trip
		}
		forward := Abs(offset.fwd) >= Abs(offset.right)
		amount := forward ? offset.fwd : offset.right
		signedTiles := Max(-3, Min(3, amount))
		key := forward ? (amount > 0 ? FwdKey : BackKey) : (amount > 0 ? RightKey : LeftKey)
		undo := forward ? (amount > 0 ? BackKey : FwdKey) : (amount > 0 ? LeftKey : RightKey)
		shiftX := signedTiles * (forward ? vfX : vrX)
		shiftY := signedTiles * (forward ? vfY : vrY)
		keepMoving := Abs(amount) > 4
		step := pd_ApproachStep(Abs(signedTiles), key, keepMoving, &heldKey, hwnd, clientW, clientH)
		if !step.ok {
			trip.interrupted := true
			return trip
		}
		trip.route.Push({tiles: Abs(signedTiles), undo: undo})
		loc := pd_LocatePointsFromClient(chromaObj, clientX, clientY, clientW, clientH)
		coast := heldKey != "" ? Max(0, pd_MovementTick() - step.finished) * step.rate : 0
		capturedCoast := HasProp(loc, "captured") ? Min(coast, Max(0, loc.captured - step.finished) * step.rate) : 0
		if coast {
			trip.route.Push({tiles: coast, undo: undo})
			if pd_MovementTick() - step.finished > 200 {
				pd_ReleaseApproach(&heldKey)
				return trip
			}
		}
		if !pd_CheckView(hwnd, clientW, clientH) {
			trip.interrupted := true
			return trip
		}
		if !pd_IsLocateStatusOk(loc.status)
			return trip
		expectedX := targetX + shiftX + (amount > 0 ? capturedCoast : -capturedCoast) * (forward ? vfX : vrX)
		expectedY := targetY + shiftY + (amount > 0 ? capturedCoast : -capturedCoast) * (forward ? vfY : vrY)
		distance := Sqrt(shiftX * shiftX + shiftY * shiftY)
		match := pd_FindNearestToTarget(loc.points, expectedX, expectedY, Max(3, clientH * 0.006, distance * 0.25))
		if !match.found {
			remaining := pd_BloomOffset(expectedX, expectedY, originX, originY, vfX, vfY, vrX, vrY)
			previous := pd_FindNearestToOrigin(loc.points, targetX, targetY)
			next := pd_FindNearestToOrigin(loc.points, expectedX, expectedY)
			tolerance := Max(3, clientH * 0.006, distance * 0.25)
			trip.arrived := Max(Abs(remaining.fwd), Abs(remaining.right)) <= 0.5
				&& (!previous.found || previous.d2 > tolerance * tolerance)
				&& (!next.found || next.d2 > tolerance * tolerance)
			return trip
		}
		if ((match.x - targetX) * shiftX + (match.y - targetY) * shiftY < distance * distance * 0.25)
			return trip
		remainingCoast := coast - capturedCoast
		targetX := match.x + (amount > 0 ? remainingCoast : -remainingCoast) * (forward ? vfX : vrX)
		targetY := match.y + (amount > 0 ? remainingCoast : -remainingCoast) * (forward ? vfY : vrY)
	}
	offset := pd_BloomOffset(targetX, targetY, originX, originY, vfX, vfY, vrX, vrY)
	trip.arrived := Max(Abs(offset.fwd), Abs(offset.right)) <= 0.5
	return trip
	} catch {
		return trip
	} finally pd_ReleaseApproach(&heldKey)
}

pd_PublishCalibState(ready, vfX, vfY, vrX, vrY, vfSign, vrSign) {
	if !(IsSet(__petalCalibParentHwnd) && __petalCalibParentHwnd)
		return
	payload := "NMPCAL|" ((ready + 0) ? 1 : 0) "|" Round(vfX, 6) "|" Round(vfY, 6) "|" Round(vrX, 6) "|" Round(vrY, 6) "|" ((vfSign < 0) ? -1 : 1) "|" ((vrSign < 0) ? -1 : 1)
	cds := Buffer(A_PtrSize*3, 0)
	NumPut("UPtr", 0, cds, 0)
	NumPut("UInt", (StrLen(payload) + 1) * 2, cds, A_PtrSize)
	NumPut("Ptr", StrPtr(payload), cds, A_PtrSize*2)
	try DllCall("SendMessageW", "Ptr", __petalCalibParentHwnd, "UInt", 0x004A, "Ptr", A_ScriptHwnd, "Ptr", cds.Ptr, "Ptr")
}
pd_IsLocateStatusOk(status) {
	return ((status = 0) || (status = 4))
}

pd_GetChromaConfigBase(clientH := 1080) {
	scale := clientH / 1080
	return {
		yellowHueRanges: [[16, 32]],
		yellowSatRange: [50, 150],
		yellowValRange: [85, 255],
		morphOpenIterations: Max(1, Round(2 * scale)),
		morphCloseIterations: Max(1, Round(3 * scale)),
		dilateIterations: 1,
		minBlobArea: Max(20, Round(250 * scale * scale)),
		maxBlobArea: Max(800, Round(8000 * scale * scale)),
		minCircularity: 0.80,
		minCenterFillRatio: 0.43,
		requirePetalContext: 2,
		ringInnerRadiusPercent: 105,
		ringOuterRadiusPercent: 200,
		petalSatRange: [0, 255],
		petalValRange: [60, 255],
		greenHueRanges: [[52, 68], [24, 48]],
		minPetalRatio: 0.42,
		drawRejectedCandidates: false
	}
}

pd_LocatePointsFromClient(chromaObj, clientX, clientY, clientW, clientH) {
	try {
	if (!(hwnd := GetRobloxHWND()) || !WinActive("ahk_id " hwnd))
		return { status: -1, written: 0, points: [] }
	width := 0, height := 0
	try WinGetClientPos(&clientX, &clientY, &width, &height, "ahk_id " hwnd)
	if (width != clientW || height != clientH)
		return { status: -1, written: 0, points: [] }
	inset := Round(clientH * 0.12)
	captureStarted := pd_MovementTick()
	pBM := Gdip_BitmapFromScreen(clientX "|" (clientY + inset) "|" clientW "|" (clientH - inset * 2))
	captured := (captureStarted + pd_MovementTick()) / 2
	if (!pBM || pBM = -1)
		return { status: -1, written: 0, points: [] }
	try hBmp := Gdip_CreateHBITMAPFromBitmap(pBM)
	finally Gdip_DisposeImage(pBM)
	if !hBmp
		return { status: -1, written: 0, points: [] }
	try result := chromaObj.LocateHBitmap(hBmp)
	finally DeleteObject(hBmp)
	result.captured := captured
	for point in result.points
		point.y += inset
	return result
	} catch {
		return {status: -1, written: 0, points: []}
	}
}

pd_FindNearestToOrigin(points, originX, originY, excluded := 0) {
	if IsObject(excluded) {
		i := excluded.Length
		while (i > 0) {
			if A_TickCount >= excluded[i].until
				excluded.RemoveAt(i)
			i--
		}
	}
	if (points.Length <= 0)
		return { found: 0, index: -1, x: 0, y: 0, d2: 0.0 }

	bestIdx := -1
	bestD2 := 1.0e30
	bestX := 0
	bestY := 0

	for i, p in points {
		skip := false
		if IsObject(excluded) {
			for blocked in excluded {
				if ((p.x - blocked.x)**2 + (p.y - blocked.y)**2 <= blocked.radius**2) {
					skip := true
					break
				}
			}
		}
		if skip
			continue
		idx := i - 1
		px := p.x
		py := p.y
		dx := px - originX
		dy := py - originY
		d2 := (dx * dx) + (dy * dy)
		if (d2 < bestD2) {
			bestD2 := d2
			bestIdx := idx
			bestX := px
			bestY := py
		}
	}

	return { found: (bestIdx >= 0) ? 1 : 0, index: bestIdx, x: bestX, y: bestY, d2: bestD2 }
}

pd_FindNearestToTarget(points, targetX, targetY, maxDistance) {
	if (points.Length <= 0)
		return { found: 0, x: 0, y: 0, shiftX: 0.0, shiftY: 0.0, d2: 0.0 }

	bestD2 := 1.0e30
	secondD2 := 1.0e30
	bestX := 0
	bestY := 0

	for _, p in points {
		px := p.x
		py := p.y
		tdx := px - targetX
		tdy := py - targetY
		d2 := (tdx * tdx) + (tdy * tdy)
		if (d2 < bestD2) {
			secondD2 := bestD2
			bestD2 := d2
			bestX := px
			bestY := py
		} else if (d2 < secondD2)
			secondD2 := d2
	}

	if (bestD2 > maxDistance * maxDistance || secondD2 <= Max(9, bestD2 * 2.25))
		return { found: 0, x: 0, y: 0, shiftX: 0.0, shiftY: 0.0, d2: 0.0 }

	return {
		found: 1,
		x: bestX,
		y: bestY,
		shiftX: bestX - targetX,
		shiftY: bestY - targetY,
		d2: bestD2
	}
}

pd_IsCalibrationUsable(vfX, vfY, vrX, vrY) {
	f2 := vfX * vfX + vfY * vfY
	r2 := vrX * vrX + vrY * vrY
	det := vfX * vrY - vfY * vrX
	return (f2 >= 1 && r2 >= 1 && det * det >= f2 * r2 * 0.0625)
}

pd_ConfirmCalibrationReturn(chromaObj, clientX, clientY, clientW, clientH, targetX, targetY, shiftX, shiftY) {
	loc := pd_LocatePointsFromClient(chromaObj, clientX, clientY, clientW, clientH)
	if (!pd_IsLocateStatusOk(loc.status) || !loc.written)
		return false
	match := pd_FindNearestToTarget(loc.points, targetX, targetY, Max(3, Sqrt(shiftX * shiftX + shiftY * shiftY) * 0.15))
	return match.found
}

pd_CalibrateVectors(chromaObj, clientX, clientY, clientW, clientH, calibTiles, targetX, targetY, originX, originY) {
	global FwdKey, BackKey, LeftKey, RightKey

	hwnd := GetRobloxHWND()
	failed := {ready: false, vfX: 0, vfY: 0, vrX: 0, vrY: 0, vfSign: 1, vrSign: 1}
	foundF := 0
	foundR := 0
	shiftFx := 0.0
	shiftFy := 0.0
	shiftRx := 0.0
	shiftRy := 0.0
	vfX := 0.0
	vfY := 0.0
	vrX := 0.0
	vrY := 0.0
	vfSign := 1
	vrSign := 1
	ready := 0

	dxTarget := targetX - originX
	dyTarget := targetY - originY
	fwdMoveKey := (dyTarget <= 0) ? FwdKey : BackKey
	fwdUndoKey := (dyTarget <= 0) ? BackKey : FwdKey
	rightMoveKey := (dxTarget <= 0) ? LeftKey : RightKey
	rightUndoKey := (dxTarget <= 0) ? RightKey : LeftKey
	vfSign := (fwdMoveKey = FwdKey) ? 1 : -1
	vrSign := (rightMoveKey = RightKey) ? 1 : -1

	if !pd_Walk(calibTiles, fwdMoveKey, 0, hwnd, clientW, clientH)
		return failed
	Sleep 80
	locF := pd_LocatePointsFromClient(chromaObj, clientX, clientY, clientW, clientH)
	if (pd_IsLocateStatusOk(locF.status) && (locF.written > 0)) {
		matchF := pd_FindNearestToTarget(locF.points, targetX, targetY, Min(clientW, clientH) / 4)
		if (matchF.found) {
			foundF := 1
			shiftFx := matchF.shiftX
			shiftFy := matchF.shiftY
		}
	}
	if !pd_Walk(calibTiles, fwdUndoKey, 0, hwnd, clientW, clientH)
		return failed
	Sleep 60
	foundF := foundF && shiftFx * shiftFx + shiftFy * shiftFy >= calibTiles * calibTiles
	if foundF
		foundF := pd_ConfirmCalibrationReturn(chromaObj, clientX, clientY, clientW, clientH, targetX, targetY, shiftFx, shiftFy)

	if !foundF
		return failed

	if !pd_Walk(calibTiles, rightMoveKey, 0, hwnd, clientW, clientH)
		return failed
	Sleep 80
	locR := pd_LocatePointsFromClient(chromaObj, clientX, clientY, clientW, clientH)
	if (pd_IsLocateStatusOk(locR.status) && (locR.written > 0)) {
		matchR := pd_FindNearestToTarget(locR.points, targetX, targetY, Min(clientW, clientH) / 4)
		if (matchR.found) {
			foundR := 1
			shiftRx := matchR.shiftX
			shiftRy := matchR.shiftY
		}
	}
	if !pd_Walk(calibTiles, rightUndoKey, 0, hwnd, clientW, clientH)
		return failed
	Sleep 60
	if foundR
		foundR := pd_ConfirmCalibrationReturn(chromaObj, clientX, clientY, clientW, clientH, targetX, targetY, shiftRx, shiftRy)

	if (foundF && foundR) {
		vfX := (shiftFx / calibTiles) * vfSign
		vfY := (shiftFy / calibTiles) * vfSign
		vrX := (shiftRx / calibTiles) * vrSign
		vrY := (shiftRy / calibTiles) * vrSign
		ready := pd_IsCalibrationUsable(vfX, vfY, vrX, vrY)
	}

	return {
		ready: ready,
		vfX: vfX,
		vfY: vfY,
		vrX: vrX,
		vrY: vrY,
		vfSign: vfSign,
		vrSign: vrSign
	}
}

pd_CollectPetals(hwnd, width, height) {
    global FwdKey, BackKey, LeftKey, RightKey
    for keys in [[FwdKey], [BackKey, RightKey], [BackKey, LeftKey], [FwdKey, LeftKey], [FwdKey, RightKey], [BackKey]] {
        if !pd_Walk(5, keys[1], keys.Length > 1 ? keys[2] : 0, hwnd, width, height)
            return false
    }
    return true
}

pd_ReturnFromBloom(route, hwnd, width, height) {
    Loop route.Length {
        step := route[route.Length - A_Index + 1]
        if !pd_Walk(step.tiles, step.undo, 0, hwnd, width, height)
            return false
    }
    return true
}

pd_ReleaseApproach(&key) {
    if key != ""
        Send "{" key " up}"
    key := ""
}

pd_ApproachStep(tiles, key, keepMoving, &heldKey, hwnd, width, height) {
    if !pd_CheckView(hwnd, width, height)
        return {ok: false}
    if heldKey != key {
        pd_ReleaseApproach(&heldKey)
        Send "{" key " down}"
        heldKey := key
    }
    started := pd_MovementTick()
    Walk(tiles)
    finished := pd_MovementTick()
    if !keepMoving
        pd_ReleaseApproach(&heldKey)
    return {ok: pd_CheckView(hwnd, width, height), finished: finished, rate: tiles / Max(1, finished - started)}
}

pd_MovementTick() {
    global __bloomPauseElapsed
    return A_TickCount - (IsSet(__bloomPauseElapsed) ? __bloomPauseElapsed : 0)
}
