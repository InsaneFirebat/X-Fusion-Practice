
; X-Fusion practice hack v1.0.1
; Minimal features because there's barely any freespace (extra freespace found at $9BCBFB)
; Tinystates will not be supported due to too many things moving around in X-Fusion

; SD2SNES Savestate code originally by acmlm, total, Myria

lorom


incsrc defines.asm
incsrc macros.asm
incsrc freespace.asm
incsrc gamemode.asm
incsrc timer.asm
incsrc save.asm
incsrc menu.asm
incsrc misc.asm

%printfreespace()

