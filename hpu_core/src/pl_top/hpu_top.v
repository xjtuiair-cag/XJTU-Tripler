// +FHDR------------------------------------------------------------------------
// XJTU IAIR Corporation All Rights Reserved
// -----------------------------------------------------------------------------
// FILE NAME  : hpu_top.v
// DEPARTMENT : CAG of IAIR
// AUTHOR     : XXXX
// AUTHOR'S EMAIL :XXXX@mail.xjtu.edu.cn
// -----------------------------------------------------------------------------
// Ver 1.0  2019--01--01 initial version.
// -----------------------------------------------------------------------------
// KEYWORDS   : top of hpu,
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

module hpu_top#(
    parameter PSIF_DATA_WTH = 64,
    parameter DDRIF_ADDR_WTH = 26,
    parameter DDRIF_ALEN_WTH = 16,
    parameter DDRIF_DATA_WTH = 512,
    parameter DDRIF_DSTROB_WTH = DDRIF_DATA_WTH/8,
    parameter DPU_REG_ADDR_WTH = 13,
    parameter DPU_REG_DATA_WTH = 32,
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
    parameter SR_DATA_WTH = 32,
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
    parameter VR_DATA_WTH = VR_PROC_PARAL * VR_PROC_WTH,
    parameter VPR_DATA_WTH = VR_PROC_PARAL
) (
    // clock & reset
    input                                   clk_i,
    input                                   clk_2x_i,
    input                                   rst_i,

    // from riscv_top to regmap
    input [DPU_REG_ADDR_WTH-1 : 0]          riscv_regmap__waddr_i,
    input                                   riscv_regmap__we_i,
    input [DPU_REG_DATA_WTH-1 : 0]          riscv_regmap__wdata_i,
    input [DPU_REG_ADDR_WTH-1 : 0]          riscv_regmap__raddr_i,
    input                                   riscv_regmap__re_i,

    output[DPU_REG_DATA_WTH-1 : 0]          riscv_regmap__rdata_o,
    output                                  riscv_regmap__rdata_act_o,
    output[7 : 0]                           riscv_regmap__intr_o,

    // zbr addr 20190409
    output                                 fshflg_ps_o,

     
  output     [28:0]  axi_ddr_araddr               , // [48:0] -> [28:0]
  input              axi_ddr_arready              ,
  output             axi_ddr_arvalid              ,
  output     [28:0]  axi_ddr_awaddr               , // [48:0] -> [28:0]
  input              axi_ddr_awready              ,
  output             axi_ddr_awvalid              , 
  input    [127:0]   axi_ddr_rdata                ,
  input    [5:0]     axi_ddr_rid                  ,
  input              axi_ddr_rlast                ,
  output             axi_ddr_rready               ,
  input              axi_ddr_rvalid               ,
  output     [127:0] axi_ddr_wdata                ,   
  output             axi_ddr_wlast                ,
  input              axi_ddr_wready               ,
  output             axi_ddr_wvalid                 
    
);

//======================================================================================================================
// Wire & Reg declaration
//======================================================================================================================




// to hpu_ctrl module
wire  [REGMAP_ADDR_WTH-1 : 0]           regmap_conv__waddr;
wire  [REGMAP_DATA_WTH-1 : 0]           regmap_conv__wdata;
wire                                    regmap_conv__we;
wire                                    regmap_conv__intr;

wire  [REGMAP_ADDR_WTH-1 : 0]           regmap_dwc__waddr;
wire  [REGMAP_DATA_WTH-1 : 0]           regmap_dwc__wdata;
wire                                    regmap_dwc__we;
wire                                    regmap_dwc__intr;

wire  [REGMAP_ADDR_WTH-1 : 0]           regmap_dtrans__waddr;
wire  [REGMAP_DATA_WTH-1 : 0]           regmap_dtrans__wdata;
wire                                    regmap_dtrans__we;
wire                                    regmap_dtrans__intr;

wire  [REGMAP_ADDR_WTH-1 : 0]           regmap_ftrans__waddr;
wire  [REGMAP_DATA_WTH-1 : 0]           regmap_ftrans__wdata;
wire                                    regmap_ftrans__we;
wire                                    regmap_ftrans__intr;

// to load_mtxreg_ctrl module
wire  [REGMAP_ADDR_WTH-1 : 0]           regmap_ldmr__waddr;
wire  [REGMAP_DATA_WTH-1 : 0]           regmap_ldmr__wdata;
wire                                    regmap_ldmr__we;
wire                                    regmap_ldmr__intr;

// to save_mtxreg_ctrl module
wire  [REGMAP_ADDR_WTH-1 : 0]           regmap_svmr__waddr;
wire  [REGMAP_DATA_WTH-1 : 0]           regmap_svmr__wdata;
wire                                    regmap_svmr__we;
wire                                    regmap_svmr__intr;

// to initial the download data module
wire  [REGMAP_ADDR_WTH-1 : 0]           regmap_dldata__waddr;
wire  [REGMAP_DATA_WTH-1 : 0]           regmap_dldata__wdata;
wire                                    regmap_dldata__we;

// to initial the upload data module
wire  [REGMAP_ADDR_WTH-1 : 0]           regmap_upldata__waddr;
wire  [REGMAP_DATA_WTH-1 : 0]           regmap_upldata__wdata;
wire                                    regmap_upldata__we;

// to mpu module
wire                                    mpu_op_extacc_act;
wire                                    mpu_op_bypass_act;
wire  [0 : 0]                           mpu_op_type;

// to vpu module
wire                                    vpu_op_sum_act;
wire  [4 : 0]                           vpu_op_clip;
wire                                    vpu_op_bias_act;
wire                                    vpu_op_relu_act;
wire                                    vpu_op_shfl_act;
wire                                    vpu_op_shfl_up_act;
wire  [7 : 0]                           vpu_op_strobe_h;
wire  [7 : 0]                           vpu_op_strobe_v;

wire                                    vputy_op_mul_sel;
wire                                    vputy_op_ldsl_sel;
wire                                    vputy_op_ldsr_sel;
wire                                    vputy_op_acc_sel;
wire                                    vputy_op_max_sel;
wire                                    vputy_sv_sel_act;
wire  [2 : 0]                           vputy_sv_mtx_sel_h;
wire  [4 : 0]                           vputy_sv_clip;
wire                                    vputy_sv_bias_act;
wire                                    vputy_sv_relu_act;
wire                                    vputy_sv_shfl_act;
wire                                    vputy_sv_chpri_act;
wire                                    vputy_sv_shfl_up_act;
wire  [7 : 0]                           vputy_sv_strobe_h;
wire  [7 : 0]                           vputy_sv_strobe_v;

// to mtxrega module
wire  [MRA_IND_WTH-1 : 0]               mpu0_mra__rindex;
wire  [MRA_ADDR_WTH-1 : 0]              mpu0_mra__raddr;
wire                                    mpu0_mra__sl;
wire                                    mpu0_mra__sr;
wire                                    mpu0_mra__frcz;
wire  [MRA_IND_WTH-1 : 0]               mpu1_mra__rindex;
wire  [MRA_ADDR_WTH-1 : 0]              mpu1_mra__raddr;
wire                                    mpu1_mra__sl;
wire                                    mpu1_mra__sr;
wire                                    mpu1_mra__frcz;
wire                                    mpu_mra__re;
wire                                    mpu_mra__rdata_act;

wire  [MRA_IND_WTH-1 : 0]               vpu_mra__windex;
wire  [MRA_ADDR_WTH-1 : 0]              vpu_mra__waddr;
wire                                    vpu_mra__we;

