; ---------------------------------------------------------------------------
;  Harvest Event Mini-Macro – AutoHotkey v1.1 (dark-theme, global hotkeys)
; ---------------------------------------------------------------------------
#NoEnv
#SingleInstance Force
SetBatchLines, -1
SetKeyDelay, -1, -1        ; Remove all key delays
SetMouseDelay, -1          ; Remove all mouse delays  
SetDefaultMouseSpeed, 0    ; Fastest mouse movement
SetWinDelay, -1           ; Remove window delays
SetControlDelay, -1       ; Remove control delays
CoordMode, Mouse, Screen
#KeyHistory 0
ListLines, Off            ; Disable line logging for speed

; ---------------------------------------------------------------------------
;  COLOUR PALETTE  (BGR for AHK v1)
; ---------------------------------------------------------------------------
BG_Main    := 0x202020     ; window background
BG_Panel   := 0x2B2B2B     ; dark gray for frames / edits
CLR_Text   := 0xFFFFFF     ; white text
CLR_Button := 0x3C3C3C     ; default button face
CLR_Start  := 0x46BB6B     ; green (start)
CLR_Stop   := 0xDB7D4D     ; red   (running/stop)
; ---------------------------------------------------------------------------
;  Globals (logic unchanged)
; ---------------------------------------------------------------------------
isSpamClicking := 0
isSpammingE    := 0
forceStop      := 0
mouseX := 986 , mouseY := 1064
isSlowMode        := 0
previousClickRate := 15
previousERate     := 5

clickX := 986
clickY := 1064
currentResolution := "1440p"
; ---------------------------------------------------------------------------
;  GUI
; ---------------------------------------------------------------------------
Gui, +Resize
Gui, Color, %BG_Main%
Gui, Font, s12 c%CLR_Text%, Segoe UI

Gui, Add, Text, x20  y20  w260 Center, Harvest Event Mini Macro

; ------- Start/Stop button --------------------------------------------------
Gui, Add, Button, x20 y50 w260 h50 gToggleAll vMainButton c%CLR_Text% Background%CLR_Start%, START SPAM
Gui, Font, s14 Bold
GuiControl, Font, MainButton
Gui, Font, s12 c%CLR_Text%

Gui, Add, Text, x20 y110 w260 Center vStatusText, Status: Stopped

; ------- Instruction block --------------------------------------------------
Gui, Font, s10 Bold
Gui, Add, Text, x20 y140 w260 Center, Before starting:
Gui, Font, s10
Gui, Add, Text, x20 y165 w260, 1. Open your inventory
Gui, Add, Text, x20 y185 w260, 2. Select / equip the item you want
Gui, Add, Text, x20 y205 w260, 3. Press F5 to run the macro

; ------- Rate controls ------------------------------------------------------
Gui, Add, Text,  x20  y235 w120, Click Rate (ms):
Gui, Add, Edit,  x160 y233 w60 h20 vClickRateEdit  cBlack Background%BG_Panel%

Gui, Add, Text,  x20  y265 w120, E Rate (ms):
Gui, Add, Edit,  x160 y263 w60 h20 vERateEdit      cBlack Background%BG_Panel%

Gui, Add, Text,  x20  y295 w120, Resolution:
Gui, Add, DropDownList, x160 y293 w90 vResolutionDropdown c%CLR_Text% Background%BG_Panel%, 1440p||1080p

; ------- Hotkey legend ------------------------------------------------------
Gui, Add, Text, x20 y330 w260, Hotkeys:
Gui, Add, Text, x20 y350 w260, Q    Start/Stop All
Gui, Add, Text, x20 y370 w260, R    Emergency Stop
Gui, Add, Text, x20 y390 w260, L     Toggle Slow Mode (50 ms / 40 ms)

; ------- Mode label & Exit --------------------------------------------------
Gui, Add, Text,   x20 y420 w260 Center vModeText, Mode: Normal
Gui, Add, Button, x20 y450 w100 h30 gExitScript c%CLR_Text% Background%CLR_Button%, Exit

; default values
GuiControl,, ClickRateEdit, 15
GuiControl,, ERateEdit,     5

