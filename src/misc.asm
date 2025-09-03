

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
    LDA !ram_magic_pants_sfx : BEQ +
    %sfxbeep()
+   LDA #$FFFF : STA $7EC19E : STA !ram_magic_pants_state
    RTL
}
%endfree(8B)


; label for HUD graphics
org $82C60C
hudgfx_bin:


; Skips the waiting time after teleporting
org $90E877
NoLoadAnimation:
    LDA !MUSIC_TRACK
    JSL $808FC1 ; queue room music track
    BRA .skip

org $90E898
  .skip


; Critical energy alarm
org $90EA7F
    JMP CriticalEnergyAlarm
CriticalEnergyAlarm_return:

%startfree(90)
CriticalEnergyAlarm:
{
    LDA !sram_energyalarm : BNE .noBeep
    LDA !MUSIC_BANK ; overwritten code
    JMP .return

  .noBeep
    LDA !SAMUS_HP : CMP #$001F : BMI ..enable
    STZ $0A6A
    RTS

  ..enable
    LDA #$0001 : STA $0A6A
    RTS
}
%endfree(90)


; Music toggle
org $808F24
    JSL hook_set_music_track
    BRA $00

org $808F65
    JML hook_set_music_data

org $849D0C
    JSL EnergyCap
    BRA $00


%startfree(80)
hook_set_music_track:
{
    STZ $07F6
    PHA
    LDA !sram_music_toggle : CMP #$01 : BNE .no_music
    PLA : STA $2140
    RTL

  .no_music
    PLA
    RTL
}

hook_set_music_data:
{
    STA $07F3 : TAX
    LDA !sram_music_toggle : CMP #$0002 : BEQ .fast_no_music
    JML $808F69

  .fast_no_music
    JML $808F89
}

EnergyCap:
{
    LDA $09EA : CMP #$0002 : BEQ .hard
    LDA #$0064 : CLC : ADC $09C4
    CMP #$05DB : BEQ .store
    BMI .store
    LDA #$05DB : BRA .store

  .hard
    LDA #$0019 : CLC : ADC $09C4
    CMP #$01C1 : BEQ .store
    BMI .store
    LDA #$01C1

  .store
    STA $09C4 : STA $09C2
    RTL
}

transfer_cgram_long:
{
    LDX #$80 : STX $2100
    JSR $933A
    LDX #$0F : STX $2100
    RTL
}
%endfree(80)


if 0 ; commented out because unused
; Rewrite load station lists so we can add our own
; 43/151 used
org $80C4B5
LoadStationLists:
    dw .mainDeck, .SRX, .TRO, .PYR, .AQA, .ARC, .NOC, .DMX

