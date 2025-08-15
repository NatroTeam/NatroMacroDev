; Comment out the function below to see all errors
; To ignore git tracking:
; `git update-index --skip-worktree lib/ErrorHandling.ahk`
; To add it back:
; git update-index --no-skip-worktree lib/ErrorHandling.ahk
OnError (e, mode) => (mode = "Return") ? -1 : 0
