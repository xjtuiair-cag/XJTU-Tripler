// +FHDR------------------------------------------------------------------------
// XJTU IAIR Corporation All Rights Reserved
// -----------------------------------------------------------------------------
// FILE NAME  : vputy_ctrl.v
// DEPARTMENT : CAG of IAIR
// AUTHOR     : XXXX
// AUTHOR'S EMAIL :XXXX@mail.xjtu.edu.cn
// -----------------------------------------------------------------------------
// Ver 1.0  2019--01--01 initial version.
// -----------------------------------------------------------------------------
// KEYWORDS   : external vector processing unit, controlling,
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

module vputy_ctrl #(
    parameter MRX_IND_WTH = 5,
    parameter MRX_ADDR_WTH = 9,
    parameter MRA_IND_WTH = 3,
    parameter MRA_ADDR_WTH = 9,
    parameter MRC_IND_WTH = 1,
    parameter MRC_ADDR_WTH = 9,
    parameter BR_IND_WTH = 1,
    parameter BR_ADDR_WTH = 9
) (
    // clock & reset
    input                                   clk_i,
    input                                   rst_i,

    // from dwc_ctrl module
    input [4 : 0]                           dwcctl_vputy__code_i,
    input                                   dwcctl_vputy0__mrs0_sl_i,
    input                                   dwcctl_vputy0__mrs0_sr_i,
    input [MRX_IND_WTH-1 : 0]               dwcctl_vputy0__mrs0_index_i,
    input [MRX_ADDR_WTH-1 : 0]              dwcctl_vputy0__mrs0_addr_i,
    input                                   dwcctl_vputy1__mrs0_sl_i,
    input                                   dwcctl_vputy1__mrs0_sr_i,
    input [MRX_IND_WTH-1 : 0]               dwcctl_vputy1__mrs0_index_i,
    input [MRX_ADDR_WTH-1 : 0]              dwcctl_vputy1__mrs0_addr_i,
    input [MRX_IND_WTH-1 : 0]               dwcctl_vputy__mrs1_index_i,
    input [MRX_ADDR_WTH-1 : 0]              dwcctl_vputy__mrs1_addr_i,
    input [5 : 0]                           dwcctl_vputy__sv_code_i,
    input [MRX_IND_WTH-1 : 0]               dwcctl_vputy__br_index_i,
    input [MRX_ADDR_WTH-1 : 0]              dwcctl_vputy__br_addr_i,
    input [4 : 0]                           dwcctl_vputy__clip_i,
    input [0 : 0]                           dwcctl_vputy__shfl_i,
    input [MRX_IND_WTH-1 : 0]               dwcctl_vputy__mrd_index_i,
    input [MRX_ADDR_WTH-1 : 0]              dwcctl_vputy__mrd_addr_i,
    input [7 : 0]                           dwcctl_vputy__strobe_h_i,

    // from datatrans_ctrl module
    input [4 : 0]                           dtransctl_vputy__code_i,
    input [MRX_IND_WTH-1 : 0]               dtransctl_vputy__mrs0_index_i,
    input [MRX_ADDR_WTH-1 : 0]              dtransctl_vputy__mrs0_addr_i,
    input [5 : 0]                           dtransctl_vputy__sv_code_i,
    input [0 : 0]                           dtransctl_vputy__shfl_i,
    input [MRX_IND_WTH-1 : 0]               dtransctl_vputy__mrd_index_i,
    input [MRX_ADDR_WTH-1 : 0]              dtransctl_vputy__mrd_addr_i,
    input [7 : 0]                           dtransctl_vputy__strobe_h_i,

    // from fmttrans_ctrl module
    input [4 : 0]                           ftransctl_vputy__code_i,
    input [MRX_IND_WTH-1 : 0]               ftransctl_vputy__mrs0_index_i,
    input [MRX_ADDR_WTH-1 : 0]              ftransctl_vputy__mrs0_addr_i,
    input [5 : 0]                           ftransctl_vputy__sv_code_i,
    input [2 : 0]                           ftransctl_vputy__mtx_sel_h_i,
    input [MRX_IND_WTH-1 : 0]               ftransctl_vputy__mrd_index_i,
    input [MRX_ADDR_WTH-1 : 0]              ftransctl_vputy__mrd_addr_i,
    input [7 : 0]                           ftransctl_vputy__strobe_h_i,

    // to vputy module
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

    // to mtxregc module
    output[MRC_IND_WTH-1 : 0]               vputy_mrc__rindex_o,
    output[MRC_ADDR_WTH-1 : 0]              vputy_mrc__raddr_o,
    output                                  vputy_mrc__re_o,
    input                                   vputy_mrc__rdata_act_i,

    // to biasreg module
    output[BR_IND_WTH-1 : 0]                vputy_brc__rindex_o,
    output[BR_ADDR_WTH-1 : 0]               vputy_brc__raddr_o,
    output                                  vputy_brc__re_o,
    input                                   vputy_brc__rdata_act_i
);

