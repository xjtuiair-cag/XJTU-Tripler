// +FHDR------------------------------------------------------------------------
// Copyright ownership belongs to CAG laboratory, Institute of Artificial
// Intelligence and Robotics, Xi'an Jiaotong University, shall not be used in
// commercial ways without permission.
// -----------------------------------------------------------------------------
// FILE NAME  : shufflenet_v2_data.c
// DEPARTMENT : CAG of IAIR
// AUTHOR     : XXXX
// AUTHOR'S EMAIL :XXXX@mail.xjtu.edu.cn
// -----------------------------------------------------------------------------
// Ver 1.0  2019--01--01 initial version.
// -----------------------------------------------------------------------------

#include "../inc/global.h"
#include "../inc/hpu_api.h"

// calculation parameters
// Conv1 & Pool1
c_conv_param   g_conv1 = {0x02200127, 0x03090002, 0x00a00000, 0x24001000, 0x00000000, 0x00000000, 0x00000000, 0x00000000};
c_dwcalc_param g_pool1 = {0x00110213, 0x40000006, 0x00780000, 0x26002000, 0x00000000, 0x00000000, 0x00000000, 0x00000000};
//c_dwcalc_param g_pool1 = {0x00220213, 0x40000006, 0x00780000, 0x26002000, 0x00000000, 0x00000000, 0x00000000, 0x00000000};
int g_conv1_fm_height = 360;
// int g_conv1_pad_width = 3;
// int g_pool1_fm_width = 120;

// Blk1_1
c_dwcalc_param g_blk1_1_lb = {0x00220209, 0x22040006, 0x003c0000, 0x26002000, 0x00000000, 0x00000000, 0x00000000, 0x00000000};
c_conv_param   g_blk1_1_lc = {0x07000209, 0x07070003, 0x003c0000, 0x24001000, 0x00000000, 0x00000000, 0x00000000, 0x00000000};
c_conv_param   g_blk1_1_ra = {0x07000213, 0x03060003, 0x003c0000, 0x24081018, 0x00000000, 0x00000000, 0x00000000, 0x00000000};
c_dwcalc_param g_blk1_1_rb = {0x00220709, 0x22040010, 0x00a00000, 0x2603201b, 0x00000000, 0x00000000, 0x00000000, 0x00000000};
c_conv_param   g_blk1_1_rc = {0x07000709, 0x0f080008, 0x00500000, 0x24101030, 0x00000000, 0x00000000, 0x00000000, 0x00000000};
int g_blk1_1_fm_height = 90;
// int g_blk1_1_lb_pad_width = 3;
// int g_blk1_1_rb_pad_width = 8;
// int g_blk1_1_lb_fm_width = 60;
// int g_blk1_1_rb_fm_width = 160;

// Blk2_[1 - 3]
c_conv_param   g_blk2_x_ra[3] ={{0x07000709, 0x03060010, 0x00a00000, 0x24001000, 0x00000000, 0x00000000, 0x00000000, 0x00000000},
                                {0x07000709, 0x03060010, 0x00a00000, 0x24001000, 0x00000000, 0x00000000, 0x00000000, 0x00000000},
                                {0x07000709, 0x03060010, 0x00a00000, 0x24001000, 0x00000000, 0x00000000, 0x00000000, 0x00000000}};
c_dwcalc_param g_blk2_x_rb[3] ={{0x00220709, 0x22040008, 0x00500008, 0x26002000, 0x0c000c00, 0x00000000, 0x00000000, 0x00000000},
                                {0x00220709, 0x22050008, 0x00500008, 0x26002000, 0x0c000c00, 0x00000000, 0x00000000, 0x00000000},
                                {0x00220709, 0x22050008, 0x00500008, 0x26002000, 0x0c000c00, 0x00000000, 0x00000000, 0x00000000}};
c_conv_param   g_blk2_x_rc[3] ={{0x07000709, 0x0f080008, 0x00500000, 0x24081040, 0x0e000e00, 0x0c000c00, 0x00000000, 0x00000000},
                                {0x07000709, 0x0f080008, 0x00500000, 0x24081040, 0x0e000e00, 0x0c000c00, 0x00000000, 0x00000000},
                                {0x07000709, 0x0f080008, 0x00500000, 0x24081040, 0x0e000e00, 0x0c000c00, 0x00000000, 0x00000000}};
c_dtrans_param g_blk2_x_dt = {0x08090007, 0x0000004f, 0x000100ff, 0x00000000, 0x0e000e00};
int g_blk2_x_fm_height = 45;
int g_blk2_x_ifm_offset = 8;

