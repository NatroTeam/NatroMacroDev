/************************************************************************
 * @description Auto-Jelly is a macro for the game Bee Swarm Simulator on Roblox. It automatically rolls bees for mutations and stops when a bee with the desired mutation is found. It also has the ability to stop on mythic and gifted bees.
 * @file auto-jelly.ahk
 * @author ninju | .ninju.
 * @date 2024/07/24
 * @version 0.0.1
***********************************************************************/

#SingleInstance Force
#Requires AutoHotkey v2.0
#Warn VarUnset, Off
;=============INCLUDES=============
#Include %A_ScriptDir%\..\lib
#Include Gdip_All.ahk
#include Roblox.ahk
#include Gdip_ImageSearch.ahk
#include OCR.ahk
;==================================
SendMode("Event")
CoordMode('Pixel', 'Screen')
CoordMode('Mouse', 'Screen')
;==================================
pToken := Gdip_Startup()
OnExit((*) => (closefunction()), -1)
OnError (e, mode) => (mode = "Return") ? -1 : 0
stopToggle(*) {
    global stopping := true
}
class __ArrEx extends Array {
    static __New() {
        Super.Prototype.includes := ObjBindMethod(this, 'includes')
    }
    static includes(arr, val) {
        for i, j in arr {
            if j = val
                return i
        }
        return 0
    }
}

if A_ScreenDPI !== 96
    throw Error("This macro requires a display-scale of 100%")
