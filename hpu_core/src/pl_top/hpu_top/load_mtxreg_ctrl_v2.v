// +FHDR------------------------------------------------------------------------
// XJTU IAIR Corporation All Rights Reserved
// -----------------------------------------------------------------------------
// FILE NAME  : load_mtxreg_ctrl_v2.v
// DEPARTMENT : CAG of IAIR
// AUTHOR     : chenfei
// AUTHOR'S EMAIL :fei.chen@mail.xjtu.edu.cn
// -----------------------------------------------------------------------------
// Ver 1.0  2019--04--25
// -----------------------------------------------------------------------------
// KEYWORDS   : load_mtxreg_ctrl_v2
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

module load_mtxreg_ctrl_v2 #(
    parameter REGMAP_ADDR_WTH = 8,
    parameter REGMAP_DATA_WTH = 32,
    parameter DDRIF_ADDR_WTH = 26,
    parameter DDRIF_ALEN_WTH = 16,
    parameter DDRIF_DATA_WTH = 512,
    parameter MRX_IND_WTH = 5,
    parameter MRX_ADDR_WTH = 9,
    parameter MRA_IND_WTH = 3,
    parameter MRA_ADDR_WTH = 9,
    parameter MRB_IND_WTH = 3,
    parameter MRB_ADDR_WTH = 9,
    parameter MRC_IND_WTH = 1,
    parameter MRC_ADDR_WTH = 9,
    parameter BR_IND_WTH = 1,
    parameter BR_ADDR_WTH = 9
) (
    // clock & reset
    input                                   clk_i,
    input                                   rst_i,

    // regmap interface: from regmap_mgr module
    input [REGMAP_ADDR_WTH-1 : 0]           regmap_ldmr__waddr_i,
    input [REGMAP_DATA_WTH-1 : 0]           regmap_ldmr__wdata_i,
    input                                   regmap_ldmr__we_i,
    output                                  regmap_ldmr__intr_o,

    // to hpu_core[x] module
    output                                  ldmr_hpu_core_sel_o,
    output[4 : 0]                           ldmr_mrx__sel_o,
    output[MRA_IND_WTH-1 : 0]               ldmr_mra__windex_o,
    output[MRA_ADDR_WTH-1 : 0]              ldmr_mra__waddr_o,
    output                                  ldmr_mra__we_o,

    output[MRB_IND_WTH-1 : 0]               ldmr_mrb__windex_o,
    output[MRB_ADDR_WTH-1 : 0]              ldmr_mrb__waddr_o,
    output                                  ldmr_mrb__we_o,

    output[MRC_IND_WTH-1 : 0]               ldmr_mrc__windex_o,
    output[MRC_ADDR_WTH-1 : 0]              ldmr_mrc__waddr_o,
    output                                  ldmr_mrc__we_o,

    output[BR_IND_WTH-1 : 0]                ldmr_brb__windex_o,
    output[BR_ADDR_WTH-1 : 0]               ldmr_brb__waddr_o,
    output                                  ldmr_brb__we_o,

    output[BR_IND_WTH-1 : 0]                ldmr_brc__windex_o,
    output[BR_ADDR_WTH-1 : 0]               ldmr_brc__waddr_o,
    output                                  ldmr_brc__we_o,
    
    // ddr data to mtrx data
    output[DDRIF_DATA_WTH-1:  0]            ldmr_ddrintf__rdata_o,
    // to ddr_intf module
    output[DDRIF_ADDR_WTH-1 : 0]            ldmr_ddrintf__raddr_o,
    output[DDRIF_ALEN_WTH-1 : 0]            ldmr_ddrintf__rlen_o,
    output                                  ldmr_ddrintf__rcmd_vld_o,
    input                                   ldmr_ddrintf__rcmd_rdy_i,
    input                                   ldmr_ddrintf__rdata_last_i,
    input                                   ldmr_ddrintf__rdata_vld_i,
    input [DDRIF_DATA_WTH-1:  0]            ldmr_ddrintf__rdata_i,
    output                                  ldmr_ddrintf__rdata_rdy_o
);

//======================================================================================================================
// Wire & Reg declaration
//======================================================================================================================
localparam  CMD_WTH = 57;

reg   [1:0]                             ldmr_ctrl;
reg   [DDRIF_ADDR_WTH-1 :0]             LDMR_ADDR_SRC;
reg   [DDRIF_ALEN_WTH-1 :0]             LDMR_TRANS_LEN;
reg   [REGMAP_DATA_WTH-1:0]             LDMR_CORE_DEST;
reg   [REGMAP_DATA_WTH-1:0]             LDMR_ADDR_DEST;
reg                                     LDMR_PIC_REODER_EN;

