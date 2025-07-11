GearShopPath:

    gearsCompleted := false
    shopOpened     := false
        SendDiscordMessage(webhookURL, "[Debug] GearShopPath", "Function started.", COLOR_INFO, false, true)

    hotbarController(0, 1, "0")
    uiUniversal("11110")
    sleepAmount(100, 500)
    hotbarController(1, 0, "2")
    sleepAmount(100, 500)
    SafeClickRelative(midX, midY)
    sleepAmount(1200, 2500)
    Send, {e}
    sleepAmount(2700, 4000)
    dialogueClick("gear")
    SendDiscordMessage(webhookURL, "Gear Cycle", "Starting gear buying cycle.", COLOR_INFO)
    sleepAmount(2500, 5000)
    ; checks for the shop opening up to 5 times to ensure it doesn't fail
    Loop, 5 {
                SendDiscordMessage(webhookURL, "[Debug] GearShopPath", "Shop detection loop, attempt " . A_Index, COLOR_INFO, false, true)
        if (simpleDetect(0x00CCFF, 10, 0.54, 0.20, 0.65, 0.325)) {
            shopOpened     := true
            ToolTip, Gear Shop Opened
            SetTimer, HideTooltip, -1500
            Sleep, 150
            CheckAndCloseBuyOption()
            SendDiscordMessage(webhookURL, "Gear Shop Status", "Gear Shop Opened.", COLOR_INFO)
            Sleep, 200
            uiUniversal("21", 0)
            Sleep, 100
            buyUniversal("gear")
            SendDiscordMessage(webhookURL, "Gear Shop Status", "Gear Shop Closed.", COLOR_INFO)
            gearsCompleted = true
            break
        }
        Sleep, 1000
    }

    if (!gearsCompleted) {
        failCount += 1
    }

    closeShop("gear", gearsCompleted)
    
    Sleep, 1000

    Gosub, zoomAlignment

    hotbarController(0, 1, "0")
    SendDiscordMessage(webhookURL, "Gears Completed", "Finished the gear buying cycle.", COLOR_COMPLETED)

Return