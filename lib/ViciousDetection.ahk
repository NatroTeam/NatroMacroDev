; Confirm warning icons against the Vicious announcement and searched field.
nm_VBConfirmAnnouncement(bitmap, candidates, field) {
	static nextRead := 0, lastError := 0
	if DllCall("GetTickCount64", "UInt64") < nextRead
		return false
	try {
		Gdip_GetImageDimensions(bitmap, &width, &height)
		image := Gdip_ResizeBitmap(bitmap, width*2, height*2, 7)
		if !image
			return false
		try lines := nm_OCRFromBitmap(image, true, 1000)
		finally Gdip_DisposeImage(image)
		return nm_VBMatchAnnouncement(lines, candidates, field, 2)
	} catch as err {
		now := DllCall("GetTickCount64", "UInt64")
		if !lastError || now-lastError >= 60000 {
			lastError := now
			nm_setStatus("Detected", "Vicious confirmation unavailable: " err.Message)
		}
		return false
	} finally nextRead := DllCall("GetTickCount64", "UInt64")+750
}
nm_VBMatchAnnouncement(lines, candidates, field, scale := 1) {
	static fields := Map("pepper", "pepper", "mountaintop", "mountain\s*top", "rose", "rose", "cactus", "cactus", "spider", "spider", "clover", "clover")
	key := RegExReplace(StrLower(field), "[^a-z]")
	if !fields.Has(key)
		return false
	pattern := "i)^\s*(?:a\s+)?(?:gifted\s+)?vicious\s+bee\s+is\s+attacking\s+[a-z0-9_ ]{1,40}?\s+in\s+(?:the\s+)?" fields[key] "\s+(?:field|patch)\b"
	for candidate in candidates {
		center := (candidate.y+candidate.h/2)*scale
		nearest := 0, distance := 100000
		for index, line in lines {
			delta := Abs(line.y+line.h/2-center)
			if delta < distance && delta <= Max(8*scale, line.h/2) {
				nearest := index, distance := delta
			}
		}
		if !nearest
			continue
		text := "", bottom := lines[nearest].y
		Loop Min(3, lines.Length-nearest+1) {
			line := lines[nearest+A_Index-1]
			if (A_Index > 1 && (line.y < bottom || line.y-bottom > 12*scale))
				break
			text .= " " RegExReplace(line.text, "[^a-zA-Z0-9_ ]", " ")
			if RegExMatch(text, pattern)
				return true
			bottom := line.y+line.h
		}
	}
	return false
}
