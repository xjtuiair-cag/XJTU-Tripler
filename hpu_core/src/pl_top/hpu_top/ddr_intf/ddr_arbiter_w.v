`timescale 1ns / 1ps

module ddr_arbiter_w #(
    parameter WRITE_BUS_NUM    = 3                                         ,   // write port number  don't spport other value  waddr_use  wlen_use wdata_use  wdata_strob_use
    
    parameter DDRIF_ADDR_WTH    = 26                                        ,   // address width per 512bit           
    parameter DDRIF_ALEN_WTH    = 16                                        ,   // address lengh    
    parameter DDRIF_DATA_WTH    = 512                                       ,   // data width 
    parameter DDRIF_DSTROB_WTH  = DDRIF_DATA_WTH/8                          ,   // strobe, 1bit = 1'b1 respsent the enabel of 1byte of data  
    
    parameter ALL_W_ADDR_WTH    = DDRIF_ADDR_WTH    *WRITE_BUS_NUM         ,
    parameter ALL_W_ALEN_WTH    = DDRIF_ALEN_WTH    *WRITE_BUS_NUM         ,
    parameter ALL_W_DATA_WTH    = DDRIF_DATA_WTH    *WRITE_BUS_NUM         ,
    parameter ALL_W_DSTROB_WTH  = DDRIF_DSTROB_WTH  *WRITE_BUS_NUM         ,
    
    parameter AXI_DATA_WTH      = 128                                      ,
    parameter AXI_M_ID          = 0                                        
    
    ) (
    // clock & reset    
    input                                   clk_i                                             ,   // core clock
    input                                   clk_ddr_ui_i                                      ,   // ddr clock    
    input                                   rst_i                                             ,   // common reset
    input [ALL_W_ADDR_WTH-1   : 0]          waddr_i                                           ,   // write port start
    input [ALL_W_ALEN_WTH-1   : 0]          wlen_i                                            ,   //  
     input [WRITE_BUS_NUM-1    : 0]          wcmd_vld_i                                        ,   //
     output[WRITE_BUS_NUM-1    : 0]          wcmd_rdy_o                                        ,   //
    input [ALL_W_DATA_WTH-1   : 0]          wdata_i                                           ,   //
    input [WRITE_BUS_NUM-1    : 0]          wdata_last_i                                      ,
    input [ALL_W_DSTROB_WTH-1 : 0]          wdata_strob_i                                     ,   //
     input [WRITE_BUS_NUM-1    : 0]          wdata_vld_i                                       ,   //
     output[WRITE_BUS_NUM-1    : 0]          wdata_rdy_o                                       ,   // write port end 
                                                                                                
   
    
// Master Interface Write Address Ports
//  output [3:0]                            m_axi_awid                                ,
    output [28:0]                           m_axi_awaddr                              ,
//  output [7:0]                            m_axi_awlen                               ,
//  output [2:0]                            m_axi_awsize                              ,
//  output [1:0]                            m_axi_awburst                             ,
//  output [3:0]                            m_axi_awcache                             ,
//  output [2:0]                            m_axi_awprot                              ,
    output                                  m_axi_awvalid                             ,
    input                                   m_axi_awready                             ,
// Master Interface Write Data Ports       
    output [127:0]                          m_axi_wdata                               ,
//  output [15:0]                           m_axi_wstrb                               ,
    output                                  m_axi_wlast                               ,
    output                                  m_axi_wvalid                              ,
    input                                   m_axi_wready                              ,
//Master Interface Write Response Ports    
    output                                  m_axi_bready                              
//  input [3:0]                             m_axi_bid                                 ,
//  input [1:0]                             m_axi_bresp                               ,
//  input                                   m_axi_bvalid                              ,
 
    
                                                                                        
    );   
localparam WCMD_EXPAND_CNT_WTH 		    = 	DDRIF_ADDR_WTH +1	                            ;
localparam WDATA_EXPAND_CNT_WTH         =   DDRIF_DATA_WTH/AXI_DATA_WTH +1                  ;


    
   
genvar i;
//======================================================================================================================
// Wire & Reg declaration
//======================================================================================================================

   
wire                                    w_bus_aribter_cmd2data_fifo_wr_en                   ;  //  
wire  [WRITE_BUS_NUM-1 : 0]             w_bus_aribter_cmd2data_fifo_wr_data                 ;
wire                                    w_bus_aribter_cmd2data_fifo_rd_en                   ;
wire  [WRITE_BUS_NUM-1 : 0]             w_bus_aribter_cmd2data_fifo_rd_data                 ;
reg   [WRITE_BUS_NUM-1 : 0]             w_bus_aribter_cmd2data_fifo_rd_data_dly0            ;
wire                                    w_bus_aribter_cmd2data_fifo_empty                   ;
reg                                     w_bus_aribter_cmd2data_fifo_empty_dly0              ;
wire                                    w_bus_aribter_cmd2data_fifo_full                    ;


wire  [DDRIF_ADDR_WTH-1 : 0]	        wcmd2axi_asyn_fifo_din			                    ;  
wire		                            wcmd2axi_asyn_fifo_wr_en		                    ;
wire		                            wcmd2axi_asyn_fifo_rd_en		                    ;
wire  [DDRIF_ADDR_WTH-1 : 0]	        wcmd2axi_asyn_fifo_dout			                    ;
wire		                            wcmd2axi_asyn_fifo_full			                    ;
wire		                            wcmd2axi_asyn_fifo_empty		                    ;


wire  [AXI_DATA_WTH     : 0]	        wdata2axi_asyn_fifo_din		                        ;
wire		                            wdata2axi_asyn_fifo_wr_en	                        ;
wire		                            wdata2axi_asyn_fifo_rd_en	                        ;
wire  [AXI_DATA_WTH     : 0]	        wdata2axi_asyn_fifo_dout	                        ;
wire			                        wdata2axi_asyn_fifo_full	                        ;
wire			                        wdata2axi_asyn_fifo_empty	                        ;


wire                                    wcmd_vld_use                                        ;   // 1bit the bus arbiter select to use   
wire                                    wcmd_rdy_use                                        ;   // 1bit 
wire  [DDRIF_ADDR_WTH-1   : 0]          waddr_use                                           ;   // write port start
wire  [DDRIF_ALEN_WTH-1   : 0]          wlen_use                                            ;   //                     

wire                                    wdata_vld_use                                       ; // the bus arbiter select to use   
wire                                    wdata_rdy_use                                       ;   
wire  [DDRIF_DATA_WTH-1   : 0]          wdata_use                                           ;   //
wire                                    wdata_last_use                                      ;   //
wire  [DDRIF_DSTROB_WTH-1 : 0]          wdata_strob_use                                     ;   //
reg   [DDRIF_DATA_WTH-1      :0]        wdata_tmp                                           ;
reg                                     wdata_last_tmp                                      ;
reg   [DDRIF_DSTROB_WTH-1    :0]        wdata_wdata_strob_tmp                               ;    
 

reg   [WRITE_BUS_NUM-1     : 0]         wbus_arbiter                                        ;
wire  [WRITE_BUS_NUM-1     : 0]         wbus_arbiter_next                                   ;
wire  [WRITE_BUS_NUM-1     : 0]         wdata_bus_arbiter                                   ;
wire  [WRITE_BUS_NUM-1     : 0]         wdata_bus_arbiter_pre                               ;

reg                                     wbus_inuse_d1                                       ;
reg                                     wbus_inuse_d2                                       ;
wire                                    wbus_inuse_pos                                      ;



    
wire                                    wcmd_expand_cnt_start_pulse                         ;
reg										wcmd_expand_cnt_hold		                        ;
reg	 [WCMD_EXPAND_CNT_WTH-1:0]		  	wcmd_expand_cnt		                                ;
wire  								    wcmd_expand_cnt_end	  	                            ;
                
reg  [WCMD_EXPAND_CNT_WTH-1:0]			wcmd_expand_cnt_start_value	                        ;
reg  [WCMD_EXPAND_CNT_WTH-1:0]			wcmd_expand_cnt_end_value		                    ;	
     
wire                                    wdata_expand_cnt_start_pulse                        ;
reg	 								    wdata_expand_cnt_hold		                        ;
reg	 [WDATA_EXPAND_CNT_WTH-1:0]		  	wdata_expand_cnt		                            ;
wire  								    wdata_expand_cnt_end	  	                        ;
wire  								    wdata_expand_cnt_end_pre	  	                    ;
        
reg  [WDATA_EXPAND_CNT_WTH-1:0]			wdata_expand_cnt_start_value	                    ;
reg  [WDATA_EXPAND_CNT_WTH-1:0]			wdata_expand_cnt_end_value		                    ;
     
     
     
    

        
     
//======================================================================================================================
// Instance
//======================================================================================================================
   
    /************************************AXI interface*************************/
    

    /*Master Interface Write Address Ports
    //output [3:0]                        m_axi_awid                                ,
    output [28:0]                         m_axi_awaddr                              ,
    //output [7:0]                        m_axi_awlen                               ,
    //output [2:0]                        m_axi_awsize                              ,
    //output [1:0]                        m_axi_awburst                             ,
    //output [3:0]                        m_axi_awcache                             ,
    //output [2:0]                        m_axi_awprot                              ,
    output                                m_axi_awvalid                             ,
    input                                 m_axi_awready                             ,
    */ 

    assign                  m_axi_awaddr[28:0]          =  {wcmd2axi_asyn_fifo_dout[22:0],6'd0} ;//??
    assign                  m_axi_awvalid               =   !wcmd2axi_asyn_fifo_empty           ;
    assign                  wcmd2axi_asyn_fifo_rd_en    =   m_axi_awvalid && m_axi_awready      ;
    
    
    /* Master Interface Write Data Ports
    output [127:0]                      m_axi_wdata                           ,
   // output [15:0]                     m_axi_wstrb                           ,
    output                              m_axi_wlast                           ,
    output                              m_axi_wvalid                           ,
    input                               m_axi_wready                           ,
    */
    
    
   assign                m_axi_wdata[127:0]         =       wdata2axi_asyn_fifo_dout[127:0] ;
   assign                m_axi_wlast                =       wdata2axi_asyn_fifo_dout[128]   ; 
   assign                m_axi_wvalid               =       !wdata2axi_asyn_fifo_empty  ; 
   assign                wdata2axi_asyn_fifo_rd_en  =       m_axi_wvalid && m_axi_wready;   
    
    
    
    
    /* Master Interface Write Response Ports
    output                              m_axi_bready                           ,
    // input [3:0]                         m_axi_bid                           ,
    // input [1:0]                         m_axi_bresp                           ,
    // input                               m_axi_bvalid                           ,
    */
   
   assign                           m_axi_bready  = 1;
   
   
    
   
    
    

   /**********************************************write cmd start*****************************************************/
    
    /*****************************************************************	
	wcmd2axi_asyn_fifo: 
            
             
	type                    : asynchronous fifo
	write data clock field  : clk_i 100m-300m
	read  data clock field  : clk_ddr_ui_i  ,which also is the AXI clock field 
	data  	width	: 26 bit address
	data	depth	: ?? (should be corrected again)
	
	******************************************************************/	
	wcmd2axi_asyn_fifo wcmd2axi_asyn_fifo_inst (
	.rst			(	rst_i					                                                            ), 
	.wr_clk			(	clk_i				                                                                ), 
	.rd_clk			(	clk_ddr_ui_i  		                                                                ), 
	.din			(	wcmd2axi_asyn_fifo_din			                                                    ), // 26bit
	.wr_en			(	wcmd2axi_asyn_fifo_wr_en			                                                ), 
	.rd_en			(	wcmd2axi_asyn_fifo_rd_en			                                                ), 
	.dout			(	wcmd2axi_asyn_fifo_dout			                                                    ), // 26bit
	.full			(	wcmd2axi_asyn_fifo_full			                                                    ), 
	.empty			(	wcmd2axi_asyn_fifo_empty			                                                )
	);
    assign          wcmd2axi_asyn_fifo_din          =         wcmd_expand_cnt                                       ;  
    assign          wcmd2axi_asyn_fifo_wr_en        =         wcmd_expand_cnt_hold && !wcmd2axi_asyn_fifo_full      ;   
    //assign          wcmd2axi_asyn_fifo_rd_en        =         1                                                      ;  
    //assign                                          =         wcmd2axi_asyn_fifo_dout                               ;  

    
    
    // arbiter based record of wcmd_vld_i
    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i) begin
            wbus_arbiter <=  'h2;
        end                     // 2019.1.7 c2
        else if ( ((wbus_arbiter & wcmd_vld_i) == 'h0 || (wcmd_expand_cnt_hold && wcmd_expand_cnt_end && !wcmd2axi_asyn_fifo_full))  && !(wcmd_expand_cnt_hold && !wcmd_expand_cnt_end)) begin
            wbus_arbiter <=  {wbus_arbiter[WRITE_BUS_NUM-2: 0], wbus_arbiter[WRITE_BUS_NUM-1]};
        end
    end
    
    always @(posedge clk_i) begin
        wbus_inuse_d1    <=  |(wbus_arbiter & wcmd_vld_i);
        wbus_inuse_d2    <=  wbus_inuse_d1;
    end
    
    assign  wbus_arbiter_next    =       (wcmd_expand_cnt_hold && wcmd_expand_cnt_end && !wcmd2axi_asyn_fifo_full)  ?  {wbus_arbiter[WRITE_BUS_NUM-2: 0], wbus_arbiter[WRITE_BUS_NUM-1]} : wbus_arbiter;
    
    assign  wbus_inuse_pos       =       wbus_inuse_d1 && (~wbus_inuse_d2)                      ;       
    
    
    // use wbus_arbiter to gerater wcmd_vld_use
            // 1 bit                     // WRITE_BUS_NUM bit                   WRITE_BUS_NUM bit 
    assign  wcmd_vld_use        =       |(wcmd_vld_i[WRITE_BUS_NUM-1:0]   &   wbus_arbiter[WRITE_BUS_NUM-1:0])  ;



     // use wcmd_rdy_use and wbus_arbiter to gerater wcmd_rdy_o
     
            // WRITE_BUS_NUM bit         // 1 bit -> WRITE_BUS_NUM bit          WRITE_BUS_NUM bit
    assign  wcmd_rdy_o          =       {WRITE_BUS_NUM{wcmd_rdy_use}}   &   wbus_arbiter[WRITE_BUS_NUM-1:0]  ;    
    
    assign  waddr_use           =       wbus_arbiter_next[0] ? waddr_i[0*DDRIF_ADDR_WTH+DDRIF_ADDR_WTH-1      :  0*DDRIF_ADDR_WTH] :
                                        wbus_arbiter_next[1] ? waddr_i[1*DDRIF_ADDR_WTH+DDRIF_ADDR_WTH-1      :  1*DDRIF_ADDR_WTH] :
                                        wbus_arbiter_next[2] ? waddr_i[2*DDRIF_ADDR_WTH+DDRIF_ADDR_WTH-1      :  2*DDRIF_ADDR_WTH] : 0;
                                        
    assign  wlen_use            =       wbus_arbiter_next[0] ? wlen_i [0*DDRIF_ALEN_WTH+DDRIF_ALEN_WTH-1      :  0*DDRIF_ALEN_WTH] :
                                        wbus_arbiter_next[1] ? wlen_i [1*DDRIF_ALEN_WTH+DDRIF_ALEN_WTH-1      :  1*DDRIF_ALEN_WTH] :
                                        wbus_arbiter_next[2] ? wlen_i [2*DDRIF_ALEN_WTH+DDRIF_ALEN_WTH-1      :  2*DDRIF_ALEN_WTH] : 0;
 
    
 
 
    // wdata_bus_arbiter 
    assign  wdata_use           =       wdata_bus_arbiter_pre[0] ? wdata_i [0*DDRIF_DATA_WTH+DDRIF_DATA_WTH-1     :  0*DDRIF_DATA_WTH] :
                                        wdata_bus_arbiter_pre[1] ? wdata_i [1*DDRIF_DATA_WTH+DDRIF_DATA_WTH-1     :  1*DDRIF_DATA_WTH] :
                                        wdata_bus_arbiter_pre[2] ? wdata_i [2*DDRIF_DATA_WTH+DDRIF_DATA_WTH-1     :  2*DDRIF_DATA_WTH] : 0;
                                        
    assign  wdata_strob_use     =       wdata_bus_arbiter_pre[0] ? wdata_strob_i[0*DDRIF_DSTROB_WTH+DDRIF_DSTROB_WTH-1     :  0*DDRIF_DSTROB_WTH] :
                                        wdata_bus_arbiter_pre[1] ? wdata_strob_i[1*DDRIF_DSTROB_WTH+DDRIF_DSTROB_WTH-1     :  1*DDRIF_DSTROB_WTH] :                
                                        wdata_bus_arbiter_pre[2] ? wdata_strob_i[2*DDRIF_DSTROB_WTH+DDRIF_DSTROB_WTH-1     :  2*DDRIF_DSTROB_WTH] :  0;  

    assign  wdata_last_use      =      |( wdata_last_i[WRITE_BUS_NUM-1:0]  &  wdata_bus_arbiter[WRITE_BUS_NUM-1:0])  ; 
                       

    

    


   
    /************** 
	wcmd_expand_cnt    expand the waddr_i to : waddr_i -> waddr_i + wlen_i
	
	start 			: shake hand of  wcmd_vld_use && wcmd_rdy_use 
	counter state	: from waddr_i -> waddr_i + wlen_i 
	add condition	: wcmd2axi_asyn_fifo_full
	*******************/                                                                                             
	//assign          wcmd_expand_cnt_start_pulse     =       wcmd_expand_cnt_hold ? (wcmd_vld_use && wcmd_rdy_use && (|(wcmd_vld_i & wbus_arbiter_next))) : ((|(wbus_arbiter & wcmd_vld_i))&&!w_bus_aribter_cmd2data_fifo_full)      ;
    assign          wcmd_expand_cnt_start_pulse     =       wcmd_vld_use && wcmd_rdy_use && (|(wcmd_vld_i & wbus_arbiter_next));

    //assign          wcmd_rdy_use                    =       (!w_bus_aribter_cmd2data_fifo_full) && (!wcmd2axi_asyn_fifo_full) && (wcmd_expand_cnt_hold&&wcmd_expand_cnt_end) ;
    // 2019.1.7 c1
    assign          wcmd_rdy_use                    =       (!w_bus_aribter_cmd2data_fifo_full) && (!wcmd2axi_asyn_fifo_full) && ( (wcmd_expand_cnt_hold&&wcmd_expand_cnt_end) || !wcmd_expand_cnt_hold);
    
    always@(posedge clk_i or posedge rst_i)
	begin
    if(rst_i)
        begin
        wcmd_expand_cnt_start_value <= {WCMD_EXPAND_CNT_WTH{1'b1}};
        wcmd_expand_cnt_end_value   <= {WCMD_EXPAND_CNT_WTH{1'b1}};    
        end
	else if( wcmd_expand_cnt_start_pulse )
        begin
        wcmd_expand_cnt_start_value <= waddr_use;
        wcmd_expand_cnt_end_value   <= waddr_use + wlen_use;
        end
	end
    

	always@(posedge clk_i or posedge rst_i)
	begin
    if(rst_i)
       wcmd_expand_cnt_hold <= 1'b0; 
	else if( wcmd_expand_cnt_start_pulse )
        wcmd_expand_cnt_hold <= 1'b1;
	else if(wcmd_expand_cnt_end && !wcmd2axi_asyn_fifo_full )
        wcmd_expand_cnt_hold <= 1'b0;
	end
	
	always@(posedge clk_i or posedge rst_i)  begin    
    if(rst_i)
        wcmd_expand_cnt <= {WCMD_EXPAND_CNT_WTH{1'b1}};
	else if(wcmd_expand_cnt_start_pulse)
		wcmd_expand_cnt <= waddr_use;
	else if(wcmd_expand_cnt_hold && !wcmd2axi_asyn_fifo_full) 
			begin
				if(wcmd_expand_cnt_end)
					wcmd_expand_cnt <= wcmd_expand_cnt_end_value;             
				else 
					wcmd_expand_cnt <= wcmd_expand_cnt + 1'd1;         
			end
	end
	
	assign   wcmd_expand_cnt_end = (wcmd_expand_cnt == wcmd_expand_cnt_end_value); 
    reg                         wcmd_expand_cnt_start_pulse_dly0;
    always@(posedge clk_i)
    begin
    wcmd_expand_cnt_start_pulse_dly0 <= wcmd_expand_cnt_start_pulse ;
    end
        
    /**********************************************write cmd end*****************************************************/

    /*****************************************************************	
	w_bus_aribter_cmd2data_fifo:    bus select from wcmd to wdata
                               when write command channel shake hand :both vld && rdy, write the arbiter result,  
                            write data channel read the data to select which channel to use
	type            : synchronous fifo
	clock field     : clk_i  100m-300m
	data  	width	: WRITE_BUS_NUM
	data	depth	: ??
	
	******************************************************************/	


    sync_fifo #(
    .FIFO_LEN(128           ),
    .DATA_WTH(WRITE_BUS_NUM ),// 2
    .ADDR_WTH(7             )
    ) w_bus_aribter_cmd2data_fifo (
    .clk_i             ( clk_i                                                                                                  ),
    .rst_i             ( rst_i                                                                                                  ),
    .wr_data_i         ( w_bus_aribter_cmd2data_fifo_wr_data    [WRITE_BUS_NUM-1 : 0]                                           ),
    .wr_en_i           ( w_bus_aribter_cmd2data_fifo_wr_en                                                                      ),
    .full_o            ( w_bus_aribter_cmd2data_fifo_full                                                                       ),
    .a_full_o          (                                                                                                        ),
    .rd_data_o         ( w_bus_aribter_cmd2data_fifo_rd_data    [WRITE_BUS_NUM-1 : 0]                                           ),
    .rd_en_i           ( w_bus_aribter_cmd2data_fifo_rd_en                                                                      ),
    .empty_o           ( w_bus_aribter_cmd2data_fifo_empty                                                                      ),
    .a_empty_o         (                                                                                                        )
    );
    

    
    assign              w_bus_aribter_cmd2data_fifo_wr_en           =       wcmd_expand_cnt_start_pulse_dly0       ;   // w_bus_aribter_cmd2data_fifo_full has been check  when   wcmd_expand_cnt_start_pulse
    assign              w_bus_aribter_cmd2data_fifo_wr_data         =       wbus_arbiter                         ; 
    assign              w_bus_aribter_cmd2data_fifo_rd_en           =       (wdata_expand_cnt_end_pre && !wdata2axi_asyn_fifo_full) && (wdata_last_tmp) && (!w_bus_aribter_cmd2data_fifo_empty) ; //(wdata_vld_use && wdata_rdy_use) && (wdata_last_tmp) && (!w_bus_aribter_cmd2data_fifo_empty) ;                            
    assign              wdata_bus_arbiter                           =       w_bus_aribter_cmd2data_fifo_rd_data_dly0 ; 
    assign              wdata_bus_arbiter_pre                       =       w_bus_aribter_cmd2data_fifo_rd_data     ; 
    
    
    always@(posedge clk_i)
    if(wdata_expand_cnt_hold)
	begin
		if(wdata_expand_cnt_start_pulse)
		begin
			w_bus_aribter_cmd2data_fifo_rd_data_dly0 <= w_bus_aribter_cmd2data_fifo_rd_data;
		end
	end
	else begin
		w_bus_aribter_cmd2data_fifo_rd_data_dly0 <= w_bus_aribter_cmd2data_fifo_rd_data;
	end
    
    
    
    
    always@(posedge clk_i)
    if(wdata_expand_cnt_hold)
	begin
		if(wdata_expand_cnt_start_pulse)
		begin
			w_bus_aribter_cmd2data_fifo_empty_dly0 <= w_bus_aribter_cmd2data_fifo_empty;
		end
	end
	else begin
		w_bus_aribter_cmd2data_fifo_empty_dly0 <= w_bus_aribter_cmd2data_fifo_empty;
	end    
    
    

    
    /**********************************************write data start***************************************************/
    

    
    // use wdata_bus_arbiter to gerater wdata_vld_use
            // 1 bit                     // WRITE_BUS_NUM bit                   WRITE_BUS_NUM bit 
    assign  wdata_vld_use        =       |(wdata_vld_i[WRITE_BUS_NUM-1:0]   &   wdata_bus_arbiter[WRITE_BUS_NUM-1:0] ) ;
    
    
    // use wdata_rdy_use and wdata_bus_arbiter to gerater wcmd_rdy_o
            // WRITE_BUS_NUM bit         // 1 bit -> WRITE_BUS_NUM bit          WRITE_BUS_NUM bit
    assign  wdata_rdy_o          =       {WRITE_BUS_NUM{wdata_rdy_use}}   &   wdata_bus_arbiter[WRITE_BUS_NUM-1:0]   ;
    
    
    
    
    
    
    /*****************************************************************	
	wdata2axi_asyn_fifo: 
            
	type                    : asynchronous fifo
	write data clock field  : clk_i 100m-300m
	read  data clock field  : clk_ddr_ui_i  ,which also is the AXI clock field 
	data  	width	: 128bit data + 1bit last signal
	data	depth	: 128 (should be corrected again)
	
	******************************************************************/	
	wdata2axi_asyn_fifo wdata2axi_asyn_fifo (
	.rst			(	rst_i					                                                            ), 
	.wr_clk			(	clk_i				                                                                ), 
	.rd_clk			(	clk_ddr_ui_i  		                                                                ), 
	.din			(	wdata2axi_asyn_fifo_din			                                                    ), // 128bit
	.wr_en			(	wdata2axi_asyn_fifo_wr_en			                                                ), 
	.rd_en			(	wdata2axi_asyn_fifo_rd_en			                                                ), 
	.dout			(	wdata2axi_asyn_fifo_dout			                                                ), // 128bit
	.full			(	wdata2axi_asyn_fifo_full			                                                ), 
	.empty			(	wdata2axi_asyn_fifo_empty			                                                )
	);

    wire            [DDRIF_DATA_WTH-1:0]  wdata_tmp_strob ;
    wire            [AXI_DATA_WTH-1:0]  wdata_tmp_strob_first ;
    
    wire            wdata_expand_cnt_ctn ;
    //assign          wdata_expand_cnt_ctn   =   (wdata_expand_cnt==0) ? (wdata_vld_use && !wdata2axi_asyn_fifo_full) : (!wdata2axi_asyn_fifo_full );
    assign          wdata_expand_cnt_ctn   =   !wdata2axi_asyn_fifo_full ;
    
    assign          wdata2axi_asyn_fifo_wr_en = wdata_expand_cnt_hold && wdata_expand_cnt_ctn;
    assign          wdata_tmp_strob             =     {     wdata_wdata_strob_tmp[63] ?   wdata_tmp [511:504]   : 8'd0,
                                                            wdata_wdata_strob_tmp[62] ?   wdata_tmp [503:496]   : 8'd0,
                                                            wdata_wdata_strob_tmp[61] ?   wdata_tmp [495:488]   : 8'd0,
                                                            wdata_wdata_strob_tmp[60] ?   wdata_tmp [487:480]   : 8'd0,
                                                            wdata_wdata_strob_tmp[59] ?   wdata_tmp [479:472]   : 8'd0,
                                                            wdata_wdata_strob_tmp[58] ?   wdata_tmp [471:464]   : 8'd0,
                                                            wdata_wdata_strob_tmp[57] ?   wdata_tmp [463:456]   : 8'd0,
                                                            wdata_wdata_strob_tmp[56] ?   wdata_tmp [455:448]   : 8'd0,
                                                            wdata_wdata_strob_tmp[55] ?   wdata_tmp [447:440]   : 8'd0,
                                                            wdata_wdata_strob_tmp[54] ?   wdata_tmp [439:432]   : 8'd0,
                                                            wdata_wdata_strob_tmp[53] ?   wdata_tmp [431:424]   : 8'd0,
                                                            wdata_wdata_strob_tmp[52] ?   wdata_tmp [423:416]   : 8'd0,
                                                            wdata_wdata_strob_tmp[51] ?   wdata_tmp [415:408]   : 8'd0,
                                                            wdata_wdata_strob_tmp[50] ?   wdata_tmp [407:400]   : 8'd0,
                                                            wdata_wdata_strob_tmp[49] ?   wdata_tmp [399:392]   : 8'd0,
                                                            wdata_wdata_strob_tmp[48] ?   wdata_tmp [391:384]   : 8'd0,
                                                            wdata_wdata_strob_tmp[47] ?   wdata_tmp [383:376]   : 8'd0,
                                                            wdata_wdata_strob_tmp[46] ?   wdata_tmp [375:368]   : 8'd0,
                                                            wdata_wdata_strob_tmp[45] ?   wdata_tmp [367:360]   : 8'd0,
                                                            wdata_wdata_strob_tmp[44] ?   wdata_tmp [359:352]   : 8'd0,
                                                            wdata_wdata_strob_tmp[43] ?   wdata_tmp [351:344]   : 8'd0,
                                                            wdata_wdata_strob_tmp[42] ?   wdata_tmp [343:336]   : 8'd0,
                                                            wdata_wdata_strob_tmp[41] ?   wdata_tmp [335:328]   : 8'd0,
                                                            wdata_wdata_strob_tmp[40] ?   wdata_tmp [327:320]   : 8'd0,
                                                            wdata_wdata_strob_tmp[39] ?   wdata_tmp [319:312]   : 8'd0,
                                                            wdata_wdata_strob_tmp[38] ?   wdata_tmp [311:304]   : 8'd0,
                                                            wdata_wdata_strob_tmp[37] ?   wdata_tmp [303:296]   : 8'd0,
                                                            wdata_wdata_strob_tmp[36] ?   wdata_tmp [295:288]   : 8'd0,
                                                            wdata_wdata_strob_tmp[35] ?   wdata_tmp [287:280]   : 8'd0,
                                                            wdata_wdata_strob_tmp[34] ?   wdata_tmp [279:272]   : 8'd0,
                                                            wdata_wdata_strob_tmp[33] ?   wdata_tmp [271:264]   : 8'd0,
                                                            wdata_wdata_strob_tmp[32] ?   wdata_tmp [263:256]   : 8'd0,
                                                            wdata_wdata_strob_tmp[31] ?   wdata_tmp [255:248]   : 8'd0,
                                                            wdata_wdata_strob_tmp[30] ?   wdata_tmp [247:240]   : 8'd0,
                                                            wdata_wdata_strob_tmp[29] ?   wdata_tmp [239:232]   : 8'd0,
                                                            wdata_wdata_strob_tmp[28] ?   wdata_tmp [231:224]   : 8'd0,
                                                            wdata_wdata_strob_tmp[27] ?   wdata_tmp [223:216]   : 8'd0,
                                                            wdata_wdata_strob_tmp[26] ?   wdata_tmp [215:208]   : 8'd0,
                                                            wdata_wdata_strob_tmp[25] ?   wdata_tmp [207:200]   : 8'd0,
                                                            wdata_wdata_strob_tmp[24] ?   wdata_tmp [199:192]   : 8'd0,
                                                            wdata_wdata_strob_tmp[23] ?   wdata_tmp [191:184]   : 8'd0,
                                                            wdata_wdata_strob_tmp[22] ?   wdata_tmp [183:176]   : 8'd0,
                                                            wdata_wdata_strob_tmp[21] ?   wdata_tmp [175:168]   : 8'd0,
                                                            wdata_wdata_strob_tmp[20] ?   wdata_tmp [167:160]   : 8'd0,
                                                            wdata_wdata_strob_tmp[19] ?   wdata_tmp [159:152]   : 8'd0,
                                                            wdata_wdata_strob_tmp[18] ?   wdata_tmp [151:144]   : 8'd0,
                                                            wdata_wdata_strob_tmp[17] ?   wdata_tmp [143:136]   : 8'd0,
                                                            wdata_wdata_strob_tmp[16] ?   wdata_tmp [135:128]   : 8'd0,
                                                            wdata_wdata_strob_tmp[15] ?   wdata_tmp [127:120]   : 8'd0,
                                                            wdata_wdata_strob_tmp[14] ?   wdata_tmp [119:112]   : 8'd0,
                                                            wdata_wdata_strob_tmp[13] ?   wdata_tmp [111:104]   : 8'd0,
                                                            wdata_wdata_strob_tmp[12] ?   wdata_tmp [103:96 ]   : 8'd0,
                                                            wdata_wdata_strob_tmp[11] ?   wdata_tmp [95 :88 ]   : 8'd0,
                                                            wdata_wdata_strob_tmp[10] ?   wdata_tmp [87 :80 ]   : 8'd0,
                                                            wdata_wdata_strob_tmp[9 ] ?   wdata_tmp [79 :72 ]   : 8'd0,
                                                            wdata_wdata_strob_tmp[8 ] ?   wdata_tmp [71 :64 ]   : 8'd0,
                                                            wdata_wdata_strob_tmp[7 ] ?   wdata_tmp [63 :56 ]   : 8'd0,
                                                            wdata_wdata_strob_tmp[6 ] ?   wdata_tmp [55 :48 ]   : 8'd0,
                                                            wdata_wdata_strob_tmp[5 ] ?   wdata_tmp [47 :40 ]   : 8'd0,
                                                            wdata_wdata_strob_tmp[4 ] ?   wdata_tmp [39 :32 ]   : 8'd0,
                                                            wdata_wdata_strob_tmp[3 ] ?   wdata_tmp [31 :24 ]   : 8'd0,
                                                            wdata_wdata_strob_tmp[2 ] ?   wdata_tmp [23 :16 ]   : 8'd0,
                                                            wdata_wdata_strob_tmp[1 ] ?   wdata_tmp [15 :8  ]   : 8'd0,
                                                            wdata_wdata_strob_tmp[0 ] ?   wdata_tmp [7  :0  ]   : 8'd0};
    /*assign          wdata_tmp_strob_first =  {              
                                                            wdata_strob_use[15] ?   wdata_use [127:120]   : 8'd0,
                                                            wdata_strob_use[14] ?   wdata_use [119:112]   : 8'd0,
                                                            wdata_strob_use[13] ?   wdata_use [111:104]   : 8'd0,
                                                            wdata_strob_use[12] ?   wdata_use [103:96 ]   : 8'd0,
                                                            wdata_strob_use[11] ?   wdata_use [95 :88 ]   : 8'd0,
                                                            wdata_strob_use[10] ?   wdata_use [87 :80 ]   : 8'd0,
                                                            wdata_strob_use[9 ] ?   wdata_use [79 :72 ]   : 8'd0,
                                                            wdata_strob_use[8 ] ?   wdata_use [71 :64 ]   : 8'd0,
                                                            wdata_strob_use[7 ] ?   wdata_use [63 :56 ]   : 8'd0,
                                                            wdata_strob_use[6 ] ?   wdata_use [55 :48 ]   : 8'd0,
                                                            wdata_strob_use[5 ] ?   wdata_use [47 :40 ]   : 8'd0,
                                                            wdata_strob_use[4 ] ?   wdata_use [39 :32 ]   : 8'd0,
                                                            wdata_strob_use[3 ] ?   wdata_use [31 :24 ]   : 8'd0,
                                                            wdata_strob_use[2 ] ?   wdata_use [23 :16 ]   : 8'd0,
                                                            wdata_strob_use[1 ] ?   wdata_use [15 :8  ]   : 8'd0,
                                                            wdata_strob_use[0 ] ?   wdata_use [7  :0  ]   : 8'd0};        */                                
    
    assign          wdata2axi_asyn_fifo_din     =   {   wdata_expand_cnt_end                                                                    , // the axi data last 
                                                        wdata_expand_cnt == 0 ? wdata_tmp_strob [0*AXI_DATA_WTH+AXI_DATA_WTH-1 : 0*AXI_DATA_WTH] :   // wdata_tmp_strob_first: 
                                                        wdata_expand_cnt == 1 ? wdata_tmp_strob [1*AXI_DATA_WTH+AXI_DATA_WTH-1 : 1*AXI_DATA_WTH] :
                                                        wdata_expand_cnt == 2 ? wdata_tmp_strob [2*AXI_DATA_WTH+AXI_DATA_WTH-1 : 2*AXI_DATA_WTH] :
                                                        wdata_expand_cnt == 3 ? wdata_tmp_strob [3*AXI_DATA_WTH+AXI_DATA_WTH-1 : 3*AXI_DATA_WTH] :
                                                        128'd0
                                                       };
                                                       
    /************** 
	wdata_expand_cnt    expand the data 512bit -> 128bit
	
	start 			: shake hand of  wdata_vld_use && wdata_rdy_use
	counter state	: from waddr_i -> waddr_i + wlen_i 
	add condition	: wcmd2axi_asyn_fifo_full
	*******************/
    
    wire            debug                           = |(wdata_bus_arbiter & wdata_vld_i);
    
    //assign  wdata_vld_use        =       |(wdata_vld_i[WRITE_BUS_NUM-1:0]   &   wdata_bus_arbiter[WRITE_BUS_NUM-1:0] ) ;

    // 2017.17 c
	//assign          wdata_expand_cnt_start_pulse     =       !w_bus_aribter_cmd2data_fifo_empty && (wdata_expand_cnt_hold ? (wdata_vld_use && wdata_rdy_use) :  (!w_bus_aribter_cmd2data_fifo_empty_dly0 && (|(wdata_bus_arbiter & wdata_vld_i)) ) )    ;
    assign          wdata_expand_cnt_start_pulse     =       (wdata_vld_use && wdata_rdy_use);
    assign          wdata_rdy_use                    =       (!w_bus_aribter_cmd2data_fifo_empty_dly0) && (!wdata2axi_asyn_fifo_full) && ((wdata_expand_cnt_hold && wdata_expand_cnt_end) || !wdata_expand_cnt_hold);
    //assign          wcmd_rdy_use                    =       (!w_bus_aribter_cmd2data_fifo_full) && (!wcmd2axi_asyn_fifo_full) && ( (wcmd_expand_cnt_hold&&wcmd_expand_cnt_end) || !wcmd_expand_cnt_hold);


    always@(posedge clk_i or posedge rst_i)
	begin
    if(rst_i)
        begin  
        wdata_expand_cnt_start_value <= {WDATA_EXPAND_CNT_WTH{1'b1}};
        wdata_expand_cnt_end_value   <= {WDATA_EXPAND_CNT_WTH{1'b1}};    
        wdata_tmp                    <= 0                           ;
        wdata_wdata_strob_tmp        <= 0                           ;
        end
	else if( wdata_vld_use && wdata_rdy_use ) // 2019.1.7 c   wdata_expand_cnt_hold &&  wdata_expand_cnt == 0
        begin
        wdata_expand_cnt_start_value <= 0                               ;
        wdata_expand_cnt_end_value   <= DDRIF_DATA_WTH/AXI_DATA_WTH - 1 ;
        wdata_tmp                    <= wdata_use                       ;
        wdata_wdata_strob_tmp        <= wdata_strob_use                 ;
        wdata_last_tmp               <= wdata_last_use                  ;
        end
	end
    

	always@(posedge clk_i or posedge rst_i)
	begin
    if(rst_i)
       wdata_expand_cnt_hold <= 1'b0; 
	else if( wdata_expand_cnt_start_pulse )
        wdata_expand_cnt_hold <= 1'b1;
	else if(wdata_expand_cnt_end && wdata_expand_cnt_ctn )
        wdata_expand_cnt_hold <= 1'b0;
	end
	
	always@(posedge clk_i or posedge rst_i)  begin    
    if(rst_i)
        wdata_expand_cnt <= {WDATA_EXPAND_CNT_WTH{1'b1}};
	else if(wdata_expand_cnt_start_pulse)
		wdata_expand_cnt <= 0;
	else if(wdata_expand_cnt_hold && wdata_expand_cnt_ctn) 
			begin
				if(wdata_expand_cnt_end)
					wdata_expand_cnt <= wdata_expand_cnt_end_value;             
				else 
					wdata_expand_cnt <= wdata_expand_cnt + 1'd1;         
			end
	end
	
	assign   wdata_expand_cnt_end = (wdata_expand_cnt == wdata_expand_cnt_end_value); 
    
    assign   wdata_expand_cnt_end_pre = ((wdata_expand_cnt == wdata_expand_cnt_end_value-1)&&wdata_expand_cnt_ctn);     
    
    
    /**********************************************write data end*****************************************************/
(* ASYNC_REG = "true" *)         reg [31:0] wcmd2axi_asyn_fifo_rd_en_cnt;
        
(* ASYNC_REG = "true" *)         reg [31:0] wdata2axi_asyn_fifo_wr_en_cnt;
(* ASYNC_REG = "true" *)         reg [31:0] wdata2axi_asyn_fifo_rd_en_cnt;
(* ASYNC_REG = "true" *)         reg [31:0] wdata_512bit_shk_cnt;
        
        
        
            always@(posedge clk_ddr_ui_i or posedge rst_i)
            begin
            if(rst_i)
                wcmd2axi_asyn_fifo_rd_en_cnt <= 0;
            else if(wcmd2axi_asyn_fifo_rd_en && !wcmd2axi_asyn_fifo_empty)
                wcmd2axi_asyn_fifo_rd_en_cnt <=   wcmd2axi_asyn_fifo_rd_en_cnt + 1;
            end
            
            
            
            
            always@(posedge clk_i or posedge rst_i)
            begin
            if(rst_i)
                wdata2axi_asyn_fifo_wr_en_cnt <= 0;
            else if(wdata2axi_asyn_fifo_wr_en && !wdata2axi_asyn_fifo_full)
                wdata2axi_asyn_fifo_wr_en_cnt <=   wdata2axi_asyn_fifo_wr_en_cnt + 1;
            end    
        
        
            always@(posedge clk_ddr_ui_i or posedge rst_i)
            begin
            if(rst_i)
                wdata2axi_asyn_fifo_rd_en_cnt <= 0;
            else if(wdata2axi_asyn_fifo_rd_en && !wdata2axi_asyn_fifo_empty)
                wdata2axi_asyn_fifo_rd_en_cnt <=    wdata2axi_asyn_fifo_rd_en_cnt + 1;
            end
            
      
            
            always@(posedge clk_i or posedge rst_i)
            begin
            if(rst_i)
                wdata_512bit_shk_cnt <= 0;
            else if(wdata_vld_i[0] && wdata_rdy_o[0])
                wdata_512bit_shk_cnt <=    wdata_512bit_shk_cnt + 1;
            end        
                
//======================================================================================================================
// just for simulation
//======================================================================================================================
// synthesis translate_off

  
// synthesis translate_on

//======================================================================================================================
// probe signals
//======================================================================================================================
wire  [DDRIF_ADDR_WTH-1 : 0]            probe_waddr_i[0 : WRITE_BUS_NUM-1];
wire  [DDRIF_ALEN_WTH-1 : 0]            probe_wlen_i[0 : WRITE_BUS_NUM-1];
wire                                    probe_wcmd_vld_i[0 : WRITE_BUS_NUM-1];
wire                                    probe_wcmd_rdy_o[0 : WRITE_BUS_NUM-1];
wire  [DDRIF_DATA_WTH-1   : 0]          probe_wdata_i[0 : WRITE_BUS_NUM-1];
wire                                    probe_wdata_last_i[0 : WRITE_BUS_NUM-1];
wire  [DDRIF_DSTROB_WTH-1 : 0]          probe_wdata_strob_i[0 : WRITE_BUS_NUM-1];
wire  [DDRIF_DSTROB_WTH-1 : 0]          probe_wdata_vld_i[0 : WRITE_BUS_NUM-1];
wire  [DDRIF_DSTROB_WTH-1 : 0]          probe_wdata_rdy_o[0 : WRITE_BUS_NUM-1];
genvar j;
generate
    for (j=0; j<WRITE_BUS_NUM; j=j+1) begin
        assign probe_waddr_i[j] = waddr_i[j*DDRIF_ADDR_WTH +: DDRIF_ADDR_WTH];
        assign probe_wlen_i[j] = wlen_i[j*DDRIF_ALEN_WTH +: DDRIF_ALEN_WTH];
        assign probe_wcmd_vld_i[j] = wcmd_vld_i[j];
        assign probe_wcmd_rdy_o[j] = wcmd_rdy_o[j];
        assign probe_wdata_i[j] = wdata_i[j*DDRIF_DATA_WTH +: DDRIF_DATA_WTH];
        assign probe_wdata_last_i[j] = wdata_last_i[j];
        assign probe_wdata_strob_i[j] = wdata_strob_i[j*DDRIF_DSTROB_WTH +: DDRIF_DSTROB_WTH];
        assign probe_wdata_vld_i[j] = wdata_vld_i[j];
        assign probe_wdata_rdy_o[j] = wdata_rdy_o[j];
    end
endgenerate

endmodule
