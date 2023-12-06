paths["WindShrine"] := "
    (LTrim Join`r`n
    ;gotoramp
    Send {space down}
    HyperSleep(300)
    Send {space up}
    " nm_Walk(36, RightKey) "
    send {space down}
    HyperSleep(300)
    send {space up}
    " nm_Walk(4, RightKey) "
    " nm_Walk(6, FwdKey) "
    " nm_Walk(3, RightKey) "
    send {space down}
    HyperSleep(300)
    send {space up}
    " nm_Walk(6, FwdKey) "
    " nm_Walk(2, LeftKey, FwdKey) "
    " nm_Walk(8, FwdKey) "
    Send {" FwdKey " down}{" RightKey " down}
    Walk(11)
    send {space down}{" RightKey " up}
    HyperSleep(200)
    send {space up}
    HyperSleep(1100)
    send {space down}
    HyperSleep(200)
    send {space up}
    Walk(18)
    send {space down}
    HyperSleep(200)
    send {space up}
    HyperSleep(200)
    " nm_Walk(21, FwdKey, RightKey) "
    send {space down}
    HyperSleep(300)
    send {space up}
    " nm_Walk(3, FwdKey) "
    " nm_Walk(19.5, RightKey) "
    send {space down}
    HyperSleep(300)
    send {space up}
    " nm_Walk(3, RightKey) "
    send {" RotRight " 2}
    HyperSleep(200)
    ;pepper
    " nm_Walk(13, FwdKey,RightKey) "
    " nm_Walk(5, RightKey) "
    send {space down}
    " nm_Walk(3, RightKey) "
    HyperSleep(200)
    send {space up}
    " nm_Walk(11, RightKey) "
    " nm_Walk(0.75, RightKey, BackKey) "
    " nm_Walk(0.75, BackKey) "
    HyperSleep(300)
)"
