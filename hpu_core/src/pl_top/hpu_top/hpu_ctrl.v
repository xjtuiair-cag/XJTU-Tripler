// +FHDR------------------------------------------------------------------------
// XJTU IAIR Corporation All Rights Reserved
// -----------------------------------------------------------------------------
// FILE NAME  : hpu_ctrl.v
// DEPARTMENT : CAG of IAIR
// AUTHOR     : XXXX
// AUTHOR'S EMAIL :XXXX@mail.xjtu.edu.cn
// -----------------------------------------------------------------------------
// Ver 1.0  2019--01--01 initial version.
// -----------------------------------------------------------------------------
// KEYWORDS   : hpu control modules,
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

module hpu_ctrl #(
    parameter REGMAP_ADDR_WTH = 8,
    parameter REGMAP_DATA_WTH = 32,
    parameter MRX_IND_WTH = 5,
    parameter MRX_ADDR_WTH = 9,
    parameter MRA_IND_WTH = 3,
    parameter MRA_ADDR_WTH = 9,
    parameter MRB_IND_WTH = 3,
    parameter MRB_ADDR_WTH = 9,
    parameter MRC_IND_WTH = 1,
    parameter MRC_ADDR_WTH = 9,
    parameter BR_IND_WTH = 1,
    parameter BR_ADDR_WTH = 9,
    parameter VR_IND_WTH = 4,
    parameter VPR_IND_WTH = 3,
    parameter SR_DATA_WTH = 32
) (
    // clock & reset
    input                                   clk_i,
    input                                   rst_i,

    // from register_map module
    input [REGMAP_ADDR_WTH-1 : 0]           regmap_conv__waddr_i,
    input [REGMAP_DATA_WTH-1 : 0]           regmap_conv__wdata_i,
    input                                   regmap_conv__we_i,
    output                                  regmap_conv__intr_o,

    input [REGMAP_ADDR_WTH-1 : 0]           regmap_dwc__waddr_i,
    input [REGMAP_DATA_WTH-1 : 0]           regmap_dwc__wdata_i,
    input                                   regmap_dwc__we_i,
    output                                  regmap_dwc__intr_o,

    input [REGMAP_ADDR_WTH-1 : 0]           regmap_dtrans__waddr_i,
    input [REGMAP_DATA_WTH-1 : 0]           regmap_dtrans__wdata_i,
    input                                   regmap_dtrans__we_i,
    output                                  regmap_dtrans__intr_o,

    input [REGMAP_ADDR_WTH-1 : 0]           regmap_ftrans__waddr_i,
    input [REGMAP_DATA_WTH-1 : 0]           regmap_ftrans__wdata_i,
    input                                   regmap_ftrans__we_i,
    output                                  regmap_ftrans__intr_o,

    // to mpu module
    output                                  mpu_op_extacc_act_o,
    output                                  mpu_op_bypass_act_o,
    output[0 : 0]                           mpu_op_type_o,

    // to vpu module
    output                                  vpu_op_sum_act_o,
    output[4 : 0]                           vpu_op_clip_o,
    output                                  vpu_op_bias_act_o,
    output                                  vpu_op_relu_act_o,
    output                                  vpu_op_shfl_act_o,
    output                                  vpu_op_shfl_up_act_o,
    output[7 : 0]                           vpu_op_strobe_h_o,
    output[7 : 0]                           vpu_op_strobe_v_o,

    output                                  vputy_op_mul_sel_o,
    output                                  vputy_op_ldsl_sel_o,
    output                                  vputy_op_ldsr_sel_o,
    output                                  vputy_op_acc_sel_o,
    output                                  vputy_op_max_sel_o,
    output                                  vputy_sv_sel_act_o,
    output[2 : 0]                           vputy_sv_mtx_sel_h_o,
    output[4 : 0]                           vputy_sv_clip_o,
    output                                  vputy_sv_bias_act_o,
    output                                  vputy_sv_relu_act_o,
    output                                  vputy_sv_shfl_act_o,
    output                                  vputy_sv_chpri_act_o,
    output                                  vputy_sv_shfl_up_act_o,
    output[7 : 0]                           vputy_sv_strobe_h_o,
    output[7 : 0]                           vputy_sv_strobe_v_o,

    // to mtxrega module
    output[MRA_IND_WTH-1 : 0]               mpu0_mra__rindex_o,
    output[MRA_ADDR_WTH-1 : 0]              mpu0_mra__raddr_o,
    output                                  mpu0_mra__sl_o,
    output                                  mpu0_mra__sr_o,
    output                                  mpu0_mra__frcz_o,
    output[MRA_IND_WTH-1 : 0]               mpu1_mra__rindex_o,
    output[MRA_ADDR_WTH-1 : 0]              mpu1_mra__raddr_o,
    output                                  mpu1_mra__sl_o,
    output                                  mpu1_mra__sr_o,
    output                                  mpu1_mra__frcz_o,
    output                                  mpu_mra__re_o,
    input                                   mpu_mra__rdata_act_i,

    output[MRA_IND_WTH-1 : 0]               vpu_mra__windex_o,
    output[MRA_ADDR_WTH-1 : 0]              vpu_mra__waddr_o,
    output                                  vpu_mra__we_o,

    output[MRA_IND_WTH-1 : 0]               vputy0_mra__rindex_o,
    output[MRA_ADDR_WTH-1 : 0]              vputy0_mra__raddr_o,
    output                                  vputy0_mra__sl_o,
    output                                  vputy0_mra__sr_o,
    output                                  vputy0_mra__frcz_o,
    output[MRA_IND_WTH-1 : 0]               vputy1_mra__rindex_o,
    output[MRA_ADDR_WTH-1 : 0]              vputy1_mra__raddr_o,
    output                                  vputy1_mra__sl_o,
    output                                  vputy1_mra__sr_o,
    output                                  vputy1_mra__frcz_o,
    output                                  vputy_mra__re_o,
    input                                   vputy_mra__rdata_act_i,

    output[MRA_IND_WTH-1 : 0]               vputy_mra__windex_o,
    output[MRA_ADDR_WTH-1 : 0]              vputy_mra__waddr_o,
    output                                  vputy_mra__we_o,

    // to mtxregb module
    output[MRB_IND_WTH-1 : 0]               mpu_mrb__rindex_o,
    output[MRB_ADDR_WTH-1 : 0]              mpu_mrb__raddr_o,
    output                                  mpu_mrb__re_o,
    output[0 : 0]                           mpu_mrb__type_o,
    input                                   mpu_mrb__rdata_act_i,
    input                                   mpu_mrb__vmode_rdata_act_i,

    output[MRB_IND_WTH-1 : 0]               vpu_mrb__windex_o,
    output[MRB_ADDR_WTH-1 : 0]              vpu_mrb__waddr_o,
    output                                  vpu_mrb__we_o,

    // to mtxregc module
    output[MRC_IND_WTH-1 : 0]               vputy_mrc__rindex_o,
    output[MRC_ADDR_WTH-1 : 0]              vputy_mrc__raddr_o,
    output                                  vputy_mrc__re_o,
    input                                   vputy_mrc__rdata_act_i,

    // to vecreg module
    output[VR_IND_WTH-1 : 0]                mpu_vr__windex_o,
    output                                  mpu_vr__we_o,
    output[VR_IND_WTH-1 : 0]                mpu_vr__rindex_o,
    output                                  mpu_vr__re_o,

    output[VR_IND_WTH-1 : 0]                vpu_vr__rd_windex_o,
    output                                  vpu_vr__rd_we_o,
    output[VR_IND_WTH-1 : 0]                vpu_vr__rs0_rindex_o,
    output[VR_IND_WTH-1 : 0]                vpu_vr__rs1_rindex_o,
    output                                  vpu_vr__rs_re_o,
    output[VPR_IND_WTH-1 : 0]               vpu_vr__rpd_windex_o,
    output                                  vpu_vr__rpd_we_o,
    output[VPR_IND_WTH-1 : 0]               vpu_vr__rps0_rindex_o,
    output[VPR_IND_WTH-1 : 0]               vpu_vr__rps1_rindex_o,
    output                                  vpu_vr__rps_re_o,

    // to biasreg module
    output[BR_IND_WTH-1 : 0]                vpu_brb__rindex_o,
    output[BR_ADDR_WTH-1 : 0]               vpu_brb__raddr_o,
    output                                  vpu_brb__re_o,
    input                                   vpu_brb__rdata_act_i,

    output[BR_IND_WTH-1 : 0]                vputy_brc__rindex_o,
    output[BR_ADDR_WTH-1 : 0]               vputy_brc__raddr_o,
    output                                  vputy_brc__re_o,
    input                                   vputy_brc__rdata_act_i
);

