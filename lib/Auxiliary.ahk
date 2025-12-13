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
