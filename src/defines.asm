
; ---------------
; Compiler Flags
; ---------------

!VERSION_MAJOR = 1
!VERSION_MINOR = 1
!VERSION_BUILD = 1
!VERSION_REV = 0


; ---------------
; Savestate code variables
; ---------------

!SAVESTATES ?= 1
!RERANDOMIZE ?= 1 ; set to 0 to disable RNG randomization on loadstate

!WRAM_START = $7EFFC0
!WRAM_BANK = $7E

!ram_realtime_room = !WRAM_START+$00
!ram_transition_flag = !WRAM_START+$02
!ram_transition_counter = !WRAM_START+$04
!ram_last_room_lag = !WRAM_START+$06
!ram_last_realtime_room = !WRAM_START+$08
!ram_last_realtime_door = !WRAM_START+$0A
!ram_last_door_lag_frames = !WRAM_START+$0C
!ram_lag_counter = !WRAM_START+$0E

!SS_INPUT_CUR = $8B
!SS_INPUT_NEW = $8F
!SS_INPUT_PREV = $97

!SRAM_DMA_BANK = $770000
!SRAM_SAVED_SP = $774004

!SRAM_MUSIC_BANK = $701FD0
!SRAM_MUSIC_TRACK = $701FD2
!MUSIC_BANK = $07F3
!MUSIC_TRACK = $07F5
!MUSIC_ROUTINE = $808FC1
!ram_room_has_set_rng = !WRAM_START+$10
!sram_save_has_set_rng = $702A00
!sram_savestate_safeword = $774006

!HUD_TILEMAP = $7EC5C8
!IH_BLANK = $000F
!HUD_0 = $0010
!HUD_1 = $0011
!HUD_2 = $0012
!HUD_3 = $0013
!HUD_4 = $0014
!HUD_5 = $0015
!HUD_6 = $0016
!HUD_7 = $0017
!HUD_8 = $0018
!HUD_9 = $0019
!HUD_0l = $0810
!HUD_1l = $0811
!HUD_2l = $0812
!HUD_3l = $0813
!HUD_4l = $0814
!HUD_5l = $0815
!HUD_6l = $0816
!HUD_7l = $0817
!HUD_8l = $0818
!HUD_9l = $0819
!HUD_0r = $0800
!HUD_1r = $0801
!HUD_2r = $0802
!HUD_3r = $0803
!HUD_4r = $0804
!HUD_5r = $0805
!HUD_6r = $0806
!HUD_7r = $0807
!HUD_8r = $0808
!HUD_9r = $0809
!HUD_DECIMAL = $004D


; ---------
; Work RAM
; ---------

!ram_tilemap_buffer = $7E5800

!ram_last_hp = !WRAM_START+$2C

; ---------
; RAM Menu
; ---------

!WRAM_MENU_START = $7EFE00

!ram_cm_stack_index = $05D5
!ram_cm_menu_stack = !WRAM_MENU_START+$00         ; 16 bytes
!ram_cm_cursor_stack = !WRAM_MENU_START+$10       ; 16 bytes

!ram_cm_cursor_max = !WRAM_MENU_START+$20
!ram_cm_horizontal_cursor = !WRAM_MENU_START+$22
!ram_cm_input_timer = !WRAM_MENU_START+$24
!ram_cm_controller = !WRAM_MENU_START+$26
!ram_cm_menu_bank = !WRAM_MENU_START+$28

!ram_cm_etanks = !WRAM_MENU_START+$2A
!ram_cm_reserve = !WRAM_MENU_START+$2C
!ram_cm_leave = !WRAM_MENU_START+$2E
!ram_cm_input_counter = !WRAM_MENU_START+$30
!ram_cm_last_nmi_counter = !WRAM_MENU_START+$32

!ram_cm_ctrl_mode = !WRAM_MENU_START+$34
!ram_cm_ctrl_timer = !WRAM_MENU_START+$36
!ram_cm_ctrl_last_input = !WRAM_MENU_START+$38
!ram_cm_ctrl_assign = !WRAM_MENU_START+$3A
!ram_cm_ctrl_swap = !WRAM_MENU_START+$3C