//======================================================================================================================
// Wire & Reg declaration
//======================================================================================================================

// conv_ctrl to mpu_ctrl
wire  [1 : 0]                           convctl_mpu__code;
wire  [0 : 0]                           convctl_mpu__type;
wire                                    convctl_mpu0__mrs0_sl;
wire                                    convctl_mpu0__mrs0_sr;
wire  [MRX_IND_WTH-1 : 0]               convctl_mpu0__mrs0_index;
wire  [MRX_ADDR_WTH-1 : 0]              convctl_mpu0__mrs0_addr;
wire                                    convctl_mpu1__mrs0_sl;
wire                                    convctl_mpu1__mrs0_sr;
wire  [MRX_IND_WTH-1 : 0]               convctl_mpu1__mrs0_index;
wire  [MRX_ADDR_WTH-1 : 0]              convctl_mpu1__mrs0_addr;
wire  [MRX_IND_WTH-1 : 0]               convctl_mpu__mrs1_index;
wire  [MRX_ADDR_WTH-1 : 0]              convctl_mpu__mrs1_addr;
wire  [VR_IND_WTH-1 : 0]                convctl_mpu__vrd_index;
wire  [6 : 0]                           convctl_mpu__mac_len;

// to vpu_ctrl module
wire  [5 : 0]                           convctl_vpu__code;
wire  [MRX_IND_WTH-1 : 0]               convctl_vpu__br_index;
wire  [MRX_ADDR_WTH-1 : 0]              convctl_vpu__br_addr;
wire  [4 : 0]                           convctl_vpu__clip;
wire  [0 : 0]                           convctl_vpu__shfl;
wire  [MRX_IND_WTH-1 : 0]               convctl_vpu__sv_index;
wire  [MRX_ADDR_WTH-1 : 0]              convctl_vpu__sv_addr;
wire  [7 : 0]                           convctl_vpu__sv_strobe_h;

