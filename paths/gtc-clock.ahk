if (MoveMethod = "walk")
{
	nm_gotoramp()
	nm_Walk(44.75, BackKey, LeftKey) ; 47.25
	nm_Walk(28, LeftKey)
	nm_Walk(10, BackKey)
	nm_Walk(6, LeftKey)
	nm_Walk(12, BackKey, LeftKey) ;corner align
	nm_Walk(1.5, RightKey)
	nm_Walk(12.2, FwdKey)
	nm_Walk(12.5, LeftKey) ; ladder 1
	nm_Walk(1.5, RightKey, BackKey)
	nm_Walk(15, BackKey)
	nm_Walk(7.5, LeftKey) ;corner align 2
	nm_Walk(1.75, RightKey)
	nm_Walk(4, FwdKey)
	nm_Walk(22.5, LeftKey) ; ladder 2
	send "{" RotLeft " 2}"
	nm_Walk(40, FwdKey)
	nm_Walk(1, BackKey)
	nm_Walk(7, RightKey) ; 2.25
	send "{" FwdKey " down}{space down}"
	HyperSleep(100)
	send "{space up}"
	HyperSleep(500)
	send "{" FwdKey " up}"
	nm_Walk(5, FwdKey)
	nm_Walk(5, LeftKey)
	nm_Walk(15, FwdKey)
}
else
{
	nm_gotoramp()
	nm_gotocannon()
	Send "{e down}"
	HyperSleep(100)
	Send "{e up}{" FwdKey " down}{" LeftKey " down}"
	HyperSleep(1500)
	send "{space 2}"
	Sleep 8000
	Send "{" FwdKey " up}{" LeftKey " up}"
	nm_Walk(15, BackKey)
	nm_Walk(3.5, RightKey)
	nm_Walk(2, RightKey, BackKey)
	nm_Walk(1, BackKey)
}
