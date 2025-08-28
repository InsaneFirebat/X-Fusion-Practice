
; ------------
; Menu Helpers
; ------------

action_mainmenu:
{
    ; Set bank of new menu
    LDA !ram_cm_cursor_stack : TAX
    LDA.l MainMenuBanks,X : STA !ram_cm_menu_bank
    STA !DP_MenuIndices+2 : STA !DP_CurrentMenu+2

    ; continue into action_submenu
}

action_submenu:
{
    ; Increment stack pointer by 2, then store current menu
    LDA !ram_cm_stack_index : INC #2 : STA !ram_cm_stack_index : TAX
    TYA : STA !ram_cm_menu_stack,X

    ; Set cursor to top for new menus
    LDA #$0000 : STA !ram_cm_cursor_stack,X

    %sfxmove()
    JSL cm_calculate_max
    JSL cm_draw
    RTL
}


; -----------
; Main menu
; -----------

; MainMenu must exist in the same bank as the menu code.
; From here, submenus can branch out into different banks
; as long as all of its menu items and submenus are included.

MainMenu:
    dw #mm_goto_equipment
    dw #mm_goto_teleport
    dw #mm_goto_events
    dw #mm_goto_misc
    dw #mm_goto_gamemenu
    dw #mm_goto_ctrlsmenu
    dw #$0000
    %cm_version_header("SM PRACTICE HACK")
if !DEV
    %cm_footer("DEVELOPMENT BUILD")
endif

MainMenuBanks:
    dw #EquipmentMenu>>16
    dw #TeleportMenu>>16
    dw #EventsMenu>>16
    dw #MiscMenu>>16
    dw #GameMenu>>16
    dw #CtrlMenu>>16