// to vputy_ctrl module
wire  [4 : 0]                           dwcctl_vputy__code;
wire                                    dwcctl_vputy0__mrs0_sl;
wire                                    dwcctl_vputy0__mrs0_sr;
wire  [MRX_IND_WTH-1 : 0]               dwcctl_vputy0__mrs0_index;
wire  [MRX_ADDR_WTH-1 : 0]              dwcctl_vputy0__mrs0_addr;
wire                                    dwcctl_vputy1__mrs0_sl;
wire                                    dwcctl_vputy1__mrs0_sr;
wire  [MRX_IND_WTH-1 : 0]               dwcctl_vputy1__mrs0_index;
wire  [MRX_ADDR_WTH-1 : 0]              dwcctl_vputy1__mrs0_addr;
wire  [MRX_IND_WTH-1 : 0]               dwcctl_vputy__mrs1_index;
wire  [MRX_ADDR_WTH-1 : 0]              dwcctl_vputy__mrs1_addr;
wire  [5 : 0]                           dwcctl_vputy__sv_code;
wire  [MRX_IND_WTH-1 : 0]               dwcctl_vputy__br_index;
wire  [MRX_ADDR_WTH-1 : 0]              dwcctl_vputy__br_addr;
wire  [4 : 0]                           dwcctl_vputy__clip;
wire  [0 : 0]                           dwcctl_vputy__shfl;
wire  [MRX_IND_WTH-1 : 0]               dwcctl_vputy__mrd_index;
wire  [MRX_ADDR_WTH-1 : 0]              dwcctl_vputy__mrd_addr;
wire  [7 : 0]                           dwcctl_vputy__strobe_h;

// to vputy_ctrl module
wire  [4 : 0]                           dtransctl_vputy__code;
wire  [MRX_IND_WTH-1 : 0]               dtransctl_vputy__mrs0_index;
wire  [MRX_ADDR_WTH-1 : 0]              dtransctl_vputy__mrs0_addr;
wire  [5 : 0]                           dtransctl_vputy__sv_code;
wire  [0 : 0]                           dtransctl_vputy__shfl;
wire  [MRX_IND_WTH-1 : 0]               dtransctl_vputy__mrd_index;
wire  [MRX_ADDR_WTH-1 : 0]              dtransctl_vputy__mrd_addr;
wire  [7 : 0]                           dtransctl_vputy__strobe_h;

wire  [4 : 0]                           ftransctl_vputy__code;
wire  [MRX_IND_WTH-1 : 0]               ftransctl_vputy__mrs0_index;
wire  [MRX_ADDR_WTH-1 : 0]              ftransctl_vputy__mrs0_addr;
wire  [5 : 0]                           ftransctl_vputy__sv_code;
wire  [2 : 0]                           ftransctl_vputy__mtx_sel_h;
wire  [MRX_IND_WTH-1 : 0]               ftransctl_vputy__mrd_index;
wire  [MRX_ADDR_WTH-1 : 0]              ftransctl_vputy__mrd_addr;
wire  [7 : 0]                           ftransctl_vputy__strobe_h;

//======================================================================================================================
// Instance
//======================================================================================================================

