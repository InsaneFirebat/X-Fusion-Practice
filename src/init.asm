
; hijack, runs as game is starting, JSR to RAM initialization to avoid bad values
org $808455
    JSL init_code

%startfree(8B)
print pc, " init start"
init_code:
{
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

    JSL init_sram

  .done
    PLA
    JML $9585F4 ; overwritten code
}

init_sram:
{
    ; SRAM
    LDA !sram_safeword : CMP !SAFEWORD : BNE .init
    LDA !sram_initialized : CMP !SRAM_VERSION : BEQ .done

  .init
    LDA !SAFEWORD : STA !sram_safeword
    LDA !SRAM_VERSION : STA !sram_initialized
    LDA #$0000 : STA !sram_energyalarm
    LDA #$0001 : STA !sram_music_toggle

  .controller_shortcuts ; called by ctrl_reset_defaults in mainmenu.asm
    LDA #$3000 : STA !sram_ctrl_menu ; Select + Start
if !SAVESTATES
    LDA #$6010 : STA !sram_ctrl_save_state ; Select + Y + R
    LDA #$6020 : STA !sram_ctrl_load_state ; Select + Y + L
endif
    LDA #$0000 : STA !sram_ctrl_full_equipment
    LDA #$0000 : STA !sram_ctrl_kill_enemies
    LDA #$0000 : STA !sram_ctrl_update_timers
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

  .done
    RTL
}
print pc, " init end"
%endfree(8B)
