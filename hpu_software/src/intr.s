# +FHDR------------------------------------------------------------------------
# Copyright ownership belongs to CAG laboratory, Institute of Artificial
# Intelligence and Robotics, Xi'an Jiaotong University, shall not be used in
# commercial ways without permission.
# -----------------------------------------------------------------------------
# FILE NAME  : intr.s
# DEPARTMENT : CAG of IAIR
# AUTHOR     : XXXX
# AUTHOR'S EMAIL :XXXX@mail.xjtu.edu.cn
# -----------------------------------------------------------------------------
# Ver 1.0  2019--01--01 initial version.
# -----------------------------------------------------------------------------

# .include "custom_ops.S"

.section .data
.align 2
.globl intr_conv_act
.globl intr_dwcalc_act
.globl intr_dtrans_act
.globl intr_ftrans_act
.globl intr_ldmr_act
.globl intr_svmr_act
.globl intr_stcalc_act

intr_conv_act: .word 0                  # int intr_conv_act = 0;
intr_dwcalc_act: .word 0                # int intr_dwcalc_act = 0;
intr_dtrans_act: .word 0                # int intr_dtrans_act = 0;
intr_ftrans_act: .word 0                # int intr_ftrans_act = 0;
intr_ldmr_act: .word 0                  # int intr_ldmr_act = 0;
intr_svmr_act: .word 0                  # int intr_svmr_act = 0;
intr_stcalc_act: .word 0                # int intr_stcalc_act = 0;

.section .text
.align 2
.globl init_intr

.include "./inc/memory_map.inc"

init_intr:
    addi sp, sp, -8                     # Allocate the stack frame
    sw ra, 4(sp)                        # Save return address of caller onto the stack frame

    la t0, intr_conv_act                # Set intr_conv_act as 0
    sw zero, 0(t0)
    la t0, intr_dwcalc_act              # Set intr_dwcalc_act as 0
    sw zero, 0(t0)
    la t0, intr_dtrans_act              # Set intr_dtrans_act as 0
    sw zero, 0(t0)
    la t0, intr_ftrans_act              # Set intr_ftrans_act as 0
    sw zero, 0(t0)
    la t0, intr_ldmr_act                # Set intr_ldmr_act as 0
    sw zero, 0(t0)
    la t0, intr_svmr_act                # Set intr_svmr_act as 0
    sw zero, 0(t0)
    la t0, intr_stcalc_act              # Set intr_stcalc_act as 0
    sw zero, 0(t0)



    addi sp, sp, 8                      # Deallocate the stack frame
    .word 0x600600b
    ret
