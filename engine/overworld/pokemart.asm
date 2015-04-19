DisplayPokemartDialogue_: ; 6c20 (1:6c20)
	ld a,[wListScrollOffset]
	ld [wd07e],a
	call UpdateSprites ; move sprites
	xor a
	ld [wcf0a],a ; flag that is set if something is sold or bought
.loop
	xor a
	ld [wListScrollOffset],a
	ld [wCurrentMenuItem],a
	ld [wPlayerMonNumber],a
	inc a
	ld [wcf93],a
	ld a,MONEY_BOX
	ld [wTextBoxID],a
	call DisplayTextBoxID ; draw money text box
	ld a,BUY_SELL_QUIT_MENU
	ld [wTextBoxID],a
	call DisplayTextBoxID ; do buy/sell/quit menu
	ld hl,wd128 ; pointer to this pokemart's inventory
	ld a,[hli]
	ld l,[hl]
	ld h,a ; hl = address of inventory
	ld a,[wd12e]
	cp a,$02
	jp z,.done
	ld a,[wd12d] ; ID of the chosen menu item
	and a ; buying?
	jp z,.buyMenu
	dec a ; selling?
	jp z,.sellMenu
	dec a ; quitting?
	jp z,.done
.sellMenu
	xor a
	ld [wcf93],a
	ld a,$02
	ld [wd11b],a
	callab Func_39bd5
	ld a,[wNumBagItems]
	and a
	jp z,.bagEmpty
	ld hl,PokemonSellingGreetingText
	call PrintText
	call SaveScreenTilesToBuffer1 ; save screen
.sellMenuLoop
	call LoadScreenTilesFromBuffer1 ; restore saved screen
	ld a,MONEY_BOX
	ld [wTextBoxID],a
	call DisplayTextBoxID ; draw money text box
	ld hl,wNumBagItems
	ld a,l
	ld [wList],a
	ld a,h
	ld [wList + 1],a
	xor a
	ld [wcf93],a
	ld [wCurrentMenuItem],a
	ld a,ITEMLISTMENU
	ld [wListMenuID],a
	call DisplayListMenuID
	jp c,.returnToMainPokemartMenu ; if the player closed the menu
.confirmItemSale ; if the player is trying to sell a specific item
	call IsKeyItem ; check if item is unsellable
	ld a,[wd124]
	and a
	jr nz,.unsellableItem
	ld a,[wcf91]
	call IsItemHM
	jr c,.unsellableItem
	ld a,PRICEDITEMLISTMENU
	ld [wListMenuID],a
	ld [$ff8e],a ; halve prices when selling
	call DisplayChooseQuantityMenu
	inc a
	jr z,.sellMenuLoop ; if the player closed the choose quantity menu with the B button
	ld hl,PokemartTellSellPriceText
	ld bc,$0e01
	call PrintText
	hlCoord 14, 7
	ld bc,$080f
	ld a,TWO_OPTION_MENU
	ld [wTextBoxID],a
	call DisplayTextBoxID ; yes/no menu
	ld a,[wd12e]
	cp a,$02
	jr z,.sellMenuLoop ; if the player pressed the B button
	ld a,[wd12d] ; ID of the chosen menu item
	dec a
	jr z,.sellMenuLoop ; if the player chose No
.sellItem
	ld a,[wcf0a] ; flag that is set if something is sold or bought
	and a
	jr nz,.skipSettingFlag1
	inc a
	ld [wcf0a],a
.skipSettingFlag1
	call AddAmountSoldToMoney
	ld hl,wNumBagItems
	call RemoveItemFromInventory
	jp .sellMenuLoop
.unsellableItem
	ld hl,PokemartUnsellableItemText
	call PrintText
	jp .returnToMainPokemartMenu
.bagEmpty
	ld hl,PokemartItemBagEmptyText
	call PrintText
	call SaveScreenTilesToBuffer1 ; save screen
	jp .returnToMainPokemartMenu
.buyMenu
	ld a,$01
	ld [wcf93],a
	ld a,$03
	ld [wd11b],a
	callab Func_39bd5
	ld hl,PokemartBuyingGreetingText
	call PrintText
	call SaveScreenTilesToBuffer1 ; save screen
.buyMenuLoop
	call LoadScreenTilesFromBuffer1 ; restore saved screen
	ld a,MONEY_BOX
	ld [wTextBoxID],a
	call DisplayTextBoxID ; draw money text box
	ld hl,wStringBuffer2 + 11
	ld a,l
	ld [wList],a
	ld a,h
	ld [wList + 1],a
	xor a
	ld [wCurrentMenuItem],a
	inc a
	ld [wcf93],a
	inc a ; a = 2 (PRICEDITEMLISTMENU)
	ld [wListMenuID],a
	call DisplayListMenuID
	jr c,.returnToMainPokemartMenu ; if the player closed the menu
IF HACK_SHOW_OWNED_ITEM_COUNT == 1
	call HackShowItemCount
ENDC
	ld a,$63
	ld [wcf97],a
	xor a
	ld [$ff8e],a
	call DisplayChooseQuantityMenu
	inc a
	jr z,.buyMenuLoop ; if the player closed the choose quantity menu with the B button
	ld a,[wcf91] ; item ID
	ld [wd11e],a ; store item ID for GetItemName
	call GetItemName
	call CopyStringToCF4B ; copy name to wcf4b
	ld hl,PokemartTellBuyPriceText
	call PrintText
	hlCoord 14, 7
	ld bc,$080f
	ld a,TWO_OPTION_MENU
	ld [wTextBoxID],a
	call DisplayTextBoxID ; yes/no menu
	ld a,[wd12e]
	cp a,$02
	jp z,.buyMenuLoop ; if the player pressed the B button
	ld a,[wd12d] ; ID of the chosen menu item
	dec a
	jr z,.buyMenuLoop ; if the player chose No
