

%startfree(9B)
print pc, " menu start"

cm_start:
{
    PHP : %ai16()
    PHB
    PHK : PLB

    ; Ensure sound is enabled when menu is open
    LDA !DISABLE_SOUNDS : PHA
    STZ !DISABLE_SOUNDS
    LDA !PB_EXPLOSION_STATUS : PHA
    STZ !PB_EXPLOSION_STATUS
    JSL SilenceSFX

    JSR cm_init
    JSL cm_draw
    JSL play_music_long ; Play 2 lag frames of music and sound effects

    JSR cm_loop ; Main menu loop

    ; Restore sounds variables
    PLA : STA !PB_EXPLOSION_STATUS
    PLA : STA !DISABLE_SOUNDS
    ; Makes the game check Samus' health again, to see if we need annoying sound
    STZ !SAMUS_HEALTH_WARNING

    JSL cm_transfer_original_tileset
    JSL cm_transfer_original_cgram

    ; Update HUD (in case we added missiles etc.)
    %a8()
    LDA #$80 : STA $802100
    %a16()
    JSL $8A890A ; X-Fusion routine that fixes layer 3 (called when unpausing)
    %a8()
    LDA #$0F : STA $0F2100
    %a16()
    JSL $809A99 ; Initialize HUD
    JSL $809AD3 ; Handle HUD tilemap
    JSL ih_update_hud_code

    JSL restore_ppu_long ; Restore PPU registers and tilemaps

    JSL play_music_long ; Play 2 lag frames of music and sound effects

    %ai16()
    JSR cm_wait_for_lag_frame
    JSL SilenceSFX

    PLB
    PLP
    RTL
}

cm_init:
{
    ; Setup registers
    %a8()
    STZ $420C ; disable HDMAs
    LDA #$80 : STA $802100 ; enable forced blanking
    LDA #$A1 : STA $4200 ; enable NMI, v-IRQ, and auto-joy read
    LDA #$09 : STA $2105 ; BG Mode 1, enable BG3 priority
    LDA #$17 : STA $212C ; enable OBJ, BG1, BG2, BG3
    LDA #$0F : STA $0F2100 ; disable forced blanking
    %a16()

    JSL initialize_ppu_long   ; Initialise PPU for message boxes
    JSL cm_transfer_custom_tileset
    JSL cm_transfer_custom_cgram

    ; Set up menu state
    %a16()
    LDA #$0000 : STA !ram_cm_leave
    STA !ram_cm_stack_index : STA !ram_cm_cursor_stack
    STA !ram_cm_ctrl_mode : STA !ram_cm_ctrl_timer
    STA !IH_CONTROLLER_PRI_NEW : STA !IH_CONTROLLER_PRI

    LDA !FRAME_COUNTER : STA !ram_cm_input_counter
    LDA.w #MainMenu : STA !ram_cm_menu_stack
    LDA.w #MainMenu>>16 : STA !ram_cm_menu_bank

    JSL cm_count_etanks
    JSL cm_calculate_max
    RTS
}

cm_count_etanks:
{
    LDA !SAMUS_HP_MAX : STA $4204
    %a8()
    ; divide by 100
    LDA #$64 : STA $4206
    %a16()
    PEA $0000 : PLA ; wait for math
    ; 16-bit result
    LDA $4214 : STA !ram_cm_etanks
    RTL
}

ClearTopOfFXTilemap:
{
    LDX #$0EFE
-   LDA #$0C4E : STA $7E4000,X
    DEX #2 : BPL -

    LDX $0330
    LDA #$0700 : STA $D0,X
    LDA #$4000 : STA $D2,X
    LDA #$007E : STA $D4,X
    LDA #$5880 : STA $D5,X
    TXA : CLC : ADC #$0007 : STA $0330
    RTS
}

cm_wait_for_lag_frame:
{
    PHP : %ai8()

    LDA $05B8   ; lag frame counter
  .loop
    CMP $05B8 : BEQ .loop

    PLP
    RTS
}

initialize_ppu_long:
{
    PHP : %a16()
    LDA $7E33EA : STA !ram_cgram_cache+$2E
    %a8()
    STZ $420C ; clear HDMA enable flags
    LDA $85 : STA $7E33EA
    LDA $5B : STA $7E33EB
    LDA #$58 : STA $5B
    LDA #$17 : STA $7A
    STZ $6A : STZ $70 : STZ $73
    LDA #$20 : STA $2132
    LDA #$40 : STA $2132
    LDA #$80 : STA $2132
    STZ $2111 : STZ $2111
    STZ $2112 : STZ $2112
    %a16()
;    LDA #$5880 : STA $2116
;    LDA $2139
;    LDA #$3981 : STA $4310
;    LDA #$4100 : STA $4312
;    LDA #$007E : STA $4314
;    LDA #$0700 : STA $4315
;    STZ $4317 : STZ $4319
;    %a8()
;    LDA #$80 : STA $2115
;    LDA #$02 : STA $420B
    PLP
    RTL
}

restore_ppu_long:
{
    PHP; : %a16()
;    LDA #$5880 : STA $2116
;    LDA #$1801 : STA $4310
;    LDA #$4100 : STA $4312
;    LDA #$007E : STA $4314
;    LDA #$0700 : STA $4315
;    STZ $4317 : STZ $4319
    %a8()
;    LDA #$80 : STA $2115
;    LDA #$02 : STA $420B
    LDA $7E33EA : STA $85 : STA $420C
    LDA $7E33EB : STA $5B
    LDA $69 : STA $6A
    LDA $6E : STA $70
    LDA $71 : STA $73
    %a16()
    LDA !ram_cgram_cache+$2E : STA $7E33EA
    PLP
    RTL
}

play_music_long:
{
    %ai8()
    LDX #$02
-   JSR cm_wait_for_lag_frame
    PHX
    JSL $808F0C ; handle music queue
    JSL $808644 ; handle sfx
    PLX : DEX : BNE -
    RTL
}


; ----------
; Drawing
; ----------

cm_transfer_custom_tileset:
{
    PHP

    ; Load custom vram to normal BG3 location
    %a8()
    LDA #$80 : STA $802100 ; enable forced blanking
    LDA #$04 : STA $210C ; BG3 starts at $4000 (8000 in vram)
    LDA #$80 : STA $2115 ; word-access, incr by 1
    LDX #$4000 : STX $2116 ; VRAM address (8000 in vram)
    LDX.w #cm_hud_table1 : STX $4302 ; Source offset
    LDA.b #cm_hud_table1>>16 : STA $4304 ; Source bank
    LDX #$0400 : STX $4305 ; Size (0x10 = 1 tile)
    LDA #$01 : STA $4300 ; word, normal increment (DMA MODE)
    LDA #$18 : STA $4301 ; destination (VRAM write)
    LDA #$01 : STA $420B ; initiate DMA (channel 1)

    LDX.w #cm_hud_table2 : STX $4302 ; Source offset
    LDA.b #cm_hud_table2>>16 : STA $4304 ; Source bank
    LDX #$0400 : STX $4305 ; Size (0x10 = 1 tile)
    LDA #$01 : STA $420B ; initiate DMA (channel 1)

    LDA #$0F : STA $0F2100 ; disable forced blanking
    PLP
    RTL
}

cm_transfer_original_tileset:
{
    PHP
    %a8()

  .normal_vram
    ; Load in normal vram to normal BG3 location
    LDA #$80 : STA $802100 ; enable forced blanking
    LDA #$04 : STA $210C ; BG3 starts at $4000 (8000 in vram)
    LDA #$80 : STA $2115 ; word-access, incr by 1
    LDX #$4000 : STX $2116 ; VRAM address (8000 in vram)
    LDX.w #hudgfx_bin : STX $4302 ; Source offset
    LDA.b #hudgfx_bin>>16 : STA $4304 ; Source bank
    LDX #$0800 : STX $4305 ; Size (0x10 = 1 tile)
    LDA #$01 : STA $4300 ; word, normal increment (DMA MODE)
    LDA #$18 : STA $4301 ; destination (VRAM write)
    LDA #$01 : STA $420B ; initiate DMA (channel 1)
    LDA #$0F : STA $0F2100 ; disable forced blanking
    PLP
    RTL
}

