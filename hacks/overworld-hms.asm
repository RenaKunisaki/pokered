;hack functions to use HM moves directly from the overworld.
SECTION "HackUseHMsFromOverworld",ROMX ;put this somewhere in ROM where it fits.
HackCheckFacingTile::
	;A was pressed and there isn't anything else here to talk to
	predef GetTileAndCoordsInFrontOfPlayer
	
	;get pointer to tile functions for this tileset.
	ld a,[W_CURMAPTILESET]
	ld b,0
	ld c,a
	ld hl, hackTilesetFunctions
	add hl,bc
	add hl,bc
	ld a,[hli]
	ld h,[hl]
	ld l,a
	
	;get the tile ID.
	ld a,[wTileInFrontOfPlayer]
	ld b,a
	
	;check the function for this tile.
.nextTile:
	ld a,[hli]
	cp $FF
	jr z, .unknownTile
	cp b
	jr nz, .nextTile
	
	;get the function pointer and call it.
	ld a,[hli]
	ld h,[hl]
	ld l,a
	jp hl
	
.unknownTile:
	;debug: show the tile ID
	ld hl,hackUnknownTileText
	;jp hackDisplayText
	ret
	
	
hackInteractWaterTile:
	;are we already surfing?
	ld a,[wWalkBikeSurfState]
	cp 2
	ret z
	
	;display the "water is calm" message.
	call hackOpenTextBox
	ld hl,hackWaterCalmText
	call PrintText
	call WaitForTextScrollButtonPress
	
IF HACK_USE_HM_FROM_OVERWORLD_DEBUG == 0
	ld a,[W_OBTAINEDBADGES]
	bit 4,a
	jr z, .done ;player doesn't have badge needed to surf.
	
	ld b,SURF
	call checkWhoHasMove
	jr nc, .done ;nobody knows Surf.
ENDC
	
	;ask if we want to surf.
	ld hl, hackWantSurfText
	call PrintText
	call YesNoChoice
	ld a,[wCurrentMenuItem]
	and a
	jr nz, .done
	
	;use Surf
	ld a,SURFBOARD
	ld [wcf91],a
	ld [wd152],a
	call UseItem
	
.done:
	jp hackCloseTextBox
	
	
hackInteractCutBush:
	;display the "can be cut" message.
	call hackOpenTextBox
	ld hl,hackTreeCutText
	call PrintText
	call WaitForTextScrollButtonPress
	
IF HACK_USE_HM_FROM_OVERWORLD_DEBUG == 0
	ld a,[W_OBTAINEDBADGES]
	bit 1,a
	jr z, .done ;player doesn't have badge needed to cut.
	
	ld b,CUT
	call checkWhoHasMove
	jr nc, .done ;nobody knows Cut.
ENDC
	
	;ask if we want to cut.
	ld hl, hackWantCutText
	call PrintText
	call YesNoChoice
	ld a,[wCurrentMenuItem]
	and a
	jr nz, .done
	
	;use Cut
	callba HackUseCut
	
.done:
	jp hackCloseTextBox
	
	
hackDisplayText:
	;display a textbox, wait for user to close it, and remove it.
	push hl
	call hackOpenTextBox
	pop hl
	call PrintText
	call WaitForTextScrollButtonPress
	jp hackCloseTextBox
	
	
hackOpenTextBox:
	xor a
	ld [wListMenuID],a
	ld hl,wcfc4 ;have the map sprites reloaded after we're done.
	set 0,[hl]
	call hackForceNPCsStandStill
	call UpdateSprites
	
	hlCoord 0, 12
	ld bc,$0412
	call TextBoxBorder
	
	ld b,$9c ; window background address
	call CopyScreenTileBufferToVRAM ; transfer background in WRAM to VRAM
	
	call LoadFontTilePatterns
	xor a
	ld [hWY],a ; put the window on the screen
	inc a
	ld [H_AUTOBGTRANSFERENABLED],a ; enable continuous WRAM to VRAM transfer each V-blank
	ret
	
hackCloseTextBox:
	xor a
	ld [H_AUTOBGTRANSFERENABLED],a
	ld a,$90
	ld [hWY],a ; move the window off the screen
	callba InitMapSprites
	ld hl,wcfc4
	res 0,[hl]
	call LoadPlayerSpriteGraphics
	call LoadCurrentMapView
	jp UpdateSprites
	
hackForceNPCsStandStill:
	;set all NPCs to standing animation so that we can
	;overwrite the walk frames with text
	ld hl,wSpriteStateData1 + 2
	ld de,$0010
	ld c,e
.spriteStandStillLoop
	ld a,[hl]
	cp a,$ff ; is the sprite visible?
	jr z,.nextSprite
; if it is visible
	and a,$fc
	ld [hl],a
.nextSprite
	add hl,de
	dec c
	jr nz,.spriteStandStillLoop
	ret
	
	
;check which mon, if any, knows a move.
;move ID in B
;returns carry set if someone has it.
;also copies their name to wcd6d, species to wcf91,
;and party position to wWhichPokemon.
checkWhoHasMove:
	ld a,[wPartyCount]
	and a
	ret z
	ld d,a
	ld e,0
	ld hl,wPartyMon1Moves
.nextMon:
	call .checkMonHasMove
	jr c, .foundMon
	push bc
	ld bc,(wPartyMon2 - wPartyMon1) - NUM_MOVES ;to next party mon move1
	add hl,bc
	pop bc
	inc e
	dec d
	jr nz,.nextMon
	and a ;clear carry
	ret