wire  [MRA_IND_WTH-1 : 0]               vputy0_mra__rindex;
wire  [MRA_ADDR_WTH-1 : 0]              vputy0_mra__raddr;
wire                                    vputy0_mra__sl;
wire                                    vputy0_mra__sr;
wire                                    vputy0_mra__frcz;
wire  [MRA_IND_WTH-1 : 0]               vputy1_mra__rindex;
wire  [MRA_ADDR_WTH-1 : 0]              vputy1_mra__raddr;
wire                                    vputy1_mra__sl;
wire                                    vputy1_mra__sr;
wire                                    vputy1_mra__frcz;
wire                                    vputy_mra__re;
wire                                    vputy_mra__rdata_act;

wire  [MRA_IND_WTH-1 : 0]               vputy_mra__windex;
wire  [MRA_ADDR_WTH-1 : 0]              vputy_mra__waddr;
wire                                    vputy_mra__we;

// to mtxregb module
wire  [MRB_IND_WTH-1 : 0]               mpu_mrb__rindex;
wire  [MRB_ADDR_WTH-1 : 0]              mpu_mrb__raddr;
wire                                    mpu_mrb__re;
wire  [0 : 0]                           mpu_mrb__type;
wire                                    mpu_mrb__rdata_act;
wire                                    mpu_mrb__vmode_rdata_act;

wire  [MRB_IND_WTH-1 : 0]               vpu_mrb__windex;
wire  [MRB_ADDR_WTH-1 : 0]              vpu_mrb__waddr;
wire                                    vpu_mrb__we;

// to mtxregc module
wire  [MRC_IND_WTH-1 : 0]               vputy_mrc__rindex;
wire  [MRC_ADDR_WTH-1 : 0]              vputy_mrc__raddr;
wire                                    vputy_mrc__re;
wire                                    vputy_mrc__rdata_act;

// to vecreg module
wire  [VR_IND_WTH-1 : 0]                mpu_vr__windex;
wire                                    mpu_vr__we;
wire  [VR_IND_WTH-1 : 0]                mpu_vr__rindex;
wire                                    mpu_vr__re;

wire  [VR_IND_WTH-1 : 0]                vpu_vr__rd_windex;
wire                                    vpu_vr__rd_we;
wire  [VR_IND_WTH-1 : 0]                vpu_vr__rs0_rindex;
wire  [VR_IND_WTH-1 : 0]                vpu_vr__rs1_rindex;
wire                                    vpu_vr__rs_re;
wire  [VPR_IND_WTH-1 : 0]               vpu_vr__rpd_windex;
wire                                    vpu_vr__rpd_we;
wire  [VPR_IND_WTH-1 : 0]               vpu_vr__rps0_rindex;
wire  [VPR_IND_WTH-1 : 0]               vpu_vr__rps1_rindex;
wire                                    vpu_vr__rps_re;

// to biasreg module
wire  [BR_IND_WTH-1 : 0]                vpu_brb__rindex;
wire  [BR_ADDR_WTH-1 : 0]               vpu_brb__raddr;
wire                                    vpu_brb__re;
wire                                    vpu_brb__rdata_act;

wire  [BR_IND_WTH-1 : 0]                vputy_brc__rindex;
wire  [BR_ADDR_WTH-1 : 0]               vputy_brc__raddr;
wire                                    vputy_brc__re;
wire                                    vputy_brc__rdata_act;

// to ddr_intf module
wire  [DDRIF_DATA_WTH-1 : 0]            svmr0_ddrintf__wdata;
wire                                    svmr0_ddrintf__wdata_act;
wire  [DDRIF_DATA_WTH-1 : 0]            svmr1_ddrintf__wdata = 0;
wire                                    svmr1_ddrintf__wdata_act = 0;

// to hpu_core[x] module
wire                                    ldmr_hpu_core_sel;
wire  [4 : 0]                           ldmr_mrx__sel;
wire  [MRA_IND_WTH-1 : 0]               ldmr_mra__windex;
wire  [MRA_ADDR_WTH-1 : 0]              ldmr_mra__waddr;
wire                                    ldmr_mra__we;
wire                                    ldmr0_mra__we;
wire                                    ldmr1_mra__we;

wire  [MRB_IND_WTH-1 : 0]               ldmr_mrb__windex;
wire  [MRB_ADDR_WTH-1 : 0]              ldmr_mrb__waddr;
wire                                    ldmr_mrb__we;
wire                                    ldmr0_mrb__we;
wire                                    ldmr1_mrb__we;

wire  [MRC_IND_WTH-1 : 0]               ldmr_mrc__windex;
wire  [MRC_ADDR_WTH-1 : 0]              ldmr_mrc__waddr;
wire                                    ldmr_mrc__we;
wire                                    ldmr0_mrc__we;
wire                                    ldmr1_mrc__we;

wire  [BR_IND_WTH-1 : 0]                ldmr_brb__windex;
wire  [BR_ADDR_WTH-1 : 0]               ldmr_brb__waddr;
wire                                    ldmr_brb__we;
wire                                    ldmr0_brb__we;
wire                                    ldmr1_brb__we;

wire  [BR_IND_WTH-1 : 0]                ldmr_brc__windex;
wire  [BR_ADDR_WTH-1 : 0]               ldmr_brc__waddr;
wire                                    ldmr_brc__we;
wire                                    ldmr0_brc__we;
wire                                    ldmr1_brc__we;

// to ddr_intf module
wire  [DDRIF_ADDR_WTH-1 : 0]            ldmr_ddrintf__raddr;
wire  [DDRIF_ALEN_WTH-1 : 0]            ldmr_ddrintf__rlen;
wire                                    ldmr_ddrintf__rcmd_vld;
wire                                    ldmr_ddrintf__rcmd_rdy;
wire                                    ldmr_ddrintf__rdata_last;
wire                                    ldmr_ddrintf__rdata_vld;
wire                                    ldmr_ddrintf__rdata_rdy;

wire  [DDRIF_DATA_WTH-1 : 0]            ldmr_ddrintf__rdata;
wire  [DDRIF_DATA_WTH-1 : 0]            ldmr_ddrintf__rdata_o;

wire                                    ldmr_ddrintf__rdata_act;

// to hpu_core[x] module
wire                                    svmr_hpu_core_sel;
wire  [MRA_IND_WTH-1 : 0]               svmr_mra__rindex;
wire  [MRA_ADDR_WTH-1 : 0]              svmr_mra__raddr;
wire                                    svmr_mra__re;
wire                                    svmr0_mra__re;
wire                                    svmr1_mra__re;

//to matrix data fifo
wire                                    mtxreg_data_we;
wire                                    mtxreg_data_re;
wire                                    mtxreg_data_full;
wire                                    mtxreg_data_empty;

// to ddr_intf module
wire  [DDRIF_ADDR_WTH-1 : 0]            svmr_ddrintf__waddr;
wire  [DDRIF_ALEN_WTH-1 : 0]            svmr_ddrintf__wlen;
wire                                    svmr_ddrintf__wcmd_vld;
wire                                    svmr_ddrintf__wcmd_rdy;
wire  [DDRIF_DSTROB_WTH-1 : 0]          svmr_ddrintf__wdata_strob;
wire                                    svmr_ddrintf__wdata_last;
wire                                    svmr_ddrintf__wdata_vld;
wire                                    svmr_ddrintf__wdata_rdy;