// Blk3_1
c_dwcalc_param g_blk3_1_lb = {0x00220f04, 0x22060020, 0x00a00000, 0x26002000, 0x00000000, 0x00000000, 0x00000000, 0x00000000};
c_conv_param   g_blk3_1_lc = {0x0f000f04, 0x07080010, 0x00500000, 0x24001000, 0x00000000, 0x00000000, 0x00000000, 0x00000000};
c_conv_param   g_blk3_1_ra = {0x0f000f09, 0x03070010, 0x00a00000, 0x24101100, 0x00000000, 0x00000000, 0x00000000, 0x00000000};
c_dwcalc_param g_blk3_1_rb = {0x00220f04, 0x22060020, 0x00a00000, 0x26102090, 0x00000000, 0x00000000, 0x00000000, 0x00000000};
c_conv_param   g_blk3_1_rc = {0x0f000f04, 0x0f090010, 0x00500000, 0x24201200, 0x00000000, 0x00000000, 0x00000000, 0x00000000};
int g_blk3_1_fm_height = 45;

// Blk4_[1 - 7]
c_conv_param   g_blk4_x_ra[7] ={{0x0f000f04, 0x03090020, 0x00a00000, 0x24001000, 0x00000000, 0x00000000, 0x00000000, 0x00000000},
                                {0x0f000f04, 0x03080020, 0x00a00000, 0x24001000, 0x00000000, 0x00000000, 0x00000000, 0x00000000},
                                {0x0f000f04, 0x03080020, 0x00a00000, 0x24001000, 0x00000000, 0x00000000, 0x00000000, 0x00000000},
                                {0x0f000f04, 0x03090020, 0x00a00000, 0x24001000, 0x00000000, 0x00000000, 0x00000000, 0x00000000},
                                {0x0f000f04, 0x03090020, 0x00a00000, 0x24001000, 0x00000000, 0x00000000, 0x00000000, 0x00000000},
                                {0x0f000f04, 0x03090020, 0x00a00000, 0x24001000, 0x00000000, 0x00000000, 0x00000000, 0x00000000},
                                {0x0f000f04, 0x03090020, 0x00a00000, 0x24001000, 0x00000000, 0x00000000, 0x00000000, 0x00000000}};
c_dwcalc_param g_blk4_x_rb[7] ={{0x00220f04, 0x22050010, 0x00500010, 0x26002000, 0x0c000c00, 0x00000000, 0x00000000, 0x00000000},
                                {0x00220f04, 0x22070010, 0x00500010, 0x26002000, 0x0c000c00, 0x00000000, 0x00000000, 0x00000000},
                                {0x00220f04, 0x22070010, 0x00500010, 0x26002000, 0x0c000c00, 0x00000000, 0x00000000, 0x00000000},
                                {0x00220f04, 0x22060010, 0x00500010, 0x26002000, 0x0c000c00, 0x00000000, 0x00000000, 0x00000000},
                                {0x00220f04, 0x22060010, 0x00500010, 0x26002000, 0x0c000c00, 0x00000000, 0x00000000, 0x00000000},
                                {0x00220f04, 0x22070010, 0x00500010, 0x26002000, 0x0c000c00, 0x00000000, 0x00000000, 0x00000000},
                                {0x00220f04, 0x22060010, 0x00500010, 0x26002000, 0x0c000c00, 0x00000000, 0x00000000, 0x00000000}};
c_conv_param   g_blk4_x_rc[7] ={{0x0f000f04, 0x0f090010, 0x00500000, 0x24101100, 0x0e000e00, 0x0c000c00, 0x00000000, 0x00000000},
                                {0x0f000f04, 0x0f080010, 0x00500000, 0x24101100, 0x0e000e00, 0x0c000c00, 0x00000000, 0x00000000},
                                {0x0f000f04, 0x0f090010, 0x00500000, 0x24101100, 0x0e000e00, 0x0c000c00, 0x00000000, 0x00000000},
                                {0x0f000f04, 0x0f080010, 0x00500000, 0x24101100, 0x0e000e00, 0x0c000c00, 0x00000000, 0x00000000},
                                {0x0f000f04, 0x0f090010, 0x00500000, 0x24101100, 0x0e000e00, 0x0c000c00, 0x00000000, 0x00000000},
                                {0x0f000f04, 0x0f080010, 0x00500000, 0x24101100, 0x0e000e00, 0x0c000c00, 0x00000000, 0x00000000},
                                {0x0f000f04, 0x0f080010, 0x00500000, 0x24101100, 0x0e000e00, 0x0c000c00, 0x00000000, 0x00000000}};
c_dtrans_param g_blk4_x_dt = {0x1004000f, 0x0000004f, 0x000100ff, 0x00000000, 0x0e000e00};
int g_blk4_x_fm_height = 23;
int g_blk4_x_ifm_offset = 16;

