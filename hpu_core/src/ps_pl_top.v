// +FHDR------------------------------------------------------------------------
// XJTU IAIR Corporation All Rights Reserved
// -----------------------------------------------------------------------------
// FILE NAME  : ps_pl_top.v
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
module ps_pl_top (
    output [3:0]                            status
);


parameter [5:0]  DDR_AXI_ID = 6'b00_1010;

parameter  PS_RVRAM_DW    =     32  ;
parameter  PS_RVRAM_AW    =     12  ;
parameter  PS_RVRAM_EW    =     4   ; 

/*zbr add 2019/4/12*/

wire             clk_100m                  ;  // clock and rst_n from ps
wire             rst_n                     ;

wire [PS_RVRAM_AW-1:0]  ps_rvram_addr      ;  // bram write and read port for   1   riscv instructions 2 riscv data 3 base ddr addrss 4   start signal
wire [PS_RVRAM_DW-1:0]  ps_rvram_din       ;
wire [PS_RVRAM_DW-1:0]  ps_rvram_dout      ;
wire                    ps_rvram_en        ;
wire                    ps_rvram_rst       ;
wire [PS_RVRAM_EW-1:0]  ps_rvram_we        ;


//assign    ps_rvram_dout[PS_RVRAM_DW-1:32] = {(PS_RVRAM_DW-32){1'b0}};

                                                //ddr interface for pl -> zynq HP0
wire    [28:0]  axi_ddr_araddr               ; // [48:0] -> [28:0]
wire            axi_ddr_arready              ;
wire            axi_ddr_arvalid              ;
wire    [28:0]  axi_ddr_awaddr               ; // [48:0] -> [28:0]
wire            axi_ddr_awready              ;
wire            axi_ddr_awvalid              ; 
wire  [127:0]   axi_ddr_rdata                ;
wire  [5:0]     axi_ddr_rid                  ;
wire            axi_ddr_rlast                ;
wire            axi_ddr_rready               ;
wire            axi_ddr_rvalid               ;
wire    [127:0] axi_ddr_wdata                ;   
wire            axi_ddr_wlast                ;
wire            axi_ddr_wready               ;
wire            axi_ddr_wvalid               ;  


wire  [31:0]    ps_ddr_intf_base_addr       ;
                 
assign          status[3:0]         =   4'd0; 


pl_top pl_top_inst(
    // clock & reset
    .rst_n                                  ( rst_n      ),
    .clk_100m                               (clk_100m    ),
    

     // from ps to downlaod instructions and risdv data
    .ps_rvram__addr_i                       (ps_rvram_addr[11:0]    ), //input [11:0]
    .ps_rvram__din_i                        (ps_rvram_din [31:0]    ), //input [31:0]
    .ps_rvram__dout_o                       (ps_rvram_dout[31:0]    ), //output[31:0]
    .ps_rvram__en_i                         (ps_rvram_en            ), //input
    .ps_rvram__rst_i                        (ps_rvram_rst           ), //input
    .ps_rvram__we_i                         ((|ps_rvram_we)         ), //input [3:0]

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
    .axi_ddr_wvalid       (axi_ddr_wvalid     ),
    
    
    .ps_ddr_intf_base_addr_o (ps_ddr_intf_base_addr)  // just use [28:0] total [31:0]
    
);


