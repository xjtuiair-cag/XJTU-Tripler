// +FHDR------------------------------------------------------------------------
// XJTU IAIR Corporation All Rights Reserved
// -----------------------------------------------------------------------------
// FILE NAME  : dl_dtcm_ctrl.v
// DEPARTMENT : CAG of IAIR
// AUTHOR     : chenfei
// AUTHOR'S EMAIL :fei.chen@mail.xjtu.edu.cn
// -----------------------------------------------------------------------------
// Ver 1.0  2018--12--03
// -----------------------------------------------------------------------------
// KEYWORDS   : dl_dtcm_ctrl
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
`timescale  1ns/1ps
// +FHDR------------------------------------------------------------------------
// XJTU IAIR Corporation All Rights Reserved
// -----------------------------------------------------------------------------
// FILE NAME  : dl_dtcm_ctrl.v
// DEPARTMENT : CAG of IAIR
// AUTHOR     : chenfei
// AUTHOR'S EMAIL :fei.chen@mail.xjtu.edu.cn
// -----------------------------------------------------------------------------
// Ver 1.0  2019--02--20
// -----------------------------------------------------------------------------
// KEYWORDS   :dl_dtcm_ctrl
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
`timescale  1ns/1ps
`include "e203_defines.v"
module dl_dtcm_ctrl #(
    parameter ADDR_WIDTH = 32
    )


    (
    //clk and reset
    input                                   clk_i,
    input                                   rst_i,

    //from ps interface
    input [15:0]                            ps_rvram__addr_i,
    input [31:0]                            ps_rvram__din_i,
    input                                   ps_rvram__en_i,
    input                                   ps_rvram__we_i,      
    
    input                                   ps_dl_dtcm_indict_i,
    //to itcm external interface
    //to riscv
     //`ifdef E203_HAS_DTCM_EXTITF //{
     //////////////////////////////////////////////////////////////
     //////////////////////////////////////////////////////////////
     // External-agent ICB to DTCM
     //    * Bus cmd channel
     output                                 ext2dtcm_icb_cmd_valid_o,
     input                                  ext2dtcm_icb_cmd_ready_i,
     output  [ADDR_WIDTH-1:0]               ext2dtcm_icb_cmd_addr_o,
     output                                 ext2dtcm_icb_cmd_read_o,
     output  [`E203_XLEN-1:0]               ext2dtcm_icb_cmd_wdata_o,
     output  [`E203_XLEN/8-1:0]             ext2dtcm_icb_cmd_wmask_o,
     //
     //    * Bus RSP channel
     input                                  ext2dtcm_icb_rsp_valid_i,
     output                                 ext2dtcm_icb_rsp_ready_o,
     input                                  ext2dtcm_icb_rsp_err_i,
     input [`E203_XLEN-1:0]                 ext2dtcm_icb_rsp_rdata_i
     //endif//
 );
localparam DPU_REG14     = 16'd272;   // data for riscv
localparam DPU_REG15     = 16'd288;   // instrction for riscv
wire         fifo_full;
wire         fifo_empty;
wire         fifo_wr;
wire         fifo_rd;
wire  [31:0] fifo_dout;
wire         ps_dl_dtcm_indict;

reg   [ADDR_WIDTH-1:0]    ext2dtcm_icb_cmd_addr;


reg_dly #(.width( 1 ),.delaynum(3))  reg_dly_inst0  (.clk (clk_i)  ,.d(ps_dl_dtcm_indict_i )  ,.q(ps_dl_dtcm_indict    ) );

//assign  #0.1 ps_dl_dtcm_ready_o =  !fifo_full;
//assign  #0.1 fifo_wr  = ps_dl_dtcm_dv_i && ps_dl_dtcm_ready_o && ps_dl_dtcm_indict_i;
assign   fifo_wr  = ps_rvram__en_i && ps_rvram__we_i && (ps_rvram__addr_i[15:0] == DPU_REG14); // max 31

 fifo_64to32  fifo_32to32_inst0(// actual is 32 to 32
  .rst          (rst_i             ),//  input rst;  
  .wr_clk       (clk_i             ),//  input wr_clk;
  .rd_clk       (clk_i             ),//  input rd_clk;
  .din          (ps_rvram__din_i   ),//  input [31:0]din;
  .wr_en        (fifo_wr           ),//  input wr_en;
  .rd_en        (fifo_rd           ),//  input rd_en;
  .dout         (fifo_dout         ),//  output [31:0]dout;
  .full         (fifo_full         ),//  output full;
  .empty        (fifo_empty        ) //  output empty;
);                    

assign  ext2dtcm_icb_cmd_valid_o = !fifo_empty;
assign  fifo_rd = ext2dtcm_icb_cmd_valid_o && ext2dtcm_icb_cmd_ready_i;
assign  ext2dtcm_icb_cmd_wdata_o = fifo_dout;
assign  ext2dtcm_icb_cmd_read_o = 1'b0;
assign  ext2dtcm_icb_cmd_wmask_o =  {`E203_XLEN{1'b1}};
 
assign  ext2dtcm_icb_rsp_ready_o = 1'b1;
always @(posedge clk_i)begin
    if(rst_i)begin
       ext2dtcm_icb_cmd_addr <=   {ADDR_WIDTH{1'b0}};
    end
    else if(!ps_dl_dtcm_indict) begin  
       ext2dtcm_icb_cmd_addr <=   {ADDR_WIDTH{1'b0}};  
    end
    else if(fifo_rd)
       ext2dtcm_icb_cmd_addr <=  ext2dtcm_icb_cmd_addr + 4;
end
assign  ext2dtcm_icb_cmd_addr_o = ext2dtcm_icb_cmd_addr;
 endmodule
