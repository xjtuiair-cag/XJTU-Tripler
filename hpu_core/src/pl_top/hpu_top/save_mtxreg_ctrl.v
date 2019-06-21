`timescale 1ns / 1ps
// +FHDR------------------------------------------------------------------------
// XJTU IAIR Corporation All Rights Reserved
// -----------------------------------------------------------------------------
// FILE NAME  : save_mtxreg_ctrl.v
// DEPARTMENT : CAG of IAIR
// AUTHOR     : chenfei
// AUTHOR'S EMAIL :fei.chen@mail.xjtu.edu.cn
// -----------------------------------------------------------------------------
// Ver 1.0  2018--12--03
// -----------------------------------------------------------------------------
// KEYWORDS   : save_mtxreg_ctrl
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
module save_mtxreg_ctrl #(
    parameter REGMAP_ADDR_WTH = 8,
    parameter REGMAP_DATA_WTH = 32,
    parameter DDRIF_ADDR_WTH = 26,
    parameter DDRIF_ALEN_WTH = 16,
    parameter DDRIF_DATA_WTH = 512,
    parameter DDRIF_DSTROB_WTH = DDRIF_DATA_WTH/8,
    parameter MRX_IND_WTH = 5,
    parameter MRX_ADDR_WTH = 9,
    parameter MRA_IND_WTH = 3,
    parameter MRA_ADDR_WTH = 9,
    parameter MRB_IND_WTH = 1,
    parameter MRB_ADDR_WTH = 9
) (
    // clock & reset
    input                                   clk_i,
    input                                   rst_i,

    // regmap interface: from regmap_mgr module
    input [REGMAP_ADDR_WTH-1 : 0]           regmap_svmr__waddr_i,////may be used just 0-15 addrs for 16 kinds functions; can be defined uniform
    input [REGMAP_DATA_WTH-1 : 0]           regmap_svmr__wdata_i,
    input                                   regmap_svmr__we_i,
    output                                  regmap_svmr__intr_o,//level active;and be clear by the mpu through regmap_svmr_waddr_i and regmap_svmr_wdata_i

    // to hpu_core[x] module
    output                                  svmr_hpu_core_sel_o,
    output[MRA_IND_WTH-1 : 0]               svmr_mra__rindex_o,
    output[MRA_ADDR_WTH-1 : 0]              svmr_mra__raddr_o,
    output                                  svmr_mra__re_o,

    //to matrix data fifo
    output                                  mtxreg_data_we_o,
    output                                  mtxreg_data_re_o,
    input                                   mtxreg_data_full_i,
    input                                   mtxreg_data_empty_i,

    // to ddr_intf module
       output[DDRIF_ADDR_WTH-1 : 0]            svmr_ddrintf__waddr_o,
      output[DDRIF_ALEN_WTH-1 : 0]            svmr_ddrintf__wlen_o,
      output                                  svmr_ddrintf__wcmd_vld_o,
      input                                   svmr_ddrintf__wcmd_rdy_i,
      output[DDRIF_DSTROB_WTH-1 : 0]          svmr_ddrintf__wdata_strob_o,
     output                                  svmr_ddrintf__wdata_last_o,
     output                                  svmr_ddrintf__wdata_vld_o,
     input                                   svmr_ddrintf__wdata_rdy_i
);

//======================================================================================================================
// Wire & Reg declaration
//======================================================================================================================
localparam  CMD_WTH = 57;

reg   [1:0]                            svmr_ctrl;
reg   [DDRIF_ADDR_WTH-1 :0]            SVMR_ADDR_DEST;
reg   [DDRIF_ALEN_WTH-1 :0]            SVMR_TRANS_LEN;
reg   [REGMAP_DATA_WTH-1:0]            SVMR_CORE_SRC;
reg   [REGMAP_DATA_WTH-1:0]            SVMR_ADDR_SRC;

wire                                   intr_clr;
wire                                   sv_strt;
wire                                   hpu_core_num;
wire  [4:0]                            mrx_index;
reg   [4:0]                            mrx_index_cmd;
wire  [8:0]                            mrx_offset;

wire  [CMD_WTH-1:0]                    fifo_cmd_din;
wire  [CMD_WTH-1:0]                    fifo_cmd_dout;
wire                                   fifo_cmd_wr;
wire                                   fifo_cmd_rd;
wire                                   fifo_cmd_rd_dly;
wire                                   fifo_cmd_empty;

reg                                    svmr_hpu_core_sel;
reg   [4 : 0]                          svmr_mrx_sel;
reg   [MRA_ADDR_WTH-1 : 0]             svmr_mrx_raddr_base;
wire  [MRA_ADDR_WTH-1 : 0]             svmr_mrx_raddr;
wire                                   svmr_mrx_re;
wire                                   svmr_mrx_re_dly;

reg   [DDRIF_ALEN_WTH-1 : 0]           ddr_trans_len;

wire  [REGMAP_ADDR_WTH-1 : 0]          regmap_svmr_waddr;
wire  [REGMAP_DATA_WTH-1 : 0]          regmap_svmr_wdata;
wire                                   regmap_svmr_we;
reg                                    regmap_svmr_intr;

reg   [DDRIF_ALEN_WTH-1 : 0]           ddr_wlen_cnt;
reg   [DDRIF_ALEN_WTH-1 : 0]           pre_wlen_cnt;

reg                                    cmd_exc_valid;

//======================================================================================================================
// Instance
//======================================================================================================================
reg_dly #(.width( REGMAP_ADDR_WTH ), .delaynum(3)) reg_dly_inst0 (.clk(clk_i), .d(regmap_svmr__waddr_i), .q(regmap_svmr_waddr) );
reg_dly #(.width( REGMAP_DATA_WTH ), .delaynum(3)) reg_dly_inst1 (.clk(clk_i), .d(regmap_svmr__wdata_i), .q(regmap_svmr_wdata) );
reg_dly #(.width( 1               ), .delaynum(3)) reg_dly_inst2 (.clk(clk_i), .d(regmap_svmr__we_i   ), .q(regmap_svmr_we   ) );

fifo_cmd_1  fifo_cmd_16x57_inst0 (
    .clk   (clk_i          ),
    .srst  (rst_i          ),
    .din   (fifo_cmd_din   ),
    .wr_en (fifo_cmd_wr    ),
    .rd_en (fifo_cmd_rd    ),
    .dout  (fifo_cmd_dout  ),
    .full  (               ),
    .empty (fifo_cmd_empty )
);
//regs explaination

always @(posedge clk_i) begin
    if(rst_i) begin
        SVMR_ADDR_DEST    <= 26'd0;
        SVMR_TRANS_LEN    <= 16'd0;
        SVMR_ADDR_SRC     <= 32'd0;
    end else if(regmap_svmr_we ) begin
        case(regmap_svmr_waddr[REGMAP_ADDR_WTH-1 : 2])
            6'd1 : begin  SVMR_ADDR_DEST    <= regmap_svmr_wdata[31:6 ]   ; end
            6'd2 : begin  SVMR_TRANS_LEN    <= regmap_svmr_wdata[15:0 ]   ; end
            6'd3 : begin  SVMR_CORE_SRC     <= regmap_svmr_wdata[31:0 ]   ; end
            6'd4 : begin  SVMR_ADDR_SRC     <= regmap_svmr_wdata[31:0 ]   ; end
        endcase
    end
end

always @(posedge clk_i) begin
    if(rst_i) begin
        svmr_ctrl <= 2'd0;
    end else begin
        if( (regmap_svmr_we) && (regmap_svmr_waddr == 'h0) ) begin
            svmr_ctrl <= regmap_svmr_wdata[1:0];
        end else begin
            svmr_ctrl <= 2'h0;
        end
    end
end

assign  intr_clr =  svmr_ctrl[1];
assign  sv_strt  =  svmr_ctrl[0];

assign  hpu_core_num =  SVMR_CORE_SRC[0];
assign  mrx_index    =  (hpu_core_num == 1'b0) ? SVMR_ADDR_SRC[13 : 9] : SVMR_ADDR_SRC[29 : 25];
assign  mrx_offset   =  (hpu_core_num == 1'b0) ? SVMR_ADDR_SRC[8 : 0] : SVMR_ADDR_SRC[24 : 16];

//generate fifo_cmd signals
assign fifo_cmd_din = {hpu_core_num, mrx_index, mrx_offset, SVMR_ADDR_DEST, SVMR_TRANS_LEN};
assign fifo_cmd_wr  = sv_strt;
assign fifo_cmd_rd  = !fifo_cmd_empty && svmr_ddrintf__wcmd_rdy_i && (!regmap_svmr_intr) && (!cmd_exc_valid);

//generate ddr interface signals
assign svmr_ddrintf__waddr_o    =  fifo_cmd_dout[(DDRIF_ADDR_WTH+DDRIF_ALEN_WTH-1) : DDRIF_ALEN_WTH];
assign svmr_ddrintf__wlen_o     =  fifo_cmd_dout[DDRIF_ALEN_WTH-1 : 0] - 1;
assign svmr_ddrintf__wcmd_vld_o =  !fifo_cmd_empty && (!regmap_svmr_intr) && (!cmd_exc_valid);

always @(posedge clk_i) begin
    if(rst_i) begin
        svmr_hpu_core_sel <= 1'b0;
        svmr_mrx_sel <= 5'b0;
        mrx_index_cmd <= {MRX_IND_WTH{1'b0}};
        svmr_mrx_raddr_base <= {MRA_ADDR_WTH{1'b0}};
        ddr_trans_len <= {DDRIF_ALEN_WTH{1'b0}};
    end else begin
        if(fifo_cmd_rd) begin
            svmr_hpu_core_sel <= fifo_cmd_dout[56];
            svmr_mrx_sel <= (fifo_cmd_dout[55:51] < 5'd8 ) ? 5'b00001
                          : (fifo_cmd_dout[55:51] < 5'd16) ? 5'b00010
                          : (fifo_cmd_dout[55:51] < 5'd18) ? 5'b00100
                          : (fifo_cmd_dout[55:51] == 5'd19) ? 5'b01000
                          : (fifo_cmd_dout[55:51] == 5'd20) ? 5'b10000
                          : svmr_mrx_sel;
            svmr_mrx_raddr_base <= fifo_cmd_dout[50 : DDRIF_ADDR_WTH+DDRIF_ALEN_WTH];
            ddr_trans_len <= svmr_ddrintf__wlen_o;
            mrx_index_cmd <= fifo_cmd_dout[55 : 51];
        end else if(svmr_ddrintf__wdata_last_o && svmr_ddrintf__wdata_rdy_i) begin
            svmr_hpu_core_sel <= 1'b0;
            svmr_mrx_sel <= 5'h0;
            mrx_index_cmd <= {MRX_IND_WTH{1'b0}};
            svmr_mrx_raddr_base <= {MRA_ADDR_WTH{1'b0}};
            ddr_trans_len <= {DDRIF_ALEN_WTH{1'b0}};
        end
    end
end

always @(posedge clk_i) begin
    if(rst_i) begin
        ddr_wlen_cnt <= {DDRIF_ALEN_WTH{1'b0}};
    end else if(svmr_ddrintf__wdata_last_o && svmr_ddrintf__wdata_rdy_i) begin
        ddr_wlen_cnt <= {DDRIF_ALEN_WTH{1'b0}};
    end else if(svmr_ddrintf__wdata_vld_o && svmr_ddrintf__wdata_rdy_i ) begin
        ddr_wlen_cnt <= ddr_wlen_cnt + 1;
    end
end

always @(posedge clk_i) begin
    if(rst_i) begin
        pre_wlen_cnt <= {DDRIF_ALEN_WTH{1'b0}};
    end else if(svmr_ddrintf__wdata_last_o && svmr_ddrintf__wdata_rdy_i) begin
        pre_wlen_cnt <= {DDRIF_ALEN_WTH{1'b0}};
    end else if(svmr_mrx_re) begin
        pre_wlen_cnt <= pre_wlen_cnt + 1;
    end
end

//generate the cmd_exc_valid
always @(posedge clk_i) begin
    if(rst_i) begin
        cmd_exc_valid <= 1'b0;
    end else if(svmr_ddrintf__wdata_last_o && svmr_ddrintf__wdata_rdy_i) begin
        cmd_exc_valid <= 1'b0;
    end else if(fifo_cmd_rd) begin
        cmd_exc_valid <= 1'b1;
    end
end

//generate the mtrx reg address
assign  svmr_mrx_raddr  = svmr_mrx_raddr_base + pre_wlen_cnt;
//always @(posedge clk_i) begin
//    if(rst_i) begin
//        svmr_mrx_re <= 1'b0;
//    end else if(!mtxreg_data_full_i && (pre_wlen_cnt <= ddr_trans_len) && (ddr_trans_len !=0) && cmd_exc_valid ) begin //mtxreg_data_full is program full of fifo,and has two threshold
//        svmr_mrx_re <= 1'b1;
//    end else begin
//        svmr_mrx_re <= 1'b0;
//    end
// end
assign svmr_mrx_re = (!mtxreg_data_full_i && (pre_wlen_cnt <= ddr_trans_len) && (ddr_trans_len !=0) && cmd_exc_valid ) ? 1'b1 : 1'b0;

//becasue svmr_mrx_re is 4 clks before the matrix reg data out , so delay 4 clks to sync the data
reg_dly #(.width(1), .delaynum(4)) reg_dly_inst3 (.clk(clk_i), .d(svmr_mrx_re), .q(svmr_mrx_re_dly) );

assign mtxreg_data_we_o = svmr_mrx_re_dly;

assign mtxreg_data_re_o = !mtxreg_data_empty_i && svmr_ddrintf__wdata_rdy_i;
assign svmr_ddrintf__wdata_vld_o   = !mtxreg_data_empty_i;
assign svmr_ddrintf__wdata_last_o  = svmr_ddrintf__wdata_vld_o && (ddr_wlen_cnt == ddr_trans_len);

assign svmr_ddrintf__wdata_strob_o = 64'hffffffffffffffff;

//generate hpu_core signals

assign svmr_hpu_core_sel_o   =  svmr_hpu_core_sel;

assign svmr_mra__rindex_o = svmr_mrx_sel[0] ? mrx_index_cmd[2:0] : 3'd0;
assign svmr_mra__raddr_o  = svmr_mrx_sel[0] ? svmr_mrx_raddr: 'd0;
assign svmr_mra__re_o     = svmr_mrx_sel[0] ? svmr_mrx_re   : 'd0;

//generate the intr signal
always @(posedge clk_i) begin
    if(rst_i) begin
        regmap_svmr_intr <= 1'b0;
    end else if(intr_clr) begin
        regmap_svmr_intr <= 1'b0;
    end else if(svmr_ddrintf__wdata_last_o && svmr_ddrintf__wdata_rdy_i) begin
        regmap_svmr_intr <= 1'b1;
    end
end
assign regmap_svmr__intr_o = regmap_svmr_intr;

//======================================================================================================================
// just for simulation
//======================================================================================================================
// synthesis translate_off

// synthesis translate_on

//======================================================================================================================
// probe signals
//======================================================================================================================

endmodule

