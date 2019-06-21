# +FHDR------------------------------------------------------------------------
# Copyright ownership belongs to CAG laboratory, Institute of Artificial
# Intelligence and Robotics, Xi'an Jiaotong University, shall not be used in
# commercial ways without permission.
# -----------------------------------------------------------------------------
# FILE NAME  : hpu_api.s
# DEPARTMENT : CAG of IAIR
# AUTHOR     : XXXX
# AUTHOR'S EMAIL :XXXX@mail.xjtu.edu.cn
# -----------------------------------------------------------------------------
# Ver 1.0  2019--01--01 initial version.
# -----------------------------------------------------------------------------

.section .text
.align 2
.globl conv_set
.globl conv_start
.globl conv_check

.globl dwcalc_set
.globl dwcalc_start
.globl dwcalc_check

.globl dtrans_set
.globl dtrans_start
.globl dtrans_check

.globl ftrans_set
.globl ftrans_start
.globl ftrans_check

.globl ldmr_set
.globl ldmr_start
.globl ldmr_check

.globl svmr_set
.globl svmr_start
.globl svmr_check

.globl dlctrl_set

.globl uplctrl_set
.globl uplctrl_start

.globl fshflg_ps

.include "./inc/memory_map.inc"

.equ LEN_DPU_CONV, 8 
.equ LEN_DPU_DWCALC, 8
.equ LEN_DPU_DTRANS, 5
.equ LEN_DPU_FTRANS, 4
.equ LEN_DPU_LDMR, 5
.equ LEN_DPU_SVMR, 4
.equ LEN_DPU_DLCTRL, 3
.equ LEN_DPU_UPLCTRL, 1

.equ INTR_H, 1
.equ INTR_L, 0

# a0 : Start address of source parameter structure
# a1 : Start address of destiny
# a2 : Length of transformation, unit is 4B
set_param:
    mv t0, a2                           # Set iterator t0 as the number of iteration 
0:  lw t1, 0(a0)                        # Load the parameter value from source
    addi a0, a0, 4                      # Increase the point of source by 4B
    sw t1, 0(a1)                        # Save the parameter value to destiny
    addi a1, a1, 4                      # Increase the point of destiny by 4B
    addi t0, t0, -1                     # Decrease iterator t0
    bnez t0, 0b                         # Branch if iterator t0 is greater than or equal to 0
    ret

# conv function:
# --conv_set: set the const parameters of conv
# --conv_start: send start signal to conv
# --conv_check: read interrupt signal or done signal of conv
# a0 : Start address of parameter structure
conv_set:
    addi sp, sp, -16                    # Allocate the stack frame
    sw ra, 12(sp)                       # Save return address of caller onto the stack frame

    li a1, DPU_CONV                     # Set destiny address of hpu_conv in hpu register map
    addi a1, a1, 4                      # Jump the control register
    li a2, LEN_DPU_CONV                 # Set the length of transformming
    call set_param                      # Call set_param function

    lw ra, 12(sp)                       # Restore the return address from the stack frame
    addi sp, sp, 16                     # Deallocate the stack frame
    ret

conv_start:
    li t0, DPU_CONV                     # Set destiny address of hpu_conv to t0
    li t1, 3                            # Set clear_intr and start_conv signs to t1
    sw t1, 0(t0)                        # Write signs to hpu_conv register map
    ret

conv_check:
    li t1, DPU_REGMGR                   # Load destity address
    lw t0, 4(t1)                        # Load hpu_conv status from the register map
    andi t0, t0, 0x00000001             # Clear all bits except interrupt bit
    li a0, INTR_L                       # Set return value as INTR_L as default
    beqz t0, conv_check_exit            # If interrupt bit is 0, jump to exit function
    li t1, DPU_CONV                     # Load conv register
    li t0, 2                            # Set clear_intr signs to t0
    sw t0, 0(t1)                        # Write signes to hpu_conv_register map
    li a0, INTR_H                       # If interrupt bit is 1, set return value as INTR_H
conv_check_exit:
    ret

# dwcalc function:
# --dwcalc_set: set the const parameters of dwcalc
# --dwcalc_start: send start signal to dwcalc
# --dwcalc: read interrupt signal or done signal of dwcalc
# a0 : Start address of parameter structure
dwcalc_set:
    addi sp, sp, -16                    # Allocate the stack frame
    sw ra, 12(sp)                       # Save return address of caller onto the stack frame

    li a1, DPU_DWCALC                   # Set destiny address of hpu_dwcalc in hpu register map
    addi a1, a1, 4                      # Jump the control register
    li a2, LEN_DPU_DWCALC               # Set the length of transformming
    call set_param                      # Call set_param function

    lw ra, 12(sp)                       # Restore the return address from the stack frame
    addi sp, sp, 16                     # Deallocate the stack frame
    ret

dwcalc_start:
    li t0, DPU_DWCALC                   # Set destiny address of hpu_dwcalc to t0
    li t1, 3                            # Set clear_intr and start_dwcalc signs to t1
    sw t1, 0(t0)                        # Write signs to hpu_dwcalc register map
    ret