conv_ctrl #(
    .REGMAP_ADDR_WTH    (REGMAP_ADDR_WTH),
    .REGMAP_DATA_WTH    (REGMAP_DATA_WTH),
    .MRX_IND_WTH        (MRX_IND_WTH),
    .MRX_ADDR_WTH       (MRX_ADDR_WTH),
    .VR_IND_WTH         (VR_IND_WTH),
    .VPR_IND_WTH        (VPR_IND_WTH),
    .SR_DATA_WTH        (SR_DATA_WTH)
) conv_ctrl_inst (
    // clock & reset
    .clk_i                                  (clk_i),
    .rst_i                                  (rst_i),

    // from register_map module
    .regmap_conv__waddr_i                   (regmap_conv__waddr_i),
    .regmap_conv__wdata_i                   (regmap_conv__wdata_i),
    .regmap_conv__we_i                      (regmap_conv__we_i),
    .regmap_conv__intr_o                    (regmap_conv__intr_o),

    // to mpu_ctrl module
    .convctl_mpu__code_o                    (convctl_mpu__code),
    .convctl_mpu__type_o                    (convctl_mpu__type),
    .convctl_mpu0__mrs0_sl_o                (convctl_mpu0__mrs0_sl),
    .convctl_mpu0__mrs0_sr_o                (convctl_mpu0__mrs0_sr),
    .convctl_mpu0__mrs0_index_o             (convctl_mpu0__mrs0_index),
    .convctl_mpu0__mrs0_addr_o              (convctl_mpu0__mrs0_addr),
    .convctl_mpu1__mrs0_sl_o                (convctl_mpu1__mrs0_sl),
    .convctl_mpu1__mrs0_sr_o                (convctl_mpu1__mrs0_sr),
    .convctl_mpu1__mrs0_index_o             (convctl_mpu1__mrs0_index),
    .convctl_mpu1__mrs0_addr_o              (convctl_mpu1__mrs0_addr),
    .convctl_mpu__mrs1_index_o              (convctl_mpu__mrs1_index),
    .convctl_mpu__mrs1_addr_o               (convctl_mpu__mrs1_addr),
    .convctl_mpu__vrd_index_o               (convctl_mpu__vrd_index),
    .convctl_mpu__mac_len_o                 (convctl_mpu__mac_len),

    // to vpu_ctrl module
    .convctl_vpu__code_o                    (convctl_vpu__code),
    .convctl_vpu__br_index_o                (convctl_vpu__br_index),
    .convctl_vpu__br_addr_o                 (convctl_vpu__br_addr),
    .convctl_vpu__clip_o                    (convctl_vpu__clip),
    .convctl_vpu__shfl_o                    (convctl_vpu__shfl),
    .convctl_vpu__sv_index_o                (convctl_vpu__sv_index),
    .convctl_vpu__sv_addr_o                 (convctl_vpu__sv_addr),
    .convctl_vpu__sv_strobe_h_o             (convctl_vpu__sv_strobe_h)
);

dwc_ctrl #(
    .REGMAP_ADDR_WTH    (REGMAP_ADDR_WTH),
    .REGMAP_DATA_WTH    (REGMAP_DATA_WTH),
    .MRX_IND_WTH        (MRX_IND_WTH),
    .MRX_ADDR_WTH       (MRX_ADDR_WTH)
) dwc_ctrl_inst (
    // clock & reset
    .clk_i                                  (clk_i),
    .rst_i                                  (rst_i),

    // from register_map module
    .regmap_dwc__waddr_i                    (regmap_dwc__waddr_i),
    .regmap_dwc__wdata_i                    (regmap_dwc__wdata_i),
    .regmap_dwc__we_i                       (regmap_dwc__we_i),
    .regmap_dwc__intr_o                     (regmap_dwc__intr_o),

    // to vputy_ctrl module
    .dwcctl_vputy__code_o                   (dwcctl_vputy__code),
    .dwcctl_vputy0__mrs0_sl_o               (dwcctl_vputy0__mrs0_sl),
    .dwcctl_vputy0__mrs0_sr_o               (dwcctl_vputy0__mrs0_sr),
    .dwcctl_vputy0__mrs0_index_o            (dwcctl_vputy0__mrs0_index),
    .dwcctl_vputy0__mrs0_addr_o             (dwcctl_vputy0__mrs0_addr),
    .dwcctl_vputy1__mrs0_sl_o               (dwcctl_vputy1__mrs0_sl),
    .dwcctl_vputy1__mrs0_sr_o               (dwcctl_vputy1__mrs0_sr),
    .dwcctl_vputy1__mrs0_index_o            (dwcctl_vputy1__mrs0_index),
    .dwcctl_vputy1__mrs0_addr_o             (dwcctl_vputy1__mrs0_addr),
    .dwcctl_vputy__mrs1_index_o             (dwcctl_vputy__mrs1_index),
    .dwcctl_vputy__mrs1_addr_o              (dwcctl_vputy__mrs1_addr),
    .dwcctl_vputy__sv_code_o                (dwcctl_vputy__sv_code),
    .dwcctl_vputy__br_index_o               (dwcctl_vputy__br_index),
    .dwcctl_vputy__br_addr_o                (dwcctl_vputy__br_addr),
    .dwcctl_vputy__clip_o                   (dwcctl_vputy__clip),
    .dwcctl_vputy__shfl_o                   (dwcctl_vputy__shfl),
    .dwcctl_vputy__mrd_index_o              (dwcctl_vputy__mrd_index),
    .dwcctl_vputy__mrd_addr_o               (dwcctl_vputy__mrd_addr),
    .dwcctl_vputy__strobe_h_o               (dwcctl_vputy__strobe_h)
);