Gui, Show, w300 h510, Harvest Event Mini Macro
Return
; ---------------------------------------------------------------------------
;  BUTTON / HOTKEY HANDLERS
; ---------------------------------------------------------------------------
ToggleAll:
    ; Remove this performance killer: Gui, Submit, NoHide
    if (isSpamClicking || isSpammingE)
        Gosub, EmergencyStop
    else {
        Gosub, StartAll
        GuiControl,, MainButton, STOP SPAM
        GuiControl,, StatusText, Status: Running
        GuiControl, +Background%CLR_Stop%, MainButton
    }
Return
; ---------------------------------------------------------------------------
StartAll:
    forceStop := 0
    
    ; Cache everything at once
    GuiControlGet, currentResolution, , ResolutionDropdown
    GuiControlGet, clickRateValue, , ClickRateEdit
    GuiControlGet, eRateValue, , ERateEdit
    
    ; Set coordinates
    if (currentResolution = "1080p") {
        clickX := 662, clickY := 705
    } else {
        clickX := 986, clickY := 1064
    }
    
    ; Validate and set timers
    clickRate := (clickRateValue + 0 < 5) ? 5 : clickRateValue + 0
    eRate := (eRateValue + 0 < 5) ? 5 : eRateValue + 0
    
    isSpamClicking := 1
    isSpammingE := 1
    SetTimer, DoClick, %clickRate%
    SetTimer, DoE, %eRate%
Return
; ---------------------------------------------------------------------------
EmergencyStop:
    forceStop := 1
    isSpamClicking := 0
    isSpammingE    := 0
    SetTimer, DoClick, Off
    SetTimer, DoE,    Off

    GuiControl,, MainButton, START SPAM
    GuiControl,, StatusText, Status: STOPPED
    GuiControl,, ModeText  , % isSlowMode ? "Mode: Slow (50 ms/40 ms)" : "Mode: Normal"
    GuiControl, +Background%CLR_Start%, MainButton
    SetTimer, ResetForceStop, -100
Return

ResetForceStop:
    forceStop := 0
Return
; ---------------------------------------------------------------------------
SlowMode:
    if (!isSlowMode) {
        ; Get current values before changing
        GuiControlGet, currentClickRate, , ClickRateEdit
        GuiControlGet, currentERate, , ERateEdit
        previousClickRate := currentClickRate
        previousERate := currentERate
        
        GuiControl,, ClickRateEdit, 50
        GuiControl,, ERateEdit, 40
        isSlowMode := 1
        GuiControl,, ModeText, Mode: Slow (50 ms/40 ms)
        if (isSpamClicking || isSpammingE)
            GuiControl,, StatusText, Status: Slow Mode Active
    } else {
        GuiControl,, ClickRateEdit, %previousClickRate%
        GuiControl,, ERateEdit, %previousERate%
        isSlowMode := 0
        GuiControl,, ModeText, Mode: Normal
        if (isSpamClicking || isSpammingE)
            GuiControl,, StatusText, Status: Running
    }

    ; refresh timers if active - cache coordinates again
    if (isSpamClicking) {
        SetTimer, DoClick, Off
        GuiControlGet, newClickRate, , ClickRateEdit
        GuiControlGet, currentResolution, , ResolutionDropdown
        if (currentResolution = "1080p") {
            clickX := 662
            clickY := 705
        } else {
            clickX := 986
            clickY := 1064
        }
        rate := newClickRate + 0
        if (rate < 5)
            rate := 5 , GuiControl,, ClickRateEdit, 5
        SetTimer, DoClick, %rate%
    }
    if (isSpammingE) {
        SetTimer, DoE, Off
        GuiControlGet, newERate, , ERateEdit
        rate := newERate + 0
        if (rate < 5)
            rate := 5 , GuiControl,, ERateEdit, 5
        SetTimer, DoE, %rate%
    }
Return
; ---------------------------------------------------------------------------
DoClick:
    if (!forceStop && isSpamClicking) {
        ; Ultra-fast click without MouseMove
        Click, %clickX%, %clickY%
    }
Return

DoE:
    if (!forceStop && isSpammingE) {
        ; Use SendRaw for fastest E key sending
        SendRaw, e
    }
Return
; ---------------------------------------------------------------------------
ExitScript:
GuiClose:
    ExitApp
Return
; ---------------------------------------------------------------------------
;  Global hotkeys
; ---------------------------------------------------------------------------
Q::Gosub ToggleAll
R::Gosub EmergencyStop
l::Gosub SlowMode
