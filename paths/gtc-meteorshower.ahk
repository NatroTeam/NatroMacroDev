if (MoveMethod = "Cannon") {
    nm_gotoramp()
    nm_gotocannon()
    send "{" RotRight " 2}{e down}"
    HyperSleep(100)
    send "{e up}{" FwdKey " down}"
    HyperSleep(1150)
    send "{space 2}{" FwdKey " up}"
    HyperSleep(6000)
    nm_Walk(22, LeftKey, FwdKey)
    sleep 200
} else {
    nm_gotoramp()
    send "{space down}{" RightKey " down}"
    Sleep 100
    send "{space up}"
    Walk(2)
    send "{" FwdKey " down}"
    Walk(1.8)
    send "{" FwdKey " up}"
    Walk(30)
    send "{" RightKey " up}{space down}"
    HyperSleep(300)
    send "{space up}"
    nm_Walk(4, RightKey)
    nm_Walk(5, FwdKey)
    nm_Walk(3, RightKey)
    send "{space down}"
    HyperSleep(300)
    send "{space up}"
    nm_Walk(6, FwdKey)
    nm_Walk(2, LeftKey, FwdKey)
    nm_Walk(8, FwdKey)
    send "{" FwdKey " down}{" RightKey " down}"
    Walk(11)
    send "{space down}{" RightKey " up}"
    HyperSleep(200)
    send "{space up}"
    HyperSleep(1100)
    send "{space down}"
    HyperSleep(200)
    send "{space up}"
    Walk(18)
    send "{space down}"
    HyperSleep(200)
    send "{space up}"
    Walk(8)
    send "{" FwdKey " up}"
    nm_Walk(33, RightKey)
    send "{space down}{" FwdKey " down}"
    HyperSleep(200)
    send "{space up}"
    Walk(2)
    send "{" RotRight " 2}{" FwdKey " up}"
    HyperSleep(500)
    send "{space down}{" FwdKey " down}"
    HyperSleep(200)
    send "{space up}"
    Walk(7)
    send "{" FwdKey " up}"
    nm_Walk(11, RightKey)
    nm_Walk(1, LeftKey)
    HyperSleep(200)
    send "{space down}{" RightKey " down}"
    HyperSleep(200)
    send "{space up}"
    Walk(38)
    send "{" FwdKey " down}"
    Walk(7)
    send "{" FwdKey " up}"
    Walk(3)
    send "{space down}"
    HyperSleep(200)
    send "{space up}"
    Walk(23.5)
    send "{space down}"
    HyperSleep(200)
    send "{space up}{" RightKey " up}"
    HyperSleep(200)
    send "{space down}"
    HyperSleep(100)
    send "{space up}"
    HyperSleep(2500)
    nm_Walk(3.5, RightKey)
    nm_Walk(5.5, BackKey)
    sleep 200
    ;path 69420 dully176
    ;24/04/12 
}
