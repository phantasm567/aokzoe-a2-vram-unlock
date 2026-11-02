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
echo "CMOS 0x7A (AOKZOE VRAM): 00=Auto(stock 6G)  04=1G 08=2G 0C=3G 10=4G 18=6G 20=8G 28=10G 30=12G 38=14G 40=16G"
mm 70 7A -IO -w 1 -n
mm 71 -IO -w 1 -n
echo "CBS AmdSetupPHX 0x17E (MB):"
setup_var.efi AmdSetupPHX:0x17E(4)
echo "Commands: vram_1g.nsh vram_2g.nsh vram_3g.nsh vram_4g.nsh vram_6g.nsh vram_8g.nsh vram_10g.nsh vram_12g.nsh vram_14g.nsh vram_16g.nsh"
echo "          vram_auto.nsh (stock)   read.nsh   reset"
:END
