AutoHoneyPath:

    autoHoneyCompleted := false
        SendDiscordMessage(webhookURL, "[Debug] AutoHoneyPath", "Function started.", COLOR_INFO, false, true)

    WinActivate, ahk_exe RobloxPlayerBeta.exe
    Sleep, 100
    SendDiscordMessage(webhookURL, "Honey Compress Cycle", "Starting honey compress cycle.", COLOR_INFO)
    hotbarController(0, 1, "0")
    uiUniversal("11110")
    sleepAmount(100, 500)
    hotbarController(1, 0, "2")
    sleepAmount(100, 500)
    SafeClickRelative(midX, midY)
    sleepAmount(800, 1000)
    Send, {Down Down}
    Sleep, 2000
    Send, {Down Up}
    sleepAmount(100, 1000)
    Send, {e}
    Sleep, % FastMode ? 100 : 300
    uiUniversal("3333160664440")
    Sleep, % FastMode ? 100 : 300
    SendInput, ^{Backspace 5}
    Sleep, % FastMode ? 100 : 300
    Send, pollinated

    Loop, 3 {
        Loop, 3 {
            ClickFirstFour()
        }
        Send, 2
        Sleep, 100
        Send, 2
        Sleep, 100
        Sleep, 30000
        Send, {e}
        Sleep, 100
    }

    Sleep, % FastMode ? 150 : 300
    SafeClickRelative(0.64, 0.51)
    Sleep, % FastMode ? 100 : 200
    Send, {2}
    Send, {2}
    Sleep, % FastMode ? 100 : 200
    uiUniversal("3333311110")
    SendDiscordMessage(webhookURL, "Honey Compress Complete", "Finished the honey compress cycle.", COLOR_COMPLETED)
    autoHoneyCompleted := true

    TrackHoneyCycle()

TrackHoneyCycle()
{
    global honeyCount, webhookURL

    honeyCount += 30

    SendDiscordMessage(webhookURL, "Honey Compressed", "+30 honey collected.", COLOR_SUCCESS)
    SendDiscordMessage(webhookURL, "Total Honey", "Total honey collected so far: " . honeyCount, COLOR_INFO)
}
closeRobuxPrompt()

Return