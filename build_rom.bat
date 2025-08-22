@echo off

:: The implementation of path expansion '%~dp0' being everywhere is a side effect of implementing drag-and-drop functionality.
:: Due to how Windows handles this, it changes the working directory to that of the file being supplied, so manual explicit
:: redirecting to the intended working directory is required where needed. Additionally, %~dp0 also already contains a path
:: delimiter '\' at it's end, do NOT add these where this wildcard is used.

setlocal EnableDelayedExpansion
title X-Fusion Practice Hack Patcher

if not exist "%~dp0asar\asar.exe" (
    echo.
    echo asar.exe not found in ~\asar\
    pause
    exit /b 0
) else if not exist "%~dp0src\main.asm" (
    echo.
    echo main.asm not found in ~\src\.
    pause
    exit /b 0
)
if exist "%~1" (
    set "rom=%~1"
    goto :main
) else if not exist "build\X-Fusion.sfc" (
    echo.
    echo X-Fusion.sfc not found in ~\build\.
    echo Alternatively, drag-and-drop an X-Fusion ROM onto this script.
    echo.
    pause
    exit /b 0
) else (
    set "rom=build\X-Fusion.sfc"
    :main
    set "choice="
    for /f "delims=" %%a in (
        "!rom!"
    ) do (
        set "outdir=%%~dpa"
        set "outrom=%%~na"
    )
    cls
    echo.
    echo Standard ........... 1
    echo Savestates ......... 2
    echo.
    echo Selected ROM:
    echo.
    echo !rom!
    echo.
    set /p "choice=Patch selection: "
    if "!choice!" equ "" (
        echo.
        echo You must enter a menu option to proceed.
        pause > nul
        goto :main
    ) else if "!choice!" == "1" (
        cls
        echo.
        echo Generating practice hack symbols...
        echo.
        python "%~dp0create_dummies.py" ".\build\00.sfc" ".\build\ff.sfc"
        "%~dp0asar\asar.exe" --no-title-check --symbols=wla --symbols-path="!outdir!!outrom! Practice Hack.sym" -DSAVESTATES=0 "%~dp0src\main.asm" "%~dp0build\00.sfc"
        "%~dp0asar\asar.exe" --no-title-check -DSAVESTATES=0 "%~dp0src\main.asm" "%~dp0build\ff.sfc"
        del "%~dp0build\00.sfc" "%~dp0build\ff.sfc" /s /q > nul
        echo.
        echo Patching practice hack ROM...
        echo.
        copy "!rom!" "!outdir!!outrom! Practice Hack.sfc" > nul
        "%~dp0asar\asar.exe" --no-title-check -DSAVESTATES=0 --symbols=wla --symbols-path="!outdir!!outrom! Practice Hack.sym" "%~dp0src\main.asm" "!outdir!!outrom! Practice Hack.sfc"
    ) else if "!choice!" == "2" (
        cls
        echo.
        echo Generating savestate practice hack symbols...
        echo.
        python "%~dp0create_dummies.py" ".\build\00.sfc" ".\build\ff.sfc"
        "%~dp0asar\asar.exe" --no-title-check --symbols=wla --symbols-path="!outdir!!outrom! Practice Hack (Savestates).sym" "%~dp0src\main.asm" "%~dp0build\00.sfc"
        "%~dp0asar\asar.exe" --no-title-check "%~dp0src\main.asm" "%~dp0build\ff.sfc"
        del "%~dp0build\00.sfc" "%~dp0build\ff.sfc" /s /q > nul
        echo.
        echo Patching savestate practice hack ROM...
        echo.
        copy "!rom!" "!outdir!!outrom! Practice Hack (Savestates).sfc" > nul
        "%~dp0asar\asar.exe" --no-title-check --symbols=wla --symbols-path="!outdir!!outrom! Practice Hack (Savestates).sym" "%~dp0src\main.asm" "!outdir!!outrom! Practice Hack (Savestates).sfc"
    ) else (
        echo.
        echo You must enter a menu option to proceed.
        pause > nul
        goto :main
    )
    if '%errorlevel%' neq '0' (
        echo.
    ) else (
        echo.
        echo Patching completed.
    )
    pause
    exit /b 0
)
