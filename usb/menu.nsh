@echo -off
for %a run (0 9)
  if exist fs%a:\setup_var.efi then
    fs%a:
    goto FOUND
  endif
endfor
echo "setup_var.efi not found"
goto END
:FOUND
if not exist amd_menu.efi then
  echo "amd_menu.efi not found. Copy the Smokeless UMAF files to the USB root (see MENU_EN.txt)."
  goto END
endif
if not exist Loader.efi then
  echo "Loader.efi not found. Copy the Smokeless UMAF files to the USB root (see MENU_EN.txt)."
  goto END
endif
echo "Menu mode: CMOS 0x7A = 01 (BIOS uses AMD CBS UMA value)"
mm 70 7A -IO -w 1 -n
mm 71 01 -IO -w 1 -n
mm 70 7A -IO -w 1 -n
mm 71 -IO -w 1 -n
echo "Opening AMD menu. Device Manager -> AMD CBS -> NBIO Common Options -> GFX Configuration"
amd_menu.efi
:END
