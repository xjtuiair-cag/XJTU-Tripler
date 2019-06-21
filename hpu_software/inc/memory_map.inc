# +FHDR------------------------------------------------------------------------
# Copyright ownership belongs to CAG laboratory, Institute of Artificial
# Intelligence and Robotics, Xi'an Jiaotong University, shall not be used in
# commercial ways without permission.
# -----------------------------------------------------------------------------
# FILE NAME  : memory_map.inc
# DEPARTMENT : CAG of IAIR
# AUTHOR     : XXXX
# AUTHOR'S EMAIL :XXXX@mail.xjtu.edu.cn
# -----------------------------------------------------------------------------
# Ver 1.0  2019--01--01 initial version.
# -----------------------------------------------------------------------------

# General memory map
.equ CLINT,             0x02000000                  # Core local interrupt controller register region, 0x02000000 - 0x0200ffff
.equ PLIC,              0x0c000000                  # Platform level interrupt controller register region, 0x0c000000 - 0x0cffffff
.equ ITCM,              0x00000000                  # Instruction tightly coupled memory region, 0x80000000 - 0x8001ffff
.equ DTCM,              0x00100000                  # Data tightly coupled memory region, 0x90000000 - 0x9001ffff
# .equ GPIO,              0x10012000                  # GPIO address region, 0x10012000 - 0x10012fff

.equ STACK_BASE_ADDR,   0x00102000

# the GPIO connected to PS control interface
.equ PS_CTRL_IF,        0x20002000

# the DPU register map address
.equ DPU_REGMGR,        0x20000000
.equ DPU_CONV,          0x20000100
.equ DPU_DWCALC,        0x20000200
.equ DPU_DTRANS,        0x20000300
.equ DPU_FTRANS,        0x20000400
.equ DPU_LDMR,          0x20000500
.equ DPU_SVMR,          0x20000600
.equ DPU_DLCTRL,        0x20000700
.equ DPU_UPLCTRL,       0x20000800

# Interrupt register address
# .equ INTR_CONV_PRIO,    0x0c000014
# .equ INTR_DWCALC_PRIO,  0x0c000018
# .equ INTR_DTRANS_PRIO,  0x0c00001c
# .equ INTR_FTRANS_PRIO,  0x0c000020
# .equ INTR_LDMR_PRIO,    0x0c000024
# .equ INTR_SVMR_PRIO,    0x0c000028
# .equ INTR_RESV0_PRIO,   0x0c00002c
# .equ INTR_RESV1_PRIO,   0x0c000030
# .equ INTR_STCALC_PRIO,  0x0c000034

# .equ INTR_PLIC_EN,      0x0c002000

# .equ INTR_PLIC_PEND,    0x0c001000
# .equ INTR_PLIC_RESP,    0x0c200004
