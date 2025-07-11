SeedShopPath:

    seedsCompleted := false
    shopOpened     := false

        SendDiscordMessage(webhookURL, "[Debug] SeedShopPath", "Function started.", COLOR_INFO, false, true)

    uiUniversal("1111020")
    sleepAmount(100, 1000)
    Send, {e}
    SendDiscordMessage(webhookURL, "Seed Cycle", "Starting seed buying cycle.", COLOR_INFO)
    sleepAmount(2500, 5000)
    ; checks for the shop opening up to 5 times to ensure it doesn't fail
    Loop, 5 {
        SendDiscordMessage(webhookURL, "[Debug] SeedShopPath", "Shop detection loop, attempt " . A_Index, COLOR_INFO, false, true)
        
        if (simpleDetect(0x00CCFF, 10, 0.54, 0.20, 0.65, 0.325)) {
            shopOpened := true
            ToolTip, Seed Shop Opened
            SetTimer, HideTooltip, -1500
            Sleep, 200
            CheckAndCloseBuyOption()
            SendDiscordMessage(webhookURL, "Seed Shop Status", "Seed Shop Opened.", COLOR_INFO)
            uiUniversal("21", 0)
            Sleep, 100
            buyUniversal("seed")
            SendDiscordMessage(webhookURL, "Seed Shop Status", "Seed Shop Closed.", COLOR_INFO)
            seedsCompleted := true
            break
        }
        Sleep, 1000
    }

    if (!seedsCompleted) {
        failCount += 1
    }

    closeShop("seed", seedsCompleted)
    SendDiscordMessage(webhookURL, "Seeds Completed", "Finished the seed buying cycle.", COLOR_COMPLETED)

Return