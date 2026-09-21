; Route plain pattern sleeps through the same interrupt-aware timing as Walk.
nm_BloomPatternSource(source) {
    output := "", pos := 1, length := StrLen(source)
    while pos <= length {
        ch := SubStr(source, pos, 1), next := SubStr(source, pos, 2)
        if next = "/*" {
            finish := InStr(source, "*/", , pos + 2)
            count := finish ? finish + 2 - pos : length - pos + 1
        } else if ch = ";" || ch = "#" {
            finish := InStr(source, "`n", , pos)
            count := finish ? finish - pos + 1 : length - pos + 1
        } else if ch = Chr(34) || ch = "'" {
            finish := pos + 1
            while finish <= length {
                token := SubStr(source, finish++, 1)
                if token = Chr(96)
                    finish++
                else if token = ch
                    break
            }
            count := finish - pos
        } else if RegExMatch(SubStr(source, pos), "^[A-Za-z_]\w*", &word) {
            name := word[0], count := StrLen(name)
            tail := LTrim(SubStr(source, pos + count), " `t")
            if name = "Sleep" && SubStr(source, pos - 1, 1) != "." && SubStr(tail, 1, 2) != ":=" {
                output .= "pd_PatternSleep", pos += count
                continue
            }
        } else
            count := 1
        output .= SubStr(source, pos, count), pos += count
    }
    return output
}