datatrans_ctrl #(
    .REGMAP_ADDR_WTH    (REGMAP_ADDR_WTH),
    .REGMAP_DATA_WTH    (REGMAP_DATA_WTH),
    .MRX_IND_WTH        (MRX_IND_WTH),
    .MRX_ADDR_WTH       (MRX_ADDR_WTH)
) datatrans_ctrl_inst (
    // clock & reset
    .clk_i                                  (clk_i),
    .rst_i                                  (rst_i),

    // from register_map module
    .regmap_dtrans__waddr_i                 (regmap_dtrans__waddr_i),
    .regmap_dtrans__wdata_i                 (regmap_dtrans__wdata_i),
    .regmap_dtrans__we_i                    (regmap_dtrans__we_i),
    .regmap_dtrans__intr_o                  (regmap_dtrans__intr_o),

    // to vputy_ctrl module
    .dtransctl_vputy__code_o                (dtransctl_vputy__code),
    .dtransctl_vputy__mrs0_index_o          (dtransctl_vputy__mrs0_index),
    .dtransctl_vputy__mrs0_addr_o           (dtransctl_vputy__mrs0_addr),
    .dtransctl_vputy__sv_code_o             (dtransctl_vputy__sv_code),
    .dtransctl_vputy__shfl_o                (dtransctl_vputy__shfl),
    .dtransctl_vputy__mrd_index_o           (dtransctl_vputy__mrd_index),
    .dtransctl_vputy__mrd_addr_o            (dtransctl_vputy__mrd_addr),
    .dtransctl_vputy__strobe_h_o            (dtransctl_vputy__strobe_h)
);

fmttrans_ctrl #(
    .REGMAP_ADDR_WTH    (REGMAP_ADDR_WTH),
    .REGMAP_DATA_WTH    (REGMAP_DATA_WTH),
    .MRX_IND_WTH        (MRX_IND_WTH),
    .MRX_ADDR_WTH       (MRX_ADDR_WTH)
) fmttrans_ctrl_inst (
    // clock & reset
    .clk_i                                  (clk_i),
    .rst_i                                  (rst_i),

    // from register_map module
    .regmap_ftrans__waddr_i                 (regmap_ftrans__waddr_i),
    .regmap_ftrans__wdata_i                 (regmap_ftrans__wdata_i),
    .regmap_ftrans__we_i                    (regmap_ftrans__we_i),
    .regmap_ftrans__intr_o                  (regmap_ftrans__intr_o),

    // to vputy_ctrl module
    .ftransctl_vputy__code_o                (ftransctl_vputy__code),
    .ftransctl_vputy__mrs0_index_o          (ftransctl_vputy__mrs0_index),
    .ftransctl_vputy__mrs0_addr_o           (ftransctl_vputy__mrs0_addr),
    .ftransctl_vputy__sv_code_o             (ftransctl_vputy__sv_code),
    .ftransctl_vputy__mtx_sel_h_o           (ftransctl_vputy__mtx_sel_h),
    .ftransctl_vputy__mrd_index_o           (ftransctl_vputy__mrd_index),
    .ftransctl_vputy__mrd_addr_o            (ftransctl_vputy__mrd_addr),
    .ftransctl_vputy__strobe_h_o            (ftransctl_vputy__strobe_h)
);