wire  [DDRIF_DATA_WTH-1:0]              svmr_ddrwrap__wdata;
wire  [DDRIF_DATA_WTH-1:0]              svmr_ddrintf__wdata;

//======================================================================================================================
// Instance
//======================================================================================================================



// wire[31 : 0] riscv_regmap__rdata;
// assign riscv_regmap__rdata_o = & riscv_regmap__rdata;

regmap_mgr #(
    .DPU_REG_ADDR_WTH       (DPU_REG_ADDR_WTH),
    .DPU_REG_DATA_WTH       (DPU_REG_DATA_WTH),
    .REGMAP_ADDR_WTH        (REGMAP_ADDR_WTH),
    .REGMAP_DATA_WTH        (REGMAP_DATA_WTH)
) regmap_mgr_inst (
    // clock & reset
    .clk_i                                  (clk_i),
    .rst_i                                  (rst_i),

    // regmap interface: from mcu_core module
    .riscv_regmap__waddr_i                  (riscv_regmap__waddr_i),
    .riscv_regmap__we_i                     (riscv_regmap__we_i),
    .riscv_regmap__wdata_i                  (riscv_regmap__wdata_i),
    .riscv_regmap__raddr_i                  (riscv_regmap__raddr_i),
    .riscv_regmap__re_i                     (riscv_regmap__re_i),
    .riscv_regmap__rdata_o                  (riscv_regmap__rdata_o),
    .riscv_regmap__rdata_act_o              (riscv_regmap__rdata_act_o),
    .riscv_regmap__intr_o                   (riscv_regmap__intr_o),

    // to hpu_ctrl module
    .regmap_conv__waddr_o                   (regmap_conv__waddr),
    .regmap_conv__wdata_o                   (regmap_conv__wdata),
    .regmap_conv__we_o                      (regmap_conv__we),
    .regmap_conv__intr_i                    (regmap_conv__intr),

    .regmap_dwc__waddr_o                    (regmap_dwc__waddr),
    .regmap_dwc__wdata_o                    (regmap_dwc__wdata),
    .regmap_dwc__we_o                       (regmap_dwc__we),
    .regmap_dwc__intr_i                     (regmap_dwc__intr),

    .regmap_dtrans__waddr_o                 (regmap_dtrans__waddr),
    .regmap_dtrans__wdata_o                 (regmap_dtrans__wdata),
    .regmap_dtrans__we_o                    (regmap_dtrans__we),
    .regmap_dtrans__intr_i                  (regmap_dtrans__intr),

    .regmap_ftrans__waddr_o                 (regmap_ftrans__waddr),
    .regmap_ftrans__wdata_o                 (regmap_ftrans__wdata),
    .regmap_ftrans__we_o                    (regmap_ftrans__we),
    .regmap_ftrans__intr_i                  (regmap_ftrans__intr),

    // to load_mtxreg_ctrl module
    .regmap_ldmr__waddr_o                   (regmap_ldmr__waddr),
    .regmap_ldmr__wdata_o                   (regmap_ldmr__wdata),
    .regmap_ldmr__we_o                      (regmap_ldmr__we),
    .regmap_ldmr__intr_i                    (regmap_ldmr__intr),

    // to save_mtxreg_ctrl module
    .regmap_svmr__waddr_o                   (regmap_svmr__waddr),
    .regmap_svmr__wdata_o                   (regmap_svmr__wdata),
    .regmap_svmr__we_o                      (regmap_svmr__we),
    .regmap_svmr__intr_i                    (regmap_svmr__intr),

    // to initial the download data module
    .regmap_dldata__waddr_o                 (regmap_dldata__waddr),
    .regmap_dldata__wdata_o                 (regmap_dldata__wdata),
    .regmap_dldata__we_o                    (regmap_dldata__we),

    // to initial the upload data module
    .regmap_upldata__waddr_o                (regmap_upldata__waddr),
    .regmap_upldata__wdata_o                (regmap_upldata__wdata),
    .regmap_upldata__we_o                   (regmap_upldata__we),
    
    // to tell ps all the layer is finish 
    .fshflg_ps_o                            (fshflg_ps_o)
);

