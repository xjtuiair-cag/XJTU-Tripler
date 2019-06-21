// +FHDR------------------------------------------------------------------------
// XJTU IAIR Corporation All Rights Reserved
// -----------------------------------------------------------------------------
// FILE NAME  : rst_gen.v
// DEPARTMENT : CAG of IAIR
// AUTHOR     : XXXX
// AUTHOR'S EMAIL :XXXX@mail.xjtu.edu.cn
// -----------------------------------------------------------------------------
// Ver 1.0  2019--01--01 initial version.
// -----------------------------------------------------------------------------
// KEYWORDS   : reset signals generating
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

module rst_gen(
    // clock & reset
    input                                   rst_i,
    input                                   clk_i,
    // internal reset signals
    input                                   clk_locked_i,
    input                                   c0_init_calib_complete_i,
    output                                  rst_o,
    output                                  rst_ddr_o
);

//======================================================================================================================
// Wire & Reg declaration
//======================================================================================================================

wire                                    asyn_rst_ddr;
reg   [1 : 0]                           rst_ddr_dlychain;
wire                                    asyn_rst;
reg   [1 : 0]                           rst_dlychain;

//======================================================================================================================
// Instance
//======================================================================================================================

// generate asynchronous mig reset signal
assign asyn_rst_ddr = rst_i | ~clk_locked_i;

// synchronous mig reset signal
always @(posedge clk_i or posedge asyn_rst_ddr) begin
    if(asyn_rst_ddr) begin
        rst_ddr_dlychain <= 2'h3;
    end else begin
        rst_ddr_dlychain <= rst_ddr_dlychain << 1;
    end
end
assign rst_ddr_o = rst_ddr_dlychain[1];

// generate hpu reset signal
assign asyn_rst = asyn_rst_ddr | ~c0_init_calib_complete_i;

always @(posedge clk_i or posedge asyn_rst) begin
    if(asyn_rst) begin
        rst_dlychain <= 2'h3;
    end else begin
        rst_dlychain <= rst_dlychain << 1;
    end
end
//assign rst_o = rst_dlychain[1];
BUFG glb_rst_inst (
    .O(rst_o),          // 1-bit output: Clock output
    .I(rst_dlychain[1]) // 1-bit input: Clock input
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
