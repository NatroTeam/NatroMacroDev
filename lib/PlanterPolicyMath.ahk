; Build, maintenance, and collection scheduling rules.
PN_Phase(previous, current, minimum, buffer) {
    if (current < 0)
        return previous
    if (previous != "Build" && previous != "Maintain" && previous != "Recover")
        previous := "Build"
    bounds := PN_Bounds(current, minimum, buffer)
    if (previous = "Build" || previous = "Recover")
        return current >= bounds.upper ? "Maintain" : previous
    return current < bounds.lower ? "Recover" : "Maintain"
}

PN_NoWorseFloor(current, oldEvents, newEvents, lower, horizon) {
    points := [0, horizon]
    for _, events in [oldEvents, newEvents]
        for _, event in events
            if (event[1] >= 0 && event[1] <= horizon)
                points.Push(event[1], Max(0, event[1]-0.001))
    boundaries := PN_Sort(points.Clone())
    for index, start in boundaries {
        finish := index < boundaries.Length ? boundaries[index+1] : horizon
        for _, events in [oldEvents, newEvents] {
            level := PN_Forecast(current, events, start)
            for _, threshold in [lower, 0] {
                crossing := start+Max(0, level-threshold)*864
                if (crossing > start && crossing < finish)
                    points.Push(crossing)
            }
        }
    }
    for _, t in points
        if (Max(0, lower-PN_Forecast(current, newEvents, t)) > Max(0, lower-PN_Forecast(current, oldEvents, t))+0.0001)
            return false
    return true
}

PN_ServiceQueue(active, clock := 0) {
    ordered := []
    for _, job in active {
        item := job.Clone(), pos := 1
        while (pos <= ordered.Length && ordered[pos].due <= item.due)
            pos++
        ordered.InsertAt(pos, item)
    }
    freeAt := clock
    for _, job in ordered {
        dispatchLead := job.HasOwnProp("dispatchLead") ? job.dispatchLead : job.lead
        job.depart := Max(freeAt, job.due-dispatchLead)
        job.at := Max(job.due, job.depart+job.lead)
        freeAt := job.at+job.tail
    }
    return ordered
}
