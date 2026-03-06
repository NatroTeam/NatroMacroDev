if goOutside {
    if (MoveMethod = "Cannon") {
        nm_gotoramp()
        nm_gotocannon()
        Send "{e down}"
        HyperSleep(100)
        Send "{e up}{" LeftKey " down}"
        HyperSleep(675)
        Send "{space 2}"
        HyperSleep(3200)
        Send "{" LeftKey " up}"
        HyperSleep(1250)
        Send "{space}"
        Sleep(1500)
        nm_Walk(2, BackKey)
        nm_Walk(7, RightKey)
    } else {
        nm_gotoramp()
        nm_Walk(86.875, BackKey, LeftKey)
        nm_Walk(43, LeftKey)
        nm_Walk(17, BackKey, LeftKey)
        nm_Walk(14, RightKey)
        nm_Walk(8, FwdKey)
    }
}
if goInside {
    nm_Walk(12, FwdKey)
    nm_Walk(16, LeftKey)
    nm_Walk(14, LeftKey, FwdKey)
    nm_Walk(4, LeftKey)
    nm_Walk(5, BackKey)
    nm_Walk(8, RightKey)
    nm_Walk(2, FwdKey)
    Send "{space}"
    nm_walk(6, FwdKey)
    nm_Walk(1, RightKey)
    nm_Walk(4, FwdKey)

}

; by Lorddrak, edited by Myurius