mpu_ctrl #(
    .MRA_IND_WTH        (MRA_IND_WTH),
    .MRA_ADDR_WTH       (MRA_ADDR_WTH),
    .MRB_IND_WTH        (MRB_IND_WTH), 
    .MRB_ADDR_WTH       (MRB_ADDR_WTH),
    .VR_IND_WTH         (VR_IND_WTH),
    .MRX_IND_WTH        (MRX_IND_WTH),
    .MRX_ADDR_WTH       (MRX_ADDR_WTH)
) mpu_ctrl_inst (
    // clock & reset
    .clk_i                                  (clk_i),
    .rst_i                                  (rst_i),

    // from conv_ctrl module
    .convctl_mpu__code_i                    (convctl_mpu__code),
    .convctl_mpu__type_i                    (convctl_mpu__type),
    .convctl_mpu0__mrs0_sl_i                (convctl_mpu0__mrs0_sl),
    .convctl_mpu0__mrs0_sr_i                (convctl_mpu0__mrs0_sr),
    .convctl_mpu0__mrs0_index_i             (convctl_mpu0__mrs0_index),
    .convctl_mpu0__mrs0_addr_i              (convctl_mpu0__mrs0_addr),
    .convctl_mpu1__mrs0_sl_i                (convctl_mpu1__mrs0_sl),
    .convctl_mpu1__mrs0_sr_i                (convctl_mpu1__mrs0_sr),
    .convctl_mpu1__mrs0_index_i             (convctl_mpu1__mrs0_index),
    .convctl_mpu1__mrs0_addr_i              (convctl_mpu1__mrs0_addr),
    .convctl_mpu__mrs1_index_i              (convctl_mpu__mrs1_index),
    .convctl_mpu__mrs1_addr_i               (convctl_mpu__mrs1_addr),
    .convctl_mpu__vrd_index_i               (convctl_mpu__vrd_index),
    .convctl_mpu__mac_len_i                 (convctl_mpu__mac_len),

    // to mpu module
    .mpu_op_extacc_act_o                    (mpu_op_extacc_act_o),
    .mpu_op_bypass_act_o                    (mpu_op_bypass_act_o),
    .mpu_op_type_o                          (mpu_op_type_o),

    // to mtxrega module
    .mpu0_mra__rindex_o                     (mpu0_mra__rindex_o),
    .mpu0_mra__raddr_o                      (mpu0_mra__raddr_o),
    .mpu0_mra__sl_o                         (mpu0_mra__sl_o),
    .mpu0_mra__sr_o                         (mpu0_mra__sr_o),
    .mpu0_mra__frcz_o                       (mpu0_mra__frcz_o),
    .mpu1_mra__rindex_o                     (mpu1_mra__rindex_o),
    .mpu1_mra__raddr_o                      (mpu1_mra__raddr_o),
    .mpu1_mra__sl_o                         (mpu1_mra__sl_o),
    .mpu1_mra__sr_o                         (mpu1_mra__sr_o),
    .mpu1_mra__frcz_o                       (mpu1_mra__frcz_o),
    .mpu_mra__re_o                          (mpu_mra__re_o),
    .mpu_mra__rdata_act_i                   (mpu_mra__rdata_act_i),

    // to mtxregb module
    .mpu_mrb__rindex_o                      (mpu_mrb__rindex_o),
    .mpu_mrb__raddr_o                       (mpu_mrb__raddr_o),
    .mpu_mrb__re_o                          (mpu_mrb__re_o),
    .mpu_mrb__type_o                        (mpu_mrb__type_o),
    .mpu_mrb__rdata_act_i                   (mpu_mrb__rdata_act_i),
    .mpu_mrb__vmode_rdata_act_i             (mpu_mrb__vmode_rdata_act_i),

    // to vecreg module
    .mpu_vr__windex_o                       (mpu_vr__windex_o),
    .mpu_vr__we_o                           (mpu_vr__we_o),
    .mpu_vr__rindex_o                       (mpu_vr__rindex_o),
    .mpu_vr__re_o                           (mpu_vr__re_o)
);

