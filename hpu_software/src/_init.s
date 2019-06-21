# +FHDR------------------------------------------------------------------------
# Copyright ownership belongs to CAG laboratory, Institute of Artificial
# Intelligence and Robotics, Xi'an Jiaotong University, shall not be used in
# commercial ways without permission.
# -----------------------------------------------------------------------------
# FILE NAME  : _init.s
# DEPARTMENT : CAG of IAIR
# AUTHOR     : XXXX
# AUTHOR'S EMAIL :XXXX@mail.xjtu.edu.cn
# -----------------------------------------------------------------------------
# Ver 1.0  2019--01--01 initial version.
# -----------------------------------------------------------------------------

# .include "./src/custom_ops.S"

.section .text.init
.align 2
.globl _start
.weak main

.include "./inc/memory_map.inc"

# no more than 16 bytes here !
_start:
    li sp, STACK_BASE_ADDR              # Set stack base address
    call main                           # Jump to main function


.section .text
.balign 256   
.globl mintvec
mintvec:
    addi sp, sp, -28                    # Protect environment
    sw t0, 24(sp)                       # Protect t0
    sw t1, 20(sp)                       # Protect t1
    sw t2, 16(sp)                       # Protect t2
    sw t3, 12(sp)                       # Protect t3
    sw t4, 8(sp)                        # Protect t4
    sw t5, 4(sp)                        # Protect t5

#     csrrc t0, mcause, zero              # Load mcause to t0
#     bgez t0, mint_exit                  # If the MSB of mcause equals 0, jump to exit processing

#     slli t0, t0, 1
#     srli t0, t0, 1
#     li t1, 11
#     bne t0, t1, mint_exit

    # prepare to clear interrupt signal
#     li t2, INTR_PLIC_RESP               # Read to clear interrupt of PLIC
#     lw t0, 0(t2)                        # Send claim req
# #    li t2, INTR_PLIC_RESP               # Read once more to confirm to clear interrupt of PLIC
# #    lw t0, 0(t2)                        # Send claim req twice
#     addi t0, t0, -5
#     slli t0, t0, 6
#     la t3, intr_conv_entry
#     add t1, t0, t3
#     li t3, 1                            # Set global virable value
#     li t0, 2                            # Set value to clear external interrupt
#     jr t1

    # picorv32_getq_insn(t0, q1)          # t0 = eoi (pending inerrupt bitmap)
    .word 0xc28b			# t0 = eoi
    li t1, 0                            # t1 = irq num (also the shift of bitmap)
    la t4, intr_conv_entry              # t4 = irq first enrty
    srli t0, t0, 3			# eoi >> 3 : ignore irq-num 0-2
loop1:
    beqz t0, mint_exit
    li t2, 9				# t2 = total irq number
    beq t1, t2, mint_exit               # exit if all irq are checked
    li t2, 1				
    and t3, t0, t2                      # t3 == t0 & 0x1
    slli t5, t1, 5			# t5 = irq_num * 0x20
    addi t1, t1, 1			# irq_num ++
    srli t0, t0, 1			# t0 >> 1
    beqz t3, loop1 			# go back if t0 & 0x1 == 0
    add t3, t4, t5                      # t3 = intr_conv_entry + (irq_num * 0x10)
    li t5, 1
    jr t3

.balign 32
intr_conv_entry:
    la t2, intr_conv_act
    sw t5, 0(t2)
    li t3, DPU_CONV
    addi t5, t5, 1 			# t5 = 2
    sw t5, 0(t3)
    j loop1

.balign 32
intr_dwcalc_entry:
    la t2, intr_dwcalc_act
    sw t5, 0(t2)
    li t3, DPU_DWCALC
    addi t5, t5, 1
    sw t5, 0(t3)
    j loop1

.balign 32
intr_dtrans_entry:
    la t2, intr_dtrans_act
    sw t5, 0(t2)
    li t3, DPU_DTRANS
    addi t5, t5, 1
    sw t5, 0(t3)
    j loop1

.balign 32
intr_ftrans_entry:
    la t2, intr_ftrans_act
    sw t5, 0(t2)
    li t3, DPU_FTRANS
    addi t5, t5, 1
    sw t5, 0(t3)
    j loop1

.balign 32
intr_ldmr_entry:
    la t2, intr_ldmr_act
    sw t5, 0(t2)
    li t3, DPU_LDMR
    addi t5, t5, 1
    sw t5, 0(t3)
    j loop1

.balign 32
intr_svmr_entry:
    la t2, intr_svmr_act
    sw t5, 0(t2)
    li t3, DPU_SVMR
    addi t5, t5, 1
    sw t5, 0(t3)
    j loop1

.balign 32
intr_resv0_entry:
    j loop1

.balign 32
intr_resv1_entry:
    j loop1

.balign 32
intr_stcalc_entry:
    la t2, intr_stcalc_act
    sw t5, 0(t2)
    j loop1

mint_exit:
    lw t0, 24(sp)                       # Restore t0
    lw t1, 20(sp)                       # Restore t1
    lw t2, 16(sp)                       # Restore t2
    lw t3, 12(sp)                       # Restore t3
    lw t4, 8(sp)                        # Restore t4
    lw t5, 4(sp)                        # Restore t5
    addi sp, sp, 28                     # Release stack frame
    # mret
    # picorv32_retirq_insn()
    .word 0x400000b