// ftrans ch8 to ch64
c_ftrans_param g_fmtrans = {0x01140801, 0x00000013, 0x00000000, 0x00000e00};
int g_fmtrans_fm_height = 23;

// Blk5_1
c_dwcalc_param g_blk5_1_lb = {0x00220313, 0x32080008, 0x00a00000, 0x26002000, 0x00000000, 0x00000000, 0x00000000, 0x00000000};
c_conv_param   g_blk5_1_lc = {0x1f000313, 0x17090004, 0x00500000, 0x24001000, 0x00000000, 0x00000000, 0x00000000, 0x00000000};
c_conv_param   g_blk5_1_ra = {0x1f000327, 0x130a0004, 0x00a00000, 0x24201080, 0x00000000, 0x00000000, 0x00000000, 0x00000000};
c_dwcalc_param g_blk5_1_rb = {0x00220313, 0x32060008, 0x00a00000, 0x26042024, 0x00000000, 0x00000000, 0x00000000, 0x00000000};
c_conv_param   g_blk5_1_rc = {0x1f000313, 0x1f0a0004, 0x00500000, 0x24401100, 0x00000000, 0x00000000, 0x00000000, 0x00000000};
int g_blk5_1_fm_height = 23;

// Blk6_[1 - 9]
c_conv_param   g_blk6_x_ra[9] ={{0x1f000313, 0x13080008, 0x00a00000, 0x24001000, 0x00000000, 0x00000000, 0x00000000, 0x00000000},
                                {0x1f000313, 0x13080008, 0x00a00000, 0x24001000, 0x00000000, 0x00000000, 0x00000000, 0x00000000},
                                {0x1f000313, 0x13080008, 0x00a00000, 0x24001000, 0x00000000, 0x00000000, 0x00000000, 0x00000000},
                                {0x1f000313, 0x13080008, 0x00a00000, 0x24001000, 0x00000000, 0x00000000, 0x00000000, 0x00000000},
                                {0x1f000313, 0x13080008, 0x00a00000, 0x24001000, 0x00000000, 0x00000000, 0x00000000, 0x00000000},
                                {0x1f000313, 0x13080008, 0x00a00000, 0x24001000, 0x00000000, 0x00000000, 0x00000000, 0x00000000},
                                {0x1f000313, 0x13080008, 0x00a00000, 0x24001000, 0x00000000, 0x00000000, 0x00000000, 0x00000000},
                                {0x1f000313, 0x13080008, 0x00a00000, 0x24001000, 0x00000000, 0x00000000, 0x00000000, 0x00000000},
                                {0x1f000313, 0x13080008, 0x00a00000, 0x24001000, 0x00000000, 0x00000000, 0x00000000, 0x00000000}};
c_dwcalc_param g_blk6_x_rb[9] ={{0x00220313, 0x32070004, 0x00500004, 0x26002000, 0x0c000c00, 0x00000000, 0x00000000, 0x00000000},
                                {0x00220313, 0x32070004, 0x00500004, 0x26002000, 0x0c000c00, 0x00000000, 0x00000000, 0x00000000},
                                {0x00220313, 0x32070004, 0x00500004, 0x26002000, 0x0c000c00, 0x00000000, 0x00000000, 0x00000000},
                                {0x00220313, 0x32070004, 0x00500004, 0x26002000, 0x0c000c00, 0x00000000, 0x00000000, 0x00000000},
                                {0x00220313, 0x32070004, 0x00500004, 0x26002000, 0x0c000c00, 0x00000000, 0x00000000, 0x00000000},
                                {0x00220313, 0x32070004, 0x00500004, 0x26002000, 0x0c000c00, 0x00000000, 0x00000000, 0x00000000},
                                {0x00220313, 0x32070004, 0x00500004, 0x26002000, 0x0c000c00, 0x00000000, 0x00000000, 0x00000000},
                                {0x00220313, 0x32070004, 0x00500004, 0x26002000, 0x0c000c00, 0x00000000, 0x00000000, 0x00000000},
                                {0x00220313, 0x32070004, 0x00500004, 0x26002000, 0x0c000c00, 0x00000000, 0x00000000, 0x00000000}};
