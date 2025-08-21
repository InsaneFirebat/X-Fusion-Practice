@echo off

echo.
echo Generating practice hack symbols...
echo.
python ".\create_dummies.py" ".\build\00.sfc" ".\build\ff.sfc"
".\asar\asar.exe" --no-title-check --symbols=wla --symbols-path=".\X-Fusion_Symbols.sym" -DSAVESTATES=0 ".\main.asm" ".\build\00.sfc"
".\asar\asar.exe" --no-title-check -DSAVESTATES=0 ".\main.asm" ".\build\ff.sfc"
echo.
echo Building practice hack patch...
python ".\create_ips.py" ".\build\00.sfc" ".\build\ff.sfc" ".\build\X-Fusion_Practice.ips"
del ".\build\00.sfc" ".\build\ff.sfc" /s /q > nul

echo.
echo Generating savestate practice hack symbols...
echo.
python ".\create_dummies.py" ".\build\00.sfc" ".\build\ff.sfc"
".\asar\asar.exe" --no-title-check --symbols=wla --symbols-path=".\X-Fusion_Savestate_Symbols.sym" ".\main.asm" ".\build\00.sfc"
".\asar\asar.exe" --no-title-check ".\main.asm" ".\build\ff.sfc"
echo.
echo Building savestate practice hack patch...
python ".\create_ips.py" ".\build\00.sfc" ".\build\ff.sfc" ".\build\X-Fusion_Practice_Savestates.ips"
del ".\build\00.sfc" ".\build\ff.sfc" /s /q > nul
pause