//======================================================================================================================
// Wire & Reg declaration
//======================================================================================================================
localparam OP_LOAD = 5'b00001;
localparam OP_MUL  = 5'b00011;
localparam OP_ACC  = 5'b00101;
localparam OP_MACC = 5'b00111;
localparam OP_MAX  = 5'b10101;
localparam OP_LDSL = 5'b01001;
localparam OP_LDSR = 5'b11001;

localparam ACT = 0;
localparam MUL = 1;
localparam ITER = 2;
localparam SHFT = 3;
localparam TYPE = 4;

localparam EN_ACT  = 0;
localparam EN_SEL  = 1;
localparam EN_BIAS = 2;
localparam EN_RELU = 3;
localparam EN_SHFL = 4;
localparam EN_CHPRI = 5;

localparam VPUTY_DLY = 20;

wire                                    dwcctl_act;
wire                                    dtransctl_act;
wire  [4 : 0]                           vputy_code;
wire                                    vputy0_mrs0_sl;
wire                                    vputy0_mrs0_sr;
wire  [MRX_IND_WTH-1 : 0]               vputy0_mrs0_index;
wire  [MRX_ADDR_WTH-1 : 0]              vputy0_mrs0_addr;
wire                                    vputy1_mrs0_sl;
wire                                    vputy1_mrs0_sr;
wire  [MRX_IND_WTH-1 : 0]               vputy1_mrs0_index;
wire  [MRX_ADDR_WTH-1 : 0]              vputy1_mrs0_addr;
wire  [MRX_IND_WTH-1 : 0]               vputy_mrs1_index;
wire  [MRX_ADDR_WTH-1 : 0]              vputy_mrs1_addr;
wire  [5 : 0]                           vputy_sv_code;
wire  [4 : 0]                           vputy_clip;
wire  [2 : 0]                           vputy_mtx_sel_h;
wire  [MRX_IND_WTH-1 : 0]               vputy_br_index;
wire  [MRX_ADDR_WTH-1 : 0]              vputy_br_addr;
wire  [0 : 0]                           vputy_shfl;
wire  [MRX_IND_WTH-1 : 0]               vputy_mrd_index;
wire  [MRX_ADDR_WTH-1 : 0]              vputy_mrd_addr;
wire  [7 : 0]                           vputy_strobe_h;

reg   [(VPUTY_DLY+1)*5-1 : 0]           code_dlychain;
reg   [(VPUTY_DLY+1)*6-1 : 0]           sv_code_dlychain;
reg   [(VPUTY_DLY+1)*5-1 : 0]           clip_dlychain;
reg   [(VPUTY_DLY+1)*3-1 : 0]           mtx_sel_h_dlychain;
reg   [(VPUTY_DLY+1)*MRX_IND_WTH-1 : 0] br_index_dlychain;
reg   [(VPUTY_DLY+1)*MRX_ADDR_WTH-1 : 0]br_addr_dlychain;
reg   [VPUTY_DLY : 0]                   shfl_dlychain;
reg   [(VPUTY_DLY+1)*MRX_IND_WTH-1 : 0] mrd_index_dlychain;
reg   [(VPUTY_DLY+1)*MRX_ADDR_WTH-1 : 0]mrd_addr_dlychain;
reg   [(VPUTY_DLY+1)*8-1 : 0]           strobe_h_dlychain;

reg                                     mrs0_re;
reg                                     mrs1_re;
reg   [MRA_IND_WTH-1 : 0]               core0_mra_rindex;
reg   [MRA_ADDR_WTH-1 : 0]              core0_mra_raddr;
reg                                     core0_mra_sl;
reg                                     core0_mra_sr;
reg                                     core0_mra_frcz;
reg   [MRA_IND_WTH-1 : 0]               core1_mra_rindex;
reg   [MRA_ADDR_WTH-1 : 0]              core1_mra_raddr;
reg                                     core1_mra_sl;
reg                                     core1_mra_sr;
reg                                     core1_mra_frcz;
reg   [MRC_IND_WTH-1 : 0]               mrc_rindex;
reg   [MRC_ADDR_WTH-1 : 0]              mrc_raddr;

