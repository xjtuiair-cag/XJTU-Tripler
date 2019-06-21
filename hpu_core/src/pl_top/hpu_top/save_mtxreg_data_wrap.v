// +FHDR------------------------------------------------------------------------
// XJTU IAIR Corporation All Rights Reserved
// -----------------------------------------------------------------------------
// FILE NAME  : save_mtxreg_data_wrap.v
// DEPARTMENT : CAG of IAIR
// AUTHOR     : chenfei
// AUTHOR'S EMAIL :fei.chen@mail.xjtu.edu.cn
// -----------------------------------------------------------------------------
// Ver 1.0  2018--12--03
// -----------------------------------------------------------------------------
// KEYWORDS   : save_mtxreg_data_wrap    
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

module save_mtxreg_data_wrap #(
    parameter DDRIF_DATA_WTH = 512
) (
    // clock & reset
    input                                   clk_i,
    input                                   rst_i,
    // data fifo ctrl 
    input                                   mtxreg_data_we_i, 
    input [DDRIF_DATA_WTH-1:0]              svmr_ddrwrap__wdata_i,
     
    input                                   mtxreg_data_re_i, 
    output[DDRIF_DATA_WTH-1:0]              svmr_ddrintf__wdata_o,
    
    output                                  mtxreg_data_full_o,
    output                                  mtxreg_data_empty_o      
);

fifo_data  fifo_data_16x512_inst0 (
    .clk        (clk_i), 
    .srst       (rst_i), 
    .din        (svmr_ddrwrap__wdata_i), 
    .wr_en      (mtxreg_data_we_i), 
    .rd_en      (mtxreg_data_re_i), 
    .dout       (svmr_ddrintf__wdata_o), 
    .full       (                    ), 
    .prog_full  (mtxreg_data_full_o), 
    .empty      (mtxreg_data_empty_o)
);

endmodule
