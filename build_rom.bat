@echo off

echo Building X-Fusion Practice with savestates
copy build\X-Fusion.sfc build\X-Fusion_Practice_Savestates.sfc && asar\asar.exe --no-title-check --symbols=wla --symbols-path=X-Fusion_Savestate_Symbols.sym src/main.asm build\X-Fusion_Practice_Savestates.sfc

echo Building X-Fusion Practice
copy build\X-Fusion.sfc build\X-Fusion_Practice.sfc && asar\asar.exe --no-title-check -DSAVESTATES=0 --symbols=wla --symbols-path=X-Fusion_Symbols.sym src/main.asm build\X-Fusion_Practice.sfc

PAUSE