cm_transfer_custom_cgram:
; $0A = Border & OFF   $7277
; $12 = Header         $48F3
; $1A = Num            $0000, $7FFF
; $32 = ON / Sel Num   $4376
; $34 = Selected item  $761F
; $3A = Sel Num        $0000, $761F
{
    PHP : %ai16()
    ; Backup gameplay palette
    LDA $7EC00A : STA !ram_cgram_cache
    LDA $7EC00E : STA !ram_cgram_cache+$02
    LDA $7EC012 : STA !ram_cgram_cache+$04
    LDA $7EC014 : STA !ram_cgram_cache+$06
    LDA $7EC016 : STA !ram_cgram_cache+$08
    LDA $7EC01A : STA !ram_cgram_cache+$0A
    LDA $7EC01C : STA !ram_cgram_cache+$0C
    LDA $7EC01E : STA !ram_cgram_cache+$0E ; not used?
    LDA $7EC032 : STA !ram_cgram_cache+$10
    LDA $7EC034 : STA !ram_cgram_cache+$12
    LDA $7EC036 : STA !ram_cgram_cache+$14
    LDA $7EC03A : STA !ram_cgram_cache+$16
    LDA $7EC03C : STA !ram_cgram_cache+$18
    LDA $7EC03E : STA !ram_cgram_cache+$1A ; not used?

    LDA #$7277 : STA $7EC00A                ; light pink
    LDA #$0000 : STA $7EC00E : STA $7EC016  ; black
    STA $7EC01A : STA $7EC036 : STA $7EC03A
    LDA #$48F3 : STA $7EC012                ; dark pink
    LDA #$7FFF : STA $7EC014 : STA $7EC01C  ; white
    LDA #$4376 : STA $7EC032                ; light green
    LDA #$761F : STA $7EC034 : STA $7EC03C  ; pink

    %i8()
    JSL transfer_cgram_long
    PLP
    RTL
}

cm_transfer_original_cgram:
{
    PHP
    %a16()

    ; Restore gameplay palette
    LDA !ram_cgram_cache : STA $7EC00A
    LDA !ram_cgram_cache+$02 : STA $7EC00E
    LDA !ram_cgram_cache+$04 : STA $7EC012
    LDA !ram_cgram_cache+$06 : STA $7EC014
    LDA !ram_cgram_cache+$08 : STA $7EC016
    LDA !ram_cgram_cache+$0A : STA $7EC01A
    LDA !ram_cgram_cache+$0C : STA $7EC01C
    LDA !ram_cgram_cache+$0E : STA $7EC01E ; not used?
    LDA !ram_cgram_cache+$10 : STA $7EC032
    LDA !ram_cgram_cache+$12 : STA $7EC034
    LDA !ram_cgram_cache+$14 : STA $7EC036
    LDA !ram_cgram_cache+$16 : STA $7EC03A
    LDA !ram_cgram_cache+$18 : STA $7EC03C
    LDA !ram_cgram_cache+$1A : STA $7EC03E ; not used?

    %i8()
    JSL transfer_cgram_long
    PLP
    RTL
}

cm_draw:
{
    PHP
    %ai16()
    JSR cm_tilemap_bg
    JSR cm_tilemap_menu
    JSR cm_tilemap_transfer
    PLP
    RTL
}

cm_tilemap_bg:
{
    ; Empty out BG3 tilemap
    LDA #$000E ; transparent tile
    LDX #$07FE ; size = $800 bytes

  .loopClearBG3
    STA !ram_tilemap_buffer,X
    DEX #2 : BPL .loopClearBG3

    ; Vertical edges
    LDX #$0000
    LDY #$0018 ; 24 rows

  .loopVertical
    LDA #$644E : STA !ram_tilemap_buffer+$082,X
    LDA #$244E : STA !ram_tilemap_buffer+$0BC,X
    TXA : CLC : ADC #$0040 : TAX
    DEY : BPL .loopVertical

    ; Horizontal edges
    LDX #$0000
    LDY #$001B ; 28 columns

  .loopHorizontal
    LDA #$A44F : STA !ram_tilemap_buffer+$044,X
    LDA #$244F : STA !ram_tilemap_buffer+$6C4,X
    INX #2
    DEY : BPL .loopHorizontal

  .fillInterior
    LDX #$0000
    LDY #$001B ; 28 columns
    LDA !MENU_BLANK ; blank background tile

  .loopBackground
    STA !ram_tilemap_buffer+$084,X
    STA !ram_tilemap_buffer+$0C4,X
    STA !ram_tilemap_buffer+$104,X
    STA !ram_tilemap_buffer+$144,X
    STA !ram_tilemap_buffer+$184,X
    STA !ram_tilemap_buffer+$1C4,X
    STA !ram_tilemap_buffer+$204,X
    STA !ram_tilemap_buffer+$244,X
    STA !ram_tilemap_buffer+$284,X
    STA !ram_tilemap_buffer+$2C4,X
    STA !ram_tilemap_buffer+$304,X
    STA !ram_tilemap_buffer+$344,X
    STA !ram_tilemap_buffer+$384,X
    STA !ram_tilemap_buffer+$3C4,X
    STA !ram_tilemap_buffer+$404,X
    STA !ram_tilemap_buffer+$444,X
    STA !ram_tilemap_buffer+$484,X
    STA !ram_tilemap_buffer+$4C4,X
    STA !ram_tilemap_buffer+$504,X
    STA !ram_tilemap_buffer+$544,X
    STA !ram_tilemap_buffer+$584,X
    STA !ram_tilemap_buffer+$5C4,X
    STA !ram_tilemap_buffer+$604,X
    STA !ram_tilemap_buffer+$644,X
    STA !ram_tilemap_buffer+$684,X
    INX #2
    DEY : BPL .loopBackground

  .done
    RTS
}

cm_tilemap_menu:
{
    LDX !ram_cm_stack_index
    LDA !ram_cm_menu_stack,X : STA !DP_MenuIndices
    LDA !ram_cm_menu_bank : STA !DP_MenuIndices+2 : STA !DP_CurrentMenu+2

    LDY #$0000 ; Y = menu item index
  .loop
    ; highlight if selected row
    TYA : CMP !ram_cm_cursor_stack,X : BEQ .selected
    LDA #$0000
    BRA .continue

  .selected
    LDA #$0010

  .continue
    ; later ORA'd with tile attributes
    STA !DP_Palette

    ; check for special entries (header/blank lines)
    LDA [!DP_MenuIndices],Y : BEQ .header
    CMP #$FFFF : BEQ .blank
    ; store menu item pointer
    STA !DP_CurrentMenu

    PHY : PHX

    ; X = action index (action type)
    LDA [!DP_CurrentMenu] : TAX

    ; !DP_CurrentMenu points to data after the action type index
    INC !DP_CurrentMenu : INC !DP_CurrentMenu

    ; draw menu item
    JSR (cm_draw_action_table,X)

    PLX : PLY

  .blank
    ; skip drawing blank lines
    INY #2
    BRA .loop

  .header
    STZ !DP_Palette
    ; menu pointer + index + 2 = header
    TYA : CLC : ADC !DP_MenuIndices : INC #2 : STA !DP_CurrentMenu
    LDX #$00C6
    JSR cm_draw_text

  .footer
    ; menu pointer + header pointer + 1 = footer
    TYA : CLC : ADC !DP_CurrentMenu : INC : STA !DP_CurrentMenu
    ; optional footer
    LDA [!DP_CurrentMenu] : CMP #$F007 : BNE .done

    ; INC past #$F007
    INC !DP_CurrentMenu : INC !DP_CurrentMenu : STZ !DP_Palette
    LDX #$0646 ; footer tilemap position
    JSR cm_draw_text
    RTS

  .done
    ; no footer, back up two bytes
    DEC !DP_CurrentMenu : DEC !DP_CurrentMenu
    RTS
}

