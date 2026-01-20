if goOutside {
    if (MoveMethod = "Cannon") {
        nm_gotoramp()
        nm_gotocannon()
        send "{e down}"
        HyperSleep(100)
        send "{e up}{" LeftKey " down}"
        HyperSleep(1200)
        send "{space 2}"
        HyperSleep(5000)
        send "{space}"
        HyperSleep(200)
        nm_Walk(10, FwdKey, LeftKey)

    } else {
        nm_gotoramp()
        nm_Walk(69, BackKey, LeftKey)
        nm_Walk(30, BackKey)
        nm_Walk(20, BackKey, LeftKey)
        nm_Walk(43.5, LeftKey)
        nm_Walk(18, FwdKey)
        nm_Walk(13, LeftKey)
        nm_Walk(55, BackKey)
        nm_Walk(20, LeftKey)
        nm_Walk(50, FwdKey)
        nm_Walk(10, LeftKey)
    }

    nm_Walk(6, RightKey)
    nm_Walk(3, BackKey)
    if !goInside
        Send "{" RotLeft " 2}"
}
if goInside {
    if goOutside {
        nm_walk(8, RightKey)
        nm_Walk(7, BackKey)
    } else {
        Send "{" RotRight " 2}"
        nm_Walk(15, LeftKey)
        nm_Walk(4, FwdKey)
        nm_Walk(3, BackKey)
        nm_Walk(15, RightKey)
        nm_Walk(6.8, BackKey)
    }
    Sleep(1000)
    nm_Walk(4, FwdKey, RightKey)
}

; by Lorddrak, edited by Myurius