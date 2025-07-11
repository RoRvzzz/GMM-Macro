


PrehistoricCraftPath:

if (cycleCount = 0 && ManualDinosaurCraftLock > 0) {
	dinosaurCraftingLocked := 1
	SetTimer, UnlockDinosaurCraft, -%ManualDinosaurCraftLock%
Return
}

selectedDinosaurCraftingItems := []
Loop, 12 {
    lastRanItem := currentItem 
    IniRead, value, %A_ScriptDir%\Settings\settings.ini, DinosaurCrafting, Item%A_Index%, 0
    if (value = 1)
        selectedDinosaurCraftingItems.Push(A_Index)
}

if (dinosaurCraftActionQueue.Length() = 0) {
    for index, item in selectedDinosaurCraftingItems
        dinosaurCraftActionQueue.Push(item)
}


    dinosaurCompleted   := false
    shopOpened          := false
    dinosaurShopFailed  := false
        SendDiscordMessage(webhookURL, "[Debug] PrehistoricCraftPath", "Function started.", COLOR_INFO, false, true)

    WinActivate, ahk_exe RobloxPlayerBeta.exe
    Sleep, 100
    uiUniversal(1110)
    Sleep, % FastMode ? 500 : 2500
    Send, {d down}
    Sleep, 9050
    Send, {d up}
    sleepAmount(100, 1000)
    Send, {c}
    Sleep, % FastMode ? 100 : 300
    Send, {e}
    Sleep, % FastMode ? 100 : 300
    Send, {e}
    Sleep, % FastMode ? 100 : 500
    SendDiscordMessage(webhookURL, "Pre-Historic Cycle", "Starting pre-historic craft cycle.", COLOR_INFO)
    Sleep, % FastMode ? 2500 : 5000

    Loop, 5 {
        if ( simpleDetect(0x040837, 5, 0.49, 0.26, 0.55, 0.59)) {
            ToolTip, Dinosaur Crafter Opened
            SetTimer, HideTooltip, -1500
            Sleep, 1000
            CheckAndCloseBuyOption()
            shopOpened := true
            SendDiscordMessage(webhookURL, "Pre-Historic Crafter Status", "Pre-Historic Crafter Opened.", COLOR_INFO)
            }
            if (shopOpened) {
                break
            }
            Sleep, 2000
        }

    if (!shopOpened) {
        ToolTip, Failed to Open Dinosaur Crafter
        SetTimer, HideTooltip, -1500
        SendDiscordMessage(webhookURL, "Shop Detection Failed", "Failed to detect Pre-Historic Crafter opening.", COLOR_ERROR, PingSelected)
	    dinosaurShopFailed := true
        adaptiveUniversal("333222311113332223111105222222505", "3332223325050531111505")
        ShopFailSafe()
    Return
}

if (dinosaurCraftActionQueue.Length() > 0) {
    currentCraftingItem := dinosaurCraftActionQueue[1]

    if (currentCraftingItem = 1) {
	currentItem := "Mutation Spray Amber"
        uiUniversal("21505405")

	Sleep, 100
	searchItem("cleaning", 1)
    SelectEquipGive()       ; function stored on the main file btw
	searchItem("dinosaur", 1)
    SelectEquipGive()
    Send, {vkC0sc029}
	Send, {e}
	Sleep, 500
	closeRobuxPrompt()

	dinosaurCraftingLocked := 1
	SetTimer, UnlockDinosaurCraft, -3600000 
	SendDiscordMessage(webhookURL, "Crafting Attempted", "Attempted to craft " . currentItem . ".", COLOR_INFO)
        dinosaurCraftActionQueue.RemoveAt(1)
        Sleep, 50
        if (dinosaurCraftActionQueue.Length() = 0) {
            dinosaurCompleted := 1
        }
    }


    if (currentCraftingItem = 2) {
	currentItem := "Ancient Seed Pack"
    Sleep, % FastMode ? 150 : 450
        uiUniversal("21404405")

	Sleep, 100
	searchItem("dinosaur", 1)
    selectEquipGive()
    Send, {vkC0sc029}
	Send, {e}
	Sleep, 500
	closeRobuxPrompt()

	dinosaurCraftingLocked := 1
	SetTimer, UnlockDinosaurCraft, -3600000
	SendDiscordMessage(webhookURL, "Crafting Attempted", "Attempted to craft " . currentItem . ".", COLOR_INFO)
        dinosaurCraftActionQueue.RemoveAt(1)
        Sleep, 50
        if (dinosaurCraftActionQueue.Length() = 0) {
            dinosaurCompleted := 1
        }
    }


    if (currentCraftingItem = 3) {
    currentItem := "Dino Crate"
        uiUniversal("21444054405")

	Sleep, 100
	searchItem("dinosaur", 1)
    selectEquipGive()
    Send, {vkC0sc029}
	Send, {e}
	Sleep, 500
	closeRobuxPrompt()

	dinosaurCraftingLocked := 1
	SetTimer, UnlockDinosaurCraft, -1800000
	SendDiscordMessage(webhookURL, "Crafting Attempted", "Attempted to craft " . currentItem . ".", COLOR_INFO)
        dinosaurCraftActionQueue.RemoveAt(1)
        Sleep, 50
        if (dinosaurCraftActionQueue.Length() = 0) {
            dinosaurCompleted := 1
        }
    }

}
if (dinosaurCraftCompleted := true) {
    Sleep, % FastMode ? 100 : 200
	Send, {2}
	Send, {2}
    Send, {c}
    Sleep, % FastMode ? 100 : 200
    uiUniversal("25050513205")
    SendDiscordMessage(webhookURL, "Dinosaur Crafting Complete", "Finished the dinosaur crafting cycle.", COLOR_COMPLETED)
    Sleep, % FastMode ? 100 : 200
}
Return