!ram_cm_palette_border = !WRAM_MENU_START+$3E
!ram_cm_palette_headeroutline = !WRAM_MENU_START+$40
!ram_cm_palette_text = !WRAM_MENU_START+$42
!ram_cm_palette_background = !WRAM_MENU_START+$44
!ram_cm_palette_numoutline = !WRAM_MENU_START+$46
!ram_cm_palette_numfill = !WRAM_MENU_START+$48
!ram_cm_palette_toggleon = !WRAM_MENU_START+$4A
!ram_cm_palette_seltext = !WRAM_MENU_START+$4C
!ram_cm_palette_seltextbg = !WRAM_MENU_START+$4E
!ram_cm_palette_numseloutline = !WRAM_MENU_START+$50
!ram_cm_palette_numsel = !WRAM_MENU_START+$52

!ram_seed_X = !WRAM_MENU_START+$60
!ram_seed_Y = !WRAM_MENU_START+$62

!ram_cm_sfxlib1 = !WRAM_MENU_START+$68
!ram_cm_sfxlib2 = !WRAM_MENU_START+$6A
!ram_cm_sfxlib3 = !WRAM_MENU_START+$6C
!ram_cm_fast_scroll_menu_selection = !WRAM_MENU_START+$6E

; ^ FREE SPACE ^ up to +$7A

!ram_tel_debug_area = !WRAM_MENU_START+$7C
!ram_tel_debug_station = !WRAM_MENU_START+$7E

; ------------------
; Reusable RAM Menu
; ------------------

; The following RAM may be used multiple times,
; as long as it isn't used multiple times on the same menu page

!ram_cm_watch_enemy_property = !WRAM_MENU_START+$80
!ram_cm_watch_enemy_index = !WRAM_MENU_START+$82
!ram_cm_watch_enemy_side = !WRAM_MENU_START+$84
!ram_cm_watch_common_address = !WRAM_MENU_START+$86

!ram_cm_phan_first_phase = !WRAM_MENU_START+$80
!ram_cm_phan_second_phase = !WRAM_MENU_START+$82

!ram_cm_varia = !WRAM_MENU_START+$80
!ram_cm_gravity = !WRAM_MENU_START+$82
!ram_cm_morph = !WRAM_MENU_START+$84
!ram_cm_bombs = !WRAM_MENU_START+$86
!ram_cm_spikebreaker = !WRAM_MENU_START+$88
!ram_cm_screw = !WRAM_MENU_START+$8A
!ram_cm_superjump = !WRAM_MENU_START+$8C
!ram_cm_space = !WRAM_MENU_START+$8E
!ram_cm_speed = !WRAM_MENU_START+$90
!ram_cm_speed2 = !WRAM_MENU_START+$92
!ram_cm_charge = !WRAM_MENU_START+$94
!ram_cm_wide = !WRAM_MENU_START+$96
!ram_cm_wave = !WRAM_MENU_START+$98
!ram_cm_plasma = !WRAM_MENU_START+$9A
!ram_cm_missile2 = !WRAM_MENU_START+$9C
!ram_cm_missile3 = !WRAM_MENU_START+$9E
!ram_cm_missile4 = !WRAM_MENU_START+$A0

!ram_cm_custompalette_blue = !WRAM_MENU_START+$80
!ram_cm_custompalette_green = !WRAM_MENU_START+$82
!ram_cm_custompalette_red = !WRAM_MENU_START+$84
!ram_cm_custompalette = !WRAM_MENU_START+$86
!ram_cm_dummy_on = !WRAM_MENU_START+$8A
!ram_cm_dummy_off = !WRAM_MENU_START+$8C
!ram_cm_dummy_num = !WRAM_MENU_START+$8E

; ^ FREE SPACE ^ up to +$CE
; Note: +$B8 to +$CE range also used as frames held counters
;       and is reset to zero when loading a savestate

; Reserve 48 bytes for CGRAM cache
; Currently first 28 bytes plus last 2 bytes are used
!ram_cgram_cache = !WRAM_MENU_START+$D0


