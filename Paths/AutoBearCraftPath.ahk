


AutoBearCraftPath:

if (cycleCount = 0 && ManualBearCraftLock > 0) {
	bearCraftingLocked := 1
	SetTimer, UnlockBearCraft, -%ManualBearCraftLock%
Return
}

selectedBearCraftingItems := []
Loop, 15 {
    lastRanItem := currentItem 
    IniRead, value, %A_ScriptDir%\Settings\settings.ini, BearCrafting, Item%A_Index%, 0
    if (value = 1)
        selectedBearCraftingItems.Push(A_Index)
}

if (bearCraftActionQueue.Length() = 0) {
    for index, item in selectedBearCraftingItems
        bearCraftActionQueue.Push(item)
}

    bearCraftCompleted      := false
    shopOpened              := false
    bearCraftShopFailed     := false
        SendDiscordMessage(webhookURL, "[Debug] AutoBearCraftPath", "Function started.", COLOR_INFO, false, true)

    WinActivate, ahk_exe RobloxPlayerBeta.exe
    SendDiscordMessage(webhookURL, "Bear Crafting Cycle", "Starting bear crafting cycle.", COLOR_INFO)
    hotbarController(0, 1, "0")
    uiUniversal("11110")
    sleepAmount(100, 500)
    hotbarController(1, 0, "2")
    sleepAmount(100, 500)
    SafeClickRelative(midX, midY)
    sleepAmount(800, 1000)
    Send, {Down Down}
    Sleep, 1160
    Send, {Down Up}
    sleepAmount(100, 1000)
    Send, {c}
    sleepAmount(100, 400)
    Send, {e}
    sleepAmount(400, 1000)
    Send, {e}
        sleepAmount(2500, 5000)
    Loop, 5 {
        if ( simpleDetect(0x040837, 5, 0.49, 0.26, 0.55, 0.59)) {
            ToolTip, Bear Crafter Opened
            SetTimer, HideTooltip, -1500
            Sleep, 1000
            CheckAndCloseBuyOption()
            shopOpened := true
            SendDiscordMessage(webhookURL, "Bear Crafter Status", "Bear Crafter Opened.", COLOR_INFO)
        }
    if (shopOpened) {
        break
        }
        Sleep, 2000
    }
    if (!shopOpened) {
        ToolTip, Failed to Open Bear Crafter
        SetTimer, HideTooltip, -1500
        SendDiscordMessage(webhookURL, "Shop Detection Failed", "Failed to detect Bear Crafter opening.", COLOR_ERROR, PingSelected)
	    bearCraftShopFailed := true
        adaptiveUniversal("333222311113332223111105222222505", "3332223325050531111505")
        ShopFailSafe()
        Return
    }

