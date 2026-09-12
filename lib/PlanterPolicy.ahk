; Save travel timing, growth observations, and planter decisions.
#Include "PlanterPolicyMath.ahk"
#Include "PlanterTiming.ahk"

PT_RecordTravel(field, seconds) {
    if (!IsNumber(seconds) || seconds < 1 || seconds > 1800)
        return false
    key := StrReplace(field, " ") "_Travel"
    samples := []
    for _, value in StrSplit(IniRead("settings\nm_config.ini", "PlanterTiming", key, ""), "|")
        if (IsNumber(value) && value >= 1 && value <= 1800)
            samples.Push(Number(value))
    samples.Push(Round(seconds, 3))
    while (samples.Length > 3)
        samples.RemoveAt(1)
    record := ""
    for _, value in samples
        record .= (record = "" ? "" : "|") value
    IniWrite record, "settings\nm_config.ini", "PlanterTiming", key
    return true
}

PT_TravelEstimate(field) {
    record := IniRead("settings\nm_config.ini", "PlanterTiming", StrReplace(field, " ") "_Travel", "")
    return PT_TimingEstimate(record)
}

PT_Seconds(field, kind := "Travel") {
    return kind = "Tail" ? 0 : PT_TravelEstimate(field).seconds
}

PT_DispatchLead(field) {
    return PT_TravelDispatch(PT_TravelEstimate(field))
}

PG_SaveModel(slot, stats, field) {
    IniWrite stats[1] "|" field "|" stats[2] "|" stats[3] "|" stats[4],
        "settings\nm_config.ini", "Planters", "PlanterModel" slot
}

PG_EffectiveStats(slot, name, field) {
    parts := StrSplit(IniRead("settings\nm_config.ini", "Planters", "PlanterModel" slot, ""), "|")
    if (parts.Length = 5 && parts[1] = name && parts[2] = field
        && IsNumber(parts[3]) && IsNumber(parts[4]) && IsNumber(parts[5])
        && parts[3] > 0 && parts[4] > 0 && parts[5] > 0)
        return [name, Number(parts[3]), Number(parts[4]), Number(parts[5])]
    return ba_GetPlanterStats(name, field)
}

PG_AdaptiveStats(stats, field) {
    return PG_AdaptiveModel(stats, field).stats
}

PG_AdaptiveModel(stats, field) {
    parts := StrSplit(IniRead("settings\nm_config.ini", "PlanterCalibration", stats[1] "_" StrReplace(field, " "), ""), "|")
    if (parts.Length != 3 || !IsNumber(parts[1]) || !IsNumber(parts[2]) || !IsNumber(parts[3])
        || parts[2] < 2 || nowUnix()-parts[3] > 604800)
        return {stats: stats.Clone(), trusted: false}
    factor := Min(2, Max(0.5, Number(parts[1])))
    return {stats: [stats[1], stats[2], stats[3]*factor, stats[4]/factor], trusted: true}
}

PG_Observe(slot, name, field, progress, at) {
    if (progress <= 0 || progress >= 0.98)
        return false
    key := "PlanterObservation" slot
    previous := StrSplit(IniRead("settings\nm_config.ini", "Planters", key, ""), "|")
    sample := name "|" field "|" at "|" progress
    if (previous.Length != 4 || previous[1] != name || previous[2] != field
        || !IsNumber(previous[3]) || !IsNumber(previous[4])) {
        IniWrite sample, "settings\nm_config.ini", "Planters", key
        return false
    }
    elapsed := at-previous[3], change := progress-previous[4]
    if (elapsed < 300 || change < 0.05) {
        if (elapsed < 0 || change < -0.03)
            IniWrite sample, "settings\nm_config.ini", "Planters", key
        return false
    }
    IniWrite sample, "settings\nm_config.ini", "Planters", key
    stats := ba_GetPlanterStats(name, field)
    factor := stats[4]*3600*change/elapsed
    if (factor < 0.5 || factor > 2)
        return false
    key := name "_" StrReplace(field, " ")
    learned := StrSplit(IniRead("settings\nm_config.ini", "PlanterCalibration", key, ""), "|")
    mean := 1, count := 0
    if (learned.Length = 3 && IsNumber(learned[1]) && IsNumber(learned[2]) && IsNumber(learned[3]) && at-learned[3] <= 604800)
        mean := Min(2, Max(0.5, Number(learned[1]))), count := Max(0, Number(learned[2]))
    mean := count ? 0.75*mean+0.25*factor : factor
    IniWrite mean "|" Min(100, count+1) "|" at, "settings\nm_config.ini", "PlanterCalibration", key
    return true
}

PG_Intent(slot, name, field, phase := unset, full := false) {
    key := "PlanterIntent" slot
    if IsSet(phase) {
        IniWrite name "|" field "|" phase "|" (full ? 1 : 0), "settings\nm_config.ini", "Planters", key
        return {phase: phase, full: full}
    }
    parts := StrSplit(IniRead("settings\nm_config.ini", "Planters", key, ""), "|")
    return parts.Length = 4 && parts[1] = name && parts[2] = field
        ? {phase: parts[3], full: parts[4] = "1"} : {phase: "Build", full: true}
}

PT_Log(kind, slot, field, identity, predicted, observed, detail) {
    try {
        path := "settings\planter-observations.tsv"
        if (FileExist(path) && FileGetSize(path) > 1048576)
            FileMove path, path ".previous", true
        FileAppend nowUnix() "`t" kind "`t" slot "`t" field "`t" identity "`t" predicted "`t" observed "`t" detail "`n", path, "UTF-8"
    } catch {
        return false
    }
    return true
}