cm_tilemap_transfer:
{
    JSR cm_wait_for_lag_frame  ; Wait for lag frame

    %a16()
    LDA #$5800 : STA $2116 ; VRAM addr
    LDA #$1801 : STA $4310 ; VRAM write
    LDA.w #!ram_tilemap_buffer : STA $4312 ; src addr
    LDA.w #!ram_tilemap_buffer>>16 : STA $4314 ; src bank
    LDA #$0800 : STA $4315 ; size
    STZ $4317 : STZ $4319 ; clear HDMA registers
    %a8()
    LDA #$80 : STA $2115 ; INC mode
    LDA #$02 : STA $420B ; enable DMA, channel 1
    JSL $808F0C ; handle music queue
;    JSL $8289EF ; handle sfx
    JSL $808644 ; handle sfx
    %a16()
    RTS
}

cm_draw_action_table:
    dw draw_toggle
    dw draw_toggle_bit
    dw draw_toggle_inverted
    dw draw_toggle_bit_inverted
    dw draw_numfield
    dw draw_numfield_hex
    dw draw_numfield_word
    dw draw_numfield_word_hex
    dw draw_choice
    dw draw_ctrl_shortcut
    dw draw_jsl
    dw draw_submenu

draw_toggle:
{
    ; grab the memory address (long)
    LDA [!DP_CurrentMenu] : INC !DP_CurrentMenu : INC !DP_CurrentMenu : STA !DP_Address
    LDA [!DP_CurrentMenu] : INC !DP_CurrentMenu : STA !DP_Address+2

    ; grab the toggle value
    LDA [!DP_CurrentMenu] : AND #$00FF : INC !DP_CurrentMenu : STA !DP_ToggleValue

    ; increment past JSL
    INC !DP_CurrentMenu : INC !DP_CurrentMenu

    ; Draw the text
    %item_index_to_vram_index()
    PHX : JSR cm_draw_text : PLX

    ; Set position for ON/OFF
    TXA : CLC : ADC #$002E : TAX

    %a8()
    ; set palette
    LDA !DP_Palette
    STA !ram_tilemap_buffer+1,X
    STA !ram_tilemap_buffer+3,X
    STA !ram_tilemap_buffer+5,X

    ; grab the value at that memory address
    LDA [!DP_Address] : CMP !DP_ToggleValue : BEQ .checked

    ; Off
    %a16()
    LDA #$244B : STA !ram_tilemap_buffer+0,X
    LDA #$244D : STA !ram_tilemap_buffer+2,X
    LDA #$244D : STA !ram_tilemap_buffer+4,X
    RTS

  .checked
    ; On
    %a16()
    LDA #$384B : STA !ram_tilemap_buffer+2,X
    LDA #$384C : STA !ram_tilemap_buffer+4,X
    RTS
}

draw_toggle_bit:
{
    ; grab the memory address (long)
    LDA [!DP_CurrentMenu] : INC !DP_CurrentMenu : INC !DP_CurrentMenu : STA !DP_Address
    LDA [!DP_CurrentMenu] : INC !DP_CurrentMenu : STA !DP_Address+2

    ; grab bitmask
    LDA [!DP_CurrentMenu] : INC !DP_CurrentMenu : INC !DP_CurrentMenu : STA !DP_ToggleValue

    ; increment past JSL
    INC !DP_CurrentMenu : INC !DP_CurrentMenu

    ; Draw the text
    %item_index_to_vram_index()
    PHX : JSR cm_draw_text : PLX

    ; Set position for ON/OFF
    TXA : CLC : ADC #$002E : TAX

    ; grab the value at that memory address
    LDA [!DP_Address] : AND !DP_ToggleValue : BNE .checked

    ; Off
    LDA #$244B : STA !ram_tilemap_buffer+0,X
    LDA #$244D : STA !ram_tilemap_buffer+2,X
    LDA #$244D : STA !ram_tilemap_buffer+4,X
    RTS

  .checked
    ; On
    %a16()
    LDA #$384B : STA !ram_tilemap_buffer+2,X
    LDA #$384C : STA !ram_tilemap_buffer+4,X
    RTS
}

draw_toggle_inverted:
{
    ; grab the memory address (long)
    LDA [!DP_CurrentMenu] : INC !DP_CurrentMenu : INC !DP_CurrentMenu : STA !DP_Address
    LDA [!DP_CurrentMenu] : INC !DP_CurrentMenu : STA !DP_Address+2

    ; grab the toggle value
    LDA [!DP_CurrentMenu] : AND #$00FF : INC !DP_CurrentMenu : STA !DP_ToggleValue

    ; increment past JSL
    INC !DP_CurrentMenu : INC !DP_CurrentMenu

    ; Draw the text
    %item_index_to_vram_index()
    PHX : JSR cm_draw_text : PLX

    ; Set position for ON/OFF
    TXA : CLC : ADC #$002E : TAX

    %a8()
    ; set palette
    LDA !DP_Palette
    STA !ram_tilemap_buffer+1,X
    STA !ram_tilemap_buffer+3,X
    STA !ram_tilemap_buffer+5,X

    ; grab the value at that memory address
    LDA [!DP_Address] : CMP !DP_ToggleValue : BNE .checked

    ; Off
    %a16()
    LDA #$244B : STA !ram_tilemap_buffer+0,X
    LDA #$244D : STA !ram_tilemap_buffer+2,X
    LDA #$244D : STA !ram_tilemap_buffer+4,X
    RTS

  .checked
    ; On
    %a16()
    LDA #$384B : STA !ram_tilemap_buffer+2,X
    LDA #$384C : STA !ram_tilemap_buffer+4,X
    RTS
}

draw_toggle_bit_inverted:
{
    ; grab the memory address (long)
    LDA [!DP_CurrentMenu] : INC !DP_CurrentMenu : INC !DP_CurrentMenu : STA !DP_Address
    LDA [!DP_CurrentMenu] : INC !DP_CurrentMenu : STA !DP_Address+2

    ; grab bitmask
    LDA [!DP_CurrentMenu] : INC !DP_CurrentMenu : INC !DP_CurrentMenu : STA !DP_ToggleValue

    ; increment past JSL
    INC !DP_CurrentMenu : INC !DP_CurrentMenu

    ; Draw the text
    %item_index_to_vram_index()
    PHX : JSR cm_draw_text : PLX

    ; Set position for ON/OFF
    TXA : CLC : ADC #$002C : TAX

    ; grab the value at that memory address
    LDA [!DP_Address] : AND !DP_ToggleValue : BEQ .checked

    ; Off
    LDA #$244B : STA !ram_tilemap_buffer+2,X
    LDA #$244D : STA !ram_tilemap_buffer+4,X
    LDA #$244D : STA !ram_tilemap_buffer+6,X
    RTS

  .checked
    ; On
    %a16()
    LDA #$384B : STA !ram_tilemap_buffer+4,X
    LDA #$384C : STA !ram_tilemap_buffer+6,X
    RTS
}

