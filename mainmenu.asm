
; ------------
; Menu Helpers
; ------------

action_infohud_mainmenu:
{
    ; Validate top display mode in range
    LDA !sram_top_display_mode : CMP #$0003 : BCC action_mainmenu
    TDC : STA !sram_top_display_mode
    BRA action_mainmenu
}

action_customize_mainmenu:
{
    ; Set fast button selection
    LDA !sram_cm_fast_scroll_button : CMP !CTRL_X : BEQ .xSelected
    CMP !CTRL_Y : BEQ .ySelected

    ; None selected
    TDC : STA !sram_cm_fast_scroll_button
    LDA #$0002 : STA !ram_cm_fast_scroll_menu_selection
    BRA action_mainmenu

  .xSelected
    TDC : STA !ram_cm_fast_scroll_menu_selection
    BRA action_mainmenu

  .ySelected
    LDA #$0001 : STA !ram_cm_fast_scroll_menu_selection

    ; continue into action_mainmenu
}

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

    BRA action_submenu_jump
}

action_presets_submenu:
{

    ; Increment stack pointer by 2
    LDA !ram_cm_stack_index : INC #2 : STA !ram_cm_stack_index : TAX

    ; Lookup preset menu pointer for current category
    LDA !sram_preset_category : ASL : TAY
    PHB : PHK : PLB
    LDA.w preset_category_submenus,Y : STA !ram_cm_menu_stack,X
    LDA.w preset_category_banks,Y : STA !ram_cm_menu_bank
    PLB

    ; continue into action_submenu_jump
}

action_submenu_jump:
{
    ; Set cursor to top for new menus
    LDA #$0000 : STA !ram_cm_cursor_stack,X

    %sfxmove()
    JSL cm_calculate_max
if !FEATURE_CUSTOMIZE_MENU
    JSL cm_colors
endif
    JSL cm_draw
    RTL
}

preset_category_submenus:
{
    dw #PresetsMenuPrkd
    dw #$0000
}

