// +FHDR------------------------------------------------------------------------
// XJTU IAIR Corporation All Rights Reserved
// -----------------------------------------------------------------------------
// FILE NAME  : biasregb.v
// DEPARTMENT : CAG of IAIR
// AUTHOR     : XXXX
// AUTHOR'S EMAIL :XXXX@mail.xjtu.edu.cn
// -----------------------------------------------------------------------------
// Ver 1.0  2019--01--01 initial version.
// -----------------------------------------------------------------------------
// KEYWORDS   : bias, memory,
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

module biasregb#(
    parameter BR_IND_WTH = 1,
    parameter BR_ADDR_WTH = 9,
    parameter BR_PROC_WTH = 8,
    parameter BR_DATA_WTH = 64
) (
    // clock & reset
    input                                   clk_i,
    input                                   rst_i,

    // from vpu_ctrl module
    input [BR_IND_WTH-1 : 0]                vpu_brb__rindex_i,
    input [BR_ADDR_WTH-1 : 0]               vpu_brb__raddr_i,
    input                                   vpu_brb__re_i,

    // to vpu module
    output[BR_DATA_WTH-1 : 0]               vpu_brb__rdata_o,
    output                                  vpu_brb__rdata_act_o,

    // from load_mtxreg_ctrl module
    input [BR_IND_WTH-1 : 0]                ldmr_brb__windex_i,
    input [BR_ADDR_WTH-1 : 0]               ldmr_brb__waddr_i,
    input                                   ldmr_brb__we_i,

    // from ddr_intf module
    input [BR_DATA_WTH-1 : 0]               ldmr_brb__wdata_i,
    input                                   ldmr_brb__wdata_act_i
);

//======================================================================================================================
// Wire & Reg declaration
//======================================================================================================================
localparam BR_PROC_N_PARAL = 1;
localparam BR_PROC_H_PARAL = 1;

localparam TOT_DLY = 3;

wire                                    br_we;
wire  [BR_ADDR_WTH-1 : 0]               br_waddr;
wire  [BR_DATA_WTH-1 : 0]               br_wdata;
wire                                    br_re;
wire  [BR_ADDR_WTH-1 : 0]               br_raddr;

reg                                     br_we_r;
reg   [BR_ADDR_WTH-1 : 0]               br_waddr_r;
reg   [BR_DATA_WTH-1 : 0]               br_wdata_r;
reg                                     br_re_r;
reg   [BR_ADDR_WTH-1 : 0]               br_raddr_r;

wire  [BR_DATA_WTH-1 : 0]               br_rdata;
reg   [BR_DATA_WTH-1 : 0]               vpu_br_rdata;
reg   [TOT_DLY : 0]                     vpu_br_re_dlychain;

//======================================================================================================================
// Instance
//======================================================================================================================

assign br_we = ldmr_brb__we_i;
assign br_waddr = ldmr_brb__waddr_i;
assign br_wdata = ldmr_brb__wdata_i;
assign br_re = vpu_brb__re_i;
assign br_raddr = vpu_brb__raddr_i;

always @(posedge clk_i) begin
    br_we_r <= br_we;
    br_waddr_r <= br_waddr;
    br_wdata_r <= br_wdata;
    br_re_r <= br_re;
    br_raddr_r <= br_raddr;
end

sdp_w512x64_r512x64_wrap biasregb[BR_PROC_H_PARAL-1 : 0] (
    .wr_clk_i                       ({BR_PROC_H_PARAL{clk_i}}),
    .we_i                           ({BR_PROC_H_PARAL{br_we_r}}),
    .waddr_i                        ({BR_PROC_H_PARAL{br_waddr_r}}),
    .wdata_i                        (br_wdata_r),
    .wdata_strob_i                  ({BR_PROC_H_PARAL{8'hff}}),
    .rd_clk_i                       ({BR_PROC_H_PARAL{clk_i}}),
    .re_i                           ({BR_PROC_H_PARAL{br_re_r}}),
    .raddr_i                        ({BR_PROC_H_PARAL{br_raddr_r}}),
    .rdata_o                        (br_rdata)
);

always @(posedge clk_i) begin
    vpu_br_rdata <= br_rdata;
end
assign vpu_brb__rdata_o = vpu_br_rdata;

always @(posedge clk_i) begin
    if(rst_i) begin
        vpu_br_re_dlychain <= {(TOT_DLY+1){1'b0}};
    end else begin
        vpu_br_re_dlychain <= {vpu_br_re_dlychain[TOT_DLY-1 : 0], vpu_brb__re_i};
    end
end
assign vpu_brb__rdata_act_o = vpu_br_re_dlychain[TOT_DLY];

//======================================================================================================================
// just for simulation
//======================================================================================================================
// synthesis translate_off

// synthesis translate_on

//======================================================================================================================
// probe signals
//======================================================================================================================

endmodule   