wire                                    intr_clr;
wire                                    ld_strt;
wire                                    hpu_core_num;
wire  [MRX_IND_WTH-1 : 0]               mrx_index;
reg   [MRX_IND_WTH-1 : 0]               mrx_index_cmd;
reg   [MRX_IND_WTH-1 : 0]               mrx_index_cmd_dly1;
wire  [MRX_IND_WTH-1 : 0]               mrx_index_reoder_cmd;
wire  [8:0]                             mrx_offset;

wire  [CMD_WTH-1:0]                     fifo_cmd_din;
wire  [CMD_WTH-1:0]                     fifo_cmd_dout;
wire                                    fifo_cmd_wr;
wire                                    fifo_cmd_rd;
wire                                    fifo_cmd_empty;

reg                                     ldmr_hpu_core_sel;
reg   [4 : 0]                           ldmr_mrx_sel;
reg   [4 : 0]                           ldmr_mrx_sel_dly1;
reg   [MRA_ADDR_WTH-1 : 0]              ldmr_mrx_waddr_base;
reg   [MRA_ADDR_WTH-1 : 0]              ldmr_mrx_waddr;
wire  [DDRIF_ALEN_WTH-1 : 0]              ldmr_mrx_reoder_waddr;
wire  [MRA_ADDR_WTH-1 : 0]              ldmr_mrx_reoder_waddr_offset;
reg                                     ldmr_mrx_we;

reg   [DDRIF_ALEN_WTH-1 : 0]            ddr_trans_len;

wire  [DDRIF_ALEN_WTH-1 : 0]            mrx_waddr;
wire  [REGMAP_ADDR_WTH-1 : 0]           regmap_ldmr_waddr;
wire  [REGMAP_DATA_WTH-1 : 0]           regmap_ldmr_wdata;
wire                                    regmap_ldmr_we;
reg                                     regmap_ldmr_intr;
wire                                    regmap_ldmr_intr_reoder;

reg   [DDRIF_ALEN_WTH-1 : 0]            ddr_rlen_cnt;
reg                                     cmd_exc_valid;

(* ASYNC_REG = "true" *)reg             data_reoder_en;
wire                                    ldmr_ddrintf__rdata_reoder_rdy;
wire                                    ldmr_mrx_reoder_we; 
wire [DDRIF_DATA_WTH-1:  0]             ldmr_ddrintf__rdata_reoder_o;
reg  [DDRIF_DATA_WTH-1:  0]             ldmr_ddrintf__rdata_i_dly;
//======================================================================================================================
// Instance
//======================================================================================================================
reg_dly #(.width( REGMAP_ADDR_WTH ), .delaynum(3)) reg_dly_inst0(.clk (clk_i), .d(regmap_ldmr__waddr_i), .q(regmap_ldmr_waddr) );
reg_dly #(.width( REGMAP_DATA_WTH ), .delaynum(3)) reg_dly_inst1(.clk (clk_i), .d(regmap_ldmr__wdata_i), .q(regmap_ldmr_wdata) );
reg_dly #(.width( 1               ), .delaynum(3)) reg_dly_inst2(.clk (clk_i), .d(regmap_ldmr__we_i   ), .q(regmap_ldmr_we   ) );
//reg_dly #(.width( 1               ), .delaynum(35)) reg_dly_inst3(.clk (clk_i), .d(regmap_ldmr_intr   ), .q(regmap_ldmr_intr_dly35   ) );

fifo_cmd_1  fifo_cmd_16x57_inst0 (
    .clk   (clk_i),
    .srst  (rst_i),
    .din   (fifo_cmd_din),
    .wr_en (fifo_cmd_wr),
    .rd_en (fifo_cmd_rd),
    .dout  (fifo_cmd_dout),
    .full  (),
    .empty (fifo_cmd_empty)
);
//regs explaination

