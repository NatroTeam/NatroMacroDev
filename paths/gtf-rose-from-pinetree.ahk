Send "{" RotLeft " 2}"
nm_walk(23, FwdKey, RightKey)
nm_walk(5, RightKey)
Send "{" RotLeft " 2}"
HyperSleep(100)
nm_walk(37, FwdKey)
nm_walk(14, FwdKey, LeftKey)
nm_walk(3, FwdKey)

; jump + glider
if (MoveMethod = "Cannon")
{
    
    send "{space down}"
    Sleep(100)
    send "{space up}"
    Sleep(200)
    send "{space down}"
    Sleep(100)
    send "{space up}"

    Sleep(3000)
}
else    ; normal walk
{
    nm_walk(61, FwdKey)
}