c_conv_param   g_blk6_x_rc[9] ={{0x1f000313, 0x1f0a0004, 0x00500000, 0x24201080, 0x0e000e00, 0x0c000c00, 0x00000000, 0x00000000},
                                {0x1f000313, 0x1f0a0004, 0x00500000, 0x24201080, 0x0e000e00, 0x0c000c00, 0x00000000, 0x00000000},
                                {0x1f000313, 0x1f0a0004, 0x00500000, 0x24201080, 0x0e000e00, 0x0c000c00, 0x00000000, 0x00000000},
                                {0x1f000313, 0x1f0a0004, 0x00500000, 0x24201080, 0x0e000e00, 0x0c000c00, 0x00000000, 0x00000000},
                                {0x1f000313, 0x1f0a0004, 0x00500000, 0x24201080, 0x0e000e00, 0x0c000c00, 0x00000000, 0x00000000},
                                {0x1f000313, 0x1f0a0004, 0x00500000, 0x24201080, 0x0e000e00, 0x0c000c00, 0x00000000, 0x00000000},
                                {0x1f000313, 0x1f0a0004, 0x00500000, 0x24201080, 0x0e000e00, 0x0c000c00, 0x00000000, 0x00000000},
                                {0x1f000313, 0x1f0a0004, 0x00500000, 0x24201080, 0x0e000e00, 0x0c000c00, 0x00000000, 0x00000000},
                                {0x1f000313, 0x1f0a0004, 0x00500000, 0x24201080, 0x0e000e00, 0x0c000c00, 0x00000000, 0x00000000}};
c_dtrans_param g_blk6_x_dt = {0x04130003, 0x0000004f, 0x000500ff, 0x00000000, 0x0e000e00};
int g_blk6_x_fm_height = 12;
int g_blk6_x_ifm_offset = 4;

// conv_preds
c_dtrans_param g_convf_dt = {0x0000001f, 0x0000001f, 0x000000ff, 0x3e003e00, 0x00a000a0};
c_ftrans_param g_convf_ft = {0x08010118, 0x00000017, 0x00000000, 0x06000600};
c_conv_param   g_convf = {0x05223f02, 0x02090040, 0x00c00040, 0x24001000, 0x0e000e00, 0x00000000, 0x00000000, 0x00000000};
int g_convf_fm_height = 12;

// ldmr/svmr parameters
// Conv1, Pool1
c_ldmr_param g_conv1_ifm = {DDR_CONV1_FM_ADDR, DDR_CONV1_FM_LEN, 0, 0x00000000};
c_ldmr_param g_conv1_wt = {DDR_CONV1_WT_ADDR, DDR_CONV1_WT_LEN, 0, 0x10001000};
c_ldmr_param g_conv1_bias = {DDR_CONV1_BS_ADDR, DDR_CONV1_BS_LEN, 0, 0x24002400};
c_svmr_param g_conv1_ofm = {DDR_B1_1_FM_ADDR, DDR_B1_1_FM_LEN, 0, 0x00000000};
// Blk1_1
c_ldmr_param g_blk1_1_ifm = {DDR_B1_1_FM_ADDR, DDR_B1_1_FM_LEN, 0, 0x00000000};
c_ldmr_param g_blk1_1_dwc_wt = {DDR_B1_1_DWC_WT_ADDR, DDR_B1_1_DWC_WT_LEN, 0, 0x20002000};
c_ldmr_param g_blk1_1_conv_wt = {DDR_B1_1_CONV_WT_ADDR, DDR_B1_1_CONV_WT_LEN, 0, 0x10001000};
c_ldmr_param g_blk1_1_dwc_bias = {DDR_B1_1_DWC_BS_ADDR, DDR_B1_1_DWC_BS_LEN, 0, 0x26002600};
c_ldmr_param g_blk1_1_conv_bias = {DDR_B1_1_CONV_BS_ADDR, DDR_B1_1_CONV_BS_LEN, 0, 0x24002400};
c_svmr_param g_blk1_1_ofm = {DDR_B2_1_FM_ADDR, DDR_B2_1_FM_LEN, 0, 0x00000000};
// Blk2_[1-3]
c_ldmr_param g_blk2_x_ifm[3] = { {DDR_B2_1_FM_ADDR, DDR_B2_1_FM_LEN, 0, 0x00000000},
                                 {DDR_B2_2_FM_ADDR, DDR_B2_2_FM_LEN, 0, 0x00000000},
                                 {DDR_B2_3_FM_ADDR, DDR_B2_3_FM_LEN, 0, 0x00000000} };
c_ldmr_param g_blk2_x_dwc_wt[3] = { {DDR_B2_1_DWC_WT_ADDR, DDR_B2_1_DWC_WT_LEN, 0, 0x20002000},
                                    {DDR_B2_2_DWC_WT_ADDR, DDR_B2_2_DWC_WT_LEN, 0, 0x20002000},
                                    {DDR_B2_3_DWC_WT_ADDR, DDR_B2_3_DWC_WT_LEN, 0, 0x20002000} };
