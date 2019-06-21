// +FHDR------------------------------------------------------------------------
// XJTU IAIR Corporation All Rights Reserved
// -----------------------------------------------------------------------------
// FILE NAME  : dec_bin_to_onehot.v
// DEPARTMENT : CAG of IAIR
// AUTHOR     : XXXX
// AUTHOR'S EMAIL :XXXX@mail.xjtu.edu.cn
// -----------------------------------------------------------------------------
// Ver 1.0  2019--01--01 initial version.
// -----------------------------------------------------------------------------
// KEYWORDS   : db2o,
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

module dec_bin_to_onehot #(
    parameter BIN_WTH = 3,
    parameter OHOT_WTH = 8
) (
    input [BIN_WTH-1 : 0]               data_i,
    output[OHOT_WTH-1 : 0]              data_o
);

//=============================================================================
// variables declaration
//=============================================================================
genvar gi;

//=============================================================================
// instance
//=============================================================================
generate
    for (gi = 0; gi < OHOT_WTH; gi = gi+1) begin
        assign data_o[gi] = (data_i == gi) ? 1'b1 : 1'b0;
    end
endgenerate

endmodule

