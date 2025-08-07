
; X-Fusion practice hack
; Minimal features because there's barely any freespace
; Tinystates will not be supported due to too many things moving around in X-Fusion

; SD2SNES Savestate code originally by acmlm, total, Myria

lorom

; Savestate code variables
!FREESPACE = $8BF800 ; repoint to anywhere in banks $80-BF, $80 preferred
; also freespace at $9BCC00
!SAVESTATES ?= 1
!RERANDOMIZE ?= 1 ; set to 0 to disable RNG randomization on loadstate
!SAVE_INPUTS = #$6010 ; Select + Y + R
!LOAD_INPUTS = #$6020 ; Select + Y + L
    ; Input Cheat Sheet
    ; $8000 = B
    ; $4000 = Y
    ; $2000 = Select
    ; $1000 = Start
    ; $0800 = Up
    ; $0400 = Down
    ; $0200 = Left
    ; $0100 = Right
    ; $0080 = A
    ; $0040 = X
    ; $0020 = L
    ; $0010 = R

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


macro a8() ; A = 8-bit
    SEP #$20
endmacro

macro a16() ; A = 16-bit
    REP #$20
endmacro

macro i8() ; X/Y = 8-bit
    SEP #$10
endmacro

macro i16() ; X/Y = 16-bit
    REP #$10
endmacro

macro ai8() ; A + X/Y = 8-bit
    SEP #$30
endmacro

macro ai16() ; A + X/Y = 16-bit
    REP #$30
endmacro


; Patch out copy protection
org $008000
    db $FF

if !SAVESTATES
; Set SRAM size
org $00FFD8
    db $08 ; 256kb
endif


; ------------
; Input Checks
; ------------

if !SAVESTATES
; hijack main game loop for input checks
org $8A8023
    JSL gamemode_start : BCS end_of_normal_gameplay

org $8A802E
    ; skip gamemode JSR if the current frame doesn't need to be processed any further
    end_of_normal_gameplay:
endif


org !FREESPACE
if !SAVESTATES
print pc, " gamemode start"
gamemode_start:
{
    PHB
    PHK : PLB

    ; check for new inputs
    LDA !SS_INPUT_NEW : BNE +
    CLC : BRA .done

    ; check for savestate inputs
+   LDA !SS_INPUT_CUR : CMP !SAVE_INPUTS : BNE +
    AND !SS_INPUT_NEW : BEQ +
    JSL save_state
    SEC : BRA .done

    ; check for loadstate inputs
+   LDA !SS_INPUT_CUR : CMP !LOAD_INPUTS : BNE +
    AND !SS_INPUT_NEW : BEQ +
    JSL load_state
    SEC : BRA .done

    ; exit carry clear to continue normal gameplay
+   CLC

  .done
    %ai16()
    LDA $0998 : AND #$00FF
    PLB
    RTL
}
print pc, " gamemode end"


; ---------
; Save/Load
; ---------

SaveASM:
print pc, " save start"
; These can be modified to do game-specific things before and after saving and loading
; Both A and X/Y are 16-bit here

; SM specific features to restore the correct music when loading a state below
pre_load_state:
    LDA !MUSIC_BANK : STA !SRAM_MUSIC_BANK
    LDA !MUSIC_TRACK : STA !SRAM_MUSIC_TRACK

    ; Rerandomize
if !RERANDOMIZE
    LDA !sram_save_has_set_rng : BNE +
    LDA $05E5 : STA $770080
    LDA $05B6 : STA $770082
endif
+   RTS

post_load_state:
    ; If $05F5 is non-zero, the game won't clear the sounds
    LDA $05F5 : PHA
    STZ $05F5

;    JSL $82BE17 ; Cancel sound effects
    LDA.W #$0002
    JSL $809049
    LDA.W #$0071
    JSL $8090CB
    LDA.W #$0001
    JSL $80914D

    PLA : STA $05F5

    ; Makes the game check Samus' health again, to see if we need annoying sound
    LDA #$0000 : STA $0A6A

    LDA !SRAM_MUSIC_BANK : CMP !MUSIC_BANK : BNE music_load_bank
    LDA !SRAM_MUSIC_TRACK : CMP !MUSIC_TRACK : BNE music_load_track
    BRA music_done

music_load_bank:
    LDA #$FF00 : CLC : ADC !MUSIC_BANK
    JSL !MUSIC_ROUTINE

music_load_track:
    LDA !MUSIC_TRACK
    JSL !MUSIC_ROUTINE