draw_numfield:
{
    ; grab the memory address (long)
    LDA [!DP_CurrentMenu] : INC !DP_CurrentMenu : INC !DP_CurrentMenu : STA !DP_Address
    LDA [!DP_CurrentMenu] : INC !DP_CurrentMenu : STA !DP_Address+2

    ; skip bounds and increment values
    INC !DP_CurrentMenu : INC !DP_CurrentMenu : INC !DP_CurrentMenu : INC !DP_CurrentMenu

    ; increment past JSL
    INC !DP_CurrentMenu : INC !DP_CurrentMenu

    ; Draw the text
    %item_index_to_vram_index()
    PHX : JSR cm_draw_text : PLX

    ; set position for the number
    TXA : CLC : ADC #$002E : TAX

    ; convert value to decimal
    LDA [!DP_Address] : AND #$00FF : JSR cm_hex2dec

    ; Clear out the area
    LDA !MENU_BLANK : STA !ram_tilemap_buffer+0,X
                      STA !ram_tilemap_buffer+2,X
                      STA !ram_tilemap_buffer+4,X

    ; Set palette
    %a8()
    LDA #$24 : ORA !DP_Palette : STA !DP_Palette+1
    LDA #'0' : STA !DP_Palette

    ; Draw numbers
    %a16()
    ; ones
    LDA !DP_ThirdDigit : CLC : ADC !DP_Palette : STA !ram_tilemap_buffer+4,X
    ; tens
    LDA !DP_SecondDigit : ORA !DP_FirstDigit : BEQ .done
    LDA !DP_SecondDigit : CLC : ADC !DP_Palette : STA !ram_tilemap_buffer+2,X
    ; hundreds
    LDA !DP_FirstDigit : BEQ .done
    CLC : ADC !DP_Palette : STA !ram_tilemap_buffer,X

  .done
    RTS
}

draw_numfield_hex:
{
    ; grab the memory address (long)
    LDA [!DP_CurrentMenu] : INC !DP_CurrentMenu : INC !DP_CurrentMenu : STA !DP_Address
    LDA [!DP_CurrentMenu] : INC !DP_CurrentMenu : STA !DP_Address+2

    ; skip bounds and increment values
    INC !DP_CurrentMenu : INC !DP_CurrentMenu : INC !DP_CurrentMenu : INC !DP_CurrentMenu

    ; increment past JSL
    INC !DP_CurrentMenu : INC !DP_CurrentMenu

    ; Draw the text
    %item_index_to_vram_index()
    PHX : JSR cm_draw_text : PLX

    ; set position for the number
    TXA : CLC : ADC #$0030 : TAX

    ; load the value
    LDA [!DP_Address] : AND #$00FF : STA !DP_DrawValue

    ; Clear out the area
    LDA !MENU_BLANK : STA !ram_tilemap_buffer+0,X
                      STA !ram_tilemap_buffer+2,X

    ; Draw numbers
    %a8()
    PHB
    LDA.b #HexMenuGFXTable>>16 : PHA : PLB
    %a16()
    ; (00X0)
    LDA !DP_DrawValue : AND #$00F0 : LSR #3 : TAY
    LDA.w HexMenuGFXTable,Y : STA !ram_tilemap_buffer,X
    ; (000X)
    LDA !DP_DrawValue : AND #$000F : ASL : TAY
    LDA.w HexMenuGFXTable,Y : STA !ram_tilemap_buffer+2,X
    PLB

    ; overwrite palette bytes
    %a8()
    LDA #$24 : ORA !DP_Palette
    STA !ram_tilemap_buffer+1,X : STA !ram_tilemap_buffer+3,X
    %a16()

    RTS
}

draw_numfield_word:
{
    ; grab the memory address (long)
    LDA [!DP_CurrentMenu] : INC !DP_CurrentMenu : INC !DP_CurrentMenu : STA !DP_Address
    LDA [!DP_CurrentMenu] : INC !DP_CurrentMenu : STA !DP_Address+2

    ; skip min/max and increment values
    INC !DP_CurrentMenu : INC !DP_CurrentMenu : INC !DP_CurrentMenu : INC !DP_CurrentMenu
    INC !DP_CurrentMenu : INC !DP_CurrentMenu : INC !DP_CurrentMenu : INC !DP_CurrentMenu

    ; increment past JSL
    INC !DP_CurrentMenu : INC !DP_CurrentMenu

    ; Draw the text
    %item_index_to_vram_index()
    PHX : JSR cm_draw_text : PLX

    ; set position for the number
    TXA : CLC : ADC #$002C : TAX

    ; convert value to decimal
    LDA [!DP_Address] : JSR cm_hex2dec

    ; Clear out the area
    LDA !MENU_BLANK : STA !ram_tilemap_buffer+0,X
                      STA !ram_tilemap_buffer+2,X
                      STA !ram_tilemap_buffer+4,X
                      STA !ram_tilemap_buffer+6,X

    ; Set palette
    %a8()
    LDA #$24 : ORA !DP_Palette : STA !DP_Palette+1
    LDA #'0' : STA !DP_Palette

    ; Draw numbers
    %a16()
    ; ones
    LDA !DP_ThirdDigit : CLC : ADC !DP_Palette : STA !ram_tilemap_buffer+6,X
    ; tens
    LDA !DP_SecondDigit : ORA !DP_FirstDigit
    ORA !DP_Temp : BEQ .done
    LDA !DP_SecondDigit : CLC : ADC !DP_Palette : STA !ram_tilemap_buffer+4,X
    ; hundreds
    LDA !DP_FirstDigit : ORA !DP_Temp : BEQ .done
    LDA !DP_FirstDigit : CLC : ADC !DP_Palette : STA !ram_tilemap_buffer+2,X
    ; thousands
    LDA !DP_Temp : BEQ .done
    CLC : ADC !DP_Palette : STA !ram_tilemap_buffer,X

  .done
    RTS
}

draw_numfield_word_hex:
{
    ; grab the memory address (long)
    LDA [!DP_CurrentMenu] : INC !DP_CurrentMenu : INC !DP_CurrentMenu : STA !DP_Address
    LDA [!DP_CurrentMenu] : INC !DP_CurrentMenu : STA !DP_Address+2

    ; skip bounds and increment values
;    INC !DP_CurrentMenu : INC !DP_CurrentMenu ; min
;    INC !DP_CurrentMenu : INC !DP_CurrentMenu ; max
;    INC !DP_CurrentMenu : INC !DP_CurrentMenu ; inc, held inc
;
;    ; increment past JSL
;    INC !DP_CurrentMenu : INC !DP_CurrentMenu

    ; Draw the text
    %item_index_to_vram_index()
    PHX : JSR cm_draw_text : PLX

    ; set position for the number
    TXA : CLC : ADC #$002C : TAX

    ; load the value
    LDA [!DP_Address] : STA !DP_DrawValue

    ; Clear out the area
    LDA !MENU_BLANK : STA !ram_tilemap_buffer+0,X
                      STA !ram_tilemap_buffer+2,X
                      STA !ram_tilemap_buffer+4,X
                      STA !ram_tilemap_buffer+6,X

    ; Draw numbers
    %a8()
    PHB
    LDA.b #HexMenuGFXTable>>16 : PHA : PLB
    %a16()
    ; (X000)
    LDA !DP_DrawValue : AND #$F000 : XBA : LSR #3 : TAY
    LDA.w HexMenuGFXTable,Y : STA !ram_tilemap_buffer,X
    ; (0X00)
    LDA !DP_DrawValue : AND #$0F00 : XBA : ASL : TAY
    LDA.w HexMenuGFXTable,Y : STA !ram_tilemap_buffer+2,X
    ; (00X0)
    LDA !DP_DrawValue : AND #$00F0 : LSR #3 : TAY
    LDA.w HexMenuGFXTable,Y : STA !ram_tilemap_buffer+4,X
    ; (000X)
    LDA !DP_DrawValue : AND #$000F : ASL : TAY
    LDA.w HexMenuGFXTable,Y : STA !ram_tilemap_buffer+6,X
    PLB

    ; overwrite palette bytes
    %a8()
    LDA #$24 : ORA !DP_Palette
    STA !ram_tilemap_buffer+1,X : STA !ram_tilemap_buffer+3,X
    STA !ram_tilemap_buffer+5,X : STA !ram_tilemap_buffer+7,X
    %a16()

    RTS
}

