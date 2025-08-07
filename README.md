# Super Metroid X-Fusion Practice Hack

This is a very minimal practice hack due to the extreme lack of freespace in the hack. Only savestates and a timer are available.

This patch was adapted from the Super Metroid Practice Hack. Find the original (and more updated version) at https://github.com/tewtal/sm_practice_hack


## Using the pre-made patch

A pre-made IPS patch is included in the \build\ directory. You will need an IPS patcher utility, such as Lunar IPS or Floating IPS, to apply the patch to your SM romhack. Always use an unheadered (UH) version of the romhack when applying the Savestate patch.


## Using the savestate feature:

By default, the inputs to create a savestate are "Select+Y+R". Once a savestate has been created, you can press "Select+Y+L" (by default) to load the savestate. Savestates cannot be created or loaded during door scrolling, music change, or when message boxes are active.


## Two ways to build from source:

### Build IPS patch:
1. Download and install Python 3 from https://python.org. Windows users will need to set the PATH environmental variable to point to their Python installation folder.
2. Run build_IPS.bat to create an IPS patch file
4. Locate the patch in \build\

### Patch your rom:

1. Place your unheadered romhack in the \build\ directory
2. Rename the romhack to `X-Fusion.sfc`
3. Run `build_rom.bat` to create a copy of your romhack with the Savestate patch applied
4. Locate the patched rom in \build\


## Known Issues:

* Making a savestate on a music change can cause a crash when loading the savestate
