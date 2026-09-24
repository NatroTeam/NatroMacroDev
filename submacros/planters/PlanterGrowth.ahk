; Persist planter growth for scheduling and timer edits.
PG_Yield(stats, start, at) {
    return Max(0, Min(stats[4]*3600, at-start)) * stats[2]*stats[3]/864
}

PG_Save(slot, name, field, start, source := "placed") {
    if (source = "placed" || source = "user-added-age-unknown") {
        for _, key in ["PlanterModel", "PlanterIntent", "PlanterObservation"]
            IniWrite "", "settings\nm_config.ini", "Planters", key slot
    } else if (source = "reconnect-paused" || source = "glitter-estimated")
        IniWrite "", "settings\nm_config.ini", "Planters", "PlanterObservation" slot
    IniWrite name "|" field "|" Round(start) "|" source,
        "settings\nm_config.ini", "Planters", "PlanterGrowth" slot
    return start
}

PG_Start(slot, name, field, deadline, estimate, now) {
    raw := IniRead("settings\nm_config.ini", "Planters", "PlanterGrowth" slot, "")
    parts := StrSplit(raw, "|")
    if (parts.Length >= 3 && parts[1] = name && parts[2] = field && IsNumber(parts[3]))
        return Min(now, Number(parts[3]))
    stats := ba_GetPlanterStats(name, field)
    interval := estimate > 0 ? Min(stats[4]*3600, estimate*864/(stats[2]*stats[3])) : 0
    if (!interval && IniRead("settings\nm_config.ini", "Planters", "PlanterHarvestFull" slot, "") = "Full")
        interval := stats[4]*3600
    start := interval > 0 && deadline < 2147483647 ? Min(now, deadline-interval) : now
    return PG_Save(slot, name, field, start, "legacy-inferred")
}

PG_TimerYield(slot, deadline, now) {
    name := IniRead("settings\nm_config.ini", "Planters", "PlanterName" slot, "None")
    field := IniRead("settings\nm_config.ini", "Planters", "PlanterField" slot, "None")
    if (name = "None" || field = "None")
        return 0
    oldDeadline := IniRead("settings\nm_config.ini", "Planters", "PlanterHarvestTime" slot, 2147483647)
    estimate := IniRead("settings\nm_config.ini", "Planters", "PlanterEstPercent" slot, 0)
    start := PG_Start(slot, name, field, oldDeadline, estimate, now)
    return Round(PG_Yield(PG_EffectiveStats(slot, name, field), start, Max(now, deadline)), 1)
}

ba_GetPlanterStats(planterName, fieldName){
	global BambooPlanters, BlueFlowerPlanters, CactusPlanters, CloverPlanters, CoconutPlanters, DandelionPlanters, MountainTopPlanters, MushroomPlanters, PepperPlanters
		, PineTreePlanters, PineapplePlanters, PumpkinPlanters, RosePlanters, SpiderPlanters, StrawberryPlanters, StumpPlanters, SunflowerPlanters
	if (planterName="None" || fieldName="None")
		return [planterName, 1, 1, 1]
	tempFieldName := StrReplace(fieldName, " ", "")
	if !IsSet(%tempFieldName%Planters)
		return [planterName, 1, 1, 1]
	for i, v in %tempFieldName%Planters {
		if (v[1] = planterName)
			return v
	}
	return [planterName, 1, 1, 1]
}
