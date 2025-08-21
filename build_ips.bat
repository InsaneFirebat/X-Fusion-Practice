@echo off

echo.
echo Generating practice hack symbols...
echo.
python ".\create_dummies.py" ".\build\00.sfc" ".\build\ff.sfc"
".\asar\asar.exe" --no-title-check --symbols=wla --symbols-path=".\build\X-Fusion Practice Hack.sym" -DSAVESTATES=0 ".\src\main.asm" ".\build\00.sfc"
".\asar\asar.exe" --no-title-check -DSAVESTATES=0 ".\src\main.asm" ".\build\ff.sfc"
echo.
echo Building practice hack patch...
python ".\create_ips.py" ".\build\00.sfc" ".\build\ff.sfc" ".\build\X-Fusion Practice Hack.ips"
del ".\build\00.sfc" ".\build\ff.sfc" /s /q > nul

echo.
echo Generating savestate practice hack symbols...
echo.
python ".\create_dummies.py" ".\build\00.sfc" ".\build\ff.sfc"
".\asar\asar.exe" --no-title-check --symbols=wla --symbols-path=".\build\X-Fusion Practice Hack (Savestates).sym" ".\src\main.asm" ".\build\00.sfc"
".\asar\asar.exe" --no-title-check ".\src\main.asm" ".\build\ff.sfc"
echo.
echo Building savestate practice hack patch...
python ".\create_ips.py" ".\build\00.sfc" ".\build\ff.sfc" ".\build\X-Fusion Practice Hack (Savestates).ips"
del ".\build\00.sfc" ".\build\ff.sfc" /s /q > nul
pause
