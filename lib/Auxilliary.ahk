/***************************************************************************************
* @description: Min + Max val in an array or map
* @author modified versions of functions by FanaticGuru
* @url https://www.autohotkey.com/boards/viewtopic.php?t=40898
***************************************************************************************/
minX(List)
{
	List.__Enum().Call(, &X)
	for key, element in List
		if (IsNumber(element) && (element < X))
			X := element
	return X
}
maxX(List)
{
	List.__Enum().Call(, &X)
	for key, element in List
		if (IsNumber(element) && (element > X))
			X := element
	return X
}

/*************************************************************************************************************
* @description: rounds a number (integer/float) to 4 s.f. and abbreviates it with common large number prefixes
* @returns: (string) result
* @author SP
*************************************************************************************************************/
FormatNumber(n)
{
	static numnames := ["M","B","T","Qa","Qi"]
	digit := floor(log(abs(n)))+1
	if (digit > 6)
	{
		numname := (digit-4)//3
		numstring := SubStr((round(n,4-digit)) / 10**(3*numname+3), 1, 5)
		numformat := (SubStr(numstring, 0) = ".") ? 1.000 : numstring, numname += (SubStr(numstring, 0) = ".") ? 1 : 0
		num := SubStr((round(n,4-digit)) / 10**(3*numname+3), 1, 5) " " numnames[numname]
	}
	else
	{
		num := Buffer(32), DllCall("GetNumberFormatEx","str","!x-sys-default-locale","uint",0,"str",n,"ptr",0,"Ptr",num.Ptr,"int",32)
		num := SubStr(StrGet(num), 1, -3)
	}
	return num
}

; auxiliary map/array functions
ObjFullyClone(obj)
{
	nobj := obj.Clone()
	for k,v in nobj
		if IsObject(v)
			nobj[k] := ObjFullyClone(v)
	return nobj
}
ObjHasValue(obj, value)
{
	for k,v in obj
		if (v = value)
			return 1
	return 0
}
ObjMinIndex(obj)
{
	for k,v in obj
		return k
	return 0
}
ObjIndexOf(obj, val)
{
	for k, v in obj
		if (v = val)
			return k
	return 0
}
ObjStrJoin(delim, arr) {
	out := ""
	try {
		for v in arr
			out .= (out = "" ? "" : delim) . v
		return out
	} catch
		return 0
}
QuickSort(arr, prop := "", low := 1, high := 0)
{
    high := high ? high : arr.Length
    if (low < high)
        p := Partition(arr, prop, low, high), (p > low) ? QuickSort(arr, prop, low, p - 1) : 0, (p < high) ? QuickSort(arr, prop, p + 1, high) : 0
    return arr
}
Partition(arr, prop, low, high)
{
    pivot := prop ? arr[high].%prop% : arr[high], i := low - 1
    Loop high - low
        j := low + A_Index - 1, val := prop ? arr[j].%prop% : arr[j], (val > pivot) ? (i++, temp := arr[i], arr[i] := arr[j], arr[j] := temp) : 0
    (i + 1 != high) ? (i++, temp := arr[i], arr[i] := arr[high], arr[high] := temp) : i++
    return i
}