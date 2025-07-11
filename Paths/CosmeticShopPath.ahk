CosmeticShopPath:
{
    cosmeticsCompleted  := false
    shopOpened          := false
    SendDiscordMessage(webhookURL, "[Debug] CosmeticShopPath", "Function started.", COLOR_INFO, false, true)

    hotbarController(0, 1, "0")
    uiUniversal("11110")
    sleepAmount(100, 500)
    hotbarController(1, 0, "2")
    sleepAmount(100, 500)
    SafeClickRelative(midX, midY)
    sleepAmount(800, 1000)
    Send, {Down Down}
    Sleep, 550
    Send, {Down Up}
    sleepAmount(100, 1000)
    Send, {e}
    sleepAmount(2500, 5000)
    SendDiscordMessage(webhookURL, "Cosmetic Cycle", "Starting cosmetic buying cycle.", COLOR_INFO)

    cosmeticNames := cosmeticItems  ; it takes it from the item arrays, no need to write all the cosmetics again

    cosmeticPaths := [ "210", "21110", "2111110"
                     , "2140", "21410", "214110"
                     , "2141110", "21411110", "214111110" ]

    Loop, 5 {
        SendDiscordMessage(webhookURL, "[Debug] CosmeticShopPath", "Shop detection loop, attempt " . A_Index, COLOR_INFO, false, true)

        if (simpleDetect(0x00CCFF, 10, 0.61, 0.182, 0.764, 0.259)) {
            shopOpened := true
            ToolTip, Cosmetic Shop Opened
            SetTimer, HideTooltip, -1500
            SendDiscordMessage(webhookURL, "Cosmetic Shop Status", "Cosmetic Shop Opened.", COLOR_INFO)
            Sleep, 200

            for index, currentItem in cosmeticNames {
                path := cosmeticPaths[index]
                Loop, 5 {
                    uiUniversal(path)
                    Sleep, 300
                }
                SendDiscordMessage(webhookURL, "Cosmetic Purchased", "Bought " . currentItem, COLOR_SUCCESS)
                Sleep, 100
            }
            SendDiscordMessage(webhookURL, "Cosmetic Shop Status", "Cosmetic Shop Closed.", COLOR_INFO)
            cosmeticsCompleted := true
        }
        if (cosmeticsCompleted)
            break

        Sleep, 2000
    }

    if (cosmeticsCompleted) {
        Sleep, 500
        uiUniversal("20043150")
    }
    else {
        SendDiscordMessage(webhookURL, "Shop Detection Failed", "Failed to detect Cosmetic Shop opening.", COLOR_ERROR, PingSelected)
        uiUniversal("11111111113020")
    }

    hotbarController(0, 1, "0")
    SendDiscordMessage(webhookURL, "Cosmetics Completed", "Finished the cosmetic buying cycle.", COLOR_COMPLETED)
Return
}