EggShopPath:

    SendDiscordMessage(webhookURL, "[Debug] EggShopPath", "Function started.", COLOR_INFO, false, true)
    Sleep, 100
    uiUniversal("11110")
    Sleep, 100
    hotbarController(1, 0, "2")
    sleepAmount(100, 1000)
    SafeClickRelative(midX, midY)
    SendDiscordMessage(webhookURL, "Egg Cycle", "Starting egg buying cycle.", COLOR_INFO)
    Sleep, 800

    ; egg 1 sequence
    SendDiscordMessage(webhookURL, "[Debug] EggShopPath", "Starting egg 1 sequence.", COLOR_INFO, false, true)
    Send, {Up Down}
    Sleep, 800
    Send {Up Up}
    sleepAmount(500, 1000)
    Send {e}
    Sleep, 100
    uiUniversal("11114", 0, 0)
    Sleep, 100
    quickDetectEgg(0x26EE26, 5, 0.41, 0.65, 0.52, 0.70)
    Sleep, 800
    ; egg 2 sequence
        SendDiscordMessage(webhookURL, "[Debug] EggShopPath", "Starting egg 2 sequence.", COLOR_INFO, false, true)
    Send, {Up down}
    Sleep, 200
    Send, {Up up}
    sleepAmount(100, 1000)
    Send {e}
    Sleep, 100
    uiUniversal("11114", 0, 0)
    Sleep, 100
    quickDetectEgg(0x26EE26, 5, 0.41, 0.65, 0.52, 0.70)
    Sleep, 800
    ; egg 3 sequence
        SendDiscordMessage(webhookURL, "[Debug] EggShopPath", "Starting egg 3 sequence.", COLOR_INFO, false, true)
    Send, {Up down}
    Sleep, 200
    Send, {Up up}
    sleepAmount(100, 1000)
    Send, {e}
    Sleep, 200
    uiUniversal("11114", 0, 0)
    Sleep, 100
    quickDetectEgg(0x26EE26, 5, 0.41, 0.65, 0.52, 0.70)
    Sleep, 800

    closeRobuxPrompt()
    sleepAmount(500, 1500)
    uiUniversal("25050513250")
    Sleep, 100
    SendDiscordMessage(webhookURL, "Eggs Completed", "Finished the egg buying cycle.", COLOR_COMPLETED)
Return