
!SAMUS_MOVEMENT_TYPE = $0A1F
!SAMUS_ANIMATION_FRAME = $0A96
!ram_magic_pants_state = !WRAM_START+$12
!ram_magic_pants_pal1 = !WRAM_START+$14
!ram_magic_pants_pal2 = !WRAM_START+$16
!ram_magic_pants_pal3 = !WRAM_START+$18

%startfree(8B)
MagicPants:
{
    LDA $0A96 : CMP #$0009 : BEQ .check
    LDA !ram_magic_pants_state : BEQ +
    LDA !ram_magic_pants_pal1 : STA $7EC188
    LDA !ram_magic_pants_pal2 : STA $7EC18A
    LDA !ram_magic_pants_pal3 : STA $7EC19E
    LDA #$0000 : STA !ram_magic_pants_state
+   RTL

  .check
    LDA $0A1C : CMP #$0009 : BEQ .flash
    CMP #$000A : BEQ .flash
    RTL

  .flash
    LDA !ram_magic_pants_state : BNE +
    LDA $7EC188 : STA !ram_magic_pants_pal1
    LDA $7EC18A : STA !ram_magic_pants_pal2
    LDA $7EC19E : STA !ram_magic_pants_pal3
+   LDA #$FFFF : STA $7EC19E : STA !ram_magic_pants_state
    RTL
}
%endfree(8B)


; label for HUD graphics
org $82C5DD
hudgfx_bin:


; Skips the waiting time after teleporting
org $90E877
NoLoadAnimation:
    LDA !MUSIC_TRACK
    JSL $808FC1 ; queue room music track
    BRA .skip

org $90E898
  .skip


%startfree(80)
transfer_cgram_long:
    JSR $933A
    RTL
%endfree(80)


;org $92D246
;; Repoint escape timer tiles
;EscapeTimerTiles:
;incbin ../resources/EscapeTimerTiles.bin
;
;pushpc
;org $A7B423
;    LDA.w #(EscapeTimerTiles>>8)&$FF00 : STA $00D3,Y
;    LDA.w #EscapeTimerTiles : STA $00D2,Y
;warnpc $A7B42F
;pullpc


cleartable
org $80FF10
    db "This hack was hacked by InsaneFirebat without Meta's consent."

org $80FFA0
    db "Blame mm2"