always @(posedge clk_i) begin
    if(rst_i) begin
       LDMR_ADDR_SRC <= 26'd0;
       LDMR_TRANS_LEN <= 16'd0;
       LDMR_CORE_DEST <= 32'd0;
       LDMR_ADDR_DEST <= 32'd0;
       LDMR_PIC_REODER_EN <= 1'd0;
    end else begin
        if(regmap_ldmr_we ) begin
           case(regmap_ldmr_waddr[REGMAP_ADDR_WTH-1 : 2])
            6'd1: begin  LDMR_ADDR_SRC     <= regmap_ldmr_wdata[31 : 6]; end
            6'd2: begin  LDMR_TRANS_LEN    <= regmap_ldmr_wdata[15 : 0]; end
            6'd3: begin  LDMR_CORE_DEST    <= regmap_ldmr_wdata[31 : 0]; end
            6'd4: begin  LDMR_ADDR_DEST    <= regmap_ldmr_wdata[31 : 0]; end
            6'd5: begin  LDMR_PIC_REODER_EN<= regmap_ldmr_wdata[0]     ; end
           endcase
        end
    end
end

always @(posedge clk_i) begin
    if(rst_i) begin
       ldmr_ctrl <= 2'd0;
    end else begin
        if( (regmap_ldmr_we ) && (regmap_ldmr_waddr == 8'h0) ) begin
            ldmr_ctrl <= regmap_ldmr_wdata[1 : 0];
        end else begin
            ldmr_ctrl <= 2'h0;
        end
    end
end
always  @(posedge clk_i) begin
        data_reoder_en <= LDMR_PIC_REODER_EN;
    end
assign  intr_clr =  ldmr_ctrl[1];
assign  ld_strt  =  ldmr_ctrl[0];

assign  hpu_core_num =  LDMR_CORE_DEST[0];
assign  mrx_index    =  (hpu_core_num == 1'b0) ? LDMR_ADDR_DEST[13 : 9] : LDMR_ADDR_DEST[29 : 25];
assign  mrx_offset   =  (hpu_core_num == 1'b0) ? LDMR_ADDR_DEST[8 : 0] : LDMR_ADDR_DEST[24 : 16];

//generate fifo_cmd signals
assign fifo_cmd_din = {hpu_core_num,mrx_index,mrx_offset,LDMR_ADDR_SRC,LDMR_TRANS_LEN};
assign fifo_cmd_wr  = ld_strt;
assign fifo_cmd_rd  = !fifo_cmd_empty && ldmr_ddrintf__rcmd_rdy_i && (!regmap_ldmr_intr) && (!cmd_exc_valid);

//generate ddr interface signals
assign ldmr_ddrintf__raddr_o    =  fifo_cmd_dout[(DDRIF_ADDR_WTH+DDRIF_ALEN_WTH-1):DDRIF_ALEN_WTH];
assign ldmr_ddrintf__rlen_o     =  fifo_cmd_dout[DDRIF_ALEN_WTH-1:0]-1;
assign ldmr_ddrintf__rcmd_vld_o =  !fifo_cmd_empty && (!regmap_ldmr_intr) && (!cmd_exc_valid);

always @(posedge clk_i) begin
    if(rst_i) begin
        ldmr_hpu_core_sel <=  1'b0;
        ldmr_mrx_sel <=  5'h0;
        mrx_index_cmd <=  {MRX_IND_WTH{1'b0}};
        ldmr_mrx_waddr_base <=  {MRA_ADDR_WTH{1'b0}};
        ddr_trans_len <=  {DDRIF_ALEN_WTH{1'b0}};
    end else if(fifo_cmd_rd) begin
        ldmr_hpu_core_sel <= fifo_cmd_dout[56];
        ldmr_mrx_sel <= (fifo_cmd_dout[55 : 51] < 5'h8) ? 5'b00001
                      : (fifo_cmd_dout[55 : 51] < 5'h10) ? 5'b00010
                      : (fifo_cmd_dout[55 : 51] < 5'h12) ? 5'b00100
                      : (fifo_cmd_dout[55 : 51] == 5'h12) ? 5'b01000
                      : (fifo_cmd_dout[55 : 51] == 5'h13) ? 5'b10000
                      : ldmr_mrx_sel;
        ldmr_mrx_waddr_base <= fifo_cmd_dout[50 : DDRIF_ADDR_WTH+DDRIF_ALEN_WTH];
        ddr_trans_len <= ldmr_ddrintf__rlen_o;
        mrx_index_cmd <= fifo_cmd_dout[55 : 51];
      end
//    end else if(ldmr_ddrintf__rdata_last_i && ldmr_ddrintf__rdata_rdy_o) begin
//        ldmr_hpu_core_sel <=  1'b0;
//        ldmr_mrx_sel <=  5'h0;
//        mrx_index_cmd <=  {MRX_IND_WTH{1'b0}};
//        ldmr_mrx_waddr_base <=  {MRA_ADDR_WTH{1'b0}};
//        ddr_trans_len <=  {DDRIF_ALEN_WTH{1'b0}};
//    end
end

//generate the cmd_exc_valid
always @(posedge clk_i) begin
    if(rst_i) begin
        cmd_exc_valid <= 1'b0;
    end else if(ldmr_ddrintf__rdata_last_i && ldmr_ddrintf__rdata_rdy_o) begin
        cmd_exc_valid <= 1'b0;
    end else if(fifo_cmd_rd) begin
        cmd_exc_valid <= 1'b1;
    end
end
assign ldmr_ddrintf__rdata_rdy_o = ((ddr_rlen_cnt <= ddr_trans_len) && cmd_exc_valid) ? (data_reoder_en ? ldmr_ddrintf__rdata_reoder_rdy : 1'b1 ): 1'b0;

always @(posedge clk_i) begin
    if(rst_i) begin
        ddr_rlen_cnt <= {DDRIF_ALEN_WTH{1'b0}};
    end else if(ldmr_ddrintf__rdata_last_i && ldmr_ddrintf__rdata_rdy_o) begin
        ddr_rlen_cnt <= {DDRIF_ALEN_WTH{1'b0}};
    end else if(ldmr_ddrintf__rdata_vld_i && ldmr_ddrintf__rdata_rdy_o) begin
        ddr_rlen_cnt <= ddr_rlen_cnt + 1;
    end
end

//generate the mtrx reg address
assign mrx_waddr = ldmr_mrx_waddr_base + ddr_rlen_cnt;
always @(posedge clk_i) begin
    if(rst_i) begin
        ldmr_mrx_waddr <= 'h0;
        ldmr_mrx_we <= 1'b0;
        ldmr_mrx_sel_dly1 <= 4'h0;
        mrx_index_cmd_dly1 <= 'h0;
    end else begin
        ldmr_mrx_waddr <= mrx_waddr[MRX_ADDR_WTH-1 : 0];
        ldmr_mrx_we <= ldmr_ddrintf__rdata_vld_i && ldmr_ddrintf__rdata_rdy_o;
        ldmr_mrx_sel_dly1 <= ldmr_mrx_sel;
        mrx_index_cmd_dly1 <= mrx_index_cmd + mrx_waddr[DDRIF_ALEN_WTH-1 : MRX_ADDR_WTH];
    end
end

assign  mrx_index_reoder_cmd = mrx_index_cmd + ldmr_mrx_reoder_waddr[DDRIF_ALEN_WTH-1 : MRX_ADDR_WTH];
assign  ldmr_mrx_reoder_waddr =  ldmr_mrx_waddr_base + ldmr_mrx_reoder_waddr_offset;

assign ldmr_mrx__sel_o = ldmr_mrx_sel_dly1;
assign ldmr_hpu_core_sel_o = ldmr_hpu_core_sel;

assign ldmr_mra__windex_o = ldmr_mrx__sel_o[0] ?(data_reoder_en ? mrx_index_reoder_cmd : mrx_index_cmd_dly1[2:0] ): 3'd0;
assign ldmr_mra__waddr_o = ldmr_mrx__sel_o[0] ? (data_reoder_en ? ldmr_mrx_reoder_waddr[MRX_ADDR_WTH-1 : 0] :ldmr_mrx_waddr): 'd0;
assign ldmr_mra__we_o = ldmr_mrx__sel_o[0] ? (data_reoder_en ? ldmr_mrx_reoder_we :ldmr_mrx_we ): 'd0;

assign ldmr_mrb__windex_o = ldmr_mrx__sel_o[1] ? (data_reoder_en ? mrx_index_reoder_cmd - 'h8 : mrx_index_cmd_dly1 - 'h8 ): 3'd0;
assign ldmr_mrb__waddr_o = ldmr_mrx__sel_o[1] ? (data_reoder_en ? ldmr_mrx_reoder_waddr[MRX_ADDR_WTH-1 : 0] :ldmr_mrx_waddr): 'd0;
assign ldmr_mrb__we_o = ldmr_mrx__sel_o[1] ? (data_reoder_en ? ldmr_mrx_reoder_we :ldmr_mrx_we ) : 'd0;

assign ldmr_mrc__windex_o = ldmr_mrx__sel_o[2] ? (data_reoder_en ? mrx_index_reoder_cmd - 'h10 : mrx_index_cmd_dly1 - 'h10) : 1'b0;
assign ldmr_mrc__waddr_o = ldmr_mrx__sel_o[2] ? (data_reoder_en ? ldmr_mrx_reoder_waddr[MRX_ADDR_WTH-1 : 0] :ldmr_mrx_waddr): 'd0;
assign ldmr_mrc__we_o = ldmr_mrx__sel_o[2] ? (data_reoder_en ? ldmr_mrx_reoder_we :ldmr_mrx_we ) : 'd0;

assign ldmr_brb__windex_o = ldmr_mrx__sel_o[3] ? (data_reoder_en ? mrx_index_reoder_cmd - 'h12 : mrx_index_cmd_dly1 - 'h12) : 1'b0;
assign ldmr_brb__waddr_o = ldmr_mrx__sel_o[3] ? (data_reoder_en ? ldmr_mrx_reoder_waddr[MRX_ADDR_WTH-1 : 0] :ldmr_mrx_waddr): 'd0;
assign ldmr_brb__we_o = ldmr_mrx__sel_o[3] ? (data_reoder_en ? ldmr_mrx_reoder_we :ldmr_mrx_we ) : 'd0;

assign ldmr_brc__windex_o = ldmr_mrx__sel_o[4] ? (data_reoder_en ? mrx_index_reoder_cmd - 'h13 : mrx_index_cmd_dly1 - 'h13) : 1'b0;
assign ldmr_brc__waddr_o = ldmr_mrx__sel_o[4] ? (data_reoder_en ? ldmr_mrx_reoder_waddr[MRX_ADDR_WTH-1 : 0] :ldmr_mrx_waddr): 'd0;
assign ldmr_brc__we_o = ldmr_mrx__sel_o[4] ? (data_reoder_en ? ldmr_mrx_reoder_we :ldmr_mrx_we ) : 'd0;

//generate the intr signal
always @(posedge clk_i) begin
    if(rst_i) begin
        regmap_ldmr_intr <= 1'b0;
    end else if(intr_clr) begin
        regmap_ldmr_intr <= 1'b0;
    end else if(ldmr_ddrintf__rdata_last_i && ldmr_ddrintf__rdata_rdy_o ) begin
        regmap_ldmr_intr <= 1'b1;
    end 
end
assign regmap_ldmr__intr_o = data_reoder_en ?  regmap_ldmr_intr_reoder  :regmap_ldmr_intr;


//add pal_reoder_pic module for the first image reodering

pal_reoder_pic #(
    .DDRIF_DATA_WTH     (DDRIF_DATA_WTH),
    .MRA_ADDR_WTH       (MRA_ADDR_WTH),
    .PAL_W_NUM          (8),
    .PAL_C_EXTEN_NUM    (16),
    .PIC_LINE_LEN       (320)
) pal_reoder_pic_inst (
    // clock & reset
    .clk_i                                  (clk_i),
    .rst_i                                  (rst_i),
    .intr_clr_i                             (intr_clr),
    .regmap_ldmr_intr_reoder_o              (regmap_ldmr_intr_reoder),
    // data reoder enable
    .reoder_en_i                            (data_reoder_en),
    // to mtrix write enable
    .ldmr_mrx__we_o                         (ldmr_mrx_reoder_we ),
    .ldmr_mrx__waddr_o                      (ldmr_mrx_reoder_waddr_offset ),
    // to mtrix data          
    .ldmr_ddrintf__rdata_o                  (ldmr_ddrintf__rdata_reoder_o),
    // to ddr_intf module
    .ldmr_ddrintf__rdata_last_i             (ldmr_ddrintf__rdata_last_i),
    .ldmr_ddrintf__rdata_vld_i              (ldmr_ddrintf__rdata_vld_i),
    .ldmr_ddrintf__rdata_i                  (ldmr_ddrintf__rdata_i),
    .ldmr_ddrintf__rdata_rdy_o              (ldmr_ddrintf__rdata_reoder_rdy)
);
always  @(posedge clk_i)begin
     ldmr_ddrintf__rdata_i_dly <= ldmr_ddrintf__rdata_i;
end
assign   ldmr_ddrintf__rdata_o = data_reoder_en   ? ldmr_ddrintf__rdata_reoder_o :ldmr_ddrintf__rdata_i ;
//======================================================================================================================
// just for simulation
//======================================================================================================================
// synthesis translate_off

// synthesis translate_on

//======================================================================================================================
// probe signals
//======================================================================================================================
endmodule