; -----
; SRAM
; -----

; Assert if SRAM is greater than 8k
; Don't check if creating IPS patches
if read1($00FFD5) == $00 || read1($00FFD5) == $FF
else
assert read1($00FFD8) <= $03,"Hack uses extra SRAM!"
endif
!SRAM_VERSION = #$0017
!SAFEWORD = #$5AFE

!SRAM_START = $702200

!sram_initialized = !SRAM_START+$00

!sram_ctrl_menu = !SRAM_START+$02
!sram_ctrl_kill_enemies = !SRAM_START+$04
!sram_ctrl_full_equipment = !SRAM_START+$06
!sram_ctrl_reset_segment_timer = !SRAM_START+$08
!sram_ctrl_reset_segment_later = !SRAM_START+$0A
!sram_ctrl_load_state = !SRAM_START+$0C
!sram_ctrl_save_state = !SRAM_START+$0E
!sram_ctrl_update_timers = !SRAM_START+$1E

!sram_music_toggle = !SRAM_START+$2A

; FREE SPACE ^ up to +$5A

!sram_seed_X = !SRAM_START+$82
!sram_seed_Y = !SRAM_START+$84

; ^ FREE SPACE ^ up to +$BA4

!sram_safeword = !SRAM_START+$BA6

!sram_custom_header_normal = !SRAM_START+$BA8 ; $18 bytes
!sram_custom_preset_safewords_normal = !SRAM_START+$BC0 ; $50 bytes
!sram_custom_preset_names_normal = !SRAM_START+$C10 ; $3C0 bytes

!sram_custom_header_tinystates = !SRAM_START+$E18 ; $18 bytes
!sram_custom_preset_safewords_tinystates = !SRAM_START+$E30 ; $20 bytes
!sram_custom_preset_names_tinystates = !SRAM_START+$E50 ; $180 bytes

; SM specific things
!SRAM_MUSIC_DATA = !SRAM_START+$0FD0
!SRAM_MUSIC_TRACK = !SRAM_START+$0FD2
!SRAM_SOUND_TIMER = !SRAM_START+$0FD4

; ^ FREE SPACE ^ up to +$0FFE


; --------------
; Vanilla Labels
; --------------

!IH_CONTROLLER_PRI = $8B
!IH_CONTROLLER_PRI_NEW = $8F
!IH_CONTROLLER_PRI_PREV = $97

!IH_CONTROLLER_SEC = $8D
!IH_CONTROLLER_SEC_NEW = $91
!IH_CONTROLLER_SEC_PREV = $99

!MENU_CLEAR = #$000E
!MENU_BLANK = #$286F
!IH_BLANK = #$2C0F
!IH_PERCENT = #$0C0A
!IH_DECIMAL = #$0CCB
!IH_HYPHEN = #$0C55
!IH_RESERVE_AUTO = #$0C0C
!IH_RESERVE_EMPTY = #$0C0D
!IH_HEALTHBOMB = #$085A
!IH_LETTER_A = #$0C64
!IH_LETTER_B = #$0C65
!IH_LETTER_C = #$0C58
!IH_LETTER_D = #$0C59
!IH_LETTER_E = #$0C5A
!IH_LETTER_F = #$0C5B
!IH_LETTER_H = #$0C6C
!IH_LETTER_L = #$0C68
!IH_LETTER_N = #$0C56
!IH_LETTER_R = #$0C69
!IH_LETTER_X = #$0C66
!IH_LETTER_Y = #$0C67
!IH_NUMBER_ZERO = #$0C09
!IH_ELEVATOR = #$1C0B
!IH_SHINETIMER = #$0032

!IH_PAUSE = #$0100 ; right
!IH_SLOWDOWN = #$0400 ; down
!IH_SPEEDUP = #$0800 ; up
!IH_RESET = #$0200 ; left
!IH_STATUS_R = #$0010 ; r
!IH_STATUS_L = #$0020 ; l

