# X-Fusion Practice Hack

# About

This patch was adapted from the [Super Metroid Practice Hack](https://github.com/tewtal/sm_practice_hack). It is a very minimal practice hack due to the extreme lack of free space in X-Fusion. Many important features had to be ommitted, such as presets and tinystates.

# Savestate Feature

By default, the inputs to create a savestate are `Select`+`Y`+`R`. Once a savestate has been created, you can press `Select`+`Y`+`L` by default to load the savestate. **Savestates cannot be created or loaded during door scrolling, music change, or when message boxes are active.**

Savestates will only work on platforms that support 256k of SRAM. This includes SD2SNES/FXPAK, bsnes, Snes9x 1.61+, Mesen, MiSTer, and Super NT. A separate patch without this feature is provided for all other platforms.

# Patching

## Pre-Made Patches

Pre-made IPS patches are included in the [`\releases\`](https://github.com/InsaneFirebat/X-Fusion-Practice/tree/main/releases) directory. You will need a patching utility such as [Floating IPS](https://github.com/Alcaro/Flips) to apply patches to X-Fusion. **Always use an unheadered ROM when applying the patches.**

## Build Patches

1. Download and install [Python 3](https://python.org). \*
2. Run `build_ips.bat` to build the IPS patch files
4. Patches will output to `\build\`

_\*Windows users will need to set the `PATH` environment variable for the Python installation._

## Patching Script

1. Place a copy of `X-Fusion.sfc`in the `\build\` directory
2. Run `build_rom.bat`
3. Alternatively, drag-and-drop an X-Fusion ROM onto the script directly
4. Output ROMs will output to the same directory as the input ROM

## Known Issues

- Making a savestate on a music change can cause a crash when loading the savestate