c_ldmr_param g_blk2_x_conv_wt[3] = { {DDR_B2_1_CONV_WT_ADDR, DDR_B2_1_CONV_WT_LEN, 0, 0x10001000},
                                     {DDR_B2_2_CONV_WT_ADDR, DDR_B2_2_CONV_WT_LEN, 0, 0x10001000},
                                     {DDR_B2_3_CONV_WT_ADDR, DDR_B2_3_CONV_WT_LEN, 0, 0x10001000} };
c_ldmr_param g_blk2_x_dwc_bias[3] = { {DDR_B2_1_DWC_BS_ADDR, DDR_B2_1_DWC_BS_LEN, 0, 0x26002600},
                                      {DDR_B2_2_DWC_BS_ADDR, DDR_B2_2_DWC_BS_LEN, 0, 0x26002600},
                                      {DDR_B2_3_DWC_BS_ADDR, DDR_B2_3_DWC_BS_LEN, 0, 0x26002600} };
c_ldmr_param g_blk2_x_conv_bias[3] = { {DDR_B2_1_CONV_BS_ADDR, DDR_B2_1_CONV_BS_LEN, 0, 0x24002400},
                                       {DDR_B2_2_CONV_BS_ADDR, DDR_B2_2_CONV_BS_LEN, 0, 0x24002400},
                                       {DDR_B2_3_CONV_BS_ADDR, DDR_B2_3_CONV_BS_LEN, 0, 0x24002400} };
c_svmr_param g_blk2_x_ofm[3] = { {DDR_B2_2_FM_ADDR, DDR_B2_2_FM_LEN, 0, 0x0e000e00},
                                 {DDR_B2_3_FM_ADDR, DDR_B2_3_FM_LEN, 0, 0x0e000e00},
                                 {DDR_B3_1_FM_ADDR, DDR_B3_1_FM_LEN, 0, 0x0e000e00} };
// Blk3_1
c_ldmr_param g_blk3_1_ifm = {DDR_B3_1_FM_ADDR, DDR_B3_1_FM_LEN, 0, 0x00000000};
c_ldmr_param g_blk3_1_dwc_wt = {DDR_B3_1_DWC_WT_ADDR, DDR_B3_1_DWC_WT_LEN, 0, 0x20002000};
c_ldmr_param g_blk3_1_conv_wt = {DDR_B3_1_CONV_WT_ADDR, DDR_B3_1_CONV_WT_LEN, 0, 0x10001000};
c_ldmr_param g_blk3_1_dwc_bias = {DDR_B3_1_DWC_BS_ADDR, DDR_B3_1_DWC_BS_LEN, 0, 0x26002600};
c_ldmr_param g_blk3_1_conv_bias = {DDR_B3_1_CONV_BS_ADDR, DDR_B3_1_CONV_BS_LEN, 0, 0x24002400};
c_svmr_param g_blk3_1_ofm = {DDR_B4_1_FM_ADDR, DDR_B4_1_FM_LEN, 0, 0x00000000};
// Blk4_1
c_ldmr_param g_blk4_x_ifm[7] = { {DDR_B4_1_FM_ADDR, DDR_B4_1_FM_LEN, 0, 0x00000000},
                                 {DDR_B4_2_FM_ADDR, DDR_B4_2_FM_LEN, 0, 0x00000000},
                                 {DDR_B4_3_FM_ADDR, DDR_B4_3_FM_LEN, 0, 0x00000000},
                                 {DDR_B4_4_FM_ADDR, DDR_B4_4_FM_LEN, 0, 0x00000000},
                                 {DDR_B4_5_FM_ADDR, DDR_B4_5_FM_LEN, 0, 0x00000000},
                                 {DDR_B4_6_FM_ADDR, DDR_B4_6_FM_LEN, 0, 0x00000000},
                                 {DDR_B4_7_FM_ADDR, DDR_B4_7_FM_LEN, 0, 0x00000000} };
c_ldmr_param g_blk4_x_dwc_wt[7] = { {DDR_B4_1_DWC_WT_ADDR, DDR_B4_1_DWC_WT_LEN, 0, 0x20002000},
                                    {DDR_B4_2_DWC_WT_ADDR, DDR_B4_2_DWC_WT_LEN, 0, 0x20002000},
                                    {DDR_B4_3_DWC_WT_ADDR, DDR_B4_3_DWC_WT_LEN, 0, 0x20002000},
                                    {DDR_B4_4_DWC_WT_ADDR, DDR_B4_4_DWC_WT_LEN, 0, 0x20002000},
                                    {DDR_B4_5_DWC_WT_ADDR, DDR_B4_5_DWC_WT_LEN, 0, 0x20002000},
                                    {DDR_B4_6_DWC_WT_ADDR, DDR_B4_6_DWC_WT_LEN, 0, 0x20002000},
                                    {DDR_B4_7_DWC_WT_ADDR, DDR_B4_7_DWC_WT_LEN, 0, 0x20002000} };
