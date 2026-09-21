HyperSleep(ms)
{
	static freq := (DllCall("QueryPerformanceFrequency", "Int64*", &f := 0), f)
	DllCall("QueryPerformanceCounter", "Int64*", &begin := 0)
	global MovementInterrupt
	current := 0, nextPoll := 0, finish := begin + ms * freq / 1000
	while (current < finish)
	{
		if IsSet(MovementInterrupt) && IsObject(MovementInterrupt) && A_TickCount >= nextPoll {
			finish += MovementInterrupt.Poll()
			nextPoll := A_TickCount + 20
		}
		if ((finish - current) > 30000)
		{
			DllCall("Winmm.dll\timeBeginPeriod", "UInt", 1)
			DllCall("Sleep", "UInt", 1)
			DllCall("Winmm.dll\timeEndPeriod", "UInt", 1)
		}
		DllCall("QueryPerformanceCounter", "Int64*", &current)
	}
}