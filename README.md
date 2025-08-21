# X-Fusion Practice Hack

# About

This is a very minimal practice hack due to the extreme lack of free space in the hack. Only savestates and a timer are available. This patch was adapted from the [Super Metroid Practice Hack](https://github.com/tewtal/sm_practice_hack).

# Savestate Feature

By default, the inputs to create a savestate are `Select`+`Y`+`R`. Once a savestate has been created, you can press `Select`+`Y`+`L` by default to load the savestate. **Savestates cannot be created or loaded during door scrolling, music change, or when message boxes are active.**

# Patching

## Pre-Made Patches

A pre-made IPS patch is included in the `\build\` directory of [releases](https://github.com/InsaneFirebat/X-Fusion-Practice/tree/main/releases). You will need a patching utility such as [Floating IPS](https://github.com/Alcaro/Flips) to apply patches to X-Fusion. **Always use an unheadered ROM when applying the patches.**

## Build Patches

1. Download and install [Python 3](https://python.org).
_\*Windows users will need to set the `PATH` environment variable for the Python installation._
2. Run `build_ips.bat` to create an IPS patch files
4. Patches will output to `\build\`

## Patching Script

1. Place a copy of `X-Fusion.sfc`in the `\build\` directory
2. Run `build_rom.bat`
3. Alternatively, drag-and-drop an X-Fusion ROM onto the script directly
4. Output ROMs will output to the same directory as the input ROM

## Known Issues

- Making a savestate on a music change can cause a crash when loading the savestate
