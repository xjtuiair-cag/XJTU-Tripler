`timescale 1ns / 1ps

module ddr_intf #(
    parameter DDRIF_ADDR_WTH = 26,
    parameter DDRIF_ALEN_WTH = 16,
    parameter DDRIF_DATA_WTH = 512,
    parameter DDRIF_DSTROB_WTH = DDRIF_DATA_WTH/8
) (
    // clock & reset
    // ddr clock
    // core clock               
    input                                   clk_i                       ,
    // common reset             
    input                                   rst_i                       ,

                
        
    // from data_upload module      

        
  
    // from save_mtxreg_ctrl module         
    input [DDRIF_ADDR_WTH-1 : 0]            svmr_ddrintf__waddr_i,
    input [DDRIF_ALEN_WTH-1 : 0]            svmr_ddrintf__wlen_i,
    input                                   svmr_ddrintf__wcmd_vld_i,
    output                                  svmr_ddrintf__wcmd_rdy_o,
    input [DDRIF_DATA_WTH-1 : 0]            svmr_ddrintf__wdata_i,
    input                                   svmr_ddrintf__wdata_last_i,
    input [DDRIF_DSTROB_WTH-1 : 0]          svmr_ddrintf__wdata_strob_i,
    input                                   svmr_ddrintf__wdata_vld_i,
    output                                  svmr_ddrintf__wdata_rdy_o,
        
    // from load_mtxreg_ctrl module         
    input [DDRIF_ADDR_WTH-1 : 0]            ldmr_ddrintf__raddr_i,
    input [DDRIF_ALEN_WTH-1 : 0]            ldmr_ddrintf__rlen_i,
    input                                   ldmr_ddrintf__rcmd_vld_i,
    output                                  ldmr_ddrintf__rcmd_rdy_o,
    output[DDRIF_DATA_WTH-1 : 0]            ldmr_ddrintf__rdata_o,
    output                                  ldmr_ddrintf__rdata_last_o,
    output                                  ldmr_ddrintf__rdata_vld_o,
    input                                   ldmr_ddrintf__rdata_rdy_i,

            
    
     
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
    output             axi_ddr_wvalid                    
);
parameter [5:0]  DDR_AXI_ID = 6'b00_1010;
//======================================================================================================================
// Wire & Reg declaration
//======================================================================================================================

//======================================================================================================================
// Instance
//======================================================================================================================

wire  [DDRIF_ADDR_WTH-1 : 0]            debug__waddr_i          = 'h0       ;
wire  [DDRIF_ALEN_WTH-1 : 0]            debug__wlen_i           = 'h0       ;
wire                                    debug__wcmd_vld_i       = 'h0       ;
wire                                    debug__wcmd_rdy_o                   ;
wire  [DDRIF_DATA_WTH-1 : 0]            debug__wdata_i          = 'h0       ;
wire                                    debug__wdata_last_i     = 'h0       ;
wire  [DDRIF_DSTROB_WTH-1 : 0]          debug__wdata_strob_i    = 'h0       ;
wire                                    debug__wdata_vld_i      = 'h0       ;
wire                                    debug__wdata_rdy_o                  ;
    
    
wire  [DDRIF_ADDR_WTH-1 : 0]            uld_ddrintf__raddr_i      = 'h0     ;
wire  [DDRIF_ALEN_WTH-1 : 0]            uld_ddrintf__rlen_i       = 'h0     ;
wire                                    uld_ddrintf__rcmd_vld_i   = 'h0     ;
wire                                    uld_ddrintf__rcmd_rdy_o             ;
wire  [DDRIF_DATA_WTH-1 : 0]            uld_ddrintf__rdata_o                ;
wire                                    uld_ddrintf__rdata_last_o           ;
wire                                    uld_ddrintf__rdata_vld_o            ;
wire                                    uld_ddrintf__rdata_rdy_i  = 1'b1    ;



wire  [DDRIF_ADDR_WTH-1 : 0]            dld_ddrintf__waddr_i         = 'h0       ;
wire  [DDRIF_ALEN_WTH-1 : 0]            dld_ddrintf__wlen_i          = 'h0       ;
wire                                    dld_ddrintf__wcmd_vld_i      = 'h0       ;
wire                                    dld_ddrintf__wcmd_rdy_o                  ;
wire  [DDRIF_DATA_WTH-1 : 0]            dld_ddrintf__wdata_i         = 'h0       ;
wire                                    dld_ddrintf__wdata_last_i    = 'h0       ;
wire  [DDRIF_DSTROB_WTH-1 : 0]          dld_ddrintf__wdata_strob_i   = 'h0       ;
wire                                    dld_ddrintf__wdata_vld_i     = 'h0       ;
wire                                    dld_ddrintf__wdata_rdy_o                 ;



ddr_arbiter_w ddr_arbiter_w_inst(                                                                                                
   .clk_i              (   clk_i                                                            ) ,   // core clock
   .clk_ddr_ui_i       (   clk_i                                                      ) ,   // ddr clock    
   .rst_i              (   rst_i                                                            ) ,   // common reset
   .waddr_i            (  { debug__waddr_i       ,  svmr_ddrintf__waddr_i       ,  dld_ddrintf__waddr_i                }) ,   // write port start
   .wlen_i             (  { debug__wlen_i        ,  svmr_ddrintf__wlen_i        ,  dld_ddrintf__wlen_i                 }) ,   //  
   .wcmd_vld_i         (  { debug__wcmd_vld_i    ,  svmr_ddrintf__wcmd_vld_i    ,  dld_ddrintf__wcmd_vld_i             }) ,   //
   .wcmd_rdy_o         (  { debug__wcmd_rdy_o    ,  svmr_ddrintf__wcmd_rdy_o    ,  dld_ddrintf__wcmd_rdy_o             }) ,   //
   .wdata_i            (  { debug__wdata_i       ,  svmr_ddrintf__wdata_i       ,  dld_ddrintf__wdata_i                }) ,   //
   .wdata_last_i       (  { debug__wdata_last_i  ,  svmr_ddrintf__wdata_last_i  ,  dld_ddrintf__wdata_last_i           }) ,   //
   .wdata_strob_i      (  { debug__wdata_strob_i ,  svmr_ddrintf__wdata_strob_i ,  dld_ddrintf__wdata_strob_i          }) ,   //
   .wdata_vld_i        (  { debug__wdata_vld_i   ,  svmr_ddrintf__wdata_vld_i   ,  dld_ddrintf__wdata_vld_i            }) ,   //
   .wdata_rdy_o        (  { debug__wdata_rdy_o   ,  svmr_ddrintf__wdata_rdy_o   ,  dld_ddrintf__wdata_rdy_o            }) ,   // write port end  
// Master Interface Write Address Ports
// .m_axi_awid     (                           ), //  output [3:0]                      
   .m_axi_awaddr   (axi_ddr_awaddr[28:0]       ), //  output [28:0]                     
// .m_axi_awlen    (                           ), //  output [7:0]                      
// .m_axi_awsize   (                           ), //  output [2:0]                      
// .m_axi_awburst  (                           ), //  output [1:0]                      
// .m_axi_awcache  (                           ), //  output [3:0]                      
// .m_axi_awprot   (                           ), //  output [2:0]                      
   .m_axi_awvalid  (axi_ddr_awvalid      ), //  output                            
   .m_axi_awready  (axi_ddr_awready      ), //  input                             
// Master Interface Write Data Ports
    .m_axi_wdata   (axi_ddr_wdata[127:0]      ), // output [127:0]                      
//  .m_axi_wstrb   (                           ), // output [15:0]                       
    .m_axi_wlast   (axi_ddr_wlast        ), // output                              
    .m_axi_wvalid  (axi_ddr_wvalid       ), // output                              
    .m_axi_wready  (axi_ddr_wready       ) // input                               
//Master Interface Write Response Ports 
//  .m_axi_bready  (                          ),  // output                              
//  .m_axi_bid     (                          ),  // input [3:0]                         
//  .m_axi_bresp   (                          ),  // input [1:0]                         
//  .m_axi_bvalid  (                          ),  // input                                                                     
    );   


ddr_arbiter_r ddr_arbiter_r_inst(   
    .clk_i              (   clk_i                                                            ) ,   // core clock
    .clk_ddr_ui_i       (   clk_i                                                      ) ,   // ddr clock    
    .rst_i              (   rst_i                                                            ) ,   // common reset
    .raddr_i            (  { ldmr_ddrintf__raddr_i       ,  uld_ddrintf__raddr_i             }) ,   // read port start
    .rlen_i             (  { ldmr_ddrintf__rlen_i        ,  uld_ddrintf__rlen_i              }) ,   //  
    .rcmd_vld_i         (  { ldmr_ddrintf__rcmd_vld_i    ,  uld_ddrintf__rcmd_vld_i          }) ,   //
    .rcmd_rdy_o         (  { ldmr_ddrintf__rcmd_rdy_o    ,  uld_ddrintf__rcmd_rdy_o          }) ,   //
    .rdata_o            (  { ldmr_ddrintf__rdata_o       ,  uld_ddrintf__rdata_o             }) ,   //
    .rdata_last_o       (  { ldmr_ddrintf__rdata_last_o  ,  uld_ddrintf__rdata_last_o        }) ,   //
    .rdata_vld_o        (  { ldmr_ddrintf__rdata_vld_o   ,  uld_ddrintf__rdata_vld_o         }) ,   //
    .rdata_rdy_i        (  { ldmr_ddrintf__rdata_rdy_i   ,  uld_ddrintf__rdata_rdy_i         }) ,   // read port end
// Master Interface Read Address Ports                                       
//  .m_axi_arid    (                          ),  // output [3:0]                        
    .m_axi_araddr  ( axi_ddr_araddr[28:0]     ),  // output [28:0]                       
//  .m_axi_arlen   (                          ),  // output [7:0]                        
//  .m_axi_arsize  (                          ),  // output [2:0]                        
//  .m_axi_arburst (                          ),  // output [1:0]                        
//  .m_axi_arcache (                          ),  // output [3:0]                        
    .m_axi_arvalid ( axi_ddr_arvalid    ),  // output                              
    .m_axi_arready ( axi_ddr_arready    ),  // input                               
// Master Interface Read Data Ports                                            
    .m_axi_rready  ( axi_ddr_rready     ),  // output                              
    .m_axi_rid     ( axi_ddr_rid[3:0]   ),  // input  [3:0]                        
    .m_axi_rdata   ( axi_ddr_rdata[127:0]  ),  // input  [127:0]                      
//  .m_axi_rresp   (                          ),  // input  [1:0]                        
    .m_axi_rlast   ( axi_ddr_rlast      ),  // input                               
    .m_axi_rvalid  ( axi_ddr_rvalid     )   // input                          
    
    );
    
    
/*
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
  .c0_ddr4_s_axi_awlen                          (3                                                       ),  // 110 -> 3         -> 4 tras 
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

  );              */    
    


//======================================================================================================================
// just for simulation
//======================================================================================================================
// synthesis translate_off

// synthesis translate_on

//======================================================================================================================
// probe signals
//======================================================================================================================

endmodule
