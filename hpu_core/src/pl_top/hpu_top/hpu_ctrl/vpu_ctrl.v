// +FHDR------------------------------------------------------------------------
// XJTU IAIR Corporation All Rights Reserved
// -----------------------------------------------------------------------------
// FILE NAME  : vpu_ctrl.v
// DEPARTMENT : CAG of IAIR
// AUTHOR     : XXXX
// AUTHOR'S EMAIL :XXXX@mail.xjtu.edu.cn
// -----------------------------------------------------------------------------
// Ver 1.0  2019--01--01 initial version.
// -----------------------------------------------------------------------------
// KEYWORDS   : vector processing unit, controlling,
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

// vpu shedule, the datapath of vpu module
//  clk,    VPU_decoder,            VR read,            sum,        clip,   BR read,            bias,       relu,   shuffle0,          MR write0,   shuffle1,           MR write1,
//  ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//  0       receive/decode op_code,
//  1                               raddr/re of VR,                                 
//  2                               VR rdata is active, sum_phase0,
//  3                                                   sum_phase1,         raddr/re of BR,
//  4                                                   sum_phase2,
//  5                                                               clip,
//  6                                                               prot0,
//  7                                                                       BR rdata is active, add bias,
//  8                                                                                           prot1,
//  9                                                                                                       relu,
//  10                                                                                                              shuffle0,
//  11                                                                                                              MR wdata is active, we of MR,   shuffle1,
//  12                                                                                                                                              MR wdata is active, we of MR,
//  ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

module vpu_ctrl #(
    parameter MRX_IND_WTH = 5,
    parameter MRX_ADDR_WTH = 9,
    parameter MRA_IND_WTH = 3,
    parameter MRA_ADDR_WTH = 9,
    parameter MRB_IND_WTH = 3,
    parameter MRB_ADDR_WTH = 9,
    parameter BR_IND_WTH = 1,
    parameter BR_ADDR_WTH = 9,
    parameter VR_IND_WTH = 4,
    parameter VPR_IND_WTH = 3,
    parameter SR_DATA_WTH = 32
) (
    // clock & reset
    input                                   clk_i,
    input                                   rst_i,

    // from conv_ctrl module
    input [5 : 0]                           convctl_vpu__code_i,
    input [MRX_IND_WTH-1 : 0]               convctl_vpu__br_index_i,
    input [MRX_ADDR_WTH-1 : 0]              convctl_vpu__br_addr_i,
    input [4 : 0]                           convctl_vpu__clip_i,
    input [0 : 0]                           convctl_vpu__shfl_i,
    input [MRX_IND_WTH-1 : 0]               convctl_vpu__sv_index_i,
    input [MRX_ADDR_WTH-1 : 0]              convctl_vpu__sv_addr_i,
    input [7 : 0]                           convctl_vpu__sv_strobe_h_i,

    // to vecreg module
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

    // to vpu module
    output                                  vpu_op_sum_act_o,
    output[4 : 0]                           vpu_op_clip_o,
    output                                  vpu_op_bias_act_o,
    output                                  vpu_op_relu_act_o,
    output                                  vpu_op_shfl_act_o,
    output                                  vpu_op_shfl_up_act_o,
    output[7 : 0]                           vpu_op_strobe_h_o,
    output[7 : 0]                           vpu_op_strobe_v_o,

    // to biasreg module
    output[BR_IND_WTH-1 : 0]                vpu_brb__rindex_o,
    output[BR_ADDR_WTH-1 : 0]               vpu_brb__raddr_o,
    output                                  vpu_brb__re_o,
    input                                   vpu_brb__rdata_act_i,

    // to mtxrega module
    output[MRA_IND_WTH-1 : 0]               vpu_mra__windex_o,
    output[MRA_ADDR_WTH-1 : 0]              vpu_mra__waddr_o,
    output                                  vpu_mra__we_o
);

//======================================================================================================================
// Wire & Reg declaration
//======================================================================================================================
localparam EN_ACT = 0;
localparam EN_SUM  = 1;
localparam EN_BIAS = 2;
localparam EN_RELU = 3;
localparam EN_SHFL = 4;
localparam EN_CHPRI = 5;

localparam VPU_DLY = 11;

wire  [5 : 0]                           vpu_code;
wire  [MRX_IND_WTH-1 : 0]               vpu_br_index;
wire  [MRX_ADDR_WTH-1 : 0]              vpu_br_addr;
wire  [4 : 0]                           vpu_clip;
wire  [MRX_IND_WTH-1 : 0]               vpu_sv_index;
wire  [MRX_ADDR_WTH-1 : 0]              vpu_sv_addr;
wire  [7 : 0]                           vpu_sv_strobe_h;
wire  [7 : 0]                           vpu_sv_strobe_v;