draw_choice:
{
    ; grab the memory address (long)
    LDA [!DP_CurrentMenu] : INC !DP_CurrentMenu : INC !DP_CurrentMenu : STA !DP_Address
    LDA [!DP_CurrentMenu] : INC !DP_CurrentMenu : STA !DP_Address+2

    ; skip the JSL target
    INC !DP_CurrentMenu : INC !DP_CurrentMenu

    ; Draw the text first
    %item_index_to_vram_index()
    PHX : JSR cm_draw_text : PLX

    ; set position for choice
    TXA : CLC : ADC #$001E : TAX

    ; grab the value at that memory address
    LDA [!DP_Address] : TAY

    ; find the correct text that should be drawn (the selected choice)
    ; skipping the first text that we already drew
    INY #2

  .loop_choices
    DEY : BEQ .found

  .loop_text
    LDA [!DP_CurrentMenu] : %a16() : INC !DP_CurrentMenu : %a8()
    CMP #$FF : BEQ .loop_choices
    BRA .loop_text

  .found
    %a16()
    JSR cm_draw_text
    RTS
}

draw_ctrl_shortcut:
{
    ; grab the memory address (long)
    LDA [!DP_CurrentMenu] : INC !DP_CurrentMenu : INC !DP_CurrentMenu : STA !DP_Address
    LDA [!DP_CurrentMenu] : INC !DP_CurrentMenu : STA !DP_Address+2

    ; draw the text
    %item_index_to_vram_index()
    PHX
    JSR cm_draw_text

    ; set position of inputs
    PLA : CLC : ADC #$0022 : TAX

    ; draw the inputs
    LDA [!DP_Address]
    JSR menu_ctrl_input_display

    RTS
}

draw_controller_input:
{
    ; grab the memory address (long)
    LDA [!DP_CurrentMenu] : INC !DP_CurrentMenu : INC !DP_CurrentMenu : STA !DP_Address
    STA !ram_cm_ctrl_assign
    LDA [!DP_CurrentMenu] : INC !DP_CurrentMenu : STA !DP_Address+2

    ; skip JSL target + argument
    INC !DP_CurrentMenu : INC !DP_CurrentMenu : INC !DP_CurrentMenu : INC !DP_CurrentMenu

    ; Draw the text
    %item_index_to_vram_index()
    PHX : JSR cm_draw_text : PLX

    ; set position for the input
    TXA : CLC : ADC #$0020 : TAX

    ; check if anything to draw
    LDA (!DP_Address) : AND #$E0F0 : BEQ .unbound

    ; determine which input to draw, using Y to refresh A
    TAY : AND !CTRL_A : BEQ .check_b : LDY #$0000 : BRA .draw
  .check_b
    TYA : AND !CTRL_B : BEQ .check_x : LDY #$0002 : BRA .draw
  .check_x
    TYA : AND !CTRL_X : BEQ .check_y : LDY #$0004 : BRA .draw
  .check_y
    TYA : AND !CTRL_Y : BEQ .check_l : LDY #$0006 : BRA .draw
  .check_l
    TYA : AND !CTRL_L : BEQ .check_r : LDY #$0008 : BRA .draw
  .check_r
    TYA : AND !CTRL_R : BEQ .check_s : LDY #$000A : BRA .draw
  .check_s
    TYA : AND !CTRL_SELECT : BEQ .unbound : LDY #$000C

  .draw
    LDA.w .CtrlMenuGFXTable,Y : STA !ram_tilemap_buffer,X
    RTS

  .unbound
    LDA !MENU_BLANK : STA !ram_tilemap_buffer,X
    RTS

  .CtrlMenuGFXTable
    ;    A      B      X      Y      L      R    Select
    ;  $0080  $8000  $0040  $4000  $0020  $0010  $2000
    dw $288F, $2887, $288E, $2886, $288D, $288C, $2885
}

draw_jsl:
draw_submenu:
{
    ; skip JSL address
    INC !DP_CurrentMenu : INC !DP_CurrentMenu

    ; skip argument
    INC !DP_CurrentMenu : INC !DP_CurrentMenu

    ; draw text normally
    %item_index_to_vram_index()
    JSR cm_draw_text
    RTS
}

cm_draw_text:
; X = pointer to tilemap area (STA !ram_tilemap_buffer,X)
{
    %a8()
    LDY #$0000
    ; terminator
    LDA [!DP_CurrentMenu],Y : INY : CMP #$FF : BEQ .end
    ; ORA with palette info
    ORA !DP_Palette : STA !DP_Palette

  .loop
    LDA [!DP_CurrentMenu],Y : CMP #$FF : BEQ .end       ; terminator
    STA !ram_tilemap_buffer,X : INX                     ; tile
    LDA !DP_Palette : STA !ram_tilemap_buffer,X : INX   ; palette
    INY : BRA .loop

  .end
    %a16()
    RTS
}


; --------------
; Input Display
; --------------

menu_ctrl_input_display:
; X = pointer to tilemap area (STA !ram_tilemap_buffer,X)
; A = Controller word
{
    JSR menu_ctrl_clear_input_display

    XBA
    LDY #$0000
  .loop
    PHA
    BIT #$0001 : BEQ .no_draw

    TYA : CLC : ADC #$0070
    XBA : ORA !DP_Palette : XBA
    STA !ram_tilemap_buffer,X : INX #2

  .no_draw
    PLA
    INY : LSR : BNE .loop

  .done
    RTS
}


menu_ctrl_clear_input_display:
{
    ; X = pointer to tilemap area
    PHA
    LDA !MENU_BLANK
    STA !ram_tilemap_buffer+0,X
    STA !ram_tilemap_buffer+2,X
    STA !ram_tilemap_buffer+4,X
    STA !ram_tilemap_buffer+6,X
    STA !ram_tilemap_buffer+8,X
    STA !ram_tilemap_buffer+10,X
    STA !ram_tilemap_buffer+12,X
    STA !ram_tilemap_buffer+14,X
    STA !ram_tilemap_buffer+16,X
    PLA
    RTS
}


; ---------
; Logic
; ---------

cm_loop:
{
    %ai16()
    JSR cm_wait_for_lag_frame
    JSL $808F0C ; Music queue
;    JSL $8289EF ; Sound fx queue
    JSL $808644 ; Sound fx queue

    LDA !ram_cm_leave : BEQ .check_ctrl_mode
    RTS ; Exit menu loop

  .check_ctrl_mode
    LDA !ram_cm_ctrl_mode : BEQ .get_player_inputs
    ; editing controller shortcut
    JSR cm_ctrl_mode
    BRA cm_loop

  .get_player_inputs
    JSR cm_get_inputs : STA !ram_cm_controller : BEQ cm_loop
    BIT #$0080 : BNE .pressedA
    BIT #$8000 : BNE .pressedB
    BIT #$0040 : BNE .pressedX
    BIT #$4000 : BNE .pressedY
    BIT #$2000 : BNE .pressedSelect
    BIT #$1000 : BNE .pressedStart
    BIT #$0800 : BNE .pressedUp
    BIT #$0400 : BNE .pressedDown
    BIT #$0100 : BNE .pressedRight
    BIT #$0200 : BNE .pressedLeft
    BIT #$0020 : BNE .pressedL
    BIT #$0010 : BNE .pressedR
    BRA cm_loop

  .pressedB
    JSL cm_previous_menu
    BRA .redraw

  .pressedDown
    LDA #$0002
    JSR cm_move
    BRA .redraw

  .pressedUp
    LDA #$FFFE
    JSR cm_move
    BRA .redraw

  .pressedL
    ; jump to top menu item
    LDX !ram_cm_stack_index
    LDA #$0000 : STA !ram_cm_cursor_stack,X
    %sfxmove()
    BRA .redraw

  .pressedR
    ; jump to bottom menu item
    LDX !ram_cm_stack_index
    LDA !ram_cm_cursor_max : DEC #2 : STA !ram_cm_cursor_stack,X
    %sfxmove()
    BRA .redraw

  .pressedA
  .pressedX
  .pressedY
  .pressedLeft
  .pressedRight
    JSR cm_execute
    BRA .redraw

  .pressedStart
  .pressedSelect
    LDA #$0001 : STA !ram_cm_leave
    JMP cm_loop

  .redraw
    JSL cm_draw
    JMP cm_loop
}