music_done:
    ; Rerandomize
if !RERANDOMIZE
    LDA !sram_save_has_set_rng : BNE +
    LDA $770080 : STA $05E5
    LDA $770082 : STA $05B6
endif
+   RTS


; These restored registers are game-specific and needs to be updated for different games
register_restore_return:
    %a8()
    LDA $84 : STA $4200
    LDA #$0F : STA $13 : STA $2100
    RTL

save_state:
    PEA $0000
    PLB : PLB

    ; Store DMA registers to SRAM
    %a8()
    LDY #$0000 : TYX

save_dma_regs:
    LDA $4300,X : STA !SRAM_DMA_BANK,X
    INX : INY
    CPY #$000B : BNE save_dma_regs
    CPX #$007B : BEQ save_dma_regs_done
    INX #5 : LDY #$0000
    BRA save_dma_regs

save_dma_regs_done:
    %ai16()
    LDX #save_write_table

run_vm:
    PHK : PLB
    JMP vm

save_write_table:
    ; Turn PPU off
    dw $1000|$2100, $80
    dw $1000|$4200, $00
    ; Single address, B bus -> A bus.  B address = reflector to WRAM ($2180).
    dw $0000|$4310, $8080  ; direction = B->A, byte reg, B addr = $2180
    ; Copy WRAM 7E0000-7E7FFF to SRAM 710000-717FFF.
    dw $0000|$4312, $0000  ; A addr = $xx0000
    dw $0000|$4314, $0071  ; A addr = $71xxxx, size = $xx00
    dw $0000|$4316, $0080  ; size = $80xx ($8000), unused bank reg = $00.
    dw $0000|$2181, $0000  ; WRAM addr = $xx0000
    dw $1000|$2183, $00    ; WRAM addr = $7Exxxx  (bank is relative to $7E)
    dw $1000|$420B, $02    ; Trigger DMA on channel 1
    ; Copy WRAM 7E8000-7EFFFF to SRAM 720000-727FFF.
    dw $0000|$4312, $0000  ; A addr = $xx0000
    dw $0000|$4314, $0072  ; A addr = $72xxxx, size = $xx00
    dw $0000|$4316, $0080  ; size = $80xx ($8000), unused bank reg = $00.
    dw $0000|$2181, $8000  ; WRAM addr = $xx8000
    dw $1000|$2183, $00    ; WRAM addr = $7Exxxx  (bank is relative to $7E)
    dw $1000|$420B, $02    ; Trigger DMA on channel 1
    ; Copy WRAM 7F0000-7F7FFF to SRAM 730000-737FFF.
    dw $0000|$4312, $0000  ; A addr = $xx0000
    dw $0000|$4314, $0073  ; A addr = $73xxxx, size = $xx00
    dw $0000|$4316, $0080  ; size = $80xx ($8000), unused bank reg = $00.
    dw $0000|$2181, $0000  ; WRAM addr = $xx0000
    dw $1000|$2183, $01    ; WRAM addr = $7Fxxxx  (bank is relative to $7E)
    dw $1000|$420B, $02    ; Trigger DMA on channel 1
    ; Copy WRAM 7F8000-7FFFFF to SRAM 740000-747FFF.
    dw $0000|$4312, $0000  ; A addr = $xx0000
    dw $0000|$4314, $0074  ; A addr = $74xxxx, size = $xx00
    dw $0000|$4316, $0080  ; size = $80xx ($8000), unused bank reg = $00.
    dw $0000|$2181, $8000  ; WRAM addr = $xx8000
    dw $1000|$2183, $01    ; WRAM addr = $7Fxxxx  (bank is relative to $7E)
    dw $1000|$420B, $02    ; Trigger DMA on channel 1
    ; Address pair, B bus -> A bus.  B address = VRAM read ($2139).
    dw $0000|$4310, $3981  ; direction = B->A, word reg, B addr = $2139
    dw $1000|$2115, $0000  ; VRAM address increment mode.
    ; Copy VRAM 0000-7FFF to SRAM 750000-757FFF.
    dw $0000|$2116, $0000  ; VRAM address >> 1.
    dw $9000|$2139, $0000  ; VRAM dummy read.
    dw $0000|$4312, $0000  ; A addr = $xx0000
    dw $0000|$4314, $0075  ; A addr = $75xxxx, size = $xx00
    dw $0000|$4316, $0080  ; size = $80xx ($0000), unused bank reg = $00.
    dw $1000|$420B, $02    ; Trigger DMA on channel 1
    ; Copy VRAM 8000-7FFF to SRAM 760000-767FFF.
    dw $0000|$2116, $4000  ; VRAM address >> 1.
    dw $9000|$2139, $0000  ; VRAM dummy read.
    dw $0000|$4312, $0000  ; A addr = $xx0000
    dw $0000|$4314, $0076  ; A addr = $76xxxx, size = $xx00
    dw $0000|$4316, $0080  ; size = $80xx ($0000), unused bank reg = $00.
    dw $1000|$420B, $02    ; Trigger DMA on channel 1
    ; Copy CGRAM 000-1FF to SRAM 772000-7721FF.
    dw $1000|$2121, $00    ; CGRAM address
    dw $0000|$4310, $3B80  ; direction = B->A, byte reg, B addr = $213B
    dw $0000|$4312, $2000  ; A addr = $xx2000
    dw $0000|$4314, $0077  ; A addr = $77xxxx, size = $xx00
    dw $0000|$4316, $0002  ; size = $02xx ($0200), unused bank reg = $00.
    dw $1000|$420B, $02    ; Trigger DMA on channel 1
    ; Done
    dw $0000, save_return

