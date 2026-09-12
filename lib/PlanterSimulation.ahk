; Offline simulation using the live planter scheduling helpers.
class PS_World {
    __New(config, days := 14) {
        this.planning := PN_PlanningState()
        this.config := config, this.finish := days*86400, this.now := 0
        this.warmup := 7*86400, this.active := []
        this.groups := [], this.segments := [], this.collections := []
        this.counts := Map(), this.decisions := 0, this.covered := 0
        this.work := Map("Place", 0, "Collect", 0, "Tail", 0)
        this.maintenanceWork := this.work.Clone()
        this.maintenanceCollections := 0, this.maximumBand := 0, this.completed := false
        for _, original in config.groups {
            group := original.Clone()
            group.level := 0, group.phase := "Build", group.lastField := ""
            group.firstBuilt := -1, group.covered := 0
            group.lowest := 100, group.collected := 0
            group.shortfall := 0, group.dip := 0, group.longestDip := 0
            this.groups.Push(group)
            this.maximumBand := Max(this.maximumBand, group.minimum*group.buffer/100)
        }
    }

    Observed(group) {
        return Round(Floor(group.level*38/100+0.000000001)*100/38)
    }

    Group(nectar) {
        for _, group in this.groups
            if (group.nectar = nectar)
                return group
        throw Error("Unknown simulated nectar: " nectar)
    }

    Advance(at, action := "") {
        at := Min(this.finish, at)
        if (at < this.now)
            throw Error("Simulation time moved backwards.")
        if (at = this.now)
            return
        levels := [], span := at-this.now
        left := Max(this.now, this.warmup), window := Max(0, at-left), allGood := window
        if (action != "") {
            this.work[action] += span
            this.maintenanceWork[action] += window
        }
        for _, group in this.groups {
            levels.Push(group.level)
            if window {
                value := Max(0, group.level-(left-this.now)/864)
                finish := Max(0, value-window/864)
                floor := PN_Bounds(value, group.minimum, group.buffer).lower
                good := Min(window, Max(0, (value-floor)*864))
                group.covered += good, allGood := Min(allGood, good)
                group.lowest := Min(group.lowest, finish)
                below := window-good
                if (value >= floor)
                    group.dip := 0
                group.dip += below
                group.longestDip := Max(group.longestDip, group.dip)
                zeroAt := Min(window, value*864)
                if (zeroAt > good)
                    group.shortfall += (Max(0, floor-value+good/864)+Max(0, floor-value+zeroAt/864))*(zeroAt-good)/2
                group.shortfall += floor*Max(0, window-value*864)
            }
            group.level := Max(0, group.level-span/864)
        }
        this.covered += allGood
        this.segments.Push([this.now, at, levels]), this.now := at
    }

    Metrics(group) {
        window := this.finish-this.warmup, floor := PN_Bounds(0, group.minimum, group.buffer).lower
        below := Max(0, window-group.covered)
        return {below: below, worst: Max(0, floor-group.lowest), longest: group.longestDip,
            average: below > 0.000001 ? group.shortfall/below : 0}
    }

    Events(nectar) {
        events := []
        for _, job in PN_ServiceQueue(this.active, this.now)
            if (job.nectar = nectar)
                events.Push([job.at-this.now, PN_JobYield(job, job.at)])
        return events
    }

    Context() {
        result := []
        for _, group in this.groups {
            current := this.Observed(group)
            group.phase := PN_Phase(group.phase, current, group.minimum, group.buffer)
            copy := group.Clone(), copy.current := current, copy.events := this.Events(group.nectar)
            result.Push(copy)
        }
        return result
    }

    Choice() {
        active := []
        for _, job in this.active {
            copy := job.Clone(), copy.start -= this.now, copy.due -= this.now
            active.Push(copy)
        }
        return PN_SelectPlan(this.Context(), active,
            this.config.capacity-this.active.Length, this.maximumBand, this.planning, this.now)
    }

    Collect(job) {
        this.Advance(job.at, "Collect")
        group := this.Group(job.nectar), before := group.level
        amount := PN_JobYield(job, job.at), group.level := Min(100, before+amount)
        if (group.firstBuilt < 0 && group.level >= 97)
            group.firstBuilt := this.now
        group.collected++
        if (this.now >= this.warmup)
            this.maintenanceCollections++
        name := job.planter[1]
        this.counts[name] := (this.counts.Has(name) ? this.counts[name] : 0)+1
        this.collections.Push({at: this.now, nectar: job.nectar, field: job.field, name: name,
            age: this.now-job.start, full: job.planter[4]*3600, amount: amount,
            before: before, after: group.level, phase: job.phase, slot: job.slot,
            minimum: group.minimum, floor: PN_Bounds(0, group.minimum, group.buffer).lower})
        for index, existing in this.active
            if (existing.slot = job.slot) {
                this.active.RemoveAt(index)
                break
            }
        this.Advance(this.now+job.tail, "Tail")
    }