cm_ctrl_mode:
; This routine cuts off input handling in cm_loop to keep focus on the selected controller shortcut
; Held inputs are displayed until held for 120 frames
{
    JSL $809459 ; Read controller input
    LDA !IH_CONTROLLER_PRI

    ; set palette
    %a8() : LDA #$28 : STA !DP_Palette : %a16()

    LDA !IH_CONTROLLER_PRI : BEQ .clear_and_draw
    CMP !ram_cm_ctrl_last_input : BNE .clear_and_draw

    ; Holding an input for more than one second
    LDA !ram_cm_ctrl_timer : INC : STA !ram_cm_ctrl_timer
    CMP.w #0060 : BNE .next_frame

    ; disallow inputs that match the menu shortcut
    LDA !DP_CtrlInput : CMP.w #!sram_ctrl_menu : BEQ .store
    LDA !IH_CONTROLLER_PRI : CMP !sram_ctrl_menu : BNE .store
    %sfxfail()
    ; set cursor position to 0 (menu shortcut)
    LDX !ram_cm_stack_index
    LDA #$0000 : STA !ram_cm_cursor_stack,X
    BRA .exit

  .store
    ; Store controller input to SRAM
    LDA !IH_CONTROLLER_PRI : STA [!DP_CtrlInput]
    %sfxconfirm()
    BRA .exit

  .clear_and_draw
    STA !ram_cm_ctrl_last_input
    LDA #$0000 : STA !ram_cm_ctrl_timer

    ; Put text cursor in X
    LDX !ram_cm_stack_index
    LDA !ram_cm_cursor_stack,X : ASL #5 : CLC : ADC #$0168 : TAX

    ; Input display
    LDA !IH_CONTROLLER_PRI
    JSR menu_ctrl_input_display
    JSR cm_tilemap_transfer

  .next_frame
    RTS

  .exit
    LDA #$0000
    STA !ram_cm_ctrl_last_input
    STA !ram_cm_ctrl_mode
    STA !ram_cm_ctrl_timer
    JSL cm_draw
    RTS
}

cm_previous_menu:
{
    JSL cm_go_back
    JML cm_calculate_max
}

cm_go_back:
{
    ; make sure next time we go to a submenu, we start on the first line.
    LDX !ram_cm_stack_index
    LDA #$0000 : STA !ram_cm_cursor_stack,X

    ; make sure we dont set a negative number
    DEX #2 : BPL .done

    ; leave menu 
    LDA #$0001 : STA !ram_cm_leave

    LDX #$0000
  .done
    STX !ram_cm_stack_index : BNE .end

    ; Reset submenu bank when back at main menu
    LDA.w #MainMenu>>16 : STA !ram_cm_menu_bank

  .end
    %sfxgoback()
    RTL
}

cm_calculate_max:
{
    LDX !ram_cm_stack_index
    LDA !ram_cm_menu_stack,X : STA !DP_MenuIndices
    LDA !ram_cm_menu_bank : STA !DP_MenuIndices+2

    LDX #$0000
  .loop
    LDA [!DP_MenuIndices] : BEQ .done
    INC !DP_MenuIndices : INC !DP_MenuIndices
    INX #2 ; count menu items in X
    BRA .loop

  .done
    ; store total menu items +2
    TXA : STA !ram_cm_cursor_max
    RTL
}

cm_get_inputs:
{
    ; Make sure we don't read joysticks twice in the same frame
    LDA !FRAME_COUNTER : CMP !ram_cm_input_counter
    PHP : STA !ram_cm_input_counter : PLP : BNE .input_read

    JSL $809459 ; Read controller input

  .input_read
    LDA !IH_CONTROLLER_PRI_NEW : BEQ .check_holding

    ; Initial delay of $0E frames
    LDA #$000E : STA !ram_cm_input_timer

    ; Return the new input
    LDA !IH_CONTROLLER_PRI_NEW
    RTS

  .check_holding
    ; Check if we're holding the dpad
    LDA !IH_CONTROLLER_PRI : AND #$0F00 : BEQ .noinput

    ; Decrement delay timer and check if it's zero
    LDA !ram_cm_input_timer : DEC : STA !ram_cm_input_timer : BNE .noinput

    ; Set new delay, default is 2
    LDA #$0002 : STA !ram_cm_input_timer

    ; Return held input
    LDA !IH_CONTROLLER_PRI : AND #$0F00 : ORA !IH_INPUT_HELD
    RTS

  .noinput
    LDA #$0000
    RTS
}

cm_move:
{
    STA !DP_Temp
    LDX !ram_cm_stack_index
    LDA !DP_Temp : CLC : ADC !ram_cm_cursor_stack,X : BPL .positive
    LDA !ram_cm_cursor_max : DEC #2 : BRA .inBounds

  .positive
    CMP !ram_cm_cursor_max : BNE .inBounds
    LDA #$0000

  .inBounds
    STA !ram_cm_cursor_stack,X : TAY

    ; check for blank menu line ($FFFF)
    LDA [!DP_MenuIndices],Y : CMP #$FFFF : BNE .end

    ; repeat move to skip blank line
    LDA !DP_Temp : BRA cm_move

  .end
    %sfxmove()
    RTS
}


; --------
; Execute
; --------

cm_execute:
{
    LDX !ram_cm_stack_index
    LDA !ram_cm_menu_stack,X : STA !DP_CurrentMenu
    LDA !ram_cm_menu_bank : STA !DP_CurrentMenu+2
    LDA !ram_cm_cursor_stack,X : TAY
    LDA [!DP_CurrentMenu],Y : STA !DP_CurrentMenu

    ; Safety net incase blank line selected
    CMP #$FFFF : BEQ .end

    ; X = action index (action type)
    LDA [!DP_CurrentMenu] : TAX

    ; !DP_CurrentMenu points to data after the action type index
    INC !DP_CurrentMenu : INC !DP_CurrentMenu

    ; Execute action
    JSR (cm_execute_action_table,X)

  .end
    RTS
}

cm_execute_action_table:
    dw execute_toggle
    dw execute_toggle_bit
    dw execute_toggle ; inverted
    dw execute_toggle_bit ; inverted
    dw execute_numfield
    dw execute_numfield_hex
    dw execute_numfield_word
    dw execute_numfield_word_hex
    dw execute_choice
    dw execute_ctrl_shortcut
    dw execute_jsl
    dw execute_submenu

execute_toggle:
{
    ; Grab address (long)
    LDA [!DP_CurrentMenu] : INC !DP_CurrentMenu : INC !DP_CurrentMenu : STA !DP_Address
    LDA [!DP_CurrentMenu] : INC !DP_CurrentMenu : STA !DP_Address+2

    ; Grab toggle value
    LDA [!DP_CurrentMenu] : INC !DP_CurrentMenu : AND #$00FF : STA !DP_ToggleValue

    ; Grab JSL target
    LDA [!DP_CurrentMenu] : INC !DP_CurrentMenu : INC !DP_CurrentMenu : STA !DP_JSLTarget

    %a8()
    LDA [!DP_Address] : CMP !DP_ToggleValue : BEQ .toggleOff
    ; toggle on
    LDA !DP_ToggleValue : STA [!DP_Address]
    BRA .jsl

  .toggleOff
    LDA #$00 : STA [!DP_Address]

  .jsl
    %a16()
    ; skip if JSL target is zero
    LDA !DP_JSLTarget : BEQ .end

    ; Set return address for indirect JSL
    LDA !ram_cm_menu_bank : STA !DP_JSLTarget+2
    PHK : PEA .end-1

    ; addr in A
    LDA [!DP_Address] : LDX #$0000
    JML.w [!DP_JSLTarget]

  .end
    %ai16()
    %sfxtoggle()
    RTS
}

