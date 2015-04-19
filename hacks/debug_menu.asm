;debug menu added by Rena's HACK_NEW_DEBUG_MENU option.
;sorry, this menu isn't in the original game.

PUSHS
SECTION "DebugMenu",ROMX
DEBUG_MENU_NUM_OPTIONS EQU 8
HackNewDebugMenu_Init:: ;init at power-on
	push af
	push bc
	push hl
	xor a
	ld [wHackDebugMenuCursor],a
	inc a
	ld hl,wHackDebugMenuItems
	ld c, DEBUG_MENU_NUM_OPTIONS
.initCountersLoop:
	ld [hli],a
	dec c
	jr nz,.initCountersLoop
	
	xor a
	ld [wHackDebugMenuWhichUse],a
	pop hl
	pop bc
	pop af
	ret
	

HackNewDebugMenu:: ;show the menu
	ld a,[W_CURMAP]
	ld [wHackDebugMenuWhichMap],a
	
	
	;init menu, or re-init after using an option
.menuInit:
	call WaitForSoundToFinish
	
	;ld hl, $fff6
	;set 1, [hl] ;set cursor to move one row per item.
	ld hl, wd730
	set 6,[hl] ;display text with no delay
	
	xor a
	ld [wLastMenuItem],a
	
	inc a
	ld [wTopMenuItemX],a
	ld [wTopMenuItemY],a
	ld [wMenuWrappingEnabled],a
	
	ld a,$FF
	ld [wMenuWatchedKeys],a ;handle all buttons
	
	ld a, DEBUG_MENU_NUM_OPTIONS - 1
	ld [wMaxMenuItem],a
	ld a,[wHackDebugMenuCursor]
	ld [wCurrentMenuItem],a
	
	call ClearScreen
	
	;menu main loop while open
.menuMainLoop:
	call .redraw
	call UpdateSprites
	call HandleMenuInput
	push af
	call WaitForSoundToFinish
	
	ld a,1
	ld [wMenuWrappingEnabled],a
	
	ld a,[wCurrentMenuItem]
	ld [wHackDebugMenuCursor],a ;save cursor
	pop af
	
	bit 0,a ;A button pressed?
	jr nz, .activate
	
	bit 1,a ;B pressed?
	jp nz, .closeMenu
	
	bit 4,a ;Right pressed?
	jr nz, .increment
	
	bit 5,a ;Left pressed?
	jr nz, .decrement
	
	jr .menuMainLoop
	
	;activate the selected option
.activate:
	ld a,[wCurrentMenuItem]
	sla a
	ld c,a
	ld b,0
	ld hl,.menuOptionPtrs
	add hl,bc
	ld a,[hli]
	ld h,[hl]
	ld l,a
	jp [hl]
	

	;increment selected option
.increment:
	ld e,1
	jr .incdec

	;decrement selected option
.decrement:
	ld e,$FF

.incdec:
	ld a,[wCurrentMenuItem]
	ld c,a
	ld b,0
	ld hl,wHackDebugMenuItems
	add hl,bc
	ld a,[hl]
	add e
	ld [hl],a
	jr .menuMainLoop

	;redraw the menu
.redraw:
	;draw border
	hlCoord 0, 0
	ld bc, $1012 ; 20 x 18
	call TextBoxBorder
	
	;draw menu text
	hlCoord 2, 1
	ld de, .menuText
	call PlaceString
	
	;draw current map and coords below "goto map"
	hlCoord 3, 4
	ld de,W_CURMAP
	ld bc, $8103 ;one byte, 3 digits, with leading zeros
	call PrintNumber
	inc hl
	ld de,W_XCOORD
	call PrintNumber
	inc hl
	ld de,W_YCOORD
	call PrintNumber
	
	;draw IDs for items that have them.
	ld c, DEBUG_MENU_NUM_OPTIONS
	hlCoord 13, 1
	ld de, wHackDebugMenuItems
.redrawNumLoop:
	push bc
	push de
	ld bc, $8103 ;one byte, 3 digits, with leading zeros
	call PrintNumber
	
	ld bc,(SCREEN_WIDTH * 2) - 3
	add hl,bc
	pop de
	inc de
	pop bc
	dec c
	jr nz, .redrawNumLoop
	
