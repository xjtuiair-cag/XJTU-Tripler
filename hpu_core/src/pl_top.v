// +FHDR------------------------------------------------------------------------
// XJTU IAIR Corporation All Rights Reserved
// -----------------------------------------------------------------------------
// FILE NAME  : pl_top.v
// DEPARTMENT : CAG of IAIR
// AUTHOR     : XXXX
// AUTHOR'S EMAIL :XXXX@mail.xjtu.edu.cn
// -----------------------------------------------------------------------------
// Ver 1.0  2019--01--01 initial version.
// -----------------------------------------------------------------------------
// KEYWORDS   : the top module of PL side
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
`include "e203_defines.v"


`define USE_PICORV32
`include "picorv_defines.v"



module pl_top (
    // clock & reset
    input                                   rst_n,
    input                                   clk_100m,
    
    // from ps to downlaod instructions and risdv data
    input [11:0]                            ps_rvram__addr_i,
    input [31:0]                            ps_rvram__din_i,
    output[31:0]                            ps_rvram__dout_o,
    input                                   ps_rvram__en_i,
    input                                   ps_rvram__rst_i,
    input                                   ps_rvram__we_i,

   output     [28:0]  axi_ddr_araddr               , // [48:0] -> [28:0]
   input              axi_ddr_arready              ,
   output             axi_ddr_arvalid              ,
   output     [28:0]  axi_ddr_awaddr               , // [48:0] -> [28:0]
   input              axi_ddr_awready              ,
   output             axi_ddr_awvalid              , 
   input    [127:0]   axi_ddr_rdata                ,
   input    [5:0]     axi_ddr_rid                  ,
   input              axi_ddr_rlast                ,
   output             axi_ddr_rready               ,
   input              axi_ddr_rvalid               ,
   output     [127:0] axi_ddr_wdata                ,   
   output             axi_ddr_wlast                ,
   input              axi_ddr_wready               ,
   output             axi_ddr_wvalid               ,
  
  
  output     [31:0]  ps_ddr_intf_base_addr_o       
    
    
);

//======================================================================================================================
// Wire & Reg declaration
//======================================================================================================================

// clock signal
wire                                    clk;
wire                                    clk_2x;
wire                                    clk_locked;

// reset signal

wire                                    rst;
wire                                    rst_ddr;

/* internal connection
 // External-agent ICB to ITCM
    //    * Bus cmd channel
wire                                 ext2itcm_icb_cmd_valid;
wire                                 ext2itcm_icb_cmd_ready;
wire  [`E203_ITCM_ADDR_WIDTH-1:0]    ext2itcm_icb_cmd_addr ;
wire                                 ext2itcm_icb_cmd_read ;
wire  [`E203_XLEN-1:0]               ext2itcm_icb_cmd_wdata;
wire  [`E203_XLEN/8-1:0]             ext2itcm_icb_cmd_wmask;
    //
    //     Bus RSP channel
wire                                 ext2itcm_icb_rsp_valid;
wire                                 ext2itcm_icb_rsp_ready;
wire                                 ext2itcm_icb_rsp_err  ;
wire[`E203_XLEN-1:0]                 ext2itcm_icb_rsp_rdata;
    //endif//
// internal connection
     // External-agent ICB to DTCM
        //     Bus cmd channel
wire                                 ext2dtcm_icb_cmd_valid;
wire                                 ext2dtcm_icb_cmd_ready;
wire  [`E203_ITCM_ADDR_WIDTH-1:0]    ext2dtcm_icb_cmd_addr ;
wire                                 ext2dtcm_icb_cmd_read ;
wire  [`E203_XLEN-1:0]               ext2dtcm_icb_cmd_wdata;
wire  [`E203_XLEN/8-1:0]             ext2dtcm_icb_cmd_wmask;
    //
    //     Bus RSP channel