save_return:
    PEA $0000
    PLB : PLB

    %ai16()
    LDA !ram_room_has_set_rng : STA !sram_save_has_set_rng

    TSC : STA !SRAM_SAVED_SP
    JMP register_restore_return


load_state:
    JSR pre_load_state
    PEA $0000
    PLB : PLB

    %a8()
    LDX #load_write_table
    JMP run_vm

load_write_table:
    ; Disable HDMA
    dw $1000|$420C, $00
    ; Turn PPU off
    dw $1000|$2100, $80
    dw $1000|$4200, $00
    ; Single address, A bus -> B bus.  B address = reflector to WRAM ($2180).
    dw $0000|$4310, $8000  ; direction = A->B, B addr = $2180
    ; Copy SRAM 710000-717FFF to WRAM 7E0000-7E7FFF.
    dw $0000|$4312, $0000  ; A addr = $xx0000
    dw $0000|$4314, $0071  ; A addr = $71xxxx, size = $xx00
    dw $0000|$4316, $0080  ; size = $80xx ($8000), unused bank reg = $00.
    dw $0000|$2181, $0000  ; WRAM addr = $xx0000
    dw $1000|$2183, $00    ; WRAM addr = $7Exxxx  (bank is relative to $7E)
    dw $1000|$420B, $02    ; Trigger DMA on channel 1
    ; Copy SRAM 720000-727FFF to WRAM 7E8000-7EFFFF.
    dw $0000|$4312, $0000  ; A addr = $xx0000
    dw $0000|$4314, $0072  ; A addr = $72xxxx, size = $xx00
    dw $0000|$4316, $0080  ; size = $80xx ($8000), unused bank reg = $00.
    dw $0000|$2181, $8000  ; WRAM addr = $xx8000
    dw $1000|$2183, $00    ; WRAM addr = $7Exxxx  (bank is relative to $7E)
    dw $1000|$420B, $02    ; Trigger DMA on channel 1
    ; Copy SRAM 730000-737FFF to WRAM 7F0000-7F7FFF.
    dw $0000|$4312, $0000  ; A addr = $xx0000
    dw $0000|$4314, $0073  ; A addr = $73xxxx, size = $xx00
    dw $0000|$4316, $0080  ; size = $80xx ($8000), unused bank reg = $00.
    dw $0000|$2181, $0000  ; WRAM addr = $xx0000
    dw $1000|$2183, $01    ; WRAM addr = $7Fxxxx  (bank is relative to $7E)
    dw $1000|$420B, $02    ; Trigger DMA on channel 1
    ; Copy SRAM 740000-747FFF to WRAM 7F8000-7FFFFF.
    dw $0000|$4312, $0000  ; A addr = $xx0000
    dw $0000|$4314, $0074  ; A addr = $74xxxx, size = $xx00
    dw $0000|$4316, $0080  ; size = $80xx ($8000), unused bank reg = $00.
    dw $0000|$2181, $8000  ; WRAM addr = $xx8000
    dw $1000|$2183, $01    ; WRAM addr = $7Fxxxx  (bank is relative to $7E)
    dw $1000|$420B, $02    ; Trigger DMA on channel 1
    ; Address pair, A bus -> B bus.  B address = VRAM write ($2118).
    dw $0000|$4310, $1801  ; direction = A->B, B addr = $2118
    dw $1000|$2115, $0000  ; VRAM address increment mode.
    ; Copy SRAM 750000-757FFF to VRAM 0000-7FFF.
    dw $0000|$2116, $0000  ; VRAM address >> 1.
    dw $0000|$4312, $0000  ; A addr = $xx0000
    dw $0000|$4314, $0075  ; A addr = $75xxxx, size = $xx00
    dw $0000|$4316, $0080  ; size = $80xx ($0000), unused bank reg = $00.
    dw $1000|$420B, $02    ; Trigger DMA on channel 1
    ; Copy SRAM 760000-767FFF to VRAM 8000-7FFF.
    dw $0000|$2116, $4000  ; VRAM address >> 1.
    dw $0000|$4312, $0000  ; A addr = $xx0000
    dw $0000|$4314, $0076  ; A addr = $76xxxx, size = $xx00
    dw $0000|$4316, $0080  ; size = $80xx ($0000), unused bank reg = $00.
    dw $1000|$420B, $02    ; Trigger DMA on channel 1
    ; Copy SRAM 772000-7721FF to CGRAM 000-1FF.
    dw $1000|$2121, $00    ; CGRAM address
    dw $0000|$4310, $2200  ; direction = A->B, byte reg, B addr = $2122
    dw $0000|$4312, $2000  ; A addr = $xx2000
    dw $0000|$4314, $0077  ; A addr = $77xxxx, size = $xx00
    dw $0000|$4316, $0002  ; size = $02xx ($0200), unused bank reg = $00.
    dw $1000|$420B, $02    ; Trigger DMA on channel 1
    ; Done
    dw $0000, load_return