execute_toggle_bit:
{
    ; Load the address
    LDA [!DP_CurrentMenu] : INC !DP_CurrentMenu : INC !DP_CurrentMenu : STA !DP_Address
    LDA [!DP_CurrentMenu] : INC !DP_CurrentMenu : STA !DP_Address+2

    ; Load which bit(s) to toggle
    LDA [!DP_CurrentMenu] : INC !DP_CurrentMenu : INC !DP_CurrentMenu : STA !DP_ToggleValue

    ; Load JSL target
    LDA [!DP_CurrentMenu] : INC !DP_CurrentMenu : INC !DP_CurrentMenu : STA !DP_JSLTarget

    ; Toggle the bit
    LDA [!DP_Address] : EOR !DP_ToggleValue : STA [!DP_Address]

    ; skip if JSL target is zero
    LDA !DP_JSLTarget : BEQ .end

    ; Set return address for indirect JSL
    LDA !ram_cm_menu_bank : STA !DP_JSLTarget+2
    PHK : PEA .end-1

    ; addr in A
    LDA [!DP_Address] : LDX #$0000
    JML.w [!DP_JSLTarget]

 .end
    %ai16()
    %sfxtoggle()
    RTS
}

execute_numfield_hex:
execute_numfield:
{
    ; grab the memory address (long)
    LDA [!DP_CurrentMenu] : INC !DP_CurrentMenu : INC !DP_CurrentMenu : STA !DP_Address
    LDA [!DP_CurrentMenu] : INC !DP_CurrentMenu : STA !DP_Address+2

    ; grab minimum and maximum values
    LDA [!DP_CurrentMenu] : INC !DP_CurrentMenu : AND #$00FF : STA !DP_Minimum
    LDA [!DP_CurrentMenu] : INC !DP_CurrentMenu : AND #$00FF : INC : STA !DP_Maximum ; INC for convenience

    ; check for held inputs
    LDA !ram_cm_controller : BIT !IH_INPUT_HELD : BNE .input_held
    ; grab normal increment and skip past both
    LDA [!DP_CurrentMenu] : INC !DP_CurrentMenu : INC !DP_CurrentMenu
    BRA .store_increment

  .input_held
    ; grab faster increment and skip past both
    INC !DP_CurrentMenu : LDA [!DP_CurrentMenu] : INC !DP_CurrentMenu

  .store_increment
    AND #$00FF : STA !DP_Increment

    ; determine dpad direction
    LDA !ram_cm_controller : BIT #$0200 : BNE .pressed_left
    ; pressed right, inc
    LDA [!DP_Address] : AND #$00FF : CLC : ADC !DP_Increment
    CMP !DP_Maximum : BCS .set_to_min
    %a8() : STA [!DP_Address] : BRA .jsl

  .pressed_left ; dec
    LDA [!DP_Address] : AND #$00FF : SEC : SBC !DP_Increment : BMI .set_to_max
    CMP !DP_Minimum : BCC .set_to_max
    %a8() : STA [!DP_Address] : BRA .jsl

  .set_to_min
    %a8()
    LDA !DP_Minimum : STA [!DP_Address] : BRA .jsl

  .set_to_max
    %a8()
    LDA !DP_Maximum : DEC : STA [!DP_Address]

  .jsl
    %a16()
    ; grab JSL pointer and skip if zero
    LDA [!DP_CurrentMenu] : BEQ .end
    STA !DP_JSLTarget

    ; Set return address for indirect JSL
    LDA !ram_cm_menu_bank : STA !DP_JSLTarget+2
    PHK : PEA .end-1

    ; addr in A
    LDA [!DP_Address] : AND #$00FF : LDX #$0000
    JML.w [!DP_JSLTarget]

  .end
    %ai16()
    %sfxnumber()
    RTS
}

execute_numfield_word:
{
    ; grab the memory address (long)
    LDA [!DP_CurrentMenu] : INC !DP_CurrentMenu : INC !DP_CurrentMenu : STA !DP_DigitAddress
    LDA [!DP_CurrentMenu] : INC !DP_CurrentMenu : STA !DP_DigitAddress+2

    ; grab minimum and maximum values
    LDA [!DP_CurrentMenu] : INC !DP_CurrentMenu : INC !DP_CurrentMenu : STA !DP_DigitMinimum
    LDA [!DP_CurrentMenu] : INC !DP_CurrentMenu : INC !DP_CurrentMenu : INC : STA !DP_DigitMaximum ; INC for convenience

  .check_held
    ; check for held inputs
    LDA !ram_cm_controller : BIT !IH_INPUT_HELD : BNE .input_held
    ; grab normal increment and skip past both
    LDA [!DP_CurrentMenu] : INC !DP_CurrentMenu : INC !DP_CurrentMenu
    INC !DP_CurrentMenu : INC !DP_CurrentMenu
    BRA .store_increment

  .input_held
    ; grab faster increment and skip past both
    INC !DP_CurrentMenu : INC !DP_CurrentMenu
    LDA [!DP_CurrentMenu] : INC !DP_CurrentMenu : INC !DP_CurrentMenu

  .store_increment
    STA !DP_Increment

    ; left/right = increment
    LDA !ram_cm_controller : BIT !IH_INPUT_LEFT : BNE .pressed_left
    ; pressed right (or A/X/Y), inc
    LDA [!DP_DigitAddress] : CLC : ADC !DP_Increment
    CMP !DP_DigitMaximum : BCS .set_to_min
    STA [!DP_DigitAddress] : BRA .jsl

  .pressed_left ; dec
    LDA [!DP_DigitAddress] : SEC : SBC !DP_Increment
    CMP !DP_DigitMinimum : BMI .set_to_max
    CMP !DP_DigitMaximum : BCS .set_to_max
    STA [!DP_DigitAddress]
    BRA .jsl

  .set_to_min
    LDA !DP_DigitMinimum : STA [!DP_DigitAddress]
    BRA .jsl

  .set_to_max
    LDA !DP_DigitMaximum : DEC : STA [!DP_DigitAddress]

  .jsl
    ; grab JSL pointer and skip if zero
    LDA [!DP_CurrentMenu] : BEQ .end
    STA !DP_JSLTarget

    ; Set return address for indirect JSL
    LDA !ram_cm_menu_bank : STA !DP_JSLTarget+2
    PHK : PEA .end-1

    ; addr in A
    LDA [!DP_Address] : LDX #$0000
    JML.w [!DP_JSLTarget]

  .end
    %ai16()
    %sfxnumber()
    RTS
}

execute_numfield_word_hex:
{
;    ; grab the memory address (long)
;    LDA [!DP_CurrentMenu] : INC !DP_CurrentMenu : INC !DP_CurrentMenu : STA !DP_Address
;    LDA [!DP_CurrentMenu] : INC !DP_CurrentMenu : STA !DP_Address+2
;
;    ; grab minimum and maximum values
;    LDA [!DP_CurrentMenu] : INC !DP_CurrentMenu : INC !DP_CurrentMenu : STA !DP_Minimum
;    LDA [!DP_CurrentMenu] : INC !DP_CurrentMenu : INC !DP_CurrentMenu : INC : STA !DP_Maximum ; INC for convenience
;
;    ; check for held inputs
;    LDA !ram_cm_controller : BIT !IH_INPUT_HELD : BNE .input_held
;    ; grab normal increment and skip past both
;    LDA [!DP_CurrentMenu] : INC !DP_CurrentMenu : INC !DP_CurrentMenu
;    BRA .store_increment
;
;  .input_held
;    ; grab faster increment and skip past both
;    INC !DP_CurrentMenu : LDA [!DP_CurrentMenu] : INC !DP_CurrentMenu
;
;  .store_increment
;    AND #$00FF : STA !DP_Increment
;
;    ; determine dpad direction
;    LDA !ram_cm_controller : BIT #$0200 : BNE .pressed_left
;    ; pressed right, inc
;    LDA [!DP_Address] : CLC : ADC !DP_Increment
;    CMP !DP_Maximum : BCS .set_to_min
;    STA [!DP_Address] : BRA .jsl
;
;  .pressed_left ; dec
;    LDA [!DP_Address] : SEC : SBC !DP_Increment : BMI .set_to_max
;    CMP !DP_Minimum : BCC .set_to_max
;    STA [!DP_Address] : BRA .jsl
;
;  .set_to_min
;    LDA !DP_Minimum : STA [!DP_Address] : BRA .jsl
;
;  .set_to_max
;    LDA !DP_Maximum : DEC : STA [!DP_Address]
;
;  .jsl
;    ; grab JSL pointer and skip if zero
;    LDA [!DP_CurrentMenu] : BEQ .end
;    STA !DP_JSLTarget
;
;    ; Set return address for indirect JSL
;    LDA !ram_cm_menu_bank : STA !DP_JSLTarget+2
;    PHK : PEA .end-1
;
;    ; addr in A
;    LDA [!DP_Address] : AND #$00FF : LDX #$0000
;    JML.w [!DP_JSLTarget]
;
;  .end
;    %ai16()
;    %sfxnumber()
    %sfxfail()
    RTS
}

