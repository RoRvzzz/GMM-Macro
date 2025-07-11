;   GAG MACRO Yark Spade Crafting update +xTazerTx's GIGA UI Rework

#SingleInstance, Force
#NoEnv
SetWorkingDir %A_ScriptDir%
#WinActivateForce
SetMouseDelay, -1 
SetWinDelay, -1
SetControlDelay, -1
SetBatchLines, -1   
global screenHeight := A_ScreenHeight
global screenWidth  := A_ScreenWidth 

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
global autoHoneyActive := 0
global seedCraftingAutoActive := 0
global bearCraftingAutoActive := 0
global dinosaurCraftingAutoActive := 0
global cosmeticAutoActive := 0
global autoSumbitAutoActive := 0
global currentSlotQueue := -1
global endOfSlotQueue := -1
global startingPointOfAutoEgg
global isFirstRun := false
global lastAutoEggCheck := ""

global bearCraftingLocked := 0
global seedCraftingLocked := 0
global dinosaurCraftingLocked := 0


global actionQueue := []
global seedCraftActionQueue := []
global bearCraftActionQueue := []
global dinosaurCraftActionQueue := []

global autoReconnectLocked := 0
global shopFailCount := 0

settingsFile    := A_ScriptDir "\Settings\settings.ini"
mainDir         := A_ScriptDir "\GUI\Images\"
debugFile       := A_ScriptDir "\Settings\debug.txt"


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

    if WinExist("ahk_exe RobloxPlayerBeta.exe") {
        WinGetPos, winX, winY, winW, winH, ahk_exe RobloxPlayerBeta.exe
        moveX := winX + Round(xRatio * winW)
        moveY := winY + Round(yRatio * winH)
        MouseMove, %moveX%, %moveY%
    }

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
    global UINavigationFix

    global indexItem
    global currentArray

    If (!order && mode = "universal") {
        return
    }

    if (!continuous) {
        sendKeybind(SavedKeybind)
        Sleep, 50
        if (UINavigationFix) {
            repeatKey("Up", 5, 50)
            Sleep, 50
            repeatKey("Left", 3, 50)
            Sleep, 50
            repeatKey("up", 5, 50)
            Sleep, 50
            repeatKey("Left", 3, 50)
            Sleep, 50
        }   
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

        FileAppend, % "index: " . index . "`n", %debug%
        FileAppend, % "previusIndex: " . previousIndex . "`n", %debug%
        FileAppend, % "currentarray: " . currentArray.Name . "`n", %debug%

        if (dir = "up") {
            repeatKey(dir)
            repeatKey("Enter")
            repeatKey(dir, sendCount)
        }
        else if (dir = "down") {
            FileAppend, % "sendCount: " . sendCount . "`n", %debug%
            repeatKey(dir, sendCount)
            repeatKey("Enter")
            repeatKey(dir)
            if ((currentArray.Name = "gearItems") && (index != 2) && (UINavigationFix)) {
                repeatKey("Left")
                }
            else if ((currentArray.Name = "seedItems") && (UINavigationFix)) {
                repeatKey("Left")
            }
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
    global UINavigationFix

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
        Sleep, % (SavedSpeed = "Ultra" ? (delay - 25) : SavedSpeed = "Max" ? (delay - 35) : delay)
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

; if u dont understand how this work, ask me (X6 M) and i will explain.
                            ; path for people using 720p lol
adaptiveUniversal(path, path720 := "", exitUi := 1, continuous := 0) {
    global screenHeight
    if (screenHeight = 720 && path720 != "") {
        uiUniversal(path720, exitUi, continuous)
    } else {
        uiUniversal(path, exitUi, continuous)
    }
}


SelectEquipGive() {
    Sleep, 250
    uiUniversal("222444444423333115052444444505")
    Sleep, 150
    Send, {vkC0sc029}
    Sleep, 150
    SendRaw, 1
    Sleep, 100
    Send, {e}
    Sleep, 250
}
                                                                    ; only used for alignment, never set this parameter to 1 if its NOT for alignment
searchItem(search := "nil", exitui := 0, seed := 0, fruit := 0, alignment := 0) {
    global SavedKeybind

    if (search = "nil") {
        Return
    }   
                    ; this one only run if the parameter alignment is set to 1
    if (search = "recall" && alignment) {
        uiUniversal("102222444444423333115052444444122224444444150522223", 1)
        Sleep, 100
        Send, {vkC0sc029}
        Sleep, 200
    }

    uiUniversal("1011143333333333333333333311440", 0)
    Sleep, 50
    typeString(search)
    Sleep, 50

    if (search = "recall") {
        uiUniversal("2224444444233331150524444441505", 1, 1)
    }

    if (search = "uncommon.egg" || search = "anti.bee") {
        uiUniversal("222444444233331150524444441505", 1, 1)
        Sleep, 150
    }   ; put them on the slot 2 of the hotbar, based on the bear crafting recipe selected

    if (seed) {     ; to select the seed filter
        adaptiveUniversal("11112222222244505", "333333222214505", 0, 1)
        Sleep, 150
    }

    if (fruit) {     ; to select the fruit filter
        adaptiveUniversal("111122222222444505", "3333332222144505", 0, 1) 
        Sleep, 150
    }

    uiUniversal(10)

    if (exitui) {
        Send, {%SavedKeybind%}
    }

    Sleep, 150
}

typeString(string, enter := 1, clean := 1) {
    if (string = "") {
        Return
    }

    if (clean) {
        Send {Backspace 25}
        Sleep, 35
    }

    Loop, Parse, string
    {
        char := A_LoopField
        if (char = " ") {
            Send, {Space}
        } else if (char = "{") {
            Send, {{}
        } else if (char = "}") {
            Send, {}}
        } else if (char ~= "[+^#!]") {
            Send, {%char%}
        } else {
            Send, %char%
        }
        Sleep, 35
    }

    if (enter) {
        Send, {Enter}
    }

    Return
}

findIndex(array := "", value := "", returnValue := "int") {
    
    FileAppend, % "Searching " . array.Name . " for " . value . "`n", %debug%

    for index, item in array {
        if (value = item) {
            FileAppend, % "found " . value . " at index " . index "`n", %debug%
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
    else if(shop = "place3") {
        SafeClickRelative(midX + 0.4, midY + 0.2)
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
        Sleep, 150
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

    if (robloxWindows == 0) {
        return false
    }

    Loop, %robloxWindows% {
        windowIDS.Push(robloxWindows%A_Index%)
        idDisplay .= windowIDS[A_Index] . ", "
    }

    firstWindow := windowIDS[1]
    StringTrimRight, idDisplay, idDisplay, 2

    if (returnIndex) {
        Return windowIDS[returnIndex]
    }

    return true
}

closeShop(shop, success) {

    StringUpper, shop, shop, T

    if (success) {

        Sleep, 500
        uiUniversal("4422222250505111111320", 1, 1)

    }
    else {
        Sleep, 500
        shopOpened := false
        ToolTip, % "Error In Detecting " . shop
        SetTimer, HideTooltip, -1500
        SendDiscordMessage(webhookURL, "Shop Detection Failed", "Failed to detect " . shop . " shop opening.", COLOR_ERROR, PingSelected)
        adaptiveUniversal("333222311113332223111105222222505", "3332223325050531111505")

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

    global UINavigationFix
    global selectedEggItems
    global currentItem

    eggsCompleted := 0
    isSelected := 0

    eggColorMap := Object()
    eggColorMap["Common Egg"]    	    := "0xFFFFFF"
    eggColorMap["Uncommon Egg"]  	    := "0x81A7D3"
    eggColorMap["Rare Egg"]      	    := "0xBB5421"
    eggColorMap["Legendary Egg"] 	    := "0x2D78A3"
    eggColorMap["Mythical Egg"]  	    := "0x00CCFF"
    eggColorMap["Bug Egg"]       	    := "0x86FFD5"
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
                    uiUniversal(1105, 1, 1)
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
        SendDiscordMessage(webhookURL, "Egg Detection Error", "Failed to detect any egg.", COLOR_ERROR, PingSelected)
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
            ;PixelGetColor, foundColor, %FoundX%, %FoundY%
            ;MouseMove, %FoundX%, %FoundY%, 10                      ; used for debug, u can ttry it for debug
            ;ToolTip, Color %foundColor% found at %FoundX%, %FoundY%
            ;Sleep, 1200
        return true
    }
}
return false
}

CheckAndCloseBuyOption() {
    Sleep, 80                       ; in the end they are the same lol :skull:
    adaptiveUniversal("3333332221333333222215050523", "3333332221333333222215050523")
    Sleep, 750         ; variation, x1Ratio, y1Ratio, x2Ratio, y2Ratio, colors*
    if (BuyOptionDetect(0, 0.46, 0.55, 0.62, 0.63, 0xFF2D9F, 0xC02278)) { 
        ToolTip, Buy Option Detected...  
        SetTimer, HideTooltip, -1500    
        Sleep, 500                          
        BuyOptionClose()                  
        Sleep, 200                            
    }
}

BuyOptionClose() {
    Sleep, 100
    uiUniversal("3210")
    SendDiscordMessage(webhookURL, "Buy Option Detected.", "Buy Option Has Been Detected And Closed", COLOR_INFO)
    Sleep, 100
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
    pingItems := ["Beanstalk Seed", "Ember Lily", "Sugar Apple", "Burning Bud"
                , "Master Sprinkler", "Bee Egg", "Paradise Egg", "Bug Egg"]

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
                uiUniversal(505, 1, 1)
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

; item arrays

#Include %A_ScriptDir%\Settings\ItemsArrays.ahk

settingsFile := A_ScriptDir "\Settings\settings.ini"

;Gosub, RunDiagnostics

Gosub, ShowGui
Return

; main ui

RunDiagnostics:
    SplashTextOn, 200, 30, GAG MACRO, Running diagnostics...
    Sleep, 500 ; Give it a moment to display

    errorMessages := ""

    ; Check 1: Running from a temporary folder (ZIP check)
    if InStr(A_ScriptDir, A_Temp) {
        errorMessages .= "- Macro is running from a temporary folder. Please extract all files from the archive before running.`n"
    }

    ; Check 2: Roblox Process
    Process, Exist, RobloxPlayerBeta.exe
    if (!ErrorLevel) {
        errorMessages .= "- Roblox process not found. Please open Roblox before using the macro.`n"
    }

    ; Check 3: AHK version compatibility
    if (SubStr(A_AhkVersion, 1, 1) = "2") {
        errorMessages .= "- This script requires AutoHotkey v1.1, but you are running v2. Please install AHK v1.1.`n"
    } else if (A_AhkVersion < "1.1.33") {
        errorMessages .= "- Outdated AHK v1 version (" . A_AhkVersion . ") detected. Please update to the latest v1.1 release.`n"
    }

    ; Check 5: DPI Scaling Check
    if (A_ScreenDPI != 96 && A_ScreenDPI != 120) { ; 100% or 125%
        errorMessages .= "- Uncommon DPI scaling detected (" . A_ScreenDPI . " DPI). Please set display scaling to 100% or 125% in Windows settings.`n"
    }


    ; Check 7: Screen Resolution
    is16x9 := (A_ScreenWidth * 9 = A_ScreenHeight * 16)
    if (!is16x9) {
        errorMessages .= "- Unsupported screen resolution (" . A_ScreenWidth . "x" . A_ScreenHeight . "). A 16:9 aspect ratio is required (e.g., 1920x1080, 2560x1440).`n"
    }
    
    SplashTextOff
    
    ; Keyboard Layout Check from diagnostic tool
    hkl := DllCall("GetKeyboardLayout", "UInt", 0)
    layoutID := hkl & 0xFFFF
    layoutHex := Format("{:04X}", layoutID)
    if (layoutHex != "0409") { ; Not English (United States)
        MsgBox, 64, Keyboard Layout Warning, Current keyboard layout is not English (US) (ID: 0x%layoutHex%). This can sometimes cause unexpected behavior.`n`nIt is recommended to switch to an 'English (United States)' layout.`n`nPress OK to continue.
    }

    if (errorMessages != "") {
        MsgBox, 16, Diagnostic Failed, The following issues were found:`n`n%errorMessages%
        ExitApp
    }


Return

#Include %A_ScriptDir%\GUI\GUI.ahk

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

DisplayServerValidity:

    Gui, Submit, NoHide

    checkValidity(privateServerLink, 1, "privateserver")

Return

ClearSaves:

    MsgBox, 4, Confirm Reset, Are you sure you want to delete all saved settings?
    IfMsgBox, No
        Return

    settingsFile := A_ScriptDir . "\Settings\settings.ini"

    if FileExist(settingsFile) {
        FileDelete, %settingsFile%
        MsgBox, 64, Settings Deleted, settings.ini has been successfully deleted.
        ExitApp
    } else {
        MsgBox, 48, Not Found, settings file not found.
    }

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
    ManualDinosaurCraftLock := ManualDinosaurCraftLock * 60000
    IniWrite, %ManualSeedCraftLock%, %settingsFile%, Main, ManualSeedCraftLock
    IniWrite, %ManualBearCraftLock%, %settingsFile%, Main, ManualBearCraftLock
    IniWrite, %ManualDinosaurCraftLock%, %settingsFile%, Main, ManualDinosaurCraftLock
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
    /*
    else if (A_GuiControl = "SelectAllSummer") {
        Loop, % summerItems.Length()
            GuiControl,, SummerItem%A_Index%, % SelectAllSummer
            Gosub, SaveSettings
    }
*/
return

UpdateSettingColor:

    Gui, Submit, NoHide

    ; color values
    autoColor := "+c" . (AutoAlign ? "90EE90" : "D3D3D3")
    pingColor := "+c" . (PingSelected ? "90EE90" : "D3D3D3")
    multiInstanceColor := "+c" . (MultiInstanceMode ? "90EE90" : "D3D3D3")
    uiNavigationFixColor := "+c" . (UINavigationFix ? "90EE90" : "D3D3D3")

    ; apply colors
    GuiControl, %autoColor%, AutoAlign
    GuiControl, +Redraw, AutoAlign

    GuiControl, %pingColor%, PingSelected
    GuiControl, +Redraw, PingSelected

    GuiControl, %multiInstanceColor%, MultiInstanceMode
    GuiControl, +Redraw, MultiInstanceMode

    GuiControl, %uiNavigationFixColor%, UINavigationFix
    GuiControl, +Redraw, UINavigationFix
    
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
/*
    selectedSummerItems := []

    Loop, % summerItems.Length() {
        if (SummerItem%A_Index%)
            selectedSummerItems.Push(summerItems[A_Index])
    }
*/
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

    selectedDinosaurCraftingItems := []

    Loop, % dinosaurCraftingItems.Length() {
        if (DinosaurCraftingItem%A_Index%)
            selectedDinosaurCraftingItems.Push(DinosaurCraftingItems[A_Index])
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
    global lastSeedCraftMinute := -1
    global lastBearCraftMinute := -1
    global lastDinosaurCraftMinute := -1
    global lastAutoSubmitHour := -1
    global cycleValidated := false

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
                cycleValidated := true 
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

AutoDinosaurCraft:
if (dinosaurCraftingLocked = 1)
	return

    if (cycleCount > 0 && Mod(currentMinute, 5) = 0 && currentMinute != lastDinosaurCraftMinute) {
        lastDinosaurCraftMinute := currentMinute
        dinosaurCraftQueued := true
        SetTimer, PushDinosaurCraft, -8000
    }
Return

PushDinosaurCraft:
    actionQueue.Push("RunAutoDinosaurCraft")
    dinosaurCraftQueued := false
Return

RunAutoDinosaurCraft:
    currentSection := "RunAutoDinosaurCraft"

 if (selectedDinosaurCraftingItems.Length()) {
    if (UseAlts) {
        for index, winID in windowIDs {
            WinActivate, ahk_id %winID%
            WinWaitActive, ahk_id %winID%,, 2
            Gosub, PrehistoricCraftPath
        }
    } else {
        Gosub, PrehistoricCraftPath
    }
}
Return




autoSubmitPetEvent:

    ; Trigger only if it's not the first cycle, it's exactly minute 0, and a new hour
    ; if (cycleCount > 0 && currentMinute = 0 && currentHour != lastAutoSubmitHour) {
    /*
    if (cycleCount > 0 && currentMinute >= 0 && currentMinute <= 10 && currentHour != lastAutoSubmitHour){
        lastAutoSubmitHour := currentHour
        SetTimer, PushautoSubmit, -8000
    }
    */

    if (cycleCount > 0 && Mod(currentMinute, 5) = 0 && currentMinute != lastAutoEggMinute) {
        lastAutoEggMinute := currentMinute
        SetTimer, PushautoSubmit, -8000
    }

Return

PushautoSubmit:

    actionQueue.Push("PetAutoSubmit")

Return

PetAutoSubmit:

    currentSection := "PetAutoSubmit"
    if (autoSubmit) {
        Gosub, PrehistoricAutoSubmit
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

    if (selectedDinosaurCraftingItems.Length()) {
        actionQueue.Push("RunAutoDinosaurCraft")
    }
    dinosaurCraftingAutoActive := 1
    SetTimer, AutoDinosaurCraft, 1000 ; checks every second if it should queue

    if (PrehistoricAutoSubmit) {
        actionQueue.Push("PetAutoSubmit")
    }
    autoSumbitAutoActive := 1
    SetTimer, autoSubmitPetEvent, 1000 ; checks every second if it should queue
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
    global actionQueue, failCount, started, autoReconnectLocked
    global firstWindow, privateServerLink, webhookURL, discordUserID, PingSelected

    if (failCount < 4)
        Return

    if (autoReconnectLocked)
        Return

    if (privateServerLink = "")
        Return

    autoReconnectLocked := 1
    started := 0
    actionQueue := []
    failCount := 0

    SetTimer, AutoReconnect, -600000

    Sleep, 500
    WinClose, % "ahk_id" . firstWindow
    Sleep, 1000
    WinClose, % "ahk_id" . firstWindow
    Sleep, 1000
    WinWaitClose, % "ahk_id" . firstWindow, , 5
    Sleep, 1000


    Run, %privateServerLink%


    ToolTip, Attempting To Reconnect...
    SetTimer, HideTooltip, -5000

    SendDiscordMessage(webhookURL, "Reconnecting...", "Lost connection or macro errored, attempting to reconnect to the server.", COLOR_WARNING, PingSelected)
    sleepAmount(15000, 45000)
    SetTimer, CheckLoadingScreen, 5000
Return

CheckLoadingScreen:

    ToolTip, Detecting Rejoin

    getWindowIDS()

    WinActivate, % "ahk_id" . firstWindow

    sleepAmount(5000, 10000)
    if (simpleDetect(0x000000, 0, 0.8, 0.8, 0.9, 0.9)) {
        SafeClickRelative(midX, midY)
    }
    else {
        ToolTip, Rejoined Successfully
        sleepAmount(15000, 30000)
        SendDiscordMessage(webhookURL, "Reconnected Successfully", "Successfully reconnected to the server and resuming macro.", COLOR_SUCCESS, PingSelected)
        Sleep, 500
        Gosub, StartScanMultiInstance

        autoReconnectLocked := 0  
    }

Return

; set up labels

untoggleUiNav:

    ; make sure the ui nav is not togggled at the start of the macro 
    Sleep, 50
    Loop, 2 {
        SendRaw, %UINavToggle%
        Sleep, 50
    }
    SafeClickRelative(0.5, 0.5)
    Sleep, 50
    uiUniversal("33332223250505")
    Sleep, 150
Return

alignment:

    ToolTip, Screen Resolution: %screenWidth%x%screenHeight%`nBeginning Alignment
    SetTimer, HideTooltip, -5000
        SendDiscordMessage(webhookURL, "[Debug] alignment", "Alignment process started.", COLOR_INFO, false, true)
    Gosub, untoggleUiNav
    Sleep, 100
    SafeClickRelative(0.5, 0.5)
    Sleep, 100

    searchitem("recall", 0, 0, 0, 1)

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
        SafeMoveRelative(0.5, 0.8)
        Sleep, 100
        }
    else {
        Gosub, zoomAlignment
        Sleep, 100
        SafeMoveRelative(0.5, 0.8)
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
    MouseMove, 0, 800, 0, R
    Sleep, 200
    Click, Right, Up
    Sleep, 50
    SafeMoveRelative(0.5, 0.5)
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

    if (UINavigationFix) {
        repeatKey("Left", 5)
        Sleep, 10
        repeatKey("Up", 5)
        Sleep, 10
    }

    repeatKey("Right", 3)
    Loop, % ((SavedSpeed = "Ultra") ? 12 : (SavedSpeed = "Max") ? 30 : 8) {
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

ShopFailSafe() {
    global shopOpened, AutoAlign

    if (!shopOpened) {
        SendDiscordMessage(webhookURL, "Statut Info", "Re-running AutoAlign...", COLOR_INFO)
        closeRobuxPrompt()
        Sleep, 100

        if (AutoAlign) {
            Gosub, untoggleUiNav
            Sleep, 100
            GoSub, cameraChange
            Sleep, 100
            Gosub, zoomAlignment
            Sleep, 100
            Gosub, cameraAlignment
            Sleep, 100
            Gosub, characterAlignment
            Sleep, 100
            Gosub, cameraChange

            SendDiscordMessage(webhookURL, "Statut Info", "AutoAlign ran successfully.", COLOR_INFO)
        } else {
            SendDiscordMessage(webhookURL, "Statut Info", "AutoAlign is disabled, skipping alignment.", COLOR_INFO)
        }

        Sleep, 100
        uiUniversal("1110110202222220")
        Sleep, 100
        return true
    }

    return false
}

ClickFirstFour() {
    baseX := 0.35
    stepX := 0.032
    y := 0.70

    Loop, 4 {
        x := baseX + (stepX * (A_Index - 1))
        SafeClickRelative(x, y)
        Sleep, % FastMode ? 50 : 200
        Send, {e}
        Sleep, % FastMode ? 400 : 200
    }
}

ClickFirstEight() {
    baseX := 0.35
    stepX := 0.035
    y := 0.70

    Loop, 8 {
        x := baseX + (stepX * (A_Index - 1))
        SafeClickRelative(x, y)
        Sleep, % FastMode ? 50 : 200
        Send, {e}
        Sleep, % FastMode ? 400 : 200
    }
}

ClickSeedFilter() {
        SafeClickRelative(0.31, 0.72)
}
ClickFruitFilter() {
        SafeClickRelative(0.31, 0.78)
}
	
UnlockSeedCraft:
    seedCraftingLocked := 0
Return

UnlockBearCraft:
    bearCraftingLocked := 0
Return

UnlockDinosaurCraft:
    dinosaurCraftingLocked := 0
Return


; buying paths
#Include %A_ScriptDir%\Paths\SeedShopPath.ahk
#Include %A_ScriptDir%\Paths\GearShopPath.ahk
#Include %A_ScriptDir%\Paths\EggShopPath.ahk
#Include %A_ScriptDir%\Paths\CosmeticShopPath.ahk
;#Include %A_ScriptDir%\Paths\SkyShopPath.ahk
;#Include %A_ScriptDir%\Paths\GnomeShopPath.ahk         ; i got them already, added next version
;#Include %A_ScriptDir%\Paths\AutoCollectPath.ahk
#Include %A_ScriptDir%\Paths\AutoHoneyPath.ahk
#Include %A_ScriptDir%\Paths\AutoSeedCraftPath.ahk
#Include %A_ScriptDir%\Paths\AutoBearCraftPath.ahk
#Include %A_ScriptDir%\Paths\PrehistoricCraftPath.ahk
#Include %A_ScriptDir%\Paths\PrehistoricAutoSubmit.ahk



#Include %A_ScriptDir%\Settings\Settings.ahk


#Include %A_ScriptDir%\Settings\MacroControl.ahk


#MaxThreadsPerHotkey, 2