c_ldmr_param g_blk4_x_conv_wt[7] = { {DDR_B4_1_CONV_WT_ADDR, DDR_B4_1_CONV_WT_LEN, 0, 0x10001000},
                                     {DDR_B4_2_CONV_WT_ADDR, DDR_B4_2_CONV_WT_LEN, 0, 0x10001000},
                                     {DDR_B4_3_CONV_WT_ADDR, DDR_B4_3_CONV_WT_LEN, 0, 0x10001000},
                                     {DDR_B4_4_CONV_WT_ADDR, DDR_B4_4_CONV_WT_LEN, 0, 0x10001000},
                                     {DDR_B4_5_CONV_WT_ADDR, DDR_B4_5_CONV_WT_LEN, 0, 0x10001000},
                                     {DDR_B4_6_CONV_WT_ADDR, DDR_B4_6_CONV_WT_LEN, 0, 0x10001000},
                                     {DDR_B4_7_CONV_WT_ADDR, DDR_B4_7_CONV_WT_LEN, 0, 0x10001000} };
c_ldmr_param g_blk4_x_dwc_bias[7] = { {DDR_B4_1_DWC_BS_ADDR, DDR_B4_1_DWC_BS_LEN, 0, 0x26002600},
                                      {DDR_B4_2_DWC_BS_ADDR, DDR_B4_2_DWC_BS_LEN, 0, 0x26002600},
                                      {DDR_B4_3_DWC_BS_ADDR, DDR_B4_3_DWC_BS_LEN, 0, 0x26002600},
                                      {DDR_B4_4_DWC_BS_ADDR, DDR_B4_4_DWC_BS_LEN, 0, 0x26002600},
                                      {DDR_B4_5_DWC_BS_ADDR, DDR_B4_5_DWC_BS_LEN, 0, 0x26002600},
                                      {DDR_B4_6_DWC_BS_ADDR, DDR_B4_6_DWC_BS_LEN, 0, 0x26002600},
                                      {DDR_B4_7_DWC_BS_ADDR, DDR_B4_7_DWC_BS_LEN, 0, 0x26002600} };
c_ldmr_param g_blk4_x_conv_bias[7] = { {DDR_B4_1_CONV_BS_ADDR, DDR_B4_1_CONV_BS_LEN, 0, 0x24002400},
                                       {DDR_B4_2_CONV_BS_ADDR, DDR_B4_2_CONV_BS_LEN, 0, 0x24002400},
                                       {DDR_B4_3_CONV_BS_ADDR, DDR_B4_3_CONV_BS_LEN, 0, 0x24002400},
                                       {DDR_B4_4_CONV_BS_ADDR, DDR_B4_4_CONV_BS_LEN, 0, 0x24002400},
                                       {DDR_B4_5_CONV_BS_ADDR, DDR_B4_5_CONV_BS_LEN, 0, 0x24002400},
                                       {DDR_B4_6_CONV_BS_ADDR, DDR_B4_6_CONV_BS_LEN, 0, 0x24002400},
                                       {DDR_B4_7_CONV_BS_ADDR, DDR_B4_7_CONV_BS_LEN, 0, 0x24002400} };
c_svmr_param g_blk4_x_ofm[7] = { {DDR_B4_2_FM_ADDR, DDR_B4_2_FM_LEN, 0, 0x0e000e00},
                                 {DDR_B4_3_FM_ADDR, DDR_B4_3_FM_LEN, 0, 0x0e000e00},
                                 {DDR_B4_4_FM_ADDR, DDR_B4_4_FM_LEN, 0, 0x0e000e00},
                                 {DDR_B4_5_FM_ADDR, DDR_B4_5_FM_LEN, 0, 0x0e000e00},
                                 {DDR_B4_6_FM_ADDR, DDR_B4_6_FM_LEN, 0, 0x0e000e00},
                                 {DDR_B4_7_FM_ADDR, DDR_B4_7_FM_LEN, 0, 0x0e000e00},
                                 {DDR_B5_1_FM_ADDR, DDR_B5_1_FM_LEN, 0, 0x0e000e00} };

// ftrans ch8 to ch64
c_ldmr_param g_fmtrans_ifm = {DDR_B5_1_FM_ADDR, DDR_B5_1_FM_LEN, 0, 0x00000000};
c_svmr_param g_fmtrans_ofm = {DDR_B5_1_FM_ADDR, DDR_B5_1_FM_LEN, 0, 0x0e000e00};

