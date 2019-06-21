// +FHDR------------------------------------------------------------------------
// XJTU IAIR Corporation All Rights Reserved
// -----------------------------------------------------------------------------
// FILE NAME  : mtxreg_hub.v
// DEPARTMENT : CAG of IAIR
// AUTHOR     : XXXX
// AUTHOR'S EMAIL :XXXX@mail.xjtu.edu.cn
// -----------------------------------------------------------------------------
// Ver 1.0  2019--01--01 initial version.
// -----------------------------------------------------------------------------
// KEYWORDS   : interface, memory,
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

module mtxreg_hub #(
    parameter MR_PROC_WTH = 8,
    parameter MR_PROC_H_PARAL = 8,
    parameter MR_PROC_V_PARAL = 8,
    parameter MTX_DATA_WTH = MR_PROC_WTH * MR_PROC_V_PARAL,
    parameter MR_DATA_WTH = MTX_DATA_WTH * MR_PROC_H_PARAL,
    parameter BR_DATA_WTH = 64,
    parameter DDRIF_DATA_WTH = 512
) (
    // clock & reset
    input                                   clk_i,
    input                                   rst_i,

    // from load_mtxreg_ctrl module
    input [4 : 0]                           ldmr_mrx__sel_i,

    // from mtxrega module
    input [MR_DATA_WTH-1 : 0]               svmr_mra__rdata_i,
    input                                   svmr_mra__rdata_act_i,

    // to mtxrega module
    output[MR_DATA_WTH-1 : 0]               ldmr_mra__wdata_o,
    output                                  ldmr_mra__wdata_act_o,

    // to mtxregb module
    output[MR_DATA_WTH-1 : 0]               ldmr_mrb__wdata_o,
    output                                  ldmr_mrb__wdata_act_o,

    // to mtxregc module
    output[MR_DATA_WTH-1 : 0]               ldmr_mrc__wdata_o,
    output                                  ldmr_mrc__wdata_act_o,

    // to biasregb module
    output[BR_DATA_WTH-1 : 0]               ldmr_brb__wdata_o,
    output                                  ldmr_brb__wdata_act_o,

    // to biasregc module
    output[MR_DATA_WTH-1 : 0]               ldmr_brc__wdata_o,
    output                                  ldmr_brc__wdata_act_o,

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
reg   [DDRIF_DATA_WTH-1 : 0]        svmr_ddr_intf_wdata;
reg                                 sv_data_act;
reg   [MR_DATA_WTH-1 : 0]           ldmr_mra_wdata;
reg   [MR_DATA_WTH-1 : 0]           ldmr_mrb_wdata;
reg   [MR_DATA_WTH-1 : 0]           ldmr_mrc_wdata;
reg   [BR_DATA_WTH-1 : 0]           ldmr_brb_wdata;
reg   [MR_DATA_WTH-1 : 0]           ldmr_brc_wdata;
reg                                 ldmr_mra_wdata_act;
reg                                 ldmr_mrb_wdata_act;
reg                                 ldmr_mrc_wdata_act;
reg                                 ldmr_brb_wdata_act;
reg                                 ldmr_brc_wdata_act;

//======================================================================================================================
// Instance
//======================================================================================================================

//always @(posedge clk_i) begin
//    svmr_ddr_intf_wdata <= svmr_mra__rdata_i;
//end
assign svmr_ddrintf__wdata_o = svmr_mra__rdata_i;

//always @(posedge clk_i) begin
//    if(rst_i) begin
//        sv_data_act <= 1'b0;
//    end else begin
//        sv_data_act <= svmr_mra__rdata_act_i;
//    end
//end
assign svmr_ddrintf__wdata_act_o = svmr_mra__rdata_act_i;

always @(posedge clk_i) begin
    ldmr_mra_wdata <= ldmr_ddrintf__rdata_i;
    ldmr_mrb_wdata <= ldmr_ddrintf__rdata_i;
    ldmr_mrc_wdata <= ldmr_ddrintf__rdata_i;
    ldmr_brb_wdata <= ldmr_ddrintf__rdata_i[BR_DATA_WTH-1 : 0];
    ldmr_brc_wdata <= ldmr_ddrintf__rdata_i;
end
assign ldmr_mra__wdata_o = ldmr_mra_wdata;
assign ldmr_mrb__wdata_o = ldmr_mrb_wdata;
assign ldmr_mrc__wdata_o = ldmr_mrc_wdata;
assign ldmr_brb__wdata_o = ldmr_brb_wdata;
assign ldmr_brc__wdata_o = ldmr_brc_wdata;

always @(posedge clk_i) begin
    if(rst_i) begin
        ldmr_mra_wdata_act <= 1'b0;
        ldmr_mrb_wdata_act <= 1'b0;
        ldmr_mrc_wdata_act <= 1'b0;
        ldmr_brb_wdata_act <= 1'b0;
        ldmr_brc_wdata_act <= 1'b0;
    end else begin
        ldmr_mra_wdata_act <= ldmr_mrx__sel_i[0] & ldmr_ddrintf__rdata_act_i;
        ldmr_mrb_wdata_act <= ldmr_mrx__sel_i[1] & ldmr_ddrintf__rdata_act_i;
        ldmr_mrc_wdata_act <= ldmr_mrx__sel_i[2] & ldmr_ddrintf__rdata_act_i;
        ldmr_brb_wdata_act <= ldmr_mrx__sel_i[3] & ldmr_ddrintf__rdata_act_i;
        ldmr_brc_wdata_act <= ldmr_mrx__sel_i[4] & ldmr_ddrintf__rdata_act_i;
    end
end
assign ldmr_mra__wdata_act_o = ldmr_mra_wdata_act;
assign ldmr_mrb__wdata_act_o = ldmr_mrb_wdata_act;
assign ldmr_mrc__wdata_act_o = ldmr_mrc_wdata_act;
assign ldmr_brb__wdata_act_o = ldmr_brb_wdata_act;
assign ldmr_brc__wdata_act_o = ldmr_brc_wdata_act;

//======================================================================================================================
// just for simulation
//======================================================================================================================
// synthesis translate_off

// synthesis translate_on

//======================================================================================================================
// probe signals
//======================================================================================================================

endmodule   




