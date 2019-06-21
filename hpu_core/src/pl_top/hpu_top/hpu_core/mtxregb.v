// +FHDR------------------------------------------------------------------------
// XJTU IAIR Corporation All Rights Reserved
// -----------------------------------------------------------------------------
// FILE NAME  : mtxregb.v
// DEPARTMENT : CAG of IAIR
// AUTHOR     : XXXX
// AUTHOR'S EMAIL :XXXX@mail.xjtu.edu.cn
// -----------------------------------------------------------------------------
// Ver 1.0  2019--01--01 initial version.
// -----------------------------------------------------------------------------
// KEYWORDS   : mtxreg, memory,
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

module mtxregb #(
    parameter MRB_IND_WTH = 3,
    parameter MRB_ADDR_WTH = 9,
    parameter MR_PROC_WTH = 8,
    parameter MR_PROC_H_PARAL = 8,
    parameter MR_PROC_V_PARAL = 8,
    parameter MTX_DATA_WTH = MR_PROC_WTH * MR_PROC_V_PARAL,
    parameter MR_DATA_WTH = MTX_DATA_WTH * MR_PROC_H_PARAL,
    parameter VMR_PROC_WTH = 64,
    parameter VMR_DATA_WTH = MR_PROC_H_PARAL * MR_PROC_V_PARAL * VMR_PROC_WTH,
    parameter MR_DSTROB_H_WTH = 8,
    parameter MR_DSTROB_V_WTH = 8
) (
    // clock & reset
    input                                   clk_i,
    input                                   rst_i,

    // from mpu_ctrl module
    input [MRB_IND_WTH-1 : 0]               mpu_mrb__rindex_i,
    input [MRB_ADDR_WTH-1 : 0]              mpu_mrb__raddr_i,
    input                                   mpu_mrb__re_i,
    input [0 : 0]                           mpu_mrb__type_i,

    // to mpu module
    output[MR_DATA_WTH-1 : 0]               mpu_mrb__rdata_o,
    output                                  mpu_mrb__rdata_act_o,

    output[VMR_DATA_WTH-1 : 0]              mpu_mrb__vmode_rdata_o,
    output                                  mpu_mrb__vmode_rdata_act_o,

    // from load_mtxreg_ctrl module
    input [MRB_IND_WTH-1 : 0]               ldmr_mrb__windex_i,
    input [MRB_ADDR_WTH-1 : 0]              ldmr_mrb__waddr_i,
    input                                   ldmr_mrb__we_i,

    // from ddr_intf module
    input [MR_DATA_WTH-1 : 0]               ldmr_mrb__wdata_i,
    input                                   ldmr_mrb__wdata_act_i
);

//======================================================================================================================
// Wire & Reg declaration
//======================================================================================================================
localparam MR_PROC_N_PARAL = 8;

localparam TOT_DLY = 3;
localparam MRB_DLY = 2;

wire  [MR_PROC_N_PARAL-1 : 0]           ldmr_mrb_windex_onehot;
wire  [MR_PROC_N_PARAL-1 : 0]           mpu_mrb_rindex_onehot;
wire                                    mrb_we[0 : MR_PROC_N_PARAL-1];
wire  [MRB_ADDR_WTH-1 : 0]              mrb_waddr[0 : MR_PROC_N_PARAL-1];
wire  [MR_DATA_WTH-1 : 0]               mrb_wdata[0 : MR_PROC_N_PARAL-1];
wire  [MR_DSTROB_H_WTH-1 : 0]           mrb_wdata_strob_h[0 : MR_PROC_N_PARAL-1];
wire  [MR_DSTROB_V_WTH-1 : 0]           mrb_wdata_strob_v[0 : MR_PROC_N_PARAL-1];
wire                                    mrb_re[0 : MR_PROC_N_PARAL-1];
wire  [MRB_ADDR_WTH-1 : 0]              mrb_raddr[0 : MR_PROC_N_PARAL-1];

reg                                     mrb_we_r[0 : MR_PROC_N_PARAL-1];
reg   [MRB_ADDR_WTH-1 : 0]              mrb_waddr_r[0 : MR_PROC_N_PARAL-1];
reg   [MR_DATA_WTH-1 : 0]               mrb_wdata_r[0 : MR_PROC_N_PARAL-1];
reg   [MR_DSTROB_H_WTH-1 : 0]           mrb_wdata_strob_h_r[0 : MR_PROC_N_PARAL-1];
reg   [MR_DSTROB_V_WTH-1 : 0]           mrb_wdata_strob_v_r[0 : MR_PROC_N_PARAL-1];
reg                                     mrb_re_r[0 : MR_PROC_N_PARAL-1];
reg   [MRB_ADDR_WTH-1 : 0]              mrb_raddr_r[0 : MR_PROC_N_PARAL-1];

wire  [MR_DATA_WTH-1 : 0]               mrb_rdata[0 : MR_PROC_N_PARAL-1];

