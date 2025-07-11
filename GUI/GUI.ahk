ShowGui: 
    Gui, Destroy
    Gui, +LastFound -MinimizeBox -Caption 
    Gui, Color, 0x101010
    WinSet, TransColor, 0x101010
    Gui, Add, Picture, x5 y5 w800 h600 BackgroundTrans, % mainDir "rbx window background .PNG"
    Gui, Add, Picture, x0 y0 w810 h610 BackgroundTrans, % mainDir "background+tab.png" 

    Gui, Add, Text, x748 y10 w54 h15 BackgroundTrans gCloseApp
    Gui, Add, Text, x10 y10 w54 h15 BackgroundTrans gMinimizeApp
    Gui, Add, Text, x70 y10 w669 h15 BackgroundTrans gDragWindow

    Gui, Font, s16 bold cBCC4C7 , Segoe UI
    Gui, Add, Tab ,  x30 y57 w810 h300 vMyTab,`n  Seeds     |GearsEggs   |Cosmetics   |Summer     |Settings       |Credits  `n|
    guicontrol, choose, mytab, 5

    Gui, Tab, 1
    
    Gui, Add, Picture, x0 y0 w810 h610 BackgroundTrans, % mainDir "backgroundseed.png"
    Gui, Font, s12 bold cBCC4C7 , Segoe UI
    Gui, Add, Text, x40 y120 center BackgroundTrans c7CFC7B, Seed Shop Items
    Gui, Font, s8 bold cBCC4C7 , Segoe UI
    IniRead, SelectAllSeeds, %settingsFile%, Seed, SelectAllSeeds, 0
    Gui, Add, CheckBox, % "x661 y192 w13 h13  vSelectAllSeeds gHandleSelectAll -Theme Background3C3C3C " . (SelectAllSeeds ? "Checked" : "")
    Gui, Add, Text, x+5 BackgroundTrans, Select All Seeds