    Place(selected) {
        group := this.Group(selected.nectar), pair := false
        for _, candidate in PN_Eligible(group, this.active, group.phase)
            if (candidate.field = selected.field && candidate.planter[1] = selected.planter[1]) {
                pair := candidate
                break
            }
        if !pair
            return false
        if (this.now+pair.delay > this.finish) {
            this.Advance(this.finish)
            return false
        }
        this.Advance(this.now+pair.delay, "Place")
        current := this.Observed(group)
        group.phase := PN_Phase(group.phase, current, group.minimum, group.buffer)
        stats := pair.planter
        age := PN_Interval(current, this.Events(group.nectar), stats[2]*stats[3]/864,
            stats[4]*3600, group.minimum, group.buffer, group.phase = "Build", Max(0, pair.lead-pair.dispatchLead))
        used := Map()
        for _, existing in this.active
            used[existing.slot] := true
        slot := 1
        while used.Has(slot)
            slot++
        job := {slot: slot, nectar: group.nectar, field: pair.field, planter: stats,
            start: this.now, due: this.now+age, phase: group.phase, fullIntent: age >= Round(stats[4]*3600),
            lead: pair.lead, tail: pair.tail, dispatchLead: pair.dispatchLead}
        this.active.Push(job), group.lastField := pair.field
        this.Protect(job)
        this.Batch(job)
        return true
    }

    Protect(job) {
        relative := [], selected := false
        for _, active in this.active {
            copy := active.Clone(), copy.start -= this.now, copy.due -= this.now
            relative.Push(copy)
            if (copy.slot = job.slot)
                selected := copy
        }
        selected.normal := this.planning.normal
        context := this.Context()
        for _, group in context
            if (group.nectar = this.planning.omit)
                group.candidates := []
        job.due := this.now+PN_ReleaseDeadline(selected, context, relative)
        job.fullIntent := job.due-job.start >= Round(job.planter[4]*3600)
    }

    Batch(newJob) {
        Loop 3 {
            slot := A_Index, old := false
            for _, job in this.active
                if (job.slot = slot)
                    old := job
            if (!old || old.slot = newJob.slot || old.due <= newJob.due || old.due >= newJob.due+600)
                continue
            group := false
            for _, candidateGroup in this.groups
                if (candidateGroup.nectar = old.nectar)
                    group := candidateGroup
            if !group
                continue
            age := newJob.due-old.start, stats := old.planter
            if (age < PN_UsefulSeconds(stats[2]*stats[3]/864, stats[4]*3600, group.minimum, group.buffer)
                || (old.fullIntent && age < Round(stats[4]*3600)))
                continue
            checks := [], original := old.due
            for _, other in this.groups
                checks.Push({group: other, before: this.Events(other.nectar)})
            old.due := newJob.due
            try {
                for _, check in checks
                    check.after := this.Events(check.group.nectar)
            } finally {
                old.due := original
            }
            safe := true
            for _, check in checks {
                horizon := Max(newJob.due, original)-this.now+Max(14400, Round(stats[4]*3600))
                for _, events in [check.before, check.after]
                    for _, event in events
                        horizon := Max(horizon, event[1]+14400)
                g := check.group
                if !PN_NoWorseFloor(this.Observed(g), check.before, check.after,
                    PN_Bounds(g.level, g.minimum, g.buffer).lower, horizon) {
                    safe := false
                    break
                }
            }
            if safe
                old.due := newJob.due
        }
    }

    Step() {
        if (this.now >= this.finish) {
            this.completed := true
            return
        }
        if (++this.decisions > 100000)
            throw Error("Simulation exceeded its event limit. Try a shorter duration.")
        queue := PN_ServiceQueue(this.active, this.now)
        if (queue.Length && queue[1].depart <= this.now && queue[1].at <= this.finish) {
            this.Collect(queue[1])
            return
        }
        if (this.active.Length < this.config.capacity) {
            choice := this.Choice()
            if choice {
                before := this.active.Length
                for _, plan in choice.plans
                    this.Place(plan)
                if (this.active.Length > before)
                    return
            }
        }
        queue := PN_ServiceQueue(this.active, this.now)
        wake := queue.Length && queue[1].at <= this.finish ? queue[1].depart : this.finish
        if (this.active.Length < this.config.capacity && this.config.capacity > 0)
            wake := Min(wake, this.now+300)
        this.Advance(Max(this.now+1, wake))
    }
}
