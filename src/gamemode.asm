

; ------------
; Input Checks
; ------------

; hijack main game loop for input checks
org $8A8023
    JSL gamemode_start : BCS end_of_normal_gameplay

org $8A802E
    ; skip gamemode JSR if the current frame doesn't need to be processed any further
    end_of_normal_gameplay:


%startfree(8B)
print pc, " gamemode start"
gamemode_start:
{
    PHB
    PHK : PLB

    ; check for new inputs
    LDA !IH_CONTROLLER_PRI_NEW : BNE +
    CLC : BRA .done

if !SAVESTATES
    ; check for savestate inputs
+   LDA !IH_CONTROLLER_PRI : CMP !sram_ctrl_save_state : BNE +
    AND !IH_CONTROLLER_PRI_NEW : BEQ +
    JSL save_state
    SEC : BRA .done

    ; check for loadstate inputs
+   LDA !IH_CONTROLLER_PRI : CMP !sram_ctrl_load_state : BNE +
    AND !IH_CONTROLLER_PRI_NEW : BEQ +
    LDA !sram_savestate_safeword : CMP !SAFEWORD : BNE +
    JSL load_state
    SEC : BRA .done
endif

if !DEV
+   ; test code
    LDA !IH_CONTROLLER_PRI : CMP #$8470 : BNE +
    AND !IH_CONTROLLER_PRI_NEW : BEQ +
    JSR TestCode
    CLC : BRA .done
endif

    ; check for menu inputs
+   LDA !IH_CONTROLLER_PRI : CMP !sram_ctrl_menu : BNE +
    AND !IH_CONTROLLER_PRI_NEW : BEQ +

    ; Set IRQ vector
    LDA $AB : PHA
    LDA #$0000 : STA $AB

    ; Enter MainMenu
    JSL cm_start

    ; Restore IRQ vector
    PLA : STA $AB

    SEC : BRA .done

    ; exit carry clear to continue normal gameplay
+   CLC

  .done
    %ai16()
    LDA !GAMEMODE : AND #$00FF
    PLB
    RTL
}

if !DEV
TestCode:
{
    RTS
    NOP #50
    RTS
}
endif
print pc, " gamemode end"
%endfree(8B)