Loop, % seedItems.Length() {
        IniRead, sVal, %settingsFile%, Seed, Item%A_Index%, 0
        if (A_Index <= 8) {
            col := 60
            idx := A_Index
        }
        else if (A_Index <= 16) {
            col := 310
            idx := A_Index - 8
        }
        else {
            col := 560
            idx := A_Index - 16
        }
        yBase := 195
        y := yBase + (idx * 40)
    
        Gui, Add, Checkbox, % "x" col " y" y " w13 h13 vSeedItem" A_Index " gHandleSelectAll cD3D3D3 " . (sVal ? "Checked" : ""),
        Gui, Add, Text, x+5 BackgroundTrans cC6CED1 , % seedItems[A_Index]

    }

    Gui, Tab, 2
    Gui, Add, Picture, x0 y0 w810 h610 BackgroundTrans, % mainDir "backgroundgear+egg.png"
    Gui, Font, s12 bold c00B8D , Segoe UI
    Gui, Add, Text, x40 y120 center BackgroundTrans c27c3f7, Gear
    Gui, Add, Text, x+5 center BackgroundTrans cWhite, and
    Gui, Add, Text, x+5 center BackgroundTrans ce1b18f, egg
    Gui, Font, s8 bold cBCC4C7 , Segoe UI
    IniRead, SelectAllGears, %settingsFile%, Gear, SelectAllGears, 0
    Gui, Add, Checkbox, % "x412 y192 w13 h13 vSelectAllGears gHandleSelectAll c87CEEB " . (SelectAllGears ? "Checked" : "") 
    Gui, Add, Text, x+5 BackgroundTrans cC6CED1 , Select All Gears

    Loop, % gearItems.Length() {
        IniRead, gVal, %settingsFile%, Gear, Item%A_Index%, 0
        if (A_Index <= 7) {
            col := 60
            idx := A_Index
            yBase := 195
        } else {
            col := 310
            idx := A_Index - 8
            yBase := 240
        }
        y := yBase + (idx * 45)
        Gui, Add, Checkbox, % "x" col " y" y " w13 h13 vGearItem" A_Index " gHandleSelectAll cD3D3D3 " . (gVal ? "Checked" : ""), % gearItems[A_Index]
        Gui, Add, Text, x+5 BackgroundTrans cD3D3D3 , % gearItems[A_Index]
    }


    IniRead, SelectAllEggs, %settingsFile%, Egg, SelectAllEggs, 0
    Gui, Add, CheckBox, % "x661 y192 w13 h13 vSelectAllEggs gHandleSelectAll -Theme BackgroundTrans ce87b07 " . (SelectAllEggs ? "Checked" : "")
    Gui, Add, Text, x+5 BackgroundTrans ce87b07 , Select All Eggs
    Loop, % eggItems.Length() {
        IniRead, eVal, %settingsFile%, Egg, Item%A_Index%, 0
        if (A_Index <= 200) {
            col := 560
            idx := A_Index
            yBase := 195
        } else {
            col := 310
            idx := A_Index - 201
            yBase := 240
        }
        y := yBase + (idx * 45)
        Gui, Add, Checkbox, % "x" col " y" y " w13 h13 vEggItem" A_Index " gHandleSelectAll cD3D3D3 " . (eVal ? "Checked" : ""), % eggItems[A_Index]
        Gui, Add, Text, x+5 BackgroundTrans cC6CED1 , % eggItems[A_Index]

    }

    Gui, Tab, 3
    Gui, Add, Picture, x0 y0 w810 h610 BackgroundTrans, % mainDir "backgroundgearcosmetic+crafting.png"
    Gui, Font, s10 bold c00B8D , Segoe UI
    Gui, Add, Text, x30 y125 center BackgroundTrans ca35100, Crafting 
    Gui, Add, Text, x+5 center BackgroundTrans c27c3f7, Gear
    Gui, Add, Text, x+5 center BackgroundTrans cwhite, and
    Gui, Add, Text, x+5 center BackgroundTrans c7CFC7B, Seed
    Gui, Font, s8 bold cBCC4C7 , Segoe UI
    IniRead, BuyAllCosmetics, %settingsFile%, Cosmetic, BuyAllCosmetics, 0
    Gui, Add, CheckBox, % "x636 y128 w13 h13 vBuyAllCosmetics gHandleSelectAll -Theme BackgroundTrans cD41551 " . (BuyAllCosmetics ? "Checked" : "")
    Gui, Add, Text, x+5 BackgroundTrans cD41551 , Buy All Cosmetic Items
    IniRead, AutoHoneySetting, %settingsFile%, AutoHoney, AutoHoneySetting, 0
    Gui, Add, CheckBox, % "x622 y550 w13 h13 vAutoHoney gSaveAutoHoney BackgroundTrans c00FF00 " . (AutoHoneySetting ? "Checked" : "")
    Gui, Add, Text, x+5 BackgroundTrans c00FF00 , Auto submit Pollinated
    ; ----- BearCrafting Set -----
    Loop, % bearCraftingItems.Length() {
        IniRead, bVal, %settingsFile%, BearCrafting, Item%A_Index%, 0
        if (A_Index <= 7) {
            col := 60
            idx := A_Index
            yBase := 195
        } else {
            col := 310
            idx := A_Index - 8
            yBase := 240
        }
        y := yBase + (idx * 45)
        Gui, Add, Checkbox, % "x" col " y" y " w13 h13 vBearCraftingItem" A_Index " gHandleSelectAll cWhite BackgroundTrans " . (bVal ? "Checked" : ""), % bearCraftingItems[A_Index]
        Gui, Add, Text, x+5 BackgroundTrans cC6CED1 , % bearCraftingItems[A_Index]
    }
    ; === Bear Craft Lock ===
    IniRead, ManualBearCraftLock, %settingsFile%, Main, ManualBearCraftLock, 0
    Gui, Add, Edit, x50 y189 w36 h18 vManualBearCraftLock gUpdateCraftLock -Theme cBlack, %ManualBearCraftLock%
    Gui, Add, Text, x+5 y+-16 BackgroundTrans c00FF00 ,Gear Timer

    ; ----- SeedCrafting Set -----
    Loop, % seedCraftingItems.Length() {
        IniRead, sVal, %settingsFile%, SeedCrafting, Item%A_Index%, 0
        if (A_Index <= 7) {
            col := 560
            idx := A_Index
            yBase := 195
        }
        else {
            col := 560
            idx := A_Index - 8
            yBase := 240
        }
        y := yBase + (idx * 45)
        Gui, Add, Checkbox, % "x" col " y" y " w13 h13 vSeedCraftingItem" A_Index " gHandleSelectAll cWhite BackgroundTrans " . (sVal ? "Checked" : ""), % seedCraftingItems[A_Index]
        Gui, Add, Text, x+5 BackgroundTrans cC6CED1 , % seedCraftingItems[A_Index]
    }

    ; === Seed Craft Lock ===
    IniRead, ManualSeedCraftLock, %settingsFile%, Main, ManualSeedCraftLock, 0
    Gui, Add, Edit, x661 y189 w36 h18 vManualSeedCraftLock gUpdateCraftLock -Theme cBlack, %ManualSeedCraftLock%
    Gui, Add, Text, x+5 y+-16 BackgroundTrans c00FF00 ,Seed Timer


    Gui, Tab, 4
    Gui, Add, Picture, x0 y0 w810 h610 BackgroundTrans, % mainDir "backgroundevent.png"

    Gui, Font, s11 bold c00B8D , Segoe UI
    Gui, Add, Text, x45 y120 center BackgroundTrans c87CEEB, Dinosaur Crafting
    ;Gui, Add, Text, x+5 center BackgroundTrans cWhite, and
    ;Gui, Add, Text, x+5 center BackgroundTrans cFF7518, Harvest
    Gui, Font, s9 cWhite Bold, Segoe UI
    ; ----- DinosaurCrafting Set -----
    Loop, % dinosaurCraftingItems.Length() {
        IniRead, sVal, %settingsFile%, DinosaurCrafting, Item%A_Index%, 0
        col := 60
        yBase := 110 + ((A_Index - 1) * 45)
        y := yBase + (idx * 45)
        Gui, Add, Checkbox, % "x" col " y" y " w13 h13 vDinosaurCraftingItem" A_Index " gHandleSelectAll cWhite BackgroundTrans " . (sVal ? "Checked" : ""), % dinosaurCraftingItems[A_Index]
        Gui, Add, Text, x+5 BackgroundTrans cC6CED1 , % dinosaurCraftingItems[A_Index]
    }

    ; === Dinosaur Craft Lock ===
    IniRead, ManualDinosaurCraftLock, %settingsFile%, Main, ManualDinosaurCraftLock, 0
    Gui, Add, Edit, x50 y189 w20 h18 vManualDinosaurCraftLock gUpdateCraftLock -Theme cBlack, %ManualDinosaurCraftLock%
    Gui, Add, Text, x+5 y+-16 BackgroundTrans c00FF00 ,Dinosaur Timer

    Gui, Font, s9 Bold cWhite , Segoe UI
    IniRead, autoSubmit, %settingsFile%, Main, Prehistoric, 0
    Gui, Add, CheckBox, % "x665 y192 w13 h13 vautoSubmit cfad15f -Theme BackgroundTrans cD41551 " . (autoSubmit ? "Checked" : "")
    Gui, Add, Text, x+5 BackgroundTrans ce87b07 , Auto-Submit 
    Gui, Add, Text, x560 y240 BackgroundTrans ce87b07 , How to use Auto Submit : 
    Gui, Add, Text, x560 y280 BackgroundTrans cFFFFFF , Step 1: Find yourself a pet 
    Gui, Add, Text, x560 y300 BackgroundTrans cFFFFFF , that you want to submit.
    Gui, Add, Text, x560 y340 BackgroundTrans cFFFFFF , Step 2: Put the pets you selected
    Gui, Add, Text, x560 y360 BackgroundTrans cFFFFFF , in slot number 6 to 0. 
    Gui, Add, Text, x560 y400 BackgroundTrans cFFFFFF , Step 3: Where is the slot?
    Gui, Add, Text, x560 y420 BackgroundTrans cFFFFFF , It's the hotbar 
    Gui, Add, Text, x560 y460 BackgroundTrans cFFFFFF , Step 4: Do Not Leave it Empty
    Gui, Add, Text, x560 y480 BackgroundTrans cFFFFFF , or Else it will submit nothing.

    Gui, Add, Text, x340 y520 BackgroundTrans cFFFFFF , Auto-Submit made by
    Gui, Add, Text, x370 y540 BackgroundTrans cFFFFFF , Nasa Yuzaki
 
    Gui, Tab, 5

    Gui, Add, Picture, x0 y0 w810 h610 BackgroundTrans, % mainDir "backgroundsettings.png"
    ; Invisible hotspots (replacing buttons)
  
    

    Gui, Add, Text, x371 y198 w69  h20 BackgroundTrans  gClearSaves  center    cC6CED1,Clear Saves
    Gui, Font, s16 bold cWhite, Segoe UI
    Gui, Add, Text, x350 y550 w110  h35 BackgroundTrans gGui2 center cYellow 0X4,help

    Gui, Add, Text, x20  y508 w230 h80 BackgroundTrans gStartScanMultiInstance  center cLime,
    Gui, Add, Text, x20  y518 w230 h80 BackgroundTrans   center cLime,f5
    Gui, Add, Text, x20  y545 w230 h80 BackgroundTrans center cC6CED1,Start macro
    Gui, Add, Text, x560 y508 w230 h80 BackgroundTrans gQuit center cRed,
    Gui, Add, Text, x560 y518 w230 h80 BackgroundTrans  center cRed,f7
    Gui, Add, Text, x560  y545 w230 h80 BackgroundTrans center cC6CED1,Stop macro
    
    Gui, Add, Text, X569 y252 W209  h55 BackgroundTrans gGui4 center cC6CED1 0X4,
    Gui, Add, Text, X569 y266 W209  h55 BackgroundTrans  center cC6CED1 0X4,Eggs

    Gui, Add, Text, X569 y310 W209  h55 BackgroundTrans gGui5  center  cC6CED1 0X4,
    Gui, Add, Text, X569 y325 W209  h55 BackgroundTrans   center  cC6CED1 0X4,Pets
    Gui, Font, s8 bold cWhite, Segoe UI

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

    Gui, Font, s8 cBlack, Segoe UI
    IniRead, SavedSpeed, %settingsFile%, Main, MacroSpeed, Stable
    Gui, Add, Text, x40 y228  BackgroundTrans cC6CED1 , Macro Speed :
    Gui, Add, DropDownList, vSavedSpeed gUpdateSpeed x+5 y+-18 w50 , Stable|Fast|Ultra|Max
    GuiControl, ChooseString, SavedSpeed, %SavedSpeed%

        IniRead, SavedKeybind, %settingsFile%, Main, UINavigationKeybind, \
    if (SavedKeybind = "") {
        SavedKeybind := "\"
    }
    Gui, Add, Text, x40 y262 BackgroundTrans cC6CED1 , UI Navigation Key :
    Gui, Add, Edit, x+5 y+-15 w20 h16 vSavedKeybind gUpdateKeybind -Theme +E0x200 +E0x800 cBlack Background2E2E2E, %savedKeybind%
    
        IniRead, PingSelected, %settingsFile%, Main, PingSelected, 0
    pingColor := PingSelected ? "c90EE90" : "cD3D3D3"
    Gui, Add, Text, x40 y296 BackgroundTrans cC6CED1 , Discord Item Pings :
    Gui, Add, Checkbox, % "x+5 w13 h13 vPingSelected gUpdateSettingColor " . pingColor . (PingSelected ? " Checked" : "")
    
    
    IniRead, AutoAlign, %settingsFile%, Main, AutoAlign, 0
    autoColor := AutoAlign ? "c90EE90" : "cD3D3D3"
    Gui, Add, Text, x40 y328 BackgroundTrans cC6CED1 , Auto-Align :
    Gui, Add, Checkbox, % "x+5 w13 h13 vAutoAlign gUpdateSettingColor " . autoColor . (AutoAlign ? " Checked" : "")
    

    IniRead, MultiInstanceMode, %settingsFile%, Main, MultiInstanceMode, 0
    multiInstanceColor := MultiInstanceMode ? "c90EE90" : "cD3D3D3"
    Gui, Add, Text, x40 y362 BackgroundTrans cC6CED1 , Multi-Instance Mode :
    Gui, Add, Checkbox, % "x+5 w13 h13 vMultiInstanceMode gUpdateSettingColor " . multiInstanceColor . (MultiInstanceMode ? " Checked" : "")
    

    IniRead, UINavigationFix, %settingsFile%, Main, UINavigationFix, 0
    uiNavigationFixColor := UINavigationFix ? "c90EE90" : "cD3D3D3"
    Gui, Add, Text, x40 y394 BackgroundTrans cC6CED1 , UI Navigation Fix :
    Gui, Add, Checkbox, % "x+5 w13 h13 vUINavigationFix gUpdateSettingColor " . uiNavigationFixColor . (UINavigationFix ? " Checked" : "")
    
    Gui, Font, s8 cBlack, Segoe UI
    IniRead, savedWebhook, %settingsFile%, Main, UserWebhook
    if (savedWebhook = "ERROR") {
        savedWebhook := ""
    }
    Gui, Add, Text, x40 y125  BackgroundTrans cC6CED1 ,Webhook URL :
    Gui, Add, Edit, x+5 y+-15 w530 h15 vwebhookURL hwndhWebhookURL +E0x200 +E0x800 -Theme cBlack, %savedWebhook%
    Gui, Add, Text, x+5  w105 h16 BackgroundTrans gDisplayWebhookValidity center  cC6CED1 ,Save Webhook

    ;WinSet, Transparent, 1, ahk_id %hWebhookURL%


    IniRead, savedUserID, %settingsFile%, Main, DiscordUserID
    if (savedUserID = "ERROR") {
        savedUserID := ""
    }
    Gui, Add, Text, x40 y147  BackgroundTrans cC6CED1 ,Discord User ID :
    Gui, Add, Edit, x+5 y+-15 w533 h15 vdiscordUserID +E0x200 +E0x800 -Theme cBlack Background2C2F33, %savedUserID%
    Gui, Add, Text, x+5 w105 h16 BackgroundTrans gUpdateUserID center  cC6CED1 ,      Save Discord ID
    


    IniRead, savedServerLink, %settingsFile%, Main, PrivateServerLink
    if (savedServerLink = "ERROR") {
        savedServerLink := ""
    }
    Gui, Add, Text, x40 y169  BackgroundTrans cC6CED1 ,Private Server :
    Gui, Add, Edit, x+5 y+-15 w541 h15 vprivateServerLink -Theme cBlack BackgroundFFFFFF, %savedServerLink%
    Gui, Add, Text, x+5 w105 h16 BackgroundTrans gDisplayServerValidity center cC6CED1 ,Save Private Server

    Gui, Tab, 6
    
    Gui, Add, Picture, x0 y0 w810 h610 BackgroundTrans, % mainDir "backgroundcredit.png"
    Gui, Font, s15 c5865F2  bold 
    Gui, Add, Text, x169 y140 center BackgroundTrans cYellow, -Credits-

    Gui, Font, s12 cC6CED1  bold ,
    Gui, Add, Text, x60 y+10  BackgroundTrans cC6CED1,
    (
-Real- (@real_07) all the original code.

-xTazerTx- (@xTazerTx) ui

-Yark Spade- (@showerdadsupreme) code

-X6 M- (@lun4r1st) code

-Moris- (@3moris3) code

-adnreal_07- (@adnrealan) code

-Hecate- (@hecate7716) code

-Nasa Yuzaki- (@nasayuzaki) code

-Rick Bro- (@rickyhoang25) code
    )
        Gui, Add, Text, x430 y175  BackgroundTrans cC6CED1,
    (
-RoRvzzz- (@RoRvzzz) discord and github
    )
    
    Gui, Font, s10 c5865F2  underline
    Gui, Add, Text, x500 y500 BackgroundTrans gOpenLink, GAG MODED MACROS DISCORD `njoin for update and bugreport

    Gui, Font, norm

    Gui, Show, w810 h610, GAG MACRO Yark Spade Crafting update +xTazerTx's GIGA UI Rework
    
Return

OpenLink:
    Run, https://discord.gg/gagmacros 
return

    MinimizeApp:
    Gui, Minimize
    return

    CloseApp:
        StopMacro(1)
    return

    DragWindow:
        PostMessage, 0xA1, 2  ; WM_NCLBUTTONDOWN, HTCAPTION
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