!IH_INPUT_START = #$1000
!IH_INPUT_UPDOWN = #$0C00
!IH_INPUT_UP = #$0800
!IH_INPUT_DOWN = #$0400
!IH_INPUT_LEFTRIGHT = #$0300
!IH_INPUT_LEFT = #$0200
!IH_INPUT_RIGHT = #$0100
!IH_INPUT_HELD = #$0001 ; used by menu

!CTRL_B = #$8000
!CTRL_Y = #$4000
!CTRL_SELECT = #$2000
!CTRL_A = #$0080
!CTRL_X = #$0040
!CTRL_L = #$0020
!CTRL_R = #$0010

!INPUT_BIND_UP = $7E09AA
!INPUT_BIND_DOWN = $7E09AC
!INPUT_BIND_LEFT = $7E09AE
!INPUT_BIND_RIGHT = $7E09B0
!IH_INPUT_SHOT = $7E09B2
!IH_INPUT_JUMP = $7E09B4
!IH_INPUT_RUN = $7E09B6
!IH_INPUT_ITEM_CANCEL = $7E09B8
!IH_INPUT_ITEM_SELECT = $7E09BA
!IH_INPUT_ANGLE_DOWN = $7E09BC
!IH_INPUT_ANGLE_UP = $7E09BE

!MUSIC_ROUTINE = $808FC1
!SFX_LIB1 = $80903F
!SFX_LIB2 = $8090C1
!SFX_LIB3 = $809143

