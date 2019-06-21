// +FHDR------------------------------------------------------------------------
// XJTU IAIR Corporation All Rights Reserved
// -----------------------------------------------------------------------------
// FILE NAME  : pl_regs.v
// DEPARTMENT : CAG of IAIR
// AUTHOR     : chenfei
// AUTHOR'S EMAIL :fei.chen@mail.xjtu.edu.cn
// -----------------------------------------------------------------------------
// Ver 1.0  2018--12--03
// -----------------------------------------------------------------------------
// KEYWORDS   : pl_regs
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
// FILE NAME  : pl_regs.v
// DEPARTMENT : CAG of IAIR
// AUTHOR     : chenfei
// AUTHOR'S EMAIL :fei.chen@mail.xjtu.edu.cn
// -----------------------------------------------------------------------------
// Ver 1.0  2019--02--20
// -----------------------------------------------------------------------------
// KEYWORDS   :pl_regs
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
module pl_regs
#(
 parameter TCQ 						= 0.1,
 parameter ASYNC_RESET 				= 0
)
(
    //clk and reset
    input                                   clk_i,
    input                                   rst_i,

    //from ps interface
    input [15:0]                            ps_rvram__addr_i,
    input [31:0]                            ps_rvram__din_i,
    output[31:0]                            ps_rvram__dout_o,
    input                                   ps_rvram__en_i,
    input                                   ps_rvram__rst_i,
    input                                   ps_rvram__we_i,
    
    //translation the regs to pl
    
    output reg                              ps_riscv__start_conv_o,
    
    //from ps to indict the ps data is weights or image
    output reg [1 : 0]                      ps_data_indict_o,  // no use zu3
    //chenfei add for test instrction fetch enable 20190219 begin
    output reg                              ps_pl_fetch_en_o,  
    //chenfei add for test instrction fetch enable 20190219 end
    //from ps to indict the ps download data to itcm or dtcm
    output reg                              ps_dl_itcm_indict_o, // no use zu3
    output reg                              ps_dl_dtcm_indict_o,  // no use zu3
    //Reserved regs
    input [31:0]                            Res_regs0,   
    input [31:0]                            Res_regs1,
    input [31:0]                            Res_regs2,
    input [31:0]                            Res_regs3,
    input [31:0]                            Res_regs4,
    input [31:0]                            Res_regs5,
    input [31:0]                            Res_regs6,
    input [31:0]                            Res_regs7,
    // zbr addr 20190409
    output [31:0]                           ps_ddr_intf_base_addr_o,  // just use [28:0] total [31:0],
    input                                   fshflg_ps_i
 );

localparam DPU_VERSION   = 16'd0  ;  
localparam DPU_DATE      = 16'd16 ;  
localparam DPU_CTRL      = 16'd32 ;  
localparam DPU_REG00     = 16'd48 ;  
localparam DPU_REG01     = 16'd64 ;  
localparam DPU_REG02     = 16'd80 ;  
localparam DPU_REG03     = 16'd96 ;  
localparam DPU_REG04     = 16'd112;  
localparam DPU_REG05     = 16'd128;  
localparam DPU_REG06     = 16'd144;  
localparam DPU_REG07     = 16'd160;  
localparam DPU_REG08     = 16'd176;  
localparam DPU_REG09     = 16'd192;  
localparam DPU_REG10     = 16'd208;  
localparam DPU_REG11     = 16'd224;  
localparam DPU_REG12     = 16'd240;  
localparam DPU_REG13     = 16'd256;
localparam DPU_REG14     = 16'd272;   // data for riscv
localparam DPU_REG15     = 16'd288;   // instrction for riscv

wire reset_synced;
wire reg_wr_en_i;
wire reg_rd_en_i;
wire reset_i;

wire [31:0] reg_wr_data_i;
reg  [31:0] reg_rd_data_o;
wire [15:0] reg_wr_addr_i;

// zbr addr 20190409
reg    [31:0] ps_ddr_intf_base_addr  ;

reg  fshflg_ps_r;