hpu_ctrl #(
    .REGMAP_ADDR_WTH        (REGMAP_ADDR_WTH),
    .REGMAP_DATA_WTH        (REGMAP_DATA_WTH),
    .MRX_IND_WTH            (MRX_IND_WTH),
    .MRX_ADDR_WTH           (MRX_ADDR_WTH),
    .MRA_IND_WTH            (MRA_IND_WTH),
    .MRA_ADDR_WTH           (MRA_ADDR_WTH),
    .MRB_IND_WTH            (MRB_IND_WTH),
    .MRB_ADDR_WTH           (MRB_ADDR_WTH),
    .MRC_IND_WTH            (MRC_IND_WTH),
    .MRC_ADDR_WTH           (MRC_ADDR_WTH),
    .BR_IND_WTH             (BR_IND_WTH),
    .BR_ADDR_WTH            (BR_ADDR_WTH),
    .VR_IND_WTH             (VR_IND_WTH),
    .VPR_IND_WTH            (VPR_IND_WTH),
    .SR_DATA_WTH            (SR_DATA_WTH)
) hpu_ctrl_inst (
    // clock & reset
    .clk_i                                  (clk_i),
    .rst_i                                  (rst_i),

    // from register_map module
    .regmap_conv__waddr_i                   (regmap_conv__waddr),
    .regmap_conv__wdata_i                   (regmap_conv__wdata),
    .regmap_conv__we_i                      (regmap_conv__we),
    .regmap_conv__intr_o                    (regmap_conv__intr),

    .regmap_dwc__waddr_i                    (regmap_dwc__waddr),
    .regmap_dwc__wdata_i                    (regmap_dwc__wdata),
    .regmap_dwc__we_i                       (regmap_dwc__we),
    .regmap_dwc__intr_o                     (regmap_dwc__intr),

    .regmap_dtrans__waddr_i                 (regmap_dtrans__waddr),
    .regmap_dtrans__wdata_i                 (regmap_dtrans__wdata),
    .regmap_dtrans__we_i                    (regmap_dtrans__we),
    .regmap_dtrans__intr_o                  (regmap_dtrans__intr),

    .regmap_ftrans__waddr_i                 (regmap_ftrans__waddr),
    .regmap_ftrans__wdata_i                 (regmap_ftrans__wdata),
    .regmap_ftrans__we_i                    (regmap_ftrans__we),
    .regmap_ftrans__intr_o                  (regmap_ftrans__intr),

    // to mpu module
    .mpu_op_extacc_act_o                    (mpu_op_extacc_act),
    .mpu_op_bypass_act_o                    (mpu_op_bypass_act),
    .mpu_op_type_o                          (mpu_op_type),

    // to vpu module
    .vpu_op_sum_act_o                       (vpu_op_sum_act),
    .vpu_op_clip_o                          (vpu_op_clip),
    .vpu_op_bias_act_o                      (vpu_op_bias_act),
    .vpu_op_relu_act_o                      (vpu_op_relu_act),
    .vpu_op_shfl_act_o                      (vpu_op_shfl_act),
    .vpu_op_shfl_up_act_o                   (vpu_op_shfl_up_act),
    .vpu_op_strobe_h_o                      (vpu_op_strobe_h),
    .vpu_op_strobe_v_o                      (vpu_op_strobe_v),

    .vputy_op_mul_sel_o                     (vputy_op_mul_sel),
    .vputy_op_ldsl_sel_o                    (vputy_op_ldsl_sel),
    .vputy_op_ldsr_sel_o                    (vputy_op_ldsr_sel),
    .vputy_op_acc_sel_o                     (vputy_op_acc_sel),
    .vputy_op_max_sel_o                     (vputy_op_max_sel),
    .vputy_sv_sel_act_o                     (vputy_sv_sel_act),
    .vputy_sv_mtx_sel_h_o                   (vputy_sv_mtx_sel_h),
    .vputy_sv_clip_o                        (vputy_sv_clip),
    .vputy_sv_bias_act_o                    (vputy_sv_bias_act),
    .vputy_sv_relu_act_o                    (vputy_sv_relu_act),
    .vputy_sv_shfl_act_o                    (vputy_sv_shfl_act),
    .vputy_sv_chpri_act_o                   (vputy_sv_chpri_act),
    .vputy_sv_shfl_up_act_o                 (vputy_sv_shfl_up_act),
    .vputy_sv_strobe_h_o                    (vputy_sv_strobe_h),
    .vputy_sv_strobe_v_o                    (vputy_sv_strobe_v),

    // to mtxrega module
    .mpu0_mra__rindex_o                     (mpu0_mra__rindex),
    .mpu0_mra__raddr_o                      (mpu0_mra__raddr),
    .mpu0_mra__sl_o                         (mpu0_mra__sl),
    .mpu0_mra__sr_o                         (mpu0_mra__sr),
    .mpu0_mra__frcz_o                       (mpu0_mra__frcz),
    .mpu1_mra__rindex_o                     (mpu1_mra__rindex),
    .mpu1_mra__raddr_o                      (mpu1_mra__raddr),
    .mpu1_mra__sl_o                         (mpu1_mra__sl),
    .mpu1_mra__sr_o                         (mpu1_mra__sr),
    .mpu1_mra__frcz_o                       (mpu1_mra__frcz),
    .mpu_mra__re_o                          (mpu_mra__re),
    .mpu_mra__rdata_act_i                   (mpu_mra__rdata_act),

    .vpu_mra__windex_o                      (vpu_mra__windex),
    .vpu_mra__waddr_o                       (vpu_mra__waddr),
    .vpu_mra__we_o                          (vpu_mra__we),

    .vputy0_mra__rindex_o                   (vputy0_mra__rindex),
    .vputy0_mra__raddr_o                    (vputy0_mra__raddr),
    .vputy0_mra__sl_o                       (vputy0_mra__sl),
    .vputy0_mra__sr_o                       (vputy0_mra__sr),
    .vputy0_mra__frcz_o                     (vputy0_mra__frcz),
    .vputy1_mra__rindex_o                   (vputy1_mra__rindex),
    .vputy1_mra__raddr_o                    (vputy1_mra__raddr),
    .vputy1_mra__sl_o                       (vputy1_mra__sl),
    .vputy1_mra__sr_o                       (vputy1_mra__sr),
    .vputy1_mra__frcz_o                     (vputy1_mra__frcz),
    .vputy_mra__re_o                        (vputy_mra__re),
    .vputy_mra__rdata_act_i                 (vputy_mra__rdata_act),

    .vputy_mra__windex_o                    (vputy_mra__windex),
    .vputy_mra__waddr_o                     (vputy_mra__waddr),
    .vputy_mra__we_o                        (vputy_mra__we),

    // to mtxregb module
    .mpu_mrb__rindex_o                      (mpu_mrb__rindex),
    .mpu_mrb__raddr_o                       (mpu_mrb__raddr),
    .mpu_mrb__re_o                          (mpu_mrb__re),
    .mpu_mrb__type_o                        (mpu_mrb__type),
    .mpu_mrb__rdata_act_i                   (mpu_mrb__rdata_act),
    .mpu_mrb__vmode_rdata_act_i             (mpu_mrb__vmode_rdata_act),

    .vpu_mrb__windex_o                      (vpu_mrb__windex),
    .vpu_mrb__waddr_o                       (vpu_mrb__waddr),
    .vpu_mrb__we_o                          (vpu_mrb__we),

    // to mtxregc module
    .vputy_mrc__rindex_o                    (vputy_mrc__rindex),
    .vputy_mrc__raddr_o                     (vputy_mrc__raddr),
    .vputy_mrc__re_o                        (vputy_mrc__re),
    .vputy_mrc__rdata_act_i                 (vputy_mrc__rdata_act),

    // to vecreg module
    .mpu_vr__windex_o                       (mpu_vr__windex),
    .mpu_vr__we_o                           (mpu_vr__we),
    .mpu_vr__rindex_o                       (mpu_vr__rindex),
    .mpu_vr__re_o                           (mpu_vr__re),

    .vpu_vr__rd_windex_o                    (vpu_vr__rd_windex),
    .vpu_vr__rd_we_o                        (vpu_vr__rd_we),
    .vpu_vr__rs0_rindex_o                   (vpu_vr__rs0_rindex),
    .vpu_vr__rs1_rindex_o                   (vpu_vr__rs1_rindex),
    .vpu_vr__rs_re_o                        (vpu_vr__rs_re),
    .vpu_vr__rpd_windex_o                   (vpu_vr__rpd_windex),
    .vpu_vr__rpd_we_o                       (vpu_vr__rpd_we),
    .vpu_vr__rps0_rindex_o                  (vpu_vr__rps0_rindex),
    .vpu_vr__rps1_rindex_o                  (vpu_vr__rps1_rindex),
    .vpu_vr__rps_re_o                       (vpu_vr__rps_re),

    // to biasreg module
    .vpu_brb__rindex_o                      (vpu_brb__rindex),
    .vpu_brb__raddr_o                       (vpu_brb__raddr),
    .vpu_brb__re_o                          (vpu_brb__re),
    .vpu_brb__rdata_act_i                   (vpu_brb__rdata_act),

    .vputy_brc__rindex_o                    (vputy_brc__rindex),
    .vputy_brc__raddr_o                     (vputy_brc__raddr),
    .vputy_brc__re_o                        (vputy_brc__re),
    .vputy_brc__rdata_act_i                 (vputy_brc__rdata_act)
);

