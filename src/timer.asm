
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


%startfree(8B)
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

    JSL MagicPants

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

    JSL ih_update_hud_code

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

    JSL ih_update_hud_code

    ; Reset realtime and gametime/transition timers
    LDA #$0000 : STA !ram_realtime_room : STA !ram_transition_counter

    JML $8A9117
}

ih_update_hud_code:
{
    PHB
    PHK : PLB

    ; Divide time by 60 and draw seconds and frames
    LDA !ram_last_realtime_room : STA $4204
    %a8()
    LDA.b #$3C : STA $4206
    %a16()
    PEA $0000 : PLA ; wait for CPU math
    LDA $4216 : STA $C1
    LDA $4214
    LDX #$0098 : JSR Draw2
    LDA $C1 : ASL : TAY
    LDA.w HexToNumberGFX1,Y : STA !HUD_TILEMAP+$00,X
    LDA.w HexToNumberGFX2,Y : STA !HUD_TILEMAP+$02,X
;    LDA #!HUD_DECIMAL : STA !HUD_TILEMAP,X

    ; Lag
    LDA !ram_last_room_lag
    LDX #$00D4 : JSR Draw3

    ; Door lag / transition time
    LDA !ram_last_door_lag_frames
    LDX #$00DC : JSR Draw2

    PLB
    RTL
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
    LDA $4216 : ASL : TAY
    LDA.w NumberGFXTable,Y : STA !HUD_TILEMAP+$02,X

    ; Tens digit
    LDA $16 : BEQ .blanktens
    ASL : TAY
    LDA.w NumberGFXTable,Y : STA !HUD_TILEMAP+$00,X

  .done
    INX #4
    RTS

  .blanktens
    LDA !IH_BLANK : STA !HUD_TILEMAP+$00,X
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
    LDA $4214 : STA $16

    ; Tens digit
    LDA $4216 : ASL : TAY
    LDA.w NumberGFXTable,Y : STA !HUD_TILEMAP+$02,X

    ; Hundreds digit
    LDA $16 : BEQ .blankhundreds
    ASL : TAY
    LDA.w NumberGFXTable,Y : STA !HUD_TILEMAP+$00,X

  .done
    TXA : CLC : ADC #$0006 : TAX
    RTS

  .blanktens
    LDA !IH_BLANK : STA !HUD_TILEMAP+$00,X : STA !HUD_TILEMAP+$02,X
    BRA .done

  .blankhundreds
    LDA !IH_BLANK : STA !HUD_TILEMAP+$00,X
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
    dw !HUD_0l, !HUD_1l, !HUD_2l, !HUD_3l, !HUD_4l, !HUD_5l, !HUD_6l, !HUD_7l, !HUD_8l, !HUD_9l
    dw !HUD_0l, !HUD_1l, !HUD_2l, !HUD_3l, !HUD_4l, !HUD_5l, !HUD_6l, !HUD_7l, !HUD_8l, !HUD_9l
    dw !HUD_0l, !HUD_1l, !HUD_2l, !HUD_3l, !HUD_4l, !HUD_5l, !HUD_6l, !HUD_7l, !HUD_8l, !HUD_9l
    dw !HUD_0l, !HUD_1l, !HUD_2l, !HUD_3l, !HUD_4l, !HUD_5l, !HUD_6l, !HUD_7l, !HUD_8l, !HUD_9l
    dw !HUD_0l, !HUD_1l, !HUD_2l, !HUD_3l, !HUD_4l, !HUD_5l, !HUD_6l, !HUD_7l, !HUD_8l, !HUD_9l
    dw !HUD_0l, !HUD_1l, !HUD_2l, !HUD_3l, !HUD_4l, !HUD_5l, !HUD_6l, !HUD_7l, !HUD_8l, !HUD_9l
print pc, " timer end"
%endfree(8B)