wire                                 ext2dtcm_icb_rsp_valid;
wire                                 ext2dtcm_icb_rsp_ready;
wire                                 ext2dtcm_icb_rsp_err  ;
wire[`E203_XLEN-1:0]                 ext2dtcm_icb_rsp_rdata;
*/

/*pico start declaration */
    /* External access to ITCM/DTCM */
	/* itcm interface */
    wire            					ext2itcm_ram_valid  ;
    wire  [31:0]    					ext2itcm_ram_addr;
    wire  [`PICORV_ITCM_RAM_MW-1:0]    	ext2itcm_ram_wen ;
    wire  [`PICORV_ITCM_RAM_WW-1:0]   	ext2itcm_ram_wdata ;
    wire  [`PICORV_ITCM_RAM_WW-1:0]    	ext2itcm_ram_rdata;
    wire            					ext2itcm_ready;
    /* dtcm interface */
    wire            					ext2dtcm_ram_valid  ;
    wire  [31:0]    					ext2dtcm_ram_addr;
    wire  [`PICORV_DTCM_RAM_MW-1:0]    	ext2dtcm_ram_wen ;
    wire  [`PICORV_DTCM_RAM_WW-1:0]    	ext2dtcm_ram_wdata ;
    wire  [`PICORV_DTCM_RAM_WW-1:0]    	ext2dtcm_ram_rdata;
    wire            					ext2dtcm_ready;
    
    wire                                picorv_rst;               
    
    wire                                riscv_regmap__act;       // read or write   act  read have exist
    wire 								riscv_regmap__wdata_act; // write act 
    
    wire [7:0] 							riscv_regmap__intr_dly;  // change  riscv_regmap__intr level to rising pulse
    wire [7:0] 							riscv_regmap__intr_pls;  

/*pico end declaration */    
    
 wire  [12 : 0]                          riscv_regmap__waddr;
 wire                                    riscv_regmap__we;
 wire  [31 : 0]                          riscv_regmap__wdata;
wire  [12 : 0]                          riscv_regmap__raddr;
wire                                    riscv_regmap__re;
wire  [31 : 0]                          riscv_regmap__rdata;
wire                                    riscv_regmap__rdata_act;
 wire  [7 : 0]                           riscv_regmap__intr;





wire ps_ddr_data_ready_hputop_o = 0;

//chenfei add for test instrction fetch enable 20190219 begin
wire                                   ps_pl_fetch_en_i;

//chenfei add for test instrction fetch enable 20190219 end
// from PS controlling DMA to mcu_core
// interface from ps
// ...
wire                                   ps_riscv__start_conv_i;

 wire                                   ps_riscv__start_conv_i_pls;
wire                                   ps_riscv__start_conv_i_dly;

wire                                   fshflg_ps ;// 5
wire ps_dl_itcm_indict ;
wire ps_dl_dtcm_indict ;




/*pico start logic */
 assign picorv_rst               =   ps_pl_fetch_en_i;
assign riscv_regmap__wdata_act  =   riscv_regmap__we;
assign riscv_regmap__act        =   riscv_regmap__wdata_act || riscv_regmap__rdata_act;

reg_dly #(
    .width( 8 ),
    .delaynum(1)
) reg_dly_inst_intr (
    .clk (clk)  ,
    .d(riscv_regmap__intr       )  ,
    .q(riscv_regmap__intr_dly   ) 
);
// rising pls
assign riscv_regmap__intr_pls = (~riscv_regmap__intr_dly) & riscv_regmap__intr & 8'h03; // mask irq 2-7

picosoc riscv_top_inst(
        // clock & reset
        .clk                        (clk),
        .resetn                     (picorv_rst),
        .trap                       (),
        .ps_riscv__start_conv_i     (ps_riscv__start_conv_i_pls),
        .ext_itcm_ram_cs  			(ext2itcm_ram_valid 	),
		.ext_itcm_ram_addr			(ext2itcm_ram_addr		),
		.ext_itcm_ram_wen 			(ext2itcm_ram_wen 		),
		.ext_itcm_ram_wdata 		(ext2itcm_ram_wdata 	),
		.ext_itcm_ram_rdata			(ext2itcm_ram_rdata		),
		.ext_itcm_ready				(ext2itcm_ready			),
		.ext_dtcm_ram_cs  			(ext2dtcm_ram_valid  	),
		.ext_dtcm_ram_addr			(ext2dtcm_ram_addr		),
		.ext_dtcm_ram_wen 			(ext2dtcm_ram_wen 		),
		.ext_dtcm_ram_wdata 		(ext2dtcm_ram_wdata 	),
		.ext_dtcm_ram_rdata			(ext2dtcm_ram_rdata		),
		.ext_dtcm_ready				(ext2dtcm_ready			),
        
        // regmap interface: from mcu_core module
        .riscv_regmap__waddr_o                  (riscv_regmap__waddr),
        .riscv_regmap__we_o                     (riscv_regmap__we),
        .riscv_regmap__wdata_o                  (riscv_regmap__wdata),
        .riscv_regmap__raddr_o                  (riscv_regmap__raddr),
        .riscv_regmap__re_o                     (riscv_regmap__re),
        .riscv_regmap__rdata_i                  (riscv_regmap__rdata),
        .riscv_regmap__rdata_act_i              (riscv_regmap__act),
        .riscv_regmap__intr_i                   (riscv_regmap__intr_pls)
    );

/*
    dl_picorv_ram_ctrl dl_itcm_ctrl_inst0(
        //clk and reset
        .clk_i(clk ),
        .rst_i(rst   ),

        //from ps interface
        .ps_dl_data_i ({ps_ddr_data_i[31:0],ps_ddr_data_i[63:32] } ),
        .ps_dl_dv_i   (ps_ddr_data_valid_i),
        .ps_dl_dlast_i(ps_ddr_data_last_i ),
        .ps_dl_ready_o(ps_ddr_data_ready_itcm_o),

        .ps_dl_indict_i(ps_dl_itcm_indict_i),
        
        .ext2tcm_ram_valid (ext2itcm_ram_valid ), 
        .ext2tcm_ram_addr  (ext2itcm_ram_addr  ), 
        .ext2tcm_ram_wdata (ext2itcm_ram_wdata ),
        .ext2tcm_ram_wmask (ext2itcm_ram_wen   ),
        .ext2tcm_ram_ready (ext2itcm_ready ),
        .ext2tcm_ram_rdata (ext2itcm_ram_rdata )
    );
    */
    dl_itcm_ctrl dl_itcm_ctrl_inst0(
    //clk and reset
    .clk_i(clk ),
    .rst_i(rst   ),
    .ps_rvram__addr_i   ({4'b0,ps_rvram__addr_i }   ),
    .ps_rvram__din_i    (ps_rvram__din_i    )    ,
    .ps_rvram__en_i     (ps_rvram__en_i     )    ,
    .ps_rvram__we_i     (ps_rvram__we_i     )    ,      

    .ps_dl_itcm_indict_i       (ps_dl_itcm_indict              )    ,
    //to itcm external interface
    //to riscv
     //`ifdef E203_HAS_ITCM_EXTITF //{
     //////////////////////////////////////////////////////////////
     //////////////////////////////////////////////////////////////
     // External-agent ICB to ITCM
     //    * Bus cmd channel
     .ext2itcm_icb_cmd_valid_o(ext2itcm_ram_valid       ),
     .ext2itcm_icb_cmd_ready_i(1                        ),
     .ext2itcm_icb_cmd_addr_o (ext2itcm_ram_addr        ),
     .ext2itcm_icb_cmd_read_o (                         ),
     .ext2itcm_icb_cmd_wdata_o(ext2itcm_ram_wdata       ),
     .ext2itcm_icb_cmd_wmask_o(ext2itcm_ram_wen         ),
     //
     //    * Bus RSP channel
     .ext2itcm_icb_rsp_valid_i(0                    ),
     .ext2itcm_icb_rsp_ready_o(                     ),
     .ext2itcm_icb_rsp_err_i  (0                    ),
     .ext2itcm_icb_rsp_rdata_i(ext2itcm_ram_rdata  )
     //endif//
 );

 
 
 /*
    dl_picorv_ram_ctrl dl_dtcm_ctrl_inst0(
        //clk and reset
        .clk_i(clk ),
        .rst_i(rst   ),

        //from ps interface
        .ps_dl_data_i ({ps_ddr_data_i[31:0],ps_ddr_data_i[63:32] }      ),
        .ps_dl_dv_i   (ps_ddr_data_valid_i),
        .ps_dl_dlast_i(ps_ddr_data_last_i ),
        .ps_dl_ready_o(ps_ddr_data_ready_dtcm_o),

        .ps_dl_indict_i(ps_dl_dtcm_indict_i),
        
        .ext2tcm_ram_valid (ext2dtcm_ram_valid ), 
        .ext2tcm_ram_addr  (ext2dtcm_ram_addr  ), 
        .ext2tcm_ram_wdata (ext2dtcm_ram_wdata ),
        .ext2tcm_ram_wmask (ext2dtcm_ram_wen ),
        .ext2tcm_ram_ready (ext2dtcm_ready ),
        .ext2tcm_ram_rdata (ext2dtcm_ram_rdata )
    );
*/