.foundMon:
	;copy mon's name to wcd6d
	ld a,e
	ld [wWhichPokemon],a
	push af
	call GetPartyMonName2
	
	;get the mon species (needed for playing cry for Strength)
	pop af
	ld hl,wPartySpecies
	ld b,0
	ld c,a
	add hl,bc
	ld a,[hl]
	ld [wcf91],a

.hasMove:
	scf
	ret
	
.checkMonHasMove:
	ld c,NUM_MOVES
.nextMove:
	ld a,[hli]
	cp b
	jr z,.hasMove
	dec c
	jr nz,.nextMove
	and a ;clear carry
	ret
	
	
;called from the boulder text "requires strength to move"
hackUseStrengthOverworld::
	ld a,[wd728]
	bit 0,a ;Strength used?
	jr nz,.alreadyUsed
	
	;show "requires strength" text
	ld hl,hackNeedStrengthText
	call PrintText
	call WaitForTextScrollButtonPress
	
IF HACK_USE_HM_FROM_OVERWORLD_DEBUG == 0
	ld a,[W_OBTAINEDBADGES]
	bit 3,a
	jr z, .done ;player doesn't have badge needed to use Strength.
	
	ld b,STRENGTH
	call checkWhoHasMove
	jr nc, .done ;nobody knows Strength.
ENDC
	
	;ask if we want to use it.
	ld hl, hackWantStrengthText
	call PrintText
	call YesNoChoice
	ld a,[wCurrentMenuItem]
	and a
	jr nz, .done
	
	;use Strength
	predef PrintStrengthTxt
	
.done:
	;don't wait for A button press.
	ld a,1
	ld [wDoNotWaitForButtonPressAfterDisplayingText],a
	ret
	
.alreadyUsed:
	ld hl,hackStrengthActiveText
	call PrintText
	call WaitForTextScrollButtonPress
	jr .done
	

;map of tileset ID => pointer to tile functions list
;XXX add more tilesets and their tile IDs.
hackTilesetFunctions:
	dw hackTileFunctionsOverworld ;OVERWORLD
	dw hackTileFunctionsNone      ;REDS_HOUSE_1
	dw hackTileFunctionsNone      ;MART
	dw hackTileFunctionsOverworld ;FOREST
	dw hackTileFunctionsNone      ;REDS_HOUSE_2
	dw hackTileFunctionsNone      ;DOJO
	dw hackTileFunctionsNone      ;POKECENTER
	dw hackTileFunctionsGym       ;GYM
	dw hackTileFunctionsNone      ;HOUSE
	dw hackTileFunctionsNone      ;FOREST_GATE
	dw hackTileFunctionsNone      ;MUSEUM
	dw hackTileFunctionsNone      ;UNDERGROUND
	dw hackTileFunctionsNone      ;GATE
	dw hackTileFunctionsNone      ;SHIP
	dw hackTileFunctionsNone      ;SHIP_PORT
	dw hackTileFunctionsNone      ;CEMETERY
	dw hackTileFunctionsNone      ;INTERIOR
	dw hackTileFunctionsNone      ;CAVERN
	dw hackTileFunctionsNone      ;LOBBY
	dw hackTileFunctionsNone      ;MANSION
	dw hackTileFunctionsNone      ;LAB
	dw hackTileFunctionsNone      ;CLUB
	dw hackTileFunctionsNone      ;FACILITY
	dw hackTileFunctionsNone      ;PLATEAU
IF DEF(_OPTION_BEACH_HOUSE)
	dw hackTileFunctionsNone      ;BEACH_HOUSE_TILESET
ENDC
	
;map of tile ID => which function to use when pressing A at it.
hackTileFunctionsOverworld:
	dbw $14, hackInteractWaterTile
	dbw $32, hackInteractWaterTile
	dbw $48, hackInteractWaterTile
	dbw $3D, hackInteractCutBush  ;cut bush on overworld
hackTileFunctionsNone:
	;use the end-of-list marker for hackTileFunctionsOverworld
	;as an empty list as well.
	db $FF ;end of list.
	
hackTileFunctionsGym:
	dbw $50, hackInteractCutBush  ;cut bush in gyms
	db $FF ;end of list.
	
	;displays tile ID if it's not in the above list.
hackUnknownTileText:
	text "Tile @" ;print inline text
	TX_NUM wTileInFrontOfPlayer, 1, 3
	db $0
	line "Tileset @"
	TX_NUM W_CURMAPTILESET, 1, 3
	db "@" ;end text
	
hackWaterCalmText:
	text "The water is calm.@"
	db "@" ;end text
	
hackWantSurfText:
	text "Do you want to "
	next "use SURF?@"
	db "@" ;end text
	
hackTreeCutText:
	text "This tree can be"
	next "CUT!@"
	db "@" ;end text
	
hackWantCutText:
	text "Do you want to "
	next "use CUT?@"
	db "@" ;end text
	
hackNeedStrengthText:
	text "This requires"
	next "STRENGTH to move!@"
	db "@" ;end text
	
hackWantStrengthText:
	text "Do you want to "
	next "use STRENGTH?@"
	db "@" ;end text
	
hackStrengthActiveText:
	text "Boulders can now"
	next "be moved.@"
	db "@" ;end text