dwcalc_check:
    li t1, DPU_REGMGR                   # Load destity address
    lw t0, 4(t1)                        # Load hpu_dwcalc status from the register map
    andi t0, t0, 0x00000002             # Clear all bits except interrupt bit
    li a0, INTR_L                       # Set return value as INTR_L as default
    beqz t0, dwcalc_check_exit          # If interrupt bit is 0, jump to exit function
    li t1, DPU_DWCALC                   # Load dwcalc register
    li t0, 2                            # Set clear_intr signs to t0
    sw t0, 0(t1)                        # Write signes to hpu_dwcalc_register map
    li a0, INTR_H                       # If interrupt bit is 1, set return value as INTR_H
dwcalc_check_exit:
    ret

# dtrans function:
# --dtrans_set: set parameters of dtrans
# --dtrans_start: send start signal to dtrans
# --dtrans_check: read interrupt signal or done signal of dtrans
# a0 : Start address of parameter structure
dtrans_set:
    addi sp, sp, -16                    # Allocate the stack frame
    sw ra, 12(sp)                       # Save return address of caller onto the stack frame

    li a1, DPU_DTRANS                   # Set destiny address of hpu_dtrans in hpu register map
    addi a1, a1, 4                      # Jump the control register
    li a2, LEN_DPU_DTRANS               # Set Length of hpu_dtrans parameter structure
    call set_param                      # Call set_param function

    lw ra, 12(sp)                       # Restore the return address from the stack frame
    addi sp, sp, 16                     # Deallocate the stack frame
    ret

dtrans_start:
    li t0, DPU_DTRANS                   # Set destiny address of hpu_dtrans to t0
    li t1, 3                            # Set clear_intr and start_dtrans signs to t1
    sw t1, 0(t0)                        # Write signs to hpu_dtrans register map
    ret

dtrans_check:
    li t1, DPU_REGMGR                   # Load destity address
    lw t0, 4(t1)                        # Load hpu_dtrans status from the register map
    andi t0, t0, 0x00000004             # Clear all bits except interrupt bit
    srli a0, t0, 2                      # Shift interrupt bit to 0 positiion
    beqz t0, dtrans_check_exit          # If interrupt bit is 0, exit function
    li t1, DPU_DTRANS                   # Clear interrupt notification signal
    li t0, 2                            # Set clear_intr command
    sw t0, 0(t1)                        # Send command
dtrans_check_exit:
    ret

# ftrans function:
# --ftrans_set: set parameters of ftrans
# --ftrans_start: send start signal to ftrans
# --ftrans_check: read interrupt signal or done signal of ftrans
# a0 : Start address of parameter structure
ftrans_set:
    addi sp, sp, -16                    # Allocate the stack frame
    sw ra, 12(sp)                       # Save return address of caller onto the stack frame

    li a1, DPU_FTRANS                   # Set destiny address of hpu_ftrans in hpu register map
    addi a1, a1, 4                      # Jump the control register
    li a2, LEN_DPU_FTRANS               # Set Length of hpu_ftrans parameter structure
    call set_param                      # Call set_param function

    lw ra, 12(sp)                       # Restore the return address from the stack frame
    addi sp, sp, 16                     # Deallocate the stack frame
    ret

ftrans_start:
    li t0, DPU_FTRANS                   # Set destiny address of hpu_ftrans to t0
    li t1, 3                            # Set clear_intr and start_ftrans signs to t1
    sw t1, 0(t0)                        # Write signs to hpu_ftrans register map
    ret

ftrans_check:
    li t1, DPU_REGMGR                   # Load destity address
    lw t0, 4(t1)                        # Load hpu_ftrans status from the register map
    andi t0, t0, 0x00000008             # Clear all bits except interrupt bit
    srli a0, t0, 3                      # Shift interrupt bit to 0 positiion
    beqz t0, ftrans_check_exit          # If interrupt bit is 0, exit function
    li t1, DPU_FTRANS                   # Clear interrupt notification signal
    li t0, 2                            # Set clear_intr command
    sw t0, 0(t1)                        # Send command
ftrans_check_exit:
    ret

# ldmr function:
# --ldmr_set: set parameters of ldmr
# --ldmr_start: send start signal to ldmr
# --ldmr_check: read interrupt signal or done signal of ldmr
# a0 : Start address of parameter structure
ldmr_set:
    addi sp, sp, -16                    # Allocate the stack frame
    sw ra, 12(sp)                       # Save return address of caller onto the stack frame

    li a1, DPU_LDMR                     # Set destiny address of hpu_ldmr in hpu register map
    addi a1, a1, 4                      # Jump the control register
    li a2, LEN_DPU_LDMR                 # Set Length of hpu_ldmr parameter structure
    call set_param                      # Call set_param function

    lw ra, 12(sp)                       # Restore the return address from the stack frame
    addi sp, sp, 16                     # Deallocate the stack frame
    ret

ldmr_start:
    li t0, DPU_LDMR                     # Set destiny address of hpu_ldmr to t0
    li t1, 3                            # Set clear_intr and start_ldmr signs to t1
    sw t1, 0(t0)                        # Write signs to hpu_ldmr register map
    ret

