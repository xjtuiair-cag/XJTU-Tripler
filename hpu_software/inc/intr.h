// +FHDR------------------------------------------------------------------------
// Copyright ownership belongs to CAG laboratory, Institute of Artificial
// Intelligence and Robotics, Xi'an Jiaotong University, shall not be used in
// commercial ways without permission.
// -----------------------------------------------------------------------------
// FILE NAME  : intr.h
// DEPARTMENT : CAG of IAIR
// AUTHOR     : XXXX
// AUTHOR'S EMAIL :XXXX@mail.xjtu.edu.cn
// -----------------------------------------------------------------------------
// Ver 1.0  2019--01--01 initial version.
// -----------------------------------------------------------------------------

#ifndef INTR_H
#define INTR_H

#ifdef __cplusplus
extern "C" {
#endif

extern int intr_conv_act;
extern int intr_dwcalc_act;
extern int intr_dtrans_act;
extern int intr_ftrans_act;
extern int intr_ldmr_act;
extern int intr_svmr_act;
extern int intr_stcalc_act;

void init_intr (void);

#ifdef __cplusplus
}
#endif

#endif
