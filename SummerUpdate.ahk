;   GAG MACRO Yark Spade Crafting update +xTazerTx's GIGA UI Rework

#SingleInstance, Force
#NoEnv
SetWorkingDir %A_ScriptDir%
#WinActivateForce
SetMouseDelay, -1 
SetWinDelay, -1
SetControlDelay, -1
SetBatchLines, -1   

; globals

global webhookURL
global privateServerLink
global discordUserID
global PingSelected
global reconnectingProcess
global AutoHoney

global windowIDS := []
global currentWindow := ""
global firstWindow := ""
global instanceNumber
global idDisplay := ""
global started := 0
global failCount := 0

global cycleCount := 0
global cycleFinished := 0
global toolTipText := ""

global currentItem := ""
global currentArray := ""
global currentSelectedArray := ""
global indexItem := ""
global indexArray := []

global currentHour
global currentMinute
global currentSecond

global midX
global midY

global msgBoxCooldown := 0

global gearAutoActive := 0
global seedAutoActive := 0
global eggAutoActive  := 0
global summerAutoActive := 0
global autoHoneyActive := 0
global seedCraftingAutoActive := 0
global bearCraftingAutoActive := 0
global autoSummerHarvestActive := 0
global cosmeticAutoActive := 0
global lastSummerHour := -1
global lastSummerShopMinute := -1

global bearCraftingLocked := 0
global seedCraftingLocked := 0

global summerShopFailed := false

global actionQueue := []
global seedCraftActionQueue := []
global bearCraftActionQueue := []

settingsFile := A_ScriptDir "\settings.ini"
mainDir := A_ScriptDir . "\Images\"
subTabcosmeticpath := mainDir . "rbx background CosmeticShop.PNG"
subTabSeedPath  := mainDir . "background seedcaft subtab.PNG"
subTabBearPath  := mainDir . "background bearcraft subtab.PNG"

subTabSummerSelectPath := mainDir . "background summer shop.PNG"
subTabSummerRecordPath := mainDir . "background harvest tab.PNG"

BuyAllCosmetics := ["A", "B", "C"]
seedCraftingItems := ["X", "Y"]
bearCraftingItems := ["L", "M"]



HideAllCheckboxSets() {
    global BuyAllCosmetics, seedCraftingItems, bearCraftingItems, AutoHoney


    GuiControl, Hide, AutoHoney
    GuiControl, Hide, BuyAllCosmetics

    Loop, % BuyAllCosmetics.Length()
        GuiControl, Hide, % "BuyAllCosmetics" A_Index

    Loop, % seedCraftingItems.Length()
        GuiControl, Hide, % "SeedCraftingItem" A_Index
            GuiControl, Hide, SeedCraftLockLabel
        GuiControl, Hide, ManualSeedCraftLock

    Loop, % bearCraftingItems.Length()
        GuiControl, Hide, % "BearCraftingItem" A_Index
        GuiControl, Hide, BearCraftLockLabel
        GuiControl, Hide, ManualBearCraftLock

}
HideAllSummerControls() {
    global summerItems
    GuiControl, Hide, SelectAllSummer
    Loop, % summerItems.Length() {
        GuiControl, Hide, SummerItem%A_Index%
    }
    GuiControl, Hide, SummerRecord
    GuiControl, Hide, SummerTest
    GuiControl, Hide, SummerLoad
    GuiControl, Hide, SummerF4
    GuiControl, Hide, autoSummerHarvest
    GuiControl, Hide, numberOfCycleLabel
    GuiControl, Hide, numberOfCycle
    GuiControl, Hide, saveCycle
    GuiControl, Hide, collectMethodLabel
    GuiControl, Hide, savedHarvestSpeed
    GuiControl, Hide, autosummerharvestext
    GuiControl, Hide, explanationtext
    GuiControl, Hide, explanationtext1
    GuiControl, Hide, explanationtext2
    GuiControl, Hide, explanationtext3

}






global currentShop := ""

global selectedResolution

global scrollCounts_1080p, scrollCounts_1440p_100, scrollCounts_1440p_125
scrollCounts_1080p :=       [2, 4, 6, 8, 9, 11, 13, 14, 16, 18, 20, 21, 23, 25, 26, 28, 29, 31]
scrollCounts_1440p_100 :=   [3, 5, 8, 10, 13, 15, 17, 20, 22, 24, 27, 30, 31, 34, 36, 38, 40, 42]
scrollCounts_1440p_125 :=   [3, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 23, 25, 27, 29, 30, 31, 32]

global gearScroll_1080p, toolScroll_1440p_100, toolScroll_1440p_125
gearScroll_1080p     := [1, 2, 4, 6, 8, 9, 11, 13]
gearScroll_1440p_100 := [2, 3, 6, 8, 10, 13, 15, 17]
gearScroll_1440p_125 := [1, 3, 4, 6, 8, 9, 12, 12]

global COLOR_SUCCESS   := 3066993   ; Green
global COLOR_ERROR     := 15158332  ; Red
global COLOR_WARNING   := 15105570  ; Orange
global COLOR_INFO      := 3447003   ; Blue
global COLOR_COMPLETED := 9896155   ; Purple

global debugWebhookMode := 0

; http functions