hpu_core #(
    .SR_DATA_WTH        (SR_DATA_WTH),
    .MRA_IND_WTH        (MRA_IND_WTH),
    .MRA_ADDR_WTH       (MRA_ADDR_WTH),
    .MRB_IND_WTH        (MRB_IND_WTH),
    .MRB_ADDR_WTH       (MRB_ADDR_WTH),
    .MRC_IND_WTH        (MRC_IND_WTH),
    .MRC_ADDR_WTH       (MRC_ADDR_WTH),
    .BR_IND_WTH         (BR_IND_WTH),
    .BR_ADDR_WTH        (BR_ADDR_WTH),
    .MR_PROC_WTH        (MR_PROC_WTH),
    .VR_PROC_WTH        (VR_PROC_WTH),
    .VMR_PROC_WTH       (VMR_PROC_WTH),
    .BR_PROC_WTH        (BR_PROC_WTH),
    .MR_PROC_H_PARAL    (MR_PROC_H_PARAL),
    .MR_PROC_V_PARAL    (MR_PROC_V_PARAL),
    .MTX_DATA_WTH       (MTX_DATA_WTH),
    .MR_DATA_WTH        (MR_DATA_WTH),
    .BR_DATA_WTH        (BR_DATA_WTH),
    .VMR_DATA_WTH       (VMR_DATA_WTH),
    .MR_DSTROB_H_WTH    (MR_DSTROB_H_WTH),
    .MR_DSTROB_V_WTH    (MR_DSTROB_V_WTH),
    .VR_PROC_PARAL      (VR_PROC_PARAL),
    .VR_IND_WTH         (VR_IND_WTH),
    .VR_DATA_WTH        (VR_DATA_WTH),
    .VPR_IND_WTH        (VPR_IND_WTH),
    .VPR_DATA_WTH       (VPR_DATA_WTH),
    .DDRIF_DATA_WTH     (DDRIF_DATA_WTH)
) hpu_core0_inst (
    // clock & reset
    .clk_i                                  (clk_i),
    .clk_2x_i                               (clk_2x_i),
    .rst_i                                  (rst_i),

    // from mpu_ctrl module
    .mpu_op_extacc_act_i                    (mpu_op_extacc_act),
    .mpu_op_bypass_act_i                    (mpu_op_bypass_act),
    .mpu_op_type_i                          (mpu_op_type),

    .mpu_vr__windex_i                       (mpu_vr__windex),
    .mpu_vr__we_i                           (mpu_vr__we),
    .mpu_vr__rindex_i                       (mpu_vr__rindex),
    .mpu_vr__re_i                           (mpu_vr__re),

    .mpu_mra__rindex_i                      (mpu0_mra__rindex),
    .mpu_mra__raddr_i                       (mpu0_mra__raddr),
    .mpu_mra__sl_i                          (mpu0_mra__sl),
    .mpu_mra__sr_i                          (mpu0_mra__sr),
    .mpu_mra__frcz_i                        (mpu0_mra__frcz),
    .mpu_mra__re_i                          (mpu_mra__re),

    .mpu_mrb__rindex_i                      (mpu_mrb__rindex),
    .mpu_mrb__raddr_i                       (mpu_mrb__raddr),
    .mpu_mrb__re_i                          (mpu_mrb__re),
    .mpu_mrb__type_i                        (mpu_mrb__type),

    // from vpu_ctrl module
    .vpu_op_sum_act_i                       (vpu_op_sum_act),
    .vpu_op_clip_i                          (vpu_op_clip),
    .vpu_op_bias_act_i                      (vpu_op_bias_act),
    .vpu_op_relu_act_i                      (vpu_op_relu_act),
    .vpu_op_shfl_act_i                      (vpu_op_shfl_act),
    .vpu_op_shfl_up_act_i                   (vpu_op_shfl_up_act),
    .vpu_op_strobe_h_i                      (vpu_op_strobe_h),
    .vpu_op_strobe_v_i                      (vpu_op_strobe_v),

    .vpu_vr__rd_windex_i                    (vpu_vr__rd_windex),
    .vpu_vr__rd_we_i                        (vpu_vr__rd_we),
    .vpu_vr__rs0_rindex_i                   (vpu_vr__rs0_rindex),
    .vpu_vr__rs1_rindex_i                   (vpu_vr__rs1_rindex),
    .vpu_vr__rs_re_i                        (vpu_vr__rs_re),
    .vpu_vr__rpd_windex_i                   (vpu_vr__rpd_windex),
    .vpu_vr__rpd_we_i                       (vpu_vr__rpd_we),
    .vpu_vr__rps0_rindex_i                  (vpu_vr__rps0_rindex),
    .vpu_vr__rps1_rindex_i                  (vpu_vr__rps1_rindex),
    .vpu_vr__rps_re_i                       (vpu_vr__rps_re),

    .vpu_mra__windex_i                      (vpu_mra__windex),
    .vpu_mra__waddr_i                       (vpu_mra__waddr),
    .vpu_mra__we_i                          (vpu_mra__we),

    .vpu_brb__rindex_i                      (vpu_brb__rindex),
    .vpu_brb__raddr_i                       (vpu_brb__raddr),
    .vpu_brb__re_i                          (vpu_brb__re),

    // from vpu_tiny_ctrl module
    .vputy_op_mul_sel_i                     (vputy_op_mul_sel),
    .vputy_op_ldsl_sel_i                    (vputy_op_ldsl_sel),
    .vputy_op_ldsr_sel_i                    (vputy_op_ldsr_sel),
    .vputy_op_acc_sel_i                     (vputy_op_acc_sel),
    .vputy_op_max_sel_i                     (vputy_op_max_sel),
    .vputy_sv_sel_act_i                     (vputy_sv_sel_act),
    .vputy_sv_mtx_sel_h_i                   (vputy_sv_mtx_sel_h),
    .vputy_sv_clip_i                        (vputy_sv_clip),
    .vputy_sv_bias_act_i                    (vputy_sv_bias_act),
    .vputy_sv_relu_act_i                    (vputy_sv_relu_act),
    .vputy_sv_shfl_act_i                    (vputy_sv_shfl_act),
    .vputy_sv_chpri_act_i                   (vputy_sv_chpri_act),
    .vputy_sv_shfl_up_act_i                 (vputy_sv_shfl_up_act),
    .vputy_sv_strobe_h_i                    (vputy_sv_strobe_h),
    .vputy_sv_strobe_v_i                    (vputy_sv_strobe_v),

    .vputy_mra__rindex_i                    (vputy0_mra__rindex),
    .vputy_mra__raddr_i                     (vputy0_mra__raddr),
    .vputy_mra__sl_i                        (vputy0_mra__sl),
    .vputy_mra__sr_i                        (vputy0_mra__sr),
    .vputy_mra__frcz_i                      (vputy0_mra__frcz),
    .vputy_mra__re_i                        (vputy_mra__re),
    .vputy_mra__windex_i                    (vputy_mra__windex),
    .vputy_mra__waddr_i                     (vputy_mra__waddr),
    .vputy_mra__we_i                        (vputy_mra__we),

    .vputy_mrc__rindex_i                    (vputy_mrc__rindex),
    .vputy_mrc__raddr_i                     (vputy_mrc__raddr),
    .vputy_mrc__re_i                        (vputy_mrc__re),

    .vputy_brc__rindex_i                    (vputy_brc__rindex),
    .vputy_brc__raddr_i                     (vputy_brc__raddr),
    .vputy_brc__re_i                        (vputy_brc__re),

    // from load_mtxreg_ctrl module
    .ldmr_mra__windex_i                     (ldmr_mra__windex),
    .ldmr_mra__waddr_i                      (ldmr_mra__waddr),
    .ldmr_mra__we_i                         (ldmr0_mra__we),

    .ldmr_mrb__windex_i                     (ldmr_mrb__windex),
    .ldmr_mrb__waddr_i                      (ldmr_mrb__waddr),
    .ldmr_mrb__we_i                         (ldmr0_mrb__we),

    .ldmr_mrc__windex_i                     (ldmr_mrc__windex),
    .ldmr_mrc__waddr_i                      (ldmr_mrc__waddr),
    .ldmr_mrc__we_i                         (ldmr0_mrc__we),

    .ldmr_brb__windex_i                     (ldmr_brb__windex),
    .ldmr_brb__waddr_i                      (ldmr_brb__waddr),
    .ldmr_brb__we_i                         (ldmr0_brb__we),

    .ldmr_brc__windex_i                     (ldmr_brc__windex),
    .ldmr_brc__waddr_i                      (ldmr_brc__waddr),
    .ldmr_brc__we_i                         (ldmr0_brc__we),

    .ldmr_mrx__sel_i                        (ldmr_mrx__sel),

    // from save_mtxreg_ctrl module
    .svmr_mra__rindex_i                     (svmr_mra__rindex),
    .svmr_mra__raddr_i                      (svmr_mra__raddr),
    .svmr_mra__re_i                         (svmr0_mra__re),

    // from ddr_intf module
    .ldmr_ddrintf__rdata_i                  (ldmr_ddrintf__rdata_o),
    .ldmr_ddrintf__rdata_act_i              (ldmr_ddrintf__rdata_act),

    // to ddr_intf module
    .svmr_ddrintf__wdata_o                  (svmr0_ddrintf__wdata),
    .svmr_ddrintf__wdata_act_o              (svmr0_ddrintf__wdata_act)
);
/*
hpu_core #(
    .SR_DATA_WTH        (SR_DATA_WTH),
    .MRA_IND_WTH        (MRA_IND_WTH),
    .MRA_ADDR_WTH       (MRA_ADDR_WTH),
    .MRB_IND_WTH        (MRB_IND_WTH),
    .MRB_ADDR_WTH       (MRB_ADDR_WTH),
    .MRC_IND_WTH        (MRC_IND_WTH),
    .MRC_ADDR_WTH       (MRC_ADDR_WTH),
    .BR_IND_WTH         (BR_IND_WTH),
    .BR_ADDR_WTH        (BR_ADDR_WTH),
    .MR_PROC_WTH        (MR_PROC_WTH),
    .VR_PROC_WTH        (VR_PROC_WTH),
    .VMR_PROC_WTH       (VMR_PROC_WTH),
    .BR_PROC_WTH        (BR_PROC_WTH),
    .MR_PROC_H_PARAL    (MR_PROC_H_PARAL),
    .MR_PROC_V_PARAL    (MR_PROC_V_PARAL),
    .MTX_DATA_WTH       (MTX_DATA_WTH),
    .MR_DATA_WTH        (MR_DATA_WTH),
    .BR_DATA_WTH        (BR_DATA_WTH),
    .VMR_DATA_WTH       (VMR_DATA_WTH),
    .MR_DSTROB_H_WTH    (MR_DSTROB_H_WTH),
    .MR_DSTROB_V_WTH    (MR_DSTROB_V_WTH),
    .VR_PROC_PARAL      (VR_PROC_PARAL),
    .VR_IND_WTH         (VR_IND_WTH),
    .VR_DATA_WTH        (VR_DATA_WTH),
    .VPR_IND_WTH        (VPR_IND_WTH),
    .VPR_DATA_WTH       (VPR_DATA_WTH),
    .DDRIF_DATA_WTH     (DDRIF_DATA_WTH)
) hpu_core1_inst (
    // clock & reset
    .clk_i                                  (clk_i),
    .clk_2x_i                               (clk_2x_i),
    .rst_i                                  (rst_i),

    // from mpu_ctrl module
    .mpu_op_extacc_act_i                    (mpu_op_extacc_act),
    .mpu_op_bypass_act_i                    (mpu_op_bypass_act),
    .mpu_op_type_i                          (mpu_op_type),

    .mpu_vr__windex_i                       (mpu_vr__windex),
    .mpu_vr__we_i                           (mpu_vr__we),
    .mpu_vr__rindex_i                       (mpu_vr__rindex),
    .mpu_vr__re_i                           (mpu_vr__re),

    .mpu_mra__rindex_i                      (mpu1_mra__rindex),
    .mpu_mra__raddr_i                       (mpu1_mra__raddr),
    .mpu_mra__sl_i                          (mpu1_mra__sl),
    .mpu_mra__sr_i                          (mpu1_mra__sr),
    .mpu_mra__frcz_i                        (mpu1_mra__frcz),
    .mpu_mra__re_i                          (mpu_mra__re),

    .mpu_mrb__rindex_i                      (mpu_mrb__rindex),
    .mpu_mrb__raddr_i                       (mpu_mrb__raddr),
    .mpu_mrb__re_i                          (mpu_mrb__re),
    .mpu_mrb__type_i                        (mpu_mrb__type),

    // from vpu_ctrl module
    .vpu_op_sum_act_i                       (vpu_op_sum_act),
    .vpu_op_clip_i                          (vpu_op_clip),
    .vpu_op_bias_act_i                      (vpu_op_bias_act),
    .vpu_op_relu_act_i                      (vpu_op_relu_act),
    .vpu_op_shfl_act_i                      (vpu_op_shfl_act),
    .vpu_op_shfl_up_act_i                   (vpu_op_shfl_up_act),
    .vpu_op_strobe_h_i                      (vpu_op_strobe_h),
    .vpu_op_strobe_v_i                      (vpu_op_strobe_v),

    .vpu_vr__rd_windex_i                    (vpu_vr__rd_windex),
    .vpu_vr__rd_we_i                        (vpu_vr__rd_we),
    .vpu_vr__rs0_rindex_i                   (vpu_vr__rs0_rindex),
    .vpu_vr__rs1_rindex_i                   (vpu_vr__rs1_rindex),
    .vpu_vr__rs_re_i                        (vpu_vr__rs_re),
    .vpu_vr__rpd_windex_i                   (vpu_vr__rpd_windex),
    .vpu_vr__rpd_we_i                       (vpu_vr__rpd_we),
    .vpu_vr__rps0_rindex_i                  (vpu_vr__rps0_rindex),
    .vpu_vr__rps1_rindex_i                  (vpu_vr__rps1_rindex),
    .vpu_vr__rps_re_i                       (vpu_vr__rps_re),

    .vpu_mra__windex_i                      (vpu_mra__windex),
    .vpu_mra__waddr_i                       (vpu_mra__waddr),
    .vpu_mra__we_i                          (vpu_mra__we),

    .vpu_brb__rindex_i                      (vpu_brb__rindex),
    .vpu_brb__raddr_i                       (vpu_brb__raddr),
    .vpu_brb__re_i                          (vpu_brb__re),

    // from vpu_tiny_ctrl module
    .vputy_op_mul_sel_i                     (vputy_op_mul_sel),
    .vputy_op_ldsl_sel_i                    (vputy_op_ldsl_sel),
    .vputy_op_ldsr_sel_i                    (vputy_op_ldsr_sel),
    .vputy_op_acc_sel_i                     (vputy_op_acc_sel),
    .vputy_op_max_sel_i                     (vputy_op_max_sel),
    .vputy_sv_sel_act_i                     (vputy_sv_sel_act),
    .vputy_sv_mtx_sel_h_i                   (vputy_sv_mtx_sel_h),
    .vputy_sv_clip_i                        (vputy_sv_clip),
    .vputy_sv_bias_act_i                    (vputy_sv_bias_act),
    .vputy_sv_relu_act_i                    (vputy_sv_relu_act),
    .vputy_sv_shfl_act_i                    (vputy_sv_shfl_act),
    .vputy_sv_chpri_act_i                   (vputy_sv_chpri_act),
    .vputy_sv_shfl_up_act_i                 (vputy_sv_shfl_up_act),
    .vputy_sv_strobe_h_i                    (vputy_sv_strobe_h),
    .vputy_sv_strobe_v_i                    (vputy_sv_strobe_v),

    .vputy_mra__rindex_i                    (vputy1_mra__rindex),
    .vputy_mra__raddr_i                     (vputy1_mra__raddr),
    .vputy_mra__sl_i                        (vputy1_mra__sl),
    .vputy_mra__sr_i                        (vputy1_mra__sr),
    .vputy_mra__frcz_i                      (vputy1_mra__frcz),
    .vputy_mra__re_i                        (vputy_mra__re),
    .vputy_mra__windex_i                    (vputy_mra__windex),
    .vputy_mra__waddr_i                     (vputy_mra__waddr),
    .vputy_mra__we_i                        (vputy_mra__we),

    .vputy_mrc__rindex_i                    (vputy_mrc__rindex),
    .vputy_mrc__raddr_i                     (vputy_mrc__raddr),
    .vputy_mrc__re_i                        (vputy_mrc__re),

    .vputy_brc__rindex_i                    (vputy_brc__rindex),
    .vputy_brc__raddr_i                     (vputy_brc__raddr),
    .vputy_brc__re_i                        (vputy_brc__re),

    // from load_mtxreg_ctrl module
    .ldmr_mra__windex_i                     (ldmr_mra__windex),
    .ldmr_mra__waddr_i                      (ldmr_mra__waddr),
    .ldmr_mra__we_i                         (ldmr1_mra__we),

    .ldmr_mrb__windex_i                     (ldmr_mrb__windex),
    .ldmr_mrb__waddr_i                      (ldmr_mrb__waddr),
    .ldmr_mrb__we_i                         (ldmr1_mrb__we),

    .ldmr_mrc__windex_i                     (ldmr_mrc__windex),
    .ldmr_mrc__waddr_i                      (ldmr_mrc__waddr),
    .ldmr_mrc__we_i                         (ldmr1_mrc__we),

    .ldmr_brb__windex_i                     (ldmr_brb__windex),
    .ldmr_brb__waddr_i                      (ldmr_brb__waddr),
    .ldmr_brb__we_i                         (ldmr1_brb__we),

    .ldmr_brc__windex_i                     (ldmr_brc__windex),
    .ldmr_brc__waddr_i                      (ldmr_brc__waddr),
    .ldmr_brc__we_i                         (ldmr1_brc__we),

    .ldmr_mrx__sel_i                        (ldmr_mrx__sel),

    // from save_mtxreg_ctrl module
    .svmr_mra__rindex_i                     (svmr_mra__rindex),
    .svmr_mra__raddr_i                      (svmr_mra__raddr),
    .svmr_mra__re_i                         (svmr1_mra__re),

    // from ddr_intf module
    .ldmr_ddrintf__rdata_i                  (ldmr_ddrintf__rdata),
    .ldmr_ddrintf__rdata_act_i              (ldmr_ddrintf__rdata_act),

    // to ddr_intf module
    .svmr_ddrintf__wdata_o                  (svmr1_ddrintf__wdata),
    .svmr_ddrintf__wdata_act_o              (svmr1_ddrintf__wdata_act)
);
*/
assign ldmr0_mra__we = ldmr_mra__we & ~ldmr_hpu_core_sel;
assign ldmr0_mrb__we = ldmr_mrb__we & ~ldmr_hpu_core_sel;
assign ldmr0_mrc__we = ldmr_mrc__we & ~ldmr_hpu_core_sel;
assign ldmr0_brb__we = ldmr_brb__we & ~ldmr_hpu_core_sel;
assign ldmr0_brc__we = ldmr_brc__we & ~ldmr_hpu_core_sel;
assign ldmr1_mra__we = ldmr_mra__we & ldmr_hpu_core_sel;
assign ldmr1_mrb__we = ldmr_mrb__we & ldmr_hpu_core_sel;
assign ldmr1_mrc__we = ldmr_mrc__we & ldmr_hpu_core_sel;
assign ldmr1_brb__we = ldmr_brb__we & ldmr_hpu_core_sel;
assign ldmr1_brc__we = ldmr_brc__we & ldmr_hpu_core_sel;