// Blk5_1
c_ldmr_param g_blk5_1_ifm = {DDR_B5_1_FM_ADDR, DDR_B5_1_FM_LEN, 0, 0x00000000};
c_ldmr_param g_blk5_1_dwc_wt = {DDR_B5_1_DWC_WT_ADDR, DDR_B5_1_DWC_WT_LEN, 0, 0x20002000};
c_ldmr_param g_blk5_1_conv_wt = {DDR_B5_1_CONV_WT_ADDR, DDR_B5_1_CONV_WT_LEN>>3, 0, 0x10001000};
c_ldmr_param g_blk5_1_dwc_bias = {DDR_B5_1_DWC_BS_ADDR, DDR_B5_1_DWC_BS_LEN, 0, 0x26002600};
c_ldmr_param g_blk5_1_conv_bias = {DDR_B5_1_CONV_BS_ADDR, DDR_B5_1_CONV_BS_LEN, 0, 0x24002400};
c_svmr_param g_blk5_1_ofm = {DDR_B6_1_FM_ADDR, DDR_B6_1_FM_LEN, 0, 0x00000000};
// Blk6_x
c_ldmr_param g_blk6_x_ifm[9] = { {DDR_B6_1_FM_ADDR, DDR_B6_1_FM_LEN, 0, 0x00000000},
                                 {DDR_B6_2_FM_ADDR, DDR_B6_2_FM_LEN, 0, 0x00000000},
                                 {DDR_B6_3_FM_ADDR, DDR_B6_3_FM_LEN, 0, 0x00000000},
                                 {DDR_B6_4_FM_ADDR, DDR_B6_4_FM_LEN, 0, 0x00000000},
                                 {DDR_B6_5_FM_ADDR, DDR_B6_5_FM_LEN, 0, 0x00000000},
                                 {DDR_B6_6_FM_ADDR, DDR_B6_6_FM_LEN, 0, 0x00000000},
                                 {DDR_B6_7_FM_ADDR, DDR_B6_7_FM_LEN, 0, 0x00000000},
                                 {DDR_B6_8_FM_ADDR, DDR_B6_8_FM_LEN, 0, 0x00000000},
                                 {DDR_B6_9_FM_ADDR, DDR_B6_9_FM_LEN, 0, 0x00000000} };
c_ldmr_param g_blk6_x_dwc_wt[9] = { {DDR_B6_1_DWC_WT_ADDR, DDR_B6_1_DWC_WT_LEN, 0, 0x20002000},
                                    {DDR_B6_2_DWC_WT_ADDR, DDR_B6_2_DWC_WT_LEN, 0, 0x20002000},
                                    {DDR_B6_3_DWC_WT_ADDR, DDR_B6_3_DWC_WT_LEN, 0, 0x20002000},
                                    {DDR_B6_4_DWC_WT_ADDR, DDR_B6_4_DWC_WT_LEN, 0, 0x20002000},
                                    {DDR_B6_5_DWC_WT_ADDR, DDR_B6_5_DWC_WT_LEN, 0, 0x20002000},
                                    {DDR_B6_6_DWC_WT_ADDR, DDR_B6_6_DWC_WT_LEN, 0, 0x20002000},
                                    {DDR_B6_7_DWC_WT_ADDR, DDR_B6_7_DWC_WT_LEN, 0, 0x20002000},
                                    {DDR_B6_8_DWC_WT_ADDR, DDR_B6_8_DWC_WT_LEN, 0, 0x20002000},
                                    {DDR_B6_9_DWC_WT_ADDR, DDR_B6_9_DWC_WT_LEN, 0, 0x20002000} };
c_ldmr_param g_blk6_x_conv_wt[9] = { {DDR_B6_1_CONV_WT_ADDR, DDR_B6_1_CONV_WT_LEN>>3, 0, 0x10001000},
                                     {DDR_B6_2_CONV_WT_ADDR, DDR_B6_2_CONV_WT_LEN>>3, 0, 0x10001000},
                                     {DDR_B6_3_CONV_WT_ADDR, DDR_B6_3_CONV_WT_LEN>>3, 0, 0x10001000},
                                     {DDR_B6_4_CONV_WT_ADDR, DDR_B6_4_CONV_WT_LEN>>3, 0, 0x10001000},
                                     {DDR_B6_5_CONV_WT_ADDR, DDR_B6_5_CONV_WT_LEN>>3, 0, 0x10001000},
                                     {DDR_B6_6_CONV_WT_ADDR, DDR_B6_6_CONV_WT_LEN>>3, 0, 0x10001000},
                                     {DDR_B6_7_CONV_WT_ADDR, DDR_B6_7_CONV_WT_LEN>>3, 0, 0x10001000},
                                     {DDR_B6_8_CONV_WT_ADDR, DDR_B6_8_CONV_WT_LEN>>3, 0, 0x10001000},
                                     {DDR_B6_9_CONV_WT_ADDR, DDR_B6_9_CONV_WT_LEN>>3, 0, 0x10001000} };