.buyItem
	call .isThereEnoughMoney
	jr c,.notEnoughMoney
	ld hl,wNumBagItems
	call AddItemToInventory
	jr nc,.bagFull
	call SubtractAmountPaidFromMoney
	ld a,[wcf0a] ; flag that is set if something is sold or bought
	and a
	jr nz,.skipSettingFlag2
	ld a,$01
	ld [wcf0a],a
.skipSettingFlag2
	ld a,(SFX_02_5a - SFX_Headers_02) / 3
	call PlaySoundWaitForCurrent
	call WaitForSoundToFinish
	ld hl,PokemartBoughtItemText
	call PrintText
	jp .buyMenuLoop
.returnToMainPokemartMenu
	call LoadScreenTilesFromBuffer1
	ld a,MONEY_BOX
	ld [wTextBoxID],a
	call DisplayTextBoxID ; draw money text box
	ld hl,PokemartAnythingElseText
	call PrintText
	jp .loop
.isThereEnoughMoney
	ld de,wPlayerMoney
	ld hl,$ff9f ; item price
	ld c,3 ; length of money in bytes
	jp StringCmp
.notEnoughMoney
	ld hl,PokemartNotEnoughMoneyText
	call PrintText
	jr .returnToMainPokemartMenu
.bagFull
	ld hl,PokemartItemBagFullText
	call PrintText
	jr .returnToMainPokemartMenu
.done
	ld hl,PokemartThankYouText
	call PrintText
	ld a,$01
	ld [wUpdateSpritesEnabled],a
	call UpdateSprites ; move sprites
	ld a,[wd07e]
	ld [wListScrollOffset],a
	ret

PokemartBuyingGreetingText: ; 6e0c (1:6e0c)
	TX_FAR _PokemartBuyingGreetingText
	db "@"

PokemartTellBuyPriceText: ; 6e11 (1:6e11)
	TX_FAR _PokemartTellBuyPriceText
	db "@"

PokemartBoughtItemText: ; 6e16 (1:6e16)
	TX_FAR _PokemartBoughtItemText
	db "@"

PokemartNotEnoughMoneyText: ; 6e1b (1:6e1b)
	TX_FAR _PokemartNotEnoughMoneyText
	db "@"

PokemartItemBagFullText: ; 6e20 (1:6e20)
	TX_FAR _PokemartItemBagFullText
	db "@"

PokemonSellingGreetingText: ; 6e25 (1:6e25)
	TX_FAR _PokemonSellingGreetingText
	db "@"

PokemartTellSellPriceText: ; 6e2a (1:6e2a)
	TX_FAR _PokemartTellSellPriceText
	db "@"

PokemartItemBagEmptyText: ; 6e2f (1:6e2f)
	TX_FAR _PokemartItemBagEmptyText
	db "@"

PokemartUnsellableItemText: ; 6e34 (1:6e34)
	TX_FAR _PokemartUnsellableItemText
	db "@"

PokemartThankYouText: ; 6e39 (1:6e39)
	TX_FAR _PokemartThankYouText
	db "@"

PokemartAnythingElseText: ; 6e3e (1:6e3e)
	TX_FAR _PokemartAnythingElseText
	db "@"
	
IF HACK_SHOW_OWNED_ITEM_COUNT == 1
HackShowItemCount:
	;clear the textbox area
	hlCoord 1,14
	ld bc, $0310 ;16x4
	call ClearScreenArea
	
	;print the label
	hlCoord 1,14
	ld de, HackItemsInBagText
	call PlaceString
	
	;fetch and print the item count
	ld a,[wcf91] ; item ID
	call HackGetNumItemsInBag
	hlCoord 9,14
	call .printNum
	
	ld a,[wcf91] ; item ID
	call HackGetNumItemsInPC
	hlCoord 9,16
	;fall through
	
.printNum:
	push hl ;push hl once to make space on the stack for our number
	push hl ;push a second time to actually save it
	ld hl,sp+2 ;get the pointer to that space
	ld a,b
	ld [hli],a ;overwrite it with the item count
	ld a,c
	ld [hld],a
	ld d,h     ;copy hl into de
	ld e,l
	pop hl     ;restore hl (destination address)
	ld bc,$4205 ;2 bytes, 5 digits, left align
	call PrintNumber
	pop hl ;pop the temp space to balance the stack.
	ret
	
HackGetNumItemsInPC::
	ld hl,wBoxItems
	jr HackGetNumItems_

HackGetNumItemsInBag::
	;given an item ID in A, count how many of them are in the bag and
	;return that amount in BC.
	ld hl,wBagItems
	
HackGetNumItems_:
	ld bc, 0
	ld d,a  ;d = item ID

.loop:
	ld a,[hli] ;a = this item ID
	cp $FF     ;no more items?
	jr z, .done
	
	cp d
	jr nz, .next
	
	;add this quantity to the total
	ld a,[hl]  ;get quantity
	push hl
	
	push bc
	pop hl ;copy bc into hl
	ld b,0
	ld c,a
	add hl,bc
	push hl
	pop bc ;copy hl into bc
	
	pop hl ;restore hl (item ptr)
	
.next:
	inc hl ;next item ID
	jr .loop
	
.done:
	ret
	
HackItemsInBagText:
	db   "In bag:"
	next "In PC:@"
ENDC