ldmr_check:
    li t1, DPU_REGMGR                   # Load destity address
    lw t0, 4(t1)                        # Load hpu_ldmr status from the register map
    andi t0, t0, 0x00000010             # Clear all bits except interrupt bit
    srli a0, t0, 4                      # Shift interrupt bit to 0 position
    beqz t0, ldmr_check_exit            # If interrupt bit is 0, exit function
    li t1, DPU_LDMR                     # Clear interrupt notification signal
    li t0, 2                            # Set clear_intr command
    sw t0, 0(t1)                        # Send command
ldmr_check_exit:
    ret

# svmr function:
# --svmr_set: set parameters of svmr
# --svmr_start: send start signal to svmr
# --svmr_check: read interrupt signal or done signal of svmr
# a0 : Start address of parameter structure
svmr_set:
    addi sp, sp, -16                    # Allocate the stack frame
    sw ra, 12(sp)                       # Save return address of caller onto the stack frame

    li a1, DPU_SVMR                     # Set destiny address of hpu_svmr in hpu register map
    addi a1, a1, 4                      # Jump the control register
    li a2, LEN_DPU_SVMR                 # Set Length of hpu_svmr parameter structure
    call set_param                      # Call set_param function

    lw ra, 12(sp)                       # Restore the return address from the stack frame
    addi sp, sp, 16                     # Deallocate the stack frame
    ret

svmr_start:
    li t0, DPU_SVMR                     # Set destiny address of hpu_svmr to t0
    li t1, 3                            # Set clear_intr and start_svmr signs to t1
    sw t1, 0(t0)                        # Write signs to hpu_svmr register map
    ret

svmr_check:
    li t1, DPU_REGMGR                   # Load destity address
    lw t0, 4(t1)                        # Load hpu_svmr status from the register map
    andi t0, t0, 0x00000020             # Clear all bits except interrupt bit
    srli a0, t0, 5                      # Shift interrupt bit to 0 position
    beqz t0, svmr_check_exit            # If interrupt bit is 0, exit function
    li t1, DPU_SVMR                     # Clear interrupt notification signal
    li t0, 2                            # Set clear_intr command
    sw t0, 0(t1)                        # Send command
svmr_check_exit:
    ret

# dlctrl function:
# --dlctrl_set: set parameters of dlctrl
# a0 : Start address of parameter structure
dlctrl_set:
    addi sp, sp, -16                    # Allocate the stack frame
    sw ra, 12(sp)                       # Save return address of caller onto the stack frame

#    li a1, DPU_DLCTRL                   # Set destiny address of hpu_dlctrl in hpu register map
#    addi a1, a1, 4                      # Jump the control register
#    li a2, LEN_DPU_DLCTRL               # Set Length of hpu_dlctrl parameter structure
#    call set_param                      # Call set_param function

    li t0, DPU_DLCTRL                   # Load the address of DPU_DLCTRL 
    lw t1, 0(a0)                        # Load fm_ddr_base_addr
    sw t1, 4(t0)                        # Write regmap of dlctrl
    li t2, 0                            # Write type is fm
    sw t2, 0(t0)                        # 
    lw t1, 4(a0)                        # Load wt_ddr_base_addr
    sw t1, 4(t0)                        # Write regmap of dlctrl
    li t2, 1                            # Write type is weight
    sw t2, 0(t0)                        # 
    lw t1, 8(a0)                        # Load wt_ddr_base_addr
    sw t1, 4(t0)                        # Write regmap of dlctrl
    li t2, 2                            # write type is bias
    sw t2, 0(t0)                        # 

    li t1, 1                            # Write dl_status as 1
    sw t1, 8(t0)                        #

    lw ra, 12(sp)                       # Restore the return address from the stack frame
    addi sp, sp, 16                     # Deallocate the stack frame
    ret

# uplctrl function:
# --uplctrl_set: set parameters of uplctrl
# a0 : Start address of parameter structure
uplctrl_set:
    addi sp, sp, -16                    # Allocate the stack frame
    sw ra, 12(sp)                       # Save return address of caller onto the stack frame

    li a1, DPU_UPLCTRL                  # Set destiny address of hpu_uplctrl in hpu register map
    addi a1, a1, 4                      # Jump the control register
    li a2, LEN_DPU_UPLCTRL              # Set Length of hpu_uplctrl parameter structure
    call set_param                      # Call set_param function

    lw ra, 12(sp)                       # Restore the return address from the stack frame
    addi sp, sp, 16                     # Deallocate the stack frame
    ret

uplctrl_start:
    li t0, DPU_UPLCTRL                  # Set destiny address of uplctrl to t0
    li t1, 3                            # Set clear_intr and start_svmr signs to t1
    sw t1, 0(t0)                        # Write signs to hpu_svmr register map
    ret
# zbr add write a pulse to ps indicate that all layer is finish

fshflg_ps:
    li t0, DPU_REGMGR                   # Set destiny address of uplctrl to t0
    li t1, 1                            # Set clear_intr and start_svmr signs to t1
    sw t1, 0(t0)                        # Write signs to hpu_svmr register map
    ret