traySetIcon(".\nm_image_assets\birb.ico")
getConfig() {
    global
    local k, v, p, c, i, section, key, value, inipath, config, f, ini
    config := {
        mutations: {
            Mutations: 0,
            Ability: 0,
            Gather: 0,
            Convert: 0,
            Energy: 0,
            Movespeed: 0,
            Crit: 0,
            Instant: 0,
            Attack: 0
        },
        bees: {
            Bomber: 0,
            Brave: 0,
            Bumble: 0,
            Cool: 0,
            Hasty: 0,
            Looker: 0,
            Rad: 0,
            Rascal: 0,
            Stubborn: 0,
            Bubble: 0,
            Bucko: 0,
            Commander: 0,
            Demo: 0,
            Exhausted: 0,
            Fire: 0,
            Frosty: 0,
            Honey: 0,
            Rage: 0,
            Riley: 0,
            Shocked: 0,
            Baby: 0,
            Carpenter: 0,
            Demon: 0,
            Diamond: 0,
            Lion: 0,
            Music: 0,
            Ninja: 0,
            Shy: 0,
            Buoyant: 0,
            Fuzzy: 0,
            Precise: 0,
            Spicy: 0,
            Tadpole: 0,
            Vector: 0,
            selectAll: 0
        },
        GUI : {
            xPos: A_ScreenWidth//2-w//2,
            yPos: A_ScreenHeight//2-h//2
        },
        extrasettings: {
            mythicStop: 0,
            giftedStop: 0
        }
    }
    for i, section in config.OwnProps()
        for key, value in section.OwnProps()
            %key% := value
    if !FileExist(".\settings")
        DirCreate(".\settings")
    inipath := ".\settings\mutations.ini"
    if FileExist(inipath) {
        loop parse FileRead(inipath), "`n", "`r" A_Space A_Tab {
            switch (c:=SubStr(A_LoopField,1,1)) {
                case "[", ";": continue
                default:
                if (p := InStr(A_LoopField, "="))
                    try k := SubStr(A_LoopField, 1, p-1), %k% := IsInteger(v := SubStr(A_LoopField, p+1)) ? Integer(v) : v
            }
        }
    }
    ini:=""
    for k, v in config.OwnProps() {
        ini .= "[" k "]`r`n"
        for i in v.OwnProps()
            ini .= i "=" %i% "`r`n"
        ini .= "`r`n"
    }
    (f:=FileOpen(inipath, "w")).Write(ini), f.Close()
}
;===Dimensions===
w:=500,h:=397
;===Bee Array===
beeArr := ["Bomber", "Brave", "Bumble", "Cool", "Hasty", "Looker", "Rad", "Rascal", "Stubborn", "Bubble", "Bucko", "Commander", "Demo", "Exhausted", "Fire", "Frosty", "Honey", "Rage", "Riley", "Shocked", "Baby", "Carpenter", "Demon", "Diamond", "Lion", "Music", "Ninja", "Shy", "Buoyant", "Fuzzy", "Precise", "Spicy", "Tadpole", "Vector"]
mutationsArr := [ {name:"Ability", triggers:["rate", "abil", "ity"], full:"AbilityRate"}, {name:"Gather", triggers:["gath", "herAm"], full:"GatherAmount"}, {name:"Convert", triggers:["convert", "vertAm"], full:"ConvertAmount"}, {name:"Instant", triggers:["inst", "antConv"], full:"InstantConversion"}, {name:"Crit", triggers:["crit", "chance"], full:"CriticalChance"}, {name:"Attack", triggers:["attack", "att", "ack"], full:"Attack"}, {name:"Energy", triggers:["energy", "rgy"], full:"Energy"}, {name:"Movespeed", triggers:["movespeed", "speed", "move"], full:"MoveSpeed"},
]
extrasettings:=[ {name:"mythicStop", text: "Stop on mythics"}, {name:"giftedStop", text: "Stop on gifteds"}
]
getConfig()
(bitmaps := Map()).CaseSense:=0
#Include %A_ScriptDir%\..\nm_image_assets\mutator\bitmaps.ahk
#include %A_ScriptDir%\..\nm_image_assets\mutatorgui\bitmaps.ahk
startGui() {
    global
    local i,j,y,hBM,x
    (mgui := Gui("+E" (0x00080000) " +OwnDialogs -Caption -DPIScale", "Auto-Jelly")).OnEvent("Close", ExitApp)
    mgui.Show()
    for i, j in [ {name:"move", options:"x0 y0 w" w " h36"}, {name:"selectall", options:"x" w-330 " y220 w40 h18"}, {name:"mutations", options:"x" w-170 " y220 w40 h18"}, {name:"close", options:"x" w-40 " y5 w28 h28"}, {name:"roll", options:"x10 y" h-42 " w" w-56 " h30"}, {name:"help", options:"x" w-40 " y" h-42 " w28 h28"}
    ]
        mgui.AddText("v" j.name " " j.options)
    for i, j in beeArr {
        y := (A_Index-1)//8*1
        mgui.AddText("v" j " x" 10+mod(A_Index-1,8)*60 " y" 50+y*40 " w45 h36")
    }
    for i, j in mutationsArr {
        y := (A_Index-1)//4*1
        mgui.AddText("v" j.name " x" 10+mod(A_Index-1,4)*120 " y" 260+y*25 " w40 h18")
    }
    for i, j in extrasettings {
        x := 10 + (w-12)/extrasettings.length * (i-1), y:=(316+h-42)//2-10
        mgui.AddText("v" j.name " x" x " y" y " w40 h18")
    }
    hBM := CreateDIBSection(w, h)
    hDC := CreateCompatibleDC()
    SelectObject(hDC, hBM)
    G := Gdip_GraphicsFromHDC(hDC)
    Gdip_SetSmoothingMode(G, 4)
    Gdip_SetInterpolationMode(G, 7)
    update := UpdateLayeredWindow.Bind(mgui.hwnd, hDC)
    update(xpos < 0 ? 0 : xpos > A_ScreenWidth ? 0 : xpos, ypos < 0 ? 0 : ypos > A_ScreenHeight ? 0 : ypos, w, h)
    hovercontrol := ""
    DrawGUI()
}
startGUI()
OnMessage(0x201, WM_LBUTTONDOWN)
OnMessage(0x200, WM_MOUSEMOVE)
DrawGUI() {
    Gdip_GraphicsClear(G)
    Gdip_FillRoundedRectanglePath(G, brush := Gdip_BrushCreateSolid(0xFF131416), 2, 2, w-4, h-4, 20), Gdip_DeleteBrush(brush)
    region := Gdip_GetClipRegion(G)
    Gdip_SetClipRect(G, 2, 21, w-2, 30, 4)
    Gdip_FillRoundedRectanglePath(G, brush := Gdip_BrushCreateSolid("0xFFFEC6DF"), 2, 2, w-4, 40, 20)
    Gdip_SetClipRegion(G, region)
    Gdip_FillRectangle(G, brush, 2, 20, w-4, 14)
    Gdip_DeleteBrush(brush), Gdip_DeleteRegion(region)
    Gdip_TextToGraphics(G, "Auto-Jelly", "s20 x20 y5 w460 Near vCenter c" (brush := Gdip_BrushCreateSolid("0xFF131416")), "Comic Sans MS", 460, 30), Gdip_DeleteBrush(brush)
    Gdip_DrawImage(G, bitmaps["close"], w-40, 5, 28, 28)
    for i, j in beeArr {
        ;bitmaps are w45 h36
        y := (A_Index-1)//8
        bm := hovercontrol = j && (%j% || SelectAll) ? j "bghover" : %j% || SelectAll ? j "bg" : hovercontrol = j ? j "hover" : j
        Gdip_DrawImage(G, bitmaps[bm], 10+mod(A_Index-1,8)*60, 50+y*40, 45, 36)
    }
    ;===Switches===
    Gdip_FillRoundedRectanglePath(G, brush := Gdip_BrushCreateSolid("0xFF" . 13*2 . 14*2 . 16*2), w-330, 220, 40, 18, 9), Gdip_DeleteBrush(brush)
    Gdip_FillEllipse(G, brush:=Gdip_BrushCreateSolid("0xFFFEC6DF"), selectAll ? w-310 : w-332, 218, 22, 22)
    Gdip_TextToGraphics(G, "Select All Bees", "s14 x" w-284 " y220 Near vCenter c" brush, "Comic Sans MS",, 20), Gdip_DeleteBrush(brush)
    if !SelectAll {
        Gdip_FillEllipse(G, brush:=Gdip_BrushCreateSolid("0xFF" . 13*2 . 14*2 . 16*2), w-330, 220, 18, 18), Gdip_DeleteBrush(brush)
        Gdip_DrawLines(G, Pen:=Gdip_CreatePen("0xFFCC0000", 2), [[w-325, 225], [w-317, 233]])
        Gdip_DrawLines(G, Pen								  , [[w-325, 233], [w-317, 225]]), Gdip_DeletePen(Pen)
    }
    else
        Gdip_DrawLines(G, Pen:=Gdip_CreatePen("0xFF006600", 2), [[w-303, 229], [w-300, 232], [w-295, 225]]), Gdip_DeletePen(Pen)
    Gdip_FillRoundedRectanglePath(G, brush := Gdip_BrushCreateSolid("0xFF" . 13*2 . 14*2 . 16*2), w-170, 220, 40, 18, 9), Gdip_DeleteBrush(brush)
    Gdip_FillEllipse(G, brush:=Gdip_BrushCreateSolid("0xFFFEC6DF"), mutations ? w-150 : w-172, 218, 22, 22)
    Gdip_TextToGraphics(G, "Mutations", "s14 x" w-124 " y220 Near vCenter c" (brush), "Comic Sans MS",, 20), Gdip_DeleteBrush(brush)
    if !mutations {
        Gdip_FillEllipse(G, brush:= Gdip_BrushCreateSolid("0xFF" . 13*2 . 14*2 . 16*2), w-170, 220, 18, 18), Gdip_DeleteBrush(brush)
        Gdip_DrawLines(G, Pen:=Gdip_CreatePen("0xFFCC0000", 2), [[w-165, 225], [w-157, 233]])
        Gdip_DrawLines(G, Pen								  , [[w-165, 233], [w-157, 225]]), Gdip_DeletePen(Pen)
    }
    else
        Gdip_DrawLines(G, Pen:=Gdip_CreatePen("0xFF006600", 2), [[w-143, 229], [w-140, 232], [w-135, 225]]), Gdip_DeletePen(Pen)
    For i, j in mutationsArr {
        y := (A_Index-1)//4
        Gdip_FillRoundedRectanglePath(G, brush := Gdip_BrushCreateSolid("0xFF" . 13*2 . 14*2 . 16*2), 10+mod(A_Index-1,4)*120, 260+y*25, 40, 18, 9), Gdip_DeleteBrush(brush)
        Gdip_FillEllipse(G, brush:=Gdip_BrushCreateSolid("0xFFFEC6DF"), (%j.name% ? 3.2 : 1) * 8+mod(A_Index-1,4)*120, 258+y*25, 22, 22), Gdip_DeleteBrush(brush)
        Gdip_TextToGraphics(G, j.name, "s13 x" 56+mod(A_Index-1,4)*120 " y" 260+y*25 " vCenter c" (brush := Gdip_BrushCreateSolid("0xFFFEC6DF")), "Comic Sans MS", 100, 20), Gdip_DeleteBrush(brush)
        if !%j.name% {
            Gdip_FillEllipse(G, brush:=Gdip_BrushCreateSolid("0xFF262832"), x:=10+mod(A_Index-1,4)*120, yp:=258+y*25+2, 18, 18), Gdip_DeleteBrush(brush)
            Gdip_DrawLines(G, Pen:=Gdip_CreatePen("0xFFCC0000", 2), [[x+5, yp+5 ], [x+13, yp+13]])
            Gdip_DrawLines(G, Pen								  , [[x+5, yp+13], [x+13, yp+5 ]]), Gdip_DeletePen(Pen)
        }
        else
            Gdip_DrawLines(G, Pen:=Gdip_CreatePen("0xFF006600", 2), [[x:=32.6+mod(A_Index-1,4)*120, yp:=269+y*25], [x+3, yp+3], [x+8, yp-4]]), Gdip_DeletePen(Pen)
    }
    if !mutations
        Gdip_FillRectangle(G, brush:=Gdip_BrushCreateSolid("0x70131416"), 9, 255, w-18, 52), Gdip_DeleteBrush(brush)
    Gdip_DrawLine(G, Pen:=Gdip_CreatePen("0xFFFEC6DF", 2), 10, 315, w-12, 315), Gdip_DeletePen(Pen)
    ;two more switches for "stop on mythic" and "stop on gifted"
    for i, j in extrasettings {
        x := 10 + (tw:=(w-12)/extrasettings.length) * (i-1), y:=(316+h-42)//2-10
        Gdip_FillRoundedRectanglePath(G, brush:=Gdip_BrushCreateSolid("0xFF262832"), x, y, 40, 18, 9), Gdip_DeleteBrush(brush), Gdip_DeleteBrush(brush)
        Gdip_FillEllipse(G, brush:=Gdip_BrushCreateSolid("0xFFFEC6DF"), %j.name% ? x+18 : x-2, y-2, 22, 22)
        Gdip_TextToGraphics(G, j.text, "s14 x" x+46 " y" y " vCenter c" brush, "Comic Sans MS", tw,20), Gdip_DeleteBrush(brush)
        if !%j.name% {
            Gdip_FillEllipse(G, brush:=Gdip_BrushCreateSolid("0xFF262832"), x, y, 18, 18), Gdip_deleteBrush(brush)
            Gdip_DrawLines(G, Pen:=Gdip_CreatePen("0xFFCC0000", 2), [[x+5, y+5 ], [x+13, y+13]])
            Gdip_DrawLines(G, Pen								  , [[x+5, y+13], [x+13, y+5 ]]), Gdip_DeletePen(Pen)
        }
        else
            Gdip_DrawLines(G, Pen:=Gdip_CreatePen("0xFF006600", 2), [[x+25, y+9], [x+28, y+12], [x+33, y+5]]), Gdip_DeletePen(Pen)
    }
    if hovercontrol = "roll"
        Gdip_FillRoundedRectanglePath(G, brush:=Gdip_BrushCreateSolid("0x30FEC6DF"), 10, h-42, w-56, 30, 10), Gdip_DeleteBrush(brush)
    if hovercontrol = "help"
        Gdip_FillRoundedRectanglePath(G, brush:=Gdip_BrushCreateSolid("0x30FEC6DF"), w-40, h-42, 30, 30, 10), Gdip_DeleteBrush(brush)
    Gdip_TextToGraphics(G, "Roll!", "x10 y" h-40 " Center vCenter s15 c" (brush:=Gdip_BrushCreateSolid("0xFFFEC6DF")),"Comic Sans MS",w-56, 28)
    Gdip_TextToGraphics(G, "?", "x" w-39 " y" h-40 " Center vCenter s15 c" brush,"Comic Sans MS",30, 28), Gdip_DeleteBrush(brush)
    Gdip_DrawRoundedRectanglePath(G, pen:=Gdip_CreatePen("0xFFFEC6DF", 4), 10, h-42, w-56, 30, 10)
    Gdip_DrawRoundedRectanglePath(G, pen, w-40, h-42, 30, 30, 10), Gdip_DeletePen(pen)
    update()
}
WM_LBUTTONDOWN(wParam, lParam, msg, hwnd) {
    global hovercontrol, mutations, Bomber, Brave, Bumble, Cool, Hasty, Looker, Rad, Rascal
    , Stubborn, Bubble, Bucko, Commander, Demo, Exhausted, Fire, Frosty, Honey, Rage
    , Riley, Shocked, Baby, Carpenter, Demon, Diamond, Lion, Music, Ninja, Shy, Buoyant
    , Fuzzy, Precise, Spicy, Tadpole, Vector, SelectAll, Ability, Gather, Convert, Energy
    , Movespeed, Crit, Instant, Attack, mythicStop, giftedStop
    MouseGetPos(,,,&ctrl,2)
    if !ctrl
        return
    switch mgui[ctrl].name, 0 {
        case "move":
            PostMessage(0x00A1,2)
        case "close":
            while GetKeyState("LButton", "P")
                sleep -1
            mousegetpos ,,, &ctrl2, 2
            if ctrl = ctrl2
                PostMessage(0x0112,0xF060)
        case "roll":
            ReplaceSystemCursors()
            blc_start()
        case "help":
            ReplaceSystemCursors()	
            Msgbox("This feature allows you to roll royal jellies until you obtain your specified bees and/or mutations!`n`nTo use:`n- Select the bees and mutations you want`n- Make sure your in-game Auto-Jelly settings are right`n- Put a neonberry on the bee you want to change (if trying `n  to obtain a mutated bee) `n- Use one royal jelly on the bee and click Yes`n- Click on Roll.`n`nTo stop: `n- Press the escape key`n`nAdditional options:`n- Stop on Gifteds stops on any gifted bee, `n  ignoring the mutation and your bee selection`n- Stop on Mythics stops on any mythic bee, `n  ignoring the mutation and your bee selection", "Auto-Jelly Help", "0x40040")
        case "selectAll":
            IniWrite(%mgui[ctrl].name% ^= 1, ".\settings\mutations.ini", "bees", mgui[ctrl].name)
        case "Bomber", "Brave", "Bumble", "Cool", "Hasty", "Looker", "Rad", "Rascal", "Stubborn", "Bubble", "Bucko", "Commander", "Demo", "Exhausted", "Fire", "Frosty", "Honey", "Rage", "Riley":
            if !selectAll
                IniWrite(%mgui[ctrl].name% ^= 1, ".\settings\mutations.ini", "bees", mgui[ctrl].name)
        case "Shocked", "Baby", "Carpenter", "Demon", "Diamond", "Lion", "Music", "Ninja", "Shy", "Buoyant", "Fuzzy", "Precise", "Spicy", "Tadpole", "Vector":
            if !selectAll
                IniWrite(%mgui[ctrl].name% ^= 1, ".\settings\mutations.ini", "bees", mgui[ctrl].name)
        case "giftedStop", "mythicStop":
            IniWrite(%mgui[ctrl].name% ^= 1, ".\settings\mutations.ini", "extrasettings", mgui[ctrl].name)
        case "mutations":
            IniWrite(%mgui[ctrl].name% ^= 1, ".\settings\mutations.ini", "mutations", mgui[ctrl].name)
        default:
            if mutations
                IniWrite(%mgui[ctrl].name% ^= 1, ".\settings\mutations.ini", "mutations", mgui[ctrl].name)
    }
    DrawGUI()
}
WM_MOUSEMOVE(wParam, lParam, msg, hwnd) {
    global
    local ctrl, hover_ctrl, tt := 0
    MouseGetPos(,,,&ctrl,2)
    if !ctrl || mgui["move"].hwnd = ctrl || mgui["close"].hwnd = ctrl
        return
    ReplaceSystemCursors("IDC_HAND")
    hovercontrol := mgui[ctrl].name
    hover_ctrl := mgui[ctrl].hwnd
    DrawGUI()
    while ctrl = hover_ctrl {
        sleep(20),MouseGetPos(,,,&ctrl,2)
        if A_Index > 120 && beeArr.includes(hovercontrol) && !tt
            tt:=1,ToolTip(hovercontrol . " Bee")
    }
    hovercontrol := ""
    ToolTip()
    ReplaceSystemCursors()
    DrawGUI()
}
ReplaceSystemCursors(IDC := "") {
    static IMAGE_CURSOR := 2, SPI_SETCURSORS := 0x57
        , SysCursors := Map(  "IDC_APPSTARTING", 32650
                            , "IDC_ARROW"      , 32512
                            , "IDC_CROSS"      , 32515
                            , "IDC_HAND"       , 32649
                            , "IDC_HELP"       , 32651
                            , "IDC_IBEAM"      , 32513
                            , "IDC_NO"         , 32648
                            , "IDC_SIZEALL"    , 32646
                            , "IDC_SIZENESW"   , 32643
                            , "IDC_SIZENWSE"   , 32642
                            , "IDC_SIZEWE"     , 32644
                            , "IDC_SIZENS"     , 32645
                            , "IDC_UPARROW"    , 32516
                            , "IDC_WAIT"       , 32514 )
    if !IDC
        DllCall("SystemParametersInfo", "UInt", SPI_SETCURSORS, "UInt", 0, "UInt", 0, "UInt", 0)
    else {
        hCursor := DllCall("LoadCursor", "Ptr", 0, "UInt", SysCursors[IDC], "Ptr")
        for k, v in SysCursors {
            hCopy := DllCall("CopyImage", "Ptr", hCursor, "UInt", IMAGE_CURSOR, "Int", 0, "Int", 0, "UInt", 0, "Ptr")
            DllCall("SetSystemCursor", "Ptr", hCopy, "UInt", v)
        }
    }
}
blc_start() {
    global stopping:=false
    hotkey "~*esc", stopToggle, "On"
    selectedBees := [], selectedMutations := []
    for i in beeArr
        if %i% || SelectAll
            selectedBees.push(i)
    if mutations {
        selectedMutations := []
        for i in mutationsArr
            if %i.name%
                selectedMutations.push(i)
    }

    if !(hwndRoblox:=GetRobloxHWND()) || !(GetRobloxClientPos(), windowWidth)
        return msgbox("You must have Bee Swarm Simulator open to use this!", "Auto-Jelly", 0x40030)
    if !selectedBees.length
        return msgbox("You must select at least one bee to run this macro!", "Auto-Jelly", 0x40030)

    yOffset := GetYOffset(hwndRoblox, &fail)
    if fail	
        MsgBox("Unable to detect in-game GUI offset!`nThis means the macro will NOT work correctly!`n`nThere are a few reasons why this can happen:`n- Incorrect graphics settings (check Troubleshooting Guide!)`n- Your Experience Language is not set to English`n- Something is covering the top of your Roblox window`n`nJoin our Discord server for support!", "WARNING!!", 0x1030 " T60")
    if mgui is Gui
        mgui.hide()
    While !stopping {
        ActivateRoblox()
        click windowX + Round(0.5 * windowWidth + 10) " " windowY + yOffset + Round(0.4 * windowHeight + 230)
        sleep 800
        pBitmap := Gdip_BitmapFromScreen(windowX + 0.5*windowWidth - 155 "|" windowY + yOffset + 0.425*windowHeight - 200 "|" 320 "|" 140)
        if mythicStop
            for i, j in ["Buoyant", "Fuzzy", "Precise", "Spicy", "Tadpole", "Vector"]
                if Gdip_ImageSearch(pBitmap, bitmaps["-" j]) || Gdip_ImageSearch(pBitmap, bitmaps["+" j]) {
                    Gdip_DisposeImage(pBitmap)
                    msgbox "Found a mythic bee!", "Auto-Jelly", 0x40040
                    break 2
                }
        if giftedStop
            for i, j in beeArr {
                if Gdip_ImageSearch(pBitmap, bitmaps["+" j]) {
                    Gdip_DisposeImage(pBitmap)
                    msgbox "Found a gifted bee!", "Auto-Jelly", 0x40040
                    break 2	
                }	
            }
        found := 0
        for i, j in selectedBees {
            if Gdip_ImageSearch(pBitmap, bitmaps["-" j]) || Gdip_ImageSearch(pBitmap, bitmaps["+" j]) {
                if (!mutations || !selectedMutations.length) {
                    Gdip_DisposeImage(pBitmap)
                    if msgbox("Found a match!`nDo you want to keep this?","Auto-Jelly!", 0x40044) = "Yes"
                        break 2
                    else
                        continue 2
                }
                found := 1
                break
            }
        }
        Gdip_DisposeImage(pBitmap)
        if !found
            continue
        pBitmap := Gdip_BitmapFromScreen(windowX + Round(0.5 * windowWidth - 320) "|" windowY + yOffset + Round(0.4 * windowHeight + 17) "|210|90")
        pEffect := Gdip_CreateEffect(5, -60,30)
        Gdip_BitmapApplyEffect(pBitmap, pEffect)
        Gdip_DisposeEffect(pEffect)
        text:= RegExReplace(OCR.FromBitmap(pBitmap).Text, "i)([\r\n\s]|mutation)*")
        Gdip_DisposeImage(pBitmap)
        found := 0
        for i, j in selectedMutations
            for k, trigger in j.triggers
                if inStr(text, trigger) { 
                    found := 1
                    break
                }
        if !found
            continue
        if msgbox("Found a match!`nDo you want to keep this?","Auto-Jelly!", 0x40044) = "Yes"
            break
    }
    hotkey "~*esc", stopToggle, "Off"
    mgui.show()
}
closeFunction(*) {
    global xPos, yPos
    Gdip_Shutdown(pToken)
    ReplaceSystemCursors()
    try {
        mgui.getPos(&xp, &yp)
        if !(xp < 0) && !(xp > A_ScreenWidth) && !(yp < 0) && !(yp > A_ScreenHeight)
            xPos := xp, yPos := yp
        IniWrite(xpos, ".\settings\mutations.ini", "GUI", "xpos")
        IniWrite(ypos, ".\settings\mutations.ini", "GUI", "ypos")
    }
}