assign svmr0_mra__re = svmr_mra__re & ~svmr_hpu_core_sel;
assign svmr1_mra__re = svmr_mra__re & svmr_hpu_core_sel;

assign svmr_ddrwrap__wdata = svmr0_ddrintf__wdata_act ? svmr0_ddrintf__wdata : svmr1_ddrintf__wdata;

assign ldmr_ddrintf__rdata_act = ldmr_ddrintf__rdata_vld & ldmr_ddrintf__rdata_rdy;

load_mtxreg_ctrl_v2 #(                                                  
    .REGMAP_ADDR_WTH    (REGMAP_ADDR_WTH),                              
    .REGMAP_DATA_WTH    (REGMAP_DATA_WTH),                              
    .DDRIF_ADDR_WTH     (DDRIF_ADDR_WTH),                               
    .DDRIF_ALEN_WTH     (DDRIF_ALEN_WTH),                               
    .MRX_IND_WTH        (MRX_IND_WTH),                                  
    .MRX_ADDR_WTH       (MRX_ADDR_WTH),                                 
    .MRA_IND_WTH        (MRA_IND_WTH),                                  
    .MRA_ADDR_WTH       (MRA_ADDR_WTH),                                 
    .MRB_IND_WTH        (MRB_IND_WTH),                                  
    .MRB_ADDR_WTH       (MRB_ADDR_WTH),                                 
    .MRC_IND_WTH        (MRC_IND_WTH),                                  
    .MRC_ADDR_WTH       (MRC_ADDR_WTH),                                 
    .BR_IND_WTH         (BR_IND_WTH),                                   
    .BR_ADDR_WTH        (BR_ADDR_WTH)                                   
) load_mtxreg_ctrl_inst (                                               
    // clock & reset                                                    
    .clk_i                                  (clk_i),                    
    .rst_i                                  (rst_i),                    
                                                                        
    // regmap interface: from regmap_mgr module                         
    .regmap_ldmr__waddr_i                   (regmap_ldmr__waddr),       
    .regmap_ldmr__wdata_i                   (regmap_ldmr__wdata),       
    .regmap_ldmr__we_i                      (regmap_ldmr__we),          
    .regmap_ldmr__intr_o                    (regmap_ldmr__intr),        
                                                                        
    // to hpu_core[x] module                                            
    .ldmr_hpu_core_sel_o                    (ldmr_hpu_core_sel),        
    .ldmr_mrx__sel_o                        (ldmr_mrx__sel),            
    .ldmr_mra__windex_o                     (ldmr_mra__windex),         
    .ldmr_mra__waddr_o                      (ldmr_mra__waddr),          
    .ldmr_mra__we_o                         (ldmr_mra__we),             
                                                                        
    .ldmr_mrb__windex_o                     (ldmr_mrb__windex),         
    .ldmr_mrb__waddr_o                      (ldmr_mrb__waddr),          
    .ldmr_mrb__we_o                         (ldmr_mrb__we),             
                                                                        
    .ldmr_mrc__windex_o                     (ldmr_mrc__windex),         
    .ldmr_mrc__waddr_o                      (ldmr_mrc__waddr),          
    .ldmr_mrc__we_o                         (ldmr_mrc__we),             
                                                                        
    .ldmr_brb__windex_o                     (ldmr_brb__windex),         
    .ldmr_brb__waddr_o                      (ldmr_brb__waddr),          
    .ldmr_brb__we_o                         (ldmr_brb__we),             
                                                                        
    .ldmr_brc__windex_o                     (ldmr_brc__windex),         
    .ldmr_brc__waddr_o                      (ldmr_brc__waddr),          
    .ldmr_brc__we_o                         (ldmr_brc__we),             
                                                                        
    .ldmr_ddrintf__rdata_o                  (ldmr_ddrintf__rdata_o),    
    // to ddr_intf module                                               
    .ldmr_ddrintf__raddr_o                  (ldmr_ddrintf__raddr),      
    .ldmr_ddrintf__rlen_o                   (ldmr_ddrintf__rlen),       
    .ldmr_ddrintf__rcmd_vld_o               (ldmr_ddrintf__rcmd_vld),   
    .ldmr_ddrintf__rcmd_rdy_i               (ldmr_ddrintf__rcmd_rdy ),  
    .ldmr_ddrintf__rdata_last_i             (ldmr_ddrintf__rdata_last ),
    .ldmr_ddrintf__rdata_vld_i              (ldmr_ddrintf__rdata_vld ), 
    .ldmr_ddrintf__rdata_i                  (ldmr_ddrintf__rdata ),     
    .ldmr_ddrintf__rdata_rdy_o              (ldmr_ddrintf__rdata_rdy )  
);                                                                        

