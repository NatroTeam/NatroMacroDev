/************************************************************************
 * @Author Myurius
 * @Description Contains functions related to CopyData structs for WM_COPYDATA 
 **********************************************************************
 */

Send_WM_COPYDATA(message, target_script, wParam := 0) {
    static WM_COPYDATA := 0x004A

    struct := Buffer(A_PtrSize * 3)
	size := (StrLen(message) + 1) * 2
	NumPut("ptr", size, "ptr", StrPtr(message), struct.Ptr, A_PtrSize)
    try
		result := SendMessage(WM_COPYDATA, wParam, struct,, target_script)
	catch
		return -1
	else
		return result
}
StringFromCopyData(struct) {
    pString := NumGet(struct + (2 * A_PtrSize), "ptr")
	string := StrGet(pString)
    return string
}
