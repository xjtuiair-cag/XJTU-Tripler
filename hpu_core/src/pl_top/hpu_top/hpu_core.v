// +FHDR------------------------------------------------------------------------
// XJTU IAIR Corporation All Rights Reserved
// -----------------------------------------------------------------------------
// FILE NAME  : hpu_core.v
// DEPARTMENT : CAG of IAIR
// AUTHOR     : XXXX
// AUTHOR'S EMAIL :XXXX@mail.xjtu.edu.cn
// -----------------------------------------------------------------------------
// Ver 1.0  2019--01--01 initial version.
// -----------------------------------------------------------------------------
// KEYWORDS   : hpu data path, memory
// -----------------------------------------------------------------------------
// PURPOSE    :
// -----------------------------------------------------------------------------
// PARAMETERS :
// -----------------------------------------------------------------------------
// REUSE ISSUES
// Reset Strategy   :
// Clock Domains    :
// Critical Timing  :
// Test Features    :
// Asynchronous I/F :
// Scan Methodology : N
// Instantiations   : N
// Synthesizable    : Y
// Other :
// -FHDR------------------------------------------------------------------------
`timescale 1ns / 1ps

module hpu_core #(
    parameter SR_DATA_WTH = 32,
    parameter MRA_IND_WTH = 3,
    parameter MRA_ADDR_WTH = 9,
    parameter MRB_IND_WTH = 3,
    parameter MRB_ADDR_WTH = 9,
    parameter MRC_IND_WTH = 1,
    parameter MRC_ADDR_WTH = 9,
    parameter BR_IND_WTH = 1,
    parameter BR_ADDR_WTH = 9,
    parameter MR_PROC_WTH = 8,
    parameter VR_PROC_WTH = 32,
    parameter VMR_PROC_WTH = 64,
    parameter BR_PROC_WTH = 8,
    parameter MR_PROC_H_PARAL = 8,
    parameter MR_PROC_V_PARAL = 8,
    parameter MTX_DATA_WTH = MR_PROC_WTH * MR_PROC_V_PARAL,
    parameter MR_DATA_WTH = MTX_DATA_WTH * MR_PROC_H_PARAL,
    parameter BR_DATA_WTH = 64,
    parameter VMR_DATA_WTH = MR_PROC_H_PARAL * MR_PROC_V_PARAL * VMR_PROC_WTH,
    parameter MR_DSTROB_H_WTH = 8,
    parameter MR_DSTROB_V_WTH = 8,
    parameter VR_PROC_PARAL = 64,
    parameter VR_IND_WTH = 4,
    parameter VR_DATA_WTH = VR_PROC_PARAL * VR_PROC_WTH,
    parameter VPR_IND_WTH = 3,
    parameter VPR_DATA_WTH = VR_PROC_PARAL,
    parameter DDRIF_DATA_WTH = 512
) (
    // clock & reset
    input                                   clk_i,
    input                                   clk_2x_i,
    input                                   rst_i,

    // from mpu_ctrl module
    input                                   mpu_op_extacc_act_i,
    input                                   mpu_op_bypass_act_i,
    input [0 : 0]                           mpu_op_type_i,

    input [VR_IND_WTH-1 : 0]                mpu_vr__windex_i,
    input                                   mpu_vr__we_i,
    input [VR_IND_WTH-1 : 0]                mpu_vr__rindex_i,
    input                                   mpu_vr__re_i,

    input [MRA_IND_WTH-1 : 0]               mpu_mra__rindex_i,
    input [MRA_ADDR_WTH-1 : 0]              mpu_mra__raddr_i,
    input                                   mpu_mra__sl_i,
    input                                   mpu_mra__sr_i,
    input                                   mpu_mra__frcz_i,
    input                                   mpu_mra__re_i,

    input [MRB_IND_WTH-1 : 0]               mpu_mrb__rindex_i,
    input [MRB_ADDR_WTH-1 : 0]              mpu_mrb__raddr_i,
    input                                   mpu_mrb__re_i,
    input [0 : 0]                           mpu_mrb__type_i,

    // from vpu_ctrl module
    input                                   vpu_op_sum_act_i,
    input [4 : 0]                           vpu_op_clip_i,
    input                                   vpu_op_bias_act_i,
    input                                   vpu_op_relu_act_i,
    input                                   vpu_op_shfl_act_i,
    input                                   vpu_op_shfl_up_act_i,
    input [7 : 0]                           vpu_op_strobe_h_i,
    input [7 : 0]                           vpu_op_strobe_v_i,

    input [VR_IND_WTH-1 : 0]                vpu_vr__rd_windex_i,
    input                                   vpu_vr__rd_we_i,
    input [VR_IND_WTH-1 : 0]                vpu_vr__rs0_rindex_i,
    input [VR_IND_WTH-1 : 0]                vpu_vr__rs1_rindex_i,
    input                                   vpu_vr__rs_re_i,
    input [VPR_IND_WTH-1 : 0]               vpu_vr__rpd_windex_i,
    input                                   vpu_vr__rpd_we_i,
    input [VPR_IND_WTH-1 : 0]               vpu_vr__rps0_rindex_i,
    input [VPR_IND_WTH-1 : 0]               vpu_vr__rps1_rindex_i,
    input                                   vpu_vr__rps_re_i,

    input [MRA_IND_WTH-1 : 0]               vpu_mra__windex_i,
    input [MRA_ADDR_WTH-1 : 0]              vpu_mra__waddr_i,
    input                                   vpu_mra__we_i,

    input [BR_IND_WTH-1 : 0]                vpu_brb__rindex_i,
    input [BR_ADDR_WTH-1 : 0]               vpu_brb__raddr_i,
    input                                   vpu_brb__re_i,

    // from vpu_tiny_ctrl module
    input                                   vputy_op_mul_sel_i,
    input                                   vputy_op_ldsl_sel_i,
    input                                   vputy_op_ldsr_sel_i,
    input                                   vputy_op_acc_sel_i,
    input                                   vputy_op_max_sel_i,
    input                                   vputy_sv_sel_act_i,
    input [2 : 0]                           vputy_sv_mtx_sel_h_i,
    input [4 : 0]                           vputy_sv_clip_i,
    input                                   vputy_sv_bias_act_i,
    input                                   vputy_sv_relu_act_i,
    input                                   vputy_sv_shfl_act_i,
    input                                   vputy_sv_chpri_act_i,
    input                                   vputy_sv_shfl_up_act_i,
    input [7 : 0]                           vputy_sv_strobe_h_i,
    input [7 : 0]                           vputy_sv_strobe_v_i,

    input [MRA_IND_WTH-1 : 0]               vputy_mra__rindex_i,
    input [MRA_ADDR_WTH-1 : 0]              vputy_mra__raddr_i,
    input                                   vputy_mra__sl_i,
    input                                   vputy_mra__sr_i,
    input                                   vputy_mra__frcz_i,
    input                                   vputy_mra__re_i,
    input [MRA_IND_WTH-1 : 0]               vputy_mra__windex_i,
    input [MRA_ADDR_WTH-1 : 0]              vputy_mra__waddr_i,
    input                                   vputy_mra__we_i,

    input [MRC_IND_WTH-1 : 0]               vputy_mrc__rindex_i,
    input [MRC_ADDR_WTH-1 : 0]              vputy_mrc__raddr_i,
    input                                   vputy_mrc__re_i,

    input [BR_IND_WTH-1 : 0]                vputy_brc__rindex_i,
    input [BR_ADDR_WTH-1 : 0]               vputy_brc__raddr_i,
    input                                   vputy_brc__re_i,

    // from load_mtxreg_ctrl module
    input [MRA_IND_WTH-1 : 0]               ldmr_mra__windex_i,
    input [MRA_ADDR_WTH-1 : 0]              ldmr_mra__waddr_i,
    input                                   ldmr_mra__we_i,

    input [MRB_IND_WTH-1 : 0]               ldmr_mrb__windex_i,
    input [MRB_ADDR_WTH-1 : 0]              ldmr_mrb__waddr_i,
    input                                   ldmr_mrb__we_i,

    input [MRC_IND_WTH-1 : 0]               ldmr_mrc__windex_i,
    input [MRC_ADDR_WTH-1 : 0]              ldmr_mrc__waddr_i,
    input                                   ldmr_mrc__we_i,

    input [BR_IND_WTH-1 : 0]                ldmr_brb__windex_i,
    input [BR_ADDR_WTH-1 : 0]               ldmr_brb__waddr_i,
    input                                   ldmr_brb__we_i,

    input [BR_IND_WTH-1 : 0]                ldmr_brc__windex_i,
    input [BR_ADDR_WTH-1 : 0]               ldmr_brc__waddr_i,
    input                                   ldmr_brc__we_i,

    input [4 : 0]                           ldmr_mrx__sel_i,

    // from save_mtxreg_ctrl module
    input [MRA_IND_WTH-1 : 0]               svmr_mra__rindex_i,
    input [MRA_ADDR_WTH-1 : 0]              svmr_mra__raddr_i,
    input                                   svmr_mra__re_i,

    // from ddr_intf module
    input [DDRIF_DATA_WTH-1 : 0]            ldmr_ddrintf__rdata_i,
    input                                   ldmr_ddrintf__rdata_act_i,

    // to ddr_intf module
    output[DDRIF_DATA_WTH-1 : 0]            svmr_ddrintf__wdata_o,
    output                                  svmr_ddrintf__wdata_act_o
);

//======================================================================================================================
// Wire & Reg declaration
//======================================================================================================================

// to vpu module
wire  [VR_DATA_WTH-1 : 0]               mpu_vr__wdata;
wire                                    mpu_vr__wdata_act;

// to mtxrega module
wire  [MR_DATA_WTH-1 : 0]               vpu_mra__wdata;
wire  [MR_DSTROB_H_WTH-1 : 0]           vpu_mra__wdata_strob_h;
wire  [MR_DSTROB_V_WTH-1 : 0]           vpu_mra__wdata_strob_v;
wire                                    vpu_mra__wdata_act;

// to mtxregb module
wire  [MR_DATA_WTH-1 : 0]               vpu_mrb__wdata;
wire  [MR_DSTROB_H_WTH-1 : 0]           vpu_mrb__wdata_strob_h;
wire  [MR_DSTROB_V_WTH-1 : 0]           vpu_mrb__wdata_strob_v;
wire                                    vpu_mrb__wdata_act;

// to mtxrega module
wire  [MR_DATA_WTH-1 : 0]               vputy_mra__wdata;
wire  [MR_DSTROB_H_WTH-1 : 0]           vputy_mra__wdata_strob_h;
wire  [MR_DSTROB_V_WTH-1 : 0]           vputy_mra__wdata_strob_v;
wire                                    vputy_mra__wdata_act;

// to mpu module
wire  [VR_DATA_WTH-1 : 0]               mpu_vr__rdata;
wire                                    mpu_vr__rdata_act;

// to vpu module
wire  [VR_DATA_WTH-1 : 0]               vpu_vr__rs0_rdata;
wire  [VR_DATA_WTH-1 : 0]               vpu_vr__rs1_rdata;
wire                                    vpu_vr__rs_rdata_act;
wire  [VPR_DATA_WTH-1 : 0]              vpu_vr__rps0_rdata;
wire  [VPR_DATA_WTH-1 : 0]              vpu_vr__rps1_rdata;
wire                                    vpu_vr__rps_rdata_act;

// to mpu module
wire  [MR_DATA_WTH-1 : 0]               mpu_mra__rdata;
wire                                    mpu_mra__rdata_act;

wire  [VMR_DATA_WTH-1 : 0]              mpu_mrb__vmode_rdata;
wire                                    mpu_mrb__vmode_rdata_act;

// to vputy module
wire  [MR_DATA_WTH-1 : 0]               vputy_mra__rdata;
wire                                    vputy_mra__rdata_act;

// to ddr_intf module
wire  [MR_DATA_WTH-1 : 0]               svmr_mra__rdata;
wire                                    svmr_mra__rdata_act;

// to mpu module
wire  [MR_DATA_WTH-1 : 0]               mpu_mrb__rdata;
wire                                    mpu_mrb__rdata_act;

// to ddr_intf module
wire  [MR_DATA_WTH-1 : 0]               svmr_mrb__rdata;
wire                                    svmr_mrb__rdata_act;

// to vpu_tiny module
wire  [MR_DATA_WTH-1 : 0]               vputy_mrc__rdata;
wire                                    vputy_mrc__rdata_act;

// to vpu module
wire  [BR_DATA_WTH-1 : 0]               vpu_brb__rdata;
wire                                    vpu_brb__rdata_act;

// to vputy module
wire  [MR_DATA_WTH-1 : 0]               vputy_brc__rdata;
wire                                    vputy_brc__rdata_act;

// to mtxrega module
wire  [MR_DATA_WTH-1 : 0]               ldmr_mra__wdata;
wire                                    ldmr_mra__wdata_act;

// to mtxregb module
wire  [MR_DATA_WTH-1 : 0]               ldmr_mrb__wdata;
wire                                    ldmr_mrb__wdata_act;

// to mtxregc module
wire  [MR_DATA_WTH-1 : 0]               ldmr_mrc__wdata;
wire                                    ldmr_mrc__wdata_act;

// to biasreg module
wire  [BR_DATA_WTH-1 : 0]               ldmr_brb__wdata;
wire                                    ldmr_brb__wdata_act;

wire  [MR_DATA_WTH-1 : 0]               ldmr_brc__wdata;
wire                                    ldmr_brc__wdata_act;

//======================================================================================================================
// Instance
//======================================================================================================================
//mpu #(
//    .MR_PROC_WTH        (MR_PROC_WTH),
//    .VR_PROC_WTH        (VR_PROC_WTH),
//    .MR_PROC_H_PARAL    (MR_PROC_H_PARAL),
//    .MR_PROC_V_PARAL    (MR_PROC_V_PARAL),
//    .MTX_DATA_WTH       (MTX_DATA_WTH),
//    .MR_DATA_WTH        (MR_DATA_WTH),
//    .VMR_DATA_WTH       (VMR_DATA_WTH),
//    .VR_DATA_WTH        (VR_DATA_WTH)
//) mpu_inst (
mpu mpu_inst (
    // clock & reset
    .clk_i                                  (clk_i),
    .clk_2x_i                               (clk_2x_i),
    .rst_i                                  (rst_i),

    // from mpu_ctrl module
    .mpu_op_extacc_act_i                    (mpu_op_extacc_act_i),
    .mpu_op_bypass_act_i                    (mpu_op_bypass_act_i),
    .mpu_op_type_i                          (mpu_op_type_i),

    // from mtxrega module
    .mpu_mra__rdata_i                       (mpu_mra__rdata),
    .mpu_mra__rdata_act_i                   (mpu_mra__rdata_act),

    // from mtxregb module
    .mpu_mrb__rdata_i                       (mpu_mrb__rdata),
    .mpu_mrb__rdata_act_i                   (mpu_mrb__rdata_act),

    .mpu_mrb__vmode_rdata_i                 (mpu_mrb__vmode_rdata),
    .mpu_mrb__vmode_rdata_act_i             (mpu_mrb__vmode_rdata_act),

    // to vecreg module
    .mpu_vr__wdata_o                        (mpu_vr__wdata),
    .mpu_vr__wdata_act_o                    (mpu_vr__wdata_act),

    // from vecreg module: for accumulation
    .mpu_vr__rdata_i                        (mpu_vr__rdata),
    .mpu_vr__rdata_act_i                    (mpu_vr__rdata_act)
);

//vpu #(
//    .SR_DATA_WTH        (SR_DATA_WTH),
//    .MR_PROC_WTH        (MR_PROC_WTH),
//    .VR_PROC_WTH        (VR_PROC_WTH),
//    .MR_PROC_H_PARAL    (MR_PROC_H_PARAL),
//    .MR_PROC_V_PARAL    (MR_PROC_V_PARAL),
//    .MTX_DATA_WTH       (MTX_DATA_WTH),
//    .MR_DATA_WTH        (MR_DATA_WTH),
//    .VMR_DATA_WTH       (VMR_DATA_WTH),
//    .VR_DATA_WTH        (VR_DATA_WTH),
//    .VPR_DATA_WTH       (VPR_DATA_WTH),
//    .BR_DATA_WTH        (BR_DATA_WTH),
//    .MR_DSTROB_H_WTH    (MR_DSTROB_H_WTH),
//    .MR_DSTROB_V_WTH    (MR_DSTROB_V_WTH)
//) vpu_inst (
vpu vpu_inst (
    // clock & reset
    .clk_i                                  (clk_i),
    .clk_2x_i                               (clk_2x_i),
    .rst_i                                  (rst_i),

    // from vpu_ctrl module
    .vpu_op_sum_act_i                       (vpu_op_sum_act_i),
    .vpu_op_clip_i                          (vpu_op_clip_i),
    .vpu_op_bias_act_i                      (vpu_op_bias_act_i),
    .vpu_op_relu_act_i                      (vpu_op_relu_act_i),
    .vpu_op_shfl_act_i                      (vpu_op_shfl_act_i),
    .vpu_op_shfl_up_act_i                   (vpu_op_shfl_up_act_i),
    .vpu_op_strobe_h_i                      (vpu_op_strobe_h_i),
    .vpu_op_strobe_v_i                      (vpu_op_strobe_v_i),

    // from vecreg module
    .vpu_vr__rs0_rdata_i                    (vpu_vr__rs0_rdata),
    .vpu_vr__rs1_rdata_i                    (vpu_vr__rs1_rdata),
    .vpu_vr__rs_rdata_act_i                 (vpu_vr__rs_rdata_act),

    // from biasreg module
    .vpu_brb__rdata_i                       (vpu_brb__rdata),
    .vpu_brb__rdata_act_i                   (vpu_brb__rdata_act),

    // to mtxrega module
    .vpu_mra__wdata_o                       (vpu_mra__wdata),
    .vpu_mra__wdata_strob_h_o               (vpu_mra__wdata_strob_h),
    .vpu_mra__wdata_strob_v_o               (vpu_mra__wdata_strob_v),
    .vpu_mra__wdata_act_o                   (vpu_mra__wdata_act)
);

//vputy #(
//    .MR_PROC_WTH        (MR_PROC_WTH),
//    .MR_PROC_H_PARAL    (MR_PROC_H_PARAL),
//    .MR_PROC_V_PARAL    (MR_PROC_V_PARAL),
//    .MTX_DATA_WTH       (MTX_DATA_WTH),
//    .MR_DATA_WTH        (MR_DATA_WTH),
//    .MR_DSTROB_H_WTH    (MR_DSTROB_H_WTH),
//    .MR_DSTROB_V_WTH    (MR_DSTROB_V_WTH)
//) vputy_inst (
vputy vputy_inst (
    // clock & reset
    .clk_i                                  (clk_i),
    .clk_2x_i                               (clk_2x_i),
    .rst_i                                  (rst_i),

    // from vpu_tiny_ctrl module
    .vputy_op_mul_sel_i                     (vputy_op_mul_sel_i),
    .vputy_op_ldsl_sel_i                    (vputy_op_ldsl_sel_i),
    .vputy_op_ldsr_sel_i                    (vputy_op_ldsr_sel_i),
    .vputy_op_acc_sel_i                     (vputy_op_acc_sel_i),
    .vputy_op_max_sel_i                     (vputy_op_max_sel_i),
    .vputy_sv_sel_act_i                     (vputy_sv_sel_act_i),
    .vputy_sv_mtx_sel_h_i                   (vputy_sv_mtx_sel_h_i),
    .vputy_sv_clip_i                        (vputy_sv_clip_i),
    .vputy_sv_bias_act_i                    (vputy_sv_bias_act_i),
    .vputy_sv_relu_act_i                    (vputy_sv_relu_act_i),
    .vputy_sv_shfl_act_i                    (vputy_sv_shfl_act_i),
    .vputy_sv_chpri_act_i                   (vputy_sv_chpri_act_i),
    .vputy_sv_shfl_up_act_i                 (vputy_sv_shfl_up_act_i),
    .vputy_sv_strobe_h_i                    (vputy_sv_strobe_h_i),
    .vputy_sv_strobe_v_i                    (vputy_sv_strobe_v_i),

    // from mtxrega module
    .vputy_mra__rdata_i                     (vputy_mra__rdata),
    .vputy_mra__rdata_act_i                 (vputy_mra__rdata_act),

    // from mtxregc module
    .vputy_mrc__rdata_i                     (vputy_mrc__rdata),
    .vputy_mrc__rdata_act_i                 (vputy_mrc__rdata_act),

    // from biasreg module
    .vputy_brc__rdata_i                     (vputy_brc__rdata),
    .vputy_brc__rdata_act_i                 (vputy_brc__rdata_act),

    // to mtxrega module
    .vputy_mra__wdata_o                     (vputy_mra__wdata),
    .vputy_mra__wdata_strob_h_o             (vputy_mra__wdata_strob_h),
    .vputy_mra__wdata_strob_v_o             (vputy_mra__wdata_strob_v),
    .vputy_mra__wdata_act_o                 (vputy_mra__wdata_act)
);

vecreg #(
    .VR_PROC_WTH        (VR_PROC_WTH),
    .VR_PROC_PARAL      (VR_PROC_PARAL),
    .VR_IND_WTH         (VR_IND_WTH),
    .VR_DATA_WTH        (VR_DATA_WTH),
    .VPR_IND_WTH        (VPR_IND_WTH),
    .VPR_DATA_WTH       (VPR_DATA_WTH)
) vecreg_inst (
    // clock & reset
    .clk_i                                  (clk_i),
    .rst_i                                  (rst_i),

    // from mpu_ctrl module
    .mpu_vr__windex_i                       (mpu_vr__windex_i),
    .mpu_vr__we_i                           (mpu_vr__we_i),
    .mpu_vr__rindex_i                       (mpu_vr__rindex_i),
    .mpu_vr__re_i                           (mpu_vr__re_i),

    // from mpu module
    .mpu_vr__wdata_i                        (mpu_vr__wdata),
    .mpu_vr__wdata_act_i                    (mpu_vr__wdata_act),
    // to mpu module
    .mpu_vr__rdata_o                        (mpu_vr__rdata),
    .mpu_vr__rdata_act_o                    (mpu_vr__rdata_act),

    // from vpu_ctrl module
    .vpu_vr__rd_windex_i                    (vpu_vr__rd_windex_i),
    .vpu_vr__rd_we_i                        (vpu_vr__rd_we_i),
    .vpu_vr__rs0_rindex_i                   (vpu_vr__rs0_rindex_i),
    .vpu_vr__rs1_rindex_i                   (vpu_vr__rs1_rindex_i),
    .vpu_vr__rs_re_i                        (vpu_vr__rs_re_i),
    .vpu_vr__rpd_windex_i                   (vpu_vr__rpd_windex_i),
    .vpu_vr__rpd_we_i                       (vpu_vr__rpd_we_i),
    .vpu_vr__rps0_rindex_i                  (vpu_vr__rps0_rindex_i),
    .vpu_vr__rps1_rindex_i                  (vpu_vr__rps1_rindex_i),
    .vpu_vr__rps_re_i                       (vpu_vr__rps_re_i),

    // from vpu module
    .vpu_vr__rd_wdata_i                     ('h0),
    .vpu_vr__rd_wdata_act_i                 ('h0),
    .vpu_vr__rpd_wdata_i                    ('h0),
    .vpu_vr__rpd_wdata_act_i                ('h0),

    // to vpu module
    .vpu_vr__rs0_rdata_o                    (vpu_vr__rs0_rdata),
    .vpu_vr__rs1_rdata_o                    (vpu_vr__rs1_rdata),
    .vpu_vr__rs_rdata_act_o                 (vpu_vr__rs_rdata_act),
    .vpu_vr__rps0_rdata_o                   (vpu_vr__rps0_rdata),
    .vpu_vr__rps1_rdata_o                   (vpu_vr__rps1_rdata),
    .vpu_vr__rps_rdata_act_o                (vpu_vr__rps_rdata_act)
);

mtxrega #(
    .MRA_IND_WTH        (MRA_IND_WTH),
    .MRA_ADDR_WTH       (MRA_ADDR_WTH),
    .MR_PROC_WTH        (MR_PROC_WTH),
    .MR_PROC_H_PARAL    (MR_PROC_H_PARAL),
    .MR_PROC_V_PARAL    (MR_PROC_V_PARAL),
    .MTX_DATA_WTH       (MTX_DATA_WTH),
    .MR_DATA_WTH        (MR_DATA_WTH),
    .VMR_PROC_WTH       (VMR_PROC_WTH),
    .VMR_DATA_WTH       (VMR_DATA_WTH),
    .MR_DSTROB_H_WTH    (MR_DSTROB_H_WTH),
    .MR_DSTROB_V_WTH    (MR_DSTROB_V_WTH)
) mtxrega_inst (
    // clock & reset
    .clk_i                                  (clk_i),
    .rst_i                                  (rst_i),

    // from mpu_ctrl module
    .mpu_mra__rindex_i                      (mpu_mra__rindex_i),
    .mpu_mra__raddr_i                       (mpu_mra__raddr_i),
    .mpu_mra__sl_i                          (mpu_mra__sl_i),
    .mpu_mra__sr_i                          (mpu_mra__sr_i),
    .mpu_mra__frcz_i                        (mpu_mra__frcz_i),
    .mpu_mra__re_i                          (mpu_mra__re_i),

    // to mpu module
    .mpu_mra__rdata_o                       (mpu_mra__rdata),
    .mpu_mra__rdata_act_o                   (mpu_mra__rdata_act),

    // from vpu_ctrl module
    .vpu_mra__windex_i                      (vpu_mra__windex_i),
    .vpu_mra__waddr_i                       (vpu_mra__waddr_i),
    .vpu_mra__we_i                          (vpu_mra__we_i),

    // from vpu module
    .vpu_mra__wdata_i                       (vpu_mra__wdata),
    .vpu_mra__wdata_strob_h_i               (vpu_mra__wdata_strob_h),
    .vpu_mra__wdata_strob_v_i               (vpu_mra__wdata_strob_v),
    .vpu_mra__wdata_act_i                   (vpu_mra__wdata_act),

    // from vputy_ctrl module
    .vputy_mra__rindex_i                    (vputy_mra__rindex_i),
    .vputy_mra__raddr_i                     (vputy_mra__raddr_i),
    .vputy_mra__sl_i                        (vputy_mra__sl_i),
    .vputy_mra__sr_i                        (vputy_mra__sr_i),
    .vputy_mra__frcz_i                      (vputy_mra__frcz_i),
    .vputy_mra__re_i                        (vputy_mra__re_i),
    .vputy_mra__windex_i                    (vputy_mra__windex_i),
    .vputy_mra__waddr_i                     (vputy_mra__waddr_i),
    .vputy_mra__we_i                        (vputy_mra__we_i),

    // to vputy module
    .vputy_mra__rdata_o                     (vputy_mra__rdata),
    .vputy_mra__rdata_act_o                 (vputy_mra__rdata_act),

    // from vputy module
    .vputy_mra__wdata_i                     (vputy_mra__wdata),
    .vputy_mra__wdata_strob_h_i             (vputy_mra__wdata_strob_h),
    .vputy_mra__wdata_strob_v_i             (vputy_mra__wdata_strob_v),
    .vputy_mra__wdata_act_i                 (vputy_mra__wdata_act),

    // from save_mtxreg_ctrl module
    .svmr_mra__rindex_i                     (svmr_mra__rindex_i),
    .svmr_mra__raddr_i                      (svmr_mra__raddr_i),
    .svmr_mra__re_i                         (svmr_mra__re_i),

    // to ddr_intf module
    .svmr_mra__rdata_o                      (svmr_mra__rdata),
    .svmr_mra__rdata_act_o                  (svmr_mra__rdata_act),

    // from load_mtxreg_ctrl module
    .ldmr_mra__windex_i                     (ldmr_mra__windex_i),
    .ldmr_mra__waddr_i                      (ldmr_mra__waddr_i),
    .ldmr_mra__we_i                         (ldmr_mra__we_i),

    // from ddr_intf module
    .ldmr_mra__wdata_i                      (ldmr_mra__wdata),
    .ldmr_mra__wdata_act_i                  (ldmr_mra__wdata_act)
);

mtxregb #(
    .MRB_IND_WTH        (MRB_IND_WTH),
    .MRB_ADDR_WTH       (MRB_ADDR_WTH),
    .MR_PROC_WTH        (MR_PROC_WTH),
    .MR_PROC_H_PARAL    (MR_PROC_H_PARAL),
    .MR_PROC_V_PARAL    (MR_PROC_V_PARAL),
    .MTX_DATA_WTH       (MTX_DATA_WTH),
    .MR_DATA_WTH        (MR_DATA_WTH),
    .VMR_PROC_WTH       (VMR_PROC_WTH),
    .VMR_DATA_WTH       (VMR_DATA_WTH),
    .MR_DSTROB_H_WTH    (MR_DSTROB_H_WTH),
    .MR_DSTROB_V_WTH    (MR_DSTROB_V_WTH)
) mtxregb_inst (
    // clock & reset
    .clk_i                                  (clk_i),
    .rst_i                                  (rst_i),

    // from mpu_ctrl module
    .mpu_mrb__rindex_i                      (mpu_mrb__rindex_i),
    .mpu_mrb__raddr_i                       (mpu_mrb__raddr_i),
    .mpu_mrb__re_i                          (mpu_mrb__re_i),
    .mpu_mrb__type_i                        (mpu_mrb__type_i),

    // to mpu module
    .mpu_mrb__rdata_o                       (mpu_mrb__rdata),
    .mpu_mrb__rdata_act_o                   (mpu_mrb__rdata_act),

    .mpu_mrb__vmode_rdata_o                 (mpu_mrb__vmode_rdata),
    .mpu_mrb__vmode_rdata_act_o             (mpu_mrb__vmode_rdata_act),

    // from load_mtxreg_ctrl module
    .ldmr_mrb__windex_i                     (ldmr_mrb__windex_i),
    .ldmr_mrb__waddr_i                      (ldmr_mrb__waddr_i),
    .ldmr_mrb__we_i                         (ldmr_mrb__we_i),

    // from ddr_intf module
    .ldmr_mrb__wdata_i                      (ldmr_mrb__wdata),
    .ldmr_mrb__wdata_act_i                  (ldmr_mrb__wdata_act)
);

mtxregc #(
    .MRC_IND_WTH        (MRC_IND_WTH),
    .MRC_ADDR_WTH       (MRC_ADDR_WTH),
    .MR_PROC_WTH        (MR_PROC_WTH),
    .MR_PROC_H_PARAL    (MR_PROC_H_PARAL),
    .MR_PROC_V_PARAL    (MR_PROC_V_PARAL),
    .MTX_DATA_WTH       (MTX_DATA_WTH),
    .MR_DATA_WTH        (MR_DATA_WTH)
) mtxregc_inst (
    // clock & reset
    .clk_i                                  (clk_i),
    .rst_i                                  (rst_i),

    // from vpu_tiny_ctrl module
    .vputy_mrc__rindex_i                    (vputy_mrc__rindex_i),
    .vputy_mrc__raddr_i                     (vputy_mrc__raddr_i),
    .vputy_mrc__re_i                        (vputy_mrc__re_i),

    // to vpu_tiny module
    .vputy_mrc__rdata_o                     (vputy_mrc__rdata),
    .vputy_mrc__rdata_act_o                 (vputy_mrc__rdata_act),

    // from load_mtxreg_ctrl module
    .ldmr_mrc__windex_i                     (ldmr_mrc__windex_i),
    .ldmr_mrc__waddr_i                      (ldmr_mrc__waddr_i),
    .ldmr_mrc__we_i                         (ldmr_mrc__we_i),

    // from ddr_intf module
    .ldmr_mrc__wdata_i                      (ldmr_mrc__wdata),
    .ldmr_mrc__wdata_act_i                  (ldmr_mrc__wdata_act)
);

biasregb #(
    .BR_IND_WTH         (BR_IND_WTH),
    .BR_ADDR_WTH        (BR_ADDR_WTH),
    .BR_PROC_WTH        (BR_PROC_WTH),
    .BR_DATA_WTH        (BR_DATA_WTH)
) biasregb_inst (
    // clock & reset
    .clk_i                                  (clk_i),
    .rst_i                                  (rst_i),

    // from vpu_ctrl module
    .vpu_brb__rindex_i                      (vpu_brb__rindex_i),
    .vpu_brb__raddr_i                       (vpu_brb__raddr_i),
    .vpu_brb__re_i                          (vpu_brb__re_i),

    // to vpu module
    .vpu_brb__rdata_o                       (vpu_brb__rdata),
    .vpu_brb__rdata_act_o                   (vpu_brb__rdata_act),

    // from load_mtxreg_ctrl module
    .ldmr_brb__windex_i                     (ldmr_brb__windex_i),
    .ldmr_brb__waddr_i                      (ldmr_brb__waddr_i),
    .ldmr_brb__we_i                         (ldmr_brb__we_i),

    // from ddr_intf module
    .ldmr_brb__wdata_i                      (ldmr_brb__wdata),
    .ldmr_brb__wdata_act_i                  (ldmr_brb__wdata_act)
);

biasregc #(
    .BR_IND_WTH         (BR_IND_WTH),
    .BR_ADDR_WTH        (BR_ADDR_WTH),
    .BR_PROC_WTH        (BR_PROC_WTH),
    .MR_PROC_H_PARAL    (MR_PROC_H_PARAL),
    .MR_PROC_V_PARAL    (MR_PROC_V_PARAL),
    .MTX_DATA_WTH       (MTX_DATA_WTH),
    .MR_DATA_WTH        (MR_DATA_WTH)
) biasregc_inst (
    // clock & reset
    .clk_i                                  (clk_i),
    .rst_i                                  (rst_i),

    // from vputy_ctrl module
    .vputy_brc__rindex_i                    (vputy_brc__rindex_i),
    .vputy_brc__raddr_i                     (vputy_brc__raddr_i),
    .vputy_brc__re_i                        (vputy_brc__re_i),

    // to vputy module
    .vputy_brc__rdata_o                     (vputy_brc__rdata),
    .vputy_brc__rdata_act_o                 (vputy_brc__rdata_act),

    // from load_mtxreg_ctrl module
    .ldmr_brc__windex_i                     (ldmr_brc__windex_i),
    .ldmr_brc__waddr_i                      (ldmr_brc__waddr_i),
    .ldmr_brc__we_i                         (ldmr_brc__we_i),

    // from ddr_intf module
    .ldmr_brc__wdata_i                      (ldmr_brc__wdata),
    .ldmr_brc__wdata_act_i                  (ldmr_brc__wdata_act)
);

mtxreg_hub #(
    .MR_PROC_WTH        (MR_PROC_WTH),
    .MR_PROC_H_PARAL    (MR_PROC_H_PARAL),
    .MR_PROC_V_PARAL    (MR_PROC_V_PARAL),
    .MTX_DATA_WTH       (MTX_DATA_WTH),
    .MR_DATA_WTH        (MR_DATA_WTH),
    .BR_DATA_WTH        (BR_DATA_WTH),
    .DDRIF_DATA_WTH     (DDRIF_DATA_WTH)
) mtxreg_hub_inst (
    // clock & reset
    .clk_i                                  (clk_i),
    .rst_i                                  (rst_i),

    // from load_mtxreg_ctrl module
    .ldmr_mrx__sel_i                        (ldmr_mrx__sel_i),

    // from mtxrega module
    .svmr_mra__rdata_i                      (svmr_mra__rdata),
    .svmr_mra__rdata_act_i                  (svmr_mra__rdata_act),

    // to mtxrega module
    .ldmr_mra__wdata_o                      (ldmr_mra__wdata),
    .ldmr_mra__wdata_act_o                  (ldmr_mra__wdata_act),

    // to mtxregb module
    .ldmr_mrb__wdata_o                      (ldmr_mrb__wdata),
    .ldmr_mrb__wdata_act_o                  (ldmr_mrb__wdata_act),

    // to mtxregc module
    .ldmr_mrc__wdata_o                      (ldmr_mrc__wdata),
    .ldmr_mrc__wdata_act_o                  (ldmr_mrc__wdata_act),

    // to biasregb module
    .ldmr_brb__wdata_o                      (ldmr_brb__wdata),
    .ldmr_brb__wdata_act_o                  (ldmr_brb__wdata_act),

    // to biasregc module
    .ldmr_brc__wdata_o                      (ldmr_brc__wdata),
    .ldmr_brc__wdata_act_o                  (ldmr_brc__wdata_act),

    // from ddr_intf module
    .ldmr_ddrintf__rdata_i                  (ldmr_ddrintf__rdata_i),
    .ldmr_ddrintf__rdata_act_i              (ldmr_ddrintf__rdata_act_i),

    // to ddr_intf module
    .svmr_ddrintf__wdata_o                  (svmr_ddrintf__wdata_o),
    .svmr_ddrintf__wdata_act_o              (svmr_ddrintf__wdata_act_o)
);

//======================================================================================================================
// just for simulation
//======================================================================================================================
// synthesis translate_off

// synthesis translate_on

//======================================================================================================================
// probe signals
//======================================================================================================================

endmodule   