load_return:
    %ai16()
    LDA !SRAM_SAVED_SP : TCS

    PEA $0000
    PLB : PLB

    ; rewrite inputs so that holding load won't keep loading, as well as rewriting saving input to loading input
    LDA !SS_INPUT_CUR : EOR !SAVE_INPUTS : ORA !LOAD_INPUTS
    STA !SS_INPUT_CUR : STA !SS_INPUT_NEW : STA !SS_INPUT_PREV

    %a8()
    LDX #$0000 : TXY

load_dma_regs:
    LDA !SRAM_DMA_BANK,X
    STA $4300,X
    INX : INY
    CPY #$000B : BNE load_dma_regs
    CPX #$007B : BEQ load_dma_regs_done
    INX #5 : LDY #$0000
    JMP load_dma_regs

load_dma_regs_done:
    ; Restore registers and return.
    %ai16()
    JSR post_load_state
    JMP register_restore_return

vm:
    ; Data format: xx xx yy yy
    ; xxxx = little-endian address to write to .vm's bank
    ; yyyy = little-endian value to write
    ; If xxxx has high bit set, read and discard instead of write.
    ; If xxxx has bit 12 set ($1000), byte instead of word.
    ; If yyyy has $DD in the low half, it means that this operation is a byte
    ; write instead of a word write.  If xxxx is $0000, end the VM.
    %ai16()
    ; Read address to write to
    LDA.w $0000,X : BEQ vm_done
    TAY
    INX #2
    ; Check for byte mode
    BIT.w #$1000 : BEQ vm_word_mode
    AND.w #$EFFF : TAY
    %a8()
vm_word_mode:
    ; Read value
    LDA.w $0000,X
    INX #2
vm_write:
    ; Check for read mode (high bit of address)
    CPY.w #$8000 : BCS vm_read
    STA $0000,Y
    BRA vm
vm_read:
    ; "Subtract" $8000 from Y by taking advantage of bank wrapping.
    LDA $8000,Y
    BRA vm

vm_done:
    ; A, X and Y are 16-bit at exit.
    ; Return to caller.  The word in the table after the terminator is the
    ; code address to return to.
    JMP ($0002,x)

print pc, " save end"


; -----------
; RNG Seeders
; -----------

if !RERANDOMIZE
pushpc

; Don't rerandomize if enemy seeds RNG
org $A3AB12
    JSL hook_hopper_set_rng

org $A2B588
    JSL hook_lavarocks_set_rng
    NOP #2

org $A8B798
    JSL hook_beetom_set_rng
    NOP #2

pullpc

print pc, " rng start"
hook_hopper_set_rng:
    LDA #$0001 : STA !ram_room_has_set_rng
    JML $808111

hook_lavarocks_set_rng:
    LDA #$0001 : STA !ram_room_has_set_rng
    LDA #$0011 : STA $05E5
    RTL

