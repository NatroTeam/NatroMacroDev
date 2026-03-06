nm_gotoramp()
Send "{space down}{" RightKey " down}"
Sleep 100
Send "{space up}"
Walk(2)
Send "{" FwdKey " down}"
Walk(1.8)
Send "{" FwdKey " up}"
Walk(30)
Send "{" RightKey " up}{space down}"
Sleep(300)
Send "{space up}"
nm_Walk(4, RightKey)
nm_Walk(5, FwdKey)
nm_Walk(3, RightKey)
Send "{space down}"
Sleep(300)
Send "{space up}"
nm_Walk(6, FwdKey)
nm_Walk(2, LeftKey, FwdKey)
nm_Walk(8, FwdKey)
Send "{" FwdKey " down}{" RightKey " down}"
Walk(11)
Send "{space down}{" RightKey " up}"
Sleep(200)
Send "{space up}"
Sleep(1100)
Send "{space down}"
Sleep(200)
Send "{space up}"
Walk(18)
Send "{" FwdKey " up}"
Send "{space down}"
Sleep(200)
Send "{space up}"
nm_Walk(30, FwdKey)
nm_Walk(7, BackKey)
Send "{" RotLeft " 2}"

;originally a copy of path 230212 by zaappiix