reg   [(VPU_DLY+1)*6-1 : 0]             vpu_code_dlychain;
reg   [(VPU_DLY+1)*MRX_IND_WTH-1 : 0]   vpu_br_index_dlychain;
reg   [(VPU_DLY+1)*MRX_ADDR_WTH-1 : 0]  vpu_br_addr_dlychain;
reg   [(VPU_DLY+1)*5-1 : 0]             vpu_clip_dlychain;
reg   [(VPU_DLY+1)*MRX_IND_WTH-1 : 0]   vpu_sv_index_dlychain;
reg   [(VPU_DLY+1)*MRX_ADDR_WTH-1 : 0]  vpu_sv_addr_dlychain;
reg   [(VPU_DLY+1)*8-1 : 0]             vpu_sv_strobe_h_dlychain;
reg   [(VPU_DLY+1)*8-1 : 0]             vpu_sv_strobe_v_dlychain;

reg                                     vr_re;
reg                                     br_re;
reg   [MRX_IND_WTH-1 : 0]               br_rindex;
reg   [MRX_ADDR_WTH-1 : 0]              br_raddr;

reg                                     sum_act;
reg   [4 : 0]                           clip;
reg                                     bias_act;
reg                                     relu_act;
reg                                     shfl_act;
reg   [MRX_IND_WTH-1 : 0]               windex;
reg   [MRX_ADDR_WTH-1 : 0]              waddr;
reg                                     we_act;

reg   [7 : 0]                           strobe_h;
reg   [7 : 0]                           strobe_v;
reg                                     shfl_up_act;
reg                                     chpri_act;
wire                                    mra_we_act;
wire                                    mrb_we_act;

reg   [MRA_IND_WTH-1 : 0]               windex_dly1;
reg   [MRA_ADDR_WTH-1 : 0]              waddr_dly1;
reg                                     we_act_dly1;
reg   [7 : 0]                           strobe_h_dly1;
reg   [7 : 0]                           strobe_v_dly1;

//======================================================================================================================
// Instance
//======================================================================================================================

// select operation code and parameters from module conv_ctrl and fc_ctrl.
assign vpu_code = convctl_vpu__code_i;
assign vpu_br_index = convctl_vpu__br_index_i;
assign vpu_br_addr = convctl_vpu__br_addr_i;
assign vpu_clip = convctl_vpu__clip_i;
assign vpu_sv_index = convctl_vpu__sv_index_i;
assign vpu_sv_addr = convctl_vpu__sv_addr_i;
assign vpu_sv_strobe_h = convctl_vpu__sv_strobe_h_i;
assign vpu_sv_strobe_v = vpu_code[EN_SHFL] ? (convctl_vpu__shfl_i ? 8'haa : 8'h55) : 8'hff;