vpu_ctrl #(
    .MRX_IND_WTH        (MRX_IND_WTH),
    .MRX_ADDR_WTH       (MRX_ADDR_WTH),
    .MRA_IND_WTH        (MRA_IND_WTH),
    .MRA_ADDR_WTH       (MRA_ADDR_WTH),
    .MRB_IND_WTH        (MRB_IND_WTH),
    .MRB_ADDR_WTH       (MRB_ADDR_WTH),
    .BR_IND_WTH         (BR_IND_WTH),
    .BR_ADDR_WTH        (BR_ADDR_WTH),
    .VR_IND_WTH         (VR_IND_WTH),
    .VPR_IND_WTH        (VPR_IND_WTH),
    .SR_DATA_WTH        (SR_DATA_WTH)
) vpu_ctrl_inst (
    // clock & reset
    .clk_i                                  (clk_i),
    .rst_i                                  (rst_i),

    // from conv_ctrl module
    .convctl_vpu__code_i                    (convctl_vpu__code),
    .convctl_vpu__br_index_i                (convctl_vpu__br_index),
    .convctl_vpu__br_addr_i                 (convctl_vpu__br_addr),
    .convctl_vpu__clip_i                    (convctl_vpu__clip),
    .convctl_vpu__shfl_i                    (convctl_vpu__shfl),
    .convctl_vpu__sv_index_i                (convctl_vpu__sv_index),
    .convctl_vpu__sv_addr_i                 (convctl_vpu__sv_addr),
    .convctl_vpu__sv_strobe_h_i             (convctl_vpu__sv_strobe_h),

    // to vecreg module
    .vpu_vr__rd_windex_o                    (vpu_vr__rd_windex_o),
    .vpu_vr__rd_we_o                        (vpu_vr__rd_we_o),
    .vpu_vr__rs0_rindex_o                   (vpu_vr__rs0_rindex_o),
    .vpu_vr__rs1_rindex_o                   (vpu_vr__rs1_rindex_o),
    .vpu_vr__rs_re_o                        (vpu_vr__rs_re_o),
    .vpu_vr__rpd_windex_o                   (vpu_vr__rpd_windex_o),
    .vpu_vr__rpd_we_o                       (vpu_vr__rpd_we_o),
    .vpu_vr__rps0_rindex_o                  (vpu_vr__rps0_rindex_o),
    .vpu_vr__rps1_rindex_o                  (vpu_vr__rps1_rindex_o),
    .vpu_vr__rps_re_o                       (vpu_vr__rps_re_o),

    // to vpu module
    .vpu_op_sum_act_o                       (vpu_op_sum_act_o),
    .vpu_op_clip_o                          (vpu_op_clip_o),
    .vpu_op_bias_act_o                      (vpu_op_bias_act_o),
    .vpu_op_relu_act_o                      (vpu_op_relu_act_o),
    .vpu_op_shfl_act_o                      (vpu_op_shfl_act_o),
    .vpu_op_shfl_up_act_o                   (vpu_op_shfl_up_act_o),
    .vpu_op_strobe_h_o                      (vpu_op_strobe_h_o),
    .vpu_op_strobe_v_o                      (vpu_op_strobe_v_o),

    // to biasreg module
    .vpu_brb__rindex_o                      (vpu_brb__rindex_o),
    .vpu_brb__raddr_o                       (vpu_brb__raddr_o),
    .vpu_brb__re_o                          (vpu_brb__re_o),
    .vpu_brb__rdata_act_i                   (vpu_brb__rdata_act_i),

    // to mtxrega module
    .vpu_mra__windex_o                      (vpu_mra__windex_o),
    .vpu_mra__waddr_o                       (vpu_mra__waddr_o),
    .vpu_mra__we_o                          (vpu_mra__we_o)
);