always @(posedge clk_i) begin
    if(reset_synced)
       begin
       fshflg_ps_r  <= 1'b0;
       end
    else if(fshflg_ps_i == 1)// interrutp pulse change to level signal 
        begin
        fshflg_ps_r  <= 1'b1;
        end
    else if(reg_wr_en_i  && reg_wr_addr_i[15:0] == DPU_REG02 && reg_wr_data_i[0] == 1'b1)
            begin
            fshflg_ps_r  <= 1'b0;
            end        
end       


assign ps_ddr_intf_base_addr_o = ps_ddr_intf_base_addr  ; // just use [28:0] total [31:0]



assign reset_i = ps_rvram__rst_i;
assign reg_wr_data_i    = ps_rvram__din_i;
assign ps_rvram__dout_o = reg_rd_data_o;
assign reg_wr_addr_i    = ps_rvram__addr_i;

assign reg_wr_en_i = ps_rvram__en_i && (ps_rvram__we_i );
assign reg_rd_en_i = ps_rvram__en_i && (~ps_rvram__we_i);


generate
    if (ASYNC_RESET) begin
        (* ASYNC_REG = "true" *)
        reg     [ 3: 0]     reset_sync = 4'hf;        
        always @(posedge clk_i or posedge reset_i) begin
            if (reset_i) begin
                reset_sync      <= #TCQ 4'hf;
            end
            else begin
                reset_sync      <= #TCQ reset_sync<<1;
            end
        end
        
        assign reset_synced = reset_sync[3];
    end
    else begin
        assign reset_synced = reset_i;
    end
endgenerate


always @(posedge clk_i) begin
    if(reset_synced)
       begin
         ps_riscv__start_conv_o <= 'h0;
         ps_data_indict_o       <= 'h0;
         ps_pl_fetch_en_o       <= 'h0;
         ps_dl_itcm_indict_o    <= 'h0;
         ps_dl_dtcm_indict_o    <= 'h0;
       end        
	else if (reg_wr_en_i) begin //write regs
		case(reg_wr_addr_i[15:0])
        DPU_CTRL: begin
                  ps_riscv__start_conv_o <= reg_wr_data_i[0] ;
                  ps_data_indict_o       <= reg_wr_data_i[2:1] ;
                  ps_pl_fetch_en_o       <= reg_wr_data_i[3] ;
                  ps_dl_itcm_indict_o    <= reg_wr_data_i[4] ;  // no use for zu3  16'h80 to itcm
                  ps_dl_dtcm_indict_o    <= reg_wr_data_i[5] ;  // no use for zu3  16'h81 to dtcm                      
                  end
        // zbr addr 20190409 
        DPU_REG00://16'h0c
                   begin
                   ps_ddr_intf_base_addr  <= reg_wr_data_i[31:0];  // just use [28:0] total [31:0]
                   end       
		endcase
	end
	else if (reg_rd_en_i) begin //read regs
	    case(reg_wr_addr_i[15:0])	        
	        DPU_VERSION:   begin reg_rd_data_o <=    32'h1B010001       ;end
	        DPU_DATE   :   begin reg_rd_data_o <=    32'h20190221       ;end
	        DPU_CTRL   :   begin
	                          reg_rd_data_o    <= {26'h0,ps_dl_dtcm_indict_o,ps_dl_itcm_indict_o,
	                                               ps_pl_fetch_en_o,ps_data_indict_o,
	                                               ps_riscv__start_conv_o}  ;
	                       end
	        DPU_REG00  :   begin reg_rd_data_o <=   {30'h0,rst_i}       ;end
	        DPU_REG01  :   begin reg_rd_data_o <=   Res_regs1       ;end  // 16'h10;
	        DPU_REG02  :   begin reg_rd_data_o <=   {31'd0,fshflg_ps_r}       ;end
	        DPU_REG03  :   begin reg_rd_data_o <=   Res_regs3       ;end
	        DPU_REG04  :   begin reg_rd_data_o <=   Res_regs4       ;end
	        DPU_REG05  :   begin reg_rd_data_o <=   Res_regs5       ;end
	        DPU_REG06  :   begin reg_rd_data_o <=   Res_regs6       ;end
	        DPU_REG07  :   begin reg_rd_data_o <=   Res_regs7       ;end
	        DPU_REG08  :   begin reg_rd_data_o <=   32'h0           ;end
	        DPU_REG09  :   begin reg_rd_data_o <=   32'h0           ;end
	        DPU_REG10  :   begin reg_rd_data_o <=   32'h0           ;end
	        DPU_REG11  :   begin reg_rd_data_o <=   32'h0           ;end
	        DPU_REG12  :   begin reg_rd_data_o <=   32'h0           ;end
	        DPU_REG13  :   begin reg_rd_data_o <=   32'h0           ;end     	        	        	        
	    endcase
		
end
end
 endmodule
