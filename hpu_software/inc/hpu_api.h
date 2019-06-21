// +FHDR------------------------------------------------------------------------
// Copyright ownership belongs to CAG laboratory, Institute of Artificial
// Intelligence and Robotics, Xi'an Jiaotong University, shall not be used in
// commercial ways without permission.
// -----------------------------------------------------------------------------
// FILE NAME  : hpu_api.h
// DEPARTMENT : CAG of IAIR
// AUTHOR     : XXXX
// AUTHOR'S EMAIL :XXXX@mail.xjtu.edu.cn
// -----------------------------------------------------------------------------
// Ver 1.0  2019--01--01 initial version.
// -----------------------------------------------------------------------------

#ifndef _HPU_API_H
#define _HPU_API_H

#ifdef __cplusplus
extern "C" {
#endif

// Data structure
typedef struct conv_param {
    int ctrl_param0;// [31:24]ofm_channel [23:20]wt_height [19:16]wt_width [15:8]ifm_channel [7:0]ifm_width
    int ctrl_param1;// [28]channel64_priority [27:26]channel_shuffle_type [25]bias_en [24]relu_en [20:16]clip_data [15:8]dilation_w [7:0]stride_w
    int ctrl_pad;   // [24:16]pad_offset [8:0]pad_left
    int wt_addr;    // [29:25]bias_mr_index [24:16]bias_mr_addr [13:9]wt_mr_index [8:0]wt_mr_addr
    int ofm_addr;   // [13:9]ofm_mr_index [8:0]ofm_mr_addr
    int ifm_addr0;  // [29:25]core1_ifm_line0_mr_index [24:16]core1_ifm_line0_mr_addr [13:9]core0_ifm_line0_mr_index [8:0]core0_ifm_line0_mr_addr
    int ifm_addr1;  // [29:25]core1_ifm_line1_mr_index [24:16]core1_ifm_line1_mr_addr [13:9]core0_ifm_line1_mr_index [8:0]core0_ifm_line1_mr_addr
    int ifm_addr2;  // [29:25]core1_ifm_line2_mr_index [24:16]core1_ifm_line2_mr_addr [13:9]core0_ifm_line2_mr_index [8:0]core0_ifm_line2_mr_addr
} c_conv_param, *pc_conv_param;

typedef struct dwcalc_set_param {
    int ctrl_param0;// [23:20]wt_height [19:16]wt_width [15:8]ifm_channel [7:0]ifm_width
    int ctrl_param1;// [30:29]ld_calc_type [28]channel64_priority [27:26]channel_shuffle_type [25]bias_en [24]relu_en [20:16]clip_data [15:8]dilation_w [7:0]stride_w
    int ctrl_pad;   // [24:16]pad_offset [8:0]pad_left
    int wt_addr;    // [29:25]bias_mr_index [24:16]bias_mr_addr [13:9]wt_mr_index [8:0]wt_mr_addr
    int ofm_addr;   // [13:9]ofm_mr_index [8:0]ofm_mr_addr
    int ifm_addr0;  // [29:25]core1_ifm_line0_mr_index [24:16]core1_ifm_line0_mr_addr [13:9]core0_ifm_line0_mr_index [8:0]core0_ifm_line0_mr_addr
    int ifm_addr1;  // [29:25]core1_ifm_line1_mr_index [24:16]core1_ifm_line1_mr_addr [13:9]core0_ifm_line1_mr_index [8:0]core0_ifm_line1_mr_addr
    int ifm_addr2;  // [29:25]core1_ifm_line2_mr_index [24:16]core1_ifm_line2_mr_addr [13:9]core0_ifm_line2_mr_index [8:0]core0_ifm_line2_mr_addr
} c_dwcalc_param, *pc_dwcalc_param;

typedef struct dtrans_param {
    int ctrl_param0;// [31:24]src_dilation [23:16]src_batch_num [15:0]src_batch_size
    int ctrl_param1;// [31:24]dest_dilation [23:16]dest_batch_num [15:0]dest_batch_size
    int ctrl_param2;// [18]channel64_priority [17:16]channel_shuffle_type [9:8]mtx_shift_v_type [7:0]mtx_strobe_h
    int src_addr;   // [13:9]src_mr_index [8:0]src_mr_addr
    int dest_addr;  // [13:9]dest_mr_index [8:0]dest_mr_addr
} c_dtrans_param, *pc_dtrans_param;

typedef struct ftrans_param {
    int ctrl_param0;// [31:24]dest_sect_step [23:16]dest_step [15:8]src_sect_step [7:0]src_step
    int ctrl_param1;// [7:0]sect_num
    int src_addr;   // [13:9]src_mr_index [8:0]src_mr_addr
    int dest_addr;  // [13:9]dest_mr_index [8:0]dest_mr_addr
} c_ftrans_param, *pc_ftrans_param;

typedef struct ldmr_param {
    int ddr_addr;   // [31:0]ddr_address
    int trans_len;  // [31:0]translation length
    int core;       // [0:0]hpu_core id
    int mr_addr;    // [29:25]core1_mr_index [24:16]core1_mr_addr [13:9]core0_mr_index [8:0]core0_mr_addr
    int reoder_en;  // [0:0] first ifm should reoder from 3 channels(BGR) to 16 channels ;
} c_ldmr_param, *pc_ldmr_param;

typedef struct svmr_param {
    int ddr_addr;   // [31:0]ddr_address
    int trans_len;  // [31:0]translation length
    int core;       // [0:0]hpu_core id
    int mr_addr;    // [29:25]core1_mr_index [24:16]core1_mr_addr [13:9]core0_mr_index [8:0]core0_mr_addr
} c_svmr_param, *pc_svmr_param;

typedef struct dlctrl_param {
    int dlctrl_fm_ddr_base_addr;
    int dlctrl_weight_ddr_base_addr;
    int dlctrl_bias_ddr_base_addr;
} c_dlctrl_param, *pc_dlctrl_param;

typedef struct uplctrl_param {
    int uplctrl_ddr_base_addr;  // [31:0]source ddr address, unit is 1B
    int uplctrl_trans_len;      // [15:0]trans_len, unit is 64B
} c_uplctrl_param, *pc_uplctrl_param;

// Function interface
void conv_set (pc_conv_param param);
void conv_start (void);
int conv_check (void);

void dwcalc_set (pc_dwcalc_param param);
void dwcalc_start (void);
int dwcalc_check (void);

void dtrans_set (pc_dtrans_param param);
void dtrans_start (void);
int dtrans_check (void);

void ftrans_set (pc_ftrans_param param);
void ftrans_start (void);
int ftrans_check (void);

void ldmr_set (pc_ldmr_param param);
void ldmr_start (void);
int ldmr_check (void);

void svmr_set (pc_svmr_param param);
void svmr_start (void);
int svmr_check (void);

void dlctrl_set(pc_dlctrl_param param);

void uplctrl_set(pc_uplctrl_param param);
void uplctrl_start(void);

void fshflg_ps(void);

#ifdef __cplusplus
}
#endif

#endif
