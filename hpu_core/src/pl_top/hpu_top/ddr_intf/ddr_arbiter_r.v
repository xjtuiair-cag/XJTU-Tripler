`timescale 1ns / 1ps

module ddr_arbiter_r #(
    parameter READ_BUS_NUM     = 2                                         ,   // read port number  don't spport other value
    
    parameter DDRIF_ADDR_WTH    = 26                                        ,   // address width per 512bit           
    parameter DDRIF_ALEN_WTH    = 16                                        ,   // address lengh    
    parameter DDRIF_DATA_WTH    = 512                                       ,   // data width 
    parameter DDRIF_DSTROB_WTH  = DDRIF_DATA_WTH/8                          ,   // strobe, 1bit = 1'b1 respsent the enabel of 1byte of data  
    
  
    parameter ALL_R_ADDR_WTH    = DDRIF_ADDR_WTH    *READ_BUS_NUM          ,
    parameter ALL_R_ALEN_WTH    = DDRIF_ALEN_WTH    *READ_BUS_NUM          ,
    parameter ALL_R_DATA_WTH    = DDRIF_DATA_WTH    *READ_BUS_NUM          ,
    
    parameter AXI_DATA_WTH      = 128                                      ,
    parameter AXI_M_ID          = 0                                        
    
    ) (
    // clock & reset    
    input                                   clk_i                                             ,   // core clock
    input                                   clk_ddr_ui_i                                      ,   // ddr clock    
    input                                   rst_i                                             ,   // common reset
                                                                                                
    input [ALL_R_ADDR_WTH-1   : 0]          raddr_i                                           ,   // read port start
    input [ALL_R_ALEN_WTH-1   : 0]          rlen_i                                            ,   //  
    input [READ_BUS_NUM-1     : 0]          rcmd_vld_i                                        ,   //
    output[READ_BUS_NUM-1     : 0]          rcmd_rdy_o                                        ,   //
    output[ALL_R_DATA_WTH-1   : 0]          rdata_o                                           ,   //
    output[READ_BUS_NUM-1     : 0]          rdata_last_o                                      ,   //
    output[READ_BUS_NUM-1     : 0]          rdata_vld_o                                       ,   //
    input [READ_BUS_NUM-1     : 0]          rdata_rdy_i                                       ,   // read port end
    
   
// Master Interface Read Address Ports     
//  output [3:0]                            m_axi_arid                                ,
    output [28:0]                           m_axi_araddr                              ,
//  output [7:0]                            m_axi_arlen                               ,
//  output [2:0]                            m_axi_arsize                              ,
//  output [1:0]                            m_axi_arburst                             ,
//  output [3:0]                            m_axi_arcache                             ,
    output                                  m_axi_arvalid                             ,
    input                                   m_axi_arready                             ,
// Master Interface Read Data Ports    
    output                                  m_axi_rready                              ,
    input  [3:0]                            m_axi_rid                                 ,
    input  [127:0]                          m_axi_rdata                               ,
//  input  [1:0]                            m_axi_rresp                               ,
    input                                   m_axi_rlast                               ,
    input                                   m_axi_rvalid                           
 
    
                                                                                        
    ); 
localparam RCMD_EXPAND_CNT_WTH          =   DDRIF_ADDR_WTH +1                               ;        
localparam RDATA_CAT_CNT_WTH 		    = 	DDRIF_DATA_WTH/AXI_DATA_WTH +1	                ;
localparam D_RCMD_EXPAND_CNT_WTH        =   DDRIF_ADDR_WTH +1                               ;    
    
   
    
genvar i;
//======================================================================================================================
// Wire & Reg declaration
//======================================================================================================================

  
/*******************************************read wire reg*******************************************/
wire                                                            r_bus_aribter_cmd2data_fifo_wr_en                   ;  //  
wire  [READ_BUS_NUM+DDRIF_ADDR_WTH+DDRIF_ALEN_WTH-1 : 0]        r_bus_aribter_cmd2data_fifo_wr_data                 ;
wire                                                            r_bus_aribter_cmd2data_fifo_rd_en                   ;  
wire  [READ_BUS_NUM+DDRIF_ADDR_WTH+DDRIF_ALEN_WTH-1 : 0]        r_bus_aribter_cmd2data_fifo_rd_data                 ;
reg   [READ_BUS_NUM+DDRIF_ADDR_WTH+DDRIF_ALEN_WTH-1 : 0]        r_bus_aribter_cmd2data_fifo_rd_data_dly0                 ;
wire                                    r_bus_aribter_cmd2data_fifo_empty                   ;
reg                                     r_bus_aribter_cmd2data_fifo_empty_dly0              ;
wire                                    r_bus_aribter_cmd2data_fifo_full                    ;

wire  [DDRIF_ADDR_WTH-1          : 0]	rcmd2axi_asyn_fifo_din			                    ;  // 128 + 1bit last
wire		                            rcmd2axi_asyn_fifo_wr_en		                    ;
wire		                            rcmd2axi_asyn_fifo_rd_en		                    ;
wire  [DDRIF_ADDR_WTH-1         : 0]	rcmd2axi_asyn_fifo_dout			                    ;
wire		                            rcmd2axi_asyn_fifo_full			                    ;
wire		                            rcmd2axi_asyn_fifo_empty		                    ;


wire  [AXI_DATA_WTH                : 0]	rdata2axi_asyn_fifo_din		                ;
wire		                            rdata2axi_asyn_fifo_wr_en	                ;
wire		                            rdata2axi_asyn_fifo_rd_en	                ;
wire  [AXI_DATA_WTH                : 0]	rdata2axi_asyn_fifo_dout	                ;
wire		                            rdata2axi_asyn_fifo_full	                ;
wire		                            rdata2axi_asyn_fifo_empty	                ;

wire                                    rcmd_vld_use                                        ; // 1bit the bus arbiter select to use   
wire                                    rcmd_rdy_use                                        ; // 1bit 
wire  [DDRIF_ADDR_WTH-1         : 0]    raddr_use                                           ;   // write port start
wire  [DDRIF_ALEN_WTH-1         : 0]    rlen_use                                            ;   //                     
                                
 wire                                    rdata_vld_use                                       ; // the bus arbiter select to use   
wire                                    rdata_rdy_use                                       ;   
wire  [DDRIF_DATA_WTH-1         : 0]    rdata_use                                           ;   //
wire                                    rdata_last_use                                      ;   
                                
wire  [DDRIF_ALEN_WTH-1         : 0]    rdata_len_use                                       ;
wire  [DDRIF_ADDR_WTH-1         : 0]    rdata_addr_use                                      ;
                                
 reg   [READ_BUS_NUM-1          : 0]     rbus_req                                            ;
reg   [READ_BUS_NUM-1          : 0]     rbus_arbiter                                        ;
wire  [READ_BUS_NUM-1          : 0]     rbus_arbiter_next                                   ;
 wire  [READ_BUS_NUM-1          : 0]     rdata_bus_arbiter                                   ;
    
reg                                     rbus_inuse_d1                                       ;
reg                                     rbus_inuse_d2                                       ;
wire                                    rbus_inuse_pos                                      ;   
 
wire                                    rcmd_expand_cnt_start_pulse                         ;
reg	 								    rcmd_expand_cnt_hold		                        ;
reg	 [RCMD_EXPAND_CNT_WTH-1:0]		  	rcmd_expand_cnt		                                ;
wire  								    rcmd_expand_cnt_end	  	                            ;
                                                    
reg  [RCMD_EXPAND_CNT_WTH-1:0]			rcmd_expand_cnt_start_value	                        ;
reg  [RCMD_EXPAND_CNT_WTH-1:0]			rcmd_expand_cnt_end_value		                    ;	
     
wire                                    rdata_cat_cnt_start_pulse                           ;
reg	 								    rdata_cat_cnt_hold		                            ;
reg	 [RDATA_CAT_CNT_WTH-1:0]		  	rdata_cat_cnt		                                ;
wire  								    rdata_cat_cnt_end	  	                            ; 
wire                                    rdata_cat_cnt_end_pre                               ;
wire  								    rdata_cat_cnt_add_ctn	  	                        ;     
        
wire [RDATA_CAT_CNT_WTH-1:0]			rdata_cat_cnt_start_value	                   =  0 ;
wire [RDATA_CAT_CNT_WTH-1:0]			rdata_cat_cnt_end_value		                   =  3 ;
     
reg  [DDRIF_DATA_WTH-1      :0]         rdata_tmp                                           ;
     
wire                                    d_rcmd_expand_cnt_start_pulse               ;
reg	 								    d_rcmd_expand_cnt_hold		                ;
reg	 [D_RCMD_EXPAND_CNT_WTH-1:0]		d_rcmd_expand_cnt		                    ;
wire  								    d_rcmd_expand_cnt_end	  	                ;
     
reg  [D_RCMD_EXPAND_CNT_WTH-1:0]		d_rcmd_expand_cnt_start_value	            ;
reg  [D_RCMD_EXPAND_CNT_WTH-1:0]		d_rcmd_expand_cnt_end_value		            ;  
    

    
//======================================================================================================================
// Instance
//======================================================================================================================
   
    /************************************AXI interface*************************/
    

   
    /* Master Interface Read Address Ports
    // output [3:0]                        m_axi_arid                           ,
      output [28:0]                        m_axi_araddr                           ,
    // output [7:0]                        m_axi_arlen                           ,
    // output [2:0]                        m_axi_arsize                           ,
    //  output [1:0]                       m_axi_arburst                           ,
    //  output [3:0]                       m_axi_arcache                           ,
    output                                 m_axi_arvalid                           ,
    input                                  m_axi_arready                           ,
    */
    
    assign                  m_axi_araddr[28:0]          =   {rcmd2axi_asyn_fifo_dout[22:0],6'd0}  ; //??
    assign                  m_axi_arvalid               =   !rcmd2axi_asyn_fifo_empty           ;
    assign                  rcmd2axi_asyn_fifo_rd_en    =   m_axi_arvalid && m_axi_arready      ;
    
    
    
    
    /* Master Interface Read Data Ports
    output                              m_axi_rready                           ,
    input  [3:0]                        m_axi_rid                               ,
    input  [127:0]                      m_axi_rdata                           ,
  //  input  [1:0]                      m_axi_rresp                           ,
    input                               m_axi_rlast                           ,
    input                               m_axi_rvalid                           ,
 */
    
    assign          m_axi_rready                =           !rdata2axi_asyn_fifo_full       ;
    assign          rdata2axi_asyn_fifo_wr_en   =           m_axi_rvalid && m_axi_rready ;//&& (m_axi_rid == AXI_M_ID)    ;

    

    
    /**********************************************read cmd start*****************************************************/
    /*****************************************************************	
	rcmd2axi_asyn_fifo: 
            
             
	type                    : asynchronous fifo
	write data clock field  : clk_i 100m-300m
	read  data clock field  : clk_ddr_ui_i  ,which also is the AXI clock field 
	data  	width	: 26 bit address
	data	depth	: ?? (should be corrected again)
	
	******************************************************************/	
	wcmd2axi_asyn_fifo rcmd2axi_asyn_fifo_inst (
	.rst			(	rst_i					                                                            ), 
	.wr_clk			(	clk_i				                                                                ), 
	.rd_clk			(	clk_ddr_ui_i  		                                                                ), 
	.din			(	rcmd2axi_asyn_fifo_din			                                                    ), // 26bit
	.wr_en			(	rcmd2axi_asyn_fifo_wr_en			                                                ), 
	.rd_en			(	rcmd2axi_asyn_fifo_rd_en			                                                ), 
	.dout			(	rcmd2axi_asyn_fifo_dout			                                                    ), // 26bit
	.full			(	rcmd2axi_asyn_fifo_full			                                                    ), 
	.empty			(	rcmd2axi_asyn_fifo_empty			                                                )
	);
    assign          rcmd2axi_asyn_fifo_din          =         rcmd_expand_cnt                                       ;  
    assign          rcmd2axi_asyn_fifo_wr_en        =         rcmd_expand_cnt_hold && !rcmd2axi_asyn_fifo_full      ;   
    //assign          rcmd2axi_asyn_fifo_rd_en        =         1                                                      ;  
    //assign                                          =         rcmd2axi_asyn_fifo_dout                               ;  

    
    
    // record req of read command valid
    generate 
    for (i = 0; i < READ_BUS_NUM; i = i + 1) begin: rcmd_vld
        always @(posedge clk_i or posedge rst_i) begin
            if(rst_i) begin
                rbus_req[i]  <= 1'b0;
            end
            else if ((rcmd_expand_cnt_hold && rcmd_expand_cnt_end) && !rcmd2axi_asyn_fifo_full && rbus_arbiter[i]) begin// the last 128 bit read compelet, then cancel the req 
                rbus_req[i]  <= 1'b0;
            end
            else if (rcmd_vld_i[i]) begin// if some bus want to read data it will strobe the vld signal,then the requst will be record to rbus_req
                rbus_req[i]  <= 1'b1;
            end
        end
    end
    endgenerate
    
    // arbiter based record of rbus_req
    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i) begin
            rbus_arbiter <=  'h2;
        end
        else if (  ((rbus_arbiter & rcmd_vld_i) == 'h0 || (rcmd_expand_cnt_hold && rcmd_expand_cnt_end && !rcmd2axi_asyn_fifo_full) ) && !( rcmd_expand_cnt_hold && !rcmd_expand_cnt_end) ) begin
            rbus_arbiter <=  {rbus_arbiter[READ_BUS_NUM-2: 0], rbus_arbiter[READ_BUS_NUM-1]};
        end
    end
    
    always @(posedge clk_i) begin
        rbus_inuse_d1    <=  |(rbus_arbiter & rcmd_vld_i);
        rbus_inuse_d2    <=   rbus_inuse_d1;
    end
    
    assign  rbus_arbiter_next    =       (rcmd_expand_cnt_hold && rcmd_expand_cnt_end && !rcmd2axi_asyn_fifo_full)  ?  {rbus_arbiter[READ_BUS_NUM-2: 0], rbus_arbiter[READ_BUS_NUM-1]} : rbus_arbiter;
    
    assign  rbus_inuse_pos       =       rbus_inuse_d1 && (~rbus_inuse_d2)                      ;       
    
    
    // use rbus_arbiter to gerater rcmd_vld_use
            // 1 bit                     // READ_BUS_NUM bit                   READ_BUS_NUM bit 
    assign  rcmd_vld_use        =       |(rcmd_vld_i[READ_BUS_NUM-1:0]   &   rbus_arbiter[READ_BUS_NUM-1:0])  ;
     // use rcmd_rdy_use and rbus_arbiter to gerater rcmd_rdy_o
            // READ_BUS_NUM bit         // 1 bit -> READ_BUS_NUM bit          READ_BUS_NUM bit
    assign  rcmd_rdy_o          =       {READ_BUS_NUM{rcmd_rdy_use}}   &   rbus_arbiter[READ_BUS_NUM-1:0]   ;    
    
    assign  raddr_use           =       rbus_arbiter_next[0] ? raddr_i[0*DDRIF_ADDR_WTH+DDRIF_ADDR_WTH-1      :  0*DDRIF_ADDR_WTH] :
                                        rbus_arbiter_next[1] ? raddr_i[1*DDRIF_ADDR_WTH+DDRIF_ADDR_WTH-1      :  1*DDRIF_ADDR_WTH] : 0;
                                        
    assign  rlen_use            =       rbus_arbiter_next[0] ? rlen_i [0*DDRIF_ALEN_WTH+DDRIF_ALEN_WTH-1      :  0*DDRIF_ALEN_WTH] :
                                        rbus_arbiter_next[1] ? rlen_i [1*DDRIF_ALEN_WTH+DDRIF_ALEN_WTH-1      :  1*DDRIF_ALEN_WTH] : 0;

    assign  rdata_o[0*DDRIF_DATA_WTH+DDRIF_DATA_WTH-1     :  0*DDRIF_DATA_WTH]             =       rdata_use            ;                                                                                      
    assign  rdata_o[1*DDRIF_DATA_WTH+DDRIF_DATA_WTH-1     :  1*DDRIF_DATA_WTH]             =       rdata_use            ;                                                                                      
                                        
    assign  rdata_last_use      =       d_rcmd_expand_cnt_hold && d_rcmd_expand_cnt_end &&  rdata_cat_cnt_end && rdata_cat_cnt_hold; 
                       

    assign  rdata_rdy_use       =    | ( rdata_rdy_i[READ_BUS_NUM-1:0]   &   rdata_bus_arbiter[READ_BUS_NUM-1:0])  ; 
    
    
    assign  rdata_vld_o          =       {READ_BUS_NUM{rdata_vld_use}}   &   rdata_bus_arbiter[READ_BUS_NUM-1:0]   ;   

     
    assign  rdata_last_o          =       {READ_BUS_NUM{rdata_last_use}}   &   rdata_bus_arbiter[READ_BUS_NUM-1:0]   ;       


   
    /************** 
	rcmd_expand_cnt    expand the raddr_i to : raddr_i -> raddr_i + rlen_i
	
	start 			: shake hand of  rcmd_vld_use && rcmd_rdy_use 
	counter state	: from raddr_i -> raddr_i + rlen_i 
	add condition	: rcmd2axi_asyn_fifo_full
	*******************/
	//assign          rcmd_expand_cnt_start_pulse     =       rcmd_expand_cnt_hold ? (rcmd_vld_use && rcmd_rdy_use &&(|(rcmd_vld_i & rbus_arbiter_next))) : ((|(rbus_arbiter & rcmd_vld_i)) && !r_bus_aribter_cmd2data_fifo_full)       ;
    assign          rcmd_expand_cnt_start_pulse     =       rcmd_vld_use && rcmd_rdy_use &&(|(rcmd_vld_i & rbus_arbiter_next))       ;
    
    assign          rcmd_rdy_use                    =       (!r_bus_aribter_cmd2data_fifo_full) && (!rcmd2axi_asyn_fifo_full) && ( (rcmd_expand_cnt_hold&&rcmd_expand_cnt_end) || !rcmd_expand_cnt_hold);



    always@(posedge clk_i or posedge rst_i)
	begin
    if(rst_i)
        begin
        rcmd_expand_cnt_start_value <= {RCMD_EXPAND_CNT_WTH{1'b1}};
        rcmd_expand_cnt_end_value   <= {RCMD_EXPAND_CNT_WTH{1'b1}};    
        end
	else if( rcmd_expand_cnt_start_pulse )
        begin
        rcmd_expand_cnt_start_value <= raddr_use;
        rcmd_expand_cnt_end_value   <= raddr_use + rlen_use;
        end
	end
    

	always@(posedge clk_i or posedge rst_i)
	begin
    if(rst_i)
       rcmd_expand_cnt_hold <= 1'b0; 
	else if( rcmd_expand_cnt_start_pulse )
        rcmd_expand_cnt_hold <= 1'b1;
	else if(rcmd_expand_cnt_end && !rcmd2axi_asyn_fifo_full )
        rcmd_expand_cnt_hold <= 1'b0;
	end
	
	always@(posedge clk_i or posedge rst_i)  begin    
    if(rst_i)
        rcmd_expand_cnt <= {RCMD_EXPAND_CNT_WTH{1'b1}};
	else if(rcmd_expand_cnt_start_pulse)
		rcmd_expand_cnt <= raddr_use;
	else if(rcmd_expand_cnt_hold && !rcmd2axi_asyn_fifo_full) 
			begin
				if(rcmd_expand_cnt_end)
					rcmd_expand_cnt <= rcmd_expand_cnt_end_value;             
				else 
					rcmd_expand_cnt <= rcmd_expand_cnt + 1'd1;         
			end
	end
	
	assign   rcmd_expand_cnt_end = (rcmd_expand_cnt == rcmd_expand_cnt_end_value); 
    reg                         rcmd_expand_cnt_start_pulse_dly0;
    always@(posedge clk_i)
    begin
    rcmd_expand_cnt_start_pulse_dly0 <= rcmd_expand_cnt_start_pulse ;
    end    
   
   
    /**********************************************read cmd end*****************************************************/
    
    
    /*****************************************************************	
	r_bus_aribter_cmd2data_fifo:    bus select from rcmd to rdata
                               when write command channel shake hand :both vld && rdy, write the arbiter result,  
                               write data channel read the data to select which channel to use
	type            : synchronous fifo
	clock field     : clk_i  100m-300m
	data  	width	: READ_BUS_NUM
	data	depth	: ??   
	
	******************************************************************/	

    // syn_fifo_nktd #(
    // .DATA_WIDTH (READ_BUS_NUM+DDRIF_ADDR_WTH+DDRIF_ALEN_WTH),
    // .DEPTH      (128 ),
    // .ALMOST_DEP (4  )
    // ) r_bus_aribter_cmd2data_fifo(
    // .clk            (   clk_i                                                               ),
    // .ngreset        (   !rst_i                                                              ),
    // .wr_en          (   r_bus_aribter_cmd2data_fifo_wr_en                                   ),  // [7:0] [15 : 8]...
    // .wr_data        (   r_bus_aribter_cmd2data_fifo_wr_data    [READ_BUS_NUM+DDRIF_ADDR_WTH+DDRIF_ALEN_WTH-1 : 0]         ),  // [i*8+7 : i*8] [i*READ_BUS_NUM+READ_BUS_NUM-1 : i*READ_BUS_NUM]
    // .rd_en          (   r_bus_aribter_cmd2data_fifo_rd_en                                   ),
    // .rd_data        (   r_bus_aribter_cmd2data_fifo_rd_data    [READ_BUS_NUM+DDRIF_ADDR_WTH+DDRIF_ALEN_WTH-1 : 0]         ),
    // .ff_empty       (   r_bus_aribter_cmd2data_fifo_empty                                   ),
    // .ff_full        (   r_bus_aribter_cmd2data_fifo_full                                    )
    // ); 

    sync_fifo #(
    .FIFO_LEN(128                                         ),
    .DATA_WTH(READ_BUS_NUM+DDRIF_ADDR_WTH+DDRIF_ALEN_WTH  ),// 2 + 26  +  16   2^6 = 64
    .ADDR_WTH(7                                           )
    ) r_bus_aribter_cmd2data_fifo (
    .clk_i             ( clk_i                                                                                                  ),
    .rst_i             ( rst_i                                                                                                  ),
    .wr_data_i         ( r_bus_aribter_cmd2data_fifo_wr_data    [READ_BUS_NUM+DDRIF_ADDR_WTH+DDRIF_ALEN_WTH-1 : 0]              ),
    .wr_en_i           ( r_bus_aribter_cmd2data_fifo_wr_en                                                                      ),
    .full_o            ( r_bus_aribter_cmd2data_fifo_full                                                                       ),
    .a_full_o          (                                                                                                        ),
    .rd_data_o         ( r_bus_aribter_cmd2data_fifo_rd_data    [READ_BUS_NUM+DDRIF_ADDR_WTH+DDRIF_ALEN_WTH-1 : 0]              ),
    .rd_en_i           ( r_bus_aribter_cmd2data_fifo_rd_en                                                                      ),
    .empty_o           ( r_bus_aribter_cmd2data_fifo_empty                                                                      ),
    .a_empty_o         (                                                                                                        )
    );
     
    
    assign              r_bus_aribter_cmd2data_fifo_wr_en           =       rcmd_expand_cnt_start_pulse_dly0       ; 
    assign              r_bus_aribter_cmd2data_fifo_wr_data         =       {rbus_arbiter,raddr_use,rlen_use}                         ; 
    assign              r_bus_aribter_cmd2data_fifo_rd_en           =       (rdata_cat_cnt_end_pre && rdata_cat_cnt_hold && d_rcmd_expand_cnt_end && d_rcmd_expand_cnt_hold && !r_bus_aribter_cmd2data_fifo_empty);//(rdata_vld_use && rdata_rdy_use) && (rdata_last_use) && (!r_bus_aribter_cmd2data_fifo_empty) ;             
    assign              rdata_len_use                               =       r_bus_aribter_cmd2data_fifo_rd_data[DDRIF_ALEN_WTH-1:0] ; 
    assign              rdata_addr_use                              =       r_bus_aribter_cmd2data_fifo_rd_data[DDRIF_ADDR_WTH+DDRIF_ALEN_WTH-1:DDRIF_ALEN_WTH] ; 
    assign              rdata_bus_arbiter                           =       r_bus_aribter_cmd2data_fifo_rd_data_dly0[READ_BUS_NUM+DDRIF_ADDR_WTH+DDRIF_ALEN_WTH-1:DDRIF_ADDR_WTH+DDRIF_ALEN_WTH] ; 
    
    always@(posedge clk_i)
    if(rdata_cat_cnt_hold)
	begin
		if(rdata_cat_cnt_add_ctn)
		begin
			r_bus_aribter_cmd2data_fifo_rd_data_dly0 <= r_bus_aribter_cmd2data_fifo_rd_data;
		end
	end
	else begin
		r_bus_aribter_cmd2data_fifo_rd_data_dly0 <= r_bus_aribter_cmd2data_fifo_rd_data;
	end

    
    
    always@(posedge clk_i)
    if(rdata_cat_cnt_hold)
	begin
		if(rdata_cat_cnt_add_ctn)
		begin
			r_bus_aribter_cmd2data_fifo_empty_dly0 <= r_bus_aribter_cmd2data_fifo_empty;
		end
	end
	else begin
		r_bus_aribter_cmd2data_fifo_empty_dly0 <= r_bus_aribter_cmd2data_fifo_empty;
	end    
    

    
    /*******************************************************************************************************************/
 
      
 
    
    
    /************** 
	rdata_cat_cnt    cat the data 512bit -> 128bit
	
	start 			: shake hand of  rdata_vld_use && rdata_rdy_use
	counter state	: from raddr_i -> raddr_i + rlen_i 
	add condition	: wcmd2axi_asyn_fifo_full
	*******************/
    
                                                             // delete the last start pulse                                            
	assign          rdata_cat_cnt_start_pulse       =       (!r_bus_aribter_cmd2data_fifo_empty)&& (rdata_cat_cnt_hold ? (rdata_vld_use && rdata_rdy_use) :  (!r_bus_aribter_cmd2data_fifo_empty_dly0 && !rdata2axi_asyn_fifo_empty ) )    ;
    assign          rdata_vld_use                   =       (!r_bus_aribter_cmd2data_fifo_empty_dly0) && (!rdata2axi_asyn_fifo_empty) && (rdata_cat_cnt_hold && rdata_cat_cnt_end);
    
    always@(posedge clk_i or posedge rst_i)
	begin
    if(rst_i)
        begin   
        rdata_tmp                    <= 0                           ;
        end
	else 
        begin
        case(rdata_cat_cnt)
        0    :  rdata_tmp[127:0  ] <= rdata2axi_asyn_fifo_dout            ;
        1    :  rdata_tmp[255:128] <= rdata2axi_asyn_fifo_dout            ;
        2    :  rdata_tmp[383:256] <= rdata2axi_asyn_fifo_dout            ;
        3    :  rdata_tmp[511:384] <= rdata2axi_asyn_fifo_dout            ;
        endcase
        end
	end
    
    assign          rdata_use             =      {rdata2axi_asyn_fifo_dout,rdata_tmp[383:0]} ;    
    
    assign          rdata_cat_cnt_add_ctn   =   (rdata_cat_cnt_end) ? (rdata_vld_use && rdata_rdy_use) : (!rdata2axi_asyn_fifo_empty );

	always@(posedge clk_i or posedge rst_i)
	begin
    if(rst_i)
       rdata_cat_cnt_hold <= 1'b0; 
	else if( rdata_cat_cnt_start_pulse )
        rdata_cat_cnt_hold <= 1'b1;
	else if(rdata_cat_cnt_end && rdata_cat_cnt_add_ctn)
        rdata_cat_cnt_hold <= 1'b0;
	end
	
	always@(posedge clk_i or posedge rst_i)  begin    
    if(rst_i)
        rdata_cat_cnt <= {RDATA_CAT_CNT_WTH{1'b1}};
	else if(rdata_cat_cnt_start_pulse)
		rdata_cat_cnt <= rdata_cat_cnt_start_value;
	else if(rdata_cat_cnt_hold && rdata_cat_cnt_add_ctn) 
			begin
				if(rdata_cat_cnt_end)
					rdata_cat_cnt <= rdata_cat_cnt_start_value;             
				else 
					rdata_cat_cnt <= rdata_cat_cnt + 1'd1;         
			end
	end
	
	assign   rdata_cat_cnt_end = (rdata_cat_cnt == rdata_cat_cnt_end_value);     
    
    assign   rdata_cat_cnt_end_pre = ((rdata_cat_cnt == rdata_cat_cnt_end_value-1) && rdata_cat_cnt_add_ctn);     
    
    
    /********************************************************************************************/
    
	
    
    /************** 
	d_rcmd_expand_cnt    expand the raddr_i to : raddr_i -> raddr_i + rlen_i
	
	start 			: shake hand of  d_rcmd_vld_use && d_rcmd_rdy_use 
	counter state	: from raddr_i -> raddr_i + rlen_i 
	add condition	: d_rcmd2axi_asyn_fifo_full
	*******************/
	assign          d_rcmd_expand_cnt_start_pulse     =       ( !d_rcmd_expand_cnt_hold  && rdata_cat_cnt_start_pulse) || (d_rcmd_expand_cnt_hold && d_rcmd_expand_cnt_end && rdata_cat_cnt_start_pulse && !r_bus_aribter_cmd2data_fifo_empty)      ;
    
    always@(posedge clk_i or posedge rst_i)
	begin
    if(rst_i)
        begin
        d_rcmd_expand_cnt_start_value <= {D_RCMD_EXPAND_CNT_WTH{1'b1}};
        d_rcmd_expand_cnt_end_value   <= {D_RCMD_EXPAND_CNT_WTH{1'b1}};    
        end
	else if( d_rcmd_expand_cnt_start_pulse )
        begin
        d_rcmd_expand_cnt_start_value <= rdata_addr_use;
        d_rcmd_expand_cnt_end_value   <= rdata_addr_use + rdata_len_use;
        end
	end
    


	always@(posedge clk_i or posedge rst_i)
	begin
    if(rst_i)
       d_rcmd_expand_cnt_hold <= 1'b0; 
	else if( d_rcmd_expand_cnt_start_pulse )
        d_rcmd_expand_cnt_hold <= 1'b1;
	else if(d_rcmd_expand_cnt_end && rdata_cat_cnt_end && rdata_cat_cnt_add_ctn )
        d_rcmd_expand_cnt_hold <= 1'b0;
	end
	
	always@(posedge clk_i or posedge rst_i)  begin    
    if(rst_i)
        d_rcmd_expand_cnt <= {D_RCMD_EXPAND_CNT_WTH{1'b1}};
	else if(d_rcmd_expand_cnt_start_pulse)
		d_rcmd_expand_cnt <= rdata_addr_use;
	else if(d_rcmd_expand_cnt_hold && rdata_cat_cnt_end && rdata_cat_cnt_add_ctn) 
			begin
				if(d_rcmd_expand_cnt_end)  
					d_rcmd_expand_cnt <=  d_rcmd_expand_cnt_end_value ;             
				else 
					d_rcmd_expand_cnt <= d_rcmd_expand_cnt + 1'd1;         
			end
	end    
    assign   d_rcmd_expand_cnt_end = (d_rcmd_expand_cnt == d_rcmd_expand_cnt_end_value); 
    /*****************************************************************	
	rdata2axi_asyn_fifo: 
            
	type                    : asynchronous fifo
	write data clock field  : clk_ddr_ui_i  ,which also is the AXI clock field 
	read  data clock field  : clk_i 100m-300m
	data  	width	: 128bit data
	data	depth	: 128 (should be corrected again)
	
	******************************************************************/	
	wdata2axi_asyn_fifo rdata2axi_asyn_fifo (
	.rst			(	rst_i					                                                            ), 
	.wr_clk			(	clk_ddr_ui_i  				                                                        ), 
	.rd_clk			(	clk_i		                                                                        ), 
	.din			(	rdata2axi_asyn_fifo_din			                                                    ), // 128bit
	.wr_en			(	rdata2axi_asyn_fifo_wr_en			                                                ), 
	.rd_en			(	rdata2axi_asyn_fifo_rd_en			                                                ), 
	.dout			(	rdata2axi_asyn_fifo_dout			                                                ), // 128bit
	.full			(	rdata2axi_asyn_fifo_full			                                                ), 
	.empty			(	rdata2axi_asyn_fifo_empty			                                                )
	);    
    
   assign           rdata2axi_asyn_fifo_rd_en = rdata_cat_cnt_hold && rdata_cat_cnt_add_ctn;
  // assign           rdata2axi_asyn_fifo_wr_en = !rdata2axi_asyn_fifo_full;//

   assign           rdata2axi_asyn_fifo_din = m_axi_rdata;
   
    /*******************************************************************************************************************/

   reg [31:0] rcmd2axi_asyn_fifo_rd_en_cnt;
    
   reg [31:0] rdata2axi_asyn_fifo_wr_en_cnt;
   reg [31:0] rdata2axi_asyn_fifo_rd_en_cnt;
    
        always@(posedge clk_ddr_ui_i or posedge rst_i)
        begin
        if(rst_i)
            rcmd2axi_asyn_fifo_rd_en_cnt <= 0;
        else if(rcmd2axi_asyn_fifo_rd_en && !rcmd2axi_asyn_fifo_empty)
            rcmd2axi_asyn_fifo_rd_en_cnt <=    rcmd2axi_asyn_fifo_rd_en_cnt + 1;
        end
        
        
        
        
        always@(posedge clk_i or posedge rst_i)
        begin
        if(rst_i)
            rdata2axi_asyn_fifo_wr_en_cnt <= 0;
        else if(rdata2axi_asyn_fifo_wr_en && !rdata2axi_asyn_fifo_full)
            rdata2axi_asyn_fifo_wr_en_cnt <=    rdata2axi_asyn_fifo_wr_en_cnt + 1;
        end    
    
    
        always@(posedge clk_ddr_ui_i or posedge rst_i)
        begin
        if(rst_i)
            rdata2axi_asyn_fifo_rd_en_cnt <= 0;
        else if(rdata2axi_asyn_fifo_rd_en && !rdata2axi_asyn_fifo_empty)
            rdata2axi_asyn_fifo_rd_en_cnt <=    rdata2axi_asyn_fifo_rd_en_cnt + 1;
        end  
//======================================================================================================================
// just for simulation
//======================================================================================================================
// synthesis translate_off

  
// synthesis translate_on

//======================================================================================================================
// probe signals
//======================================================================================================================
wire  [DDRIF_ADDR_WTH-1 : 0]            probe_raddr_i[0 : READ_BUS_NUM-1];
wire  [DDRIF_ALEN_WTH-1 : 0]            probe_rlen_i[0 : READ_BUS_NUM-1];
wire                                    probe_rcmd_vld_i[0 : READ_BUS_NUM-1];
wire                                    probe_rcmd_rdy_o[0 : READ_BUS_NUM-1];
wire  [DDRIF_DATA_WTH-1   : 0]          probe_rdata_o[0 : READ_BUS_NUM-1];
wire                                    probe_rdata_last_o[0 : READ_BUS_NUM-1];
wire                                    probe_rdata_vld_o[0 : READ_BUS_NUM-1];
wire                                    probe_rdata_rdy_i[0 : READ_BUS_NUM-1];
genvar j;

generate
for (j=0; j<READ_BUS_NUM; j=j+1) begin
    assign probe_raddr_i[j] = raddr_i[j*DDRIF_ADDR_WTH +: DDRIF_ADDR_WTH];
    assign probe_rlen_i[j] = rlen_i[j*DDRIF_ALEN_WTH +: DDRIF_ALEN_WTH];
    assign probe_rcmd_vld_i[j] = rcmd_vld_i[j];
    assign probe_rcmd_rdy_o[j] = rcmd_rdy_o[j];
    assign probe_rdata_o[j] = rdata_o[j*DDRIF_DATA_WTH +: DDRIF_DATA_WTH];
    assign probe_rdata_last_o[j] = rdata_last_o[j];
    assign probe_rdata_vld_o[j] = rdata_vld_o[j];
    assign probe_rdata_rdy_i[j] = rdata_rdy_i[j];
end
endgenerate

endmodule