!VRAM_WRITE_STACK_POINTER = $0330
!OAM_STACK_POINTER = $0590
!PB_EXPLOSION_STATUS = $0592
!REALTIME_LAG_COUNTER = $05A0 ; Not used in vanilla
!NMI_REQUEST_FLAG = $05B4
!FRAME_COUNTER_8BIT = $05B5
!FRAME_COUNTER = $05B6
!DEBUG_MODE = $05D1
!CACHED_RANDOM_NUMBER = $05E5
!DISABLE_SOUNDS = $05F5
!DISABLE_MINIMAP = $05F7
!SOUND_TIMER = $0686
!LOAD_STATION_INDEX = $078B
!DOOR_ID = $078D
!DOOR_DIRECTION = $0791
!ROOM_ID = $079B
!AREA_ID = $079F
!ROOM_WIDTH_BLOCKS = $07A5
!ROOM_WIDTH_SCROLLS = $07A9
!PREVIOUS_CRE_BITSET = $07B1
!CRE_BITSET = $07B3
!STATE_POINTER = $07BB
!ROOM_MUSIC_DATA_INDEX = $07CB
!MUSIC_DATA = $07F3
!MUSIC_TRACK = $07F5
!LAYER1_X = $0911
!LAYER1_Y = $0915
!LAYER2_X = $0917
!LAYER2_Y = $0919
!BG1_X_OFFSET = $091D
!BG1_Y_OFFSET = $091F
!BG2_X_SCROLL = $0921
!BG2_Y_SCROLL = $0923
!SAMUS_DOOR_SUBSPEED = $092B
!SAMUS_DOOR_SPEED = $092D
!CURRENT_SAVE_FILE = $0952
!GAMEMODE = $0998
!DOOR_FUNCTION_POINTER = $099C
!SAMUS_ITEMS_EQUIPPED = $09A2
!SAMUS_ITEMS_COLLECTED = $09A4
!SAMUS_BEAMS_EQUIPPED = $09A6
!SAMUS_BEAMS_COLLECTED = $09A8
!SAMUS_RESERVE_MODE = $09C0
!SAMUS_HP = $09C2
!SAMUS_HP_MAX = $09C4
!SAMUS_MISSILES = $09C6
!SAMUS_MISSILES_MAX = $09C8
!SAMUS_SUPERS = $09CA
!SAMUS_SUPERS_MAX = $09CC
!SAMUS_PBS = $09CE
!SAMUS_PBS_MAX = $09D0
!SAMUS_ITEM_SELECTED = $09D2
!SAMUS_RESERVE_MAX = $09D4
!SAMUS_RESERVE_ENERGY = $09D6
!IGT_FRAMES = $09DA
!IGT_SECONDS = $09DC
!IGT_MINUTES = $09DE
!IGT_HOURS = $09E0
!SAMUS_MOONWALK = $09E4
!PAL_DEBUG_MOVEMENT = $09E6
!SAMUS_AUTO_CANCEL = $0A04
!SAMUS_LAST_HP = $0A06
!SAMUS_POSE = $0A1C
!SAMUS_POSE_DIRECTION = $0A1E
!SAMUS_MOVEMENT_TYPE = $0A1F
!SAMUS_PREVIOUS_POSE = $0A20
!SAMUS_PREVIOUS_POSE_DIRECTION = $0A22
!SAMUS_PREVIOUS_MOVEMENT_TYPE = $0A23
!SAMUS_LAST_DIFFERENT_POSE = $0A24
!SAMUS_LAST_DIFFERENT_POSE_DIRECTION = $0A26
!SAMUS_LAST_DIFFERENT_MOVEMENT_TYPE = $0A27
!SAMUS_POTENTIAL_POSE_VALUES = $0A28
!SAMUS_POTENTIAL_POSE_FLAGS = $0A2E
!SAMUS_LOCKED_HANDLER = $0A42
!SAMUS_MOVEMENT_HANDLER = $0A44
!SAMUS_SUBUNIT_ENERGY = $0A4C
!SAMUS_NORMAL_MOVEMENT_HANDLER = $0A58
!SAMUS_DRAW_HANDLER = $0A5C
!SAMUS_CONTROLLER_HANDLER = $0A60
!SAMUS_SHINE_TIMER = $0A68
!SAMUS_HEALTH_WARNING = $0A6A
!SAMUS_CONTACT_DAMAGE_INDEX = $0A6E
!SAMUS_HYPER_BEAM = $0A76
!DEMO_PREINSTRUCTION_POINTER = $0A7A
!DEMO_INSTRUCTION_TIMER = $0A7C
!DEMO_INSTRUCTION_POINTER = $0A7E
!DEMO_CONTROLLER_PRI = $0A84
!DEMO_INPUT_ENABLED = $0A88
!DEMO_PREVIOUS_CONTROLLER_PRI = $0A8C
!DEMO_PREVIOUS_CONTROLLER_PRI_NEW = $0A8E
!SAMUS_ANIMATION_FRAME_TIMER = $0A94
!SAMUS_ANIMATION_FRAME = $0A96
!SAMUS_SHINESPARK_DELAY_TIMER = $0AA2
!SAMUS_SHINE_TIMER_TYPE = $0ACC
!SAMUS_AUTO_JUMP_TIMER = $0AF4
!SAMUS_X = $0AF6
!SAMUS_X_SUBPX = $0AF8
!SAMUS_Y = $0AFA
!SAMUS_Y_SUBPX = $0AFC
!SAMUS_X_RADIUS = $0AFE
!SAMUS_Y_RADIUS = $0B00
!SAMUS_COLLISION_DIRECTION = $0B02
!SAMUS_SPRITEMAP_X = $0B04
!SAMUS_PREVIOUS_X = $0B10
!SAMUS_PREVIOUS_X_SUBPX = $0B12
!SAMUS_PREVIOUS_Y = $0B14
!SAMUS_PREVIOUS_Y_SUBPX = $0B16
!SAMUS_Y_SUBSPEED = $0B2C
!SAMUS_Y_SPEEDCOMBINED = $0B2D
!SAMUS_Y_SPEED = $0B2E
!SAMUS_Y_SUBACCELERATION = $0B32
!SAMUS_Y_ACCELERATION = $0B34
!SAMUS_Y_DIRECTION = $0B36
!SAMUS_DASH_COUNTER = $0B3F
!SAMUS_X_RUNSPEED = $0B42
!SAMUS_X_SUBRUNSPEED = $0B44
!SAMUS_X_MOMENTUM = $0B46
!SAMUS_X_SUBMOMENTUM = $0B48
!SAMUS_PROJ_X = $0B64
!SAMUS_PROJ_Y = $0B78
!SAMUS_PROJ_RADIUS_X = $0BB4
!SAMUS_PROJ_RADIUS_Y = $0BC8
!SAMUS_PROJ_PROPERTIES = $0C18
!SAMUS_COOLDOWN_TIMER = $0CCC
!SAMUS_PROJECTILE_TIMER = $0CCE
!SAMUS_CHARGE_TIMER = $0CD0
!SAMUS_BOMB_COUNTER = $0CD2
!SAMUS_BOMB_SPREAD_CHARGE_TIMER = $0CD4
!SAMUS_POWER_BOMB_X = $0CE2
!SAMUS_POWER_BOMB_Y = $0CE4
!PREVIOUS_CONTROLLER_PRI = $0DFE
!PREVIOUS_CONTROLLER_PRI_NEW = $0E00
!ELEVATOR_PROPERTIES = $0E16
!ELEVATOR_STATUS = $0E18
!HEALTH_BOMB_FLAG = $0E1A
!ENEMY_BG2_VRAM_TRANSFER_FLAG = $0E1E
!ENEMY_INDEX = $0E54
!ENEMY_ID = $0F78
!ENEMY_X = $0F7A
!ENEMY_Y = $0F7E
!ENEMY_X_RADIUS = $0F82
!ENEMY_Y_RADIUS = $0F84
!ENEMY_PROPERTIES = $0F86
!ENEMY_EXTRA_PROPERTIES = $0F88
!ENEMY_HP = $0F8C
!ENEMY_SPRITEMAP = $0F8E
!ENEMY_BANK = $0FA6
!SAMUS_IFRAME_TIMER = $18A8
!SAMUS_KNOCKBACK_TIMER = $18AA
!ENEMY_PROJ_ID = $1997
!ENEMY_PROJ_X_SUBPX = $1A27
!ENEMY_PROJ_X = $1A4B
!ENEMY_PROJ_Y_SUBPX = $1A6F
!ENEMY_PROJ_Y = $1A93
!ENEMY_PROJ_X_VELOCITY = $1AB7
!ENEMY_PROJ_Y_VELOCITY = $1ADB
!ENEMY_PROJ_RADIUS = $1BB3
!ENEMY_PROJ_PROPERTIES = $1BD7
!MESSAGE_BOX_INDEX = $1C1F
!DEMO_TIMER = $1F53
!DEMO_CURRENT_SET = $1F55
!DEMO_CURRENT_SCENE = $1F57

