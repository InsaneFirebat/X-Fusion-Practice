@echo off

:: The implementation of path expansion ^(%~dp0^) being everywhere is a side effect of implementing drag-and-drop functionality.
:: Due to how Windows handles this, it changes the working directory to that of the file being supplied, so manual explicit
:: redirecting to the intended working directory is required where needed. Additionally, %~dp0 also already contains a path
:: delimiter ^(\^) at it's end, do NOT add these where this wildcard is used. And yes, the Windows command interpreter is so
:: busted, you even have to escape certain characters in COMMENTS. Thanks John Microsoft.

:: This comment was added primarily as technical documentation, and for anyone that shares my many frustration with Windows.
:: - Mr. Mendelli

setlocal EnableDelayedExpansion
title X-Fusion Practice Hack Patcher

if not exist "%~dp0asar\asar.exe" (
    echo.
    echo asar.exe not found in ~\asar\
    pause
    exit /b 0
) else if not exist "%~dp0main.asm" (
    echo.
    echo main.asm not found.
    pause
    exit /b 0
) else if not exist "%~dp0X-Fusion_Symbols.sym" (
    echo.
    echo X-Fusion_Symbols.sym not found.
    echo You must run build_ips.bat to generate symbols.
    pause
    exit /b 0
) else if not exist "%~dp0X-Fusion_Savestate_Symbols.sym" (
    echo.
    echo X-Fusion_Savestate_Symbols.sym not found.
    echo You must run build_ips.bat to generate symbols.
    pause
    exit /b 0
) else if exist "%~1" (
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
    for /f "delims=" %%a in (
        "!rom!"
    ) do set "outdir=%%~dpa"
    for /f "delims=" %%b in (
        "!rom!"
    ) do set "outrom=%%~nb"
    cls
    echo.
    echo Selected ROM:
    echo.
    echo !rom!
    echo.
    set /p "choice=Apply practice hack patches? "
    if "!choice!" equ "" (
        echo.
        echo You must enter y or n to proceed.
        pause > nul
        goto :main
    ) else if "!choice!" equ "n" (
        exit /b 0
    ) else if "!choice!" equ "y" (
        cls
        echo.
        echo Patching practice hack ROM...
        echo.
        copy "!rom!" "!outdir!!outrom! Practice Hack.sfc" > nul
        "%~dp0asar\asar.exe" --no-title-check -DSAVESTATES=0 --symbols=wla --symbols-path="%~dp0X-Fusion_Symbols.sym" "%~dp0main.asm" "!outdir!!outrom! Practice Hack.sfc"
        echo.
        echo Patching savestate practice hack ROM...
        echo.
        copy "!rom!" "!outdir!!outrom! Practice Hack (Savestates).sfc" > nul
        "%~dp0asar\asar.exe" --no-title-check --symbols=wla --symbols-path="%~dp0X-Fusion_Savestate_Symbols.sym" "%~dp0main.asm" "!outdir!!outrom! Practice Hack (Savestates).sfc"
    ) else (
        echo.
        echo You must enter y or n to proceed.
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