ps_block_wrapper ps_block_wrapper_inst0
   (
    .axi_ddr_araddr               ( {17'd0,axi_ddr_araddr[28:0]  + ps_ddr_intf_base_addr[31:0]}  ),//  [31:0] -> [48:0]  = 17
    .axi_ddr_arburst              (2'd1                                             ),
    .axi_ddr_arcache              (4'd0                                             ),
    .axi_ddr_arid                 (DDR_AXI_ID                                       ),
    .axi_ddr_arlen                (8'd3                                             ),  // 11 -> 3    +1     -> 4 tras 
    .axi_ddr_arlock               (1'b0                                             ),
    .axi_ddr_arprot               (3'd0                                             ),
    .axi_ddr_arqos                (4'd0                                             ),
    .axi_ddr_arready              (axi_ddr_arready                                  ),
    .axi_ddr_arsize               (3'd4                                             ),  // 100 -> 16 bytes = 128 bit
    .axi_ddr_aruser               (1'b0                                             ),
    .axi_ddr_arvalid              (axi_ddr_arvalid                                  ),// 1 axi_ddr_arvalid
    
    .axi_ddr_awaddr               ({17'd0,axi_ddr_awaddr[28:0] + ps_ddr_intf_base_addr[31:0] } ), // [31:0] -> [48:0] = 17
    .axi_ddr_awburst              (2'd1                                            ),
    .axi_ddr_awcache              (4'd0                                            ),
    .axi_ddr_awid                 (DDR_AXI_ID                                      ),
    .axi_ddr_awlen                (8'd3                                            ),   // 11 -> 3    +1     -> 4 tras 
    .axi_ddr_awlock               (1'b0                                            ),
    .axi_ddr_awprot               (3'd0                                            ),
    .axi_ddr_awqos                (4'd0                                            ),
    .axi_ddr_awready              (axi_ddr_awready                                 ),
    .axi_ddr_awsize               (3'd4                                            ),   // 100 -> 16 bytes = 128 bit
    .axi_ddr_awuser               (1'b0                                            ),
    .axi_ddr_awvalid              (axi_ddr_awvalid                                 ),//2  axi_ddr_awvalid
    
    .axi_ddr_bid                  (                                                ),
    .axi_ddr_bready               (1                                               ),
    .axi_ddr_bresp                (                                                ),
    .axi_ddr_bvalid               (                                                ),
    
    .axi_ddr_rdata                (axi_ddr_rdata[127:0]                            ), //[127:0]
    .axi_ddr_rid                  (axi_ddr_rid                                     ), // [5:0]
    .axi_ddr_rlast                (axi_ddr_rlast                                   ),
    .axi_ddr_rready               (axi_ddr_rready                                  ),//4 axi_ddr_rready
    .axi_ddr_rresp                (                                                ),
    .axi_ddr_rvalid               (axi_ddr_rvalid                                  ),
                                                                                   
                                                                                   
    .axi_ddr_wdata                (axi_ddr_wdata                                   ), //[127:0]
    .axi_ddr_wlast                (axi_ddr_wlast                                   ),
    .axi_ddr_wready               (axi_ddr_wready                                  ),
    .axi_ddr_wstrb                (16'hffff                                        ),
    .axi_ddr_wvalid               (axi_ddr_wvalid                                 ),//3 axi_ddr_wvalid
                                                                                   
                                                                                   
    .clk_100m                     (clk_100m                                        ),
    .ps_rvram_addr                (ps_rvram_addr                                   ),
    .ps_rvram_clk                 (                                                ),
    .ps_rvram_din                 (ps_rvram_din                                    ),
    .ps_rvram_dout                (ps_rvram_dout                                   ),
    .ps_rvram_en                  (ps_rvram_en                                     ),
    .ps_rvram_rst                 (ps_rvram_rst                                    ),
    .ps_rvram_we                  (ps_rvram_we                                     ),
    .rst_n                        (rst_n                                           )          
            
                                                    );
                                                    
                                                    


/*
wire                                    c0_ddr4_clk;
 // Slave Interface Write Address Ports
wire [3:0]                              c0_ddr4_s_axi_awid;
wire [28:0]                             c0_ddr4_s_axi_awaddr;
wire [7:0]                              c0_ddr4_s_axi_awlen;
wire [2:0]                              c0_ddr4_s_axi_awsize;
wire [1:0]                              c0_ddr4_s_axi_awburst;
wire [3:0]                              c0_ddr4_s_axi_awcache;
wire [2:0]                              c0_ddr4_s_axi_awprot;
wire                                    c0_ddr4_s_axi_awvalid;
wire                                    c0_ddr4_s_axi_awready;
 // Slave Interface Write Data Ports
wire [127:0]                            c0_ddr4_s_axi_wdata;
wire [15:0]                             c0_ddr4_s_axi_wstrb;
wire                                    c0_ddr4_s_axi_wlast;
wire                                    c0_ddr4_s_axi_wvalid;
wire                                    c0_ddr4_s_axi_wready;
 // Slave Interface Write Response Ports
wire                                    c0_ddr4_s_axi_bready;
wire [3:0]                              c0_ddr4_s_axi_bid;
wire [1:0]                              c0_ddr4_s_axi_bresp;
wire                                    c0_ddr4_s_axi_bvalid;
 // Slave Interface Read Address Ports
wire [3:0]                              c0_ddr4_s_axi_arid;
wire [28:0]                             c0_ddr4_s_axi_araddr;
wire [7:0]                              c0_ddr4_s_axi_arlen;
wire [2:0]                              c0_ddr4_s_axi_arsize;
wire [1:0]                              c0_ddr4_s_axi_arburst;
wire [3:0]                              c0_ddr4_s_axi_arcache;
wire                                    c0_ddr4_s_axi_arvalid;
wire                                    c0_ddr4_s_axi_arready;
 // Slave Interface Read Data Ports
wire                                    c0_ddr4_s_axi_rready;
wire [3:0]                              c0_ddr4_s_axi_rid;
wire [127:0]                            c0_ddr4_s_axi_rdata;
wire [1:0]                              c0_ddr4_s_axi_rresp;
wire                                    c0_ddr4_s_axi_rlast;
wire                                    c0_ddr4_s_axi_rvalid;
ddr4_mig u_ddr4_mig
  (
   .sys_rst                                     (rst_ddr_i                                               ),
   .c0_sys_clk_p                                (c0_sys_clk_p                                            ),
   .c0_sys_clk_n                                (c0_sys_clk_n                                            ),
   .c0_init_calib_complete                      (c0_init_calib_complete_o                                ),
   
   .c0_ddr4_act_n                               (c0_ddr4_act_n                                           ),
   .c0_ddr4_adr                                 (c0_ddr4_adr                                             ),
   .c0_ddr4_ba                                  (c0_ddr4_ba                                              ),
   .c0_ddr4_bg                                  (c0_ddr4_bg                                              ),
   .c0_ddr4_cke                                 (c0_ddr4_cke                                             ),
   .c0_ddr4_odt                                 (c0_ddr4_odt                                             ),
   .c0_ddr4_cs_n                                (c0_ddr4_cs_n                                            ),
   .c0_ddr4_ck_t                                (c0_ddr4_ck_t                                            ),
   .c0_ddr4_ck_c                                (c0_ddr4_ck_c                                            ),
   .c0_ddr4_reset_n                             (c0_ddr4_reset_n_int                                     ),
   .c0_ddr4_dm_dbi_n                            (c0_ddr4_dm_dbi_n                                        ),
   .c0_ddr4_dq                                  (c0_ddr4_dq                                              ),
   .c0_ddr4_dqs_c                               (c0_ddr4_dqs_c                                           ),
   .c0_ddr4_dqs_t                               (c0_ddr4_dqs_t                                           ),
   .c0_ddr4_ui_clk                              (c0_ddr4_clk                                             ),
   .c0_ddr4_ui_clk_sync_rst                     (c0_ddr4_rst                                             ),  // c0_ddr4_rst
   .addn_ui_clkout1                             (                                                        ),
   .dbg_clk                                     (                                                        ),
  // Slave Interface Write Address Ports                                                                 
  .c0_ddr4_aresetn                              (~c0_ddr4_rst                                            ),
  .c0_ddr4_s_axi_awid                           ( 4'd0                                                   ),
  .c0_ddr4_s_axi_awaddr                         (c0_ddr4_s_axi_awaddr  + ps_ddr_intf_base_addr_i[28:0]   ),
  .c0_ddr4_s_axi_awlen                          (3                                                       ),  // 11 -> 3         -> 4 tras 
  .c0_ddr4_s_axi_awsize                         (4                                                       ),  // 100 -> 16 bytes = 128 bit
  .c0_ddr4_s_axi_awburst                        (1                                                       ),  // INCR type
  .c0_ddr4_s_axi_awlock                         (1'b0                                                    ),
  .c0_ddr4_s_axi_awcache                        (0                                                       ),
  .c0_ddr4_s_axi_awprot                         (0                                                       ),
  .c0_ddr4_s_axi_awqos                          (4'b0                                                    ),
  .c0_ddr4_s_axi_awvalid                        (c0_ddr4_s_axi_awvalid                                   ),
  .c0_ddr4_s_axi_awready                        (c0_ddr4_s_axi_awready                                   ),
  // Slave Interface Write Data Ports                                                                    
  .c0_ddr4_s_axi_wdata                          (c0_ddr4_s_axi_wdata                                     ),
  .c0_ddr4_s_axi_wstrb                          (16'hffff                                                ),
  .c0_ddr4_s_axi_wlast                          (c0_ddr4_s_axi_wlast                                     ),
  .c0_ddr4_s_axi_wvalid                         (c0_ddr4_s_axi_wvalid                                    ),
  .c0_ddr4_s_axi_wready                         (c0_ddr4_s_axi_wready                                    ),
  // Slave Interface Write Response Ports                                                                ),
  .c0_ddr4_s_axi_bid                            (                                                        ),
  .c0_ddr4_s_axi_bresp                          (                                                        ),
  .c0_ddr4_s_axi_bvalid                         (                                                        ),
  .c0_ddr4_s_axi_bready                         (1                                                       ),
  // Slave Interface Read Address Ports                                                                  
  .c0_ddr4_s_axi_arid                           (0                                                       ),
  .c0_ddr4_s_axi_araddr                         (c0_ddr4_s_axi_araddr + ps_ddr_intf_base_addr_i[28:0]    ),
  .c0_ddr4_s_axi_arlen                          (3                                                       ),
  .c0_ddr4_s_axi_arsize                         (4                                                       ),
  .c0_ddr4_s_axi_arburst                        (1                                                       ),
  .c0_ddr4_s_axi_arlock                         (1'b0                                                    ),
  .c0_ddr4_s_axi_arcache                        (0                                                       ),
  .c0_ddr4_s_axi_arprot                         (3'b0                                                    ),
  .c0_ddr4_s_axi_arqos                          (4'b0                                                    ),
  .c0_ddr4_s_axi_arvalid                        (c0_ddr4_s_axi_arvalid                                   ),
  .c0_ddr4_s_axi_arready                        (c0_ddr4_s_axi_arready                                   ),
  // Slave Interface Read Data Ports                                                                     
  .c0_ddr4_s_axi_rid                            (c0_ddr4_s_axi_rid                                       ),
  .c0_ddr4_s_axi_rdata                          (c0_ddr4_s_axi_rdata                                     ),
  .c0_ddr4_s_axi_rresp                          (                                                       ),
  .c0_ddr4_s_axi_rlast                          (c0_ddr4_s_axi_rlast                                     ),
  .c0_ddr4_s_axi_rvalid                         (c0_ddr4_s_axi_rvalid                                    ),
  .c0_ddr4_s_axi_rready                         (c0_ddr4_s_axi_rready                                    ),
  // Debug Port
  .dbg_bus                                      (                                                        )                                             

  );                                                    
                        */                            
 

endmodule