.drawItemName:
	;draw item name
	ld a,[wHackDebugMenuWhichItem]
	and a
	jr z, .invalidItem ;don't attempt to print the names of invalid items
	cp MAX_ELIXER+1
	jr c,.validItem
	cp HM_01
	jr nc,.validItem
	
.invalidItem:
	ld a,$2C ;"?????"
	
.validItem:
	ld [wd11e],a
	call GetItemName
	hlCoord 3, 6
	ld de, wcd6d
	call PlaceString
	
.drawMonName:
	;draw mon name
	ld a,[wHackDebugMenuWhichMon]
	and a
	jr z, .invalidMon ;don't attempt to print the names of invalid mons
	cp VICTREEBEL+1
	jr c,.validMon
	
.invalidMon:
	ld de,.questionText
	jr .printMon
	
.validMon:
	ld [wd11e],a
	call GetMonName
	ld de, wcd6d
	
.printMon:
	hlCoord 3, 8
	call PlaceString
	

.drawUseText:
	ld a,[wHackDebugMenuWhichUse]
	cp 3
	jr c,.useTextOK
	ld de,.questionText
	jr .useTextWriteString
	
.useTextOK:
	ld hl, .useThingText-9
	ld bc, 9
	inc a
.mult:
	add hl,bc
	dec a
	jr nz,.mult
	
	ld d,h
	ld e,l
.useTextWriteString:
	hlCoord 3, 2
	jp PlaceString
	
	
	;"Go to map" function
.funcGotoMap:
	ld a,$FF
	ld hl,W_TOWNVISITEDFLAG
	ld [hli],a ;unlock all fly destinations
	ld [hli],a
	call ChooseFlyDestination
	jp .closeMenu
	
	;selecting a map by ID is clunky and buggy
	ld hl,wd732
	set 2,[hl] ;we used fly (whatever difference it is)
	set 3,[hl] ;trigger a warp
	res 4,[hl] ;destination isn't wDungeonWarpDestinationMap
	res 6,[hl] ;destination isn't wLastBlackoutMap
	
	inc hl
	set 7,[hl] ;used Fly (correct entrance animation)
	
	ld hl,wd736
	set 0,[hl] ;step down from door
	set 2,[hl] ;standing on warp
	
	;I don't know how much of this is necessary or what it all does.
	;This is still buggy; warping to indoor maps corrupts them.
	ld hl,wd72e
	res 4,[hl] ;unsure what this is for.
	
	ld a,$26
	ld [wd730],a
	
	;kill the map script so it doesn't try to run from unloaded map
	ld de,EmptyFunc2
	ld hl,W_MAPSCRIPTPTR
	ld a,e
	ld [hli],a
	ld [hl],d
	
	ld hl,wd790
	res 7,[hl] ; unset Safari Zone bit
	xor a
	ld [W_NUMSAFARIBALLS],a
	ld [W_SAFARIZONEENTRANCECURSCRIPT],a
	inc a
	ld [wEscapedFromBattle],a
	ld [wcd6a],a ; item used
	
	ld a,[W_CURMAP]
	ld [wLastMap],a
	
	ld a,[wHackDebugMenuWhichMap]
	ld [wDestinationMap],a
	ld [W_CURMAP],a
	ld a,1
	ld [wDestinationWarpID],a
	jp .closeMenu
	
	
	;"Give Item" function
.funcGiveItem:
	ld a,99
	ld [wcf97],a ;max quantity
	ld a,ITEMLISTMENU
	ld [wListMenuID],a
	call DisplayChooseQuantityMenu
	
	;give the item
	cp $FF
	jp z, .menuMainLoop ;cancelled
	ld a,[wcf96] ;selected quantity
	ld c,a
	ld a,[wHackDebugMenuWhichItem]
	ld b,a
	call GiveItem
	jr nc, .giveItemFail
	
	;play "deposit item" sound.
	ld a,(SFX_02_55 - SFX_Headers_02) / 3
	call PlaySound
	jp .menuInit
	
