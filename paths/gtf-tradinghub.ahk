if (MoveMethod = "Cannon") {
    nm_gotoramp()
    nm_gotocannon()
    send "{e down}"
    HyperSleep(100)
    send "{e up}{" FwdKey " down}"
    Hypersleep(750)
	loop 2 {
		send "{space down}"
		HyperSleep(50)
		send "{space up}"
	}
    HyperSleep(5000)
	Walk(9)
	Send "{" RotLeft " 2}"
	Walk(10)
	loop 2 {
		send "{space down}"
		HyperSleep(50)
		send "{space up}"
		(A_Index = 1 ? HyperSleep(300) : "")
	}
	Send("{" FwdKey " up}"), HyperSleep(3500)
    nm_Walk(3, FwdKey)
	nm_Walk(13, FwdKey, RightKey)
	nm_Walk(5, RightKey)
	nm_Walk(5, FwdKey)
	nm_Walk(8, BackKey, LeftKey)
	nm_Walk(6.8, BackKey, RightKey)
	nm_Walk(13, FwdKey, RightKey)
    ;path 240222 money_mountain
} else {
    nm_Walk(3, FwdKey)
	nm_Walk(52, LeftKey)
	nm_Walk(3, FwdKey)
	send "{" FwdKey " down}{space down}"
	HyperSleep(300)
	send "{space up}"
	nm_Walk(5, RightKey)
	send "{space down}"
	HyperSleep(300)
	send "{space up}{" FwdKey " up}"
	HyperSleep(500)
	nm_Walk(2, FwdKey)
	nm_Walk(15, RightKey)
	nm_Walk(6, FwdKey, RightKey)
	nm_Walk(7, FwdKey)
	nm_Walk(5, BackKey, LeftKey)
	nm_Walk(23, FwdKey)
	nm_Walk(12, LeftKey)    
	nm_Walk(16.5, LeftKey, FwdKey)
	nm_Walk(20, LeftKey, BackKey)
	nm_Walk(25, FwdKey, LeftKey) ; 31
    ;path 240222 money_mountain
}