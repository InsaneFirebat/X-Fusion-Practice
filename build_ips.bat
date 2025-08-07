@echo off

echo Building X-Fusion Practice with savestates
python create_dummies.py 00.sfc ff.sfc

copy *.sfc build
asar\asar.exe --no-title-check --symbols=wla --symbols-path=X-Fusion_Savestate_Symbols.sym main.asm build\00.sfc
asar\asar.exe --no-title-check main.asm build\ff.sfc
python create_ips.py build\00.sfc build\ff.sfc build\X-Fusion_Practice_Savestates.ips

del 00.sfc ff.sfc build\00.sfc build\ff.sfc


echo Building X-Fusion Practice
python create_dummies.py 00.sfc ff.sfc

copy *.sfc build
asar\asar.exe --no-title-check --symbols=wla --symbols-path=X-Fusion_Symbols.sym -DSAVESTATES=0 main.asm build\00.sfc
asar\asar.exe --no-title-check -DSAVESTATES=0 main.asm build\ff.sfc
python create_ips.py build\00.sfc build\ff.sfc build\X-Fusion_Practice.ips

del 00.sfc ff.sfc build\00.sfc build\ff.sfc

PAUSE