!PLM_DELETE = $AAE3


; --------------------
; Aliases and Bitmasks
; --------------------

!FRAMERATE = #$003C

!DP_MenuIndices = $00 ; 0x4
!DP_CurrentMenu = $04 ; 0x4
!DP_Address = $08 ; 0x4
!DP_JSLTarget = $0C ; 0x4
!DP_CtrlInput = $10 ; 0x4
!DP_Palette = $14
!DP_Temp = $16
; v these repeat v
!DP_ToggleValue = $18
!DP_Increment = $1A
!DP_Minimum = $1C
!DP_Maximum = $1E
!DP_DrawValue = $18
!DP_FirstDigit = $1A
!DP_SecondDigit = $1C
!DP_ThirdDigit = $1E
!DP_KB_Index = $18
!DP_KB_Row = $1A
!DP_KB_Control = $1C
!DP_KB_Shift = $1E
; v single digit editing v
!DP_DigitAddress = $20 ; 0x4
!DP_DigitValue = $24
!DP_DigitMinimum = $26
!DP_DigitMaximum = $28

!ACTION_TOGGLE              = #$0000
!ACTION_TOGGLE_BIT          = #$0002
!ACTION_TOGGLE_INVERTED     = #$0004
!ACTION_TOGGLE_BIT_INVERTED = #$0006
!ACTION_NUMFIELD            = #$0008
!ACTION_NUMFIELD_HEX        = #$000A
!ACTION_NUMFIELD_WORD       = #$000C
!ACTION_CHOICE              = #$000E
!ACTION_CTRL_SHORTCUT       = #$0010
!ACTION_JSL                 = #$0012
!ACTION_JSL_SUBMENU         = #$0014
