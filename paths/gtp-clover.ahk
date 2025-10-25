if (MoveMethod = "walk")
{
    nm_gotoramp()
    nm_Walk(44.75, BackKey, LeftKey) ; 47.25
    nm_Walk(52.5, LeftKey)
    nm_Walk(2.8, BackKey, RightKey)
    nm_Walk(7.7, BackKey)
    nm_Walk(20.5, LeftKey)
    nm_Walk(5.5, FwdKey)

    ; going to corner
    nm_Walk(20, FwdKey, LeftKey)
    nm_Walk(5, FwdKey)
    nm_Walk(10, LeftKey)
    nm_Walk(10, FwdKey, LeftKey)

    ; out of corner
    nm_Walk(15, RightKey)
    nm_Walk(15, RightKey, FwdKey)
    nm_Walk(3, BackKey)

}
else
{
    nm_gotoramp()
    nm_gotocannon()
    send "{e down}"
    HyperSleep(100)
    send "{e up}{" LeftKey " down}{" FwdKey " down}"
    HyperSleep(525) ; change to 625? idea
    send "{space 2}"
    HyperSleep(1250)
    send "{" FwdKey " up}"
    HyperSleep(3850)
    send "{" LeftKey " up}{space}"
    HyperSleep(1000)

    ; going to corner
    nm_Walk(25, FwdKey, LeftKey)
    nm_Walk(7, FwdKey)
    nm_Walk(10, FwdKey, LeftKey)

    ; out of corner
    nm_Walk(15, RightKey)
    nm_Walk(15, RightKey, FwdKey)
    nm_Walk(3, BackKey)
}
;path 230729 noobyguy
; edited by Lorddrak