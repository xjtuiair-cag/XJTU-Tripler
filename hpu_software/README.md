# hpu_reg_version_software
This repository stores the RISC-V C/assembly code, running on hpu_reg_version module.
The code manages the top schedule of DNN network.
You can find many details of our design optimization from this code.

## Instruction
Please make sure that the RISC-V cross compiler toolchain is sucessfully installed on your platform.
For more information about how to install this toolchain, please refer to https://github.com/riscv/riscv-gnu-toolchain

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
