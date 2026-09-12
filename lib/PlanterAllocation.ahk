; Choose planter and field combinations across the available slots.
PN_JobYield(job, at) {
    return Max(0, Min(job.planter[4]*3600, at-job.start))*job.planter[2]*job.planter[3]/864
}

PN_Eligible(group, active, phase) {
    allowed := [], rotated := [], sipping := []
    for _, candidate in group.candidates {
        busy := false
        for _, job in active
            if (job.field = candidate.field || job.planter[1] = candidate.planter[1]) {
                busy := true
                break
            }
        if busy
            continue
        allowed.Push(candidate)
        if (candidate.field != group.lastField)
            rotated.Push(candidate)
        if (phase != "Build" && group.sippingField != "" && candidate.field = group.sippingField)
            sipping.Push(candidate)
    }
    return sipping.Length ? sipping : (rotated.Length ? rotated : allowed)
}

PN_TypeOptions(plans) {
    options := [], positions := Map()
    for _, plan in plans {
        key := plan.planter[1]
        if !positions.Has(key) {
            positions[key] := options.Length+1
            options.Push(plan)
        } else {
            index := positions[key], previous := options[index]
            if (plan.useful/plan.growth > previous.useful/previous.growth+0.000000000001)
                options[index] := plan
        }
    }
    return options
}

PN_NeedGroup(group, current, events, candidates, phase, maximumBand := 0) {
    plans := PN_CandidatePlans(current, events, candidates, group.minimum, group.buffer, phase = "Build")
    if !plans.Length
        return false
    reserve := current
    for _, event in events
        reserve += Max(0, event[2])
    target := phase = "Build" ? 100 : Min(100, PN_Bounds(current, group.minimum, group.buffer).lower+2*maximumBand)
    for _, plan in plans {
        plan.nectar := group.nectar, plan.priority := group.priority, plan.phase := phase
        plan.urgency := reserve-target
    }
    options := PN_TypeOptions(plans)
    return {nectar: group.nectar, options: options, best: options[1]}
}

PN_RawPlan(groups, active, slots, maximumBand := 0, concentrated := false) {
    prepared := [], focus := false, threshold := Round(100-100/38)
    for _, group in groups {
        bounds := PN_Bounds(group.current, group.minimum, group.buffer)
        repair := concentrated && (group.phase = "Build" || (group.phase = "Recover" && group.current < bounds.lower))
        target := group.phase = "Build" ? threshold : bounds.upper
        pending := false
        if repair
            for _, event in group.events
                if (PN_Forecast(group.current, group.events, Max(0, event[1])) >= target) {
                    pending := true
                    break
                }
        candidates := PN_Eligible(group, active, group.phase)
        prepared.Push({group: group, candidates: candidates, repair: repair, pending: pending})
        if (repair && !pending && candidates.Length && (!focus || group.priority < focus.priority))
            focus := group
    }
    needs := []
    for _, item in prepared {
        group := item.group
        if (concentrated && item.repair && (item.pending || !focus || group.nectar != focus.nectar))
            continue
        need := PN_NeedGroup(group, group.current, group.events, item.candidates, group.phase, maximumBand)
        if !need
            continue
        if (concentrated && !item.repair) {
            reserve := group.current
            for _, event in group.events
                reserve += Max(0, event[2])
            upper := PN_Bounds(group.current, group.minimum, group.buffer).upper
            for _, plan in need.options
                plan.urgency := reserve-upper-(reserve < upper ? 100 : 0)
        }
        pos := 1
        while (pos <= needs.Length && !PN_NeedBefore(need.best, needs[pos].best))
            pos++
        needs.InsertAt(pos, need)
    }
    return PN_JointAssignment(needs, slots)
}

PN_Assignment(plans, coverage) {
    result := {plans: plans.Clone(), coverage: coverage, production: 0, growth: 0}
    for _, plan in plans {
        result.production += plan.useful/plan.growth
        result.growth += plan.growth
    }
    return result
}

PN_AssignmentBefore(candidate, best) {
    if !best
        return true
    if (candidate.plans.Length != best.plans.Length)
        return candidate.plans.Length > best.plans.Length
    if (candidate.coverage != best.coverage)
        return candidate.coverage > best.coverage
    if (candidate.production != best.production)
        return candidate.production > best.production
    return candidate.growth > best.growth
}

PN_SearchAssignments(groups, index, slots, chosen, types, fields, coverage, &best) {
    if (chosen.Length = slots || index > groups.Length) {
        if chosen.Length {
            proposal := PN_Assignment(chosen, coverage)
            if PN_AssignmentBefore(proposal, best)
                best := proposal
        }
        return
    }
    for _, plan in groups[index].options {
        name := plan.planter[1]
        if (types.Has(name) || fields.Has(plan.field))
            continue
        types[name] := true, fields[plan.field] := true, chosen.Push(plan)
        PN_SearchAssignments(groups, index+1, slots, chosen, types, fields,
            coverage+2**(groups.Length-index), &best)
        chosen.Pop(), types.Delete(name), fields.Delete(plan.field)
    }
    PN_SearchAssignments(groups, index+1, slots, chosen, types, fields, coverage, &best)
}

PN_JointAssignment(groups, slots) {
    slots := Min(3, Max(0, Floor(slots)), groups.Length)
    if !slots
        return false
    best := false
    PN_SearchAssignments(groups, 1, slots, [], Map(), Map(), 0, &best)
    return best
}

PN_ReleaseDeadline(job, groups, active) {
    if (job.phase = "Build")
        return job.due
    others := [], ownMinimum := 0, ownBuffer := 0, ownKnown := false
    for _, other in active
        if (other.slot != job.slot)
            others.Push(other)
    queue := PN_ServiceQueue(active), lag := 0, deadline := job.due
    for _, item in queue
        if (item.slot = job.slot)
            lag := Max(0, item.at-item.due)
    for _, group in groups {
        if (group.nectar = job.nectar) {
            ownMinimum := group.minimum, ownBuffer := group.buffer, ownKnown := true
            continue
        }
        if (group.phase = "Build" || group.current < PN_Bounds(group.current, group.minimum, group.buffer).lower)
            continue
        growing := false
        for _, other in others
            if (other.nectar = group.nectar) {
                growing := true
                break
            }
        if growing
            continue
        needed := 1.0e15
        for _, candidate in PN_Eligible(group, others, group.phase) {
            stats := candidate.planter
            lead := candidate.HasOwnProp("lead") ? candidate.lead : 0
            dispatch := candidate.HasOwnProp("dispatchLead") ? candidate.dispatchLead : lead
            delay := candidate.HasOwnProp("delay") ? candidate.delay : 0
            needed := Min(needed, delay+PN_UsefulSeconds(stats[2]*stats[3]/864,
                stats[4]*3600, group.minimum, group.buffer)+Max(0, lead-dispatch))
        }
        if (needed = 1.0e15)
            continue
        latest := PN_FloorTime(group.current, group.events, PN_MaintenanceFloor(group.minimum, group.buffer))-needed
        if (latest < 0 && (!job.HasOwnProp("normal") || !job.normal))
            continue
        anotherSlot := false
        for _, other in queue
            if (other.slot != job.slot && other.at+other.tail <= latest) {
                anotherSlot := true
                break
            }
        if !anotherSlot
            deadline := Min(deadline, latest-job.tail-lag)
    }
    if !ownKnown
        return job.due
    useful := PN_UsefulSeconds(job.planter[2]*job.planter[3]/864, job.planter[4]*3600, ownMinimum, ownBuffer)
    return Min(job.due, Max(Ceil(job.start+useful), Floor(deadline)))
}