reg                                     op_mul_sel;
reg                                     op_ldsl_sel;
reg                                     op_ldsr_sel;
reg                                     op_acc_sel;
reg                                     op_max_sel;

reg   [2 : 0]                           mtx_sel_h;

reg                                     br_re;
reg   [BR_IND_WTH-1 : 0]                br_rindex;
reg   [BR_ADDR_WTH-1 : 0]               br_raddr;

reg                                     sel_act;

reg   [4 : 0]                           clip;

reg                                     bias_act;

reg                                     relu_act;

reg                                     shfl_act;
reg                                     chpri_act;

reg   [MRX_IND_WTH-1 : 0]               windex;
reg   [MRX_ADDR_WTH-1 : 0]              waddr;
reg                                     we_act;
wire                                    mra_we_act;

reg   [7 : 0]                           strobe_h;
reg   [7 : 0]                           strobe_v;

reg                                     shfl_up_act;

reg   [MRX_IND_WTH-1 : 0]               windex_dly1;
reg   [MRX_ADDR_WTH-1 : 0]              waddr_dly1;
reg                                     mra_we_act_dly1;
reg   [7 : 0]                           strobe_h_dly1;
reg   [7 : 0]                           strobe_v_dly1;

//======================================================================================================================
// Instance
//======================================================================================================================

// select operation code and parameters from module dwc_ctrl, pool_ctrl, and dtrans_ctrl.
assign dwcctl_act = dwcctl_vputy__code_i[ACT];
assign dtransctl_act = dtransctl_vputy__code_i[ACT];
assign vputy_code = dwcctl_act ? dwcctl_vputy__code_i : dtransctl_act ? dtransctl_vputy__code_i : ftransctl_vputy__code_i;
assign vputy0_mrs0_sl = dwcctl_act ? dwcctl_vputy0__mrs0_sl_i : 1'b0;
assign vputy0_mrs0_sr = dwcctl_act ? dwcctl_vputy0__mrs0_sr_i : 1'b0;
assign vputy0_mrs0_index = dwcctl_act ? dwcctl_vputy0__mrs0_index_i : dtransctl_act ? dtransctl_vputy__mrs0_index_i : ftransctl_vputy__mrs0_index_i;
assign vputy0_mrs0_addr = dwcctl_act ? dwcctl_vputy0__mrs0_addr_i : dtransctl_act ? dtransctl_vputy__mrs0_addr_i : ftransctl_vputy__mrs0_addr_i;
assign vputy1_mrs0_sl = dwcctl_act ? dwcctl_vputy1__mrs0_sl_i : 1'b0;
assign vputy1_mrs0_sr = dwcctl_act ? dwcctl_vputy1__mrs0_sr_i : 1'b0;
assign vputy1_mrs0_index = dwcctl_act ? dwcctl_vputy1__mrs0_index_i : dtransctl_act ? dtransctl_vputy__mrs0_index_i : ftransctl_vputy__mrs0_index_i;
assign vputy1_mrs0_addr = dwcctl_act ? dwcctl_vputy1__mrs0_addr_i : dtransctl_act ? dtransctl_vputy__mrs0_addr_i : ftransctl_vputy__mrs0_addr_i;
assign vputy_mrs1_index = dwcctl_vputy__mrs1_index_i;
assign vputy_mrs1_addr = dwcctl_vputy__mrs1_addr_i;
assign vputy_sv_code = dwcctl_act ? dwcctl_vputy__sv_code_i : dtransctl_act ? dtransctl_vputy__sv_code_i : ftransctl_vputy__sv_code_i;
assign vputy_clip = dwcctl_act ? dwcctl_vputy__clip_i : 5'h0;
assign vputy_mtx_sel_h = ftransctl_vputy__mtx_sel_h_i;
assign vputy_br_index = dwcctl_vputy__br_index_i;
assign vputy_br_addr = dwcctl_vputy__br_addr_i;
assign vputy_shfl = dwcctl_act ? dwcctl_vputy__shfl_i : dtransctl_vputy__shfl_i;
assign vputy_mrd_index = dwcctl_act ? dwcctl_vputy__mrd_index_i : dtransctl_act ? dtransctl_vputy__mrd_index_i : ftransctl_vputy__mrd_index_i;
assign vputy_mrd_addr = dwcctl_act ? dwcctl_vputy__mrd_addr_i : dtransctl_act ? dtransctl_vputy__mrd_addr_i : ftransctl_vputy__mrd_addr_i;
assign vputy_strobe_h = dwcctl_act ? dwcctl_vputy__strobe_h_i : dtransctl_act ? dtransctl_vputy__strobe_h_i : ftransctl_vputy__strobe_h_i;