preset_category_banks:
{
    dw #PresetsMenuPrkd>>16
    dw #$0000
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
    dw #mm_goto_audiomenu
if !FEATURE_CUSTOMIZE_MENU
    dw #mm_goto_customize
endif
    dw #$0000
    %cm_version_header("SM PRACTICE HACK")

MainMenuBanks:
    dw #EquipmentMenu>>16
    dw #TeleportMenu>>16
    dw #EventsMenu>>16
    dw #MiscMenu>>16
    dw #GameMenu>>16
    dw #CtrlMenu>>16
    dw #AudioMenu>>16
if !FEATURE_CUSTOMIZE_MENU
    dw #CustomizeMenu>>16
endif

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

mm_goto_audiomenu:
    %cm_mainmenu("Audio Menu", #AudioMenu)

if !FEATURE_CUSTOMIZE_MENU
mm_goto_customize:
    %cm_jsl("Menu Customization", #action_customize_mainmenu, #CustomizeMenu)
endif


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
    dw #eq_currentreserves
    dw #eq_setreserves
    dw #eq_reservemode
    dw #$FFFF
    dw #eq_currentmissiles
    dw #eq_setmissiles
    dw #$FFFF
    dw #eq_currentsupers
    dw #eq_setsupers
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
    LDA !SAMUS_SUPERS_MAX : STA !SAMUS_SUPERS
    LDA !SAMUS_PBS_MAX : STA !SAMUS_PBS
    LDA !SAMUS_RESERVE_MAX : STA !SAMUS_RESERVE_ENERGY
    LDA #$0002 : JSL !SFX_LIB2 ; big energy pickup
    RTL

eq_toggle_category:
    %cm_submenu("Category Loadouts", #ToggleCategoryMenu)

eq_goto_toggleitems:
    %cm_jsl("Toggle Items", #eq_prepare_items_menu, #ToggleItemsMenu)

eq_goto_togglebeams:
    %cm_jsl("Toggle Beams", #eq_prepare_beams_menu, #ToggleBeamsMenu)

eq_currentenergy:
    %cm_numfield_word("Current Energy", !SAMUS_HP, 0, 2100, 1, 20, #0)

eq_setetanks:
    %cm_numfield("Energy Tanks", !ram_cm_etanks, 0, 21, 1, 1, .routine)
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

eq_currentreserves:
    %cm_numfield_word("Current Reserves", !SAMUS_RESERVE_ENERGY, 0, 700, 1, 20, #0)

eq_setreserves:
    %cm_numfield("Reserve Tanks", !ram_cm_reserve, 0, 7, 1, 1, .routine)
  .routine
    TAX : BEQ .zero
    LDA #$0000
  .loop
    DEX : BMI .endloop
    CLC : ADC #$0064
    BRA .loop
  .zero
    STA !SAMUS_RESERVE_MODE
  .endloop
    STA !SAMUS_RESERVE_ENERGY : STA !SAMUS_RESERVE_MAX
    RTL

eq_reservemode:
    dw !ACTION_CHOICE
    dl #!SAMUS_RESERVE_MODE
    dw #.routine
    db #$28, "Reserve Mode", #$FF
    db #$28, " UNOBTAINED", #$FF
    db #$28, "       AUTO", #$FF
    db #$28, "     MANUAL", #$FF
    db #$FF
  .routine
    LDA !SAMUS_RESERVE_MAX : BNE .end
    STA !SAMUS_RESERVE_MODE
    %sfxfail()
  .end
    RTL

eq_currentmissiles:
    %cm_numfield_word("Current Missiles", !SAMUS_MISSILES, 0, 230, 1, 20, #0)

eq_setmissiles:
    %cm_numfield_word("Missiles", !SAMUS_MISSILES_MAX, 0, 230, 5, 20, .routine)
  .routine
    LDA !SAMUS_MISSILES_MAX : STA !SAMUS_MISSILES
    RTL

eq_currentsupers:
    %cm_numfield("Current Super Missiles", !SAMUS_SUPERS, 0, 50, 1, 5, #0)

eq_setsupers:
    %cm_numfield("Super Missiles", !SAMUS_SUPERS_MAX, 0, 50, 5, 5, .routine)
  .routine
    LDA !SAMUS_SUPERS_MAX : STA !SAMUS_SUPERS
    RTL

eq_currentpbs:
    %cm_numfield("Current Power Bombs", !SAMUS_PBS, 0, 50, 1, 5, #0)

eq_setpbs:
    %cm_numfield("Power Bombs", !SAMUS_PBS_MAX, 0, 50, 5, 5, .routine)
  .routine
    LDA !SAMUS_PBS_MAX : STA !SAMUS_PBS
    RTL

; ---------------------
; Toggle Category menu
; ---------------------

ToggleCategoryMenu:
    dw #cat_100
    dw #cat_any_new
    dw #cat_any_old
    dw #cat_14ice
    dw #cat_14speed
    dw #cat_gt_code
    dw #cat_gt_max
    dw #cat_rbo
    dw #cat_any_glitched
    dw #cat_inf_cf
    dw #cat_nothing
    dw #$0000
    %cm_header("TOGGLE CATEGORY")

cat_100:
    %cm_jsl("100%", action_category, #$0000)

cat_any_new:
    %cm_jsl("Any% PRKD", action_category, #$0001)

cat_any_old:
    %cm_jsl("Any% KPDR", action_category, #$0002)

cat_14ice:
    %cm_jsl("14% Ice", action_category, #$0003)

cat_14speed:
    %cm_jsl("14% Speed", action_category, #$0004)

cat_gt_code:
    %cm_jsl("GT Code", action_category, #$0005)

cat_gt_max:
    %cm_jsl("GT Max%", action_category, #$0006)

cat_rbo:
    %cm_jsl("RBO", action_category, #$0007)

cat_any_glitched:
    %cm_jsl("Any% Glitched", action_category, #$0008)

cat_inf_cf:
    %cm_jsl("Infinite Crystal Flashes", action_category, #$0009)

cat_nothing:
    %cm_jsl("Nothing", action_category, #$000A)

action_category:
{
    TYA : ASL #4 : TAX

    LDA.l .table,X : STA !SAMUS_ITEMS_COLLECTED : STA !SAMUS_ITEMS_EQUIPPED : INX #2

    LDA.l .table,X : STA !SAMUS_BEAMS_COLLECTED : TAY
    AND #$000C : CMP #$000C : BEQ .murderBeam
    TYA : STA !SAMUS_BEAMS_EQUIPPED : INX #2 : BRA .doneMurderBeam

  .murderBeam
    TYA : AND #$100B : STA !SAMUS_BEAMS_EQUIPPED : INX #2

  .doneMurderBeam
    LDA.l .table,X : STA !SAMUS_HP : STA !SAMUS_HP_MAX : INX #2
    LDA.l .table,X : STA !SAMUS_MISSILES : STA !SAMUS_MISSILES_MAX : INX #2
    LDA.l .table,X : STA !SAMUS_SUPERS : STA !SAMUS_SUPERS_MAX : INX #2
    LDA.l .table,X : STA !SAMUS_PBS : STA !SAMUS_PBS_MAX : INX #2
    LDA.l .table,X : STA !SAMUS_RESERVE_MAX : STA !SAMUS_RESERVE_ENERGY : INX #2

    JSL cm_set_etanks_and_reserve
    %sfxconfirm()
    JML $90AC8D ; update beam gfx

  .table
    ;  Items,  Beams,  Health, Miss,   Supers, PBs,    Reserv, Dummy
    dw #$F32F, #$100F, #$05DB, #$00E6, #$0032, #$0032, #$0190, #$0000        ; 100%
    dw #$3125, #$1007, #$018F, #$000F, #$000A, #$0005, #$0000, #$0000        ; any% new
    dw #$3325, #$100B, #$018F, #$000F, #$000A, #$0005, #$0000, #$0000        ; any% old
    dw #$1025, #$1002, #$018F, #$000A, #$000A, #$0005, #$0000, #$0000        ; 14% ice
    dw #$3025, #$1000, #$018F, #$000A, #$000A, #$0005, #$0000, #$0000        ; 14% speed
    dw #$F33F, #$100F, #$02BC, #$0064, #$0014, #$0014, #$012C, #$0000        ; gt code
    dw #$F33F, #$100F, #$0834, #$0145, #$0041, #$0041, #$02BC, #$0000        ; 135%
    dw #$710C, #$1001, #$031F, #$001E, #$0019, #$0014, #$0064, #$0000        ; rbo
    dw #$9004, #$0000, #$00C7, #$0005, #$0005, #$0005, #$0000, #$0000        ; any% glitched
    dw #$F32F, #$100F, #$0031, #$01A4, #$005A, #$0063, #$0000, #$0000        ; crystal flash
    dw #$0000, #$0000, #$0063, #$0000, #$0000, #$0000, #$0000, #$0000        ; nothing
}


; ------------------
; Toggle Items menu
; ------------------

eq_prepare_items_menu:
{
    LDA !SAMUS_ITEMS_COLLECTED : BIT #$0001 : BEQ .noVaria
    LDA !SAMUS_ITEMS_EQUIPPED : BIT #$0001 : BNE .equipVaria
    ; unequip
    LDA #$0002 : STA !ram_cm_varia : BRA .doneVaria
  .equipVaria
    LDA #$0001 : STA !ram_cm_varia : BRA .doneVaria
  .noVaria
    LDA #$0000 : STA !ram_cm_varia
  .doneVaria

    LDA !SAMUS_ITEMS_COLLECTED : BIT #$0020 : BEQ .noGravity
    LDA !SAMUS_ITEMS_EQUIPPED : BIT #$0020 : BNE .equipGravity
    ; unequip
    LDA #$0002 : STA !ram_cm_gravity : BRA .doneGravity
  .equipGravity
    LDA #$0001 : STA !ram_cm_gravity : BRA .doneGravity
  .noGravity
    LDA #$0000 : STA !ram_cm_gravity
  .doneGravity

    LDA !SAMUS_ITEMS_COLLECTED : BIT #$0004 : BEQ .noMorph
    LDA !SAMUS_ITEMS_EQUIPPED : BIT #$0004 : BNE .equipMorph
    ; unequip
    LDA #$0002 : STA !ram_cm_morph : BRA .doneMorph
  .equipMorph
    LDA #$0001 : STA !ram_cm_morph : BRA .doneMorph
  .noMorph
    LDA #$0000 : STA !ram_cm_morph
  .doneMorph

    LDA !SAMUS_ITEMS_COLLECTED : BIT #$1000 : BEQ .noBombs
    LDA !SAMUS_ITEMS_EQUIPPED : BIT #$1000 : BNE .equipBombs
    ; unequip
    LDA #$0002 : STA !ram_cm_bombs : BRA .doneBombs
  .equipBombs
    LDA #$0001 : STA !ram_cm_bombs : BRA .doneBombs
  .noBombs
    LDA #$0000 : STA !ram_cm_bombs
  .doneBombs

    LDA !SAMUS_ITEMS_COLLECTED : BIT #$0002 : BEQ .noSpring
    LDA !SAMUS_ITEMS_EQUIPPED : BIT #$0002 : BNE .equipSpring
    ; unequip
    LDA #$0002 : STA !ram_cm_spring : BRA .doneSpring
  .equipSpring
    LDA #$0001 : STA !ram_cm_spring : BRA .doneSpring
  .noSpring
    LDA #$0000 : STA !ram_cm_spring
  .doneSpring

    LDA !SAMUS_ITEMS_COLLECTED : BIT #$0008 : BEQ .noScrew
    LDA !SAMUS_ITEMS_EQUIPPED : BIT #$0008 : BNE .equipScrew
    ; unequip
    LDA #$0002 : STA !ram_cm_screw : BRA .doneScrew
  .equipScrew
    LDA #$0001 : STA !ram_cm_screw : BRA .doneScrew
  .noScrew
    LDA #$0000 : STA !ram_cm_screw
  .doneScrew

    LDA !SAMUS_ITEMS_COLLECTED : BIT #$0100 : BEQ .noHiJump
    LDA !SAMUS_ITEMS_EQUIPPED : BIT #$0100 : BNE .equipHiJump
    ; unequip
    LDA #$0002 : STA !ram_cm_hijump : BRA .doneHiJump
  .equipHiJump
    LDA #$0001 : STA !ram_cm_hijump : BRA .doneHiJump
  .noHiJump
    LDA #$0000 : STA !ram_cm_hijump
  .doneHiJump

    LDA !SAMUS_ITEMS_COLLECTED : BIT #$0200 : BEQ .noSpace
    LDA !SAMUS_ITEMS_EQUIPPED : BIT #$0200 : BNE .equipSpace
    ; unequip
    LDA #$0002 : STA !ram_cm_space : BRA .doneSpace
  .equipSpace
    LDA #$0001 : STA !ram_cm_space : BRA .doneSpace
  .noSpace
    LDA #$0000 : STA !ram_cm_space
  .doneSpace

    LDA !SAMUS_ITEMS_COLLECTED : BIT #$2000 : BEQ .noSpeed
    LDA !SAMUS_ITEMS_EQUIPPED : BIT #$2000 : BNE .equipSpeed
    ; unequip
    LDA #$0002 : STA !ram_cm_speed : BRA .doneSpeed
  .equipSpeed
    LDA #$0001 : STA !ram_cm_speed : BRA .doneSpeed
  .noSpeed
    LDA #$0000 : STA !ram_cm_speed
  .doneSpeed

    %setmenubank()
    JML action_submenu
}

ToggleItemsMenu:
    dw #ti_variasuit
    dw #ti_gravitysuit
    dw #$FFFF
    dw #ti_morphball
    dw #ti_bomb
    dw #ti_springball
    dw #ti_screwattack
    dw #$FFFF
    dw #ti_hijumpboots
    dw #ti_spacejump
    dw #ti_speedbooster
    dw #$FFFF
    dw #ti_grapple
    dw #ti_xray
    dw #$0000
    %cm_header("TOGGLE ITEMS")

ti_variasuit:
    %cm_equipment_item("Varia Suit", !ram_cm_varia, #$0001, #$FFFE)

ti_gravitysuit:
    %cm_equipment_item("Gravity Suit", !ram_cm_gravity, #$0020, #$FFDF)

ti_morphball:
    %cm_equipment_item("Morph Ball", !ram_cm_morph, #$0004, #$FFFB)

ti_bomb:
    %cm_equipment_item("Bombs", !ram_cm_bombs, #$1000, #$EFFF)

ti_springball:
    %cm_equipment_item("Spring Ball", !ram_cm_spring, #$0002, #$FFFD)

ti_screwattack:
    %cm_equipment_item("Screw Attack", !ram_cm_screw, #$0008, #$FFF7)

ti_hijumpboots:
    %cm_equipment_item("Hi Jump Boots", !ram_cm_hijump, #$0100, #$FEFF)

ti_spacejump:
    %cm_equipment_item("Space Jump", !ram_cm_space, #$0200, #$FDFF)

ti_speedbooster:
    %cm_equipment_item("Speed Booster", !ram_cm_speed, #$2000, #$DFFF)

ti_grapple:
    %cm_toggle_bit("Grapple", !SAMUS_ITEMS_COLLECTED, #$4000, .routine)
  .routine
    LDA !SAMUS_ITEMS_EQUIPPED : EOR #$4000 : STA !SAMUS_ITEMS_EQUIPPED
    RTL

ti_xray:
    %cm_toggle_bit("X-Ray", !SAMUS_ITEMS_COLLECTED, #$8000, .routine)
  .routine
    LDA !SAMUS_ITEMS_EQUIPPED : EOR #$8000 : STA !SAMUS_ITEMS_EQUIPPED
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
    LDA #$0002 : STA !ram_cm_charge : BRA .doneCharge
  .equipCharge
    LDA #$0001 : STA !ram_cm_charge : BRA .doneCharge
  .noCharge
    LDA #$0000 : STA !ram_cm_charge
  .doneCharge

    LDA !SAMUS_BEAMS_COLLECTED : BIT #$0002 : BEQ .noIce
    LDA !SAMUS_BEAMS_EQUIPPED : BIT #$0002 : BNE .equipIce
    ; unequip Ice
    LDA #$0002 : STA !ram_cm_ice : BRA .doneIce
  .equipIce
    LDA #$0001 : STA !ram_cm_ice : BRA .doneIce
  .noIce
    LDA #$0000 : STA !ram_cm_ice
  .doneIce

    LDA !SAMUS_BEAMS_COLLECTED : BIT #$0001 : BEQ .noWave
    LDA !SAMUS_BEAMS_EQUIPPED : BIT #$0001 : BNE .equipWave
    ; unequip Wave
    LDA #$0002 : STA !ram_cm_wave : BRA .doneWave
  .equipWave
    LDA #$0001 : STA !ram_cm_wave : BRA .doneWave
  .noWave
    LDA #$0000 : STA !ram_cm_wave
  .doneWave

    LDA !SAMUS_BEAMS_COLLECTED : BIT #$0004 : BEQ .noSpazer
    LDA !SAMUS_BEAMS_EQUIPPED : BIT #$0004 : BNE .equipSpazer
    ; unequip Spazer
    LDA #$0002 : STA !ram_cm_spazer : BRA .doneSpazer
  .equipSpazer
    LDA #$0001 : STA !ram_cm_spazer : BRA .doneSpazer
  .noSpazer
    LDA #$0000 : STA !ram_cm_spazer
  .doneSpazer

    LDA !SAMUS_BEAMS_COLLECTED : BIT #$0008 : BEQ .noPlasma
    LDA !SAMUS_BEAMS_EQUIPPED : BIT #$0008 : BNE .equipPlasma
    ; unequip Plasma
    LDA #$0002 : STA !ram_cm_plasma : BRA .donePlasma
  .equipPlasma
    LDA #$0001 : STA !ram_cm_plasma : BRA .donePlasma
  .noPlasma
    LDA #$0000 : STA !ram_cm_plasma
  .donePlasma

    RTL
}

ToggleBeamsMenu:
    dw tb_chargebeam
    dw tb_icebeam
    dw tb_wavebeam
    dw tb_spazerbeam
    dw tb_plasmabeam
    dw #$FFFF
    dw misc_hyperbeam
    dw #$FFFF
    dw tb_glitchedbeams
    dw #$0000
    %cm_header("TOGGLE BEAMS")

tb_chargebeam:
    %cm_equipment_beam("Charge", !ram_cm_charge, #$1000, #$EFFF, #$100F)

tb_icebeam:
    %cm_equipment_beam("Ice", !ram_cm_ice, #$0002, #$FFFD, #$100F)

tb_wavebeam:
    %cm_equipment_beam("Wave", !ram_cm_wave, #$0001, #$FFFE, #$100F)

tb_spazerbeam:
    %cm_equipment_beam("Spazer", !ram_cm_spazer, #$0004, #$FFFB, #$1007)

tb_plasmabeam:
    %cm_equipment_beam("Plasma", !ram_cm_plasma, #$0008, #$FFF7, #$100B)

tb_glitchedbeams:
    %cm_submenu("Glitched Beams", #GlitchedBeamsMenu)

equipment_toggle_beams:
{
; DP values are passed in from the cm_equipment_beam macro that calls this routine
; Address is a 24-bit pointer to !ram_cm_<beam>, Increment is the inverse, ToggleValue is the bitmask, Temp is the AND for Spazer+Plasma safety
    LDA [!DP_Address] : BEQ .unobtained
    DEC : BEQ .equipped
    ; unquipped
    LDA !SAMUS_BEAMS_EQUIPPED : AND !DP_Increment : STA !SAMUS_BEAMS_EQUIPPED
    LDA !SAMUS_BEAMS_COLLECTED : ORA !DP_ToggleValue : STA !SAMUS_BEAMS_COLLECTED
    BRA .checkSpazer

  .equipped
    LDA !SAMUS_BEAMS_EQUIPPED : ORA !DP_ToggleValue : AND !DP_Temp : STA !SAMUS_BEAMS_EQUIPPED
    LDA !SAMUS_BEAMS_COLLECTED : ORA !DP_ToggleValue : STA !SAMUS_BEAMS_COLLECTED
    BRA .checkSpazer

  .unobtained
    LDA !SAMUS_BEAMS_EQUIPPED : AND !DP_Increment : STA !SAMUS_BEAMS_EQUIPPED
    LDA !SAMUS_BEAMS_COLLECTED : AND !DP_Increment : STA !SAMUS_BEAMS_COLLECTED

  .checkSpazer
    ; Reinitialize Spazer and Plasma since they affect each other
    LDA !SAMUS_BEAMS_COLLECTED : BIT #$0004 : BEQ .noSpazer
    LDA !SAMUS_BEAMS_EQUIPPED : BIT #$0004 : BNE .equipSpazer
    ; unequip Spazer
    LDA #$0002 : STA !ram_cm_spazer : BRA .checkPlasma
  .equipSpazer
    LDA #$0001 : STA !ram_cm_spazer : BRA .checkPlasma
  .noSpazer
    LDA #$0000 : STA !ram_cm_spazer

  .checkPlasma
    LDA !SAMUS_BEAMS_COLLECTED : BIT #$0008 : BEQ .noPlasma
    LDA !SAMUS_BEAMS_EQUIPPED : BIT #$0008 : BNE .equipPlasma
    ; unequip Plasma
    LDA #$0002 : STA !ram_cm_plasma : BRA .done
  .equipPlasma
    LDA #$0001 : STA !ram_cm_plasma : BRA .done
  .noPlasma
    LDA #$0000 : STA !ram_cm_plasma

  .done
    JML $90AC8D ; update beam gfx
}


; -------------------
; Glitched Beams menu
; -------------------

GlitchedBeamsMenu:
    dw #gb_murder
    dw #gb_spacetime
    dw #gb_chainsaw
    dw #gb_unnamed
    dw #$0000
    %cm_header("GLITCHED BEAMS")
    %cm_footer("BEWARE OF CRASHES")

gb_murder:
    %cm_jsl("Murder Beam", action_glitched_beam, #$100F)

gb_spacetime:
    %cm_jsl("Spacetime Beam", action_glitched_beam, #$100E)

gb_chainsaw:
    %cm_jsl("Chainsaw Beam", action_glitched_beam, #$100D)

gb_unnamed:
    %cm_jsl("Unnamed Glitched Beam", action_glitched_beam, #$100C)

action_glitched_beam:
{
    TYA : STA !SAMUS_BEAMS_EQUIPPED
    LDA !SAMUS_BEAMS_COLLECTED : ORA !SAMUS_BEAMS_EQUIPPED : STA !SAMUS_BEAMS_COLLECTED
    JSL setup_beams_ram
    LDA #$0042 : JSL !SFX_LIB1 ; unlabled, song dependent sound
    JSL $90AC8D ; update beam gfx
    RTL
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
    dw #tel_goto_debug
    dw #$0000
    %cm_header("TELEPORT TO SAVE STATION")

tel_goto_crat:
    %cm_submenu("Crateria", #TeleportCrateriaMenu)

tel_goto_brin:
    %cm_submenu("Brinstar", #TeleportBrinstarMenu)

tel_goto_norf:
    %cm_submenu("Norfair", #TeleportNorfairMenu)

tel_goto_ship:
    %cm_submenu("Wrecked Ship", #TeleportWreckedShipMenu)

tel_goto_mari:
    %cm_submenu("Maridia", #TeleportMaridiaMenu)

tel_goto_tour:
    %cm_submenu("Tourian", #TeleportTourianMenu)

tel_goto_debug:
    %cm_submenu("Debug Teleports", #DebugTeleportMenu)

TeleportCrateriaMenu:
    dw #tel_crateriaship
    dw #tel_crateriaparlor
    dw #$0000
    %cm_header("CRATERIA SAVE STATIONS")

tel_crateriaship:
    %cm_jsl("Crateria Ship", #action_teleport, #$0000)

tel_crateriaparlor:
    %cm_jsl("Crateria Parlor", #action_teleport, #$0001)

TeleportBrinstarMenu:
    dw #tel_brinstarpink
    dw #tel_brinstargreenshaft
    dw #tel_brinstargreenetecoons
    dw #tel_brinstarkraid
    dw #tel_brinstarredtower
    dw #$0000
    %cm_header("BRINSTAR SAVE STATIONS")

tel_brinstarpink:
    %cm_jsl("Brinstar Pink Spospo", #action_teleport, #$0100)

tel_brinstargreenshaft:
    %cm_jsl("Brinstar Green Shaft", #action_teleport, #$0101)

tel_brinstargreenetecoons:
    %cm_jsl("Brinstar Green Etecoons", #action_teleport, #$0102)

tel_brinstarkraid:
    %cm_jsl("Brinstar Kraid", #action_teleport, #$0103)

tel_brinstarredtower:
    %cm_jsl("Brinstar Red Tower", #action_teleport, #$0104)

TeleportNorfairMenu:
    dw #tel_norfairgrapple
    dw #tel_norfairbubble
    dw #tel_norfairtunnel
    dw #tel_norfaircrocomire
    dw #tel_norfairlnelevator
    dw #tel_norfairridley
    dw #$0000
    %cm_header("NORFAIR SAVE STATIONS")

tel_norfairgrapple:
    %cm_jsl("Norfair Grapple", #action_teleport, #$0200)

tel_norfairbubble:
    %cm_jsl("Norfair Bubble Mountain", #action_teleport, #$0201)

tel_norfairtunnel:
    %cm_jsl("Norfair Tunnel", #action_teleport, #$0202)

tel_norfaircrocomire:
    %cm_jsl("Norfair Crocomire", #action_teleport, #$0203)

tel_norfairlnelevator:
    %cm_jsl("Norfair LN Elevator", #action_teleport, #$0204)

tel_norfairridley:
    %cm_jsl("Norfair Ridley", #action_teleport, #$0205)

TeleportWreckedShipMenu:
    dw #tel_wreckedship
    dw #$0000
    %cm_header("WRECKED SHIP SAVE STATIONS")

tel_wreckedship:
    %cm_jsl("Wrecked Ship", #action_teleport, #$0300)

TeleportMaridiaMenu:
    dw #tel_maridiatube
    dw #tel_maridiaelevator
    dw #tel_maridiaaqueduct
    dw #tel_maridiadraygon
    dw #$0000
    %cm_header("MARIDIA SAVE STATIONS")

tel_maridiatube:
    %cm_jsl("Maridia Tube", #action_teleport, #$0400)

tel_maridiaelevator:
    %cm_jsl("Maridia Elevator", #action_teleport, #$0401)

tel_maridiaaqueduct:
    %cm_jsl("Maridia Aqueduct", #action_teleport, #$0402)

tel_maridiadraygon:
    %cm_jsl("Maridia Draygon", #action_teleport, #$0403)

TeleportTourianMenu:
    dw #tel_tourianentrance
    dw #tel_tourianmb
    dw #$0000
    %cm_header("TOURIAN SAVE STATIONS")

tel_tourianentrance:
    %cm_jsl("Tourian Entrance", #action_teleport, #$0501)

tel_tourianmb:
    %cm_jsl("Tourian MB", #action_teleport, #$0500)

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
        db #$28, "   CRATERIA", #$FF
        db #$28, "   BRINSTAR", #$FF
        db #$28, "    NORFAIR", #$FF
        db #$28, "  REQT SHIP", #$FF
        db #$28, "    MARIDIA", #$FF
        db #$28, "    TOURIAN", #$FF
    db #$FF

tel_debug_station:
    %cm_numfield_hex("Station ID", !ram_tel_debug_station, 0, 22, 1, 4, #0)

tel_debug_execute:
    %cm_jsl("TELEPORT", #action_debug_teleport, #$0000)

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
    JSL reset_all_counters
    JSL stop_all_sounds

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
    dw #misc_hyperbeam
    dw #$FFFF
    dw #misc_gooslowdown
    dw #misc_healthbomb
    dw #$FFFF
    dw #misc_magicpants
    dw #misc_spacepants
    dw #$FFFF
    dw #misc_metronome
    dw #misc_metronome_tickrate
    dw #misc_metronome_sfx
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

misc_hyperbeam:
    %cm_toggle_bit("Hyper Beam", $7E0A76, #$8000, #.routine)
  .routine
    AND #$8000 : BEQ .off
    LDA #$0003
    JSL $91E4AD ; setup Samus for Hyper Beam
    RTL

  .off
    ; check for Spazer+Plasma
    LDA !SAMUS_BEAMS_COLLECTED : AND #$000C : CMP #$000C : BEQ .disableMurder
    LDA !SAMUS_BEAMS_COLLECTED : STA !SAMUS_BEAMS_EQUIPPED
    BRA .FXobjects

  .disableMurder
    LDA !SAMUS_BEAMS_COLLECTED : AND #$000B : STA !SAMUS_BEAMS_EQUIPPED

  .FXobjects
    LDX #$000E

  .loopFXobjects
    LDA $1E7D,X : CMP #$E1F0 : BEQ .found
    DEX #2 : BPL .loopFXobjects

  .found
    ; clear Hyper Beam palette FX object
    STZ $1E7D,X ; this is probably the only one that matters
    STZ $1E8D,X : STZ $1E9D,X : STZ $1EAD,X
    STZ $1EBD,X : STZ $1ECD,X : STZ $1EDD,X

    JSL $90AC8D ; update beam gfx
    RTL

misc_gooslowdown:
    %cm_numfield("Goo Slowdown", $7E0A66, 0, 4, 1, 1, #0)

misc_healthbomb:
    %cm_toggle("Health Bomb Flag", !SAMUS_HEALTH_WARNING, #$0001, #0)

misc_magicpants:
    dw !ACTION_CHOICE
    dl #!ram_magic_pants_enabled
    dw #$0000
    db #$28, "Magic Pants", #$FF
    db #$28, "        OFF", #$FF
    db #$28, "      FLASH", #$FF
    db #$28, "       LOUD", #$FF
    db #$28, "       BOTH", #$FF
    db #$FF

misc_spacepants:
    dw !ACTION_CHOICE
    dl #!ram_space_pants_enabled
    dw #$0000
    db #$28, "Space Pants", #$FF
    db #$28, "        OFF", #$FF
    db #$28, "      FLASH", #$FF
    db #$28, "       LOUD", #$FF
    db #$28, "       BOTH", #$FF
    db #$FF

misc_metronome:
    %cm_toggle("Metronome", !ram_metronome, #$0001, GameLoopExtras)

misc_metronome_tickrate:
    %cm_numfield("Metronome Tickrate", !sram_metronome_tickrate, 1, 255, 1, 8, #.routine)
    .routine
        LDA #$0000 : STA !ram_metronome_counter
        RTL

GameLoopExtras:
{
    LDA !ram_magic_pants_enabled : BNE .enabled
    LDA !ram_space_pants_enabled : BNE .enabled
    LDA !ram_metronome : BNE .enabled
    LDA #$0000
  .enabled
    STA !ram_game_loop_extras
    RTL
}

misc_metronome_sfx:
    dw !ACTION_CHOICE
    dl #!sram_metronome_sfx
    dw #$0000
    db #$28, "Metronome SFX", #$FF
    db #$28, "    MISSILE", #$FF
    db #$28, "      CLICK", #$FF
    db #$28, "       BEEP", #$FF
    db #$28, " POWER BEAM", #$FF
    db #$28, "     SPAZER", #$FF
    db #$FF

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
    dw #$FFFF
    dw #events_goto_bosses
    dw #$FFFF
    dw #events_zebesawake
    dw #events_maridiatubebroken
    dw #events_chozoacid
    dw #events_shaktool
    dw #events_tourian
    dw #events_metroid1
    dw #events_metroid2
    dw #events_metroid3
    dw #events_metroid4
    dw #events_mb1glass
    dw #events_zebesexploding
    dw #events_animals
    dw #$0000
    %cm_header("EVENTS")

events_resetevents:
    %cm_jsl("Reset All Events", .routine, #$0000)
  .routine
    LDA #$0000
    STA $7ED820 : STA $7ED822
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
    INX : CPX #$D0 : BNE .loop
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
    INX : CPX #$90 : BNE .loop
    PLP
    %sfxreset()
    RTL

events_goto_bosses:
    %cm_submenu("Bosses", #BossesMenu)

events_zebesawake:
    %cm_toggle_bit("Zebes Awake", $7ED820, #$0001, #0)

events_maridiatubebroken:
    %cm_toggle_bit("Maridia Tube Broken", $7ED820, #$0800, #0)

events_shaktool:
    %cm_toggle_bit("Shaktool Done Digging", $7ED820, #$2000, #0)

events_chozoacid:
    %cm_toggle_bit("Chozo Lowered Acid", $7ED821, #$0010, #0)

events_tourian:
    %cm_toggle_bit("Tourian Open", $7ED820, #$0400, #0)

events_metroid1:
    %cm_toggle_bit("1st Metroids Cleared", $7ED822, #$0001, #0)

events_metroid2:
    %cm_toggle_bit("2nd Metroids Cleared", $7ED822, #$0002, #0)

events_metroid3:
    %cm_toggle_bit("3rd Metroids Cleared", $7ED822, #$0004, #0)

events_metroid4:
    %cm_toggle_bit("4th Metroids Cleared", $7ED822, #$0008, #0)

events_mb1glass:
    %cm_toggle_bit("MB1 Glass Broken", $7ED820, #$0004, #0)

events_zebesexploding:
    %cm_toggle_bit("Zebes Set Ablaze", $7ED820, #$4000, #0)

events_animals:
    %cm_toggle_bit("Animals Saved", $7ED820, #$8000, #0)


; ------------
; Bosses menu
; ------------

BossesMenu:
    dw #boss_ceresridley
    dw #boss_bombtorizo
    dw #boss_spospo
    dw #boss_kraid
    dw #boss_phantoon
    dw #boss_botwoon
    dw #boss_draygon
    dw #boss_crocomire
    dw #boss_gt
    dw #boss_ridley
    dw #boss_mb
    dw #$FFFF
    dw #boss_kraid_statue
    dw #boss_phantoon_statue
    dw #boss_draygon_statue
    dw #boss_ridley_statue
    dw #$0000
    %cm_header("BOSSES")

boss_ceresridley:
    %cm_toggle_bit("Ceres Ridley", #$7ED82E, #$0001, #0)

boss_bombtorizo:
    %cm_toggle_bit("Bomb Torizo", #$7ED828, #$0004, #0)

boss_spospo:
    %cm_toggle_bit("Spore Spawn", #$7ED828, #$0200, #0)

boss_kraid:
    %cm_toggle_bit("Kraid", #$7ED828, #$0100, #0)

boss_phantoon:
    %cm_toggle_bit("Phantoon", #$7ED82A, #$0100, #0)

boss_botwoon:
    %cm_toggle_bit("Botwoon", #$7ED82C, #$0002, #0)

boss_draygon:
    %cm_toggle_bit("Draygon", #$7ED82C, #$0001, #0)

boss_crocomire:
    %cm_toggle_bit("Crocomire", #$7ED82A, #$0002, #0)

boss_gt:
    %cm_toggle_bit("Golden Torizo", #$7ED82A, #$0004, #0)

boss_ridley:
    %cm_toggle_bit("Ridley", #$7ED82A, #$0001, #0)

boss_mb:
    %cm_toggle_bit("Mother Brain", #$7ED82C, #$0200, #0)

boss_kraid_statue:
    %cm_toggle_bit("Kraid Statue", #$7ED820, #$0200, #0)

boss_phantoon_statue:
    %cm_toggle_bit("Phantoon Statue", #$7ED820, #$0040, #0)

boss_draygon_statue:
    %cm_toggle_bit("Draygon Statue", #$7ED820, #$0100, #0)

boss_ridley_statue:
    %cm_toggle_bit("Ridley Statue", #$7ED820, #$0080, #0)



; Memory viewer?

ih_ram_watch:
    %cm_jsl("Customize RAM Watch", #ih_prepare_ram_watch_menu, #RAMWatchMenu)

incsrc ramwatchmenu.asm

print pc, " mainmenu InfoHUD end"
;warnpc $85F800 ; gamemode.asm


; ----------
; Game menu
; ----------

;org $B3F000
org !ORG_MAINMENU_GAME
print pc, " mainmenu GameMenu start"

GameMenu:
    dw #game_alternatetext
    dw #game_moonwalk
    dw #game_iconcancel
    dw #game_goto_controls
    dw #$FFFF
    dw #game_cutscenes
    dw #$FFFF
    dw #game_goto_debug
    dw #$FFFF
    dw #game_minimap
    dw #game_clear_minimap
    dw #$0000
    %cm_header("GAME")

game_alternatetext:
    %cm_toggle("Japanese Text", $7E09E2, #$0001, #0)

game_moonwalk:
    %cm_toggle("Moon Walk", $7E09E4, #$0001, #0)

game_iconcancel:
    %cm_toggle("Icon Cancel", $7E09EA, #$0001, #0)

game_goto_controls:
    %cm_submenu("Controller Setting Mode", #ControllerSettingMenu)

game_cutscenes:
    %cm_submenu("Cutscenes Menu", #CutscenesMenu)

game_minimap:
    %cm_toggle("Minimap", !ram_minimap, #$0001, #0)

game_clear_minimap:
    %cm_jsl("Clear Minimap", .clear_minimap, #$0000)

  .clear_minimap
    LDA #$0000 : STA !ram_map_counter : STA $7E0789
    STA $7ED908 : STA $7ED90A : STA $7ED90C : STA $7ED90E
    LDX #$00FE
  .clear_minimap_loop
    STA $7ECD52,X : STA $7ECE52,X
    STA $7ECF52,X : STA $7ED052,X
    STA $7ED152,X : STA $7ED252,X
    STA $7ED352,X : STA $7ED452,X
    STA $7ED91C,X : STA $7EDA1C,X
    STA $7EDB1C,X : STA $7EDC1C,X
    STA $7EDD1C,X : STA $7E07F7,X
    DEX : DEX : BPL .clear_minimap_loop
    %sfxreset()
    RTL

game_goto_debug:
    %cm_submenu("Debug Settings", #DebugMenu)


; ----------
; Debug Menu
; ----------

DebugMenu:
    dw #game_debugmode
    dw #game_debugbrightness
    dw #game_invincibility
    dw #game_pacifist
    dw #game_debugplms
    dw #game_debugprojectiles
    dw #game_debugfixscrolloffsets
    dw #$0000
    %cm_header("DEBUG SETTINGS")

game_debugmode:
    %cm_toggle("Debug Mode", $7E05D1, #$0001, #0)

game_debugbrightness:
    %cm_toggle("Debug CPU Brightness", $7E0DF4, #$0001, #0)

game_invincibility:
    %cm_toggle_bit("Invincibility", $7E0DE0, #$0007, #0)

game_pacifist:
    %cm_toggle("Pacifist Mode", !ram_pacifist, #$0001, #0)

game_debugplms:
    %cm_toggle_bit_inverted("Pseudo G-Mode", $7E1C23, #$8000, #0)

game_debugprojectiles:
    %cm_toggle_bit("Enable Projectiles", $7E198D, #$8000, #0)

game_debugfixscrolloffsets:
    %cm_toggle_bit("Fix Scroll Offsets", !ram_fix_scroll_offsets, #$0001, #0)


; ---------------
; Cutscenes menu
; ---------------

CutscenesMenu:
    dw #cutscenes_quickboot
    dw #$FFFF
    dw #cutscenes_fast_kraid
    dw #cutscenes_fast_phantoon
    dw #$0000
    %cm_header("CUTSCENES")

cutscenes_quickboot:
    %cm_toggle_bit("Boot to Menu", !sram_cutscenes, !CUTSCENE_QUICKBOOT, #0)

cutscenes_fast_kraid:
    %cm_toggle_bit("Skip Kraid Intro", !sram_cutscenes, !CUTSCENE_FAST_KRAID, #0)

cutscenes_fast_phantoon:
    %cm_toggle_bit("Skip Phantoon Intro", !sram_cutscenes, !CUTSCENE_FAST_PHANTOON, #0)


; -------------------
; Controller Settings
; -------------------

ControllerSettingMenu:
    dw #controls_common_layouts
    dw #controls_save_to_file
    dw #$FFFF
    dw #controls_shot
    dw #controls_jump
    dw #controls_dash
    dw #controls_item_select
    dw #controls_item_cancel
    dw #controls_angle_up
    dw #controls_angle_down
    dw #$0000
    %cm_header("CONTROLLER SETTING MODE")

controls_common_layouts:
    %cm_submenu("Common Controller Layouts", #ControllerCommonMenu)

controls_shot:
    %cm_ctrl_input("        SHOT", !IH_INPUT_SHOT, action_submenu, #AssignControlsMenu)

controls_jump:
    %cm_ctrl_input("        JUMP", !IH_INPUT_JUMP, action_submenu, #AssignControlsMenu)

controls_dash:
    %cm_ctrl_input("        DASH", !IH_INPUT_RUN, action_submenu, #AssignControlsMenu)

controls_item_select:
    %cm_ctrl_input(" ITEM SELECT", !IH_INPUT_ITEM_SELECT, action_submenu, #AssignControlsMenu)

controls_item_cancel:
    %cm_ctrl_input(" ITEM CANCEL", !IH_INPUT_ITEM_CANCEL, action_submenu, #AssignControlsMenu)

controls_angle_up:
    %cm_ctrl_input("    ANGLE UP", !IH_INPUT_ANGLE_UP, action_submenu, #AssignAngleControlsMenu)

controls_angle_down:
    %cm_ctrl_input("  ANGLE DOWN", !IH_INPUT_ANGLE_DOWN, action_submenu, #AssignAngleControlsMenu)

controls_save_to_file:
    %cm_jsl("Save to File", .routine, #0)
  .routine
    LDA !GAMEMODE : CMP #$0002 : BEQ .fail
    LDA !CURRENT_SAVE_FILE : BEQ .fileA
    CMP #$0001 : BEQ .fileB
    CMP #$0002 : BEQ .fileC

  .fail
    %sfxfail()
    RTL

  .fileA
    LDX #$0020 : BRA .save

  .fileB
    LDX #$067C : BRA .save

  .fileC
    LDX #$0CD8

  .save
    LDA.w !IH_INPUT_SHOT : STA $700000,X : INX #2
    LDA.w !IH_INPUT_JUMP : STA $700000,X : INX #2
    LDA.w !IH_INPUT_RUN : STA $700000,X : INX #2
    LDA.w !IH_INPUT_ITEM_CANCEL : STA $700000,X : INX #2
    LDA.w !IH_INPUT_ITEM_SELECT : STA $700000,X : INX #2
    LDA.w !IH_INPUT_ANGLE_UP : STA $700000,X : INX #2
    LDA.w !IH_INPUT_ANGLE_DOWN : STA $700000,X
    %sfxconfirm()
    RTL

AssignControlsMenu:
    dw controls_assign_A
    dw controls_assign_B
    dw controls_assign_X
    dw controls_assign_Y
    dw controls_assign_Select
    dw controls_assign_L
    dw controls_assign_R
    dw #$0000
    %cm_header("ASSIGN AN INPUT")

controls_assign_A:
    %cm_jsl("A", action_assign_input, !CTRL_A)

controls_assign_B:
    %cm_jsl("B", action_assign_input, !CTRL_B)

controls_assign_X:
    %cm_jsl("X", action_assign_input, !CTRL_X)

controls_assign_Y:
    %cm_jsl("Y", action_assign_input, !CTRL_Y)

controls_assign_Select:
    %cm_jsl("Select", action_assign_input, !CTRL_SELECT)

controls_assign_L:
    %cm_jsl("L", action_assign_input, !CTRL_L)

controls_assign_R:
    %cm_jsl("R", action_assign_input, !CTRL_R)

AssignAngleControlsMenu:
    dw #controls_assign_L
    dw #controls_assign_R
    dw #$0000
    %cm_header("ASSIGN AN INPUT")
    %cm_footer("ONLY L OR R ALLOWED")

action_assign_input:
{
    LDA !ram_cm_ctrl_assign : STA $C2 : TAX  ; input address in $C2 and X
    LDA $7E0000,X : STA !ram_cm_ctrl_swap    ; save old input for later
    TYA : STA $7E0000,X                      ; store new input
    STY $C4                                  ; saved new input for later

    JSL check_duplicate_inputs

    ; determine which sfx to play
    CMP #$FFFF : BEQ .undetected
    %sfxconfirm()
    BRA .done
  .undetected
    %sfxgoback()
  .done
    JML cm_previous_menu
}

check_duplicate_inputs:
{
    ; ram_cm_ctrl_assign = word address of input being assigned
    ; ram_cm_ctrl_swap = previous input bitmask being moved
    ; X / $C2 = word address of new input
    ; Y / $C4 = new input bitmask

    LDA #$09B2 : CMP $C2 : BEQ .check_jump      ; check if we just assigned shot
    LDA $09B2 : BEQ .swap_shot                  ; check if shot is unassigned
    CMP $C4 : BNE .check_jump                   ; skip to check_jump if not a duplicate assignment
  .swap_shot
    JMP .shot                                   ; swap with shot

  .check_jump
    LDA #$09B4 : CMP $C2 : BEQ .check_dash
    LDA $09B4 : BEQ .swap_jump
    CMP $C4 : BNE .check_dash
  .swap_jump
    JMP .jump

  .check_dash
    LDA #$09B6 : CMP $C2 : BEQ .check_cancel
    LDA $09B6 : BEQ .swap_dash
    CMP $C4 : BNE .check_cancel
  .swap_dash
    JMP .dash

  .check_cancel
    LDA #$09B8 : CMP $C2 : BEQ .check_select
    LDA $09B8 : BEQ .swap_cancel
    CMP $C4 : BNE .check_select
  .swap_cancel
    JMP .cancel

  .check_select
    LDA #$09BA : CMP $C2 : BEQ .check_up
    LDA $09BA : BEQ .swap_select
    CMP $C4 : BNE .check_up
  .swap_select
    JMP .select

  .check_up
    LDA #$09BE : CMP $C2 : BEQ .check_down
    LDA $09BE : BEQ .swap_up
    CMP $C4 : BNE .check_down
  .swap_up
    JMP .up

  .check_down
    LDA #$09BC : CMP $C2 : BEQ .not_detected
    LDA $09BC : BEQ .swap_down
    CMP $C4 : BNE .not_detected
  .swap_down
    JMP .down

  .not_detected
    %sfxfail()
    LDA #$FFFF
    JML cm_previous_menu

  .shot
    LDA !ram_cm_ctrl_swap : AND #$0030 : BEQ .shot_safe  ; check if old input is L or R
    LDA #$0000 : STA $09B2                               ; unassign input
    RTL
  .shot_safe
    LDA !ram_cm_ctrl_swap : STA $09B2                    ; input is safe to be assigned
    RTL

  .jump
    LDA !ram_cm_ctrl_swap : AND #$0030 : BEQ .jump_safe
    LDA #$0000 : STA $09B4
    RTL
  .jump_safe
    LDA !ram_cm_ctrl_swap : STA $09B4
    RTL

  .dash
    LDA !ram_cm_ctrl_swap : AND #$0030 : BEQ .dash_safe
    LDA #$0000 : STA $09B6
    RTL
  .dash_safe
    LDA !ram_cm_ctrl_swap : STA $09B6
    RTL

  .cancel
    LDA !ram_cm_ctrl_swap : AND #$0030 : BEQ .cancel_safe
    LDA #$0000 : STA $09B8
    RTL
  .cancel_safe
    LDA !ram_cm_ctrl_swap : STA $09B8
    RTL

  .select
    LDA !ram_cm_ctrl_swap : AND #$0030 : BEQ .select_safe
    LDA #$0000 : STA $09BA
    RTL
  .select_safe
    LDA !ram_cm_ctrl_swap : STA $09BA
    RTL

  .up
    LDA !ram_cm_ctrl_swap : AND #$0030 : BEQ .unbind_up  ; check if input is L or R, unbind if not
    LDA !ram_cm_ctrl_swap : STA $09BE                    ; safe to assign input
    CMP $09BC : BEQ .swap_angle_down                     ; check if input matches angle down
    RTL

  .unbind_up
    STA $09BE               ; unassign up
    RTL

  .swap_angle_down
    CMP #$0020 : BNE .angle_down_l  ; check if angle up is assigned to L
    LDA #$0010 : STA $09BC  ; assign R to angle down
    RTL
  .angle_down_l
    LDA #$0020 : STA $09BC  ; assign L to angle down
    RTL

  .down
    LDA !ram_cm_ctrl_swap : AND #$0030 : BEQ .unbind_down
    LDA !ram_cm_ctrl_swap : STA $09BC
    CMP $09BE : BEQ .swap_angle_up
    RTL

  .unbind_down
    STA $09BC               ; unassign down
    RTL

  .swap_angle_up
    CMP #$0020 : BNE .angle_up_l
    LDA #$0010 : STA $09BE
    RTL
  .angle_up_l
    LDA #$0020 : STA $09BE
    RTL
}

ControllerCommonMenu:
    dw #controls_common_default
    dw #controls_common_d2
    dw #controls_common_d3
    dw #controls_common_d4
    dw #controls_common_d5
    dw #$0000
    %cm_header("COMMON CONTROLLER LAYOUTS")
    %cm_footer("WIKI.SUPERMETROID.RUN")

controls_common_default:
    %cm_jsl("Default (D1)", #action_set_common_controls, #$0000)

controls_common_d2:
    %cm_jsl("Select+Cancel Swap (D2)", #action_set_common_controls, #$000E)

controls_common_d3:
    %cm_jsl("D2 + Shot+Select Swap (D3)", #action_set_common_controls, #$001C)

controls_common_d4:
    %cm_jsl("MMX Style (D4)", #action_set_common_controls, #$002A)

controls_common_d5:
    %cm_jsl("SMW Style (D5)", #action_set_common_controls, #$0038)

action_set_common_controls:
{
    TYX
    LDA.l ControllerLayoutTable,X : STA.w !IH_INPUT_SHOT
    LDA.l ControllerLayoutTable+2,X : STA.w !IH_INPUT_JUMP
    LDA.l ControllerLayoutTable+4,X : STA.w !IH_INPUT_RUN
    LDA.l ControllerLayoutTable+6,X : STA.w !IH_INPUT_ITEM_CANCEL
    LDA.l ControllerLayoutTable+8,X : STA.w !IH_INPUT_ITEM_SELECT
    LDA.l ControllerLayoutTable+10,X : STA.w !IH_INPUT_ANGLE_DOWN
    LDA.l ControllerLayoutTable+12,X : STA.w !IH_INPUT_ANGLE_UP
    %sfxconfirm()
    JML cm_previous_menu

ControllerLayoutTable:
    ;  shot     jump     dash     cancel        select        down     up
    dw !CTRL_X, !CTRL_A, !CTRL_B, !CTRL_Y,      !CTRL_SELECT, !CTRL_L, !CTRL_R ; Default (D1)
    dw !CTRL_X, !CTRL_A, !CTRL_B, !CTRL_SELECT, !CTRL_Y,      !CTRL_L, !CTRL_R ; Select+Cancel Swap (D2)
    dw !CTRL_Y, !CTRL_A, !CTRL_B, !CTRL_SELECT, !CTRL_X,      !CTRL_L, !CTRL_R ; D2 + Shot+Select Swap (D3)
    dw !CTRL_Y, !CTRL_B, !CTRL_A, !CTRL_SELECT, !CTRL_X,      !CTRL_L, !CTRL_R ; MMX Style (D4)
    dw !CTRL_X, !CTRL_B, !CTRL_Y, !CTRL_SELECT, !CTRL_A,      !CTRL_L, !CTRL_R ; SMW Style (D5)
}

print pc, " mainmenu GameMenu end"
pullpc


; ----------
; Ctrl Menu
; ----------

CtrlMenu:
    dw #ctrl_menu
if !FEATURE_SD2SNES
    dw #ctrl_save_state
    dw #ctrl_load_state
    dw #ctrl_auto_save_state
endif
    dw #ctrl_load_last_preset
    dw #ctrl_random_preset
    dw #ctrl_save_custom_preset
    dw #ctrl_load_custom_preset
    dw #ctrl_inc_custom_preset
    dw #ctrl_dec_custom_preset
    dw #ctrl_reset_segment_timer
    dw #ctrl_reset_segment_later
    dw #ctrl_full_equipment
    dw #ctrl_kill_enemies
    dw #ctrl_toggle_tileviewer
    dw #ctrl_update_timers
    dw #$FFFF
    dw #ctrl_clear_shortcuts
    dw #ctrl_reset_defaults
    dw #$0000
    %cm_header("CONTROLLER SHORTCUTS")
    %cm_footer("PRESS AND HOLD FOR 2 SEC")

ctrl_menu:
    %cm_ctrl_shortcut("Main menu", !sram_ctrl_menu)

ctrl_load_last_preset:
    %cm_ctrl_shortcut("Reload Preset", !sram_ctrl_load_last_preset)

if !FEATURE_SD2SNES
ctrl_save_state:
    %cm_ctrl_shortcut("Save State", !sram_ctrl_save_state)

ctrl_load_state:
    %cm_ctrl_shortcut("Load State", !sram_ctrl_load_state)

ctrl_auto_save_state:
    %cm_ctrl_shortcut("Auto Save State", !sram_ctrl_auto_save_state)
endif

ctrl_reset_segment_timer:
    %cm_ctrl_shortcut("Reset Seg Timer", !sram_ctrl_reset_segment_timer)

ctrl_reset_segment_later:
    %cm_ctrl_shortcut("Reset Seg Later", !sram_ctrl_reset_segment_later)

ctrl_full_equipment:
    %cm_ctrl_shortcut("Full Equipment", !sram_ctrl_full_equipment)

ctrl_kill_enemies:
    %cm_ctrl_shortcut("Kill Enemies", !sram_ctrl_kill_enemies)

ctrl_random_preset:
    %cm_ctrl_shortcut("Random Preset", !sram_ctrl_random_preset)

ctrl_save_custom_preset:
    %cm_ctrl_shortcut("Save Cust Preset", !sram_ctrl_save_custom_preset)

ctrl_load_custom_preset:
    %cm_ctrl_shortcut("Load Cust Preset", !sram_ctrl_load_custom_preset)

ctrl_inc_custom_preset:
    %cm_ctrl_shortcut("Next Preset Slot", !sram_ctrl_inc_custom_preset)

ctrl_dec_custom_preset:
    %cm_ctrl_shortcut("Prev Preset Slot", !sram_ctrl_dec_custom_preset)

ctrl_toggle_tileviewer:
    %cm_ctrl_shortcut("Toggle OOB Tiles", !sram_ctrl_toggle_tileviewer)

ctrl_update_timers:
    %cm_ctrl_shortcut("Update Timers", !sram_ctrl_update_timers)

ctrl_clear_shortcuts:
    %cm_jsl("Clear All Shortcuts", .routine, #$0000)
  .routine
    TYA
    STA !ram_game_mode_extras
    STA !sram_ctrl_save_state
    STA !sram_ctrl_load_state
    STA !sram_ctrl_auto_save_state
    STA !sram_ctrl_load_last_preset
    STA !sram_ctrl_full_equipment
    STA !sram_ctrl_kill_enemies
    STA !sram_ctrl_random_preset
    STA !sram_ctrl_save_custom_preset
    STA !sram_ctrl_load_custom_preset
    STA !sram_ctrl_inc_custom_preset
    STA !sram_ctrl_dec_custom_preset
    STA !sram_ctrl_reset_segment_timer
    STA !sram_ctrl_reset_segment_later
    STA !sram_ctrl_toggle_tileviewer
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

; ----------
; Audio Menu
; ----------

AudioMenu:
    dw #audio_music_toggle
    dw #audio_fanfare_toggle
    dw #audio_health_alarm
    dw #$FFFF
    dw #audio_goto_music
    dw #$FFFF
    dw #audio_sfx_lib1
    dw #audio_sfx_lib2
    dw #audio_sfx_lib3
    dw #audio_sfx_silence
    dw #$0000
    %cm_header("AUDIO MENU")
    %cm_footer("PRESS Y TO PLAY SOUNDS")

audio_music_toggle:
    dw !ACTION_CHOICE
    dl #!sram_music_toggle
    dw .routine
    db #$28, "Music", #$FF
    db #$28, "        OFF", #$FF
    db #$28, "         ON", #$FF
    db #$28, "   FAST OFF", #$FF
    db #$28, " PRESET OFF", #$FF
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

audio_fanfare_toggle:
    %cm_toggle_bit("Fanfare", !sram_fanfare_toggle, !FANFARE_TOGGLE, #0)

audio_health_alarm:
    dw !ACTION_CHOICE
    dl #!sram_healthalarm
    dw #$0000
    db #$28, "Low Health Alar", #$FF
    db #$28, "m     NEVER", #$FF
    db #$28, "m   VANILLA", #$FF
    db #$28, "m    PB FIX", #$FF
    db #$28, "m  IMPROVED", #$FF
    db #$FF

audio_goto_music:
    %cm_submenu("Music Selection", #MusicSelectMenu1)

audio_sfx_lib1:
    %cm_numfield_sound("Library One Sound", !ram_cm_sfxlib1, 1, 66, 1, 4, .routine)
  .routine
    LDA !IH_CONTROLLER_PRI_NEW : BIT !CTRL_Y : BEQ .done
    LDA !ram_cm_sfxlib1 : JML !SFX_LIB1
  .done
    RTL

audio_sfx_lib2:
    %cm_numfield_sound("Library Two Sound", !ram_cm_sfxlib2, 1, 127, 1, 4, .routine)
  .routine
    LDA !IH_CONTROLLER_PRI_NEW : BIT !CTRL_Y : BEQ audio_sfx_lib1_done
    LDA !ram_cm_sfxlib2 : JML !SFX_LIB2

audio_sfx_lib3:
    %cm_numfield_sound("Library Three Sound", !ram_cm_sfxlib3, 1, 47, 1, 4, .routine)
  .routine
    LDA !IH_CONTROLLER_PRI_NEW : BIT !CTRL_Y : BEQ audio_sfx_lib1_done
    LDA !ram_cm_sfxlib3 : JML !SFX_LIB3

audio_sfx_silence:
    %cm_jsl("Silence Sound FX", .routine, #0)
  .routine
    JML stop_all_sounds

MusicSelectMenu1:
    dw #audio_music_title1
    dw #audio_music_title2
    dw #audio_music_intro
    dw #audio_music_ceres
    dw #audio_music_escape
    dw #audio_music_rainstorm
    dw #audio_music_spacepirate
    dw #audio_music_samustheme
    dw #audio_music_greenbrinstar
    dw #audio_music_redbrinstar
    dw #audio_music_uppernorfair
    dw #audio_music_lowernorfair
    dw #audio_music_easternmaridia
    dw #audio_music_westernmaridia
    dw #audio_music_wreckedshipoff
    dw #audio_music_wreckedshipon
    dw #audio_music_hallway
    dw #audio_music_goldenstatue
    dw #audio_music_tourian
    dw #$FFFF
    dw #audio_music_goto_2
    dw #$0000
    %cm_header("PLAY MUSIC - PAGE ONE")

audio_music_title1:
    %cm_jsl("Title Theme Part 1", #audio_playmusic, #$0305)

audio_music_title2:
    %cm_jsl("Title Theme Part 2", #audio_playmusic, #$0306)

audio_music_intro:
    %cm_jsl("Intro", #audio_playmusic, #$3605)

audio_music_ceres:
    %cm_jsl("Ceres Station", #audio_playmusic, #$2D06)

audio_music_escape:
    %cm_jsl("Escape Sequence", #audio_playmusic, #$2407)

audio_music_rainstorm:
    %cm_jsl("Zebes Rainstorm", #audio_playmusic, #$0605)

audio_music_spacepirate:
    %cm_jsl("Space Pirate Theme", #audio_playmusic, #$0905)

audio_music_samustheme:
    %cm_jsl("Samus Theme", #audio_playmusic, #$0C05)

audio_music_greenbrinstar:
    %cm_jsl("Green Brinstar", #audio_playmusic, #$0F05)

audio_music_redbrinstar:
    %cm_jsl("Red Brinstar", #audio_playmusic, #$1205)

audio_music_uppernorfair:
    %cm_jsl("Upper Norfair", #audio_playmusic, #$1505)

audio_music_lowernorfair:
    %cm_jsl("Lower Norfair", #audio_playmusic, #$1805)

audio_music_easternmaridia:
    %cm_jsl("Eastern Maridia", #audio_playmusic, #$1B05)

audio_music_westernmaridia:
    %cm_jsl("Western Maridia", #audio_playmusic, #$1B06)

audio_music_wreckedshipoff:
    %cm_jsl("Wrecked Ship Unpowered", #audio_playmusic, #$3005)

audio_music_wreckedshipon:
    %cm_jsl("Wrecked Ship", #audio_playmusic, #$3006)

audio_music_hallway:
    %cm_jsl("Hallway to Statue", #audio_playmusic, #$0004)

audio_music_goldenstatue:
    %cm_jsl("Golden Statue", #audio_playmusic, #$0906)

audio_music_tourian:
    %cm_jsl("Tourian", #audio_playmusic, #$1E05)

audio_music_goto_2:
    %cm_adjacent_submenu("GOTO PAGE TWO", #MusicSelectMenu2)

MusicSelectMenu2:
    dw #audio_music_preboss1
    dw #audio_music_preboss2
    dw #audio_music_miniboss
    dw #audio_music_smallboss
    dw #audio_music_bigboss
    dw #audio_music_motherbrain
    dw #audio_music_credits
    dw #audio_music_itemroom
    dw #audio_music_itemfanfare
    dw #audio_music_spacecolony
    dw #audio_music_zebesexplodes
    dw #audio_music_loadsave
    dw #audio_music_death
    dw #audio_music_lastmetroid
    dw #audio_music_galaxypeace
    dw #$FFFF
    dw #audio_music_goto_1
    dw #$0000
    %cm_header("PLAY MUSIC - PAGE TWO")

audio_music_preboss1:
    %cm_jsl("Chozo Statue Awakens", #audio_playmusic, #$2406)

audio_music_preboss2:
    %cm_jsl("Approaching Confrontation", #audio_playmusic, #$2706)

audio_music_miniboss:
    %cm_jsl("Miniboss Fight", #audio_playmusic, #$2A05)

audio_music_smallboss:
    %cm_jsl("Small Boss Confrontation", #audio_playmusic, #$2705)

audio_music_bigboss:
    %cm_jsl("Big Boss Confrontation", #audio_playmusic, #$2405)

audio_music_motherbrain:
    %cm_jsl("Mother Brain Fight", #audio_playmusic, #$2105)

audio_music_credits:
    %cm_jsl("Credits", #audio_playmusic, #$3C05)

audio_music_itemroom:
    %cm_jsl("Item - Elevator Room", #audio_playmusic, #$0003)

audio_music_itemfanfare:
    %cm_jsl("Item Fanfare", #audio_playmusic, #$0002)

audio_music_spacecolony:
    %cm_jsl("Arrival at Space Colony", #audio_playmusic, #$2D05)

audio_music_zebesexplodes:
    %cm_jsl("Zebes Explodes", #audio_playmusic, #$3305)

audio_music_loadsave:
    %cm_jsl("Samus Appears", #audio_playmusic, #$0001)

audio_music_death:
    %cm_jsl("Death", #audio_playmusic, #$3905)

audio_music_lastmetroid:
    %cm_jsl("Last Metroid in Captivity", #audio_playmusic, #$3F05)

audio_music_galaxypeace:
    %cm_jsl("The Galaxy is at Peace", #audio_playmusic, #$4205)

audio_music_goto_1:
    %cm_adjacent_submenu("GOTO PAGE TWO", #MusicSelectMenu1)

audio_playmusic:
{
    PHY
    ; always load silence first
    LDA #$0000 : JSL !MUSIC_ROUTINE
    PLY : TYA
    STZ $C1 : %a8() : STA $C1
    XBA : %a16()
    STA !ROOM_MUSIC_DATA_INDEX
    ; play from negative data index
    ORA #$FF00 : JSL !MUSIC_ROUTINE
    ; play from track index
    LDA $C1 : JSL !MUSIC_ROUTINE
    RTL
}

