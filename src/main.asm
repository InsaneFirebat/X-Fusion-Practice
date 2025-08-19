
; X-Fusion practice hack v1.0.1
; Minimal features because there's barely any freespace (extra freespace found at $9BCBFB)
; Tinystates will not be supported due to too many things moving around in X-Fusion

; SD2SNES Savestate code originally by acmlm, total, Myria

lorom

; Savestate code variables
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
!HUD_0r = $0000 ; shifted right by 1 pixel, looks nice so I'll use it
!HUD_1r = $0001
!HUD_2r = $0002
!HUD_3r = $0003
!HUD_4r = $0004
!HUD_5r = $0005
!HUD_6r = $0006
!HUD_7r = $0007
!HUD_8r = $0008
!HUD_9r = $0009
!HUD_DECIMAL = $004D


incsrc defines.asm
incsrc macros.asm
incsrc freespace.asm
incsrc gamemode.asm
incsrc timer.asm
incsrc save.asm
incsrc menu.asm
incsrc misc.asm

%printfreespace()