vputy_ctrl #(
    .MRX_IND_WTH        (MRX_IND_WTH),
    .MRX_ADDR_WTH       (MRX_ADDR_WTH),
    .MRA_IND_WTH        (MRA_IND_WTH),
    .MRA_ADDR_WTH       (MRA_ADDR_WTH),
    .MRC_IND_WTH        (MRC_IND_WTH),
    .MRC_ADDR_WTH       (MRC_ADDR_WTH),
    .BR_IND_WTH         (BR_IND_WTH),
    .BR_ADDR_WTH        (BR_ADDR_WTH)
) vputy_ctrl_inst (
    // clock & reset
    .clk_i                                  (clk_i),
    .rst_i                                  (rst_i),

    // from dwc_ctrl module
    .dwcctl_vputy__code_i                   (dwcctl_vputy__code),
    .dwcctl_vputy0__mrs0_sl_i               (dwcctl_vputy0__mrs0_sl),
    .dwcctl_vputy0__mrs0_sr_i               (dwcctl_vputy0__mrs0_sr),
    .dwcctl_vputy0__mrs0_index_i            (dwcctl_vputy0__mrs0_index),
    .dwcctl_vputy0__mrs0_addr_i             (dwcctl_vputy0__mrs0_addr),
    .dwcctl_vputy1__mrs0_sl_i               (dwcctl_vputy1__mrs0_sl),
    .dwcctl_vputy1__mrs0_sr_i               (dwcctl_vputy1__mrs0_sr),
    .dwcctl_vputy1__mrs0_index_i            (dwcctl_vputy1__mrs0_index),
    .dwcctl_vputy1__mrs0_addr_i             (dwcctl_vputy1__mrs0_addr),
    .dwcctl_vputy__mrs1_index_i             (dwcctl_vputy__mrs1_index),
    .dwcctl_vputy__mrs1_addr_i              (dwcctl_vputy__mrs1_addr),
    .dwcctl_vputy__sv_code_i                (dwcctl_vputy__sv_code),
    .dwcctl_vputy__br_index_i               (dwcctl_vputy__br_index),
    .dwcctl_vputy__br_addr_i                (dwcctl_vputy__br_addr),
    .dwcctl_vputy__clip_i                   (dwcctl_vputy__clip),
    .dwcctl_vputy__shfl_i                   (dwcctl_vputy__shfl),
    .dwcctl_vputy__mrd_index_i              (dwcctl_vputy__mrd_index),
    .dwcctl_vputy__mrd_addr_i               (dwcctl_vputy__mrd_addr),
    .dwcctl_vputy__strobe_h_i               (dwcctl_vputy__strobe_h),

    // from datatrans_ctrl module
    .dtransctl_vputy__code_i                (dtransctl_vputy__code),
    .dtransctl_vputy__mrs0_index_i          (dtransctl_vputy__mrs0_index),
    .dtransctl_vputy__mrs0_addr_i           (dtransctl_vputy__mrs0_addr),
    .dtransctl_vputy__sv_code_i             (dtransctl_vputy__sv_code),
    .dtransctl_vputy__shfl_i                (dtransctl_vputy__shfl),
    .dtransctl_vputy__mrd_index_i           (dtransctl_vputy__mrd_index),
    .dtransctl_vputy__mrd_addr_i            (dtransctl_vputy__mrd_addr),
    .dtransctl_vputy__strobe_h_i            (dtransctl_vputy__strobe_h),

    // from fmttrans_ctrl module
    .ftransctl_vputy__code_i                (ftransctl_vputy__code),
    .ftransctl_vputy__mrs0_index_i          (ftransctl_vputy__mrs0_index),
    .ftransctl_vputy__mrs0_addr_i           (ftransctl_vputy__mrs0_addr),
    .ftransctl_vputy__sv_code_i             (ftransctl_vputy__sv_code),
    .ftransctl_vputy__mtx_sel_h_i           (ftransctl_vputy__mtx_sel_h),
    .ftransctl_vputy__mrd_index_i           (ftransctl_vputy__mrd_index),
    .ftransctl_vputy__mrd_addr_i            (ftransctl_vputy__mrd_addr),
    .ftransctl_vputy__strobe_h_i            (ftransctl_vputy__strobe_h),

    // to vputy module
    .vputy_op_mul_sel_o                     (vputy_op_mul_sel_o),
    .vputy_op_ldsl_sel_o                    (vputy_op_ldsl_sel_o),
    .vputy_op_ldsr_sel_o                    (vputy_op_ldsr_sel_o),
    .vputy_op_acc_sel_o                     (vputy_op_acc_sel_o),
    .vputy_op_max_sel_o                     (vputy_op_max_sel_o),
    .vputy_sv_sel_act_o                     (vputy_sv_sel_act_o),
    .vputy_sv_mtx_sel_h_o                   (vputy_sv_mtx_sel_h_o),
    .vputy_sv_clip_o                        (vputy_sv_clip_o),
    .vputy_sv_bias_act_o                    (vputy_sv_bias_act_o),
    .vputy_sv_relu_act_o                    (vputy_sv_relu_act_o),
    .vputy_sv_shfl_act_o                    (vputy_sv_shfl_act_o),
    .vputy_sv_chpri_act_o                   (vputy_sv_chpri_act_o),
    .vputy_sv_shfl_up_act_o                 (vputy_sv_shfl_up_act_o),
    .vputy_sv_strobe_h_o                    (vputy_sv_strobe_h_o),
    .vputy_sv_strobe_v_o                    (vputy_sv_strobe_v_o),

    // to mtxrega module
    .vputy0_mra__rindex_o                   (vputy0_mra__rindex_o),
    .vputy0_mra__raddr_o                    (vputy0_mra__raddr_o),
    .vputy0_mra__sl_o                       (vputy0_mra__sl_o),
    .vputy0_mra__sr_o                       (vputy0_mra__sr_o),
    .vputy0_mra__frcz_o                     (vputy0_mra__frcz_o),
    .vputy1_mra__rindex_o                   (vputy1_mra__rindex_o),
    .vputy1_mra__raddr_o                    (vputy1_mra__raddr_o),
    .vputy1_mra__sl_o                       (vputy1_mra__sl_o),
    .vputy1_mra__sr_o                       (vputy1_mra__sr_o),
    .vputy1_mra__frcz_o                     (vputy1_mra__frcz_o),
    .vputy_mra__re_o                        (vputy_mra__re_o),
    .vputy_mra__rdata_act_i                 (vputy_mra__rdata_act_i),

    .vputy_mra__windex_o                    (vputy_mra__windex_o),
    .vputy_mra__waddr_o                     (vputy_mra__waddr_o),
    .vputy_mra__we_o                        (vputy_mra__we_o),

    // to mtxregc module
    .vputy_mrc__rindex_o                    (vputy_mrc__rindex_o),
    .vputy_mrc__raddr_o                     (vputy_mrc__raddr_o),
    .vputy_mrc__re_o                        (vputy_mrc__re_o),
    .vputy_mrc__rdata_act_i                 (vputy_mrc__rdata_act_i),

    // to biasreg module
    .vputy_brc__rindex_o                    (vputy_brc__rindex_o),
    .vputy_brc__raddr_o                     (vputy_brc__raddr_o),
    .vputy_brc__re_o                        (vputy_brc__re_o),
    .vputy_brc__rdata_act_i                 (vputy_brc__rdata_act_i)
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

