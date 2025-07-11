


AutoSeedCraftPath:

if (cycleCount = 0 && ManualSeedCraftLock > 0) {
	seedCraftingLocked := 1
	SetTimer, UnlockSeedCraft, -%ManualSeedCraftLock%
Return
}

selectedSeedCraftingItems := []
Loop, 12 {
    lastRanItem := currentItem 
    IniRead, value, %A_ScriptDir%\Settings\settings.ini, SeedCrafting, Item%A_Index%, 0
    if (value = 1)
        selectedSeedCraftingItems.Push(A_Index)
}

if (seedCraftActionQueue.Length() = 0) {
    for index, item in selectedSeedCraftingItems
        seedCraftActionQueue.Push(item)
}

    seedCraftCompleted       := false
    shopOpened               := false
    seedCraftShopFailed      := false
        SendDiscordMessage(webhookURL, "[Debug] AutoSeedCraftPath", "Function started.", COLOR_INFO, false, true)

    WinActivate, ahk_exe RobloxPlayerBeta.exe
    SendDiscordMessage(webhookURL, "Seed Crafting Cycle", "Starting seed crafting cycle.", COLOR_INFO)
    hotbarController(0, 1, "0")
    uiUniversal("11110")
    sleepAmount(100, 500)
    hotbarController(1, 0, "2")
    sleepAmount(100, 500)
    SafeClickRelative(midX, midY)
    sleepAmount(800, 1000)
    Send, {Down Down}
    Sleep, 880
    Send, {Down Up}
    sleepAmount(250, 1000)
    Send, {c}
    sleepAmount(100, 300)
    Send, {e}
    sleepAmount(400, 1000)
    Send, {e}
    sleepAmount(2500, 5000)
    Loop, 5 {
        if ( simpleDetect(0x040837, 5, 0.49, 0.26, 0.55, 0.59)) {
            shopOpened := true
            Sleep, 250
            ToolTip, Seed Crafter Opened
            SetTimer, HideTooltip, -1500
            Sleep, 1000
            CheckAndCloseBuyOption()
            SendDiscordMessage(webhookURL, "Seed Crafter Status", "Seed Crafter Opened.", COLOR_INFO)
            }
            if (shopOpened) {
                break
            }
            Sleep, 2000
        }
    if (!shopOpened) {
        ToolTip, Failed to Open Seed Crafter
        SetTimer, HideTooltip, -1500
        SendDiscordMessage(webhookURL, "Shop Detection Failed", "Failed to detect Seed Crafter opening.", COLOR_ERROR, PingSelected)
        seedCraftShopFailed := true
        adaptiveUniversal("333222311113332223111105222222505", "3332223325050531111505")
        ShopFailSafe()
        Return
    }

if (seedCraftActionQueue.Length() > 0) {
    currentCraftingItem := seedCraftActionQueue[1]

    if (currentCraftingItem = 1) {
	currentItem := "Peace Lily"
        uiUniversal("21505405")

	sleepAmount(100, 300)
    searchItem("uncommon.egg")
	searchItem("rafflesia", 1, 1)
    SelectEquipGive()       ; function stored on the main file btw
	searchItem("cauliflower", 1, 1)
    SelectEquipGive()
    searchItem("recall") 
    Send, {vkC0sc029}
	Send, {e}
	sleepAmount(500, 1000)
	closeRobuxPrompt()
searchItem("recall", 1, 0, 0, 1)
	seedCraftingLocked := 1
	SetTimer, UnlockSeedCraft, -600000 
	SendDiscordMessage(webhookURL, "Crafting Attempted", "Attempted to craft " . currentItem . ".", COLOR_INFO)
        seedCraftActionQueue.RemoveAt(1)
        Sleep, 50
        if (seedCraftActionQueue.Length() = 0) {
            seedCraftCompleted := 1
        }
    }


    if (currentCraftingItem = 2) {
	currentItem := "Aloe Vera Seed"
        uiUniversal("21450450")

	sleepAmount(100, 300)
	searchItem("peace", 1, 1)
    SelectEquipGive()
	searchItem("prickly", 1, 0, 1)
    SelectEquipGive()
    Send, {vkC0sc029}
	Send, {e}
	sleepAmount(500, 1000)
	closeRobuxPrompt()

	seedCraftingLocked := 1
	SetTimer, UnlockSeedCraft, -600000
	SendDiscordMessage(webhookURL, "Crafting Attempted", "Attempted to craft " . currentItem . ".", COLOR_INFO)
        seedCraftActionQueue.RemoveAt(1)
        Sleep, 50
        if (seedCraftActionQueue.Length() = 0) {
            seedCraftCompleted := 1
        }
    }


    if (currentCraftingItem = 3) {
	currentItem := "Guanabana Seed"
        uiUniversal("214450450")

	sleepAmount(100, 300)
	searchItem("aloe", 1, 1)
    SelectEquipGive()
	searchItem("prickly", 1, 1)
    SelectEquipGive()
	searchItem("banana", 1, 0, 1)
    SelectEquipGive()
    Send, {vkC0sc029}
	Send, {e}
	sleepAmount(500, 1000)
	closeRobuxPrompt()

	seedCraftingLocked := 1
	SetTimer, UnlockSeedCraft, -600000
	SendDiscordMessage(webhookURL, "Crafting Attempted", "Attempted to craft " . currentItem . ".", COLOR_INFO)
        seedCraftActionQueue.RemoveAt(1)
        Sleep, 50
        if (seedCraftActionQueue.Length() = 0) {
            seedCraftCompleted := 1
        }
    }

}

if (seedCraftCompleted) {
    sleepAmount(100, 300)
    hotbarController(0, 1, "2")
    Send, {c}
    sleepAmount(100, 300)
    uiUniversal("25050513205")
    SendDiscordMessage(webhookURL, "Seed Crafting Complete", "Finished the seed crafting cycle.", COLOR_COMPLETED)
    sleepAmount(100, 300)
}

Return