save_mtxreg_ctrl #(
    .REGMAP_ADDR_WTH    (REGMAP_ADDR_WTH),
    .REGMAP_DATA_WTH    (REGMAP_DATA_WTH),
    .DDRIF_ADDR_WTH     (DDRIF_ADDR_WTH),
    .DDRIF_ALEN_WTH     (DDRIF_ALEN_WTH),
    .DDRIF_DATA_WTH     (DDRIF_DATA_WTH),
    .DDRIF_DSTROB_WTH   (DDRIF_DSTROB_WTH),
    .MRX_IND_WTH        (MRX_IND_WTH),
    .MRX_ADDR_WTH       (MRX_ADDR_WTH),
    .MRA_IND_WTH        (MRA_IND_WTH),
    .MRA_ADDR_WTH       (MRA_ADDR_WTH),
    .MRB_IND_WTH        (MRB_IND_WTH),
    .MRB_ADDR_WTH       (MRB_ADDR_WTH)
) save_mtxreg_ctrl_inst (
    // clock & reset
    .clk_i                                  (clk_i),
    .rst_i                                  (rst_i),

    // regmap interface: from regmap_mgr module
    .regmap_svmr__waddr_i                   (regmap_svmr__waddr),
    .regmap_svmr__wdata_i                   (regmap_svmr__wdata),
    .regmap_svmr__we_i                      (regmap_svmr__we),
    .regmap_svmr__intr_o                    (regmap_svmr__intr),

    // to hpu_core[x] module
    .svmr_hpu_core_sel_o                    (svmr_hpu_core_sel),
    .svmr_mra__rindex_o                     (svmr_mra__rindex),
    .svmr_mra__raddr_o                      (svmr_mra__raddr),
    .svmr_mra__re_o                         (svmr_mra__re),

    //to matrix data fifo
    .mtxreg_data_we_o                       (mtxreg_data_we),
    .mtxreg_data_re_o                       (mtxreg_data_re),
    .mtxreg_data_full_i                     (mtxreg_data_full),
    .mtxreg_data_empty_i                    (mtxreg_data_empty),

    // to ddr_intf module
    .svmr_ddrintf__waddr_o                  (svmr_ddrintf__waddr),
    .svmr_ddrintf__wlen_o                   (svmr_ddrintf__wlen),
    .svmr_ddrintf__wcmd_vld_o               (svmr_ddrintf__wcmd_vld),
    .svmr_ddrintf__wcmd_rdy_i               (svmr_ddrintf__wcmd_rdy),
    .svmr_ddrintf__wdata_strob_o            (svmr_ddrintf__wdata_strob),
    .svmr_ddrintf__wdata_last_o             (svmr_ddrintf__wdata_last),
    .svmr_ddrintf__wdata_vld_o              (svmr_ddrintf__wdata_vld),
    .svmr_ddrintf__wdata_rdy_i              (svmr_ddrintf__wdata_rdy)
);

