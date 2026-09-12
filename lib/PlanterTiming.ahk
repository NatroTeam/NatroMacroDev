; Estimate field travel time from the latest completed trips.
PT_TimingEstimate(record) {
    fallback := 90
    samples := []
    for _, value in StrSplit(record, "|") {
        if (!IsNumber(value) || value < 1 || value > 1800)
            continue
        samples.Push(Number(value))
        while (samples.Length > 3)
            samples.RemoveAt(1)
    }
    if (!samples.Length)
        return {seconds: fallback, samples: samples.Length, learned: false}
    PN_Sort(samples)
    middle := Floor((samples.Length+1)/2)
    seconds := Mod(samples.Length, 2) ? samples[middle] : (samples[middle]+samples[middle+1])/2
    return {seconds: seconds, samples: samples.Length, learned: true}
}

PT_TravelDispatch(estimate) {
    return estimate.learned ? estimate.seconds : 0
}