SendDiscordMessage(webhookURL, title, description := "", color := 3447003, doPing := false, debugOnly := false) {
    global discordUserID, PingSelected, debugWebhookMode

    if (debugOnly && !debugWebhookMode)
        return

    if (!webhookURL || InStr(webhookURL, " "))
        return

    nowUTC := A_NowUTC
    FormatTime, isoTimestamp, %nowUTC%, yyyy-MM-ddTHH:mm:ss.000Z

    ; Basic JSON escaping
    title := StrReplace(StrReplace(title, "\", "\\"), """", "\""")
    description := StrReplace(StrReplace(StrReplace(description, "\", "\\"), """", "\"""), "`n", "\n")

    embed := "{""title"": """ . title . ""","
            . """description"": """ . description . ""","
            . """color"": " . color . ","
            . """timestamp"": """ . isoTimestamp . ""","
            . """footer"": {""text"": ""GAG MACRO""}}"

    jsonPayload := "{""embeds"": [" . embed . "]}"

    if (doPing && PingSelected && discordUserID) {
        pingContent := "<@" . discordUserID . ">"
        jsonPayload := "{""content"": """ . pingContent . """, ""embeds"": [" . embed . "]}"
    }

    whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
    try {
        whr.Open("POST", webhookURL, false)
        whr.SetRequestHeader("Content-Type", "application/json")
        whr.Send(jsonPayload)
        whr.WaitForResponse()
        status := whr.Status
        if (status != 200 && status != 204) {
            return
        }
    } catch {
        return
    }
}

checkValidity(url, msg := 0, mode := "nil") {

    global webhookURL
    global privateServerLink
    global settingsFile

    isValid := 0

    if (mode = "webhook" && (url = "" || !(InStr(url, "discord.com/api") || InStr(url, "discordapp.com/api")))) {
        isValid := 0
        if (msg) {
            MsgBox, 0, Message, Invalid Webhook
            IniRead, savedWebhook, %settingsFile%, Main, UserWebhook,
            GuiControl,, webhookURL, %savedWebhook%
        }
        return false
    }

    if (mode = "privateserver" && (url = "" || !InStr(url, "roblox.com/share"))) {
        isValid := 0
        if (msg) {
            MsgBox, 0, Message, Invalid Private Server Link
            IniRead, savedServerLink, %settingsFile%, Main, PrivateServerLink,
            GuiControl,, privateServerLink, %savedServerLink%
        }
        return false
    }

    try {
        whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
        whr.Open("GET", url, false)
        whr.Send()
        whr.WaitForResponse()
        status := whr.Status

        if (mode = "webhook" && (status = 200 || status = 204)) {
            isValid := 1
        } else if (mode = "privateserver" && (status >= 200 && status < 400)) {
            isValid := 1
        }
    } catch {
        isValid := 0
    }

    if (msg) {
        if (mode = "webhook") {
            if (isValid && webhookURL != "") {
                IniWrite, %webhookURL%, %settingsFile%, Main, UserWebhook
                MsgBox, 0, Message, Webhook Saved Successfully
            }
            else if (!isValid && webhookURL != "") {
                MsgBox, 0, Message, Invalid Webhook
                IniRead, savedWebhook, %settingsFile%, Main, UserWebhook,
                GuiControl,, webhookURL, %savedWebhook%
            }
        } else if (mode = "privateserver") {
            if (isValid && privateServerLink != "") {
                IniWrite, %privateServerLink%, %settingsFile%, Main, PrivateServerLink
                MsgBox, 0, Message, Private Server Link Saved Successfully
            }
            else if (!isValid && privateServerLink != "") {
                MsgBox, 0, Message, Invalid Private Server Link
                IniRead, savedServerLink, %settingsFile%, Main, PrivateServerLink,
                GuiControl,, privateServerLink, %savedServerLink%
            }
        }
    }

    return isValid

}


showPopupMessage(msgText := "nil", duration := 2000) {

    static popupID := 99

    ; get main GUI position and size
    WinGetPos, guiX, guiY, guiW, guiH, A

    innerX := 20
    innerY := 35
    innerW := 200
    innerH := 50
    winW := 200
    winH := 50
    x := guiX + (guiW - winW) // 2 - 40
    y := guiY + (guiH - winH) // 2

    if (!msgBoxCooldown) {
        msgBoxCooldown = 1
        Gui, %popupID%:Destroy
        Gui, %popupID%:+AlwaysOnTop -Caption +ToolWindow +Border
        Gui, %popupID%:Color, FFFFFF
        Gui, %popupID%:Font, s10 cBlack, Segoe UI
        Gui, %popupID%:Add, Text, x%innerX% y%innerY% w%innerW% h%innerH% BackgroundWhite Center cBlack, %msgText%
        Gui, %popupID%:Show, x%x% y%y% NoActivate
        SetTimer, HidePopupMessage, -%duration%
        Sleep, 2200
        msgBoxCooldown = 0
    }

}


; mouse functions

SafeMoveRelative(xRatio, yRatio) {

    global safeMoveDepth
    safeMoveDepth++
    if (safeMoveDepth > 10) {
        ToolTip, Infinite SafeMoveRelative recursion detected.
        SendDiscordMessage(webhookURL, "Infinite SafeMoveRelative recursion detected.")
        Sleep, 1500
        ToolTip
        safeMoveDepth--
        return
    }

    if WinExist("ahk_exe RobloxPlayerBeta.exe") {
        WinGetPos, winX, winY, winW, winH, ahk_exe RobloxPlayerBeta.exe
        moveX := winX + Round(xRatio * winW)
        moveY := winY + Round(yRatio * winH)
        MouseMove, %moveX%, %moveY%
    }

    safeMoveDepth--
}

SafeClickRelative(xRatio, yRatio) {

    if WinExist("ahk_exe RobloxPlayerBeta.exe") {
        WinGetPos, winX, winY, winW, winH, ahk_exe RobloxPlayerBeta.exe
        clickX := winX + Round(xRatio * winW)
        clickY := winY + Round(yRatio * winH)
        Click, %clickX%, %clickY%
    }

}

getMouseCoord(axis) {

    WinGetPos, winX, winY, winW, winH, ahk_exe RobloxPlayerBeta.exe
        CoordMode, Mouse, Screen
        MouseGetPos, mouseX, mouseY

        relX := (mouseX - winX) / winW
        relY := (mouseY - winY) / winH

        if (axis = "x")
            return relX
        else if (axis = "y")
            return relY

    return ""  ; error

}

; directional sequence encoder/executor
; if you're going to modify the calls to this make sure you know what you're doing (ui navigation has some odd behaviours)

uiUniversal(order := 0, exitUi := 1, continuous := 0, spam := 0, spamCount := 30, delayTime := 50, mode := "universal", index := 0, dir := "nil", itemType := "nil") {

    global SavedSpeed
    global SavedKeybind


    global indexItem
    global currentArray

    If (!order && mode = "universal") {
        return
    }

    if (!continuous) {
        sendKeybind(SavedKeybind)
        Sleep, 50   
    }  

    ; right = 1, left = 2, up = 3, down = 4, enter = 0, manual delay = 5
    if (mode = "universal") {

        Loop, Parse, order 
        {
            if (A_LoopField = "1") {
                repeatKey("Right", 1)
            }
            else if (A_LoopField = "2") {
                repeatKey("Left", 1)
            }
            else if (A_LoopField = "3") {
                repeatKey("Up", 1)
            }        
            else if (A_LoopField = "4") {
                repeatKey("Down", 1)
            }  
            else if (A_LoopField = "0") {
                repeatKey("Enter", spam ? spamCount : 1, spam ? 10 : 0)
            }       
            else if (A_LoopField = "5") {
                Sleep, 100
            } 
            else if (A_LoopField = "6") {
                Sleep, 100
            } 
            if (SavedSpeed = "Stable" && A_LoopField != "5") {
                Sleep, %delayTime%
            }
        }

    }
    else if (mode = "calculate") {

        previousIndex := findIndex(currentArray, indexItem)
        sendCount := index - previousIndex

        FileAppend, % "index: " . index . "`n", debug.txt
        FileAppend, % "previusIndex: " . previousIndex . "`n", debug.txt
        FileAppend, % "currentarray: " . currentArray.Name . "`n", debug.txt

        if (dir = "up") {
            repeatKey(dir)
            repeatKey("Enter")
            repeatKey(dir, sendCount)
        }
        else if (dir = "down") {
            FileAppend, % "sendCount: " . sendCount . "`n", debug.txt
            repeatKey(dir, sendCount)
            repeatKey("Enter")
            repeatKey(dir)
        }

    }
    else if (mode = "close") {

        if (dir = "up") {
            repeatKey(dir)
            repeatKey("Enter")
            repeatKey(dir, index)
        }
        else if (dir = "down") {
            repeatKey(dir, index)
            repeatKey("Enter")
            repeatKey(dir)
        }

    }

    if (exitUi) {
        Sleep, 50
        sendKeybind(SavedKeybind)
    }

    return

}

; universal shop buyer

buyUniversal(itemType) {

    global currentArray
    global currentSelectedArray
    global indexItem := ""
    global indexArray := []

        SendDiscordMessage(webhookURL, "[Debug] buyUniversal", "Starting for item type: " . itemType, COLOR_INFO, false, true)

    indexArray := []
    lastIndex := 0
    
    ; name array
    arrayName := itemType . "Items"
    currentArray := %arrayName%
    currentArray.Name := arrayName

    ; get arrays
    StringUpper, itemType, itemType, T

    selectedArrayName := "selected" . itemtype . "Items"
    currentSelectedArray := %selectedArrayName%

    ; get item indexes
    for i, selectedItem in currentSelectedArray {
        indexArray.Push(findIndex(currentArray, selectedItem))
    }

    ; buy items
    for i, index in indexArray {
        currentItem := currentSelectedArray[i]
                SendDiscordMessage(webhookURL, "[Debug] buyUniversal", "Processing item: " . currentItem . " at calculated index " . index, COLOR_INFO, false, true)
        Sleep, 50
        uiUniversal(, 0, 1, , , , "calculate", index, "down", itemType)
        indexItem := currentSelectedArray[i]
        sleepAmount(100, 200)
        quickDetect(0x26EE26, 0x1DB31D, 5, 0.4262, 0.2903, 0.6918, 0.8508)
        Sleep, 50
        lastIndex := index - 1
    }

    ; end
        SendDiscordMessage(webhookURL, "[Debug] buyUniversal", "Finished. Closing UI with lastIndex: " . lastIndex, COLOR_INFO, false, true)
    Sleep, 100
    uiUniversal(, 0, 1,,,, "close", lastIndex, "up", itemType)
    Sleep, 100

}

; helper functions

repeatKey(key := "nil", count := 1, delay := 30) {

    global SavedSpeed

    if (key = "nil") {
        return
    }

    Loop, %count% {
        Send {%key%}
        Sleep, % (SavedSpeed = "Ultra" ? (delay - 25) : SavedSpeed = "Max" ? (delay - 30) : delay)
    }

}

sendKeybind(keybind) {

    if (keybind = "\") {
        Send, \
    }
    else {
        Send, {%keybind%}
    }

}

sleepAmount(fastTime, slowTime) {

    global SavedSpeed

    Sleep, % (SavedSpeed != "Stable") ? fastTime : slowTime

}

findIndex(array := "", value := "", returnValue := "int") {
    
    FileAppend, % "Searching " . array.Name . " for " . value . "`n", debug.txt

    for index, item in array {
        if (value = item) {
            FileAppend, % "found " . value . " at index " . index "`n", debug.txt
            if (returnValue = "int") {
                return index
            }
            else if (returnValue = "bool") {
                return true
            }
        }
    }

    if (returnValue = "int") {
        return 1
    }
    else if (returnValue = "bool") {
        return false
    }

}

searchItem(search := "nil") {

    global UINavigationFix

    if(search = "nil") {
        Return
    }
    
    ;with UINavigationFix
    if (UINavigationFix) {
        uiUniversal("150524150505305", 0) 
        typeString(search)
        Sleep, 50

        if (search = "recall") {
            if (isFavoriteToggled(0.568, 0.565)){
                uiUniversal("2255055211550554155055", 1, 1)
            }
            else{
                uiUniversal("22211550554155055", 1, 1)
            }
        }
        uiUniversal(10)
    }
    else { ;without UINavigationFix
        uiUniversal("1011143333333333333333333311440", 0)
        Sleep, 50      
        typeString(search)
        Sleep, 50

        if (search = "recall") {
            uiUniversal("22211550554155055", 1, 1)
        }

        uiUniversal(10)
    }

}

typeString(string, enter := 1, clean := 1) {

    if (string = "") {
        Return
    }

    if (clean) {
        Send {BackSpace 20}
        Sleep, 100
    }

    Loop, Parse, string
    {
        Send, {%A_LoopField%}
        Sleep, 100
    }

    if (enter) {
        Send, {Enter}
    }

    Return

}

dialogueClick(shop) {

    Loop, 10 {
        Send, {WheelUp}
        Sleep, 20
    }

    sleepAmount(500, 1500)

    Loop, 1 {
        Send, {WheelDown}
        Sleep, 20
    }

    sleepAmount(500, 1500)

    if (shop = "gear") {
        SafeClickRelative(midX + 0.4, midY - 0.1)
    }

    Sleep, 500

    SafeMoveRelative(midX, midY)

}

hotbarController(select := 0, unselect := 0, key := "nil") {

    if ((select = 1 && unselect = 1) || (select = 0 && unselect = 0) || key = "nil") {
        Return
    }

    if (unselect) {
        Send, {%key%}
        Sleep, 200
        Send, {%key%}
    }
    else if (select) {
        Send, {%key%}
    }

}

closeRobuxPrompt() {

    Loop, 4 {
        Send {Escape}
        Sleep, 100
    }

}

getWindowIDS(returnIndex := 0) {

    global windowIDS
    global idDisplay
    global firstWindow

    windowIDS := []
    idDisplay := ""
    firstWindow := ""

    WinGet, robloxWindows, List, ahk_exe RobloxPlayerBeta.exe

    Loop, %robloxWindows% {
        windowIDS.Push(robloxWindows%A_Index%)
        idDisplay .= windowIDS[A_Index] . ", "
    }

    firstWindow := % windowIDS[1]

    StringTrimRight, idDisplay, idDisplay, 2

    if (returnIndex) {
        Return windowIDS[returnIndex]
    }
    
}

closeShop(shop, success) {

    StringUpper, shop, shop, T

    if (success) {

        Sleep, 500
        uiUniversal("4330320", 1, 1)

    }
    else {

        ToolTip, % "Error In Detecting " . shop
        SetTimer, HideTooltip, -1500
        SendDiscordMessage(webhookURL, "Shop Detection Failed", "Failed to detect " . shop . " shop opening.", COLOR_ERROR, PingSelected)
        ; failsafe
        uiUniversal("3332223111133322231111054105")

    }

}

walkDistance(order := 0, multiplier := 1) {

    ; later

}

sendMessages() {

    ; later

}

; color detectors

quickDetectEgg(buyColor, variation := 10, x1Ratio := 0.0, y1Ratio := 0.0, x2Ratio := 1.0, y2Ratio := 1.0) {

    global selectedEggItems
    global currentItem

    eggsCompleted := 0
    isSelected := 0

    eggColorMap := Object()
    eggColorMap["Common Egg"]    	:= "0xFFFFFF"
    eggColorMap["Uncommon Egg"]  	:= "0x81A7D3"
    eggColorMap["Rare Egg"]      	:= "0xBB5421"
    eggColorMap["Legendary Egg"] 	:= "0x2D78A3"
    eggColorMap["Mythical Egg"]  	:= "0x00CCFF"
    eggColorMap["Bug Egg"]       	:= "0x86FFD5"
    eggColorMap["Common Summer Egg"]    := "0x00FFFF"
    eggColorMap["Rare Summer Egg"]      := "0xFFFFAA"
    eggColorMap["Paradise Egg"]         := "0x32CDFF"
    eggColorMap["Bee Egg"]              := "0xFFAA00"

    Loop, 5 {
        for rarity, color in eggColorMap {
            currentItem := rarity
            isSelected := 0

            for i, selected in selectedEggItems {
                if (selected = rarity) {
                    isSelected := 1
                    break
                }
            }

            ; check for the egg on screen, if its selected it gets bought
            if (simpleDetect(color, variation, 0.41, 0.32, 0.54, 0.38)) {
                if (isSelected) {
                    quickDetect(buyColor, 0, 5, 0.4, 0.60, 0.65, 0.70, 0, 1)
                    eggsCompleted = 1
                    break
                } else {
                    if (simpleDetect(buyColor, variation, 0.40, 0.60, 0.65, 0.70)) {
                        ToolTip, % currentItem . "`nIn Stock, Not Selected"
                        SetTimer, HideTooltip, -1500
                        SendDiscordMessage(webhookURL, "Item In Stock", currentItem . " is in stock but not selected in the GUI.", COLOR_INFO)
                    }
                    else {
                        ToolTip, % currentItem . "`nNot In Stock, Not Selected"
                        SetTimer, HideTooltip, -1500
                        SendDiscordMessage(webhookURL, "Item Out of Stock", currentItem . " was not in stock.", COLOR_INFO)
                    }
                    if (UINavigationFix) {
                        uiUniversal(3140, 1, 1)
                    }
                    else {
                        uiUniversal(1105, 1, 1)
                    }
                    eggsCompleted = 1
                    break
                }
            }    
        }
        ; failsafe
        if (eggsCompleted) {
            return
        }
        Sleep, 1500
    }
    
    if (!eggsCompleted) {
        uiUniversal(5, 1, 1)
        ToolTip, Error In Detection
        SetTimer, HideTooltip, -1500
        SendDiscordMessage(webhookURL, "Egg Detection Error", "Failed to detect any egg after 5 attempts.", COLOR_ERROR, PingSelected)
    }

}

isFavoriteToggled(xRatio, yRatio, variation := 10, showMarker := false) {
    CoordMode, Pixel, Screen
    WinGetPos, winX, winY, winW, winH, ahk_exe RobloxPlayerBeta.exe

    x := winX + Round(xRatio * winW)
    y := winY + Round(yRatio * winH)

    PixelGetColor, color, x, y, RGB

    r := (color >> 16) & 0xFF
    g := (color >> 8) & 0xFF
    b := color & 0xFF

    return (Abs(r - 255) <= variation && Abs(g - 255) <= variation && Abs(b - 255) <= variation)
}

simpleDetect(colorInBGR, variation, x1Ratio := 0.0, y1Ratio := 0.0, x2Ratio := 1.0, y2Ratio := 1.0) {

    CoordMode, Pixel, Screen
    CoordMode, Mouse, Screen

    ; limit search to specified area
	WinGetPos, winX, winY, winW, winH, ahk_exe RobloxPlayerBeta.exe

    x1 := winX + Round(x1Ratio * winW)
    y1 := winY + Round(y1Ratio * winH)
    x2 := winX + Round(x2Ratio * winW)
    y2 := winY + Round(y2Ratio * winH)

    PixelSearch, FoundX, FoundY, x1, y1, x2, y2, colorInBGR, variation, Fast
    if (ErrorLevel = 0) {
        return true
    }

}

quickDetect(color1, color2, variation := 10, x1Ratio := 0.0, y1Ratio := 0.0, x2Ratio := 1.0, y2Ratio := 1.0, item := 1, egg := 0) {

    CoordMode, Pixel, Screen
    CoordMode, Mouse, Screen

    stock := 0
    eggDetected := 0

    global currentItem
    global UINavigationFix
    
    ; change to whatever you want to be pinged for
    pingItems := []

	ping := false

    if (PingSelected) {
        for i, pingitem in pingItems {
            if (pingitem = currentItem) {
                ping := true
                break
            }
        }
    }

    ; limit search to specified area
	WinGetPos, winX, winY, winW, winH, ahk_exe RobloxPlayerBeta.exe

    x1 := winX + Round(x1Ratio * winW)
    y1 := winY + Round(y1Ratio * winH)
    x2 := winX + Round(x2Ratio * winW)
    y2 := winY + Round(y2Ratio * winH)

    ; for seeds/gears checks if either color is there (buy button)
    if (item) {
        for index, color in [color1, color2] {
            PixelSearch, FoundX, FoundY, x1, y1, x2, y2, %color%, variation, Fast RGB
            if (ErrorLevel = 0) {
                stock := 1
                ToolTip, %currentItem% `nIn Stock
                SetTimer, HideTooltip, -1500  
                uiUniversal(50, 0, 1, 1)
                Sleep, 50
                if (ping)
                    SendDiscordMessage(webhookURL, "Item Purchased", "Successfully bought " . currentItem . ".", COLOR_SUCCESS, ping)
                else
                    SendDiscordMessage(webhookURL, "Item Purchased", "Successfully bought " . currentItem . ".", COLOR_SUCCESS)
            }
        }
    }

    ; for eggs
    if (egg) {
        PixelSearch, FoundX, FoundY, x1, y1, x2, y2, color1, variation, Fast RGB
        if (ErrorLevel = 0) {
            stock := 1
            ToolTip, %currentItem% `nIn Stock
            SetTimer, HideTooltip, -1500  
            uiUniversal(500, 1, 1)
            Sleep, 50
            if (ping)
                SendDiscordMessage(webhookURL, "Item Purchased", "Successfully bought " . currentItem . ".", COLOR_SUCCESS, ping)
            else
                SendDiscordMessage(webhookURL, "Item Purchased", "Successfully bought " . currentItem . ".", COLOR_SUCCESS)
        }
        if (!stock) {
            if (UINavigationFix) {
                uiUniversal(3140, 1, 1)
            }
            else {
                uiUniversal(1105, 1, 1)
            }
            SendDiscordMessage(webhookURL, "Item Out of Stock", currentItem . " was not in stock.", COLOR_INFO)  
        }
    }

    Sleep, 100

    if (!stock) {
        ToolTip, %currentItem% `nNot In Stock
        SetTimer, HideTooltip, -1500
        ; SendDiscordMessage(webhookURL, currentItem . " Not In Stock.")  
    }

}


BuyOptionDetect(variation, x1Ratio := 0.0, y1Ratio := 0.0, x2Ratio := 1.0, y2Ratio := 1.0, colors*) {

    CoordMode, Pixel, Screen
    CoordMode, Mouse, Screen

    ; limit search to specified area
	WinGetPos, winX, winY, winW, winH, ahk_exe RobloxPlayerBeta.exe

    x1 := winX + Round(x1Ratio * winW)
    y1 := winY + Round(y1Ratio * winH)
    x2 := winX + Round(x2Ratio * winW)
    y2 := winY + Round(y2Ratio * winH)

    ; Check each color
    for index, color in colors {
        PixelSearch, FoundX, FoundY, x1, y1, x2, y2, %color%, variation, Fast
        if (ErrorLevel = 0) {
            return true
        }
    }
    return false
}

CheckAndCloseBuyOption() {
    if (BuyOptionDetect(0, 0.35, 0.55, 0.46, 0.63, 0x26EE26, 0x646464, 0x1DB31D)) {     ; if u want to add another color,
        ToolTip, Buy Option Detected...                                                 ; simply add it here lol, 
        SetTimer, HideTooltip, -1500                                                    ; i used colors* to be easier
        Sleep, 500                                                                      ; to change if u have to
        BuyOptionClose()                                                                ; be careful there is lot of 
        Sleep, 100                                                                      ; false positive, mostly with
    } else {                                                                            ; the NO STOCK button so dont
        ToolTip, Buy Option Was Not Detected.                                           ; change any color here if you 
        SetTimer, HideTooltip, -1500                                                    ; dont know what u are doing
        Sleep, 500                                                                      ; btw colors are in BGR format
    }
}

BuyOptionClose() {
    Sleep, 100
    uiUniversal("333333223210") ; close buy option btw, most of it is just to make sure it starts from settings icon, the real part is 210
    SendDiscordMessage(webhookURL, "Buy Option Detected.", "Buy Option Has Been Detected And Closed", COLOR_INFO)
    Sleep, 100
}


; item arrays

seedItems := ["Carrot Seed", "Strawberry Seed", "Blueberry Seed"
             , "Tomato Seed", "Cauliflower Seed", "Watermelon Seed", "Rafflesia Seed"
             , "Green Apple Seed", "Avacado Seed", "Banana Seed", "Pineapple Seed"
             , "Kiwi Seed", "Bell Pepper Seed", "Prickly Pear Seed", "Loquat Seed"
             , "Feijoa Seed", "Pitcher Plant Seed", "Sugar Apple Seed"] ;

gearItems := ["Watering Can", "Trowel", "Recall Wrench", "Basic Sprinkler", "Advanced Sprinkler"
             , "Godly Sprinkler", "Magnifying Glass", "Tanning Mirror", "Master Sprinkler", "Cleaning Spray", "Favorite Tool", "Harvest Tool", "Friendship Pot"]

eggItems := ["Common Egg", "Rare Summer Egg", "Bee Egg", "Common Summer Egg", "Paradise Egg", "Mythical Egg"
             , "Bug Egg"]

cosmeticItems := ["Cosmetic 1", "Cosmetic 2", "Cosmetic 3", "Cosmetic 4", "Cosmetic 5"
             , "Cosmetic 6",  "Cosmetic 7", "Cosmetic 8", "Cosmetic 9"]

summerItems := ["Summer Seed Pack", "Delphinium Seed", "Lily of the Valley Seed", "Travelers Fruit Seed", "Muatation Spray Burnt"
	   , "Oasis Crate", "Oasis Egg", "Hamster"]

bearCraftingItems := ["Lightning Rod", "Reclaimer", "Tropical Mist Sprinkler", "Berry Blusher Sprinkler", "Spice Spritzer Sprinkler", "Sweet Soaker Sprinkler"
	  , "Flower Froster Sprinkler", "Stalk Sprout Sprinkler", "Mutation Spray Choc", "Mutation Spray Chilled", "Mutation Spray Shocked"
	  , "Anti Bee Egg", "Pack Bee"]

seedCraftingItems := ["Peace Lily Seed", "Aloe Vera Seed", "Guanabana Seed"]
	

settingsFile := A_ScriptDir "\settings.ini"

;Gosub, RunDiagnostics
Gosub, ShowGui
Return
; main ui
RunDiagnostics:
    SplashTextOn, 200, 30, GAG MACRO, Running diagnostics...
    Sleep, 500 ; Give it a moment to display
    errorMessages := ""
    criticalErrors := false
    

    if InStr(A_ScriptDir, A_Temp) {
        errorMessages .= "- Macro is running from a temporary folder. Please extract all files from the archive before running.`n"
    }
    

    Process, Exist, RobloxPlayerBeta.exe
    if (!ErrorLevel) {
        errorMessages .= "- Roblox process not found. Please open Roblox before using the macro.`n"
    }
    

    if (SubStr(A_AhkVersion, 1, 1) = "2") {
        errorMessages .= "- This script requires AutoHotkey v1.1, but you are running v2. Please install AHK v1.1.`n"
        criticalErrors := true
    } else if (A_AhkVersion < "1.1.33") {
        errorMessages .= "- Outdated AHK v1 version (" . A_AhkVersion . ") detected. Please update to the latest v1.1 release.`n"
    }
    

    if (A_ScreenDPI != 96 && A_ScreenDPI != 144) { ; 100% or 125%
        errorMessages .= "- Uncommon DPI scaling detected (" . A_ScreenDPI . " DPI). Please set display scaling to 100% or 125% or 150% in Windows settings.`n"
    }
    

    is16x9 := (A_ScreenWidth * 9 = A_ScreenHeight * 16)
    if (!is16x9) {
        errorMessages .= "- Unsupported screen resolution (" . A_ScreenWidth . "x" . A_ScreenHeight . "). A 16:9 aspect ratio is required (e.g., 1920x1080, 2560x1440).`n"
    }
    
    SplashTextOff
    

    hkl := DllCall("GetKeyboardLayout", "UInt", 0)
    layoutID := hkl & 0xFFFF
    layoutHex := Format("{:04X}", layoutID)
    if (layoutHex != "0409") { ; Not English (United States)
        MsgBox, 4, Keyboard Layout Warning, Current keyboard layout is not English (US) (ID: 0x%layoutHex%). This can sometimes cause unexpected behavior.`n`nIt is recommended to switch to an 'English (United States)' layout.`n`nClick YES to continue anyway, or NO to exit.
        IfMsgBox No
            ExitApp
    }
    
    if (errorMessages != "") {
        if (criticalErrors) {
            ; Critical errors that really shouldn't be skipped
            MsgBox, 16, Critical Issues Found, The following critical issues were found:`n`n%errorMessages%`n`nThese issues will likely cause the macro to fail completely.
            ExitApp
        } else {
            ; Non-critical warnings that can be skipped
            MsgBox, 4, Diagnostic Warnings, The following issues were found:`n`n%errorMessages%`n`nThese may cause the macro to not work properly.`n`nClick YES to continue anyway, or NO to exit.
            IfMsgBox No
                ExitApp
        }
    }

Return
ShowGui:
    Gui, Destroy
    Gui, -MinimizeBox -Caption
    Gui, Color, 0x202020  ; Needed for transparency to work properly
    WinSet, TransColor, 0x202020  ; Make black fully transparent
    Gui, Add, Picture, x0 y0 w520 h425 BackgroundTrans, % mainDir "rbx window background .PNG"
    
    Gui, Add, Picture, x0 y0 w520 h425 BackgroundTrans, % mainDir "background minimize button.PNG"
    Gui, Add, Picture, x0 y0 w520 h425 BackgroundTrans, % mainDir "background close button.PNG"
    Gui, Add, Picture, x0 y0 w520 h425 BackgroundTrans, % mainDir "background settings rbx macro Tabsfixed.PNG" 

    Gui, Add, Text, x496 y0 w24 h24 BackgroundTrans gCloseApp
    Gui, Add, Text, x0 y0 w24 h24 BackgroundTrans gMinimizeApp
    Gui, Add, Text, x0 y0 w472 h15 BackgroundTrans gDragWindow







    Gui, Font, s9 cWhite, Segoe UI
    Gui, Add, Tab , x0 y24 w540 h24 vMyTab,`n    Seeds    |    Gears    |    Eggs    |   Cosmetics   |    Summer    |     Settings     |   Credits`n    |
    guicontrol, choose, mytab, 6

    Gui, Tab, 1
    Gui, Add, Picture, x0 y0 w520 h425 BackgroundTrans, % mainDir "rbx background Seed tab.PNG"
    IniRead, SelectAllSeeds, %settingsFile%, Seed, SelectAllSeeds, 0
    Gui, Add, CheckBox, % "x391 y135 w12 h12 vSelectAllSeeds gHandleSelectAll -Theme Background3C3C3C " . (SelectAllSeeds ? "Checked" : "")
    

Loop, % seedItems.Length() {
        IniRead, sVal, %settingsFile%, Seed, Item%A_Index%, 0
        if (A_Index > 12) {
            col := 369
            idx := A_Index - 13
            yBase := 183
        }
        else if (A_Index > 6) {
            col := 198
            idx := A_Index - 7
            yBase := 183

        }
        else {
            col := 23
            idx := A_Index
            yBase := 143
        }
        y := yBase + (idx * 40)
        Gui, Add, Checkbox, % "x" col " y" y " w12 h12 vSeedItem" A_Index " gHandleSelectAll cD3D3D3 " . (sVal ? "Checked" : ""), 

    }

    Gui, Tab, 2
    Gui, Add, Picture, x0 y0 w520 h425 BackgroundTrans, % mainDir "rbx background Gears tab.PNG"

    IniRead, SelectAllGears, %settingsFile%, Gear, SelectAllGears, 0
    Gui, Add, Checkbox, % "x391 y135 w12 h12 vSelectAllGears gHandleSelectAll c87CEEB " . (SelectAllGears ? "Checked" : ""), Select All Gears 


    Loop, % gearItems.Length() {
        IniRead, gVal, %settingsFile%, Gear, Item%A_Index%, 0
        if (A_Index > 9) {
            col := 373
            idx := A_Index - 10
            yBase := 192
        }
        else if (A_Index > 4) {
            col := 200
            idx := A_Index - 5
            yBase := 192
        
        }
        else {
            col := 28
            idx := A_Index
            yBase := 160
        }
        y := yBase + (idx * 31)
        Gui, Add, Checkbox, % "x" col " y" y " w12 h12 vGearItem" A_Index " gHandleSelectAll cD3D3D3 " . (gVal ? "Checked" : ""), 

    }
    Gui, Tab, 3
    Gui, Add, Picture, x0 y0 w520 h425 BackgroundTrans, % mainDir "rbx background egg tab.PNG"
    IniRead, SelectAllEggs, %settingsFile%, Egg, SelectAllEggs, 0
    Gui, Add, CheckBox, % "x391 y135 w12 h12 vSelectAllEggs gHandleSelectAll -Theme BackgroundTrans ce87b07 " . (SelectAllEggs ? "Checked" : "")

    Loop, % eggItems.Length() {
        IniRead, eVal, %settingsFile%, Egg, Item%A_Index%, 0
        if (A_Index > 5) {
            col := 375
            idx := A_Index - 6
            yBase := 260
        }
        else if (A_Index > 3) {
            col := 200
            idx := A_Index - 4
            yBase := 260
        
        }
        else if (A_Index > 2) {
            col := 23
            idx := A_Index - 3
            yBase := 370
        
        }
        else if (A_Index > 1) {
            col := 23
            idx := A_Index - 2
            yBase := 300
        
        }
        else if (A_Index > 0) {
            col := 23
            idx := A_Index - 1
            yBase := 235
        
        }        
        
        y := yBase + (idx * 112)
        Gui, Add, Checkbox, % "x" col " y" y " w12 h12 vEggItem" A_Index " gHandleSelectAll cD3D3D3 " . (eVal ? "Checked" : ""), % eggItems[A_Index]


    }

    Gui, Tab, 4
    Gui, Add, Picture, x0 y0 w520 h425 BackgroundTrans, % mainDir "rbx background CosmeticShop.PNG"

    Gui, Add, Picture, x0 y0 w520 h425 vSubTabImage BackgroundTrans, % subTabSummerPath

    ;   Gui, Add, Picture, x0 y0 w520 h425 vSubTabImage BackgroundTrans, % subTabSummerPath
    ; Text "buttons" to switch tabs - must contain text to be clickable
    Gui, Add, Text, x12  y80 w130 h40 gShowcosmeticSubTab BackgroundTrans,
    Gui, Add, Text, x140 y80 w130 h40 gShowSeedSubTab  BackgroundTrans,
    Gui, Add, Text, x282 y80 w130 h40 gShowBearSubTab  BackgroundTrans,
    ;just saving stuff dont ask    color 32CD32                             background seedcaft subtab.PNG          background bearcraft subtab.PNG
    ;Gui, Add, Text, x152 y80 w120 h40 gShowSeedSubTab  BackgroundTrans,seed  
    ;Gui, Add, Text, x293 y80 w120 h40 gShowBearSubTab  BackgroundTrans,bear



    IniRead, BuyAllCosmetics, %settingsFile%, Cosmetic, BuyAllCosmetics, 0
    Gui, Add, CheckBox, % "x61 y118 w12 h12 vBuyAllCosmetics gHandleSelectAll -Theme BackgroundTrans cD41551 " . (BuyAllCosmetics ? "Checked" : "")
    IniRead, AutoHoneySetting, %settingsFile%, AutoHoney, AutoHoneySetting, 0
    Gui, Add, CheckBox, % "x379 y135 w12 h12 vAutoHoney gSaveAutoHoney BackgroundTrans c00FF00 " . (AutoHoneySetting ? "Checked" : ""), submite pollinated

    ; ----- SeedCrafting Set -----
    Loop, % seedCraftingItems.Length() {
        IniRead, sVal, %settingsFile%, SeedCrafting, Item%A_Index%, 0
        if (A_Index > 2) {
            col := 374, idx := A_Index - 3, yBase := 213
        } else if (A_Index > 1) {
            col := 199, idx := A_Index - 2, yBase := 213
        } else {
            col := 25, idx := A_Index, yBase := 143
        }
        y := yBase + (idx * 70)
        Gui, Add, Checkbox, % "x" col " y" y " w12 h12 vSeedCraftingItem" A_Index " gHandleSelectAll cWhite BackgroundTrans " . (sVal ? "Checked" : ""), % seedCraftingItems[A_Index]
    }

    ; === Seed Craft Lock ===
    IniRead, ManualSeedCraftLock, %settingsFile%, Main, ManualSeedCraftLock, 0
    Gui, Add, Edit, x369 y132 w36 h18 vManualSeedCraftLock gUpdateCraftLock -Theme cBlack, %ManualSeedCraftLock%

    ; ----- BearCrafting Set -----
    Loop, % bearCraftingItems.Length() {
        IniRead, bVal, %settingsFile%, BearCrafting, Item%A_Index%, 0
    if (A_Index > 8) {
        col := 374, idx := A_Index - 9, yBase := 183  ; was 183
    } else if (A_Index > 4) {
        col := 199, idx := A_Index - 5, yBase := 183  ; was 183
    } else {
        col := 25, idx := A_Index, yBase := 133
    }
        y := yBase + (idx * 50)
        Gui, Add, Checkbox, % "x" col " y" y " w12 h12 vBearCraftingItem" A_Index " gHandleSelectAll cWhite BackgroundTrans " . (bVal ? "Checked" : ""), % bearCraftingItems[A_Index]
    }
    ; === Bear Craft Lock ===
    IniRead, ManualBearCraftLock, %settingsFile%, Main, ManualBearCraftLock, 0
    Gui, Add, Edit, x369 y132 w36 h18 vManualBearCraftLock gUpdateCraftLock -Theme cBlack, %ManualBearCraftLock%
    
        HideAllCheckboxSets()
Gosub, ShowcosmeticSubTab

    Gui, Tab, 5
    Gui, Add, Picture, x0 y0 w520 h425 BackgroundTrans, % mainDir "background harvest tab.PNG"
    Gui, Add, Picture, x0 y0 w520 h425 BackgroundTrans, % mainDir "background summer shop.PNG"
    Gui, Add, Picture, x0 y0 w520 h425 BackgroundTrans vPicSummerShop, % subTabSummerSelectPath
    Gui, Add, Picture, x0 y0 w520 h425 BackgroundTrans vPicHarvestTab, % subTabSummerRecordPath

; Initially show summer shop background, hide harvest tab
GuiControl, Show, PicSummerShop
GuiControl, Hide, PicHarvestTab

   
    Gui, Add, Text, x12  y80 w130 h40 gShowSummerSelectSubTab BackgroundTrans,
    Gui, Add, Text, x140 y80 w130 h40 gShowSummerRecordSubTab BackgroundTrans,

    ; Select All checkbox
    IniRead, SelectAllSummer, %settingsFile%, Summer, SelectAll, 0
    Gui, Add, CheckBox, % "x391 y135 w12 h12 vSelectAllSummer gHandleSelectAll BackgroundTrans cFFD700 " . (SelectAllSummer ? "Checked" : "")

    ; Summer item checkboxes
    Gui, Font, s9 cWhite Bold, Segoe UI
    Loop, % summerItems.Length() {
        IniRead, hVal, %settingsFile%, Summer, Item%A_Index%, 0
        if (A_Index > 6) {
            col := 375, idx := A_Index - 7, yBase := 193
        } else if (A_Index > 3) {
            col := 200, idx := A_Index - 4, yBase := 193
        } else {
            col := 20, idx := A_Index, yBase := 143
        }
        y := yBase + (idx * 50)
        Gui, Add, Checkbox, % "x" col " y" y " w13 h13 vSummerItem" A_Index " gHandleSelectAll cWhite BackgroundTrans " . (hVal ? "Checked" : ""), % SummerItems[A_Index]
    }

    ; Buttons
    Gui, Add, Button, x202 y185 w120 h40 gToggleRecording vSummerRecord Background202020, Record New Path `n(F1)
    Gui, Add, Button, x202 y350 w120 h40 gDemoInput vSummerTest Background202020, Test Path `n(F2)
    Gui, Add, Button, x375 y350 w120 h40 gLoadInputs vSummerLoad Background202020, Load Saved Path `n(F3)
    Gui, Add, Button, x25 y350 w120 h40 gF4 vSummerF4 Background202020, Test Auto-Harvest `n(F4)

    ; Auto-collect checkbox
    IniRead, autoSummerHarvest, %settingsFile%, Main, SummerHarvest, 0
    Gui, Add, Checkbox, x20 y137 w13 h13 vautoSummerHarvest cFF7518, Auto-Collect & Submit Summer Harvest
    Gui, Font, s9 cWhite Bold, Segoe UI
    Gui, Add, Text, x35 y137 BackgroundTrans vautosummerharvestext cFF7518 , Auto Harvest and submit




    ; Number of Cycle
    Gui, Font, s9 cWhite Bold, Segoe UI
    Gui, Add, Text, x195 y137 BackgroundTrans cFF7518 vnumberOfCycleLabel, Number of Cycle

    IniRead, savedNumberOfCycle, %settingsFile%, Main, NumberOfCycle
    if (savedNumberOfCycle = "ERROR" || savedNumberOfCycle = "")
        savedNumberOfCycle := 3

    Gui, Font, s8 c000000 Bold, Segoe UI
    Gui, Add, Edit, x290 y135 w25 h18 vnumberOfCycle +BackgroundFFFFFF, %savedNumberOfCycle%

    Gui, Font, s8 cD3D3D3 Bold, Segoe UI
    Gui, Add, Button, x460 y137 w35 h18 gUpdateNumberOfCycle vsaveCycle Background202020, Save

    ; Collect method
    Gui, Font, s9 cWhite Bold, Segoe UI
    Gui, Add, Text, x328 y137 BackgroundTrans cFF7518 vcollectMethodLabel, Collect Method

    Gui, Font, s8 cBlack, Segoe UI
    IniRead, savedHarvestSpeed, %settingsFile%, Main, HarvestSpeed, Stable
    Gui, Add, DropDownList, vsavedHarvestSpeed gUpdateHarvestSpeed x415 y134 w35, Stable|Fast
    GuiControl, ChooseString, savedHarvestSpeed, %savedHarvestSpeed%
    Gui, Font, s8 cBlack, Segoe UI
    Gui, Add, Text, x25 y190 w120 BackgroundTrans cwhite vexplanationtext,
    ( 
Press F1 and wait the alignment to finish.

After the alignment finishes,
proceed to use only the keyboard  to navigate to your target plant to harvest.
)
    Gui, Add, Text, x200 y240 w120 BackgroundTrans cwhite vexplanationtext1,
( 
Once you finished to navigate to your target plant, Press F1 again to stop recording the path.
     )
     Gui, Add, Text, x375 y190 w120 BackgroundTrans cwhite vexplanationtext2,
( 
Press F2 to see if your path is correctly recorded. 

Once it's all done, you can now start the macro and the Summer Harvest is now automated.

     )
     Gui, Add, Text, x395 y392 w120 BackgroundTrans cwhite vexplanationtext3,
     (
       CREDIT-nasayuzaki- 
     )
 HideAllSummerControls()
 Gosub, ShowSummerSelectSubTab


    Gui, Tab, 6
    
    ; Invisible hotspots (replacing buttons)
    Gui, Add, Text, x390 y86  w100 h16 gDisplayWebhookValidity BackgroundTrans 0x4
    Gui, Add, Text, x390 y111 w100 h16 gUpdateUserID          BackgroundTrans 0x4
    Gui, Add, Text, x390 y135 w100 h16 gDisplayServerValidity BackgroundTrans 0x4
    Gui, Add, Text, x217 y164 w85  h18 gClearSaves            BackgroundTrans 0x4
    Gui, Add, Text, x15  y370 w105 h40 gStartScanMultiInstance BackgroundTrans 0x4
    Gui, Add, Text, x405 y370 w105 h40 gQuit                  BackgroundTrans 0x4
    Gui, Add, Text, x240 y385 w40  h25 gGui2                  BackgroundTrans 0x4
    Gui, Add, Text, x414 y251 w84  h20 gGui4                  BackgroundTrans 0x4
    Gui, Add, Text, x414 y218 w84  h20 gGui5                  BackgroundTrans 0x4

    
  
    Gui, Add, Picture, x0 y0 w520 h425 BackgroundTrans, % mainDir "rbx macro setting  tab backgroundfixed.PNG"
    Gui, Add, Picture, x0 y0 w520 h425 BackgroundTrans, % mainDir "background settings rbx button help.PNG"
    Gui, Add, Picture, x0 y0 w520 h425 BackgroundTrans, % mainDir "background settings rbx button start.PNG"
    Gui, Add, Picture, x0 y0 w520 h425 BackgroundTrans, % mainDir "background settings rbx button stop.PNG"
    Gui, Add, Picture, x0 y0 w520 h425 BackgroundTrans, % mainDir "rbx macro setting  tab Save Webhook button.PNG"
    Gui, Add, Picture, x0 y0 w520 h425 BackgroundTrans, % mainDir "rbx macro setting  tab clear save button.PNG"
    Gui, Add, Picture, x0 y0 w520 h425 BackgroundTrans, % mainDir "rbx macro setting  tab Save PS Link button.PNG"
    Gui, Add, Picture, x0 y0 w520 h425 BackgroundTrans, % mainDir "rbx macro setting  tab Save User ID button.PNG"
    Gui, Add, Picture, x0 y0 w520 h425 BackgroundTrans, % mainDir "rbx macro setting  tab Eggs button1.PNG"
    Gui, Add, Picture, x0 y-3 w520 h425 BackgroundTrans, % mainDir "rbx macro setting  tab Pets button.PNG" 


    ; opt1 := (selectedResolution = 1 ? "Checked" : "")
    ; opt2 := (selectedResolution = 2 ? "Checked" : "")
    ; opt3 := (selectedResolution = 3 ? "Checked" : "")
    ; opt4 := (selectedResolution = 4 ? "Checked" : "")
    
    ;Gui, Add, GroupBox, x30 y200 w260 h110, Resolution
    ; Gui, Add, Text, x35 y220, Resolutions:
    ; IniRead, selectedResolution, %settingsFile%, Main, Resolution, 1
    ; Gui, Add, Radio, x35 y240 vselectedResolution gUpdateResolution c708090 %opt1%, 2560x1440 125`%
    ; Gui, Add, Radio, x35 y260 gUpdateResolution c708090 %opt2%, 2560x1440 100`%
    ; Gui, Add, Radio, x35 y280 gUpdateResolution c708090 %opt3%, 1920x1080 100`%
    ; Gui, Add, Radio, x35 y300 gUpdateResolution c708090 %opt4%, 1280x720 100`%


        IniRead, PingSelected, %settingsFile%, Main, PingSelected, 0
    pingColor := PingSelected ? "c90EE90" : "cD3D3D3"
    Gui, Add, Checkbox, % "x140 y246 w12 h12 vPingSelected gUpdateSettingColor " . pingColor . (PingSelected ? " Checked" : ""), Discord Item Pings
    
    IniRead, AutoAlign, %settingsFile%, Main, AutoAlign, 0
    autoColor := AutoAlign ? "c90EE90" : "cD3D3D3"
    Gui, Add, Checkbox, % "x105 y272 w12 h12 vAutoAlign gUpdateSettingColor " . autoColor . (AutoAlign ? " Checked" : ""), Auto-Align


    IniRead, MultiInstanceMode, %settingsFile%, Main, MultiInstanceMode, 0
    multiInstanceColor := MultiInstanceMode ? "c90EE90" : "cD3D3D3"
    Gui, Add, Checkbox, % "x160 y299 w12 h12 vMultiInstanceMode gUpdateSettingColor " . multiInstanceColor . (MultiInstanceMode ? " Checked" : ""), Multi-Instance Mode

    Gui, Font, s8 cBlack, Segoe UI
    IniRead, savedWebhook, %settingsFile%, Main, UserWebhook
    if (savedWebhook = "ERROR") {
        savedWebhook := ""
    }
    Gui, Add, Edit, x125 y87 w255 h15 vwebhookURL hwndhWebhookURL +E0x200 +E0x800 -Theme cBlack, %savedWebhook%


    ;WinSet, Transparent, 1, ahk_id %hWebhookURL%


    IniRead, savedUserID, %settingsFile%, Main, DiscordUserID
    if (savedUserID = "ERROR") {
        savedUserID := ""
    }
    
    Gui, Add, Edit, x135 y111 w245 h15 vdiscordUserID +E0x200 +E0x800 -Theme cBlack Background2C2F33, %savedUserID%


    IniRead, savedUserID, %settingsFile%, Main, DiscordUserID


    IniRead, savedServerLink, %settingsFile%, Main, PrivateServerLink
    if (savedServerLink = "ERROR") {
        savedServerLink := ""
    }
    Gui, Add, Edit, x125 y136 w255 h15 vprivateServerLink -Theme cBlack BackgroundFFFFFF, %savedServerLink%

    
    IniRead, SavedKeybind, %settingsFile%, Main, UINavigationKeybind, \
    if (SavedKeybind = "") {
        SavedKeybind := "\"
    }
    Gui, Add, Edit, x169 y220 w20 h16 vSavedKeybind gUpdateKeybind -Theme +E0x200 +E0x800 cBlack Background2E2E2E, %savedKeybind%


    Gui, Font, s8 cD3D3D3 Bold, Segoe UI
    
    Gui, Font, s8 cBlack, Segoe UI
    IniRead, SavedSpeed, %settingsFile%, Main, MacroSpeed, Stable
    Gui, Add, DropDownList, vSavedSpeed gUpdateSpeed x115 y191 w50 , Stable|Fast|Ultra|Max
    GuiControl, ChooseString, SavedSpeed, %SavedSpeed%
    




    Gui, Tab, 7
    Gui, Add, Picture, x0 y0 w520 h425 BackgroundTrans, % mainDir "rbx macro background credit.png"
    Gui, Font, cBlue underline
    Gui, Add, Text, x355 y345 w150 BackgroundTrans gOpenLink, GAG MODED MACROS DISCORD `njoin for update and bugreport

    Gui, Font, norm

    Gui, Show, w520 h425, GAG MACRO Yark Spade Crafting update +xTazerTx's GIGA UI Rework

   

Return

OpenLink:
    Run, https://discord.gg/gagmacros 
return

; --- SUMMER NASA STUFF ---
    Gui, Font, s8 cD3D3D3 Bold, Segoe UI
    Gui, Add, Text, x50 y190, Macro Speed:
    Gui, Font, s8 cBlack, Segoe UI
    IniRead, SavedSpeed, %settingsFile%, Main, MacroSpeed, Stable
    Gui, Add, DropDownList, vSavedSpeed gUpdateSpeed x130 y190 w50, Stable|Fast|Ultra|Max
    GuiControl, ChooseString, SavedSpeed, %SavedSpeed%

    Gui, Font, s10 cWhite Bold, Segoe UI
    Gui, Add, Button, x50 y335 w150 h40 gStartScanMultiInstance Background202020, Start Macro (F5)
    Gui, Add, Button, x320 y335 w150 h40 gQuit Background202020, Stop Macro (F7)

    Gui, Tab, 8
    Gui, Font, s9 cWhite Bold, Segoe UI
    Gui, Add, GroupBox, x23 y50 w475 h340 cfad15f, Summer Harvest
    Gui, Add, Button, x40 y80 w120 h40 gToggleRecording Background202020, Record New Path `n(F1)
    Gui, Add, Button, x200 y80 w120 h40 gDemoInput Background202020, Test Path `n(F2)
    Gui, Add, Button, x360 y80 w120 h40 gLoadInputs Background202020, Load Saved Path `n(F3)
    Gui, Add, Button, x200 y415 w120 h40 gF4 Background202020, Test Auto-Harvest `n(F4)
    IniRead, autoSummerHarvest, %settingsFile%, Main, SummerHarvest, 0
    Gui, Add, Checkbox, % "x40 y150 vautoSummerHarvest cfad15f " . (autoSummerHarvest ? "Checked" : ""), Auto-Collect & Submit Summer Harvest

    Gui, Font, s9 cWhite Bold, Segoe UI
    Gui, Add, Text, x280 y150 cfad15f, |   Number of Cycle
    IniRead, savedNumberOfCycle, %settingsFile%, Main, NumberOfCycle
    if (savedNumberOfCycle = "ERROR" || savedNumberOfCycle = "")
        savedNumberOfCycle := 3
    Gui, Font, s8 c000000 Bold, Segoe UI
    Gui, Add, Edit, x400 y150 w25 h18 vnumberOfCycle +BackgroundFFFFFF, %savedNumberOfCycle%
    Gui, Font, s8 cD3D3D3 Bold, Segoe UI
    Gui, Add, Button, x430 y150 w35 h18 gUpdateNumberOfCycle Background202020, Save
    IniRead, savedNumberOfCycle, %settingsFile%, Main, NumberOfCycle

    Gui, Font, s9 cWhite Bold, Segoe UI
    Gui, Add, Text, x280 y170 cfad15f, |   Collect Method
    Gui, Font, s8 cBlack, Segoe UI
    IniRead, savedHarvestSpeed, %settingsFile%, Main, HarvestSpeed, Stable
    Gui, Add, DropDownList, vsavedHarvestSpeed gUpdateHarvestSpeed x400 y170 w66, Stable|Fast
    GuiControl, ChooseString, savedHarvestSpeed, %savedHarvestSpeed%


    Gui, Font, s14 cD3D3D3 Bold, Segoe UI
    Gui, Add, Text, x40 y170, How to Use:
    Gui, Font, s8 cD3D3D3 Bold, Segoe UI
    Gui, Add, Text, x50 y200, Step 1: Press F1 and wait the alignment to finish.
    Gui, Add, Text, x50 y217, Step 2: After the alignment finishes, proceed to use only the keyboard `n to navigate to your target plant to harvest.
    Gui, Add, Text, x50 y247, Step 3: Once you finished to navigate to your target plant, Press F1 `n again to stop recording the path. 
    Gui, Add, Text, x50 y277, Step 4: Press F2 to see if your path is correctly recorded. 
    Gui, Add, Text, x50 y295, Step 5: Once it's all done, you can now start the macro and the Summer Harvest is `n now automated.
    Gui, Font, s15 cD3D3D3 Bold, Segoe Script
    Gui, Add, Picture, x227 y320 w69 h69, % mainDir "Images\\Nasa.png"
    Gui, Add, Text, x200 y380, NasaYuzaki
    Gui, Show, w520 h460, NasaYuzaki's Modded Macro [SUMMER UPDATE]


    MinimizeApp:
    Gui, Minimize
    return

    CloseApp:
        ExitApp
    return

    DragWindow:
        PostMessage, 0xA1, 2  ; WM_NCLBUTTONDOWN, HTCAPTION
    return


    
; ----- Tab Switch Labels -----

ShowcosmeticSubTab:
    HideAllCheckboxSets()
    GuiControl,, SubTabImage, % subTabSummerPath
    GuiControl, Show, AutoHoney
    GuiControl, Show, BuyAllCosmetics
    Loop, % BuyAllCosmetics.Length() {
        GuiControl, Show, % "BuyAllCosmetics" A_Index
    }
return



ShowSeedSubTab:
    HideAllCheckboxSets()
    GuiControl,, SubTabImage, % subTabSeedPath
    Loop, % seedCraftingItems.Length() {
        GuiControl, Show, % "SeedCraftingItem" A_Index  
        GuiControl, Show, SeedCraftLockLabel
        GuiControl, Show, ManualSeedCraftLock

    }
return




ShowBearSubTab:
    HideAllCheckboxSets()
    GuiControl,, SubTabImage, % subTabBearPath
    Loop, % bearCraftingItems.Length() {
        GuiControl, Show, % "BearCraftingItem" A_Index
        GuiControl, Show, BearCraftLockLabel
        GuiControl, Show, ManualBearCraftLock

    }
return
ShowSummerSelectSubTab:
    HideAllSummerControls()
    GuiControl, Show, PicSummerShop
    GuiControl, Hide, PicHarvestTab

    GuiControl, Show, SelectAllSummer
    Loop, % summerItems.Length() {
        GuiControl, Show, SummerItem%A_Index%
        
    }
return



ShowSummerRecordSubTab:
    HideAllSummerControls()
    GuiControl, Show, PicHarvestTab
    GuiControl, Hide, PicSummerShop

    ; Show record tab controls ONLY
    GuiControl, Show, SummerRecord
    GuiControl, Show, SummerTest
    GuiControl, Show, SummerLoad
    GuiControl, Show, SummerF4
    GuiControl, Show, autoSummerHarvest
    GuiControl, Show, numberOfCycleLabel
    GuiControl, Show, numberOfCycle
    GuiControl, Show, saveCycle
    GuiControl, Show, collectMethodLabel
    GuiControl, Show, savedHarvestSpeed
    GuiControl, Show, autosummerharvestext
    GuiControl, Show, explanationtext
    GuiControl, Show, explanationtext1
    GuiControl, Show, explanationtext2
    GuiControl, Show, explanationtext3

return











return

Gui2:
	Gui, 2:Show, x200 y200 w520 h425
		Gui, 2:+Resize +MinimizeBox +SysMenu
		Gui, 2:Margin, 10, 10
		Gui, 2:Color, 0x202020
		Gui, 2:Font, s9 cWhite, Segoe UI
		Gui, 2:Add, Tab, x10 y10 w495 h400 , Help Window|How to set up|Common issues|Manual Alignment|multi instance
	
	Gui, 2: Tab, 1
	Gui, 2: Font, s9 cWhite norm, Segoe UI
	Gui, 2: Add, GroupBox, x20 y50 w475 h350 cD3D3D3,
	Gui, 2: Add, Text, x35 y75 w450 h300,
(
Welcomed  to the help tab

This window is  intended for helpping trouble shoot and setting up the macro without the help of anyone please check the other tabs



First and foremost if its your fist time using the macro and  downloading ahk 1.1 please restart your computer because ahk did not boot properlly

Also extract the  entire file and dont have them spread around it will lead to the macro failing to run properly



Newest known bug and fix:
The shovel bugg where your navigation key start on the toolbar and the fix for that is just rejoining till you dont have it

)
	
		Gui, 2: Tab, 2
		Gui, 2: Font, s9 cWhite norm, Segoe UI
		Gui, 2: Add, GroupBox, x23 y50 w475 h350 cD3D3D3,
		
		Gui, 2: Add, Text, x35 y75 w450 h300,

		(
This is what you should do to run the macro


In roblox setting disable shiftlock, put the camera mode in default and enable ui navigation

Turn on auto-align

Disable fastmode

Input your navigation key and forward movement key in the macro settings
Place the recall wrench is you 2nd toolbar slot and fill the rest of the slot with anything else

Do not start the macro with ui navigation on



And start the macro with f5 and stop it with f7 (fn+f5 and fn+f7 for small keyboard)
Also you can force shutdown the macro with Rshift.
)
		Gui, 2: Tab, 3
		Gui, 2: Font, s9 cWhite norm, Segoe UI
		Gui, 2:Add, GroupBox, x23 y50 w475 h350 cD3D3D3,
		
		Gui, 2:Add, Text, x35 y75 w450 h300,
(
The macro isnt clicking where it should  to open the shops? 

Make sure to run the macro in 1920x1080 100 or 2560x1440 150 or any 16:9 resolution
Also disable hdr or any  colour altering display settings 

Rhe macro is missing the eggs ?

Remove or pet grey mouse or any movement speed pets


)
		Gui, 2: Tab, 4
		Gui, 2: Font, s9 cWhite norm, Segoe UI
		Gui, 2: Add, GroupBox, x23 y50 w475 h350 cD6D6D6, !!! do not do this if you use auto-align!!!
		
		Gui, 2:Add, Text, x35 y69 w450 h300,
(
You must be in that exact camera position for manual alignment to work and same for the zoom level.

Failling to align correctly will lead to drifting wich will break some of the shops
)
Gui, 2:Add, Picture, x35 y145 w450 h250, % mainDir "camalign.png"

		Gui, 2: Tab, 5
		Gui, 2: Font, s9 cWhite norm, Segoe UI
		Gui, 2: Add, GroupBox, x23 y50 w475 h350 cD6D6D6, 
		
		Gui, 2:Add, Text, x35 y69 w450 h300,
		(
Using multy instance mode is very simple just get yourself multiple roblox window and the macro will do all the works itself.


this can be donr by using bloxstarp or any other means of generating orther roblox instance.


but be carefull depending on wich client you use you might get banned from roblox beacause of the recent modified client ban that roblox implemented.
)
Return

Gui3:
    Gui, 3:Show, x169 y40 w440 h969 
    Gui, 3:+Resize +MinimizeBox +SysMenu 
    Gui, 3:Margin, 10, 10
    Gui, 3:Color, c244f29
    Gui, 3:Add, Text, x100 y98 BackgroundTrans,...........................................................
    Gui, 3:Add, Picture, x-21 y-10 w478 h1001, % mainDir "beequest.png"
    
    

    Gui, 3:Add, Checkbox, cYellow x340 y3 gSwitch, Always on top
Return
Switch:
	if(Always:=!Always)
		Gui,+AlwaysOnTop
	else
		Gui,-AlwaysOnTop
	return
Gui4:
    Gui, 4:Show, x169 y20 w574 h938
    Gui, 4:+Resize +MinimizeBox +SysMenu 
    Gui, 4:Margin, 10, 10
    Gui, 4:Color, c244f29
    Gui, 4:Add, Picture, x-25 y-9 w619 h969, % mainDir "eggs.png"

    Gui, 4:Add, Checkbox, cYellow x480 y3 gSwitch1, Always on top
Return
Switch1:
	if(Always:=!Always)
		Gui,-AlwaysOnTop
	else
		Gui,+AlwaysOnTop
	return


Gui5:
    Gui, 5:Show, x169 y0 w626 h1000
    Gui, 5:+Resize +MinimizeBox +SysMenu 
    Gui, 5:Margin, 10, 10
    Gui, 5:Color, c244f29
    Gui, 5:Add, Picture, x-7 y13 w724 h986, % mainDir "pets.png"

    Gui, 5:Add, Checkbox, cYellow x530 y3 gSwitch2, Always on top
Return
Switch2:
	if(Always:=!Always)
		Gui,+AlwaysOnTop
	else
		Gui,-AlwaysOnTop
	return





Return

; ui handlers

DisplayWebhookValidity:
    
    Gui, Submit, NoHide

    checkValidity(webhookURL, 1, "webhook")

Return

UpdateUserID:

    Gui, Submit, NoHide

    if (discordUserID != "") {
        IniWrite, %discordUserID%, %settingsFile%, Main, DiscordUserID
        MsgBox, 0, Message, Discord UserID Saved
    }

Return

UpdateNumberOfCycle:

    Gui, Submit, NoHide

    if (numberOfCycle != "") {
        IniWrite, %numberOfCycle%, %settingsFile%, Main, NumberOfCycle
        MsgBox, 0, Message, Number Of Cycle Saved!
    }else{
        MsgBox, 48, Warning, Number Of Cycle is empty or invalid.
    }

Return

DisplayServerValidity:

    Gui, Submit, NoHide

    checkValidity(privateServerLink, 1, "privateserver")

Return

ClearSaves:

    IniWrite, %A_Space%, %settingsFile%, Main, UserWebhook
    IniWrite, %A_Space%, %settingsFile%, Main, DiscordUserID
    IniWrite, %A_Space%, %settingsFile%, Main, PrivateServerLink

    IniRead, savedWebhook, %settingsFile%, Main, UserWebhook
    IniRead, savedUserID, %settingsFile%, Main, DiscordUserID
    IniRead, savedServerLink, %settingsFile%, Main, PrivateServerLink

    GuiControl,, webhookURL, %savedWebhook% 
    GuiControl,, discordUserID, %savedUserID% 
    GuiControl,, privateServerLink, %savedServerLink% 

    MsgBox, 0, Message, Webhook, User Id, and Private Server Link Cleared

Return

UpdateKeybind:

    Gui, Submit, NoHide

    if (StrLen(SavedKeybind) > 1) {
        MsgBox, 0, Error, % "Keybind must be a single key, please type a valid keybind."
        SavedKeybind := "\"
        GuiControl,, SavedKeybind, %SavedKeybind%
        Return
    }
    else {
        IniWrite, %SavedKeybind%, %settingsFile%, Main, UINavigationKeybind
    }

    Return

UpdateCraftLock:

    Gui, Submit, NoHide
    ManualSeedCraftLock := ManualSeedCraftLock * 60000
    ManualBearCraftLock := ManualBearCraftLock * 60000
    IniWrite, %ManualSeedCraftLock%, %settingsFile%, Main, ManualSeedCraftLock
    IniWrite, %ManualBearCraftLock%, %settingsFile%, Main, ManualBearCraftLock
    Return
    
UpdateSpeed:

    Gui, Submit, NoHide

    IniWrite, %SavedSpeed%, %settingsFile%, Main, MacroSpeed
    GuiControl, ChooseString, SavedSpeed, %SavedSpeed%
    if (SavedSpeed = "Fast") {
        MsgBox, 0, Disclaimer, % "Macro speed set to " . SavedSpeed . ". Use with caution (Requires a stable FPS rate)."
    }
    else if (SavedSpeed = "Ultra") {
        MsgBox, 0, Disclaimer, % "Macro speed set to " . SavedSpeed . ". Use at your own risk, high chance of erroring/breaking (Requires a very stable and high FPS rate)."
    }
    else if (SavedSpeed = "Max") {
        MsgBox, 0, Disclaimer, % "Macro speed set to " . SavedSpeed . ". Zero delay on UI Navigation inputs, I wouldn't recommend actually using this it's mostly here for fun."
    }
    else {
        MsgBox, 0, Message, % "Macro speed set to " . SavedSpeed . ". Recommended for lower end devices."
    }

Return

UpdateHarvestSpeed:

    Gui, Submit, NoHide

    IniWrite, %savedHarvestSpeed%, %settingsFile%, Main, MacroSpeed
    GuiControl, ChooseString, savedHarvestSpeed, %savedHarvestSpeed%
    if (savedHarvestSpeed = "Fast") {
        MsgBox, 0, Disclaimer, % "Harvest speed set to " . savedHarvestSpeed . ". Use it if you have clean garden ( Fast but Unstable [ Might Break ] )."
    }
    else {
        MsgBox, 0, Message, % "Harvest speed set to " . savedHarvestSpeed . ". Recommended for stable collecting ( Messy Garden )."
    }

Return

UpdateResolution:

    Gui, Submit, NoHide

    IniWrite, %selectedResolution%, %settingsFile%, Main, Resolution

return

HandleSelectAll:

    Gui, Submit, NoHide

    if (SubStr(A_GuiControl, 1, 9) = "SelectAll") {
        group := SubStr(A_GuiControl, 10)  ; seeds, gears, eggs
        controlVar := A_GuiControl
        Loop {
            item := group . "Item" . A_Index
            if (!IsSet(%item%))
                break
            GuiControl,, %item%, % %controlVar%
        }
    }
    else if (RegExMatch(A_GuiControl, "^(Seed|Gear|Egg)Item\d+$", m)) {
        group := m1  ; seed, gear, egg
        
        assign := (group = "Seed" || group = "Gear" || group = "Egg") ? "SelectAll" . group . "s" : "SelectAll" . group

        if (!%A_GuiControl%)
            GuiControl,, %assign%, 0
    }

    if (A_GuiControl = "SelectAllSeeds") {
        Loop, % seedItems.Length()
            GuiControl,, SeedItem%A_Index%, % SelectAllSeeds
            Gosub, SaveSettings
    }
    else if (A_GuiControl = "SelectAllEggs") {
        Loop, % eggItems.Length()
            GuiControl,, EggItem%A_Index%, % SelectAllEggs
            Gosub, SaveSettings
    }
    else if (A_GuiControl = "SelectAllGears") {
        Loop, % gearItems.Length()
            GuiControl,, GearItem%A_Index%, % SelectAllGears
            Gosub, SaveSettings
    }
    else if (A_GuiControl = "SelectAllSummer") {
        Loop, % summerItems.Length()
            GuiControl,, SummerItem%A_Index%, % SelectAllSummer
            Gosub, SaveSettings
    }

return

UpdateSettingColor:

    Gui, Submit, NoHide

    ; color values
    autoColor := "+c" . (AutoAlign ? "90EE90" : "D3D3D3")
    pingColor := "+c" . (PingSelected ? "90EE90" : "D3D3D3")
    multiInstanceColor := "+c" . (MultiInstanceMode ? "90EE90" : "D3D3D3")

    ; apply colors
    GuiControl, %autoColor%, AutoAlign
    GuiControl, +Redraw, AutoAlign

    GuiControl, %pingColor%, PingSelected
    GuiControl, +Redraw, PingSelected

    GuiControl, %multiInstanceColor%, MultiInstanceMode
    GuiControl, +Redraw, MultiInstanceMode
    
return

HideTooltip:

    ToolTip

return

HidePopupMessage:

    Gui, 99:Destroy

Return

GetScrollCountRes(index, mode := "seed") {

    global scrollCounts_1080p, scrollCounts_1440p_100, scrollCounts_1440p_125
    global gearScroll_1080p, gearScroll_1440p_100, gearScroll_1440p_125

    if (mode = "seed") {
        arr1 := scrollCounts_1080p
        arr2 := scrollCounts_1440p_100
        arr3 := scrollCounts_1440p_125
    } else if (mode = "gear") {
        arr1 := gearScroll_1080p
        arr2 := gearScroll_1440p_100
        arr3 := gearScroll_1440p_125
    }

    arr := (selectedResolution = 1) ? arr1
        : (selectedResolution = 2) ? arr2
        : (selectedResolution = 3) ? arr3
        : []

    loopCount := arr.HasKey(index) ? arr[index] : 0

    return loopCount
}

; item selection

UpdateSelectedItems:

    Gui, Submit, NoHide
    
    selectedSeedItems := []

    Loop, % seedItems.Length() {
        if (SeedItem%A_Index%)
            selectedSeedItems.Push(seedItems[A_Index])
    }

    selectedGearItems := []

    Loop, % gearItems.Length() {
        if (GearItem%A_Index%)
            selectedGearItems.Push(gearItems[A_Index])
    }

    selectedEggItems := []

    Loop, % eggItems.Length() {
        if (eggItem%A_Index%)
            selectedEggItems.Push(eggItems[A_Index])
    }

    selectedSummerItems := []

    Loop, % summerItems.Length() {
        if (SummerItem%A_Index%)
            selectedSummerItems.Push(summerItems[A_Index])
    }

    selectedSeedCraftingItems := []

    Loop, % seedCraftingItems.Length() {
        if (SeedCraftingItem%A_Index%)
            selectedSeedCraftingItems.Push(SeedCraftingItems[A_Index])
    }

    selectedBearCraftingItems := []

    Loop, % bearCraftingItems.Length() {
        if (BearCraftingItem%A_Index%)
            selectedBearCraftingItems.Push(BearCraftingItems[A_Index])
    }

Return

GetSelectedItems() {

    result := ""
    if (selectedSeedItems.Length()) {
        result .= "Seed Items:`n"
        for _, name in selectedSeedItems
            result .= "  - " name "`n"
    }
    if (selectedGearItems.Length()) {
        result .= "Gear Items:`n"
        for _, name in selectedGearItems
            result .= "  - " name "`n"
    }
    if (selectedEggItems.Length()) {
        result .= "Egg Items:`n"
        for _, name in selectedEggItems
            result .= "  - " name "`n"
    }

    return result
    
}

DrawDebugBox(x1, y1, x2, y2, color := "Red") {
    Gui, DebugBox:Destroy
    Gui, DebugBox:+AlwaysOnTop +ToolWindow -Caption +LastFound +E0x20 ; E0x20 = click-through
    Gui, DebugBox:Color, %color%
    WinSet, Transparent, 50
    
    width := x2 - x1
    height := y2 - y1
    Gui, DebugBox:Show, x%x1% y%y1% w%width% h%height% NoActivate
    SetTimer, RemoveDebugBox, -1500
}

RemoveDebugBox:
    Gui, DebugBox:Destroy
Return

SaveAutoHoney:
    Gui, Submit, NoHide
    IniWrite, %AutoHoney%, %settingsFile%, AutoHoney, AutoHoneySetting
Return

; macro starts

StartScanMultiInstance:
    
    Gui, Submit, NoHide

    global cycleCount
    global cycleFinished

    global lastGearMinute := -1
    global lastSeedMinute := -1
    global lastEggShopMinute := -1
    global lastCosmeticShopHour := -1
    global lastAutoHoneyMinute := -1
    global lastSummerShopMinute := -1
    global lastSummerRetryMinute := -1
    global lastSeedCraftMinute := -1
    global lastBearCraftMinute := -1
    global lastSummerHarvestMinute := -1

    started := 1
    cycleFinished := 1

    currentSection := "StartScanMultiInstance"

    SetTimer, AutoReconnect, Off
    SetTimer, CheckLoadingScreen, Off

    getWindowIDS()

    if InStr(A_ScriptDir, A_Temp) {
        MsgBox, 16, Error, Please, extract the file before running the macro.
        ExitApp
    }

    if(!windowIDS.MaxIndex()) {
        MsgBox, 1, Message, No roblox window found, if this is a false flag press OK to continue.
        IfMsgBox, Cancel
        Return
    }

    SendDiscordMessage(webhookURL, "Macro Started", "The macro has been initialized.", COLOR_INFO)

    if (MultiInstanceMode) {
        MsgBox, 1, Multi-Instance Mode, % "You have " . windowIDS.MaxIndex() . " instances open. (Instance ID's: " . idDisplay . ")`nPress OK to start the macro."
        IfMsgBox, Cancel
            Return
    }

    if WinExist("ahk_id " . firstWindow) {
        WinActivate
        WinWaitActive, , , 2
    }

    if (MultiInstanceMode) {
        for window in windowIDS {

            currentWindow := % windowIDS[window]

            ToolTip, % "Aligning Instance " . window . " (" . currentWindow . ")"
            SetTimer, HideTooltip, -5000

            WinActivate, % "ahk_id " . currentWindow

            Sleep, 500
            SafeClickRelative(0.5, 0.5)
            Sleep, 100
            Gosub, alignment
            Sleep, 100

        }
    }
    else {

        Sleep, 500
        Gosub, alignment
        Sleep, 100

    }

    WinActivate, % "ahk_id " . firstWindow

    Gui, Submit, NoHide
        
    Gosub, UpdateSelectedItems  
    itemsText := GetSelectedItems()

    Sleep, 500

    Gosub, SetTimers

    while (started) {
        if (actionQueue.Length()) {
            SetTimer, AutoReconnect, Off
            ToolTip  
            next := actionQueue.RemoveAt(1)
            if (MultiInstanceMode) {
                for window in windowIDS {
                    currentWindow := % windowIDS[window]
                    instanceNumber := window
                    ToolTip, % "Running Cycle On Instance " . window
                    SetTimer, HideTooltip, -1500
                    SendDiscordMessage(webhookURL, "Running Instance " . instanceNumber, "Now running automations on instance #" . instanceNumber, COLOR_INFO)
                    WinActivate, % "ahk_id " . currentWindow
                    Sleep, 200
                    SafeClickRelative(midX, midY)
                    Sleep, 200
                    Gosub, % next
                }
            }
            else {
                WinActivate, % "ahk_id " . firstWindow
                Gosub, % next
            }
            if (!actionQueue.MaxIndex()) {
                cycleFinished := 1
            }
            Sleep, 500
        } else {
            Gosub, SetToolTip
            if (cycleFinished) {
                WinActivate, % "ahk_id " . firstWindow
                cycleCount++
                SendDiscordMessage(webhookURL, "Cycle " . cycleCount . " Completed", "All tasks for the current cycle have finished.", COLOR_COMPLETED)
                cycleFinished := 0
                if (!MultiInstanceMode) {
                    SetTimer, AutoReconnect, 5000
                }
            }
            Sleep, 1000
        }
    }

Return

; actions

AutoBuySeed:

    ; queues if its not the first cycle and the time is a multiple of 5
    if (cycleCount > 0 && Mod(currentMinute, 5) = 0 && currentMinute != lastSeedMinute) {
        lastSeedMinute := currentMinute
        SetTimer, PushBuySeed, -8000
    }

Return

PushBuySeed: 

    actionQueue.Push("BuySeed")

Return

BuySeed:

    currentSection := "BuySeed"
    if (selectedSeedItems.Length())
        Gosub, SeedShopPath

Return

AutoBuyGear:

    ; queues if its not the first cycle and the time is a multiple of 5
    if (cycleCount > 0 && Mod(currentMinute, 5) = 0 && currentMinute != lastGearMinute) {
        lastGearMinute := currentMinute
        SetTimer, PushBuyGear, -8000
    }

Return

PushBuyGear: 

    actionQueue.Push("BuyGear")

Return

BuyGear:

    currentSection := "BuyGear"
    if (selectedGearItems.Length())
        Gosub, GearShopPath

Return

AutoBuyEggShop:

    ; queues if its not the first cycle and the time is a multiple of 30
    if (cycleCount > 0 && Mod(currentMinute, 30) = 0 && currentMinute != lastEggShopMinute) {
        lastEggShopMinute := currentMinute
        SetTimer, PushBuyEggShop, -8000
    }

Return

PushBuyEggShop: 

    actionQueue.Push("BuyEggShop")

Return

BuyEggShop:

    currentSection := "BuyEggShop"
    if (selectedEggItems.Length()) {
        Gosub, EggShopPath
    } 

Return

AutoBuyCosmeticShop:

    ; queues if its not the first cycle, the minute is 0, and the current hour is an even number (every 2 hours)
    if (cycleCount > 0 && currentMinute = 0 && Mod(currentHour, 2) = 0 && currentHour != lastCosmeticShopHour) {
        lastCosmeticShopHour := currentHour
        SetTimer, PushBuyCosmeticShop, -8000
    }

Return

PushBuyCosmeticShop: 

    actionQueue.Push("BuyCosmeticShop")

Return

BuyCosmeticShop:

    currentSection := "BuyCosmeticShop"
    if (BuyAllCosmetics) {
        Gosub, CosmeticShopPath
    } 

Return

AutoBuySummer:
    if (cycleCount > 0 && Mod(currentMinute, 30) = 0 && currentMinute != lastSummerShopMinute) {
        lastSummerShopMinute := currentMinute
        SetTimer, PushBuySummer, -8000
    }
        if (summerShopFailed && Mod(currentMinute, 5) = 0 && currentMinute != lastSummerRetryMinute) {
            lastSummerRetryMinute := currentMinute
            SendDiscordMessage(webhookURL, "Retrying Summer Shop", "Attempting to run the summer shop cycle again after a previous failure.", COLOR_WARNING)
            SetTimer, PushBuySummer, -8000
        }
Return


PushBuySummer: 
    actionQueue.Push("BuySummer")
Return

BuySummer:
    currentSection := "BuySummer"

    if (selectedSummerItems.Length()) {
        if (UseAlts) {
            for index, winID in windowIDs {
                WinActivate, ahk_id %winID%
                WinWaitActive, ahk_id %winID%,, 2
                Gosub, SummerShopPath
            }
        }
        else {
            Gosub, SummerShopPath
        } 
    } 
Return


AutoHoney:
    if (cycleCount > 0 && Mod(currentMinute, 5) = 0 && currentMinute != lastAutoHoneyMinute) {
        lastAutoHoneyMinute := currentMinute
        SetTimer, PushAutoHoney, -8000
    }
Return

PushAutoHoney:
    actionQueue.Push("RunAutoHoney")
Return

RunAutoHoney:
    currentSection := "RunAutoHoney"

 if (AutoHoney) {
    if (UseAlts) {
        for index, winID in windowIDs {
            WinActivate, ahk_id %winID%
            WinWaitActive, ahk_id %winID%,, 2
            Gosub, AutoHoneyPath
        }
    } else {
        Gosub, AutoHoneyPath
    }
}
Return

AutoSeedCraft:
if (seedCraftingLocked = 1)
	return

    if (cycleCount > 0 && Mod(currentMinute, 5) = 0 && currentMinute != lastSeedCraftMinute) {
        lastSeedCraftMinute := currentMinute
        SetTimer, PushSeedCraft, -8000
    }
Return

PushSeedCraft:
    actionQueue.Push("RunAutoSeedCraft")
Return

RunAutoSeedCraft:
    currentSection := "RunAutoSeedCraft"

 if (selectedSeedCraftingItems.Length()) {
    if (UseAlts) {
        for index, winID in windowIDs {
            WinActivate, ahk_id %winID%
            WinWaitActive, ahk_id %winID%,, 2
            Gosub, AutoSeedCraftPath
        }
    } else {
        Gosub, AutoSeedCraftPath
    }
}
Return

AutoBearCraft:
if (bearCraftingLocked = 1)
	return

    if (cycleCount > 0 && Mod(currentMinute, 5) = 0 && currentMinute != lastBearCraftMinute) {
        lastBearCraftMinute := currentMinute
        bearCraftQueued := true
        SetTimer, PushBearCraft, -8000
    }
Return

PushBearCraft:
    actionQueue.Push("RunAutoBearCraft")
    bearCraftQueued := false
Return

RunAutoBearCraft:
    currentSection := "RunAutoBearCraft"

 if (selectedBearCraftingItems.Length()) {
    if (UseAlts) {
        for index, winID in windowIDs {
            WinActivate, ahk_id %winID%
            WinWaitActive, ahk_id %winID%,, 2
            Gosub, AutoBearCraftPath
        }
    } else {
        Gosub, AutoBearCraftPath
    }
}
Return

autoCollectSummerHarvest:
    if (cycleCount > 0 && currentMinute = 0 && Mod(currentHour, 1) = 0 && currentHour != lastSummerHarvestHour) {
        lastSummerHarvestHour := currentHour
        SetTimer, PushautoSummerHarvest, -8000
    }

Return

PushautoSummerHarvest:

    actionQueue.Push("SubmitHarvest")

Return

SubmitHarvest:

    currentSection := "SubmitHarvest"
    if (autoSummerHarvest) {
        Gosub, SummerHarvestPath
    }

Return

; helper labels

SetToolTip:

    mod5 := Mod(currentMinute, 5)
    rem5min := (mod5 = 0) ? 5 : 5 - mod5
    rem5sec := rem5min * 60 - currentSecond
    if (rem5sec < 0)
        rem5sec := 0
    seedMin := rem5sec // 60
    seedSec := Mod(rem5sec, 60)
    seedText := (seedSec < 10) ? seedMin . ":0" . seedSec : seedMin . ":" . seedSec
    gearMin := rem5sec // 60
    gearSec := Mod(rem5sec, 60)
    gearText := (gearSec < 10) ? gearMin . ":0" . gearSec : gearMin . ":" . gearSec

    mod30 := Mod(currentMinute, 30)
    rem30min := (mod30 = 0) ? 30 : 30 - mod30
    rem30sec := rem30min * 60 - currentSecond
    if (rem30sec < 0)
        rem30sec := 0
    eggMin := rem30sec // 60
    eggSec := Mod(rem30sec, 60)
    eggText := (eggSec < 10) ? eggMin . ":0" . eggSec : eggMin . ":" . eggSec

    mod60 := Mod(currentMinute, 60)
    rem60min := (mod60 = 0) ? 60 : 60 - mod60
    rem60sec := rem60min * 60 - currentSecond
    if (rem60sec < 0)
        rem60sec := 0
    honeyMin := rem60sec // 60
    honeySec := Mod(rem60sec, 60)
    honeyText := (honeySec < 10) ? honeyMin . ":0" . honeySec : honeyMin . ":" . honeySec

    totalSecNow := currentHour * 3600 + currentMinute * 60 + currentSecond
    nextCosHour := (Floor(currentHour/2) + 1) * 2
    nextCosTotal := nextCosHour * 3600
    remCossec := nextCosTotal - totalSecNow
    if (remCossec < 0)
        remCossec := 0
    cosH := remCossec // 3600
    cosM := (remCossec - cosH*3600) // 60
    cosS := Mod(remCossec, 60)
    if (cosH > 0)
        cosText := cosH . ":" . (cosM < 10 ? "0" . cosM : cosM) . ":" . (cosS < 10 ? "0" . cosS : cosS)
    else
        cosText := cosM . ":" . (cosS < 10 ? "0" . cosS : cosS)


    tooltipText := ""
    if (selectedSeedItems.Length()) {
        tooltipText .= "Seed Shop: " . seedText . "`n"
    }
    if (selectedGearItems.Length()) {
        tooltipText .= "Gear Shop: " . gearText . "`n"
    }
    if (selectedEggItems.Length()) {
        tooltipText .= "Egg Shop : " . eggText . "`n"
    }
    if (BuyAllCosmetics) {
        tooltipText .= "Cosmetic Shop: " . cosText . "`n"
    }
    if (selectedSummerItems.Length()) {
        tooltipText .= "Summer Shop: " . eggText . "`n"
    }
    if (AutoHoney) {
    	tooltipText .= "Turn in Pollinated: " . seedText . "`n"
    }

    if (tooltipText != "") {
        CoordMode, Mouse, Screen
        MouseGetPos, mX, mY
        offsetX := 10
        offsetY := 10
        ToolTip, % tooltipText, % (mX + offsetX), % (mY + offsetY)
    } else {
        ToolTip  ; clears any existing tooltip
    }

Return

SetTimers:

    SetTimer, UpdateTime, 1000

    if (selectedSeedItems.Length()) {
        actionQueue.Push("BuySeed")
    }
    seedAutoActive := 1
    SetTimer, AutoBuySeed, 1000 ; checks every second if it should queue

    if (selectedGearItems.Length()) {
        actionQueue.Push("BuyGear")
    }
    gearAutoActive := 1
    SetTimer, AutoBuyGear, 1000 ; checks every second if it should queue

    if (selectedEggItems.Length()) {
        actionQueue.Push("BuyEggShop")
    }
    eggAutoActive := 1
    SetTimer, AutoBuyEggShop, 1000 ; checks every second if it should queue

    if (BuyAllCosmetics) {
        actionQueue.Push("BuyCosmeticShop")
    }
    cosmeticAutoActive := 1
    SetTimer, AutoBuyCosmeticShop, 1000 ; checks every second if it should queue

    if (selectedSummerItems.Length()) {
        actionQueue.Push("BuySummer")
    }
    summerAutoActive := 1
    SetTimer, AutoBuySummer, 1000 ; checks every second if it should queue

    if (AutoHoney) {
        actionQueue.Push("RunAutoHoney")
    }
    autoHoneyActive := 1
    SetTimer, AutoHoney, 1000 ; checks every second if it should queue

    if (selectedSeedCraftingItems.Length()) {
        actionQueue.Push("RunAutoSeedCraft")
    }
    seedCraftingAutoActive := 1
    SetTimer, AutoSeedCraft, 1000 ; checks every second if it should queue

    if (selectedBearCraftingItems.Length()) {
        actionQueue.Push("RunAutoBearCraft")
    }
    bearCraftingAutoActive := 1
    SetTimer, AutoBearCraft, 1000 ; checks every second if it should queue

    autoSummerHarvestActive := 1
    SetTimer, autoCollectSummerHarvest, 1000 ; checks every second if it should queue
    
Return

UpdateTime:

    FormatTime, currentHour,, hh
    FormatTime, currentMinute,, mm
    FormatTime, currentSecond,, ss

    currentHour := currentHour + 0
    currentMinute := currentMinute + 0
    currentSecond := currentSecond + 0

Return

AutoReconnect:

    global actionQueue

    shouldReconnect := false

    Loop, 3 {
        detectedColor1 := simpleDetect(0x302927, 0, 0.3988, 0.3548, 0.6047, 0.6674)
        detectedColor2 := simpleDetect(0x3D3B39, 0, 0.3988, 0.3548, 0.6047, 0.6674)
        detectedWhite := simpleDetect(0xFFFFFF, 0, 0.3988, 0.3548, 0.6047, 0.6674)

        if ((detectedColor1 || detectedColor2) && detectedWhite && privateServerLink != "") {
		shouldReconnect := true
        break
        } else {
            break
        }

        Sleep, 2000
    }

    if (shouldReconnect) {
        started := 0
        actionQueue := []
        SetTimer, AutoReconnect, Off
        Sleep, 500
        WinClose, % "ahk_id" . firstWindow
        Sleep, 1000
        WinClose, % "ahk_id" . firstWindow
        Sleep, 500
        Run, % privateServerLink
        ToolTip, Attempting To Reconnect
        SetTimer, HideTooltip, -5000
        SendDiscordMessage(webhookURL, "Reconnecting...", "Lost connection or macro errored, attempting to reconnect to the server.", COLOR_WARNING, PingSelected)
        sleepAmount(15000, 30000)
        SetTimer, CheckLoadingScreen, 5000
    }


Return

CheckLoadingScreen:

    ToolTip, Detecting Rejoin

    getWindowIDS()

    WinActivate, % "ahk_id" . firstWindow

    if (simpleDetect(0x000000, 0, 0.75, 0.75, 0.9, 0.9)) {
        SafeClickRelative(midX, midY)
    }
    else {
        ToolTip, Rejoined Successfully
        sleepAmount(10000, 20000)
        SendDiscordMessage(webhookURL, "Reconnected Successfully", "Successfully reconnected to the server and resuming macro.", COLOR_SUCCESS, PingSelected)
        Sleep, 200
        Gosub, StartScanMultiInstance
    }

Return

; set up labels

alignment:

    ToolTip, Beginning Alignment
    SetTimer, HideTooltip, -5000
        SendDiscordMessage(webhookURL, "[Debug] alignment", "Alignment process started.", COLOR_INFO, false, true)

    SafeClickRelative(0.5, 0.5)
    Sleep, 100

    searchitem("recall")

    Sleep, 200

    if (AutoAlign) {
        GoSub, cameraChange
        Sleep, 100
        Gosub, zoomAlignment
        Sleep, 100
        GoSub, cameraAlignment
        Sleep, 100
        Gosub, characterAlignment
        Sleep, 100
        Gosub, cameraChange
        Sleep, 100
        }
    else {
        Gosub, zoomAlignment
        Sleep, 100
    }

    Sleep, 1000
    uiUniversal(11110)
    Sleep, 100

    ToolTip, Alignment Complete
    SetTimer, HideTooltip, -1000
        SendDiscordMessage(webhookURL, "[Debug] alignment", "Alignment process finished.", COLOR_INFO, false, true)

Return

cameraChange:

    ; changes camera mode to follow and can be called again to reverse it (0123, 0->3, 3->0)
    Send, {Escape}
    Sleep, 500
    Send, {Tab}
    Sleep, 400
    Send {Down}
    Sleep, 100
    repeatKey("Right", 2, (SavedSpeed = "Ultra") ? 55 : (SavedSpeed = "Max") ? 60 : 30)
    Sleep, 100
    Send {Escape}

Return

cameraAlignment:

    ; puts character in overhead view
    Click, Right, Down
    Sleep, 200
    SafeMoveRelative(0.5, 0.5)
    Sleep, 200
    MouseMove, 0, 800, R
    Sleep, 200
    Click, Right, Up

Return

zoomAlignment:

    ; sets correct player zoom
    SafeMoveRelative(0.5, 0.5)
    Sleep, 100

    Loop, 40 {
        Send, {WheelUp}
        Sleep, 20
    }

    Sleep, 200

    Loop, 6 {
        Send, {WheelDown}
        Sleep, 20
    }

    midX := getMouseCoord("x")
    midY := getMouseCoord("y")

Return

characterAlignment:

    ; aligns character through spam tping and using the follow camera mode

    sendKeybind(SavedKeybind)
    Sleep, 10

    repeatKey("Right", 3)
    Loop, % ((SavedSpeed = "Ultra") ? 12 : (SavedSpeed = "Max") ? 18 : 8) {
    Send, {Enter}
    Sleep, 10
    repeatKey("Right", 2)
    Sleep, 10
    Send, {Enter}
    Sleep, 10
    repeatKey("Left", 2)
    }
    Sleep, 10
    sendKeybind(SavedKeybind)

Return

; buying paths

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
    quickDetectEgg(0x26EE26, 15, 0.41, 0.65, 0.52, 0.70)
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
    quickDetectEgg(0x26EE26, 15, 0.41, 0.65, 0.52, 0.70)
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
    quickDetectEgg(0x26EE26, 15, 0.41, 0.65, 0.52, 0.70)
    Sleep, 300

    closeRobuxPrompt()
    sleepAmount(1250, 2500)
    uiUniversal("11110")
    Sleep, 100
    SendDiscordMessage(webhookURL, "Eggs Completed", "Finished the egg buying cycle.", COLOR_COMPLETED)

    if (AutoAlign) {
                SendDiscordMessage(webhookURL, "[Debug] EggShopPath", "Auto-aligning after cycle.", COLOR_INFO, false, true)
        GoSub, cameraChange
        Sleep, 100
        Gosub, zoomAlignment
        Sleep, 100
        GoSub, cameraAlignment
        Sleep, 100
        Gosub, characterAlignment
        Sleep, 100
        Gosub, cameraChange
    }
    else {
        Gosub, zoomAlignment
    }

Return

SeedShopPath:

    seedsCompleted := 0
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
            ToolTip, Seed Shop Opened
            CheckAndCloseBuyOption()
            SetTimer, HideTooltip, -1500
            SendDiscordMessage(webhookURL, "Seed Shop Status", "Seed Shop Opened.", COLOR_INFO)
            Sleep, 200
            uiUniversal("3331114433331114405550555", 0)
            Sleep, 100
            buyUniversal("seed")
            SendDiscordMessage(webhookURL, "Seed Shop Status", "Seed Shop Closed.", COLOR_INFO)
            seedsCompleted = 1
        }
        if (seedsCompleted) {
            break
        }
        Sleep, 2000
    }

    closeShop("seed", seedsCompleted)

    SendDiscordMessage(webhookURL, "Seeds Completed", "Finished the seed buying cycle.", COLOR_COMPLETED)

Return

GearShopPath:

    gearsCompleted := 0
        SendDiscordMessage(webhookURL, "[Debug] GearShopPath", "Function started.", COLOR_INFO, false, true)

    hotbarController(0, 1, "0")
    uiUniversal("11110")
    sleepAmount(100, 500)
    hotbarController(1, 0, "2")
    sleepAmount(100, 500)
    SafeClickRelative(midX, midY)
    sleepAmount(1200, 2500)
    Send, {e}
    sleepAmount(1500, 5000)
    dialogueClick("gear")
    SendDiscordMessage(webhookURL, "Gear Cycle", "Starting gear buying cycle.", COLOR_INFO)
    sleepAmount(2500, 5000)
    ; checks for the shop opening up to 5 times to ensure it doesn't fail
    Loop, 5 {
                SendDiscordMessage(webhookURL, "[Debug] GearShopPath", "Shop detection loop, attempt " . A_Index, COLOR_INFO, false, true)
        if (simpleDetect(0x00CCFF, 10, 0.54, 0.20, 0.65, 0.325)) {
            ToolTip, Gear Shop Opened
            CheckAndCloseBuyOption()
            SetTimer, HideTooltip, -1500
            SendDiscordMessage(webhookURL, "Gear Shop Status", "Gear Shop Opened.", COLOR_INFO)
            Sleep, 200
            uiUniversal("3331114433331114405550555", 0)
            Sleep, 100
            buyUniversal("gear")
            SendDiscordMessage(webhookURL, "Gear Shop Status", "Gear Shop Closed.", COLOR_INFO)
            gearsCompleted = 1
        }
        if (gearsCompleted) {
            break
        }
        Sleep, 2000
                if (!gearsCompleted) {
            if (AutoAlign) {
                GoSub, cameraChange
                Sleep, 100
                Gosub, zoomAlignment
                Sleep, 100
                GoSub, cameraAlignment
                Sleep, 100
                Gosub, characterAlignment
                Sleep, 100
                Gosub, cameraChange
            }
    }
}

    closeShop("gear", gearsCompleted)
    
    Sleep, 1000

    Gosub, zoomAlignment

    hotbarController(0, 1, "0")
    SendDiscordMessage(webhookURL, "Gears Completed", "Finished the gear buying cycle.", COLOR_COMPLETED)

Return

CosmeticShopPath:

    ; if you are reading this please forgive this absolute garbage label
    cosmeticsCompleted := 0
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
    ; checks for the shop opening up to 5 times to ensure it doesn't fail
    Loop, 5 {
        SendDiscordMessage(webhookURL, "[Debug] CosmeticShopPath", "Shop detection loop, attempt " . A_Index, COLOR_INFO, false, true)
        if (simpleDetect(0x00CCFF, 10, 0.61, 0.182, 0.764, 0.259)) {
            ToolTip, Cosmetic Shop Opened
            SetTimer, HideTooltip, -1500
            SendDiscordMessage(webhookURL, "Cosmetic Shop Status", "Cosmetic Shop Opened.", COLOR_INFO)
            Sleep, 200
            for index, item in cosmeticItems {
                label := StrReplace(item, " ", "")
                currentItem := cosmeticItems[A_Index]
                Gosub, %label%
                SendDiscordMessage(webhookURL, "Cosmetic Purchased", "Bought " . currentItem, COLOR_SUCCESS)
                Sleep, 100
            }
            SendDiscordMessage(webhookURL, "Cosmetic Shop Status", "Cosmetic Shop Closed.", COLOR_INFO)
            cosmeticsCompleted = 1
        }
        if (cosmeticsCompleted) {
            break
        }
        Sleep, 2000
    }

    if (cosmeticsCompleted) {
        Sleep, 500
        uiUniversal("111114150320")
    }
    else {
        SendDiscordMessage(webhookURL, "Shop Detection Failed", "Failed to detect Cosmetic Shop opening.", COLOR_ERROR, PingSelected)
        ; failsafe
        uiUniversal("11114111350")
        Sleep, 50
        uiUniversal("11110")
    }

    hotbarController(0, 1, "0")
    SendDiscordMessage(webhookURL, "Cosmetics Completed", "Finished the cosmetic buying cycle.", COLOR_COMPLETED)

Return

SummerShopPath:

    summerCompleted := false
    shopOpened := false
    summerShopFailed := false
        SendDiscordMessage(webhookURL, "[Debug] SummerShopPath", "Function started.", COLOR_INFO, false, true)

    WinActivate, ahk_exe RobloxPlayerBeta.exe
    Sleep, 100
    uiUniversal(11110)
    Sleep, 100
    uiUniversal(111110)
    Sleep, 100
    Sleep, % FastMode ? 500 : 2500
    Send, {d down}
    Sleep, 9900
    Send, {d up}
    Sleep, 30
    Send, {s down}
    Sleep, 900
    Send, {s up}
    Sleep, 200
    Loop, 4 {
        Send, {WheelDown}
        Sleep, 20
    }
    ; Talk To NPC
    Sleep, 250
    Send, {e}
    Sleep, 1500

    ; Repositioning Camera View
    Loop, 20 {
    Send, {WheelUp}
    Sleep, 20
    }
    Loop, 6 {
        Send, {WheelDown}
        Sleep, 20
    }
    Sleep, 500
    SafeClickRelative(0.61, 0.43) ;use F4 to get the exact value of the right place for you
    Sleep, 100
    SafeClickRelative(0.61, 0.46) ;use F4 to get the exact value of the right place for you
    Sleep, % FastMode ? 500 : 1500
    SendDiscordMessage(webhookURL, "Summer Cycle", "Starting summer buying cycle.", COLOR_INFO)
    Sleep, % FastMode ? 2500 : 5000

     ; detect shop open (up to 5 tries)
    Loop, 5 {
        SendDiscordMessage(webhookURL, "[Debug] SummerShopPath", "Shop detection loop, attempt " . A_Index, COLOR_INFO, false, true)
        if (simpleDetect(0xFAB312, 10, 0.54, 0.20, 0.65, 0.325) ) {
            shopOpened := true
            CheckAndCloseBuyOption()
            ToolTip, Summer Shop Opened
            SetTimer, HideTooltip, -1500
        SendDiscordMessage(webhookURL, "Summer Shop Status", "Summer Shop Opened.", COLOR_INFO)
            Sleep, 200
	break
        }
        Sleep, 2000
    }

    if (!shopOpened) {
        SendDiscordMessage(webhookURL, "Shop Detection Failed", "Failed to detect Summer Shop opening.", COLOR_ERROR, PingSelected)
        uiUniversal("3332223111133322231111501450")
	summerShopFailed := true
    if (AutoAlign) {
        GoSub, cameraChange
        Sleep, 100
        Gosub, zoomAlignment
        Sleep, 100
        GoSub, cameraAlignment
        Sleep, 100
        Gosub, characterAlignment
        Sleep, 100
        Gosub, cameraChange
    }
        Return
    }
    ; shop opennig 
    uiUniversal("3331144333311144505044", 0)
    Sleep, 100

    summerNames := ["Summer Seed Pack", "Delphinium Seed", "Lily Of The Valley Seed", "Traveler's Fruit Seed", "Mutation Spray Burnt", "Oasis Crate"
                , "Oasis Egg", "Hamster"]

    summerPaths := [ "3333333333333333333444435044"
                    , "33333333333333333334444504"
                    , "333333333333333333344444504"
                    , "3333333333333333333444444504"
                    , "33333333333333333334444444504"
                    , "3333333333333333333444444445044"
                    , "333333333333333333344444444445044"
                    , "3333333333333333333444444444444504" ]

    selectedSummerItems := []
    Loop, % summerNames.Length()
    {
        IniRead, value, %A_ScriptDir%\settings.ini, Summer, Item%A_Index%, 0
        if (value = 1)
            selectedSummerItems.Push(A_Index)
    }

    for index, idx in selectedSummerItems {
        currentItem := summerNames[idx]
        path := summerPaths[idx]

        uiUniversal(path, 0, 1)
        quickDetect(0x26EE26, 0x1DB31D, 5, 0.4262, 0.2903, 0.6918, 0.8208)
        uiUniversal("350", 0, 1)
        Sleep, 300
    }

    SendDiscordMessage(webhookURL, "Summer Shop Has Now Been Closed.")
	summerCompleted := true
    if (summerCompleted) {
        Sleep, 500
        uiUniversal("3333333333333322225006", 1, 1)
        Sleep, 120          ; in case a robux prompt
        Send, {Escape}
        Sleep, 80
        Send, {Escape}
        Sleep, 50
        SendDiscordMessage(webhookURL, "Summer Completed", "Finished the summer buying cycle.", COLOR_COMPLETED)
    }
			Sleep, % FastMode ? 150 : 1500
    if (AutoAlign) {
        GoSub, cameraChange
        Sleep, 100
        Gosub, zoomAlignment
        Sleep, 100
        GoSub, cameraAlignment
        Sleep, 100
        Gosub, characterAlignment
        Sleep, 100
        Gosub, cameraChange
    }
    else {
        Gosub, zoomAlignment
    }
Return


ClickFirstFour() {
        SafeClickRelative(0.35, 0.70)
        Sleep, % FastMode ? 50 : 200
        Send, {e}
        Sleep, % FastMode ? 400 : 200
        SafeClickRelative(0.38, 0.70)
        Sleep, % FastMode ? 50 : 200
        Send, {e}
        Sleep, % FastMode ? 400 : 200
        SafeClickRelative(0.415, 0.70)
        Sleep, % FastMode ? 50 : 200
        Send, {e}
        Sleep, % FastMode ? 400 : 200
        SafeClickRelative(0.45, 0.70)
        Sleep, % FastMode ? 50 : 200
        Send, {e}
        Sleep, % FastMode ? 400 : 200
}

ClickFirstEight() {
        SafeClickRelative(0.35, 0.70)
        Sleep, % FastMode ? 50 : 200
        Send, {e}
        Sleep, % FastMode ? 400 : 200
        SafeClickRelative(0.38, 0.70)
        Sleep, % FastMode ? 50 : 200
        Send, {e}
        Sleep, % FastMode ? 400 : 200
        SafeClickRelative(0.415, 0.70)
        Sleep, % FastMode ? 50 : 200
        Send, {e}
        Sleep, % FastMode ? 400 : 200
        SafeClickRelative(0.45, 0.70)
        Sleep, % FastMode ? 50 : 200
        Send, {e}
        Sleep, % FastMode ? 400 : 200
        SafeClickRelative(0.485, 0.70)
        Sleep, % FastMode ? 50 : 200
        Send, {e}
        Sleep, % FastMode ? 400 : 200
        SafeClickRelative(0.52, 0.70)
        Sleep, % FastMode ? 50 : 200
        Send, {e}
        Sleep, % FastMode ? 400 : 200
        SafeClickRelative(0.555, 0.70)
        Sleep, % FastMode ? 50 : 200
        Send, {e}
        Sleep, % FastMode ? 400 : 200
        SafeClickRelative(0.59, 0.70)
        Sleep, % FastMode ? 50 : 200
        Send, {e}
}


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
    uiUniversal("63636363616066664646460")
    Sleep, % FastMode ? 100 : 300
    SendInput, ^{Backspace 5}
    Sleep, % FastMode ? 100 : 300
    Send, pollinated

    Loop, 3
    {
	ClickFirstFour()
    }
    Send, 2
    Sleep, 100
    Send, 2
    Sleep, 100
    Sleep, 30000
    Send, {e}
    Sleep, 100
    Loop, 3
    {
	ClickFirstFour()
    }
    Send, 2
    Sleep, 100
    Send, 2
    Sleep, 100
    Sleep, 30000
    Send, {e}
    Sleep, 100
    Loop, 3
    {
	ClickFirstFour()
    }

    Sleep, % FastMode ? 150 : 300
    SafeClickRelative(0.64, 0.51)
    Sleep, % FastMode ? 100 : 200
    Send, {2}
    Send, {2}
    Sleep, % FastMode ? 100 : 200
    uiUniversal("63636363636161616160")
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

        Sleep, 120          ; in case a robux prompt
        Send, {Escape}
        Sleep, 80
        Send, {Escape}
        Sleep, 50
Return


ClickSeedFilter() {
        SafeClickRelative(0.31, 0.72)
}
ClickFruitFilter() {
        SafeClickRelative(0.31, 0.78)
}
	

AutoSeedCraftPath:

if (cycleCount = 0 && ManualSeedCraftLock > 0) {
	seedCraftingLocked := 1
	SetTimer, UnlockSeedCraft, -%ManualSeedCraftLock%
Return
}

selectedSeedCraftingItems := []
Loop, 12 {
    lastRanItem := currentItem 
    IniRead, value, %A_ScriptDir%\settings.ini, SeedCrafting, Item%A_Index%, 0
    if (value = 1)
        selectedSeedCraftingItems.Push(A_Index)
}

if (seedCraftActionQueue.Length() = 0) {
    for index, item in selectedSeedCraftingItems
        seedCraftActionQueue.Push(item)
}

    seedCraftCompleted := false
    seedCraftShopOpened := false
    seedCraftShopFailed := false

CraftShopUiFix() {
    uiUniversal("33333333")
    Sleep, % FastMode ? 100 : 300
    uiUniversal("51515154545450505333333")
    Sleep, % FastMode ? 100 : 300
    uiUniversal("3333333545450505")
}

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
    Sleep, 900
    Send, {Down Up}
    sleepAmount(100, 1000)
    Send, {c}
    Sleep, % FastMode ? 100 : 300
    Send, {e}
    Sleep, % FastMode ? 500 : 1500
    Send, {e}
    Sleep, % FastMode ? 100 : 300
Loop, 5 {
        if (simpleDetect(0xA0014C, 15, 0.54, 0.20, 0.65, 0.325)) {
            ToolTip, Seed Crafter Opened
            SetTimer, HideTooltip, -1500
            seedCraftShopOpened := true
            SendDiscordMessage(webhookURL, "Seed Crafter Status", "Seed Crafter Opened.", COLOR_INFO)
	    break
	}
        else if (simpleDetect(0xA3014D, 15, 0.54, 0.20, 0.65, 0.325)) {
            ToolTip, Seed Crafter Opened
            SetTimer, HideTooltip, -1500
            seedCraftShopOpened := true
            SendDiscordMessage(webhookURL, "Seed Crafter Status", "Seed Crafter Opened.", COLOR_INFO)
	    break
	}
}

    if (!seedCraftShopOpened) {
        SendDiscordMessage(webhookURL, "Shop Detection Failed", "Failed to detect Seed Crafter opening.", COLOR_ERROR, PingSelected)
        uiUniversal("63636362626263616161616363636262626361616161606561646056")
	seedCraftShopFailed := true
    if (AutoAlign) {
        GoSub, cameraChange
        Sleep, 100
        Gosub, zoomAlignment
        Sleep, 100
        GoSub, cameraAlignment
        Sleep, 100
        Gosub, characterAlignment
        Sleep, 100
        Gosub, cameraChange
    }
        Return
    }

if (seedCraftActionQueue.Length() > 0) {
    currentCraftingItem := seedCraftActionQueue[1]

    if (currentCraftingItem = 1) {
	CraftShopUiFix()
	currentItem := "Peace Lily"
        uiUniversal("333333354545505545505")

	Sleep, 100
	searchItem("rafflesia")
	Sleep, 100
	ClickSeedFilter()
	Sleep, 100
	ClickFirstFour()
	Sleep, 100
        Send, {vkC0sc029}
	Sleep, 100
	searchItem("cauliflower")
	Sleep, 100
	ClickSeedFilter()
	Sleep, 100
	ClickFirstFour()
	Sleep, 100
        Send, {vkC0sc029}
	Sleep, 500
	closeRobuxPrompt()

	seedCraftingLocked := 1
	SetTimer, UnlockSeedCraft, -1200000 
	SendDiscordMessage(webhookURL, "Crafting Attempted", "Attempted to craft " . currentItem . ".", COLOR_INFO)
        seedCraftActionQueue.RemoveAt(1)
        Sleep, 50
    }
    if (currentCraftingItem = 2) {
	currentItem := "Aloe Vera Seed"
    uiUniversal("33333333")
    Sleep, % FastMode ? 100 : 300
    uiUniversal("515151545450505333333")
    Sleep, % FastMode ? 100 : 300
    uiUniversal("3333333545450505")

        uiUniversal("333333333354545450545505")

	Sleep, 100
	searchItem("peace")
	Sleep, 100
	ClickSeedFilter()
	Sleep, 100
	ClickFirstFour()
	Sleep, 100
        Send, {vkC0sc029}
	Sleep, 100
	searchItem("prickly")
	Sleep, 100
	ClickSeedFilter()
	Sleep, 100
	ClickFirstFour()
	Sleep, 100
        Send, {vkC0sc029}
	Sleep, 500
	closeRobuxPrompt()

	seedCraftingLocked := 1
	SetTimer, UnlockSeedCraft, -600000
	SendDiscordMessage(webhookURL, "Crafting Attempted", "Attempted to craft " . currentItem . ".", COLOR_INFO)
        seedCraftActionQueue.RemoveAt(1)
        Sleep, 50
    }
    if (currentCraftingItem = 3) {
        uiUniversal("3333333545450505")
	currentItem := "Guanabana Seed"
        uiUniversal("33333333335454545450545505")

	Sleep, 100
	searchItem("bamboo")
	Sleep, 100
	ClickFruitFilter()
	Sleep, 100
	ClickFirstFour()
	Sleep, 100
        Send, {vkC0sc029}
	Sleep, 100
	searchItem("manuka")
	Sleep, 100
	ClickSeedFilter()
	Sleep, 100
	ClickFirstFour()
	Sleep, 500
	closeRobuxPrompt()

	seedCraftingLocked := 1
	SetTimer, UnlockSeedCraft, -960000
	SendDiscordMessage(webhookURL, "Crafting Attempted", "Attempted to craft " . currentItem . ".", COLOR_INFO)
        seedCraftActionQueue.RemoveAt(1)
        Sleep, 50
    }

}
    seedCraftCompleted := true
    Sleep, % FastMode ? 100 : 200
	Send, {2}
	Send, {2}
    Sleep, % FastMode ? 100 : 200
    uiUniversal("63636363636161616160")
    SendDiscordMessage(webhookURL, "Seed Crafting Complete", "Finished the seed crafting cycle.", COLOR_COMPLETED)
    Sleep, % FastMode ? 100 : 200
    if (AutoAlign) {
        GoSub, cameraChange
        Sleep, 100
        Gosub, zoomAlignment
        Sleep, 100
        GoSub, cameraAlignment
        Sleep, 100
        Gosub, characterAlignment
        Sleep, 100
        Gosub, cameraChange
    }
Return

AutoBearCraftPath:

if (cycleCount = 0 && ManualBearCraftLock > 0) {
	bearCraftingLocked := 1
	SetTimer, UnlockBearCraft, -%ManualBearCraftLock%
Return
}

selectedBearCraftingItems := []
Loop, 15 {
    lastRanItem := currentItem 
    IniRead, value, %A_ScriptDir%\settings.ini, BearCrafting, Item%A_Index%, 0
    if (value = 1)
        selectedBearCraftingItems.Push(A_Index)
}

if (bearCraftActionQueue.Length() = 0) {
    for index, item in selectedBearCraftingItems
        bearCraftActionQueue.Push(item)
}

    bearCraftCompleted := false
    bearCraftShopOpened := false
    bearCraftShopFailed := false

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
    Sleep, 1200
    Send, {Down Up}
    sleepAmount(100, 1000)
    Send, {c}
    Sleep, % FastMode ? 100 : 300
    Send, {e}
    Sleep, % FastMode ? 500 : 1500
    Send, {e}
    Sleep, % FastMode ? 100 : 300
Loop, 5 {
        if (simpleDetect(0xA0014C, 15, 0.54, 0.20, 0.65, 0.325)) {
            ToolTip, Seed Crafter Opened
            SetTimer, HideTooltip, -1500
            bearCraftShopOpened := true
            SendDiscordMessage(webhookURL, "Bear Crafter Status", "Bear Crafter Opened.", COLOR_INFO)
	    break
	}
        else if (simpleDetect(0xA3014D, 15, 0.54, 0.20, 0.65, 0.325)) {
            ToolTip, Seed Crafter Opened
            SetTimer, HideTooltip, -1500
            bearCraftShopOpened := true
            SendDiscordMessage(webhookURL, "Bear Crafter Status", "Bear Crafter Opened.", COLOR_INFO)
	    break
	}
}

    if (!bearCraftShopOpened) {
        SendDiscordMessage(webhookURL, "Shop Detection Failed", "Failed to detect Bear Crafter opening.", COLOR_ERROR, PingSelected)
        uiUniversal("63636362626263616161616363636262626361616161606561646056")
	bearCraftShopFailed := true
    if (AutoAlign) {
        GoSub, cameraChange
        Sleep, 100
        Gosub, zoomAlignment
        Sleep, 100
        GoSub, cameraAlignment
        Sleep, 100
        Gosub, characterAlignment
        Sleep, 100
        Gosub, cameraChange
    }
        Return
    }

if (bearCraftActionQueue.Length() > 0) {
    currentCraftingItem := bearCraftActionQueue[1]

    if (currentCraftingItem = 1) {
	CraftShopUiFix()
	currentItem := "Lightning Rod"
        uiUniversal("3333333545450545505")

	Sleep, 100
	searchItem("basic")
	Sleep, 100
	ClickFirstFour()
	Sleep, 100
        Send, {vkC0sc029}
	Sleep, 100
	searchItem("advanced")
	Sleep, 100
	ClickFirstFour()
	Sleep, 100
        Send, {vkC0sc029}
	Sleep, 100
	searchItem("godly")
	Sleep, 100
	ClickFirstFour()
	Sleep, 100
        Send, {vkC0sc029}
	Sleep, 500
	closeRobuxPrompt()
	Sleep, 100

	bearCraftingLocked := 1
	SetTimer, UnlockBearCraft, -2700000
	SendDiscordMessage(webhookURL, "Crafting Attempted", "Attempted to craft " . currentItem . ".", COLOR_INFO)
        bearCraftActionQueue.RemoveAt(1)
        Sleep, 50
    }
    if (currentCraftingItem = 2) {
	CraftShopUiFix()
	currentItem := "Reclaimer"
        uiUniversal("333333354545450545505")

	Sleep, 100
	searchItem("common")
	Sleep, 100
	ClickFirstFour()
	Sleep, 100
        Send, {vkC0sc029}
	Sleep, 100
	searchItem("harvest")
	Sleep, 100
	ClickFirstFour()
	Sleep, 100
        Send, {vkC0sc029}
	Sleep, 500
	closeRobuxPrompt()
	Sleep, 100

	bearCraftingLocked := 1
	SetTimer, UnlockBearCraft, -1500000
	SendDiscordMessage(webhookURL, "Crafting Attempted", "Attempted to craft " . currentItem . ".", COLOR_INFO)
        bearCraftActionQueue.RemoveAt(1)
        Sleep, 50
    }
    if (currentCraftingItem = 3) {
	CraftShopUiFix()
	currentItem := "Tropical Mist Sprinkler"
        uiUniversal("33333335454545450545505")

	Sleep, 100
	searchItem("coconut")
	Sleep, 100
	ClickFruitFilter()
	Sleep, 100
	ClickFirstFour()
	Sleep, 100
        Send, {vkC0sc029}
	Sleep, 100
	searchItem("dragon")
	Sleep, 100
	ClickFruitFilter()
	Sleep, 100
	ClickFirstFour()
	Sleep, 100
        Send, {vkC0sc029}
	Sleep, 100
	searchItem("mango")
	Sleep, 100
	ClickFruitFilter()
	Sleep, 100
	ClickFirstFour()
	Sleep, 100
        Send, {vkC0sc029}
	Sleep, 100
	searchItem("godly")
	Sleep, 100
	ClickFirstFour()
	Sleep, 500
	closeRobuxPrompt()
	Sleep, 100

	bearCraftingLocked := 1
	SetTimer, UnlockBearCraft, -3600000
	SendDiscordMessage(webhookURL, "Crafting Attempted", "Attempted to craft " . currentItem . ".", COLOR_INFO)
        bearCraftActionQueue.RemoveAt(1)
        Sleep, 50
    }
    if (currentCraftingItem = 4) {

	CraftShopUiFix()
	currentItem := "Berry Blusher Sprinkler"
        uiUniversal("3333333545454545450545505")

	Sleep, 100
	searchItem("grape")
	Sleep, 100
	ClickFruitFilter()
	Sleep, 100
	ClickFirstFour()
	Sleep, 100
        Send, {vkC0sc029}
	Sleep, 100
	searchItem("blueberry")
	Sleep, 100
	ClickFruitFilter()
	Sleep, 100
	ClickFirstFour()
	Sleep, 100
        Send, {vkC0sc029}
	Sleep, 100
	searchItem("strawberry")
	Sleep, 100
	ClickFruitFilter()
	Sleep, 100
	ClickFirstFour()
	Sleep, 100
        Send, {vkC0sc029}
	Sleep, 100
	searchItem("godly")
	Sleep, 100
	ClickFirstFour()
	Sleep, 500
	closeRobuxPrompt()
	Sleep, 100

	bearCraftingLocked := 1
	SetTimer, UnlockBearCraft, -3600000
	SendDiscordMessage(webhookURL, "Crafting Attempted", "Attempted to craft " . currentItem . ".", COLOR_INFO)
        bearCraftActionQueue.RemoveAt(1)
        Sleep, 50
    }
    if (currentCraftingItem = 5) {

        uiUniversal("33333333")
        Sleep, % FastMode ? 100 : 300
        uiUniversal("5151515454545454545450505333333")
        Sleep, % FastMode ? 100 : 300
        uiUniversal("3333333545454545450505")

	CraftShopUiFix()
	currentItem := "Spice Spritzer Sprinkler"
        uiUniversal("333333354545454545450545505")

	Sleep, 100
	searchItem("pepper")
	Sleep, 100
	ClickFruitFilter()
	Sleep, 100
	ClickFirstFour()
	Sleep, 100
        Send, {vkC0sc029}
	Sleep, 100
	searchItem("ember")
	Sleep, 100
	ClickFruitFilter()
	Sleep, 100
	ClickFirstFour()
	Sleep, 100
        Send, {vkC0sc029}
	Sleep, 100
	searchItem("cacao")
	Sleep, 100
	ClickFruitFilter()
	Sleep, 100
	ClickFirstFour()
	Sleep, 100
        Send, {vkC0sc029}
	Sleep, 100
	searchItem("master")
	Sleep, 100
	ClickFirstFour()
	Sleep, 500
	closeRobuxPrompt()
	Sleep, 100

	bearCraftingLocked := 1
	SetTimer, UnlockBearCraft, -3600000
	SendDiscordMessage(webhookURL, "Crafting Attempted", "Attempted to craft " . currentItem . ".", COLOR_INFO)
        bearCraftActionQueue.RemoveAt(1)
        Sleep, 50
    }
    if (currentCraftingItem = 6) {

	CraftShopUiFix()
	currentItem := "Sweet Soaker Sprinkler"
        uiUniversal("33333335454545454545450545505")

	Sleep, 100
	searchItem("watermelon")
	Sleep, 100
	ClickFruitFilter()
	Sleep, 100
	ClickFirstFour()
	Sleep, 100
	ClickFirstFour()
	Sleep, 100
	searchItem("master")
	Sleep, 100
	ClickFirstFour()
	Sleep, 500
	closeRobuxPrompt()
	Sleep, 100

	bearCraftingLocked := 1
	SetTimer, UnlockBearCraft, -3600000
	SendDiscordMessage(webhookURL, "Crafting Attempted", "Attempted to craft " . currentItem . ".", COLOR_INFO)
        bearCraftActionQueue.RemoveAt(1)
        Sleep, 50
    }
    if (currentCraftingItem = 7) {
	CraftShopUiFix()
	currentItem := "Flower Froster Sprinkler"
        uiUniversal("3333333545454545454545450545505")

	Sleep, 100
	searchItem("orange")
	Sleep, 100
	ClickFruitFilter()
	Sleep, 100
	ClickFirstFour()
	Sleep, 100
        Send, {vkC0sc029}
	Sleep, 100
	searchItem("daffodil")
	Sleep, 100
	ClickFruitFilter()
	Sleep, 100
	ClickFirstFour()
	Sleep, 100
        Send, {vkC0sc029}
	Sleep, 100
	searchItem("advanced")
	Sleep, 100
	ClickFruitFilter()
	Sleep, 100
	ClickFirstFour()
	Sleep, 100
        Send, {vkC0sc029}
	Sleep, 100
	searchItem("basic")
	Sleep, 100
	ClickFirstFour()
	Sleep, 500
	closeRobuxPrompt()
	Sleep, 100

	bearCraftingLocked := 1
	SetTimer, UnlockBearCraft, -3600000
	SendDiscordMessage(webhookURL, "Crafting Attempted", "Attempted to craft " . currentItem . ".", COLOR_INFO)
        bearCraftActionQueue.RemoveAt(1)
        Sleep, 50
    }
    if (currentCraftingItem = 8) {
	CraftShopUiFix()
	currentItem := "Stalk Sprout Sprinkler"
        uiUniversal("33333333333354545454545454545450545505")

	Sleep, 100
	searchItem("bamboo")
	Sleep, 100
	ClickFruitFilter()
	Sleep, 100
	ClickFirstFour()
	Sleep, 100
        Send, {vkC0sc029}
	Sleep, 100
	searchItem("beanstalk")
	Sleep, 100
	ClickFruitFilter()
	Sleep, 100
	ClickFirstFour()
	Sleep, 100
        Send, {vkC0sc029}
	Sleep, 100
	searchItem("mushroom")
	Sleep, 100
	ClickFruitFilter()
	Sleep, 100
	ClickFirstFour()
	Sleep, 100
        Send, {vkC0sc029}
	Sleep, 100
	searchItem("advanced")
	Sleep, 100
	ClickFirstFour()
	Sleep, 500
	closeRobuxPrompt()
	Sleep, 100

	bearCraftingLocked := 1
	SetTimer, UnlockBearCraft, -3600000
	SendDiscordMessage(webhookURL, "Crafting Attempted", "Attempted to craft " . currentItem . ".", COLOR_INFO)
        bearCraftActionQueue.RemoveAt(1)
        Sleep, 50
    }
    if (currentCraftingItem = 9) {
	CraftShopUiFix()
	currentItem := "Mutation Spray Choc"
        uiUniversal("33333333333333335454545454545454545450545505")

	Sleep, 100
	searchItem("cacao")
	Sleep, 100
	ClickFruitFilter()
	Sleep, 100
	ClickFirstFour()
	Sleep, 100
        Send, {vkC0sc029}
	Sleep, 100
	searchItem("cleaning")
	Sleep, 100
	ClickFirstFour()
	Sleep, 500
	closeRobuxPrompt()
	Sleep, 100

	bearCraftingLocked := 1
	SetTimer, UnlockBearCraft, -720000
	SendDiscordMessage(webhookURL, "Crafting Attempted", "Attempted to craft " . currentItem . ".", COLOR_INFO)
        bearCraftActionQueue.RemoveAt(1)
        Sleep, 50
    }
    if (currentCraftingItem = 10) {
	CraftShopUiFix()
	currentItem := "Mutation Spray Chilled"
        uiUniversal("3333333333333333545454545454545454545450545505")

	Sleep, 100
	searchItem("godly")
	Sleep, 100
	ClickFirstFour()
	Sleep, 100
        Send, {vkC0sc029}
	Sleep, 100
	searchItem("cleaning")
	Sleep, 100
	ClickFirstFour()
	Sleep, 500
	closeRobuxPrompt()
	Sleep, 100

	bearCraftingLocked := 1
	SetTimer, UnlockBearCraft, -300000
	SendDiscordMessage(webhookURL, "Crafting Attempted", "Attempted to craft " . currentItem . ".", COLOR_INFO)
        bearCraftActionQueue.RemoveAt(1)
        Sleep, 50
    }
    if (currentCraftingItem = 11) {
	CraftShopUiFix()
	currentItem := "Mutation Spray Shocked"
        uiUniversal("333333333333333354545454545454545454545450545505")

	Sleep, 100
	searchItem("lightning")
	Sleep, 100
	ClickFruitFilter()
	Sleep, 100
	ClickFirstFour()
	Sleep, 100
        Send, {vkC0sc029}
	Sleep, 100
	searchItem("cleaning")
	Sleep, 100
	ClickFirstFour()
	Sleep, 500
	closeRobuxPrompt()
	Sleep, 100

	bearCraftingLocked := 1
	SetTimer, UnlockBearCraft, -1800000
	SendDiscordMessage(webhookURL, "Crafting Attempted", "Attempted to craft " . currentItem . ".", COLOR_INFO)
        bearCraftActionQueue.RemoveAt(1)
        Sleep, 50
    }
    if (currentCraftingItem = 12) {
	CraftShopUiFix()
	currentItem := "Anti Bee Egg"
        uiUniversal("333333333333333354545454545454545454545454555054545505")

	Sleep, 100
	searchItem("egg")
	Sleep, 100
	ClickFirstEight()
	Sleep, 500
	closeRobuxPrompt()
	Sleep, 100

	bearCraftingLocked := 1
	SetTimer, UnlockBearCraft, -7200000
	SendDiscordMessage(webhookURL, "Crafting Attempted", "Attempted to craft " . currentItem . ".", COLOR_INFO)
        bearCraftActionQueue.RemoveAt(1)
        Sleep, 50
    }
    if (currentCraftingItem = 13) {
	CraftShopUiFix()
	currentItem := "Pack Bee"
        uiUniversal("33333333333333335454545454545454545454545454545550545505")

	Sleep, 100
	searchItem("sunflower")
	Sleep, 100
	ClickFruitFilter()
	Sleep, 100
	ClickFirstFour()
	Sleep, 100
        Send, {vkC0sc029}
	Sleep, 100
	searchItem("dahlia")
	Sleep, 100
	ClickFruitFilter()
	Sleep, 100
	ClickFirstFour()
	Sleep, 100
        Send, {vkC0sc029}
	Sleep, 100
	searchItem("egg")
	Sleep, 100
	ClickFirstEight()
	Sleep, 500
	closeRobuxPrompt()
	Sleep, 100

	bearCraftingLocked := 1
	SetTimer, UnlockBearCraft, -14400000
	SendDiscordMessage(webhookURL, "Crafting Attempted", "Attempted to craft " . currentItem . ".", COLOR_INFO)
        bearCraftActionQueue.RemoveAt(1)
        Sleep, 50
    }
}

    bearCraftCompleted := true
    Sleep, % FastMode ? 100 : 200
	Send, {2}
	Send, {2}
    Sleep, % FastMode ? 100 : 200
    uiUniversal("63636363636161616160")
    SendDiscordMessage(webhookURL, "Bear Crafting Complete", "Finished the bear crafting cycle.", COLOR_COMPLETED)
    Sleep, % FastMode ? 100 : 200
    if (AutoAlign) {
        GoSub, cameraChange
        Sleep, 100
        Gosub, zoomAlignment
        Sleep, 100
        GoSub, cameraAlignment
        Sleep, 100
        Gosub, characterAlignment
        Sleep, 100
        Gosub, cameraChange
    }
Return

UnlockSeedCraft:
    seedCraftingLocked := 0
Return

UnlockBearCraft:
    bearCraftingLocked := 0
Return

; cosmetic labels

Cosmetic1:

    Sleep, 50
    Loop, 2 {
        uiUniversal("11111445000000000000")
        sleepAmount(50, 200)
    }

Return

Cosmetic2:

    Sleep, 50
    Loop, 2 {
        uiUniversal("11111442250000000000000")
        sleepAmount(50, 200)
    }

Return

Cosmetic3:

    Sleep, 50
    Loop, 2 {
        uiUniversal("11111442222500000000000")
        sleepAmount(50, 200)
    }

Return

Cosmetic4:

    Sleep, 50
    Loop, 2 {
        uiUniversal("111114422224500000000000")
        sleepAmount(50, 200)
    }

Return

Cosmetic5:

    Sleep, 50
    Loop, 2 {
        uiUniversal("111114422224150000000000")
        sleepAmount(50, 200)
    }

Return

Cosmetic6:

    Sleep, 50
    Loop, 2 {
        uiUniversal("111114422224115000000000")
        sleepAmount(50, 200)
    }

Return

Cosmetic7:

    Sleep, 50
    Loop, 2 {
        uiUniversal("1111144222241115000000000")
        sleepAmount(50, 200)
    }

Return

Cosmetic8:

    Sleep, 50
    Loop, 2 {
        uiUniversal("1111144222241111500000000")
        sleepAmount(50, 200)
    }

Return

Cosmetic9:

    Sleep, 50
    Loop, 2 {
        uiUniversal("11111442222411111500000000")
        sleepAmount(50, 200)
    }

Return


SummerHarvestPath:

    global savedHarvestSpeed

    cycleCounter := 0

    if(LoadInputs()){
        ToolTip, No Saved Path Found! `n Skipping Summer Harvest Path
        Sleep, 5000
        return
    }
    SendDiscordMessage(webhookURL, "**[Summer Harvest Started]**")
    IniRead, numberOfCycle, %settingsFile%, Main, NumberOfCycle
    if (numberOfCycle = "ERROR" || numberOfCycle = "")
        numberOfCycle := 3
    Loop, %numberOfCycle% {
        cycleCounter++
        SendDiscordMessage(webhookURL, "**Cycle Number: ** **" . cycleCounter . "** out of **" . numberOfCycle . "**")
        uiUniversal(11110)
        PlayInputs()
        Sleep, 100
        Send, {o down}
        Sleep, 300
        Send, {o up}
        Sleep, 100

        if(savedHarvestSpeed = "Fast"){
            ; For Safe Clearing

            Send, {Space up}
            Send, {Right up}

            ; =================

            Loop, 20 {
            Send, {WheelUp}
            Sleep, 20
            }
            Sleep, 100
            Loop, 3 {
                Send, {WheelDown}
                Sleep, 20
            }
            Sleep, 100
            Send, {Space down}
            Sleep, 100
            Send, {Right down}
            Sleep, 100
            SetTimer, SpamE, 10
            ToolTip, Collecting Fruits. Please Wait~
            Sleep, (20 * 1000)  ; 20 seconds
            SetTimer, SpamE, Off
            Send, {Space up}
            Send, {Right up}
            ToolTip, Done!

            ; Fix Camera
            SafeClickRelative(0.5, 0.5)
            Sleep, 100
            GoSub, cameraChange
            Sleep, 100
            Gosub, zoomAlignment
            Sleep, 100
            GoSub, cameraAlignment
            Sleep, 100
            Gosub, characterAlignment
            Sleep, 100
            Gosub, cameraChange
            Sleep, 100
        }
        else
        {
            ; Stable way of collecting fruits
            Send, {e down}
            ToolTip, Collecting Fruits. Please Wait~
            Sleep, % (30 * 1000) ; Hold for 30 sec
            Send, {e up}
            ToolTip, Done!
            ; Repositioning Camera After Collect
            Loop, 20 {
            Send, {WheelUp}
            Sleep, 20
            }
            Sleep, 100
            Loop, 6 {
                Send, {WheelDown}
                Sleep, 20
            }
        }
        Sleep, 1000
        ToolTip
        Sleep, 1000
        uiUniversal(11110)
        Sleep, 100
        uiUniversal(111110)
        Sleep, 100
        Send, {d down}
        Sleep, % ((10 * 1000) + 700) ; Hold for 10.7 sec
        Send, {d up}
        Sleep, 30
        Send, {s down}
        Sleep, 900
        Send, {s up}
        Loop, 4 {
            Send, {WheelDown}
            Sleep, 20
        }
        ; Talk To NPC
        Send, e
        Sleep, 1500

        ; Repositioning Camera View
        Loop, 20 {
        Send, {WheelUp}
        Sleep, 20
        }
        Loop, 6 {
            Send, {WheelDown}
            Sleep, 20
        }
        Sleep, 500
        SafeClickRelative(0.66, 0.58) ;use F4 to get the exact value of the right place for you
        Sleep, 1000
        uiUniversal(11110)
    }
    cycleCounter := 0 ;reset cycle count
    SendDiscordMessage(webhookURL, "**[Summer Harvest Finished]**")

Return

; === Toggle Recording ===
ToggleRecording() {
    global recording, inputList, startTime, lastEventTime, keyStates

    if (!recording) {
        Gosub, alignment
        recording := true
        inputList := []
        keyStates := {}
        startTime := A_TickCount
        lastEventTime := startTime
        SetTimer, MonitorInputs, 10
        ToolTip Recording started... (Press F1 to stop)
        Sleep, 1500
    } else {
        recording := false
        SetTimer, MonitorInputs, Off
        ToolTip
        SaveInputs()  ; Save when stopping
        MsgBox % "Recording stopped. " inputList.MaxIndex() " events recorded and saved."
    }
}

; === Playback ===
DemoInput(){
    global inputList, playback

    if (inputList.MaxIndex() = "")
    {
        MsgBox No input recorded.
        return
    }
    Gosub, alignment
    PlayInputs()
}

PlayInputs() {
    global inputList, playback

    if (inputList.MaxIndex() = "")
    {
        ToolTip, No input recorded!
        return
    }
    ; Gosub, alignment
    /*
    Sleep, 1000
    uiUniversal(11110)
    Sleep, 100
    */
    playback := true
    ToolTip Emulating Recorded Path...
    for index, item in inputList {
        Sleep, % item.time

        if (item.type = "key") {
            if (item.event = "down")
                SendInput % "{" item.key " down}"
            else if (item.event = "up")
                SendInput % "{" item.key " up}"
        } else if (item.type = "mouse") {
            MouseMove, % item.x, % item.y, 0
            if (item.button = "LButton")
                Click, left
            else if (item.button = "RButton")
                Click, right
            else if (item.button = "MButton")
                Click, middle
        }
    }
    ToolTip
    playback := false
}

; === Input Monitoring Timer ===
MonitorInputs:
    global inputList, lastEventTime, keyStates

    ; Mouse buttons
    for index, btn in ["LButton", "RButton", "MButton"] {
        state := GetKeyState(btn, "P")
        prev := keyStates.HasKey(btn) ? keyStates[btn] : 0
        if (state && !prev) {
            PushEvent("mouse", btn, A_TickCount)
        }
        keyStates[btn] := state
    }

    ; Keyboard keys
    Loop, 255 {
        vk := A_Index
        key := GetKeyName(Format("vk{:02X}", vk))
        if (key = "")
            continue

        ; Prevent recording toggle/play/load keys
        if (key = "F1" || key = "F2" || key = "F3")
            continue

        state := GetKeyState(key, "P")
        prev := keyStates.HasKey(key) ? keyStates[key] : 0
        now := A_TickCount

        if (state && !prev) {
            PushEvent("key", key, now, "down")
        } else if (!state && prev) {
            PushEvent("key", key, now, "up")
        }
        keyStates[key] := state
    }
return

; === Push Recorded Event ===
PushEvent(type, keyOrBtn, time, event:="") {
    global inputList, lastEventTime

    elapsed := time - lastEventTime
    lastEventTime := time

    if (type = "key") {
        inputList.Push({type: "key", key: keyOrBtn, event: event, time: elapsed})
    } else if (type = "mouse") {
        MouseGetPos, x, y
        inputList.Push({type: "mouse", button: keyOrBtn, x: x, y: y, time: elapsed})
    }
}

; === Save Inputs to File ===
SaveInputs() {
    global inputList
    macroFile := A_ScriptDir "\savedPath.ini"
    FileDelete, %macroFile%

    Loop, % inputList.MaxIndex()
    {
        i := A_Index
        event := inputList[i]
        section := "Event" . i

        IniWrite, % event.type,   %macroFile%, %section%, Type
        IniWrite, % event.time,   %macroFile%, %section%, Delay

        if (event.type = "key") {
            IniWrite, % event.key,    %macroFile%, %section%, Key
            IniWrite, % event.event,  %macroFile%, %section%, Action
        } else if (event.type = "mouse") {
            IniWrite, % event.button, %macroFile%, %section%, Button
            IniWrite, % event.x,      %macroFile%, %section%, X
            IniWrite, % event.y,      %macroFile%, %section%, Y
        }
    }
    IniWrite, % inputList.MaxIndex(), %macroFile%, Info, TotalEvents
}

; === Load Inputs from File ===
LoadInputs() {
    global inputList
    macroFile := A_ScriptDir "\savedPath.ini"

    if (!FileExist(macroFile)) {
        ToolTip, Load Failed! savedPath.ini not found!
        return true
    }

    inputList := []
    IniRead, totalEvents, %macroFile%, Info, TotalEvents, 0

    Loop, %totalEvents%
    {
        section := "Event" . A_Index
        IniRead, type,   %macroFile%, %section%, Type
        IniRead, delay,  %macroFile%, %section%, Delay

        if (type = "key") {
            IniRead, key,    %macroFile%, %section%, Key
            IniRead, action, %macroFile%, %section%, Action
            inputList.Push({type: "key", key: key, event: action, time: delay})
        } else if (type = "mouse") {
            IniRead, button, %macroFile%, %section%, Button
            IniRead, x,      %macroFile%, %section%, X
            IniRead, y,      %macroFile%, %section%, Y
            inputList.Push({type: "mouse", button: button, x: x, y: y, time: delay})
        }
    }
    if(totalEvents){
        ToolTip, % "Load Successful! " totalEvents " events loaded from the Saved Path!"
    }else{
        ToolTip, Empty Saved Path! No Paths were loaded.
    }
    Sleep, 1500
    ToolTip
}



; save settings and start/exit

SaveSettings:

    Gui, Submit, NoHide

    ; — now write them out —
    Loop, % eggItems.Length()
        IniWrite, % (eggItem%A_Index% ? 1 : 0), %settingsFile%, Egg, Item%A_Index%

    Loop, % gearItems.Length()
        IniWrite, % (GearItem%A_Index% ? 1 : 0), %settingsFile%, Gear, Item%A_Index%

    Loop, % seedItems.Length()
        IniWrite, % (SeedItem%A_Index% ? 1 : 0), %settingsFile%, Seed, Item%A_Index%

    Loop, % summerItems.Length()
    	IniWrite, % (SummerItem%A_Index% ? 1 : 0), %settingsFile%, Summer, Item%A_Index%

    Loop, % seedCraftingItems.Length()
    	IniWrite, % (SeedCraftingItem%A_Index% ? 1 : 0), %settingsFile%, SeedCrafting, Item%A_Index%

    Loop, % bearCraftingItems.Length()
    	IniWrite, % (BearCraftingItem%A_Index% ? 1 : 0), %settingsFile%, BearCrafting, Item%A_Index%

    IniWrite, %AutoAlign%, %settingsFile%, Main, AutoAlign
    IniWrite, %PingSelected%, %settingsFile%, Main, PingSelected
    IniWrite, %MultiInstanceMode%, %settingsFile%, Main, MultiInstanceMode
    IniWrite, %BuyAllCosmetics%, %settingsFile%, Cosmetic, BuyAllCosmetics
    IniWrite, %SelectAllEggs%, %settingsFile%, Egg, SelectAllEggs
    IniWrite, %SelectAllSummer%, %settingsFile%, Summer, SelectAllSummer
    IniWrite, %AutoHoney%, %settingsFile%, AutoHoney, AutoHoneySetting
    IniWrite, % autoSummerHarvest,     %settingsFile%, Main, SummerHarvest
    IniWrite, % numberOfCycle,         %settingsFile%, Main, NumberOfCycle
    IniWrite, % savedHarvestSpeed,     %settingsFile%, Main, HarvestSpeed

Return

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

#MaxThreadsPerHotkey, 2

F9::
    global debugWebhookMode
    debugWebhookMode := !debugWebhookMode
    tooltipText := "Debug Webhook Mode: " . (debugWebhookMode ? "ON" : "OFF")
    ToolTip, %tooltipText%
    SetTimer, HideTooltip, -1500
    SendDiscordMessage(webhookURL, "Debug Mode Toggled", tooltipText, COLOR_WARNING)
Return

F1::ToggleRecording()
F2::DemoInput()
F3::LoadInputs()

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

F4::
    global started

    if(!started){
        Gosub, alignment
        Gosub, SummerHarvestPath
    }

Return

F13::

    Gosub, alignment
    Sleep, 1000
    uiUniversal(11110)
    Sleep, 100
    uiUniversal(111110)
    Sleep, 100
    Send, {d down}
    Sleep, % ((10 * 1000) + 700) ; Hold for 10.7 sec
    Send, {d up}
    Sleep, 30
    Send, {s down}
    Sleep, 900
    Send, {s up}
    Loop, 4 {
        Send, {WheelDown}
        Sleep, 20
    }
    ; Talk To NPC
    Send, e
    Sleep, 1500

    ; Repositioning Camera View
    Loop, 20 {
    Send, {WheelUp}
    Sleep, 20
    }
    Loop, 6 {
        Send, {WheelDown}
        Sleep, 20
    }
    Sleep, 50000
    SafeClickRelative(0.62, 0.53) ;use F4 to get the exact value of the right place for you
    Sleep, 1000
    uiUniversal(11110)

Return
