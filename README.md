# AOKZOE A2 (Ryzen 7 7840U): set the iGPU VRAM (UMA Frame Buffer) without flashing the BIOS

The stock AOKZOE A2 / A2 Pro BIOS does not let you choose how much RAM goes to the
Radeon 780M. The AMD CBS menu (`Advanced -> AMD CBS -> NBIO Common Options -> GFX Configuration`)
is in the firmware but hidden. This repo has a bootable UEFI Shell USB that sets the VRAM size
to anything from 1 GB to 16 GB. **The BIOS is not modified or flashed.**

> Made with the help of [Devin](https://devin.ai) (AI software engineer by Cognition AI), which
> reverse-engineered the BIOS, found why the usual AMD CBS method does not work on this console,
> and wrote the scripts. Thanks, Devin!

## Compatibility

| | |
|---|---|
| Device | AOKZOE A2 / A2 Pro with **AMD Ryzen 7 7840U** |
| BIOS | **1.16** (`AOK_7840U_V1.16_..._20240106`); other versions are not checked |
| Tested | 8 GB on a 32 GB unit: Task Manager shows 7.9 GB dedicated GPU memory |

Every other size uses the same firmware code path (see [How it works](#how-it-works)), but only 8 GB
has been tested on real hardware. Use at your own risk.

## Why the usual method does not work on AOKZOE

Tools like Smokeless UMAF / UniversalAMDFormBrowser, or writing `AmdSetupPHX` with `setup_var.efi`,
change the AMD CBS value. On the A2 that value gets **overwritten on every boot** by AOKZOE's own code
in the `AmdNbioDxe` module. That code reads the VRAM size from **CMOS byte `0x7A`**:

| CMOS `0x7A` | Result |
|---|---|
| `00` (factory) | Auto, picked by board straps (6 GB on a 32 GB A2) |
| `01` | Use the AMD CBS value |
| `02`..`C0` | VRAM = value x 256 MB |

So the scripts write CMOS `0x7A`, and write the same size to AMD CBS to keep the two consistent.

## Usage

1. Format a USB stick as **FAT32**. Copy everything inside [`usb/`](usb) to the root of the stick.
2. In the BIOS (press `DEL` at power on), **disable Secure Boot**.
3. Boot from the USB stick. The UEFI Shell starts and prints the current values.
4. Type a command and press `Enter`:

   | VRAM | Command | CMOS line should show |
   |---|---|---|
   | 1 GB | `vram_1g.nsh` | `0x04` |
   | 2 GB | `vram_2g.nsh` | `0x08` |
   | 3 GB | `vram_3g.nsh` | `0x0C` |
   | 4 GB | `vram_4g.nsh` | `0x10` |
   | 6 GB | `vram_6g.nsh` | `0x18` |
   | 8 GB | `vram_8g.nsh` | `0x20` |
   | 10 GB | `vram_10g.nsh` | `0x28` |
   | 12 GB | `vram_12g.nsh` | `0x30` |
   | 14 GB | `vram_14g.nsh` | `0x38` |
   | 16 GB | `vram_16g.nsh` | `0x40` |
   | Factory (auto) | `vram_auto.nsh` | `0x00` |

5. Type `reset` and remove the stick. **The console reboots by itself once more.** That is normal: the
   BIOS applies the new size and does a warm reset.
6. In Windows, open Task Manager -> Performance -> GPU and check **Dedicated GPU memory**.

`read.nsh` only shows the current values and changes nothing.

### Manual commands (no scripts needed)

The VRAM size is just one CMOS byte, so you can also set it from any UEFI Shell. Example for 8 GB (`0x20`):

```
mm 70 7A -IO -w 1 -n
mm 71 20 -IO -w 1 -n
mm 70 7A -IO -w 1 -n
mm 71 -IO -w 1 -n
```

The last command should print `0x20`. Then run `reset`.

## Beta: the real AMD CBS menu from the USB stick

> **Beta, not yet tested on a physical AOKZOE A2.** Only the launch was tested in a virtual machine.
> The CMOS scripts above are the tested method.

`menu.nsh` sets CMOS `0x7A = 01` (so the AOKZOE code uses the AMD CBS value) and opens
UniversalAMDFormBrowser by Smokeless ([DavidS95/Smokeless_UMAF](https://github.com/DavidS95/Smokeless_UMAF),
Ryzen 7000 build: [XUANHLGG/UniversalAMDFormBrowser-Ventoy-Ryzen7000](https://github.com/XUANHLGG/UniversalAMDFormBrowser-Ventoy-Ryzen7000)).
The BIOS is not flashed. The menu program is not included in this repo (no license for redistribution):

1. Download [UMAF_BETA.zip](https://github.com/DavidS95/Smokeless_UMAF/blob/main/UMAF_BETA.zip).
2. Copy `DisplayEngine.efi`, `Loader.efi`, `SetupBrowser.efi`, `SREP_Config.cfg`, `SuppressIFPatcher.efi`,
   `UiApp.efi` to the USB root.
3. Copy its `EFI/Boot/BOOTX64.efi` to the USB root as `amd_menu.efi`. Do **not** replace this kit's
   `EFI/BOOT/BOOTX64.EFI` (the UEFI Shell).
4. Boot the USB stick, type `menu.nsh`, then go to
   **Device Manager → AMD CBS → NBIO Common Options → GFX Configuration**:
   `iGPU Configuration = UMA_SPECIFIED`, `UMA Frame buffer Size` = the size you want.
5. F10 → Y to save, then Reset. The console may reboot by itself 1–2 times.

Change **only** GFX Configuration: other AMD CBS/PBS options are real settings and wrong values can
stop the console from booting. 10/12/14 GB are not in the AMD menu, so use the `vram_*.nsh` scripts for those.
Any `vram_*.nsh` script switches back to the normal CMOS mode. Details: `usb/MENU_EN.txt` / `usb/MENU_RU.txt`.

## How much VRAM to choose

- **16 GB RAM:** up to 4-6 GB (factory is 6 GB).
- **32 GB RAM:** 8 GB is the sweet spot. Use 12-16 GB only if a game refuses to run or complains about
  low VRAM. At 16 GB VRAM, Windows keeps only 16 GB of RAM.

More dedicated VRAM usually does not raise FPS: the driver also uses "shared GPU memory" when it needs more.

## Fix: the AOKZOE logo is gone after the first change (AMI screen / Windows logo instead)

After the first VRAM change, the boot can show the AMI screen instead of the AOKZOE logo, and
Windows then shows its own logo. To fix it:

1. Power on and press `DEL` to enter the BIOS.
2. Go to **Boot -> Quiet Boot** and set it to **Enabled**.
3. If it is already Enabled, press **F9 (Load Defaults)**, then **Save & Exit**.
4. The console may reboot by itself once. That is normal.

Your VRAM setting is kept: it lives in CMOS byte `0x7A`, and Load Defaults does not touch it. This was
confirmed on the test unit: the logo came back and VRAM stayed at 8 GB.

## Revert to factory

- Run `vram_auto.nsh` from the USB stick, or
- Do a full CMOS clear (RTC battery / CMOS reset). That sets `0x7A` back to `00`.

If the CMOS gets cleared (for example, the RTC battery runs flat), VRAM goes back to factory. Just run the script again.

After a BIOS update, check that this still applies before using the scripts.

## How it works

Found in BIOS 1.16 (`AmdNbioDxe`, OEM code):

```asm
mov    ebx,0xc00          ; default 3 GB
mov    edx,0x70
mov    al,0x7a            ; CMOS index 0x7A
out    dx,al
mov    edx,0x71
in     al,dx              ; read VRAM selector
...
mov    r8d,0x37b1f8cf     ; APCB_TOKEN_UID_UMASIZE
...
cmp    bpl,0xc0
cmovbe ebx,r14d           ; 02..C0 -> value << 8 (MB)
```

If the new size differs from the APCB `UMASIZE` token, the module updates APCB and logs
`Issue warm reset since APCB changed...`. That warm reset is the extra automatic reboot.

The hidden AMD CBS fields (`CbsSetupDxePHX` IFR) are written as well:

| Field | VarStore | Offset | Size |
|---|---|---|---|
| iGPU Configuration (`01` = UMA_SPECIFIED) | `AmdSetupPHX` `3A997502-647A-4C82-998E-52EF9486A247` | `0x17C` | 1 byte |
| UMA Frame buffer Size (MB) | `AmdSetupPHX` | `0x17E` | 4 bytes |

## Disclaimer

No warranty. You change firmware settings at your own risk. The BIOS image itself is never modified.

## Credits

- Solution, BIOS analysis and scripts: made with the help of **[Devin](https://devin.ai)** by Cognition AI.
- [`setup_var.efi`](https://github.com/datasone/setup_var.efi) by datasone (Apache-2.0).
- UEFI Shell build from [pbatard/UEFI-Shell](https://github.com/pbatard/UEFI-Shell) (EDK II, BSD-2-Clause-Patent).

See [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).