.giveItemFail:
	ld a,(SFX_02_46 - SFX_Headers_02) / 3
	call PlaySound
	jp .menuInit
	
	
	;"Give Mon" function
.funcGiveMon:
	ld a,100
	ld [wcf97],a ;max quantity (level)
	ld a,ITEMLISTMENU
	ld [wListMenuID],a
	call DisplayChooseQuantityMenu
	
	;give the mon
	cp $FF
	jp z, .menuMainLoop ;cancelled
	
	ld a,[hJoyHeld]
	bit 2,a ;select held?
	jr nz,.fightMon
	
	ld a,[wcf96] ;selected quantity
	ld c,a
	ld a,[wHackDebugMenuWhichMon]
	ld b,a
	call GivePokemon ;does sound effect, text, nickname etc
	jp .menuInit


.fightMon:
	ld a,[wcf96] ;selected quantity
	ld [W_CURENEMYLVL], a
	ld a,[wHackDebugMenuWhichMon]
	ld [W_CUROPPONENT], a
	jp .closeMenu
	
	
.funcUseThing:
	;ld a,(SFX_02_59 - SFX_Headers_02) / 3
	ld a,158 ;"ball placed on healing machine" sound
	call PlaySound
	ld a,[wHackDebugMenuWhichUse]
	and a
	jr z, .useRepel
	dec a
	jr z, .useStrength
	dec a
	jr z,.useFlash
	jp .menuInit
	
.useRepel:
	ld a,255
	ld [wRepelRemainingSteps],a
	jp .menuInit

.useStrength:
	ld hl,wd728
	set 0,[hl]
	jp .menuInit

.useFlash:
	xor a
	ld [wMapPalOffset],a
	jp .menuInit
	
	
.funcHealParty:
	predef HealParty
	ld a,(SFX_02_3e - SFX_Headers_02) / 3 ; status ailment curing sound
	call PlaySound
	jp .menuInit
	
.funcGiveMoney:
	ld a,$99
	ld hl,wPlayerMoney
	ld [hli],a
	ld [hli],a
	ld [hli],a
	ld hl,wPlayerCoins
	ld [hli],a
	ld [hli],a
	
	ld a,(SFX_02_5a - SFX_Headers_02) / 3
	call PlaySound
	jp .menuInit
	

	;"Open PC" function
.funcOpenPC:
	call FuncTX_PokemonCenterPC
	jp .closeMenu
	;I don't know why the menu doesn't work after opening the PC.
	;it seems to have to do with wFlags_0xcd60.
	;if I save that and restore it after calling the PC,
	;the game will actually crash, which makes no goddamn sense.
	;even with this, the start menu doesn't actually close.
	
	
.funcShowTextbox:
	ld a,[wHackDebugMenuWhichSound]
	ld [wTextBoxID],a
	call DisplayTextBoxID
	call HandleMenuInput
	jp CloseStartMenu

	
.funcPlaySound:
	ld a,[wHackDebugMenuWhichSound]
	call PlaySound
	jp .menuInit
	
	
.closeMenu:
	ld hl, wd730
	res 6,[hl] ;turn text delay back on
	jp CloseStartMenu
	
	
	;Function pointers for each item
.menuOptionPtrs:
	dw .funcUseThing
	dw .funcGotoMap
	dw .funcGiveItem
	dw .funcGiveMon
	dw .funcHealParty
	dw .funcGiveMoney
	dw .funcOpenPC
	dw .funcShowTextbox
	;dw .funcPlaySound

	
	;Item text
.menuText:
	db   "Use:"
	next "Go to map:"
	next "Give Item:"
	next "Give ", $E1, $E2, ":"
	next "Heal Party"
	next "Give Money"
	next "Open PC"
	next "Show Txtbx"
	db "@" ;end text
	
.questionText:
	db "?????@"
	
.useThingText:
	db "Repel   @"
	db "Strength@"
	db "Flash   @"

;other interesting functions/thoughts:
;give/edit badges (W_OBTAINEDBADGES)
;edit W_MISSABLEOBJECTLIST, W_GAMEPROGRESSFLAGS

POPS