mm_goto_equipment:
    %cm_mainmenu("Equipment", #EquipmentMenu)

mm_goto_teleport:
    %cm_mainmenu("Teleport", #TeleportMenu)

mm_goto_events:
    %cm_mainmenu("Events", #EventsMenu)

mm_goto_misc:
    %cm_mainmenu("Misc", #MiscMenu)

mm_goto_gamemenu:
    %cm_mainmenu("Game Options", #GameMenu)

mm_goto_ctrlsmenu:
    %cm_mainmenu("Controller Shortcuts", #CtrlMenu)


; ----------------
; Equipment menu
; ----------------

EquipmentMenu:
    dw #eq_refill
    dw #eq_toggle_category
    dw #eq_goto_toggleitems
    dw #eq_goto_togglebeams
    dw #$FFFF
    dw #eq_currentenergy
    dw #eq_setetanks
    dw #$FFFF
    dw #eq_energyreserves
    dw #eq_ammoreserves
    dw #eq_maxreserves
    dw #$FFFF
    dw #eq_currentmissiles
    dw #eq_setmissiles
    dw #$FFFF
    dw #eq_currentpbs
    dw #eq_setpbs
    dw #$0000
    %cm_header("EQUIPMENT")

eq_refill:
    %cm_jsl("Refill", .refill, #$0000)
  .refill
    LDA !SAMUS_HP_MAX : STA !SAMUS_HP
    LDA !SAMUS_MISSILES_MAX : STA !SAMUS_MISSILES
;    LDA !SAMUS_SUPERS_MAX : STA !SAMUS_SUPERS
    LDA !SAMUS_PBS_MAX : STA !SAMUS_PBS
    LDA $09D4 : STA $09EC : STA $09EE
    LDA #$0002 : JSL !SFX_LIB2 ; big energy pickup
    RTL

eq_toggle_category:
    %cm_submenu("Category Loadouts", #ToggleCategoryMenu)

eq_goto_toggleitems:
    %cm_jsl("Toggle Items", #eq_prepare_items_menu, #ToggleItemsMenu)

eq_goto_togglebeams:
    %cm_jsl("Toggle Beams", #eq_prepare_beams_menu, #ToggleBeamsMenu)

eq_currentenergy:
    %cm_numfield_word("Current Energy", !SAMUS_HP, 0, 1499, 1, 20, #0)

eq_setetanks:
    %cm_numfield("Energy Tanks", !ram_cm_etanks, 0, 14, 1, 1, .routine)
  .routine
    TAX : BEQ .zero
    LDA #$0000
    CPX #$000F : BPL .loop
    LDA #$0063
  .loop
    DEX : BMI .endloop
    CLC : ADC #$0064
    BRA .loop
  .zero
    LDA #$0063
  .endloop
    STA !SAMUS_HP_MAX : STA !SAMUS_HP
    RTL

eq_energyreserves:
    %cm_numfield("Energy Reserves", $09EC, 0, 7, 1, 1, #0)

eq_ammoreserves:
    %cm_numfield("Ammo Reserves", $09EE, 0, 7, 1, 1, #0)

eq_maxreserves:
    %cm_numfield("Max Reserves", $09D4, 0, 7, 1, 1, #0)

eq_currentmissiles:
    %cm_numfield_word("Current Missiles", !SAMUS_MISSILES, 5, 99, 1, 4, #0)

eq_setmissiles:
    %cm_numfield_word("Missiles", !SAMUS_MISSILES_MAX, 5, 99, 1, 4, .routine)
  .routine
    LDA !SAMUS_MISSILES_MAX : STA !SAMUS_MISSILES
    RTL

eq_currentpbs:
    %cm_numfield("Current Power Bombs", !SAMUS_PBS, 0, 50, 1, 5, #0)

eq_setpbs:
    %cm_numfield("Power Bombs", !SAMUS_PBS_MAX, 0, 50, 1, 5, .routine)
  .routine
    LDA !SAMUS_PBS_MAX : STA !SAMUS_PBS
    RTL


; ---------------------
; Toggle Category menu
; ---------------------

ToggleCategoryMenu:
    dw #cat_100
    dw #cat_nothing
;    dw #cat_any_new
;    dw #cat_any_old
;    dw #cat_14ice
;    dw #cat_14speed
;    dw #cat_gt_code
;    dw #cat_gt_max
;    dw #cat_rbo
;    dw #cat_any_glitched
;    dw #cat_inf_cf
    dw #$0000
    %cm_header("TOGGLE CATEGORY")

cat_100:
    %cm_jsl("100%", action_category, #$0000)

cat_nothing:
    %cm_jsl("Nothing", action_category, #$0001)

;cat_any_new:
;    %cm_jsl("Any% PRKD", action_category, #$0001)
;
;cat_any_old:
;    %cm_jsl("Any% KPDR", action_category, #$0002)
;
;cat_14ice:
;    %cm_jsl("14% Ice", action_category, #$0003)
;
;cat_14speed:
;    %cm_jsl("14% Speed", action_category, #$0004)
;
;cat_gt_code:
;    %cm_jsl("GT Code", action_category, #$0005)
;
;cat_gt_max:
;    %cm_jsl("GT Max%", action_category, #$0006)
;
;cat_rbo:
;    %cm_jsl("RBO", action_category, #$0007)
;
;cat_any_glitched:
;    %cm_jsl("Any% Glitched", action_category, #$0008)
;
;cat_inf_cf:
;    %cm_jsl("Infinite Crystal Flashes", action_category, #$0009)

action_category:
{
    TYA : ASL #4 : TAX

    LDA.l .table,X : STA !SAMUS_ITEMS_COLLECTED : STA !SAMUS_ITEMS_EQUIPPED : INX #2

    LDA.l .table,X : STA !SAMUS_BEAMS_COLLECTED : INX #2
    LDA.l .table,X : STA !SAMUS_BEAMS_EQUIPPED : INX #2
    LDA.l .table,X : STA !SAMUS_HP : STA !SAMUS_HP_MAX : INX #2
    LDA.l .table,X : STA !SAMUS_MISSILES : STA !SAMUS_MISSILES_MAX : INX #2
;    LDA.l .table,X : STA !SAMUS_SUPERS : STA !SAMUS_SUPERS_MAX : INX #2
    INX #2 ; Supers unused
    LDA.l .table,X : STA !SAMUS_PBS : STA !SAMUS_PBS_MAX : INX #2
    LDA.l .table,X : STA $09D4 : STA $09EC : STA $09EE : INX #2

;    JSL cm_set_etanks_and_reserve
    %sfxconfirm()
    JML $90AC8D ; update beam gfx

  .table
    ;  Items,  C Beam, E Beam, Health, Miss,   Supers, PBs,    Reserv
    dw #$FBBF, #$1007, #$1007, #$05DB, #$0063, #$0032, #$0032, #$0007 ; 100%
;    dw #$3125, #$1007, #$1007, #$018F, #$000F, #$000A, #$0005, #$0000 ; any% new
;    dw #$3325, #$100B, #$100B, #$018F, #$000F, #$000A, #$0005, #$0000 ; any% old
;    dw #$1025, #$1002, #$1002, #$018F, #$000A, #$000A, #$0005, #$0000 ; 14% ice
;    dw #$3025, #$1000, #$1000, #$018F, #$000A, #$000A, #$0005, #$0000 ; 14% speed
;    dw #$F33F, #$100F, #$100B, #$02BC, #$0064, #$0014, #$0014, #$012C ; gt code
;    dw #$F33F, #$100F, #$100B, #$0834, #$0145, #$0041, #$0041, #$02BC ; 135%
;    dw #$710C, #$1001, #$1001, #$031F, #$001E, #$0019, #$0014, #$0064 ; rbo
;    dw #$9004, #$0000, #$0000, #$00C7, #$0005, #$0005, #$0005, #$0000 ; any% glitched
;    dw #$F32F, #$100F, #$100B, #$0031, #$01A4, #$005A, #$0063, #$0000 ; crystal flash
    dw #$0000, #$0000, #$0000, #$0063, #$0005, #$0000, #$0000, #$0000 ; nothing
}


; ------------------
; Toggle Items menu
; ------------------

eq_prepare_items_menu:
{
    LDA !SAMUS_ITEMS_COLLECTED : BIT #$0001 : BEQ .noVaria
    LDA !SAMUS_ITEMS_EQUIPPED : BIT #$0001 : BNE .equipVaria
    ; unequip
    LDA #$0002 : BRA .doneVaria
  .equipVaria
    LDA #$0001 : BRA .doneVaria
  .noVaria
    LDA #$0000
  .doneVaria
    STA !ram_cm_varia

    LDA !SAMUS_ITEMS_COLLECTED : BIT #$0020 : BEQ .noGravity
    LDA !SAMUS_ITEMS_EQUIPPED : BIT #$0020 : BNE .equipGravity
    ; unequip
    LDA #$0002 : BRA .doneGravity
  .equipGravity
    LDA #$0001 : BRA .doneGravity
  .noGravity
    LDA #$0000
  .doneGravity
    STA !ram_cm_gravity

    LDA !SAMUS_ITEMS_COLLECTED : BIT #$0004 : BEQ .noMorph
    LDA !SAMUS_ITEMS_EQUIPPED : BIT #$0004 : BNE .equipMorph
    ; unequip
    LDA #$0002 : BRA .doneMorph
  .equipMorph
    LDA #$0001 : BRA .doneMorph
  .noMorph
    LDA #$0000
  .doneMorph
    STA !ram_cm_morph

    LDA !SAMUS_ITEMS_COLLECTED : BIT #$1000 : BEQ .noBombs
    LDA !SAMUS_ITEMS_EQUIPPED : BIT #$1000 : BNE .equipBombs
    ; unequip
    LDA #$0002 : BRA .doneBombs
  .equipBombs
    LDA #$0001 : BRA .doneBombs
  .noBombs
    LDA #$0000
  .doneBombs
    STA !ram_cm_bombs

    LDA !SAMUS_ITEMS_COLLECTED : BIT #$0008 : BEQ .noScrew
    LDA !SAMUS_ITEMS_EQUIPPED : BIT #$0008 : BNE .equipScrew
    ; unequip
    LDA #$0002 : BRA .doneScrew
  .equipScrew
    LDA #$0001 : BRA .doneScrew
  .noScrew
    LDA #$0000
  .doneScrew
    STA !ram_cm_screw

    LDA !SAMUS_ITEMS_COLLECTED : BIT #$0100 : BEQ .noSuperJump
    LDA !SAMUS_ITEMS_EQUIPPED : BIT #$0100 : BNE .equipSuperJump
    ; unequip
    LDA #$0002 : BRA .doneSuperJump
  .equipSuperJump
    LDA #$0001 : BRA .doneSuperJump
  .noSuperJump
    LDA #$0000
  .doneSuperJump
    STA !ram_cm_superjump

    LDA !SAMUS_ITEMS_COLLECTED : BIT #$0200 : BEQ .noSpace
    LDA !SAMUS_ITEMS_EQUIPPED : BIT #$0200 : BNE .equipSpace
    ; unequip
    LDA #$0002 : BRA .doneSpace
  .equipSpace
    LDA #$0001 : BRA .doneSpace
  .noSpace
    LDA #$0000
  .doneSpace
    STA !ram_cm_space

    LDA !SAMUS_ITEMS_COLLECTED : BIT #$2000 : BEQ .noSpeed
    LDA !SAMUS_ITEMS_EQUIPPED : BIT #$2000 : BNE .equipSpeed
    ; unequip
    LDA #$0002 : BRA .doneSpeed
  .equipSpeed
    LDA #$0001 : BRA .doneSpeed
  .noSpeed
    LDA #$0000
  .doneSpeed
    STA !ram_cm_speed

    LDA !SAMUS_ITEMS_COLLECTED : BIT #$0010 : BEQ .noSpeed2
    LDA !SAMUS_ITEMS_EQUIPPED : BIT #$0010 : BNE .equipSpeed2
    ; unequip
    LDA #$0002 : BRA .doneSpeed2
  .equipSpeed2
    LDA #$0001 : BRA .doneSpeed2
  .noSpeed2
    LDA #$0000
  .doneSpeed2
    STA !ram_cm_speed2

    LDA !SAMUS_ITEMS_COLLECTED : BIT #$0080 : BEQ .noSpikeBreaker
    LDA !SAMUS_ITEMS_EQUIPPED : BIT #$0080 : BNE .equipSpikeBreaker
    ; unequip
    LDA #$0002 : BRA .doneSpikeBreaker
  .equipSpikeBreaker
    LDA #$0001 : BRA .doneSpikeBreaker
  .noSpikeBreaker
    LDA #$0000
  .doneSpikeBreaker
    STA !ram_cm_spikebreaker

    LDA !SAMUS_ITEMS_COLLECTED : BIT #$0002 : BEQ .noMissile2
    LDA !SAMUS_ITEMS_EQUIPPED : BIT #$0002 : BNE .equipMissile2
    ; unequip
    LDA #$0002 : BRA .doneMissile2
  .equipMissile2
    LDA #$0001 : BRA .doneMissile2
  .noMissile2
    LDA #$0000
  .doneMissile2
    STA !ram_cm_missile2

    LDA !SAMUS_ITEMS_COLLECTED : BIT #$8000 : BEQ .noMissile3
    LDA !SAMUS_ITEMS_EQUIPPED : BIT #$8000 : BNE .equipMissile3
    ; unequip
    LDA #$0002 : BRA .doneMissile3
  .equipMissile3
    LDA #$0001 : BRA .doneMissile3
  .noMissile3
    LDA #$0000
  .doneMissile3
    STA !ram_cm_missile3

    LDA !SAMUS_ITEMS_COLLECTED : BIT #$0010 : BEQ .noMissile4
    LDA !SAMUS_ITEMS_EQUIPPED : BIT #$0010 : BNE .equipMissile4
    ; unequip
    LDA #$0002 : BRA .doneMissile4
  .equipMissile4
    LDA #$0001 : BRA .doneMissile4
  .noMissile4
    LDA #$0000
  .doneMissile4
    STA !ram_cm_missile4

    %setmenubank()
    JML action_submenu
}

ToggleItemsMenu:
    dw #ti_variasuit
    dw #ti_gravitysuit
    dw #ti_spikebreaker
    dw #ti_screwattack
    dw #$FFFF
    dw #ti_morphball
    dw #ti_bomb
    dw #ti_superjump
    dw #ti_spacejump
    dw #ti_speedbooster
    dw #ti_speedbooster2
    dw #$FFFF
    dw #ti_missile2
    dw #ti_missile3
    dw #ti_missile4
    dw #$FFFF
    dw #ti_grapple
    dw #$0000
    %cm_header("TOGGLE ITEMS")

; 1: Varia Suit
; 2: Lv.2 Missile
; 4: Morphing Ball
; 8: Screw Attack
; 10h: Lv.4 Missile
; 20h: Gravity Suit
; 80h: Spike Breaker
; 100h: Super Jump
; 200h: Space Jump
; 800h:  Lv.2 Speedbooster
; 1000h: Bombs
; 2000h: Speedbooster
; 4000h: Grapple
; 8000h: Lv.3 Missile

ti_variasuit:
    %cm_equipment_item("Varia Suit", !ram_cm_varia, #$0001, #$FFFE)

ti_gravitysuit:
    %cm_equipment_item("Gravity Suit", !ram_cm_gravity, #$0020, #$FFDF)

ti_spikebreaker:
    %cm_equipment_item("Spike Breaker", !ram_cm_spikebreaker, #$0080, #$FF7F)

ti_screwattack:
    %cm_equipment_item("Screw Attack", !ram_cm_screw, #$0008, #$FFF7)

ti_morphball:
    %cm_equipment_item("Morphing Ball", !ram_cm_morph, #$0004, #$FFFB)

ti_bomb:
    %cm_equipment_item("Bombs", !ram_cm_bombs, #$1000, #$EFFF)

ti_superjump:
    %cm_equipment_item("Super Jump", !ram_cm_superjump, #$0100, #$FEFF)

ti_spacejump:
    %cm_equipment_item("Space Jump", !ram_cm_space, #$0200, #$FDFF)

ti_speedbooster:
    %cm_equipment_item("Speedbooster", !ram_cm_speed, #$2000, #$DFFF)

ti_speedbooster2:
    %cm_equipment_item("Lv.2 Speedbooster", !ram_cm_speed2, #$0800, #$F7FF)

ti_missile2:
    %cm_equipment_item("Lv.2 Missile", !ram_cm_missile2, #$0002, #$FFFD)

ti_missile3:
    %cm_equipment_item("Lv.3 Missile", !ram_cm_missile3, #$8000, #$7FFF)

ti_missile4:
    %cm_equipment_item("Lv.4 Missile", !ram_cm_missile4, #$0010, #$FFEF)

ti_grapple:
    %cm_toggle_bit("Grapple", !SAMUS_ITEMS_COLLECTED, #$4000, .routine)
  .routine
    LDA !SAMUS_ITEMS_EQUIPPED : EOR #$4000 : STA !SAMUS_ITEMS_EQUIPPED
    RTL

equipment_toggle_items:
{
; DP values are passed in from the cm_equipment_item macro that calls this routine
; Address is a 24-bit pointer to !ram_cm_<item>, Increment is the inverse, ToggleValue is the bitmask
    LDA [!DP_Address] : BEQ .unobtained
    DEC : BEQ .equipped
    ; unquipped
    LDA !SAMUS_ITEMS_EQUIPPED : AND !DP_Increment : STA !SAMUS_ITEMS_EQUIPPED
    LDA !SAMUS_ITEMS_COLLECTED : ORA !DP_ToggleValue : STA !SAMUS_ITEMS_COLLECTED
    RTL

  .equipped
    LDA !SAMUS_ITEMS_EQUIPPED : ORA !DP_ToggleValue : STA !SAMUS_ITEMS_EQUIPPED
    LDA !SAMUS_ITEMS_COLLECTED : ORA !DP_ToggleValue : STA !SAMUS_ITEMS_COLLECTED
    RTL

  .unobtained
    LDA !SAMUS_ITEMS_EQUIPPED : AND !DP_Increment : STA !SAMUS_ITEMS_EQUIPPED
    LDA !SAMUS_ITEMS_COLLECTED : AND !DP_Increment : STA !SAMUS_ITEMS_COLLECTED
    RTL
}


; -----------------
; Toggle Beams menu
; -----------------

eq_prepare_beams_menu:
{
    JSL setup_beams_ram
    %setmenubank()
    JML action_submenu
}

setup_beams_ram:
{
    LDA !SAMUS_BEAMS_COLLECTED : BIT #$1000 : BEQ .noCharge
    LDA !SAMUS_BEAMS_EQUIPPED : BIT #$1000 : BNE .equipCharge
    ; unequip Charge
    LDA #$0002 : BRA .doneCharge
  .equipCharge
    LDA #$0001 : BRA .doneCharge
  .noCharge
    LDA #$0000
  .doneCharge
    STA !ram_cm_charge

    LDA !SAMUS_BEAMS_COLLECTED : BIT #$0004 : BEQ .noWide
    LDA !SAMUS_BEAMS_EQUIPPED : BIT #$0004 : BNE .equipWide
    ; unequip Ice
    LDA #$0002 : BRA .doneWide
  .equipWide
    LDA #$0001 : BRA .doneWide
  .noWide
    LDA #$0000
  .doneWide
    STA !ram_cm_wide

    LDA !SAMUS_BEAMS_COLLECTED : BIT #$0001 : BEQ .noWave
    LDA !SAMUS_BEAMS_EQUIPPED : BIT #$0001 : BNE .equipWave
    ; unequip Wave
    LDA #$0002 : BRA .doneWave
  .equipWave
    LDA #$0001 : BRA .doneWave
  .noWave
    LDA #$0000
  .doneWave
    STA !ram_cm_wave

    LDA !SAMUS_BEAMS_COLLECTED : BIT #$0002 : BEQ .noPlasma
    LDA !SAMUS_BEAMS_EQUIPPED : BIT #$0002 : BNE .equipPlasma
    ; unequip Plasma
    LDA #$0002 : BRA .donePlasma
  .equipPlasma
    LDA #$0001 : BRA .donePlasma
  .noPlasma
    LDA #$0000
  .donePlasma
    STA !ram_cm_plasma

    RTL
}

ToggleBeamsMenu:
    dw tb_chargebeam
    dw tb_wavebeam
    dw tb_widebeam
    dw tb_plasmabeam
;    dw #$FFFF
;    dw misc_hyperbeam
    dw #$0000
    %cm_header("TOGGLE BEAMS")

tb_chargebeam:
    %cm_equipment_beam("Charge", !ram_cm_charge, #$1000, #$EFFF, #$100F)

tb_wavebeam:
    %cm_equipment_beam("Wave", !ram_cm_wave, #$0001, #$FFFE, #$100F)

tb_widebeam:
    %cm_equipment_beam("Wide", !ram_cm_wide, #$0004, #$FFFB, #$100F)

tb_plasmabeam:
    %cm_equipment_beam("Plasma", !ram_cm_plasma, #$0002, #$FFFD, #$100F)

equipment_toggle_beams:
{
; DP values are passed in from the cm_equipment_beam macro that calls this routine
; Address is a 24-bit pointer to !ram_cm_<beam>, Increment is the inverse, ToggleValue is the bitmask, Temp is the AND for Spazer+Plasma safety
    LDA [!DP_Address] : BEQ .unobtained
    DEC : BEQ .equipped
    ; unquipped
    LDA !SAMUS_BEAMS_EQUIPPED : AND !DP_Increment : STA !SAMUS_BEAMS_EQUIPPED
    LDA !SAMUS_BEAMS_COLLECTED : ORA !DP_ToggleValue : STA !SAMUS_BEAMS_COLLECTED
    JML $90AC8D ; update beam gfx

  .equipped
    LDA !SAMUS_BEAMS_EQUIPPED : ORA !DP_ToggleValue : AND !DP_Temp : STA !SAMUS_BEAMS_EQUIPPED
    LDA !SAMUS_BEAMS_COLLECTED : ORA !DP_ToggleValue : STA !SAMUS_BEAMS_COLLECTED
    JML $90AC8D ; update beam gfx

  .unobtained
    LDA !SAMUS_BEAMS_EQUIPPED : AND !DP_Increment : STA !SAMUS_BEAMS_EQUIPPED
    LDA !SAMUS_BEAMS_COLLECTED : AND !DP_Increment : STA !SAMUS_BEAMS_COLLECTED
    JML $90AC8D ; update beam gfx
}


; ---------------
; Teleport menu
; ---------------

TeleportMenu:
    dw #tel_goto_crat
    dw #tel_goto_brin
    dw #tel_goto_norf
    dw #tel_goto_ship
    dw #tel_goto_mari
    dw #tel_goto_tour
    dw #tel_goto_ceres
    dw #tel_goto_debug
if !DEV
    dw #$FFFF
    dw #tel_goto_debugtel
endif
    dw #$0000
    %cm_header("TELEPORT TO SAVE STATION")

tel_goto_crat:
    %cm_submenu("Main Deck", #TeleportCrateriaMenu)

tel_goto_brin:
    %cm_submenu("SECT-1-SRX", #TeleportBrinstarMenu)

tel_goto_norf:
    %cm_submenu("SECT-2-TRO", #TeleportNorfairMenu)

tel_goto_ship:
    %cm_submenu("SECT-3-PYR", #TeleportWreckedShipMenu)

tel_goto_mari:
    %cm_submenu("SECT-4-AQA", #TeleportMaridiaMenu)

tel_goto_tour:
    %cm_submenu("SECT-5-ARC", #TeleportTourianMenu)

tel_goto_ceres:
    %cm_submenu("SECT-6-NOC", #TeleportCeresMenu)

tel_goto_debug:
    %cm_submenu("SECT-X-DMX", #TeleportDebugMenu)

if !DEV
tel_goto_debugtel:
    %cm_submenu("Debug Teleports", #DebugTeleportMenu)
endif

TeleportCrateriaMenu:
    dw #tel_crateriaship
    dw #tel_crateriaparlor
    dw #tel_crateria2
    dw #$0000
    %cm_header("MAIN DECK SAVE STATIONS")

tel_crateriaship:
    %cm_jsl("Crew Quarters", #action_teleport, #$0000)

tel_crateriaparlor:
    %cm_jsl("Central Nexus", #action_teleport, #$0001)

tel_crateria2:
    %cm_jsl("Yakuza Arena", #action_teleport, #$0002)

TeleportBrinstarMenu:
    dw #tel_brinstarpink
    dw #tel_brinstarredtower
    dw #tel_brinstar5
    dw #tel_brinstar6
    dw #$0000
    %cm_header("SECT-1-SRX SAVE STATIONS")

tel_brinstarpink:
    %cm_jsl("Revival Room", #action_teleport, #$0100)

tel_brinstarredtower:
    %cm_jsl("Twin Junctions West", #action_teleport, #$0104)

tel_brinstar5:
    %cm_jsl("Twin Junctions East", #action_teleport, #$0105)

tel_brinstar6:
    %cm_jsl("East Spike Tower", #action_teleport, #$0106)

TeleportNorfairMenu:
    dw #tel_norfairgrapple
    dw #tel_norfairbubble
    dw #tel_norfairtunnel
    dw #$0000
    %cm_header("SECT-2-TRO SAVE STATIONS")

tel_norfairgrapple:
    %cm_jsl("Cloister", #action_teleport, #$0200)

tel_norfairbubble:
    %cm_jsl("Cultivation Station", #action_teleport, #$0201)

tel_norfairtunnel:
    %cm_jsl("Crum-Ball Tower", #action_teleport, #$0202)

TeleportWreckedShipMenu:
    dw #tel_wreckedship
    dw #tel_wreckedship1
    dw #tel_wreckedship2
    dw #tel_wreckedship3
    dw #$0000
    %cm_header("SECT-3-PYR SAVE STATIONS")

tel_wreckedship:
    %cm_jsl("Entrance Lobby", #action_teleport, #$0300)

tel_wreckedship1:
    %cm_jsl("Big Red", #action_teleport, #$0301)

tel_wreckedship2:
    %cm_jsl("Bubble Heights", #action_teleport, #$0302)

tel_wreckedship3:
    %cm_jsl("Neo-Ridley Gauntlet Access", #action_teleport, #$0303)

TeleportMaridiaMenu:
    dw #tel_maridiatube
    dw #tel_maridiaelevator
    dw #tel_maridiaaqueduct
    dw #tel_maridiadraygon
    dw #tel_maridia4
    dw #$0000
    %cm_header("SECT-4-AQA SAVE STATIONS")

tel_maridiatube:
    %cm_jsl("Reservoir Vault", #action_teleport, #$0400)

tel_maridiaelevator:
    %cm_jsl("Sciser Shaft", #action_teleport, #$0401)

tel_maridiaaqueduct:
    %cm_jsl("Buoyant Bridge", #action_teleport, #$0402)

tel_maridiadraygon:
    %cm_jsl("Neo-Draygon Access", #action_teleport, #$0403)

tel_maridia4:
    %cm_jsl("Glass Tube", #action_teleport, #$0404)

TeleportTourianMenu:
    dw #tel_tourianmb
    dw #tel_tourianentrance
    dw #tel_tourian2
    dw #tel_tourian3
    dw #$0000
    %cm_header("SECT-5-ARC SAVE STATIONS")

tel_tourianmb:
    %cm_jsl("North Blue Tower", #action_teleport, #$0500)

tel_tourianentrance:
    %cm_jsl("South Blue Tower", #action_teleport, #$0501)

tel_tourian2:
    %cm_jsl("Cellar", #action_teleport, #$0502)

tel_tourian3:
    %cm_jsl("Freezer Hallway", #action_teleport, #$0503)

TeleportCeresMenu:
    dw #tel_ceres0
    dw #tel_ceres1
    dw #tel_ceres2
    dw #tel_ceres3
    dw #tel_ceres4
    dw #$0000
    %cm_header("SECT-6-NOC SAVE STATIONS")

tel_ceres0:
    %cm_jsl("Entrance Lobby North", #action_teleport, #$0600)

tel_ceres1:
    %cm_jsl("East Turbo Tube Access", #action_teleport, #$0601)

tel_ceres2:
    %cm_jsl("Warehouse", #action_teleport, #$0602)

tel_ceres3:
    %cm_jsl("Entrance Lobby South", #action_teleport, #$0603)

tel_ceres4:
    %cm_jsl("Catacombs", #action_teleport, #$0604)

TeleportDebugMenu:
    dw #tel_debug0
    dw #tel_debug1
    dw #tel_debug2
    dw #tel_debug3
    dw #tel_debug4
    dw #tel_debug5
    dw #tel_debug6
    dw #tel_debug7
    dw #tel_debug8
    dw #$0000
    %cm_header("SECT-X-DMX SAVE STATIONS")

tel_debug0:
    %cm_jsl("Xenometroid Birthplace", #action_teleport, #$0700)

tel_debug1:
    %cm_jsl("Serpentine Break", #action_teleport, #$0701)

tel_debug2:
    %cm_jsl("Metroid Chase with Dev Exit", #action_teleport, #$0702)

tel_debug3:
    %cm_jsl("SA-X Hallway of Death", #action_teleport, #$0703)

tel_debug4:
    %cm_jsl("DMX Elevator Top", #action_teleport, #$0704)

tel_debug5:
    %cm_jsl("Winding SA-X Chase", #action_teleport, #$0705)

tel_debug6:
    %cm_jsl("Golden Four Containment", #action_teleport, #$0706)

tel_debug7:
    %cm_jsl("Ventilation B", #action_teleport, #$0707)

tel_debug8:
    %cm_jsl("Omega Queen", #action_teleport, #$0708)

if !DEV
DebugTeleportMenu:
    dw #tel_debug_area
    dw #tel_debug_station
    dw #tel_debug_execute
    dw #$0000
    %cm_header("DEBUG LOAD POINTS")

tel_debug_area:
    dw !ACTION_CHOICE
    dl #!ram_tel_debug_area
    dw #$0000
    db #$28, "Select Area", #$FF
        db #$28, "  MAIN DECK", #$FF
        db #$28, " SECT-1-SRX", #$FF
        db #$28, " SECT-2-TRO", #$FF
        db #$28, " SECT-3-PYR", #$FF
        db #$28, " SECT-4-AQA", #$FF
        db #$28, " SECT-5-ARC", #$FF
        db #$28, " SECT-6-NOC", #$FF
        db #$28, " SECT-X-DMX", #$FF
    db #$FF

tel_debug_station:
    %cm_numfield_hex("Station ID", !ram_tel_debug_station, 0, $16, 1, 4, #0)

tel_debug_execute:
    %cm_jsl("TELEPORT", #action_debug_teleport, #$0000)
endif

action_teleport:
{
    ; teleport destination in Y when called
    TYA : AND #$FF00 : XBA : STA !AREA_ID
    TYA : AND #$00FF : STA !LOAD_STATION_INDEX
    LDA #$0006 : STA !GAMEMODE

    ; Make sure we can teleport to Zebes from Ceres
    %a8()
    LDA #$05 : STA $7ED914
    %a16()

    STZ $0727 ; Pause menu index
    STZ $0795 ; Clear door transition flag
    STZ $0E18 ; Set elevator to inactive
    STZ $1C1F ; Clear message box index

    LDA !SAMUS_HP_MAX : BNE .branch
    LDA #$001F : STA !SAMUS_HP

  .branch
;    JSL reset_all_counters
;    JSL stop_all_sounds
    LDA #$0002
    JSL $809049
    LDA #$0071
    JSL $8090CB
    LDA #$0001
    JSL $80914D

    LDA #$0001 : STA !ram_cm_leave

    RTL
}

action_debug_teleport:
{
    LDA !ram_tel_debug_area : XBA
    ORA !ram_tel_debug_station : TAY
    JMP action_teleport
}


; -----------
; Misc menu
; -----------

MiscMenu:
    dw #misc_bluesuit
    dw #misc_flashsuit
;    dw #misc_hyperbeam
    dw #$FFFF
    dw #misc_magicpants
    dw #misc_loudpants
    dw #$FFFF
    dw #misc_healthbomb
    dw #misc_energyalarm
    dw #$FFFF
    dw #misc_killenemies
    dw #misc_forcestand
    dw #misc_clearliquid
    dw #$0000
    %cm_header("MISC")

misc_bluesuit:
    %cm_toggle("Blue Suit", !SAMUS_DASH_COUNTER, #$0004, #0)

misc_flashsuit:
    %cm_toggle("Flash Suit", !SAMUS_SHINE_TIMER, #$0001, #0)

;misc_hyperbeam:
;    %cm_toggle_bit("Disruptor Beam", $7E0A76, #$8000, #.routine)
;  .routine
;    AND #$8000 : BEQ .off
;    LDA #$0003
;;    JSL $91E4AD ; setup Samus for Hyper Beam
;    LDA #$1009 : STA !SAMUS_BEAMS_EQUIPPED
;    JSL $90AC8D
;    LDA #$8000 : STA $0A76
;    STZ $0DC0
;
;    RTL
;
;  .off
;    ; check for Spazer+Plasma
;    LDA !SAMUS_BEAMS_COLLECTED : AND #$000C : CMP #$000C : BEQ .disableMurder
;    LDA !SAMUS_BEAMS_COLLECTED : STA !SAMUS_BEAMS_EQUIPPED
;    BRA .FXobjects
;
;  .disableMurder
;    LDA !SAMUS_BEAMS_COLLECTED : AND #$000B : STA !SAMUS_BEAMS_EQUIPPED
;
;  .FXobjects
;    LDX #$000E
;
;  .loopFXobjects
;    LDA $1E7D,X : CMP #$E1F0 : BEQ .found
;    DEX #2 : BPL .loopFXobjects
;
;  .found
;    ; clear Hyper Beam palette FX object
;    STZ $1E7D,X ; this is probably the only one that matters
;    STZ $1E8D,X : STZ $1E9D,X : STZ $1EAD,X
;    STZ $1EBD,X : STZ $1ECD,X : STZ $1EDD,X
;
;    JSL $90AC8D ; update beam gfx
;    RTL

misc_magicpants:
    %cm_toggle("Magic Pants", !ram_magic_pants_enabled, #$0001, #.routine)
  .routine
    CMP #$0000 : BNE +
    STA !ram_magic_pants_sfx
+   RTL

misc_loudpants:
    %cm_toggle("Loud Pants", !ram_magic_pants_sfx, #$0001, #.routine)
  .routine
    CMP #$0000 : BEQ +
    STA !ram_magic_pants_enabled
+   RTL

misc_healthbomb:
    %cm_toggle("Health Bomb Flag", !SAMUS_HEALTH_WARNING, #$0001, #0)

misc_energyalarm:
    %cm_toggle_inverted("Critical Energy Alarm", !sram_energyalarm, #$0001, #0)

misc_killenemies:
    %cm_jsl("Kill Enemies", .kill_loop, #0)
  .kill_loop
    ; 8000 = solid to Samus, 0400 = Ignore Samus projectiles, 0100 = Invisible
    TAX : LDA $0F86,X : BIT #$8500 : BNE .next_enemy
    ORA #$0200 : STA $0F86,X
  .next_enemy
    TXA : CLC : ADC #$0040 : CMP #$0800 : BNE .kill_loop
    LDA #$0009 : JSL !SFX_LIB2 ; enemy killed
    RTL

misc_forcestand:
    %cm_jsl("Force Samus to Stand Up", .routine, #0)
  .routine
    JSL $90E2D4
    %sfxconfirm()
    RTL

misc_clearliquid:
    %cm_toggle_bit("Ignore Water this Room", $197E, #$0004, #0)


; -----------
; Events menu
; -----------
EventsMenu:
    dw #events_resetevents
    dw #events_resetdoors
    dw #events_resetitems
;    dw #$FFFF
;    dw #events_goto_bosses
;    dw #$FFFF
;    dw #events_zebesawake
;    dw #events_maridiatubebroken
;    dw #events_chozoacid
;    dw #events_shaktool
;    dw #events_tourian
;    dw #events_metroid1
;    dw #events_metroid2
;    dw #events_metroid3
;    dw #events_metroid4
;    dw #events_mb1glass
;    dw #events_zebesexploding
;    dw #events_animals
    dw #$0000
    %cm_header("EVENTS")

events_resetevents:
    %cm_jsl("Reset All Events", .routine, #$0000)
  .routine
    LDA #$0000
    STA $7ED820 : STA $7ED822 : STA $7ED824 : STA $7ED826
    %sfxreset()
    RTL

events_resetdoors:
    %cm_jsl("Reset All Doors", .routine, #$0000)
  .routine
    PHP : %ai8()
    LDX #$B0
    LDA #$00
  .loop
    STA $7ED800,X
    INX : CPX #$F0 : BNE .loop
    PLP
    %sfxreset()
    RTL

events_resetitems:
    %cm_jsl("Reset All Items", .routine, #$0000)
  .routine
    PHP : %ai8()
    LDX #$70
    LDA #$00
  .loop
    STA $7ED800,X
    INX : CPX #$B0 : BNE .loop
    PLP
    %sfxreset()
    RTL

;events_goto_bosses:
;    %cm_submenu("Bosses", #BossesMenu)
;
;events_zebesawake:
;    %cm_toggle_bit("Zebes Awake", $7ED820, #$0001, #0)
;
;events_maridiatubebroken:
;    %cm_toggle_bit("Maridia Tube Broken", $7ED820, #$0800, #0)
;
;events_shaktool:
;    %cm_toggle_bit("Shaktool Done Digging", $7ED820, #$2000, #0)
;
;events_chozoacid:
;    %cm_toggle_bit("Chozo Lowered Acid", $7ED821, #$0010, #0)
;
;events_tourian:
;    %cm_toggle_bit("Tourian Open", $7ED820, #$0400, #0)
;
;events_metroid1:
;    %cm_toggle_bit("1st Metroids Cleared", $7ED822, #$0001, #0)
;
;events_metroid2:
;    %cm_toggle_bit("2nd Metroids Cleared", $7ED822, #$0002, #0)
;
;events_metroid3:
;    %cm_toggle_bit("3rd Metroids Cleared", $7ED822, #$0004, #0)
;
;events_metroid4:
;    %cm_toggle_bit("4th Metroids Cleared", $7ED822, #$0008, #0)
;
;events_mb1glass:
;    %cm_toggle_bit("MB1 Glass Broken", $7ED820, #$0004, #0)
;
;events_zebesexploding:
;    %cm_toggle_bit("Zebes Set Ablaze", $7ED820, #$4000, #0)
;
;events_animals:
;    %cm_toggle_bit("Animals Saved", $7ED820, #$8000, #0)
;
;
;; ------------
;; Bosses menu
;; ------------
;
;BossesMenu:
;    dw #boss_ceresridley
;    dw #boss_bombtorizo
;    dw #boss_spospo
;    dw #boss_kraid
;    dw #boss_phantoon
;    dw #boss_botwoon
;    dw #boss_draygon
;    dw #boss_crocomire
;    dw #boss_gt
;    dw #boss_ridley
;    dw #boss_mb
;    dw #$FFFF
;    dw #boss_kraid_statue
;    dw #boss_phantoon_statue
;    dw #boss_draygon_statue
;    dw #boss_ridley_statue
;    dw #$0000
;    %cm_header("BOSSES")
;
;boss_ceresridley:
;    %cm_toggle_bit("Ceres Ridley", #$7ED82E, #$0001, #0)
;
;boss_bombtorizo:
;    %cm_toggle_bit("Bomb Torizo", #$7ED828, #$0004, #0)
;
;boss_spospo:
;    %cm_toggle_bit("Spore Spawn", #$7ED828, #$0200, #0)
;
;boss_kraid:
;    %cm_toggle_bit("Kraid", #$7ED828, #$0100, #0)
;
;boss_phantoon:
;    %cm_toggle_bit("Phantoon", #$7ED82A, #$0100, #0)
;
;boss_botwoon:
;    %cm_toggle_bit("Botwoon", #$7ED82C, #$0002, #0)
;
;boss_draygon:
;    %cm_toggle_bit("Draygon", #$7ED82C, #$0001, #0)
;
;boss_crocomire:
;    %cm_toggle_bit("Crocomire", #$7ED82A, #$0002, #0)
;
;boss_gt:
;    %cm_toggle_bit("Golden Torizo", #$7ED82A, #$0004, #0)
;
;boss_ridley:
;    %cm_toggle_bit("Ridley", #$7ED82A, #$0001, #0)
;
;boss_mb:
;    %cm_toggle_bit("Mother Brain", #$7ED82C, #$0200, #0)
;
;boss_kraid_statue:
;    %cm_toggle_bit("Kraid Statue", #$7ED820, #$0200, #0)
;
;boss_phantoon_statue:
;    %cm_toggle_bit("Phantoon Statue", #$7ED820, #$0040, #0)
;
;boss_draygon_statue:
;    %cm_toggle_bit("Draygon Statue", #$7ED820, #$0100, #0)
;
;boss_ridley_statue:
;    %cm_toggle_bit("Ridley Statue", #$7ED820, #$0080, #0)


; ----------
; Game menu
; ----------

GameMenu:
;    dw #game_alternatetext
    dw #game_moonwalk
;    dw #game_iconcancel
    dw #$FFFF
    dw #game_music_toggle
    dw #$FFFF
    dw #game_debugmode
;    dw #game_debugbrightness
    dw #game_invincibility
    dw #game_debugplms
    dw #game_debugprojectiles
    dw #$0000
    %cm_header("GAME")

game_moonwalk:
    %cm_toggle_bit("Moon Walk", $7E09E4, #$FFFF, #0)

game_music_toggle:
    dw !ACTION_CHOICE
    dl #!sram_music_toggle
    dw .routine
    db #$28, "Music", #$FF
    db #$28, "        OFF", #$FF
    db #$28, "         ON", #$FF
    db #$28, "   FAST OFF", #$FF
    db #$FF
  .routine
    ; Clear music queue
    STZ $0629 : STZ $062B : STZ $062D : STZ $062F
    STZ $0631 : STZ $0633 : STZ $0635 : STZ $0637
    STZ $0639 : STZ $063B : STZ $063D : STZ $063F
    CMP #$0001 : BEQ .resume_music
    STZ $2140
    RTL
  .resume_music
    LDA !MUSIC_DATA : CLC : ADC #$FF00 : PHA : STZ !MUSIC_DATA : PLA : JSL !MUSIC_ROUTINE
    LDA !MUSIC_TRACK : PHA : STZ !MUSIC_TRACK : PLA : JSL !MUSIC_ROUTINE
    RTL

game_debugmode:
    %cm_toggle("Debug Mode", $7E05D1, #$0001, #0)

game_invincibility:
    %cm_toggle_bit("Invincibility", $7E0DE0, #$0007, #0)

game_debugplms:
    %cm_toggle_bit_inverted("Pseudo G-Mode", $7E1C23, #$8000, #0)

game_debugprojectiles:
    %cm_toggle_bit("Enable Projectiles", $7E198D, #$8000, #0)


; ----------
; Ctrl Menu
; ----------

CtrlMenu:
    dw #ctrl_menu
if !SAVESTATES
    dw #ctrl_save_state
    dw #ctrl_load_state
endif
    dw #ctrl_full_equipment
    dw #ctrl_kill_enemies
    dw #ctrl_update_timers
    dw #$FFFF
    dw #ctrl_clear_shortcuts
    dw #ctrl_reset_defaults
    dw #$0000
    %cm_header("CONTROLLER SHORTCUTS")
    %cm_footer("PRESS AND HOLD FOR 2 SEC")

ctrl_menu:
    %cm_ctrl_shortcut("Main menu", !sram_ctrl_menu)

if !SAVESTATES
ctrl_save_state:
    %cm_ctrl_shortcut("Save State", !sram_ctrl_save_state)

ctrl_load_state:
    %cm_ctrl_shortcut("Load State", !sram_ctrl_load_state)
endif

ctrl_full_equipment:
    %cm_ctrl_shortcut("Full Equipment", !sram_ctrl_full_equipment)

ctrl_kill_enemies:
    %cm_ctrl_shortcut("Kill Enemies", !sram_ctrl_kill_enemies)

ctrl_update_timers:
    %cm_ctrl_shortcut("Update Timers", !sram_ctrl_update_timers)

ctrl_clear_shortcuts:
    %cm_jsl("Clear All Shortcuts", .routine, #$0000)
  .routine
    TYA
if !SAVESTATES
    STA !sram_ctrl_save_state
    STA !sram_ctrl_load_state
endif
    STA !sram_ctrl_full_equipment
    STA !sram_ctrl_kill_enemies
    STA !sram_ctrl_update_timers
    ; menu to default, Start + Select
    LDA #$3000 : STA !sram_ctrl_menu
    %sfxconfirm()
    RTL

ctrl_reset_defaults:
    %cm_jsl("Reset to Defaults", .routine, #$0000)
  .routine
    %sfxreset()
    JML init_sram_controller_shortcuts
    RTL


; This label is used to seed RNG for the menu
InitSRAMLabel:
