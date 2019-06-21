// +FHDR------------------------------------------------------------------------
// XJTU IAIR Corporation All Rights Reserved
// -----------------------------------------------------------------------------
// FILE NAME  : mtrxregc.v
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

module mtxregc #(
    parameter MRC_IND_WTH = 1,
    parameter MRC_ADDR_WTH = 9,
    parameter MR_PROC_WTH = 8,
    parameter MR_PROC_H_PARAL = 8,
    parameter MR_PROC_V_PARAL = 8,
    parameter MTX_DATA_WTH = MR_PROC_WTH * MR_PROC_V_PARAL,
    parameter MR_DATA_WTH = MTX_DATA_WTH * MR_PROC_H_PARAL
) (
    // clock & reset
    input                                   clk_i,
    input                                   rst_i,

    // from vpu_tiny_ctrl module
    input [MRC_IND_WTH-1 : 0]               vputy_mrc__rindex_i,
    input [MRC_ADDR_WTH-1 : 0]              vputy_mrc__raddr_i,
    input                                   vputy_mrc__re_i,

    // to vpu_tiny module
    output[MR_DATA_WTH-1 : 0]               vputy_mrc__rdata_o,
    output                                  vputy_mrc__rdata_act_o,

    // from load_mtxreg_ctrl module
    input [MRC_IND_WTH-1 : 0]               ldmr_mrc__windex_i,
    input [MRC_ADDR_WTH-1 : 0]              ldmr_mrc__waddr_i,
    input                                   ldmr_mrc__we_i,

    // from ddr_intf module
    input [MR_DATA_WTH-1 : 0]               ldmr_mrc__wdata_i,
    input                                   ldmr_mrc__wdata_act_i
);

//======================================================================================================================
// Wire & Reg declaration
//======================================================================================================================
localparam MR_PROC_N_PARAL = 1; // The standard version sould be 2.

localparam TOT_DLY = 3;
localparam MRC_DLY = 2;

wire  [MR_PROC_N_PARAL-1 : 0]           ldmr_mrc_windex_onehot;
wire  [MR_PROC_N_PARAL-1 : 0]           vputy_mrc_rindex_onehot;

wire                                    mrc_we[0 : MR_PROC_N_PARAL-1];
wire  [MRC_ADDR_WTH-1 : 0]              mrc_waddr[0 : MR_PROC_N_PARAL-1];
wire  [MR_DATA_WTH-1 : 0]               mrc_wdata[0 : MR_PROC_N_PARAL-1];
wire                                    mrc_re[0 : MR_PROC_N_PARAL-1];
wire  [MRC_ADDR_WTH-1 : 0]              mrc_raddr[0 : MR_PROC_N_PARAL-1];

reg                                     mrc_we_r[0 : MR_PROC_N_PARAL-1];
reg   [MRC_ADDR_WTH-1 : 0]              mrc_waddr_r[0 : MR_PROC_N_PARAL-1];
reg   [MR_DATA_WTH-1 : 0]               mrc_wdata_r[0 : MR_PROC_N_PARAL-1];
reg                                     mrc_re_r[0 : MR_PROC_N_PARAL-1];
reg   [MRC_ADDR_WTH-1 : 0]              mrc_raddr_r[0 : MR_PROC_N_PARAL-1];

wire  [MR_DATA_WTH-1 : 0]               mrc_rdata[0 : MR_PROC_N_PARAL-1];

reg   [MRC_IND_WTH*(MRC_DLY+1)-1 : 0]   vputy_mrc_rindex_dlychain;
reg   [MR_DATA_WTH-1 : 0]               vputy_mrc_rdata;

reg   [TOT_DLY : 0]                     vputy_mrc_re_dlychain;

genvar gi;

//======================================================================================================================
// Instance
//======================================================================================================================

dec_bin_to_onehot #(1, 2) ldmr_mrc_windex_inst (ldmr_mrc__windex_i, ldmr_mrc_windex_onehot);
dec_bin_to_onehot #(1, 2) vputy_mrc_rindex_inst (vputy_mrc__rindex_i, vputy_mrc_rindex_onehot);

generate
    for(gi = 0; gi < MR_PROC_N_PARAL; gi = gi+1) begin: mrc
        assign mrc_we[gi] = ldmr_mrc__we_i & ldmr_mrc_windex_onehot[gi];
        assign mrc_waddr[gi] = ldmr_mrc__waddr_i;
        assign mrc_wdata[gi] = ldmr_mrc__wdata_i;
        assign mrc_re[gi] = vputy_mrc__re_i & vputy_mrc_rindex_onehot[gi];
        assign mrc_raddr[gi] = vputy_mrc__raddr_i;

        always @(posedge clk_i) begin
            mrc_we_r[gi] <= mrc_we[gi];
            mrc_waddr_r[gi] <= mrc_waddr[gi];
            mrc_wdata_r[gi] <= mrc_wdata[gi];
            mrc_re_r[gi] <= mrc_re[gi];
            mrc_raddr_r[gi] <= mrc_raddr[gi];
        end

        sdp_w512x64_r512x64_wrap mtxregc[MR_PROC_H_PARAL-1 : 0] (
            .wr_clk_i                       ({MR_PROC_H_PARAL{clk_i}}),
            .we_i                           ({MR_PROC_H_PARAL{mrc_we_r[gi]}}),
            .waddr_i                        ({MR_PROC_H_PARAL{mrc_waddr_r[gi]}}),
            .wdata_i                        (mrc_wdata_r[gi]),
            .wdata_strob_i                  ({MR_PROC_H_PARAL{8'hff}}),
            .rd_clk_i                       ({MR_PROC_H_PARAL{clk_i}}),
            .re_i                           ({MR_PROC_H_PARAL{mrc_re_r[gi]}}),
            .raddr_i                        ({MR_PROC_H_PARAL{mrc_raddr_r[gi]}}),
            .rdata_o                        (mrc_rdata[gi])
        );
    end
endgenerate

always @(posedge clk_i) begin
    vputy_mrc_rindex_dlychain <= {vputy_mrc_rindex_dlychain[MRC_IND_WTH*MRC_DLY-1 : 0], vputy_mrc__rindex_i};
end

always @(posedge clk_i) begin
    vputy_mrc_rdata <= mrc_rdata[vputy_mrc_rindex_dlychain[MRC_IND_WTH*MRC_DLY +: MRC_IND_WTH]];
end
assign vputy_mrc__rdata_o = vputy_mrc_rdata;

always @(posedge clk_i) begin
    if(rst_i) begin
        vputy_mrc_re_dlychain <= {(TOT_DLY+1){1'b0}};
    end else begin
        vputy_mrc_re_dlychain <= {vputy_mrc_re_dlychain[TOT_DLY-1:0], vputy_mrc__re_i};
    end
end
assign vputy_mrc__rdata_act_o = vputy_mrc_re_dlychain[TOT_DLY];

//======================================================================================================================
// just for simulation
//======================================================================================================================
// synthesis translate_off

// synthesis translate_on

//======================================================================================================================
// probe signals
//======================================================================================================================

endmodule   
