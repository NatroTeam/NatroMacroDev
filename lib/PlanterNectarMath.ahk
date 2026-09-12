; Forecast nectar and harvest times. Time is seconds; nectar is percentage points.
PN_Sort(items, column := 0) {
    Loop items.Length {
        i := A_Index
        while (i > 1 && (column ? items[i][column] < items[i-1][column] : items[i] < items[i-1])) {
            previous := items[i-1], items[i-1] := items[i], items[i] := previous
            i--
        }
    }
    return items
}

PN_Forecast(current, events, seconds) {
    level := Min(100, Max(0, current)), previous := 0
    for _, event in PN_Sort(events.Clone(), 1) {
        t := Max(0, event[1])
        if (t > seconds)
            break
        level := Min(100, Max(0, level - (t - previous)/864) + Max(0, event[2]))
        previous := t
    }
    return Max(0, level - Max(0, seconds - previous)/864)
}

PN_FloorTime(current, events, floorPercent) {
    level := Min(100, Max(0, current)), previous := 0
    for _, event in PN_Sort(events.Clone(), 1) {
        t := Max(0, event[1])
        crossing := previous + Max(0, level - floorPercent)*864
        if (crossing < t)
            return crossing
        level := Min(100, Max(0, level - (t-previous)/864) + Max(0, event[2]))
        previous := t
    }
    return previous + Max(0, level - floorPercent)*864
}

PN_Bounds(current, minimum, buffer) {
    band := minimum * Min(20, Max(0, buffer))/100
    upper := Min(100, minimum+band)
    return {lower: Max(0, minimum-band), upper: upper}
}

PN_RecoveryNeedsFullGrowth(current, minimum, buffer) {
    bounds := PN_Bounds(current, minimum, buffer)
    return current < bounds.lower && minimum-bounds.lower < 100/38
}

PN_UsefulSeconds(rate, fullSeconds, minimum, buffer) {
    fullSeconds := Max(1, Round(fullSeconds))
    if (rate <= 0)
        return fullSeconds
    points := Max(Min(100, minimum*(1+Min(20, Max(0, buffer))/100))-minimum, 100/38)
    return Min(fullSeconds, Max(1, Ceil(points/rate)))
}

PN_TargetTime(current, events, rate, fullSeconds, target, earliest) {
    boundaries := [earliest, fullSeconds]
    for _, event in events
        if (event[1] > earliest && event[1] < fullSeconds)
            boundaries.Push(event[1])
    PN_Sort(boundaries)
    left := earliest
    for _, right in boundaries {
        if (PN_Forecast(current, events, left)+rate*left >= target)
            return left
        if (PN_Forecast(current, events, right)+rate*right >= target) {
            lo := left, hi := right
            Loop 40 {
                mid := (lo+hi)/2
                if (PN_Forecast(current, events, mid)+rate*mid >= target)
                    hi := mid
                else
                    lo := mid
            }
            return Min(fullSeconds, Ceil(hi))
        }
        left := right
    }
    return fullSeconds
}

PN_Interval(current, events, rate, fullSeconds, minimum, buffer, buildToFull, deliveryDelay := 0) {
    fullSeconds := Max(1, Round(fullSeconds))
    if (rate <= 0 || buildToFull || PN_RecoveryNeedsFullGrowth(current, minimum, buffer))
        return fullSeconds
    bounds := PN_Bounds(current, minimum, buffer)
    protected := PN_MaintenanceFloor(minimum, buffer)
    usefulAt := PN_UsefulSeconds(rate, fullSeconds, minimum, buffer)
    floorTime := Max(0, PN_FloorTime(current, events, protected)-Max(0, deliveryDelay))
    if (floorTime >= usefulAt)
        return Max(1, Min(fullSeconds, Floor(floorTime)))
    hardFloorTime := Max(0, PN_FloorTime(current, events, bounds.lower)-Max(0, deliveryDelay))
    pixelAt := Min(fullSeconds, Max(1, Ceil((100/38)/rate)))
    if (hardFloorTime >= Min(usefulAt, pixelAt))
        return Max(1, Min(fullSeconds, Floor(hardFloorTime)))
    recovery := PN_TargetTime(current, events, rate, fullSeconds, bounds.upper, usefulAt)
    restored := PN_Forecast(current, events, recovery)
    if (restored >= minimum) {
        later := []
        for _, event in events
            if (event[1] > recovery)
                later.Push([event[1]-recovery, event[2]])
        recovery += Max(0, PN_FloorTime(restored, later, protected)-Max(0, deliveryDelay))
    }
    return Max(1, Min(fullSeconds, recovery))
}

PN_MaintenanceFloor(minimum, buffer) {
    return Max(0, minimum*(1-0.75*Min(20, Max(0, buffer))/100))
}

PN_CandidateKey(candidate) {
    stats := candidate.planter
    delay := candidate.HasOwnProp("delay") ? candidate.delay : 0
    lead := candidate.HasOwnProp("lead") ? candidate.lead : 0
    dispatch := candidate.HasOwnProp("dispatchLead") ? candidate.dispatchLead : lead
    return Format("{:.17g}|{:.17g}|{:.17g}|{:.17g}|{:.17g}", stats[2]*stats[3]/864, stats[4], delay, lead, dispatch)
}

PN_CandidatePlans(current, events, candidates, minimum, buffer, buildToFull, candidateKeys := false) {
    plans := [], calculations := Map(), arrivals := Map(), levels := Map()
    lower := PN_Bounds(current, minimum, buffer).lower
    for _, candidate in candidates {
        stats := candidate.planter
        key := candidateKeys && candidateKeys.Has(candidate) ? candidateKeys[candidate] : PN_CandidateKey(candidate)
        if !calculations.Has(key) {
            rate := stats[2]*stats[3]/864
            delay := candidate.HasOwnProp("delay") ? candidate.delay : 0
            if !arrivals.Has(delay) {
                later := []
                for _, event in events
                    if (event[1] > delay)
                        later.Push([event[1]-delay, event[2]])
                arrivals[delay] := later, levels[delay] := PN_Forecast(current, events, delay)
            }
            lead := candidate.HasOwnProp("lead") ? candidate.lead : 0
            dispatch := candidate.HasOwnProp("dispatchLead") ? candidate.dispatchLead : lead
            growth := PN_Interval(levels[delay], arrivals[delay], rate, stats[4]*3600,
                minimum, buffer, buildToFull, Max(0, lead-dispatch))
            growth := Max(growth, lead), seconds := delay+growth
            if !levels.Has(seconds)
                levels[seconds] := PN_Forecast(current, events, seconds)
            amount := rate*Min(growth, stats[4]*3600)
            calculations[key] := {growth: growth, seconds: seconds, useful: Min(amount, Max(0, 100-levels[seconds]))}
        }
        value := calculations[key]
        plans.Push({field: candidate.field, planter: stats, seconds: value.seconds, growth: value.growth,
            building: buildToFull, useful: value.useful, lower: lower})
    }
    return plans
}

PN_NeedBefore(candidate, best) {
    if !best
        return true
    if (candidate.urgency != best.urgency)
        return candidate.urgency < best.urgency
    return candidate.priority < best.priority
}
