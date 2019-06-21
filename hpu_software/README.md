# hpu_reg_version_software
This repository stores the RISC-V C/assembly code, running on hpu_reg_version module.
The code manages the top schedule of DNN network.


## Instruction
In order to compile the code, type follow commands at root directory.
```
mkdir output
make clean
make all
```

## Output introduction
hpu.mo is the generated code in ELF format.
hpu.dump is the disassemble file for debugging.
hpu.hex is the content of data/program sections in ASCII format.
1_dtcm.verilog and 1_itcm.verilog is the generated purpose, which can be accessed by verilog simulator directly.