// delay chains of all signtals
always @(posedge clk_i) begin
    if(rst_i) begin
        vpu_code_dlychain <= {((VPU_DLY+1)*6){1'b0}};
    end else begin
        vpu_code_dlychain <= {vpu_code_dlychain[VPU_DLY*6-1 : 0], vpu_code};
    end
end
always @(posedge clk_i) begin
    vpu_clip_dlychain <= {vpu_clip_dlychain[VPU_DLY*5-1 : 0], vpu_clip};
    vpu_br_index_dlychain <= {vpu_br_index_dlychain[VPU_DLY*MRX_IND_WTH-1 : 0], vpu_br_index};
    vpu_br_addr_dlychain <= {vpu_br_addr_dlychain[VPU_DLY*MRX_ADDR_WTH-1 : 0], vpu_br_addr};
    vpu_sv_index_dlychain <= {vpu_sv_index_dlychain[VPU_DLY*MRX_IND_WTH-1 : 0], vpu_sv_index};
    vpu_sv_addr_dlychain <= {vpu_sv_addr_dlychain[VPU_DLY*MRX_ADDR_WTH-1 : 0], vpu_sv_addr};
    vpu_sv_strobe_h_dlychain <= {vpu_sv_strobe_h_dlychain[VPU_DLY*8-1 : 0], vpu_sv_strobe_h};
    vpu_sv_strobe_v_dlychain <= {vpu_sv_strobe_v_dlychain[VPU_DLY*8-1 : 0], vpu_sv_strobe_v};
end

// clk delay 1
// set the read addr/en signal of VR, which stores the calculating result of
// MPU.
// The read data is active at clk2.
always @(posedge clk_i) begin
    if(rst_i) begin
        vr_re <= 1'b0;
    end else begin
        vr_re <= vpu_code[EN_ACT];
    end
end
assign vpu_vr__rs_re_o = vr_re;
assign vpu_vr__rs0_rindex_o = 'h0;
assign vpu_vr__rs1_rindex_o = 'h0;

// In register version, VPU register is shrinked to only store the psum data,
// only need one 4B storage space. Hence below interface is reserved and set to 0.
assign vpu_vr__rd_windex_o = 'h0;
assign vpu_vr__rd_we_o = 1'b0;
assign vpu_vr__rpd_windex_o = 'h0;
assign vpu_vr__rpd_we_o = 1'b0;
assign vpu_vr__rps0_rindex_o = 'h0;
assign vpu_vr__rps1_rindex_o = 'h0;
assign vpu_vr__rps_re_o = 1'b0;

// clk delay 3
// set read addr/en of BR, which stores the bias data. The bias data is active
// at clk(3+4)= clk7.
always @(posedge clk_i) begin
    if(rst_i) begin
        br_re <= 1'b0;
    end else begin
        br_re <= vpu_code_dlychain[6 + EN_ACT] & vpu_code_dlychain[6 + EN_BIAS];
    end
end
assign vpu_brb__re_o = br_re;

always @(posedge clk_i) begin
    br_rindex <= vpu_br_index_dlychain[MRX_IND_WTH +: MRX_IND_WTH] - 5'h12;
    br_raddr <= vpu_br_addr_dlychain[MRX_ADDR_WTH +: MRX_ADDR_WTH];
end
assign vpu_brb__rindex_o = br_rindex[BR_IND_WTH-1 : 0];
assign vpu_brb__raddr_o = br_raddr;

// clk delay 4
// In clk4, select the original calc result of MPU and sum data in veritical direction.
always @(posedge clk_i) begin
    sum_act <= vpu_code_dlychain[2*6 + EN_ACT] & vpu_code_dlychain[2*6 + EN_SUM];
end
assign vpu_op_sum_act_o = sum_act;

// clk delay 5
// Clip the 4B data to 1B data, in order to fit the ofm store.
always @(posedge clk_i) begin
    clip <= vpu_clip_dlychain[3*5 +: 5];
end
assign vpu_op_clip_o = clip;

// clk delay 7
// Set whether need to add bias data to ofm. The bias data is 1B width.
always @(posedge clk_i) begin
    bias_act <= vpu_code_dlychain[5*6 + EN_ACT] & vpu_code_dlychain[5*6 + EN_BIAS];
end
assign vpu_op_bias_act_o = bias_act;

// clk delay 9
// Set whether need to do RELU operation to ofm.
always @(posedge clk_i) begin
    relu_act <= vpu_code_dlychain[7*6 + EN_ACT] & vpu_code_dlychain[7*6 + EN_RELU];
end
assign vpu_op_relu_act_o = relu_act;

// clk delay 10
// When shuffle is active, write lower 4 channels at first, write left 4 channels
// at next cycle.
// When shuffle is 0, wrie the whole 8 channels of ofm at one cycle.
always @(posedge clk_i) begin
    shfl_act <= vpu_code_dlychain[8*6 + EN_ACT] & vpu_code_dlychain[8*6 + EN_SHFL];
end
assign vpu_op_shfl_act_o = shfl_act;

// clk delay 11
// If the ofm does not need shuffle, write the ofm data at current clock cycle.
// Otherwise, write lower 4 channel at current clock cycle, and write upper
// 4 channel at next clock cycle. Be attention, the address should increase
// accrodingly.
always @(posedge clk_i) begin
    windex <= vpu_sv_index_dlychain[9*MRX_IND_WTH +: MRX_IND_WTH];
    waddr <= vpu_sv_addr_dlychain[9*MRX_ADDR_WTH +: MRX_ADDR_WTH];
    we_act <= vpu_code_dlychain[9*6 + EN_ACT];
end

always @(posedge clk_i) begin
    strobe_h <= vpu_sv_strobe_h_dlychain[9*8 +: 8];
    strobe_v <= vpu_sv_strobe_v_dlychain[9*8 +: 8];
end

// clk delay 12
// shfl_up_act signal indicates writing upper 4 channel data.
always @(posedge clk_i) begin
    shfl_up_act <= vpu_code_dlychain[10*6 + EN_ACT] & vpu_code_dlychain[10*6 + EN_SHFL];
    chpri_act <= vpu_code_dlychain[9*6 + EN_ACT] & vpu_code_dlychain[9*6 + EN_CHPRI];
end
assign vpu_op_shfl_up_act_o = shfl_up_act;

always @(posedge clk_i) begin
    windex_dly1 <= windex;
    if(chpri_act) begin
        waddr_dly1 <= waddr;
    end else begin
        waddr_dly1 <= waddr + 1'b1;
    end
    we_act_dly1 <= we_act;
    if(chpri_act) begin
        strobe_h_dly1 <= {strobe_h[6 : 0], 1'b0};
    end else begin
        strobe_h_dly1 <= strobe_h;
    end
    strobe_v_dly1 <= strobe_v;
end

// clk delay 11-12
assign vpu_mra__windex_o = shfl_up_act ? windex_dly1 : windex;
assign vpu_mra__waddr_o = shfl_up_act ? waddr_dly1 : waddr;
assign vpu_mra__we_o = shfl_up_act ? we_act_dly1 : we_act;
assign vpu_op_strobe_h_o = shfl_up_act ? strobe_h_dly1 : strobe_h;
assign vpu_op_strobe_v_o = shfl_up_act ? strobe_v_dly1 : strobe_v;

//======================================================================================================================
// just for simulation
//======================================================================================================================
// synthesis translate_off

// synthesis translate_on

//======================================================================================================================
// probe signals
//======================================================================================================================

endmodule   