c_ldmr_param g_blk6_x_dwc_bias[9] = { {DDR_B6_1_DWC_BS_ADDR, DDR_B6_1_DWC_BS_LEN, 0, 0x26002600},
                                      {DDR_B6_2_DWC_BS_ADDR, DDR_B6_2_DWC_BS_LEN, 0, 0x26002600},
                                      {DDR_B6_3_DWC_BS_ADDR, DDR_B6_3_DWC_BS_LEN, 0, 0x26002600},
                                      {DDR_B6_4_DWC_BS_ADDR, DDR_B6_4_DWC_BS_LEN, 0, 0x26002600},
                                      {DDR_B6_5_DWC_BS_ADDR, DDR_B6_5_DWC_BS_LEN, 0, 0x26002600},
                                      {DDR_B6_6_DWC_BS_ADDR, DDR_B6_6_DWC_BS_LEN, 0, 0x26002600},
                                      {DDR_B6_7_DWC_BS_ADDR, DDR_B6_7_DWC_BS_LEN, 0, 0x26002600},
                                      {DDR_B6_8_DWC_BS_ADDR, DDR_B6_8_DWC_BS_LEN, 0, 0x26002600},
                                      {DDR_B6_9_DWC_BS_ADDR, DDR_B6_9_DWC_BS_LEN, 0, 0x26002600} };
c_ldmr_param g_blk6_x_conv_bias[9] = { {DDR_B6_1_CONV_BS_ADDR, DDR_B6_1_CONV_BS_LEN, 0, 0x24002400},
                                       {DDR_B6_2_CONV_BS_ADDR, DDR_B6_2_CONV_BS_LEN, 0, 0x24002400},
                                       {DDR_B6_3_CONV_BS_ADDR, DDR_B6_3_CONV_BS_LEN, 0, 0x24002400},
                                       {DDR_B6_4_CONV_BS_ADDR, DDR_B6_4_CONV_BS_LEN, 0, 0x24002400},
                                       {DDR_B6_5_CONV_BS_ADDR, DDR_B6_5_CONV_BS_LEN, 0, 0x24002400},
                                       {DDR_B6_6_CONV_BS_ADDR, DDR_B6_6_CONV_BS_LEN, 0, 0x24002400},
                                       {DDR_B6_7_CONV_BS_ADDR, DDR_B6_7_CONV_BS_LEN, 0, 0x24002400},
                                       {DDR_B6_8_CONV_BS_ADDR, DDR_B6_8_CONV_BS_LEN, 0, 0x24002400},
                                       {DDR_B6_9_CONV_BS_ADDR, DDR_B6_9_CONV_BS_LEN, 0, 0x24002400} };
c_svmr_param g_blk6_x_ofm[9] = { {DDR_B6_2_FM_ADDR, DDR_B6_2_FM_LEN, 0, 0x0e000e00},
                                 {DDR_B6_3_FM_ADDR, DDR_B6_3_FM_LEN, 0, 0x0e000e00},
                                 {DDR_B6_4_FM_ADDR, DDR_B6_4_FM_LEN, 0, 0x0e000e00},
                                 {DDR_B6_5_FM_ADDR, DDR_B6_5_FM_LEN, 0, 0x0e000e00},
                                 {DDR_B6_6_FM_ADDR, DDR_B6_6_FM_LEN, 0, 0x0e000e00},
                                 {DDR_B6_7_FM_ADDR, DDR_B6_7_FM_LEN, 0, 0x0e000e00},
                                 {DDR_B6_8_FM_ADDR, DDR_B6_8_FM_LEN, 0, 0x0e000e00},
                                 {DDR_B6_9_FM_ADDR, DDR_B6_9_FM_LEN, 0, 0x0e000e00},
                                 {DDR_CONVF_FM_ADDR, DDR_CONVF_FM_LEN, 0, 0x0e000e00} };
// CONVF(Conv Preds)
c_ldmr_param g_convf_ifm = {DDR_CONVF_FM_ADDR, DDR_CONVF_FM_LEN, 0, 0x00000000};
c_ldmr_param g_convf_wt = {DDR_CONVF_WT_ADDR, DDR_CONVF_WT_LEN, 0, 0x10001000};
c_ldmr_param g_convf_bias = {DDR_CONVF_BS_ADDR, DDR_CONVF_BS_LEN, 0, 0x24002400};
c_svmr_param g_convf_ofm = {DDR_OUTPUT_FM_ADDR, DDR_OUTPUT_FM_LEN, 0, 0x0e000e00};

