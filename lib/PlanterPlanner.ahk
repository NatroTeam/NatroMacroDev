; Compare maintenance and recovery plans using the same growth, travel, and HUD model as the simulator.
class PN_PlanningState {
    __New() {
        this.gaps := Map(), this.mode := false, this.normal := false, this.omit := ""
    }

    Observe(groups, now) {
        previousGaps := this.gaps, this.gaps := Map()
        for _, group in groups {
            key := group.nectar, floor := PN_Bounds(group.current, group.minimum, group.buffer).lower
            signature := group.minimum "|" group.buffer
            previous := previousGaps.Has(key) ? previousGaps[key] : false
            age := 0
            if (previous && previous.signature = signature && group.current < floor) {
                elapsed := Max(0, now-previous.at)
                age := previous.value >= floor ? Max(0, elapsed-(previous.value-floor)*864) : previous.age+elapsed
            }
            this.gaps[key] := {age: age, at: now, value: group.current, signature: signature}
        }
    }
}

PN_SelectPlan(groups, active, slots, maximumBand := 0, state := false, now := 0) {
    if (slots <= 0 || !groups.Length)
        return false
    if !state
        state := PN_PlanningState()
    state.Observe(groups, now), state.omit := ""
    initial := PN_RawPlan(groups, active, slots, maximumBand, state.mode)
    if !initial
        initial := PN_RawPlan(groups, active, slots, maximumBand)
    if !initial
        return false
    uncovered := false
    for _, group in groups {
        floor := PN_Bounds(group.current, group.minimum, group.buffer).lower
        if (group.current >= floor)
            continue
        pending := false
        for _, event in group.events
            if (PN_Forecast(group.current, group.events, Max(0, event[1])) >= floor) {
                pending := true
                break
            }
        if !pending
            uncovered := true
    }
    if !uncovered
        return initial
    baseline := PN_Preview(groups, active, slots, maximumBand, false, "", 96, true)
    if (baseline && PN_Stable(baseline.world, 72*3600)) {
        state.mode := false, state.normal := true
        return baseline.first
    }
    best := false, bestScore := false, chosenMode := false, chosenOmit := ""
    choices := [{focus: false, omit: ""}, {focus: true, omit: ""}]
    for _, group in groups
        if group.candidates.Length
            choices.Push({focus: true, omit: group.nectar})
    support := PN_SupportLimit(groups, Min(3, active.Length+slots))
    for _, choice in choices {
        preview := PN_Preview(groups, active, slots, maximumBand, choice.focus, choice.omit, 48)
        if !preview
            continue
        score := PN_PreviewScore(preview.world, state, support)
        if (!bestScore || PN_PreviewBefore(score, bestScore)) {
            best := preview.first, bestScore := score, chosenMode := choice.focus, chosenOmit := choice.omit
        }
    }
    if best {
        state.mode := chosenMode, state.normal := false, state.omit := chosenOmit
        return best
    }
    return initial
}

PN_Preview(groups, active, slots, maximumBand, focus, omit, hours, normal := false) {
    world := PN_PlanningWorld(groups, active, Min(3, active.Length+slots), hours, focus, omit, normal)
    world.maximumBand := maximumBand
    first := world.Choice()
    if !first
        return false
    for _, plan in first.plans
        world.Place(plan)
    Loop 4096 {
        if (world.now >= world.finish)
            return {world: world, first: first}
        world.Step()
    }
    return false
}

PN_Stable(world, start) {
    for index, group in world.groups {
        covered := 0, floor := PN_Bounds(0, group.minimum, group.buffer).lower
        for _, segment in world.segments {
            left := Max(start, segment[1]), span := Max(0, segment[2]-left)
            value := Max(0, segment[3][index]-(left-segment[1])/864)
            covered += Min(span, Max(0, (value-floor)*864))
        }
        if (covered < world.finish-start-1)
            return false
    }
    return true
}

PN_SupportLimit(groups, capacity) {
    types := Map(), rates := [], production := 0
    for _, group in groups
        for _, candidate in group.candidates {
            stats := candidate.planter, name := stats[1], rate := stats[2]*stats[3]
            types[name] := Max(types.Has(name) ? types[name] : 0, rate)
        }
    for _, rate in types
        rates.Push(rate)
    PN_Sort(rates)
    Loop Min(capacity, rates.Length)
        production += rates[rates.Length-A_Index+1]
    return Min(Max(1, groups.Length-1), Max(1, Floor(production)))
}

PN_PreviewScore(world, state, support) {
    horizon := world.finish, count := world.groups.Length, weights := [], ages := [], total := 0
    for index, group in world.groups {
        weight := (count-index+1)**0.25, total += weight, weights.Push(weight)
        ages.Push(state.gaps[group.nectar].age)
    }
    utility := 0, terminal := 0
    for _, segment in world.segments {
        span := segment[2]-segment[1], covered := []
        for index, group in world.groups {
            floor := PN_Bounds(0, group.minimum, group.buffer).lower
            good := Min(span, Max(0, (segment[3][index]-floor)*864)), covered.Push(good)
            if good
                ages[index] := 0
            below := span-good, gap := ages[index]*below+below*below/2
            ages[index] += below
            utility += weights[index]*count/total*(good/horizon-2*gap/horizon**2)
        }
        PN_Sort(covered)
        utility += count*covered[count-support+1]/horizon
    }
    for index, group in world.groups
        terminal += weights[index]*count/total*Min(group.level, group.minimum)/100
    travel := world.work["Place"]+world.work["Collect"]
    utility -= count*travel/horizon
    return {utility: utility, terminal: terminal, collections: world.collections.Length}
}

PN_PreviewBefore(candidate, previous) {
    if (candidate.utility != previous.utility)
        return candidate.utility > previous.utility
    if (candidate.terminal != previous.terminal)
        return candidate.terminal > previous.terminal
    return candidate.collections < previous.collections
}

class PN_PlanningWorld extends PS_World {
    __New(groups, active, capacity, hours, focus, omit, normal) {
        super.__New({groups: groups, capacity: capacity}, hours/24)
        this.focus := focus, this.planning.normal := normal
        for index, group in this.groups {
            original := groups[index]
            group.level := Round(original.current*38/100)*100/38
            group.phase := original.phase, group.lastField := original.lastField
            if (group.nectar = omit)
                group.candidates := []
        }
        for _, job in active {
            copy := job.Clone()
            if !copy.HasOwnProp("fullIntent")
                copy.fullIntent := copy.phase = "Build" || copy.due-copy.start >= Round(copy.planter[4]*3600)
            this.active.Push(copy)
        }
    }

    Choice() {
        return PN_RawPlan(this.Context(), this.active,
            this.config.capacity-this.active.Length, this.maximumBand, this.focus)
    }

    Collect(job) {
        for _, group in this.groups
            if (group.nectar = job.nectar) {
                super.Collect(job)
                return
            }
        this.Advance(job.at, "Collect")
        for index, existing in this.active
            if (existing.slot = job.slot) {
                this.active.RemoveAt(index)
                break
            }
        this.Advance(this.now+job.tail, "Tail")
    }
}
