StopMacro(terminate := 1) {

    Gui, Submit, NoHide

    Sleep, 50
    started := 0
    Gosub, SaveSettings
    Gui, Destroy
    if (terminate)
        ExitApp

}

PauseMacro(terminate := 1) {

    Gui, Submit, NoHide
    Sleep, 50
    started := 0
    Gosub, SaveSettings

}

; pressing x on window closes macro 
GuiClose:

    StopMacro(1)

Return

; pressing f7 button reloads
Quit:

    PauseMacro(1)
    SendDiscordMessage(webhookURL, "Macro reloaded.", "The script is being reloaded.", COLOR_INFO)
    Reload ; ahk built in reload

Return

; f7 reloads
F7::

    PauseMacro(1)
    SendDiscordMessage(webhookURL, "Macro reloaded.", "The script is being reloaded via hotkey.", COLOR_INFO)
    Reload ; ahk built in reload

Return

; f5 starts scan
F5:: 

Gosub, StartScanMultiInstance

Return

F8::

MsgBox, 1, Message, % "Delete debug file?"

IfMsgBox, OK
FileDelete, debug.txt

Return


F9::
    global debugWebhookMode
    debugWebhookMode := !debugWebhookMode
    tooltipText := "Debug Webhook Mode: " . (debugWebhookMode ? "ON" : "OFF")
    ToolTip, %tooltipText%
    SetTimer, HideTooltip, -1500
    SendDiscordMessage(webhookURL, "Debug Mode Toggled", tooltipText, COLOR_WARNING)
Return


F10::

    MouseGetPos, mx, my
    WinGetPos, winX, winY, winW, winH, ahk_exe RobloxPlayerBeta.exe
    xRatio := (mx - winX) / winW
    yRatio := (my - winY) / winH
    MsgBox, Relative Position:`nX: %xRatio%`nY: %yRatio%

Return

SpamE:

    Send, e

Return