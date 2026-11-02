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
echo "Setting VRAM = 4G"
mm 70 7A -IO -w 1 -n
mm 71 10 -IO -w 1 -n
setup_var.efi AmdSetupPHX:0x17C=0x01 AmdSetupPHX:0x17E(4)=0x1000
echo "Read back:"
echo "CMOS 0x7A (AOKZOE VRAM): 00=Auto(stock 6G) 01=AMD CBS menu  04=1G 08=2G 0C=3G 10=4G 18=6G 20=8G 28=10G 30=12G 38=14G 40=16G"
mm 70 7A -IO -w 1 -n
mm 71 -IO -w 1 -n
echo "CBS AmdSetupPHX 0x17E (MB):"
setup_var.efi AmdSetupPHX:0x17E(4)
echo "Done. Type: reset   (console will reboot itself once more, it is normal)"
:END