;        ___________________________________________ Room pointer
;       |       ____________________________________ Door pointer
;       |      |       _____________________________ Door BTS
;       |      |      |       ______________________ Screen X position
;       |      |      |      |       _______________ Screen Y position
;       |      |      |      |      |       ________ Samus Y offset (relative to screen top)
;       |      |      |      |      |      |       _ Samus X offset (relative to screen centre)
;       |      |      |      |      |      |      |
  .mainDeck
    dw $8000, $91E4, $0000, $0000, $0000, $00A1, $0020 ; $00 - Crew Quarters
    dw $803D, $8F80, $0000, $0000, $0000, $00A1, $FFE0 ; $01 - Central Nexus
    dw $807A, $9328, $0000, $0000, $0000, $00A1, $0000 ; $02 - Yakuza Arena

  .SRX
    dw $8B5A, $9400, $0000, $0100, $0000, $00B0, $0000 ; $00 - Revival Room
    dw $8B5A, $9400, $0000, $0100, $0000, $00B0, $0000 ; $01 - Revival Room
    dw $8B5A, $9400, $0000, $0000, $0000, $00B0, $0010 ; $02 - Revival Room (right)
    dw $8B5A, $9400, $0000, $0200, $0000, $00B0, $FFF0 ; $03 - Revival Room (left)
    dw $8A2F, $9664, $0000, $0000, $0000, $00A1, $FFE0 ; $04 - Twin Junctions West
    dw $8A52, $95C8, $0000, $0000, $0000, $00A1, $FFE0 ; $05 - Twin Junctions East
    dw $8A90, $9850, $0000, $0000, $0000, $00A1, $0020 ; $06 - East Spike Tower
    dw $8A52, $95C8, $0000, $0000, $0000, $00B0, $FFE0 ; $07 - Twin Junctions East (autosave)

  .TRO
    dw $932D, $9D90, $0000, $0000, $0000, $00A1, $0020 ; $00 - Cloister
    dw $9350, $9A30, $0000, $0000, $0000, $00A1, $FFE0 ; $01 - Cultivation Station
    dw $9373, $9BF8, $0000, $0000, $0000, $00A1, $0000 ; $02 - Crum-Ball Tower

  .PYR
    dw $9C22, $9F34, $0000, $0000, $0000, $00A1, $0020 ; $00 - Entrance Lobby
    dw $9C45, $A0B4, $0000, $0000, $0000, $00A1, $FFE0 ; $01 - Big Red
    dw $9C68, $A1C8, $0000, $0000, $0000, $00A1, $FFE0 ; $02 - Bubble Heights
    dw $9C8B, $A3CC, $0000, $0000, $0000, $00A1, $0000 ; $03 - Neo-Ridley Gauntlet Access

  .AQA
    dw $A47A, $A5B8, $0000, $0000, $0000, $00A1, $FFE0 ; $00 - Reservoir Vault
    dw $A49D, $A75C, $0000, $0000, $0000, $00A1, $0000 ; $01 - Sciser Shaft
    dw $A4C0, $A8F4, $0000, $0000, $0000, $00A1, $0000 ; $02 - Buoyant Bridge
    dw $A4E3, $AB40, $0000, $0000, $0000, $00A1, $0000 ; $03 - Neo-Draygon Access
    dw $A506, $AABC, $0000, $0000, $0000, $00A1, $0020 ; $04 - Glass Tube

  .ARC
    dw $AEB0, $AD80, $0000, $0000, $0000, $00A1, $FFE0 ; $00 - North Blue Tower
    dw $AEEE, $ACB4, $0000, $0000, $0000, $00A1, $0000 ; $01 - South Blue Tower
    dw $AF2C, $B038, $0000, $0000, $0000, $00A1, $FFE0 ; $02 - Cellar
    dw $AF4F, $B140, $0000, $0000, $0000, $00A1, $0000 ; $03 - Freezer Hallway

  .NOC
    dw $B737, $B1F4, $0000, $0000, $0000, $00A1, $0000 ; $00 - Entrance Lobby North
    dw $B75A, $B3F8, $0000, $0000, $0000, $00A1, $0000 ; $01 - East Turbo Tube Access
    dw $B77D, $B6E0, $0000, $0000, $0000, $00A1, $0020 ; $02 - Warehouse
    dw $B7A0, $B50C, $0000, $0000, $0000, $00A1, $0020 ; $03 - Entrance Lobby South
    dw $BCE8, $B698, $0000, $0000, $0000, $00A1, $0020 ; $04 - Catacombs

  .DMX
    dw $BFB0, $B7DC, $0000, $0000, $0200, $0090, $0050 ; $00 - Xenometroid Birthplace
    dw $C13C, $B86C, $0004, $0000, $0000, $0090, $0050 ; $01 - Serpentine Break
    dw $C182, $B884, $0004, $0000, $0100, $0090, $FFB0 ; $02 - Metroid Chase with Dev Exit
    dw $C1EB, $B8B4, $0004, $0000, $0000, $0090, $FFB0 ; $03 - SA-X Hallway of Death (left)
    dw $C254, $B950, $0000, $0000, $0000, $0090, $0000 ; $04 - DMX Elevator Top
    dw $C29A, $B908, $0000, $0100, $0000, $0090, $0050 ; $05 - Winding SA-X Chase
    dw $C326, $B944, $0004, $0300, $0000, $00A0, $0048 ; $06 - Golden Four Containment
    dw $BF8D, $B968, $0000, $0000, $0100, $0090, $FFB0 ; $07 - Ventilation B
    dw $C0F6, $B854, $0000, $0000, $0000, $0090, $0048 ; $08 - Omega Queen
    dw $C2E0, $B92C, $0000, $0000, $0000, $00A0, $0030 ; $09 - Hornoad Sewer
    dw $C1EB, $B8B4, $0000, $0400, $0000, $0090, $0030 ; $0A - SA-X Hallway of Death (right)

warnpc $80CD07
endif


cleartable
org $80FF10
    db "This hack was hacked by InsaneFirebat without Meta's consent."

org $80FFA0
    db "Blame mm2"