hook_beetom_set_rng:
    LDA #$0001 : STA !ram_room_has_set_rng
    LDA #$0017 : STA $05E5
    RTL
print pc, " rng end"
endif
endif

pushpc
; hijack, runs as game is starting, JSR to RAM initialization to avoid bad values
org $808455
    JSL init_code
pullpc


print pc, " init start"
init_code:
    %ai16()
    PHA
    LDA #$0000
if !SAVESTATES
    STA !sram_save_has_set_rng : STA !ram_room_has_set_rng
endif
    STA !ram_realtime_room : STA !ram_transition_flag
    STA !ram_transition_counter : STA !ram_last_room_lag
    STA !ram_last_realtime_room : STA !ram_last_realtime_door
    STA !ram_last_door_lag_frames : STA !ram_lag_counter
    PLA
    JML $9585F4 ; overwritten code
print pc, " init end"


pushpc
org $8095FC ; hijack, runs at the end of NMI
    JML ih_nmi_end

org $9493B8 ; hijack, runs when Samus hits a door BTS
    JSL ih_before_room_transition

org $9493FB ; hijack, runs when Samus hits a door BTS
    JSL ih_before_room_transition

org $8A9141 ; hijack, runs when Samus is coming out of a room transition
    JML ih_after_room_transition

org $8A800F
    JSL ih_game_loop_code
pullpc


print pc, " timer start"
ih_nmi_end:
{
    LDA !ram_realtime_room : INC : STA !ram_realtime_room

    PLY : PLX : PLA : PLD : PLB
    RTI
}

ih_game_loop_code:
{
    ; inc transition timer
    LDA !ram_transition_counter : INC : STA !ram_transition_counter

    ; overwritten code + return
    JML $808111
}

ih_before_room_transition:
{
    ; overwritten code
    STA $0998

    ; Check if we've already run on this frame
    LDA !ram_transition_flag : BNE .done

    ; Lag
    LDA !ram_realtime_room : SEC : SBC !ram_transition_counter : STA !ram_last_room_lag

    ; Room timers
    LDA !ram_realtime_room : STA !ram_last_realtime_room

    ; Reset variables
    LDA #$0000 : STA !ram_transition_counter
    STA !ram_realtime_room : STA !ram_last_realtime_door
if !SAVESTATES
    STA !ram_room_has_set_rng
endif
    LDA #$0001 : STA !ram_transition_flag

    JSR ih_update_hud_code

  .done
    CLC
    RTL
}

ih_after_room_transition:
{
    ; overwritten code
    LDA #$0008 : STA $0998

    ; update last door times
    LDA !ram_transition_counter : STA !ram_last_door_lag_frames
    LDA !ram_realtime_room : STA !ram_last_realtime_door

    ; clear transition variables
    LDA #$0000 : STA !ram_transition_flag : STA !ram_lag_counter

    JSR ih_update_hud_code

    ; Reset realtime and gametime/transition timers
    LDA #$0000 : STA !ram_realtime_room : STA !ram_transition_counter

    JML $8A9117
}

ih_update_hud_code:
{
    PHB
    PHK : PLB

    LDX #$0094

    ; Divide time by 60 or 50 and draw seconds and frames
    LDA !ram_last_realtime_room : STA $4204
    %a8()
    LDA.b #$3C : STA $4206
    %a16()
    PEA $0000 : PLA ; wait for CPU math
    LDA $4216 : STA $C1
    LDA $4214 : JSR Draw3
    LDA $C1 : ASL : TAY
    LDA.w HexToNumberGFX1,Y : STA !HUD_TILEMAP+$02,X
    LDA.w HexToNumberGFX2,Y : STA !HUD_TILEMAP+$04,X
    LDA #!HUD_DECIMAL : STA !HUD_TILEMAP,X

    ; Lag
    LDA !ram_last_room_lag : LDX #$00D4 : JSR Draw3

    ; Door lag / transition time
    LDA !ram_last_door_lag_frames
    LDX #$00DC : JSR Draw2

    PLB
    RTS
}

Draw2:
{
    STA $4204
    %a8()
    LDA #$0A : STA $4206 ; divide by 10
    %a16()
    PEA $0000 : PLA ; wait for CPU math
    LDA $4214 : STA $16

    ; Ones digit
    LDA $4216 : ASL : TAY : LDA.w NumberGFXTable,Y : STA !HUD_TILEMAP+$02,X

    ; Tens digit
    LDA $16 : BEQ .blanktens
    ASL : TAY
    LDA.w NumberGFXTable,Y : STA !HUD_TILEMAP+$00,X

  .done
    INX #4
    RTS

  .blanktens
    LDA #!IH_BLANK : STA !HUD_TILEMAP+$00,X
    BRA .done
}

