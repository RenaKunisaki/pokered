; Rena's various hacks can be toggled/configured here.
; Note that changing these settings and then loading an existing save file might
; have various issues from not being able to walk at all to just immediately
; crashing the game.
; With these hacks disabled (all set to 0), the ROM should build identical
; to the original.


; hacks to increase player's walking speed.
; 0: normal (slow) walking speed.
; 1: fast walking (always run).
; 2: normal walking; hold B to run (anywhere)
; 3: normal walking; hold B to run (only outdoors/on maps that allow biking)
HACK_RUNNING_SHOES EQU 2



;speed up EVERYTHING on the overworld, including NPCs.
; 0: normal speed
; 1: high speed
; 2: ludicrous speed
HACK_SPEED_UP_OVERWORLD EQU 0


; hacks to deal with that stupid health alarm beep
; 0: leave it alone
; 1: disable it completely
; 2: beep a few times then stop
HACK_LOW_HEALTH_ALARM EQU 2

;how many times to beep, with mode 2 (1 to 127)
HACK_LOW_HEALTH_ALARM_COUNT EQU 2


; hack to enhance the battle screen:
; * Display power and accuracy of selected move.
; * Display PP of all moves.
; * Display "caught" indicator next to opponent
; * Display both level and status on HUD
; Planned enhancements:
; * EXP bars
; * Display a move's category (physical/special/status)
HACK_ENHANCE_BATTLE_SCREEN EQU 1


;show the "stats/switch/cancel" menu when switching mons in battle.
;normally it doesn't show when choosing a mon after yours or an opponent's
;has fainted, which is annoying because you can't check stats.
HACK_BATTLE_PARTY_STATS_MENU EQU 1


;allow to press left/right to adjust quantity by 10 when
;buying/selling/tossing an item
HACK_ADJUST_ITEM_QTY_BY_10 EQU 1


;when buying items, show how many you already have
HACK_SHOW_OWNED_ITEM_COUNT EQU 1


;allow to set the text speed anywhere from 0 to 7 frames per letter
HACK_FULL_TEXT_SPEED_OPTION EQU 1


;make the default text speed the fastest setting (no delay)
HACK_DEFAULT_TEXT_SPEED_FAST EQU 1


;make the text always appear with no delay, regardless of the setting
HACK_TEXT_NO_DELAY EQU 0


;allow to use HMs from the overworld by "talking" to bushes, water, rocks etc.
HACK_USE_HM_FROM_OVERWORLD EQU 1

;allow to use HMs from the overworld without HMs or badges
HACK_USE_HM_FROM_OVERWORLD_DEBUG EQU 1

; Enable the original debug mode (bit 1 of wd732)
; This activates the following functions in the existing code:
; * Skip new game intro (use default names)
; * Start new game outside player's house
; * Hold B to prevent wild encounters
; note that this hack might interfere with link battles, because those turn
; the debug mode off for some reason, but this hack forces it back on.
; probably this has to do with them re-using the "destination map" variable.
HACK_ENABLE_DEBUG_MODE EQU 1


;hold B to walk through walls.
HACK_WALK_THROUGH_WALLS EQU 1


;enable a new debug menu (not in the original program)
HACK_NEW_DEBUG_MENU EQU 1


;skip the intro and boot directly to the title screen
HACK_SKIP_INTRO EQU 1


;try to free some ROM0 space. needed for some hacks,
;especially if using several at once.
_CRAP_ASSEMBLER_1 EQU HACK_USE_HM_FROM_OVERWORLD
_CRAP_ASSEMBLER_2 EQU HACK_SHOW_OWNED_ITEM_COUNT | HACK_ADJUST_ITEM_QTY_BY_10
_CRAP_ASSEMBLER_3 EQU _CRAP_ASSEMBLER_1 | _CRAP_ASSEMBLER_2
IF _CRAP_ASSEMBLER_3 == 0
HACK_FREE_ROM0_SPACE EQU 0
ELSE
HACK_FREE_ROM0_SPACE EQU 1
ENDC