save_mtxreg_data_wrap #(
    .DDRIF_DATA_WTH     (DDRIF_DATA_WTH)
) save_mtxreg_data_wrap (
    // clock & reset
    .clk_i                                  (clk_i),
    .rst_i                                  (rst_i),
    // data fifo ctrl
    .mtxreg_data_we_i                       (mtxreg_data_we),
    .svmr_ddrwrap__wdata_i                  (svmr_ddrwrap__wdata),

    .mtxreg_data_re_i                       (mtxreg_data_re),
    .svmr_ddrintf__wdata_o                  (svmr_ddrintf__wdata),

    .mtxreg_data_full_o                     (mtxreg_data_full),
    .mtxreg_data_empty_o                    (mtxreg_data_empty)
);

ddr_intf #(
    .DDRIF_ADDR_WTH     (DDRIF_ADDR_WTH),
    .DDRIF_ALEN_WTH     (DDRIF_ALEN_WTH),
    .DDRIF_DATA_WTH     (DDRIF_DATA_WTH),
    .DDRIF_DSTROB_WTH   (DDRIF_DSTROB_WTH)
) ddr_intf_inst (
    // clock & reset
    // ddr clock
    // core clock
    .clk_i                                  (clk_i),
    // common reset
    .rst_i                                  (rst_i),



    // from save_mtxreg_ctrl module
    .svmr_ddrintf__waddr_i                  (svmr_ddrintf__waddr),
    .svmr_ddrintf__wlen_i                   (svmr_ddrintf__wlen),
    .svmr_ddrintf__wcmd_vld_i               (svmr_ddrintf__wcmd_vld),
    .svmr_ddrintf__wcmd_rdy_o               (svmr_ddrintf__wcmd_rdy),
    .svmr_ddrintf__wdata_i                  (svmr_ddrintf__wdata),
    .svmr_ddrintf__wdata_last_i             (svmr_ddrintf__wdata_last),
    .svmr_ddrintf__wdata_strob_i            (svmr_ddrintf__wdata_strob),
    .svmr_ddrintf__wdata_vld_i              (svmr_ddrintf__wdata_vld),
    .svmr_ddrintf__wdata_rdy_o              (svmr_ddrintf__wdata_rdy),

    // from load_mtxreg_ctrl module
    .ldmr_ddrintf__raddr_i                  (ldmr_ddrintf__raddr),
    .ldmr_ddrintf__rlen_i                   (ldmr_ddrintf__rlen),
    .ldmr_ddrintf__rcmd_vld_i               (ldmr_ddrintf__rcmd_vld),
    .ldmr_ddrintf__rcmd_rdy_o               (ldmr_ddrintf__rcmd_rdy),
    .ldmr_ddrintf__rdata_o                  (ldmr_ddrintf__rdata),
    .ldmr_ddrintf__rdata_last_o             (ldmr_ddrintf__rdata_last),
    .ldmr_ddrintf__rdata_vld_o              (ldmr_ddrintf__rdata_vld),
    .ldmr_ddrintf__rdata_rdy_i              (ldmr_ddrintf__rdata_rdy),
    
    
   .axi_ddr_araddr       (axi_ddr_araddr     ),
  .axi_ddr_arready      (axi_ddr_arready    ),
  .axi_ddr_arvalid      (axi_ddr_arvalid    ),
  .axi_ddr_awaddr       (axi_ddr_awaddr     ),
  .axi_ddr_awready      (axi_ddr_awready    ),
  .axi_ddr_awvalid      (axi_ddr_awvalid    ),
  .axi_ddr_rdata        (axi_ddr_rdata      ),
  .axi_ddr_rid          (axi_ddr_rid        ),
  .axi_ddr_rlast        (axi_ddr_rlast      ),
  .axi_ddr_rready       (axi_ddr_rready     ),
  .axi_ddr_rvalid       (axi_ddr_rvalid     ),
  .axi_ddr_wdata        (axi_ddr_wdata      ),
  .axi_ddr_wlast        (axi_ddr_wlast      ),
  .axi_ddr_wready       (axi_ddr_wready     ),
  .axi_ddr_wvalid       (axi_ddr_wvalid     )
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
