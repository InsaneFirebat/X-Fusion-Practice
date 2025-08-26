
; Instructions:

; incsrc this file near the beginning of assembly (top of main.asm)
; Use %startfree(XX) in place of your freespace orgs and replace XX with the desired bank
; Use %endfree(XX) at the end of freespace, before the next %startfree() macro
; Use %printfreespace() at the end of assembly (bottom of main.asm) to print debug info about freespace usage

; Original design by cout https://github.com/cout/baby_metroid/blob/main/src/freespace.asm


; Assign start of freespace per bank
; Only one chunk allowed per bank
; Ommited banks have no freespace
!START_FREESPACE_80 = $80FE89
!START_FREESPACE_81 = $81FF22
!START_FREESPACE_83 = $83B974
!START_FREESPACE_84 = $84FEC9
!START_FREESPACE_8B = $8BF754
!START_FREESPACE_90 = $90FF6D
!START_FREESPACE_92 = $92B1C7
!START_FREESPACE_9B = $9BCBFB

; Assign end of freespace per bank
; Set for freespace that doesn't end at the bank border
!END_FREESPACE_80 = $80FFD0
!END_FREESPACE_81 = $810000+$10000
!END_FREESPACE_83 = $83BA00
!END_FREESPACE_84 = $840000+$10000
!END_FREESPACE_8B = $8B0000+$10000
!END_FREESPACE_90 = $900000+$10000
!END_FREESPACE_92 = $92CBED
!END_FREESPACE_9B = $9BE000

; These defines will be reassigned by the endfree macro
; This leaves our starting location untouched for later evaluation
!FREESPACE_80 = !START_FREESPACE_80
!FREESPACE_81 = !START_FREESPACE_81
!FREESPACE_83 = !START_FREESPACE_83
!FREESPACE_84 = !START_FREESPACE_84
!FREESPACE_8B = !START_FREESPACE_8B
!FREESPACE_90 = !START_FREESPACE_90
!FREESPACE_92 = !START_FREESPACE_92
!FREESPACE_9B = !START_FREESPACE_9B

; Allows us to setup warnings for mishandled macros
!FREESPACE_BANK = -1

macro startfree(bank)
; Allows us to assign freespace without gaps from different files
assert !FREESPACE_BANK < 0, "You forgot to close out bank !FREESPACE_BANK"
org !FREESPACE_<bank>
!FREESPACE_BANK = $<bank>
endmacro

macro endfree(bank)
; Used to close out an org and track the next free byte
assert !FREESPACE_BANK >= 0, "No matching startfree(<bank>)"
assert $<bank> = !FREESPACE_BANK, "You closed out the wrong bank. (Check bank !FREESPACE_BANK)"
!FREESPACE_COUNTER_<bank> ?= 0
FreespaceLabel<bank>_!FREESPACE_COUNTER_<bank>:
!FREESPACE_<bank> := FreespaceLabel<bank>_!FREESPACE_COUNTER_<bank>
!FREESPACE_COUNTER_<bank> #= !FREESPACE_COUNTER_<bank>+1
!FREESPACE_BANK = -1
warnpc !END_FREESPACE_<bank>
endmacro

macro printfreespacebank(bank)
; Print some numbers about our freespace usage
org !FREESPACE_<bank>
!FREESPACE_COUNTER_<bank> ?= 0
if !FREESPACE_COUNTER_<bank>
print "Bank $<bank> ended at $", pc, " with $", hex(!FREESPACE_<bank>-!START_FREESPACE_<bank>), " bytes used, $", hex(!END_FREESPACE_<bank>-!FREESPACE_<bank>-1), " bytes remaining"
endif
endmacro

macro printfreespace()
; Hide this long list in a single macro
; Use this macro at the end of assembly for debug text about freespace usage
%printfreespacebank(80)
%printfreespacebank(81)
%printfreespacebank(83)
%printfreespacebank(84)
%printfreespacebank(8B)
%printfreespacebank(90)
%printfreespacebank(92)
%printfreespacebank(9B)
endmacro

