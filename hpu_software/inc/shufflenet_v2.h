// +FHDR------------------------------------------------------------------------
// Copyright ownership belongs to CAG laboratory, Institute of Artificial
// Intelligence and Robotics, Xi'an Jiaotong University, shall not be used in
// commercial ways without permission.
// -----------------------------------------------------------------------------
// FILE NAME  : shufflenet_v2.h
// DEPARTMENT : CAG of IAIR
// AUTHOR     : XXXX
// AUTHOR'S EMAIL :XXXX@mail.xjtu.edu.cn
// -----------------------------------------------------------------------------
// Ver 1.0  2019--01--01 initial version.
// -----------------------------------------------------------------------------

#ifndef SHUFFLENET_V2_H
#define SHUFFLENET_V2_H

#ifdef __cpluscplus
extern "C" {
#endif

// calculation parameters
// Conv1 & Pool1
extern c_conv_param   g_conv1;
extern c_dwcalc_param g_pool1;
extern int g_conv1_fm_height;

// Blk1_1
extern c_dwcalc_param g_blk1_1_lb;
extern c_conv_param   g_blk1_1_lc;
extern c_conv_param   g_blk1_1_ra;
extern c_dwcalc_param g_blk1_1_rb;
extern c_conv_param   g_blk1_1_rc;
extern int g_blk1_1_fm_height;

// Blk2_[1 - 3]
extern c_conv_param   g_blk2_x_ra[3];
extern c_dwcalc_param g_blk2_x_rb[3];
extern c_conv_param   g_blk2_x_rc[3];
extern c_dtrans_param g_blk2_x_dt;
extern int g_blk2_x_fm_height;
extern int g_blk2_x_ifm_offset;

// Blk3_1
extern c_dwcalc_param g_blk3_1_lb;
extern c_conv_param   g_blk3_1_lc;
extern c_conv_param   g_blk3_1_ra;
extern c_dwcalc_param g_blk3_1_rb;
extern c_conv_param   g_blk3_1_rc;
extern int g_blk3_1_fm_height;

// Blk4_[1 - 7]
extern c_conv_param   g_blk4_x_ra[7];
extern c_dwcalc_param g_blk4_x_rb[7];
extern c_conv_param   g_blk4_x_rc[7];
extern c_dtrans_param g_blk4_x_dt;
extern int g_blk4_x_fm_height;
extern int g_blk4_x_ifm_offset;

// ftrans ch8 to ch64
extern c_ftrans_param g_fmtrans;
extern int g_fmtrans_fm_height;

// Blk5_1
extern c_dwcalc_param g_blk5_1_lb;
extern c_conv_param   g_blk5_1_lc;
extern c_conv_param   g_blk5_1_ra;
extern c_dwcalc_param g_blk5_1_rb;
extern c_conv_param   g_blk5_1_rc;
extern int g_blk5_1_fm_height;

// Blk6_[1 - 9]
extern c_conv_param   g_blk6_x_ra[9];
extern c_dwcalc_param g_blk6_x_rb[9];
extern c_conv_param   g_blk6_x_rc[9];
extern c_dtrans_param g_blk6_x_dt;
extern int g_blk6_x_fm_height;
extern int g_blk6_x_ifm_offset;

// conv_preds
extern c_dtrans_param g_convf_dt;
extern c_ftrans_param g_convf_ft;
extern c_conv_param   g_convf;
extern int g_convf_fm_height;

// ldmr/svmr parameters
// Conv1, Pool1
extern c_ldmr_param g_conv1_ifm;
extern c_ldmr_param g_conv1_wt;
extern c_ldmr_param g_conv1_bias;
extern c_svmr_param g_conv1_ofm;
// Blk1_1
extern c_ldmr_param g_blk1_1_ifm;
extern c_ldmr_param g_blk1_1_dwc_wt;
extern c_ldmr_param g_blk1_1_conv_wt;
extern c_ldmr_param g_blk1_1_dwc_bias;
extern c_ldmr_param g_blk1_1_conv_bias;
extern c_svmr_param g_blk1_1_ofm;
// Blk2_[1-3]
extern c_ldmr_param g_blk2_x_ifm[3];
extern c_ldmr_param g_blk2_x_dwc_wt[3];
extern c_ldmr_param g_blk2_x_conv_wt[3];
extern c_ldmr_param g_blk2_x_dwc_bias[3];
extern c_ldmr_param g_blk2_x_conv_bias[3];
extern c_svmr_param g_blk2_x_ofm[3];
// Blk3_1
extern c_ldmr_param g_blk3_1_ifm;
extern c_ldmr_param g_blk3_1_dwc_wt;
extern c_ldmr_param g_blk3_1_conv_wt;
extern c_ldmr_param g_blk3_1_dwc_bias;
extern c_ldmr_param g_blk3_1_conv_bias;
extern c_svmr_param g_blk3_1_ofm;
// Blk4_1
extern c_ldmr_param g_blk4_x_ifm[7];
extern c_ldmr_param g_blk4_x_dwc_wt[7];
extern c_ldmr_param g_blk4_x_conv_wt[7];
extern c_ldmr_param g_blk4_x_dwc_bias[7];
extern c_ldmr_param g_blk4_x_conv_bias[7];
extern c_svmr_param g_blk4_x_ofm[7];

// ftrans ch8 to ch64
extern c_ldmr_param g_fmtrans_ifm;
extern c_svmr_param g_fmtrans_ofm;

// Blk5_1
extern c_ldmr_param g_blk5_1_ifm;
extern c_ldmr_param g_blk5_1_dwc_wt;
extern c_ldmr_param g_blk5_1_conv_wt;
extern c_ldmr_param g_blk5_1_dwc_bias;
extern c_ldmr_param g_blk5_1_conv_bias;
extern c_svmr_param g_blk5_1_ofm;
// Blk6_x
extern c_ldmr_param g_blk6_x_ifm[9];
extern c_ldmr_param g_blk6_x_dwc_wt[9];
extern c_ldmr_param g_blk6_x_conv_wt[9];
extern c_ldmr_param g_blk6_x_dwc_bias[9];
extern c_ldmr_param g_blk6_x_conv_bias[9];
extern c_svmr_param g_blk6_x_ofm[9];
// CONVF(Conv Preds)
extern c_ldmr_param g_convf_ifm;
extern c_ldmr_param g_convf_wt;
extern c_ldmr_param g_convf_bias;
extern c_svmr_param g_convf_ofm;

void shufflenet_v2();

#ifdef __cplusplus
}
#endif

#endif