if (bearCraftActionQueue.Length() > 0) {
    currentCraftingItem := bearCraftActionQueue[1]

    if (currentCraftingItem = 1) {
	currentItem := "Lightning Rod"
        uiUniversal("21505405")

	sleepAmount(100, 300)
	searchItem("basic", 1)
    SelectEquipGive()       ; function stored on the main file btw
	searchItem("advanced", 1)
    SelectEquipGive()
	searchItem("godly", 1)
    SelectEquipGive()
    Send, {vkC0sc029}
	Send, {e}
	sleepAmount(500, 1000)
	closeRobuxPrompt()

	bearCraftingLocked := 1
	SetTimer, UnlockBearCraft, -2700000
	SendDiscordMessage(webhookURL, "Crafting Attempted", "Attempted to craft " . currentItem . ".", COLOR_INFO)
        bearCraftActionQueue.RemoveAt(1)
        Sleep, 50
        if (bearCraftActionQueue.Length() = 0) {
            bearCraftCompleted := 1
        }
    }


    if (currentCraftingItem = 2) {
	currentItem := "Reclaimer"
        uiUniversal("214505405")

	sleepAmount(100, 300)
    searchItem("uncommon.egg") ; put the uncommon egg in slot 2, cause when u search for common egg it shows both, and can break the search function
	searchItem("common.egg", 1)
    SelectEquipGive()
	searchItem("harvest", 1)
    SelectEquipGive()
    searchItem("recall") ; equip again the wrench
    Send, {vkC0sc029}
	Send, {e}
	sleepAmount(500, 1000)
	closeRobuxPrompt()

	bearCraftingLocked := 1
	SetTimer, UnlockBearCraft, -1500000
	SendDiscordMessage(webhookURL, "Crafting Attempted", "Attempted to craft " . currentItem . ".", COLOR_INFO)
        bearCraftActionQueue.RemoveAt(1)
        Sleep, 50
        if (bearCraftActionQueue.Length() = 0) {
            bearCraftCompleted := 1
        }
    }

    
    if (currentCraftingItem = 3) {
	currentItem := "Tropical Mist Sprinkler"
        uiUniversal("2144505405")

	sleepAmount(100, 300)
	searchItem("coconut", 1, 0, 1)
    SelectEquipGive()
	searchItem("dragon", 1, 0, 1)
    SelectEquipGive()
	searchItem("mango", 1, 0, 1)
    SelectEquipGive()
	searchItem("godly", 1)
    SelectEquipGive()
    Send, {vkC0sc029}
	Send, {e}
	sleepAmount(500, 1000)
	closeRobuxPrompt()

	bearCraftingLocked := 1
	SetTimer, UnlockBearCraft, -3600000
	SendDiscordMessage(webhookURL, "Crafting Attempted", "Attempted to craft " . currentItem . ".", COLOR_INFO)
        bearCraftActionQueue.RemoveAt(1)
        Sleep, 50
        if (bearCraftActionQueue.Length() = 0) {
            bearCraftCompleted := 1
        }
    }

    
    if (currentCraftingItem = 4) {
	currentItem := "Berry Blusher Sprinkler"
        uiUniversal("21444505405")

	sleepAmount(100, 300)
	searchItem("grape", 1, 0, 1)
    SelectEquipGive()
	searchItem("blueberry", 1, 0, 1)
    SelectEquipGive()
	searchItem("strawberry", 1, 0, 1)
    SelectEquipGive()
	searchItem("godly", 1)
    SelectEquipGive()
    Send, {vkC0sc029}
	Send, {e}
	sleepAmount(500, 1000)
	closeRobuxPrompt()


	bearCraftingLocked := 1
	SetTimer, UnlockBearCraft, -3600000
	SendDiscordMessage(webhookURL, "Crafting Attempted", "Attempted to craft " . currentItem . ".", COLOR_INFO)
        bearCraftActionQueue.RemoveAt(1)
        Sleep, 50
        if (bearCraftActionQueue.Length() = 0) {
            bearCraftCompleted := 1
        }
    }

    
    if (currentCraftingItem = 5) {
	currentItem := "Spice Spritzer Sprinkler"
        uiUniversal("214444505405")

	sleepAmount(100, 300)
	searchItem("pepper", 1, 0, 1)
    SelectEquipGive()
	searchItem("ember", 1, 0, 1)
    SelectEquipGive()
	searchItem("cacao", 1, 0, 1)
    SelectEquipGive()
	searchItem("master", 1)
    SelectEquipGive()
    Send, {vkC0sc029}
	Send, {e}
	sleepAmount(500, 1000)
	closeRobuxPrompt()

	bearCraftingLocked := 1
	SetTimer, UnlockBearCraft, -3600000
	SendDiscordMessage(webhookURL, "Crafting Attempted", "Attempted to craft " . currentItem . ".", COLOR_INFO)
        bearCraftActionQueue.RemoveAt(1)
        Sleep, 50
        if (bearCraftActionQueue.Length() = 0) {
            bearCraftCompleted := 1
        }
    }

    
    if (currentCraftingItem = 6) {
	currentItem := "Sweet Soaker Sprinkler"
        uiUniversal("2144444505405")

	sleepAmount(100, 300)
	Loop, 3 {
	searchItem("watermelon", 1, 0, 1)
    SelectEquipGive()
    sleepAmount(100, 300)
	}
	searchItem("master", 1)
    SelectEquipGive()
    Send, {vkC0sc029}
	Send, {e}
	sleepAmount(500, 1000)
	closeRobuxPrompt()

	bearCraftingLocked := 1
	SetTimer, UnlockBearCraft, -3600000
	SendDiscordMessage(webhookURL, "Crafting Attempted", "Attempted to craft " . currentItem . ".", COLOR_INFO)
        bearCraftActionQueue.RemoveAt(1)
        Sleep, 50
        if (bearCraftActionQueue.Length() = 0) {
            bearCraftCompleted := 1
        }
    }

    
    if (currentCraftingItem = 7) {
	currentItem := "Flower Froster Sprinkler"
        uiUniversal("21444444505405")

	sleepAmount(100, 300)
	searchItem("orange", 1, 0, 1)
    SelectEquipGive()
	searchItem("daffodil", 1, 0, 1)
    SelectEquipGive()
	searchItem("advanced", 1)
    SelectEquipGive()
	searchItem("basic", 1)
    SelectEquipGive()
    Send, {vkC0sc029}
	Send, {e}
	sleepAmount(500, 1000)
	closeRobuxPrompt()

	bearCraftingLocked := 1
	SetTimer, UnlockBearCraft, -3600000
	SendDiscordMessage(webhookURL, "Crafting Attempted", "Attempted to craft " . currentItem . ".", COLOR_INFO)
        bearCraftActionQueue.RemoveAt(1)
        Sleep, 50
        if (bearCraftActionQueue.Length() = 0) {
            bearCraftCompleted := 1
        }
    }

    
    if (currentCraftingItem = 8) {
	currentItem := "Stalk Sprout Sprinkler"
        uiUniversal("214444444505405")

	sleepAmount(100, 300)
	searchItem("bamboo", 1, 0, 1)
    SelectEquipGive()
	searchItem("beanstalk", 1, 0, 1)
    SelectEquipGive()
	searchItem("mushroom", 1, 0, 1)
    SelectEquipGive()
	searchItem("advanced", 1)
    SelectEquipGive()
    Send, {vkC0sc029}
	Send, {e}
	sleepAmount(500, 1000)
	closeRobuxPrompt()

	bearCraftingLocked := 1
	SetTimer, UnlockBearCraft, -3600000
	SendDiscordMessage(webhookURL, "Crafting Attempted", "Attempted to craft " . currentItem . ".", COLOR_INFO)
        bearCraftActionQueue.RemoveAt(1)
        Sleep, 50
        if (bearCraftActionQueue.Length() = 0) {
            bearCraftCompleted := 1
        }
    }

    
    if (currentCraftingItem = 9) {
	currentItem := "Mutation Spray Choc"
        uiUniversal("2144444444505405")

	sleepAmount(100, 300)
	searchItem("cleaning", 1)
    SelectEquipGive()
	searchItem("cacao", 1, 0, 1)
    SelectEquipGive()
    Send, {vkC0sc029}
	Send, {e}
	sleepAmount(500, 1000)
	closeRobuxPrompt()

	bearCraftingLocked := 1
	SetTimer, UnlockBearCraft, -720000
	SendDiscordMessage(webhookURL, "Crafting Attempted", "Attempted to craft " . currentItem . ".", COLOR_INFO)
        bearCraftActionQueue.RemoveAt(1)
        Sleep, 50
        if (bearCraftActionQueue.Length() = 0) {
            bearCraftCompleted := 1
        }
    }

    
    if (currentCraftingItem = 10) {
	currentItem := "Mutation Spray Chilled"
        uiUniversal("21444444444505405")

	sleepAmount(100, 300)
	searchItem("cleaning", 1)
    SelectEquipGive()
	searchItem("godly", 1)
    SelectEquipGive()
    Send, {vkC0sc029}
	Send, {e}
	sleepAmount(500, 1000)
	closeRobuxPrompt()

	bearCraftingLocked := 1
	SetTimer, UnlockBearCraft, -300000
	SendDiscordMessage(webhookURL, "Crafting Attempted", "Attempted to craft " . currentItem . ".", COLOR_INFO)
        bearCraftActionQueue.RemoveAt(1)
        Sleep, 50
        if (bearCraftActionQueue.Length() = 0) {
            bearCraftCompleted := 1
        }
    }

    
    if (currentCraftingItem = 11) {
	currentItem := "Mutation Spray Shocked"
        uiUniversal("214444444444505405")

	sleepAmount(100, 300)
	searchItem("cleaning", 1)
    SelectEquipGive()
	searchItem("rod", 1)
    SelectEquipGive()
    Send, {vkC0sc029}
	Send, {e}
	sleepAmount(500, 1000)
	closeRobuxPrompt()

	bearCraftingLocked := 1
	SetTimer, UnlockBearCraft, -1800000
	SendDiscordMessage(webhookURL, "Crafting Attempted", "Attempted to craft " . currentItem . ".", COLOR_INFO)
        bearCraftActionQueue.RemoveAt(1)
        Sleep, 50
        if (bearCraftActionQueue.Length() = 0) {
            bearCraftCompleted := 1
        }
    }

    
    if (currentCraftingItem = 12) {
	currentItem := "Anti Bee Egg"
        uiUniversal("21444444444445054405")

	sleepAmount(100, 300)
    searchItem("anti.bee") ; put the anti bee egg in slot 2, cause when u search for bee egg it shows both, and can break the search function
	searchItem("bee.egg", 1)
    SelectEquipGive()
    searchItem("recall") ; equip again the wrench
    Send, {vkC0sc029}
	Send, {e}
	sleepAmount(500, 1000)
	closeRobuxPrompt()


	bearCraftingLocked := 1
	SetTimer, UnlockBearCraft, -7200000
	SendDiscordMessage(webhookURL, "Crafting Attempted", "Attempted to craft " . currentItem . ".", COLOR_INFO)
        bearCraftActionQueue.RemoveAt(1)
        Sleep, 50
        if (bearCraftActionQueue.Length() = 0) {
            bearCraftCompleted := 1
        }
    }

    
    if (currentCraftingItem = 13) {
	currentItem := "Pack Bee"
        uiUniversal("214444444444444505405")

	sleepAmount(100, 300)
	searchItem("anti", 1)
    SelectEquipGive()
	searchItem("sunflower", 1, 0, 1)
    SelectEquipGive()
	searchItem("purple", 1, 0, 1)
    SelectEquipGive()
    Send, {vkC0sc029}
	Send, {e}
	sleepAmount(500, 1000)
	closeRobuxPrompt()

	bearCraftingLocked := 1
	SetTimer, UnlockBearCraft, -14400000
	SendDiscordMessage(webhookURL, "Crafting Attempted", "Attempted to craft " . currentItem . ".", COLOR_INFO)
        bearCraftActionQueue.RemoveAt(1)
        Sleep, 50
        if (bearCraftActionQueue.Length() = 0) {
            bearCraftCompleted := 1
        }
    }
}

if (bearCraftCompleted) {
    sleepAmount(100, 300)
    hotbarController(0, 1, "2")
    Send, {c}
    sleepAmount(100, 300)
    uiUniversal("25050513205")
    SendDiscordMessage(webhookURL, "Bear Crafting Complete", "Finished the bear crafting cycle.", COLOR_COMPLETED)
    sleepAmount(100, 300)
}
Return