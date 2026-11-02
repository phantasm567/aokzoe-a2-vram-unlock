AOKZOE A2 (Ryzen 7 7840U), BIOS 1.16: set the video memory size (VRAM / UMA) without flashing the BIOS. Version 3
==================================================================================================================

Why version 1 did not work:
  The AOKZOE BIOS has its own code (the AmdNbioDxe module). On every boot it takes the VRAM size
  from CMOS byte 0x7A and overwrites the AMD CBS setting with it:
    0x7A = 00         -> auto: the size depends on the model (6 GB on a 32 GB A2). This is the factory setting
    0x7A = 01         -> the AMD CBS value is used
    0x7A = 02..C0     -> VRAM = value x 256 MB (04=1G, 08=2G, 0C=3G, 10=4G, 18=6G, 20=8G, 28=10G, 30=12G, 38=14G, 40=16G)
  If the new value differs from the current one, the BIOS saves it and reboots the console BY ITSELF
  once. This is normal.
  The scripts (version 2 and later) write CMOS byte 0x7A and, for consistency, the same value to AMD CBS.

Preparation:
  FAT32 USB stick. Copy EVERYTHING from the archive to the root of the stick (delete any old files).
  Secure Boot must be disabled in the BIOS.

Usage:
  1. Boot from the USB stick. The current values are shown.
  2. Type a command, for example vram_4g.nsh, and press Enter.
     Available: vram_1g / 2g / 3g / 4g / 6g / 8g / 10g / 12g / 14g / 16g.nsh and vram_auto.nsh (back to factory).
  3. Check that the CMOS line shows the expected value (for example 0x10 for 4G).
  4. Type reset and remove the USB stick. The console may reboot by itself once more, this is normal.
  5. In Windows: Task Manager -> GPU -> "Dedicated GPU memory".

Recommendations:
  With 16 GB RAM, a sensible maximum is 4-6 GB (factory is 6 GB). 8 GB leaves Windows only 8 GB.
  With 32 GB RAM: 8 GB is optimal, 12 GB if a game does not have enough VRAM, 16 GB is the maximum (Windows keeps 16 GB).

Revert:
  - vram_auto.nsh: factory mode.
  - If the RTC battery runs flat or the CMOS is reset, the byte becomes 00, i.e. factory mode.
    Just run the script again.

Only for AOKZOE A2 7840U, BIOS 1.16. Do not touch any other addresses.
