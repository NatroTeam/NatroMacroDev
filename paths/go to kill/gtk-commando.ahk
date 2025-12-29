nm_gotoRamp()
if MoveMethod = "Walk" {
    nm_Walk(44.75, BackKey, LeftKey) 
    nm_Walk(42.5, LeftKey) 
    nm_Walk(8.5, BackKey) 
    nm_Walk(22.5, LeftKey) 
    send "{" RotLeft " 2}"
    nm_Walk(27, FwdKey) 
    nm_Walk(12, LeftKey, FwdKey) 
    nm_Walk(11, FwdKey)
} else {
    nm_gotoCannon()
    send "{" SC_E " down}"
    HyperSleep(100)
    send "{" SC_E " up}"
    HyperSleep(400)
    send "{" LeftKey " down}{" FwdKey " down}"
    HyperSleep(1050)
    send "{" SC_Space " 2}"
    HyperSleep(5850)
    send "{" FwdKey " up}"
    HyperSleep(750)
    send "{" SC_Space "}{" RotLeft " 2}"
    HyperSleep(1500)
    send "{" LeftKey " up}"
    nm_Walk(4, BackKey) 
    nm_Walk(4.5, LeftKey)
}

if MoveSpeed < 34 {
    nm_Walk(10, LeftKey) 
    HyperSleep(50)
    nm_Walk(6, RightKey) 
    HyperSleep(50)
    nm_Walk(2, LeftKey) 
    HyperSleep(50)
    nm_Walk(7, FwdKey) 
    HyperSleep(750)
    send "{" SC_Space " down}"
    HyperSleep(50)
    send "{" SC_Space " up}"
    nm_Walk(5.5, FwdKey) 
    HyperSleep(750)
    Loop 3 {
        send "{" SC_Space " down}"
        HyperSleep(50)
        send "{" SC_Space " up}"
        nm_Walk(6, FwdKey) 
        HyperSleep(750)
    }
    nm_Walk(1, FwdKey) 
    send "{" SC_Space " down}"
    HyperSleep(50)
    send "{" SC_Space " up}"
    nm_Walk(6, FwdKey) 
    HyperSleep(750)
    nm_Walk(5, FwdKey) 
    HyperSleep(50)
    nm_Walk(9, BackKey) 
    Sleep 4000
    send "{" SC_Space " down}"
    HyperSleep(50)
    send "{" SC_Space " up}"
    nm_Walk(0.5, BackKey) 
    HyperSleep(1500)
} else {
    nm_Walk(10, LeftKey)
    HyperSleep(50)
    nm_Walk(6, RightKey)
    HyperSleep(50)
    nm_Walk(2, LeftKey)
    HyperSleep(50)
    nm_Walk(7, FwdKey)
    HyperSleep(750)
    send "{" SC_Space " down}"
    HyperSleep(50)
    send "{" SC_Space " up}"
    nm_Walk(4.5, FwdKey)
    HyperSleep(750)
    Loop 3 {
        send "{" SC_Space " down}"
        HyperSleep(50)
        send "{" SC_Space " up}"
        nm_Walk(5, FwdKey) 
        HyperSleep(750)
    }
    nm_Walk(1, FwdKey) 
    send "{" SC_Space " down}"
    HyperSleep(50)
    send "{" SC_Space " up}"
    nm_Walk(6, FwdKey) 
    HyperSleep(750)
    nm_Walk(5, FwdKey) 
    HyperSleep(50)
    nm_Walk(9, BackKey) 
    Sleep 4000
    send "{" SC_Space " down}"
    HyperSleep(50)
    send "{" SC_Space " up}"
    nm_Walk(0.5, BackKey) 
    HyperSleep(1500)
}

; commando path from before 1.2.0