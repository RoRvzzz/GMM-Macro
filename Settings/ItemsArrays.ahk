if (A_LineFile = A_ScriptFullPath) {
    MsgBox, 48, Error, Please do not launch this file directly, run the Main file.
}   

seedItems := ["Carrot Seed", "Strawberry Seed", "Blueberry Seed", "Orange Tulip"
            , "Tomato Seed", "Daffoldil Seed", "Watermelon Seed", "Pumpkin Seed"
             , "Apple Seed", "Bamboo Seed", "Coconut Seed", "Cactus Seed"
             , "Dragon Fruit Seed", "Mango Seed", "Grape Seed", "Mushroom Seed"
             , "Pepper Seed", "Cacao Seed", "Beanstalk Seed", "Ember Lily"
             , "Sugar Apple", "Burning Bud"]
/*
seedItems := ["Carrot Seed", "Strawberry Seed", "Blueberry Seed"
             , "Tomato Seed", "Cauliflower Seed", "Watermelon Seed", "Rafflesia Seed"
             , "Green Apple Seed", "Avacado Seed", "Banana Seed", "Pineapple Seed"      ; ======================================
             , "Kiwi Seed", "Bell Pepper Seed", "Prickly Pear Seed", "Loquat Seed"      ; the one used during summer update
             , "Feijoa Seed", "Pitcher Plant Seed", "Sugar Apple Seed"]                 ; ======================================
*/
gearItems := ["Watering Can", "Trowel", "Recall Wrench", "Basic Sprinkler"
            , "Advanced Sprinkler", "Godly Sprinkler", "Magnifying Glass"
            , "Tanning Mirror", "Master Sprinkler", "Cleaning Spray"
            , "Favorite Tool", "Harvest Tool", "Friendship Pot"]

eggItems := ["Common Egg", "Rare Summer Egg", "Bee Egg", "Common Summer Egg"
           , "Paradise Egg", "Mythical Egg", "Bug Egg"]

cosmeticItems := ["Cosmetic 1", "Cosmetic 2", "Cosmetic 3", "Cosmetic 4", "Cosmetic 5"
                , "Cosmetic 6",  "Cosmetic 7", "Cosmetic 8", "Cosmetic 9"]

summerItems := ["Summer Seed Pack", "Delphinium Seed", "Lily of the Valley Seed"
              , "Travelers Fruit Seed", "Muatation Spray Burnt", "Oasis Crate"
              , "Oasis Egg", "Hamster"]

bearCraftingItems := ["Lightning Rod", "Reclaimer", "Tropical Mist Sprinkler"
                    , "Berry Blusher Sprinkler", "Spice Spritzer Sprinkler"
                    , "Sweet Soaker Sprinkler", "Flower Froster Sprinkler"
                    , "Stalk Sprout Sprinkler", "Mutation Spray Choc"
                    , "Mutation Spray Chilled", "Mutation Spray Shocked"
	                , "Anti Bee Egg", "Pack Bee"]

seedCraftingItems := ["Peace Lily Seed", "Aloe Vera Seed", "Guanabana Seed"]

dinosaurCraftingItems := ["Mutation Spray Amber", "Ancient Seed Pack", "Dino Crate"]