Draw3:
{
    STA $4204
    %a8()
    LDA #$0A : STA $4206 ; divide by 10
    %a16()
    PEA $0000 : PLA ; wait for CPU math
    LDA $4214 : STA $16

    ; Ones digit
    LDA $4216 : ASL : TAY
    LDA.w NumberGFXTable,Y : STA !HUD_TILEMAP+$04,X

    LDA $16 : BEQ .blanktens
    STA $4204
    %a8()
    LDA #$0A : STA $4206 ; divide by 10
    %a16()
    PEA $0000 : PLA ; wait for CPU math
    LDA $4214 : STA $14

    ; Tens digit
    LDA $4216 : ASL : TAY
    LDA.w NumberGFXTable,Y : STA !HUD_TILEMAP+$02,X

    ; Hundreds digit
    LDA $14 : BEQ .blankhundreds
    ASL : TAY
    LDA.w NumberGFXTable,Y : STA !HUD_TILEMAP+$00,X

  .done
    INX #6
    RTS

  .blanktens
    LDA #!IH_BLANK : STA !HUD_TILEMAP+$00,X : STA !HUD_TILEMAP+$02,X
    BRA .done

  .blankhundreds
    LDA #!IH_BLANK : STA !HUD_TILEMAP+$00,X
    BRA .done
}

NumberGFXTable:
    dw !HUD_0, !HUD_1, !HUD_2, !HUD_3, !HUD_4, !HUD_5, !HUD_6, !HUD_7, !HUD_8, !HUD_9

HexToNumberGFX1:
    dw !HUD_0r, !HUD_0r, !HUD_0r, !HUD_0r, !HUD_0r, !HUD_0r, !HUD_0r, !HUD_0r, !HUD_0r, !HUD_0r
    dw !HUD_1r, !HUD_1r, !HUD_1r, !HUD_1r, !HUD_1r, !HUD_1r, !HUD_1r, !HUD_1r, !HUD_1r, !HUD_1r
    dw !HUD_2r, !HUD_2r, !HUD_2r, !HUD_2r, !HUD_2r, !HUD_2r, !HUD_2r, !HUD_2r, !HUD_2r, !HUD_2r
    dw !HUD_3r, !HUD_3r, !HUD_3r, !HUD_3r, !HUD_3r, !HUD_3r, !HUD_3r, !HUD_3r, !HUD_3r, !HUD_3r
    dw !HUD_4r, !HUD_4r, !HUD_4r, !HUD_4r, !HUD_4r, !HUD_4r, !HUD_4r, !HUD_4r, !HUD_4r, !HUD_4r
    dw !HUD_5r, !HUD_5r, !HUD_5r, !HUD_5r, !HUD_5r, !HUD_5r, !HUD_5r, !HUD_5r, !HUD_5r, !HUD_5r

HexToNumberGFX2:
    dw !HUD_0, !HUD_1, !HUD_2, !HUD_3, !HUD_4, !HUD_5, !HUD_6, !HUD_7, !HUD_8, !HUD_9
    dw !HUD_0, !HUD_1, !HUD_2, !HUD_3, !HUD_4, !HUD_5, !HUD_6, !HUD_7, !HUD_8, !HUD_9
    dw !HUD_0, !HUD_1, !HUD_2, !HUD_3, !HUD_4, !HUD_5, !HUD_6, !HUD_7, !HUD_8, !HUD_9
    dw !HUD_0, !HUD_1, !HUD_2, !HUD_3, !HUD_4, !HUD_5, !HUD_6, !HUD_7, !HUD_8, !HUD_9
    dw !HUD_0, !HUD_1, !HUD_2, !HUD_3, !HUD_4, !HUD_5, !HUD_6, !HUD_7, !HUD_8, !HUD_9
    dw !HUD_0, !HUD_1, !HUD_2, !HUD_3, !HUD_4, !HUD_5, !HUD_6, !HUD_7, !HUD_8, !HUD_9
print pc, " timer end"

cleartable

org $80FF10
    db "This hack was hacked by InsaneFirebat without Meta's consent."

org $80FFA0
    db "Blame mm2"