reg   [MRB_IND_WTH*(MRB_DLY+1)-1 : 0]   mpu_mrb_rindex_dlychain;

reg   [MR_DATA_WTH-1 : 0]               mpu_mrb_rdata;
reg   [VMR_DATA_WTH-1 : 0]              vmode_rdata;

reg   [TOT_DLY : 0]                     mpu_mrb_re_dlychain;

genvar gi;
integer i;

//======================================================================================================================
// Instance
//======================================================================================================================

dec_bin_to_onehot #(3, 8) ldmr_mrb_windex_inst (ldmr_mrb__windex_i, ldmr_mrb_windex_onehot);
dec_bin_to_onehot #(3, 8) mpu_mrb_rindex_inst (mpu_mrb__rindex_i, mpu_mrb_rindex_onehot);

generate
    for (gi = 0; gi < MR_PROC_N_PARAL; gi = gi+1) begin : mrb
        assign mrb_we[gi] = ldmr_mrb__we_i & ldmr_mrb_windex_onehot[gi];
        assign mrb_waddr[gi] = ldmr_mrb__waddr_i;
        assign mrb_wdata[gi] = ldmr_mrb__wdata_i;
        assign mrb_wdata_strob_h[gi] = 8'hff;
        assign mrb_wdata_strob_v[gi] = 8'hff;
        assign mrb_re[gi] = mpu_mrb__re_i & mpu_mrb_rindex_onehot[gi];
        assign mrb_raddr[gi] = mpu_mrb__raddr_i;

        always @(posedge clk_i) begin
            mrb_we_r[gi] <= mrb_we[gi];
            mrb_waddr_r[gi] <= mrb_waddr[gi];
            mrb_wdata_r[gi] <= mrb_wdata[gi];
            mrb_wdata_strob_h_r[gi] <= mrb_wdata_strob_h[gi];
            mrb_wdata_strob_v_r[gi] <= mrb_wdata_strob_v[gi];
            mrb_re_r[gi] <= mpu_mrb__type_i ? {MR_PROC_H_PARAL{mpu_mrb__re_i}} : mrb_re[gi];
            mrb_raddr_r[gi] <= mpu_mrb__type_i ? mpu_mrb__raddr_i : mrb_raddr[gi];
        end

        sdp_w512x64_r512x64_wrap mtxregb[MR_PROC_H_PARAL-1 : 0] (
            .wr_clk_i                       ({MR_PROC_H_PARAL{clk_i}}),
            .we_i                           ({MR_PROC_H_PARAL{mrb_we_r[gi]}} & mrb_wdata_strob_h_r[gi]),
            .waddr_i                        ({MR_PROC_H_PARAL{mrb_waddr_r[gi]}}),
            .wdata_i                        (mrb_wdata_r[gi]),
            .wdata_strob_i                  ({MR_PROC_H_PARAL{mrb_wdata_strob_v_r[gi]}}),
            .rd_clk_i                       ({MR_PROC_H_PARAL{clk_i}}),
            .re_i                           ({MR_PROC_H_PARAL{mrb_re_r[gi]}}),
            .raddr_i                        ({MR_PROC_H_PARAL{mrb_raddr_r[gi]}}),
            .rdata_o                        (mrb_rdata[gi])
        );
    end
endgenerate

always @(posedge clk_i) begin
    mpu_mrb_rindex_dlychain <= {mpu_mrb_rindex_dlychain[MRB_IND_WTH*MRB_DLY-1 : 0], mpu_mrb__rindex_i};
end

always @(posedge clk_i) begin
    mpu_mrb_rdata <= mrb_rdata[mpu_mrb_rindex_dlychain[MRB_IND_WTH*MRB_DLY +: MRB_IND_WTH]];
end
assign mpu_mrb__rdata_o = mpu_mrb_rdata;

always @(posedge clk_i) begin
    for(i=0; i<MR_PROC_N_PARAL; i=i+1) begin
        vmode_rdata[MR_DATA_WTH*i +: MR_DATA_WTH] <= mrb_rdata[i];
    end
end
assign mpu_mrb__vmode_rdata_o = vmode_rdata;

always @(posedge clk_i) begin
    if(rst_i) begin
        mpu_mrb_re_dlychain <= {(TOT_DLY+1){1'b0}};
    end else begin
        mpu_mrb_re_dlychain <= {mpu_mrb_re_dlychain[TOT_DLY-1:0], mpu_mrb__re_i};
    end
end
assign mpu_mrb__rdata_act_o = mpu_mrb_re_dlychain[TOT_DLY];
assign mpu_mrb__vmode_rdata_act_o = mpu_mrb_re_dlychain[TOT_DLY];

//======================================================================================================================
// just for simulation
//======================================================================================================================
// synthesis translate_off

// synthesis translate_on

//======================================================================================================================
// probe signals
//======================================================================================================================

endmodule   
