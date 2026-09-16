/************************************************************************
 * @description Distance between two given strings
 * @author Dully176
 * @function LevenshteinDistance()
 * @version 1.0.0
 ***********************************************************************/
LevenshteinDistance(string_a, string_b){
    len1 := StrLen(string_a), len2 := StrLen(string_b)
    s1 := StrSplit(string_a), s2 := StrSplit(string_b)
    d := {}, d.0 := { 0: 0 }
    Loop len1
        d.%A_Index% := { 0: A_Index }
    Loop len2
        d.0.%A_Index% := A_Index
    Loop len1 {
        i := A_Index
        Loop len2 {
            j := A_Index
            cost := s1[i] != s2[j]
            d.%i%.%j% := Min(d.%i - 1%.%j% + 1, d.%i%.%j - 1% + 1, d.%i - 1%.%j - 1% + cost)
        }
    }
    return d.%len1%.%len2%
}