execute_choice:
{
    ; grab the memory address (long)
    LDA [!DP_CurrentMenu] : INC !DP_CurrentMenu : INC !DP_CurrentMenu : STA !DP_Address
    LDA [!DP_CurrentMenu] : INC !DP_CurrentMenu : STA !DP_Address+2

    LDA [!DP_CurrentMenu] : INC !DP_CurrentMenu : INC !DP_CurrentMenu : STA !DP_JSLTarget

    ; we either increment or decrement
    LDA !ram_cm_controller : BIT #$0200 : BNE .pressed_left
    ; pressed right
    LDA [!DP_Address] : INC : BRA .bounds_check

  .pressed_left
    LDA [!DP_Address] : DEC

  .bounds_check
    TAX         ; X = new value
    LDY #$0000  ; Y will be set to max
    %a8()

  .loop_choices
    LDA [!DP_CurrentMenu] : %a16() : INC !DP_CurrentMenu : %a8() : CMP #$FF : BEQ .loop_done

  .loop_text
    LDA [!DP_CurrentMenu] : %a16() : INC !DP_CurrentMenu : %a8()
    CMP #$FF : BNE .loop_text
    INY : BRA .loop_choices

  .loop_done
    ; Y = maximum + 2
    ; for convenience so we can use BCS. We do one more DEC in `.set_to_max`
    ; in order to get the actual max.
    DEY

    %a16()
    ; X = new value (might be out of bounds)
    TXA : BMI .set_to_max
    TYA : STA !DP_Maximum
    TXA : CMP !DP_Maximum : BCS .set_to_zero

    BRA .store

  .set_to_zero
    LDA #$0000 : BRA .store

  .set_to_max
    TYA : DEC

  .store
    STA [!DP_Address]

    ; skip if JSL target is zero
    LDA !DP_JSLTarget : BEQ .end

    ; Set return address for indirect JSL
    LDA !ram_cm_menu_bank : STA !DP_JSLTarget+2
    PHK : PEA .end-1

    ; addr in A
    LDA [!DP_Address] : LDX #$0000
    JML.w [!DP_JSLTarget]

  .end
    %ai16()
    %sfxtoggle()
    RTS
}

execute_ctrl_shortcut:
{
    ; < and > should do nothing here
    ; also ignore the input held flag
    LDA !ram_cm_controller : BIT #$0301 : BNE .end

    ; grab memory address (long)
    LDA [!DP_CurrentMenu] : INC !DP_CurrentMenu : INC !DP_CurrentMenu : STA !DP_CtrlInput
    LDA [!DP_CurrentMenu] : INC !DP_CurrentMenu : STA !DP_CtrlInput+2

    ; press X to delete a shortcut
    LDA !ram_cm_controller : BIT !CTRL_X : BNE .reset_shortcut

    ; enable ctrl mode to edit shortcuts
    LDA #$0001 : STA !ram_cm_ctrl_mode
    LDA #$0000 : STA !ram_cm_ctrl_timer
    RTS

  .reset_shortcut
    LDA.w #!sram_ctrl_menu : CMP !DP_CtrlInput : BEQ .end
    %sfxconfirm()

    LDA #$0000 : STA [!DP_CtrlInput]

  .end
    RTS
}

execute_jsl:
{
    ; <, > and X should do nothing here
    ; also ignore input held flag
    LDA !ram_cm_controller : BIT #$0341 : BNE .end

    ; !DP_JSLTarget = JSL target
    LDA [!DP_CurrentMenu] : INC !DP_CurrentMenu : INC !DP_CurrentMenu : STA !DP_JSLTarget

    ; Set return address for indirect JSL
    LDA !ram_cm_menu_bank : STA !DP_JSLTarget+2
    PHK : PEA .end-1

    ; Y = Argument
    LDA [!DP_CurrentMenu] : TAY

    LDX #$0000
    JML.w [!DP_JSLTarget]

  .end
    %ai16()
    RTS
}

execute_submenu:
{
    ; <, > and X should do nothing here
    ; also ignore input held flag
    LDA !ram_cm_controller : BIT #$0341 : BNE .end

    ; !DP_JSLTarget = JSL target
    LDA [!DP_CurrentMenu] : INC !DP_CurrentMenu : INC !DP_CurrentMenu : STA !DP_JSLTarget

    ; Set bank of action_submenu
    ; instead of the new menu's bank
    LDA.w #action_submenu>>16 : STA !DP_JSLTarget+2

    ; Set return address for indirect JSL
    PHK : PEA .end-1

    ; Y = Argument
    LDA [!DP_CurrentMenu] : TAY

    LDX #$0000
    JML.w [!DP_JSLTarget]

  .end
    %ai16()
    RTS
}

cm_hex2dec:
{
    ; store 16-bit dividend
    STA $4204

    ; divide by 100
    %a8()
    LDA #$64 : STA $4206
    %a16()
    PEA $0000 : PLA ; wait for math

    ; store result and use remainder as new dividend
    LDA $4214 : STA !DP_Temp
    LDA $4216 : STA $4204

    ; divide by 10
    %a8()
    LDA #$0A : STA $4206
    %a16()
    PEA $0000 : PLA ; wait for math

    ; store result and remainder, divide the rest
    LDA $4214 : STA !DP_SecondDigit ; tens
    LDA $4216 : STA !DP_ThirdDigit ; ones
    LDA !DP_Temp : STA $4204

    ; divide by 10
    %a8()
    LDA #$0A : STA $4206
    %a16()
    PEA $0000 : PLA ; wait for math

    ; store result and remainder
    LDA $4214 : STA !DP_Temp ; thousands
    LDA $4216 : STA !DP_FirstDigit ; hundreds

    RTS
}

SilenceSFX:
{
    LDA #$0002
    JSL $809049
    LDA #$0071
    JSL $8090CB
    LDA #$0001
    JML $80914D
}
print pc, " menu end"
%endfree(9B)


; ----------
; Resources
; ----------

org $92D246
print pc, " menu data1 start"
cm_hud_table1:
    incbin ../resources/cm_gfx1.bin
warnpc $92D7D2
print pc, " menu data1 end"

org $92E768
print pc, " menu data2 start"
cm_hud_table2:
    incbin ../resources/cm_gfx2.bin

HexMenuGFXTable:
    dw $2C20, $2C21, $2C22, $2C23, $2C24, $2C25, $2C26, $2C27, $2C28, $2C29, $2C00, $2C01, $2C02, $2C03, $2C04, $2C05
warnpc $92ED23
print pc, " menu data2 end"


print pc, " mainmenu start"
incsrc mainmenu.asm
print pc, " mainmenu end"
