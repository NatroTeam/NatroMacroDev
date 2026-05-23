/**
 * Returns only item names that *should* be in the inventory
 * @param {Array} words Array of words from an OCRResult.Words
 * @returns {Array} The filtered Array of words
*/
filterHeight(height) {
	func(words) {
    	filteredWords := Array()
    	for idx, word in words {
    	    itemRect := word.BoundingRect
    	    if itemRect.H > height {
				fakeWord := Map()
				fakeWord.Text := StrReplace(word.Text, "-")
				fakeWord.BoundingRect := itemRect
				filteredWords.Push(fakeWord)
    	    }
    	}
		return filteredWords
	}
    return (words) => func(words)
}

itemArray := ["Cog", "Ticket", "SprinklerBuilder", "BeequipCase", "Gumdrops", "Coconut", "Stinger", "Snowflake", "MicroConverter", "Honeysuckle", "Whirligig", "FieldDice", "SmoothDice", "LoadedDice", "JellyBeans", "RedExtract", "BlueExtract", "Glitter", "Glue", "Oil", "Enzymes", "TropicalDrink", "PurplePotion", "SuperSmoothie", "MarshmallowBee", "Sprout", "MagicBean", "FestiveBean", "CloudVial", "BloomShaker", "NightBell", "BoxOFrogs", "AntPass", "BrokenDrive", "7ProngedCog", "RoboPass", "Translator", "SpiritPetal", "Present", "Treat", "StarTreat", "AtomicTreat", "SunflowerSeed", "Strawberry", "Pineapple", "Blueberry", "Bitterberry", "Neonberry", "MoonCharm", "GingerbreadBear", "AgedGingerbreadBear", "WhiteDrive", "RedDrive", "BlueDrive", "GlitchedDrive", "ComfortingVial", "InvigoratingVial", "MotivatingVial", "RefreshingVial", "SatisfyingVial", "NectarShowerVial", "PinkBalloon", "RedBalloon", "WhiteBalloon", "BlackBalloon", "SoftWax", "HardWax", "CausticWax", "SwirledWax", "Turpentine", "PaperPlanter", "TicketPlanter", "StickerPlanter", "FestivePlanter", "PlasticPlanter", "CandyPlanter", "RedClayPlanter", "BlueClayPlanter", "TackyPlanter", "PesticidePlanter", "HeatTreatedPlanter", "HydroponicPlanter", "PetalPlanter", "PlanterOfPlenty", "BasicEgg", "SilverEgg", "GoldEgg", "DiamondEgg", "MythicEgg", "StarEgg", "GiftedSilverEgg", "GiftedGoldEgg", "GiftedDiamondEgg", "GiftedMythicEgg", "RoyalJelly", "StarJelly", "BumbleBeeEgg", "GiftedExhaustedBeeEgg", "GiftedFrostyBeeEgg", "GiftedDiamondBeeEgg", "BumbleBeeJelly", "RageBeeJelly", "ShockedBeeJelly", "BearBeeJelly", "CobaltBeeJelly", "CrimsonBeeJelly", "FestiveBeeJelly", "GummyBeeJelly", "PhotonBeeJelly", "PuppyBeeJelly", "TabbyBeeJelly", "ViciousBeeJelly"]
(items := Map()).CaseSense := 0
for idx, item in itemArray {
	items[item] := [idx, item]
	items[idx] := [idx, item]
}

/**
 * Looks for the given item in the invetory
 * @param {String | Integer} item The item you're searching for
 * @param {String} direction direction you want it to search IF the item is unknown
 * @param {Integer} max max amount of attempts
 * @returns {Rect | Boolean} X,Y,W,H Map or false if it failed to find the item.
*/
nm_InventorySearch(item, direction:="down", maxIter:=70) {
	static lastItemIdx := 0
	nm_OpenMenu("itemmenu")
	
	itemIdx := 0
	itemName := item
	if items.Has(item) {
		itemIdx := items[item][1]
		itemName := items[item][2]
	}
	
	; Activate roblox window and get it's current position and height
	if !(hwnd := GetRobloxHWND())
		return false ; No roblox, return nothing.
	
	ActivateRoblox()
	GetRobloxClientPos(hwnd)
	offsetY := GetYOffset(hwnd)
	
	; Scroll to the end of inventory IF item isn't known
	if !itemIdx {
		scrollDir := direction = "down" ? "Up" : "Down" 
		lastItemIdx := 0
		Loop 10 {
			SendEvent "{Click " windowX+30 " " windowY+offsetY+200 " 0}"
			SendInput "{Wheel" scrollDir " 100}"
			Sleep 50
		}
	}
	
	itemRect := false
	firstItem := ""
	doubleCheck := false
	clearViewCheck := false
	remainingItems := []
	scrollDir := direction = "down" ? "Down" : "Up"
	Loop maxIter { ; Start searching
		ActivateRoblox()
		GetRobloxClientPos(hwnd)
		scrollIntensity := 3
		
		searchResult := findTextInRect(itemName, windowX+100, windowY+150, 250, windowHeight-250,, filterHeight(11))
		words := searchResult["Words"]
		if searchResult.Has("Word") {
			itemRect := searchResult["Word"].BoundingRect
			if Abs(words[words.Length].BoundingRect.Y - itemRect.Y) <= itemRect.H {
				SendInput "{WheelDown 3}"
				Sleep 550
				remainingItems := []
				if !clearViewCheck { ; Check if at the end of the inventory, if so item is fully visible, ignore continue.
					clearViewCheck := true
					continue
				}
			}
			break ; Item found and is fully visible, break the loop
		}
		
		if itemIdx and remainingItems.Length = 0 {
			remainingItems := itemArray.Clone()
			remainingItems.RemoveAt(itemIdx)
			
			if lastItemIdx { ; Start from last searched item.
				if lastItemIdx > itemIdx {
					remainingItems.Length := itemIdx - 1
				} else {
					remainingItems.RemoveAt(1, lastItemIdx-1)
				}
			}
		}
		
		if itemIdx {
			(wrapped := Map("Words", words)).Words := words
			found := false
			for i, item in remainingItems {
				if findTextInRect(item, wrapped).Has("Word") {
					idx := items[item][1]
					scrollDir := idx > itemIdx ? "Up" : "Down"
					scrollIntensity := Max(Abs(itemIdx - idx) // 10, 3)
					found := true
					if idx > itemIdx {
						remainingItems.Length := i - 1
					} else {
						remainingItems.RemoveAt(1, i)
					}
					break
				}
			}
			if !found {
				remainingItems := []
			}
		}
		
		SendEvent "{Click " windowX+30 " " windowY+offsetY+200 " 0}"
		SendInput "{Wheel" scrollDir " " scrollIntensity "}"
		Sleep 550 ; wait for scroll to finish
		if 10 > A_Index {
			continue
		}
		
		firstWord := searchResult["Words"][1]
		
		if firstWord.Text = firstItem and firstItem {
			if !doubleCheck {
				doubleCheck := true
				continue
			} else if !itemIdx {
				break ; at the end of inventory
			}
			; Somehow got lost in the inventory, change directions & reset known items.
			scrollDir := scrollDir = 'Down' ? 'Up' : 'Down'
			remainingItems := []
			continue
		}
		
		firstItem := firstWord.Text
		doubleCheck := false
	}
	
	if itemIdx {
		lastItemIdx := itemIdx
	}
	
	return itemRect ; Return rect of item for dragging
}