dl_dtcm_ctrl dl_dtcm_ctrl_inst0(
    //clk and reset
    .clk_i(clk ),
    .rst_i(rst   ),

    //from ps interface
    .ps_rvram__addr_i   ({4'b0,ps_rvram__addr_i }),
    .ps_rvram__din_i    (ps_rvram__din_i    )    ,
    .ps_rvram__en_i     (ps_rvram__en_i     )    ,
    .ps_rvram__we_i     (ps_rvram__we_i     )    ,  
    
    .ps_dl_dtcm_indict_i       (ps_dl_dtcm_indict              )    ,
    //to itcm external interface
    //to riscv
     //`ifdef E203_HAS_DTCM_EXTITF //{
     //////////////////////////////////////////////////////////////
     //////////////////////////////////////////////////////////////
     // External-agent ICB to DTCM
     //    * Bus cmd channel
     .ext2dtcm_icb_cmd_valid_o(ext2dtcm_ram_valid   ),
     .ext2dtcm_icb_cmd_ready_i(1       ),
     .ext2dtcm_icb_cmd_addr_o (ext2dtcm_ram_addr    ),
     .ext2dtcm_icb_cmd_read_o (                    ),
     .ext2dtcm_icb_cmd_wdata_o(ext2dtcm_ram_wdata   ),
     .ext2dtcm_icb_cmd_wmask_o(ext2dtcm_ram_wen     ),
     //                                                              
     //    * Bus RSP channel                                         
     .ext2dtcm_icb_rsp_valid_i(0                    ),
     .ext2dtcm_icb_rsp_ready_o(                     ),
     .ext2dtcm_icb_rsp_err_i  (0                    ),
     .ext2dtcm_icb_rsp_rdata_i(ext2dtcm_ram_rdata   )
     //endif//
 );

/*pico endlogic */    
    
//======================================================================================================================
// Instance
//======================================================================================================================

clk_gen clk_gen_inst (
    // clock signal of chip
    .clk_in1                                (clk_100m),
    // output clock signal
    .clk_o                                  (clk),
    .clk_2x_o                               (clk_2x),
    // lock signal
    .locked_o                               (clk_locked)
);

rst_gen rst_gen_inst (
    // reset signal of chip
    .rst_i                                  (!rst_n),
    .clk_i                                  (clk),
    // internal reset signals
    .clk_locked_i                           (clk_locked),
    .c0_init_calib_complete_i               (1'b1),
    .rst_o                                  (rst),
    .rst_ddr_o                              (   )
);
/*
riscv_top riscv_top_inst(
    // clock & reset
    .clk_i                                  (clk),
    .rst_i                                  (rst),

    // interface to ps
    // ...
    .ps_riscv__start_conv_i                 (ps_riscv__start_conv_i_pls),
     //chenfei add for test instrction fetch enable 20190219 begin
    .ps_pl_fetch_en_i                       (ps_pl_fetch_en_i      ),
    //chenfei add for test instrction fetch enable 20190219 end
    //`ifdef E203_HAS_ITCM_EXTITF //{
     //////////////////////////////////////////////////////////////
     //////////////////////////////////////////////////////////////
     // External-agent ICB to ITCM
     //    * Bus cmd channel
     .ext2itcm_icb_cmd_valid_i(ext2itcm_icb_cmd_valid  ),
     .ext2itcm_icb_cmd_ready_o(ext2itcm_icb_cmd_ready  ),
     .ext2itcm_icb_cmd_addr_i (ext2itcm_icb_cmd_addr   ),
     .ext2itcm_icb_cmd_read_i (ext2itcm_icb_cmd_read   ),
     .ext2itcm_icb_cmd_wdata_i(ext2itcm_icb_cmd_wdata  ),
     .ext2itcm_icb_cmd_wmask_i(ext2itcm_icb_cmd_wmask  ),
     //
     //    * Bus RSP channel
     .ext2itcm_icb_rsp_valid_o(ext2itcm_icb_rsp_valid  ),
     .ext2itcm_icb_rsp_ready_i(ext2itcm_icb_rsp_ready  ),
     .ext2itcm_icb_rsp_err_o  (ext2itcm_icb_rsp_err    ),
     .ext2itcm_icb_rsp_rdata_o(ext2itcm_icb_rsp_rdata  ),
     //endif//
     //to itcm external interface
     //to riscv
      //`ifdef E203_HAS_DTCM_EXTITF //{
      //////////////////////////////////////////////////////////////
      //////////////////////////////////////////////////////////////
      // External-agent ICB to DTCM
      //    * Bus cmd channel
      .ext2dtcm_icb_cmd_valid_i(ext2dtcm_icb_cmd_valid  ),
      .ext2dtcm_icb_cmd_ready_o(ext2dtcm_icb_cmd_ready  ),
      .ext2dtcm_icb_cmd_addr_i (ext2dtcm_icb_cmd_addr   ),
      .ext2dtcm_icb_cmd_read_i (ext2dtcm_icb_cmd_read   ),
      .ext2dtcm_icb_cmd_wdata_i(ext2dtcm_icb_cmd_wdata  ),
      .ext2dtcm_icb_cmd_wmask_i(ext2dtcm_icb_cmd_wmask  ),
      //                                                              
      //    * Bus RSP channel                                         
      .ext2dtcm_icb_rsp_valid_o(ext2dtcm_icb_rsp_valid ),
      .ext2dtcm_icb_rsp_ready_i(ext2dtcm_icb_rsp_ready ), // 
      .ext2dtcm_icb_rsp_err_o  (ext2dtcm_icb_rsp_err   ),
      .ext2dtcm_icb_rsp_rdata_o(ext2dtcm_icb_rsp_rdata ),
      //endif//
     
     
    // regmap interface: from mcu_core module
    .riscv_regmap__waddr_o                  (riscv_regmap__waddr),
    .riscv_regmap__we_o                     (riscv_regmap__we),
    .riscv_regmap__wdata_o                  (riscv_regmap__wdata),
    .riscv_regmap__raddr_o                  (riscv_regmap__raddr),
    .riscv_regmap__re_o                     (riscv_regmap__re),
    .riscv_regmap__rdata_i                  (riscv_regmap__rdata),
    .riscv_regmap__rdata_act_i              (riscv_regmap__rdata_act),
    .riscv_regmap__intr_i                   (riscv_regmap__intr)
);
*/

wire ps_ddr_data_valid_i;
assign  ps_ddr_data_valid_i =  0;


hpu_top hpu_top_inst (
    // clock & reset
    .clk_i                                  (clk),
    .clk_2x_i                               (clk_2x),
    .rst_i                                  (rst),

    // from riscv_top to regmap
    .riscv_regmap__waddr_i                  (riscv_regmap__waddr),
    .riscv_regmap__we_i                     (riscv_regmap__we),
    .riscv_regmap__wdata_i                  (riscv_regmap__wdata),
    .riscv_regmap__raddr_i                  (riscv_regmap__raddr),
    .riscv_regmap__re_i                     (riscv_regmap__re),
    .riscv_regmap__rdata_o                  (riscv_regmap__rdata),
    .riscv_regmap__rdata_act_o              (riscv_regmap__rdata_act),
    .riscv_regmap__intr_o                   (riscv_regmap__intr),
   

    .fshflg_ps_o                            (fshflg_ps),

    .axi_ddr_araddr       (axi_ddr_araddr     ),
  .axi_ddr_arready      (axi_ddr_arready    ),
  .axi_ddr_arvalid      (axi_ddr_arvalid    ),
  .axi_ddr_awaddr       (axi_ddr_awaddr     ),
  .axi_ddr_awready      (axi_ddr_awready    ),
  .axi_ddr_awvalid      (axi_ddr_awvalid    ),
  .axi_ddr_rdata        (axi_ddr_rdata      ),
  .axi_ddr_rid          (axi_ddr_rid        ),
  .axi_ddr_rlast        (axi_ddr_rlast      ),
  .axi_ddr_rready       (axi_ddr_rready     ),
  .axi_ddr_rvalid       (axi_ddr_rvalid     ),
  .axi_ddr_wdata        (axi_ddr_wdata      ),
  .axi_ddr_wlast        (axi_ddr_wlast      ),
  .axi_ddr_wready       (axi_ddr_wready     ),
  .axi_ddr_wvalid       (axi_ddr_wvalid     )
);

pl_regs  pl_regs_inst0(
.clk_i                     (clk    )    ,
.rst_i                     (rst    )    ,
.ps_rvram__addr_i          ({4'b0,ps_rvram__addr_i }   )    ,
.ps_rvram__din_i           (ps_rvram__din_i     )    ,
.ps_rvram__dout_o          (ps_rvram__dout_o    )    ,
.ps_rvram__en_i            (ps_rvram__en_i      )    ,
.ps_rvram__rst_i           (ps_rvram__rst_i     )    ,
.ps_rvram__we_i            (ps_rvram__we_i      )    ,
.ps_riscv__start_conv_o    (ps_riscv__start_conv_i        )    ,
.ps_pl_fetch_en_o          (ps_pl_fetch_en_i              )    ,
.ps_dl_itcm_indict_o       (ps_dl_itcm_indict              )    ,
.ps_dl_dtcm_indict_o       (ps_dl_dtcm_indict              )    ,


.Res_regs0                 (ps_riscv__start_conv_i    )    ,
.Res_regs1                 (ps_ddr_intf_base_addr_o    )    ,
.Res_regs2                 (32'd0   )    ,
.Res_regs3                 (    )    ,
.Res_regs4                 (    )    ,
.Res_regs5                 (    )    ,
.Res_regs6                 (    )    ,
.Res_regs7                 (    )    ,
.ps_ddr_intf_base_addr_o   (ps_ddr_intf_base_addr_o),
.fshflg_ps_i                (fshflg_ps)           
 );

   
reg_dly #(.width( 1 ),.delaynum(1))  reg_dly_inst0  (.clk (clk)  ,.d(ps_riscv__start_conv_i)  ,.q(ps_riscv__start_conv_i_dly  ) );
assign ps_riscv__start_conv_i_pls = (!ps_riscv__start_conv_i_dly)&& ps_riscv__start_conv_i;


//======================================================================================================================
// just for simulation
//======================================================================================================================
// synthesis translate_off

// synthesis translate_on

//======================================================================================================================
// probe signals
//======================================================================================================================
//wire  [31:0]  ps2pl_packet_cnt; 
//wire  [31:0]  ps2pl_byte_cnt  ; 
//wire  [31:0]  pl2ps_packet_cnt;
//wire  [31:0]  pl2ps_byte_cnt  ;


//axi_cnt s2c0
//(
// .rst_b     (!rst      ),   
// .sys_clk   (clk       ),
// .last      (         ),
// .valid     (ps_ddr_data_valid_i        ),
// .ready     (ps_ddr_data_ready_hputop_o ),
// .packet_cnt(ps2pl_packet_cnt      ),
// .byte_cnt  (ps2pl_byte_cnt        )
//);

//axi_cnt c2s0
//(
// .rst_b     (!rst                  ),
// .sys_clk   (clk                   ),
// .last      (       ),
// .valid     (      ),
// .ready     (      ),
// .packet_cnt(pl2ps_packet_cnt        ),
// .byte_cnt  (pl2ps_byte_cnt          )
//);

//vio_0  VIO_0_U0
//(
//.clk        (clk              ) , 
//.probe_in0  (ps2pl_packet_cnt   ) , 
//.probe_in1  (ps2pl_byte_cnt     ) , 
//.probe_in2  (pl2ps_packet_cnt   ) , 
//.probe_in3  (pl2ps_byte_cnt     ) , 
//.probe_in4  (32'h20190226       ) 
//);


endmodule
