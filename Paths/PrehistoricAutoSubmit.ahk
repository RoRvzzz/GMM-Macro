PrehistoricAutoSubmit:

    global started
    global startingPointOfAutoEgg
    global currentSlotQueue
    global isFirstRun
    global lastAutoEggCheck

/*
    isPastHour := A_Now
    EnvSub, isPastHour, %startingPointOfAutoEgg%, Seconds
    if(!isFirstRun){
        ;do nothing
        isFirstRun := true
    }else{
        if(isPastHour <= 3200){
            return
        }
    }
*/
    elapsedHour := 1
    elapsedMinute := elapsedHour * 60
    elapsedSeconds := elapsedMinute * 60
    checkTime := A_Now
    if (startingPointOfAutoEgg != "" && lastAutoEggCheck != startingPointOfAutoEgg) {
        lastAutoEggCheck := checkTime
        EnvSub, checkTime, %startingPointOfAutoEgg%, Seconds
        elapsedTime := checkTime
        if (elapsedTime < elapsedSeconds) {
            return ; skip the proccess
        }
    }
    elapsedTimeCalculate := lastAutoEggCheck
    EnvSub, elapsedTimeCalculate, %startingPointOfAutoEgg%, Seconds
    SendDiscordMessage(webhookURL, "**[PREHISTORIC CYCLE]**")


    WinActivate, ahk_exe RobloxPlayerBeta.exe
    SendDiscordMessage(webhookURL, "Pet Auto Submit Cycle", "Starting pet auto submit cycle.", COLOR_INFO)
    Sleep, 100
    ;Path to Egg Proccess Location
    uiUniversal(1110)
    Sleep, 200
    Send, {d down}
    Sleep, % ((9 * 1000) + 860) ; Hold for 9.86 sec
    Send, {d up}
    Sleep, 30
    Send, {Up down}
    Sleep, % ((0 * 1000) + 700) ; Place For Egg Claim 0.7 Sec
    Send, {Up up}
    Sleep, 500
    Send, e ; Claim
    Sleep, 500
    Send, {Down down}
    Sleep, % ((0 * 1000) + 400) ; Place For Egg Process 0.4 Sec
    Send, {Down up}
    Sleep, 500
    Send, {a down}
    Sleep, % ((0 * 1000) + 100) ; Place For Egg Process 0.1 Sec
    Send, {a up}
    Sleep, 500

    ; Add Pet to Submit Logic Here
    if(currentSlotQueue < 0){
        currentSlotQueue := 6 ; starting position for submit
    }else if(currentSlotQueue > 9){
        currentSlotQueue := 0 ; failsafe for 0 as end point 
    }else if(currentSlotQueue = 0){
        SendDiscordMessage(webhookURL, "Pet Auto Submit", "All Pets in the Queue is already been submitted\nSkipping Auto-Collect & Submit for Prehistoric", COLOR_INFO)
        return
    }
    Sleep, 30

    ; Submitting Pets Logic
    currentSlotQueueString := "" . currentSlotQueue
    hotbarController(1, 0, currentSlotQueueString)
    Sleep, 300
    currentSlotQueueString := ""

    ; Talk To NPC
    Send, e
    Sleep, 1500
    dialogueClick("place3")
    SendDiscordMessage(webhookURL, "Pet Auto Submit", "Submitted Pet in Slot **#" . currentSlotQueue . "**", COLOR_INFO)
    Sleep, 500
    hotbarController(0, 1, "1") ; resets selected hotbar
    Sleep, 1000
    uiUniversal(11110)
    Gosub, zoomAlignment
    SendDiscordMessage(webhookURL, "Pet Auto Submit", "Pet auto submit is now completed.", COLOR_INFO)
    startingPointOfAutoEgg := A_now
    currentSlotQueue++

Return