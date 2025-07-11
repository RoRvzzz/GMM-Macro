if (A_LineFile = A_ScriptFullPath) {
    MsgBox, 48, Error, Please do not launch this file directly, run the Main file.
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

    Loop, % dinosaurCraftingItems.Length()
    	IniWrite, % (DinosaurCraftingItem%A_Index% ? 1 : 0), %settingsFile%, DinosaurCrafting, Item%A_Index%

    ; — settings —
    IniWrite, %AutoAlign%, %settingsFile%, Main, AutoAlign
    IniWrite, %PingSelected%, %settingsFile%, Main, PingSelected
    IniWrite, %MultiInstanceMode%, %settingsFile%, Main, MultiInstanceMode
    IniWrite, %UINavigationFix%, %settingsFile%, Main, UINavigationFix

    ; — shops —
    IniWrite, %BuyAllCosmetics%, %settingsFile%, Cosmetic, BuyAllCosmetics
    IniWrite, %SelectAllEggs%, %settingsFile%, Egg, SelectAllEggs
    IniWrite, %AutoHoney%, %settingsFile%, AutoHoney, AutoHoneySetting
    IniWrite, %autoSubmit%, %settingsFile%, Main, Prehistoric
Return