// delay chains of all signals
always @(posedge clk_i) begin
    if(rst_i) begin
        code_dlychain <= {(VPUTY_DLY+1)*5{1'b0}};
        sv_code_dlychain <= {(VPUTY_DLY+1)*6{1'b0}};
    end else begin
        code_dlychain <= {code_dlychain[VPUTY_DLY*5-1 : 0], vputy_code};
        sv_code_dlychain <= {sv_code_dlychain[VPUTY_DLY*6-1 : 0], vputy_sv_code};
    end
end

always @(posedge clk_i) begin
    clip_dlychain <= {clip_dlychain[VPUTY_DLY*5-1 : 0], vputy_clip};
    mtx_sel_h_dlychain <= {mtx_sel_h_dlychain[VPUTY_DLY*3-1 : 0], vputy_mtx_sel_h};
    br_index_dlychain <= {br_index_dlychain[VPUTY_DLY*MRX_IND_WTH-1 : 0], vputy_br_index};
    br_addr_dlychain <= {br_addr_dlychain[VPUTY_DLY*MRX_ADDR_WTH-1 : 0], vputy_br_addr};
    shfl_dlychain <= {shfl_dlychain[VPUTY_DLY-1 : 0], vputy_shfl};
    mrd_index_dlychain <= {mrd_index_dlychain[VPUTY_DLY*MRX_IND_WTH-1 : 0], vputy_mrd_index};
    mrd_addr_dlychain <= {mrd_addr_dlychain[VPUTY_DLY*MRX_ADDR_WTH-1 : 0], vputy_mrd_addr};
    strobe_h_dlychain <= {strobe_h_dlychain[VPUTY_DLY*8-1 : 0], vputy_strobe_h};
end

// clk delay 1
always @(posedge clk_i) begin
    if(rst_i) begin
        mrs0_re <= 1'b0;
        mrs1_re <= 1'b0;
    end else begin
        mrs0_re <= vputy_code[ACT];
        mrs1_re <= vputy_code[ACT] & vputy_code[MUL];
    end
end
assign vputy_mra__re_o = mrs0_re;
assign vputy_mrc__re_o = mrs1_re;

always @(posedge clk_i) begin
    core0_mra_rindex <= vputy0_mrs0_index;
    core0_mra_raddr <= vputy0_mrs0_addr;
    core0_mra_sl <= vputy0_mrs0_sl;
    core0_mra_sr <= vputy0_mrs0_sr;
    core0_mra_frcz <= (&vputy0_mrs0_index);
    core1_mra_rindex <= vputy1_mrs0_index;
    core1_mra_raddr <= vputy1_mrs0_addr;
    core1_mra_sl <= vputy1_mrs0_sl;
    core1_mra_sr <= vputy1_mrs0_sr;
    core1_mra_frcz <= (&vputy1_mrs0_index);
    mrc_rindex <= vputy_mrs1_index - 5'h10;
    mrc_raddr <= vputy_mrs1_addr;
end
assign vputy0_mra__rindex_o = core0_mra_rindex;
assign vputy0_mra__raddr_o = core0_mra_raddr;
assign vputy0_mra__sl_o = core0_mra_sl;
assign vputy0_mra__sr_o = core0_mra_sr;
assign vputy0_mra__frcz_o = core0_mra_frcz;
assign vputy1_mra__rindex_o = core1_mra_rindex;
assign vputy1_mra__raddr_o = core1_mra_raddr;
assign vputy1_mra__sl_o = core1_mra_sl;
assign vputy1_mra__sr_o = core1_mra_sr;
assign vputy1_mra__frcz_o = core1_mra_frcz;
assign vputy_mrc__rindex_o = mrc_rindex;
assign vputy_mrc__raddr_o = mrc_raddr;

// clk delay 9
always @(posedge clk_i) begin
    op_mul_sel <= code_dlychain[7*5 + MUL];
    op_ldsl_sel <= code_dlychain[7*5 + SHFT] & ~code_dlychain[7*5 + TYPE];
    op_ldsr_sel <= code_dlychain[7*5 + SHFT] & code_dlychain[7*5 + TYPE];
    op_acc_sel <= code_dlychain[7*5 + ITER] & ~code_dlychain[7*5 + TYPE];
    op_max_sel <= code_dlychain[7*5 + ITER] & code_dlychain[7*5 + TYPE];
end
assign vputy_op_mul_sel_o = op_mul_sel;
assign vputy_op_ldsl_sel_o = op_ldsl_sel;
assign vputy_op_ldsr_sel_o = op_ldsr_sel;
assign vputy_op_acc_sel_o = op_acc_sel;
assign vputy_op_max_sel_o = op_max_sel;

// clk delay 10
always @(posedge clk_i) begin
    mtx_sel_h <= mtx_sel_h_dlychain[8*3 +: 3];
end
assign vputy_sv_mtx_sel_h_o = mtx_sel_h;

// clk delay 11
always @(posedge clk_i) begin
    if(rst_i) begin
        br_re <= 1'b0;
    end else begin
        br_re <= sv_code_dlychain[9*6 + EN_ACT] & sv_code_dlychain[9*6 + EN_BIAS];
    end
end
assign vputy_brc__re_o = br_re;

always @(posedge clk_i) begin
    br_rindex <= br_index_dlychain[9*MRX_IND_WTH +: MRX_IND_WTH] - 5'h13;
    br_raddr <= br_addr_dlychain[9*MRX_ADDR_WTH +: MRX_ADDR_WTH];
end
assign vputy_brc__rindex_o = br_rindex;
assign vputy_brc__raddr_o = br_raddr;

// clk delay 12
always @(posedge clk_i) begin
    sel_act <= sv_code_dlychain[10*6 + EN_ACT] & sv_code_dlychain[10*6 + EN_SEL];
end
assign vputy_sv_sel_act_o = sel_act;

// clk delay 13
always @(posedge clk_i) begin
    clip <= clip_dlychain[11*5 +: 5];
end
assign vputy_sv_clip_o = clip;

// clk delay 15
always @(posedge clk_i) begin
    bias_act <= sv_code_dlychain[13*6 + EN_ACT] & sv_code_dlychain[13*6 + EN_BIAS];
end
assign vputy_sv_bias_act_o = bias_act;

// clk delay 17
always @(posedge clk_i) begin
    relu_act <= sv_code_dlychain[15*6 + EN_ACT] & sv_code_dlychain[15*6 + EN_RELU];
end
assign vputy_sv_relu_act_o = relu_act;

// clk delay 18
always @(posedge clk_i) begin
    shfl_act <= sv_code_dlychain[16*6 + EN_ACT] & sv_code_dlychain[16*6 + EN_SHFL];
    chpri_act <= sv_code_dlychain[16*6 + EN_ACT] & sv_code_dlychain[16*6 + EN_CHPRI];
end
assign vputy_sv_shfl_act_o = shfl_act;
assign vputy_sv_chpri_act_o = chpri_act;

// clk delay 19
always @(posedge clk_i) begin
    windex <= mrd_index_dlychain[17*MRX_IND_WTH +: MRX_IND_WTH];
    waddr <= mrd_addr_dlychain[17*MRX_ADDR_WTH +: MRX_ADDR_WTH];
    we_act <= sv_code_dlychain[17*6 + EN_ACT];
end
assign mra_we_act = we_act && (windex[MRX_IND_WTH-1 : MRA_IND_WTH] == 'h0);

always @(posedge clk_i) begin
    strobe_h <= strobe_h_dlychain[17*8 +: 8];
    if(sv_code_dlychain[17*6 + EN_ACT] & sv_code_dlychain[17*6 + EN_SHFL]) begin
        strobe_v <= shfl_dlychain[17] ? 8'haa : 8'h55;
    end else begin
        strobe_v <= 8'hff;
    end
end

// clk delay 20
always @(posedge clk_i) begin
    shfl_up_act <= sv_code_dlychain[18*6 + EN_ACT] & sv_code_dlychain[18*6 + EN_SHFL];
end
assign vputy_sv_shfl_up_act_o = shfl_up_act;

always @(posedge clk_i) begin
    windex_dly1 <= windex;
    waddr_dly1 <= waddr + 1'b1;
    mra_we_act_dly1 <= mra_we_act;
    strobe_h_dly1 <= strobe_h;
    strobe_v_dly1 <= strobe_v;
end

// clk delay 19-20
assign vputy_mra__windex_o = shfl_up_act ? windex_dly1 : windex;
assign vputy_mra__waddr_o = shfl_up_act ? waddr_dly1 : waddr;
assign vputy_mra__we_o = shfl_up_act ? mra_we_act_dly1 : mra_we_act;
assign vputy_sv_strobe_h_o = shfl_up_act ? strobe_h_dly1 : strobe_h;
assign vputy_sv_strobe_v_o = shfl_up_act ? strobe_v_dly1 : strobe_v;

//======================================================================================================================
// just for simulation
//======================================================================================================================
// synthesis translate_off

// synthesis translate_on

//======================================================================================================================
// probe signals
//======================================================================================================================

endmodule   
