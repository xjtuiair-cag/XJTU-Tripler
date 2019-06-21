// +FHDR------------------------------------------------------------------------
// XJTU IAIR Corporation All Rights Reserved
// -----------------------------------------------------------------------------
// FILE NAME  : dwc_ctrl.v
// DEPARTMENT : CAG of IAIR
// AUTHOR     : XXXX
// AUTHOR'S EMAIL :XXXX@mail.xjtu.edu.cn
// -----------------------------------------------------------------------------
// Ver 1.0  2019--01--01 initial version.
// -----------------------------------------------------------------------------
// KEYWORDS   : depth-wise calc, controlling,
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

module dwc_ctrl #(
    parameter REGMAP_ADDR_WTH = 8,
    parameter REGMAP_DATA_WTH = 32,
    parameter MRX_IND_WTH = 5,
    parameter MRX_ADDR_WTH = 9
) (
    // clock & reset
    input                                   clk_i,
    input                                   rst_i,

    // from register_map module
    input [REGMAP_ADDR_WTH-1 : 0]           regmap_dwc__waddr_i,
    input [REGMAP_DATA_WTH-1 : 0]           regmap_dwc__wdata_i,
    input                                   regmap_dwc__we_i,
    output                                  regmap_dwc__intr_o,

    // to vputy_ctrl module
    output[4 : 0]                           dwcctl_vputy__code_o,
    output                                  dwcctl_vputy0__mrs0_sl_o,
    output                                  dwcctl_vputy0__mrs0_sr_o,
    output[MRX_IND_WTH-1 : 0]               dwcctl_vputy0__mrs0_index_o,
    output[MRX_ADDR_WTH-1 : 0]              dwcctl_vputy0__mrs0_addr_o,
    output                                  dwcctl_vputy1__mrs0_sl_o,
    output                                  dwcctl_vputy1__mrs0_sr_o,
    output[MRX_IND_WTH-1 : 0]               dwcctl_vputy1__mrs0_index_o,
    output[MRX_ADDR_WTH-1 : 0]              dwcctl_vputy1__mrs0_addr_o,
    output[MRX_IND_WTH-1 : 0]               dwcctl_vputy__mrs1_index_o,
    output[MRX_ADDR_WTH-1 : 0]              dwcctl_vputy__mrs1_addr_o,
    output[5 : 0]                           dwcctl_vputy__sv_code_o,
    output[MRX_IND_WTH-1 : 0]               dwcctl_vputy__br_index_o,
    output[MRX_ADDR_WTH-1 : 0]              dwcctl_vputy__br_addr_o,
    output[4 : 0]                           dwcctl_vputy__clip_o,
    output[0 : 0]                           dwcctl_vputy__shfl_o,
    output[MRX_IND_WTH-1 : 0]               dwcctl_vputy__mrd_index_o,
    output[MRX_ADDR_WTH-1 : 0]              dwcctl_vputy__mrd_addr_o,
    output[7 : 0]                           dwcctl_vputy__strobe_h_o
);

//======================================================================================================================
// Wire & Reg declaration
//======================================================================================================================
localparam SET_START = 0;
localparam CLR_INTR = 1;

localparam OP_LOAD = 5'b00001;
localparam OP_MUL  = 5'b00011;
localparam OP_ACC  = 5'b00101;
localparam OP_MACC = 5'b00111;
localparam OP_MAX  = 5'b10101;
localparam OP_LDSL = 5'b01001;
localparam OP_LDSR = 5'b11001;

localparam EN_ACT  = 0;
localparam EN_SEL  = 1;
localparam EN_BIAS = 2;
localparam EN_RELU = 3;
localparam EN_SHFL = 4;
localparam EN_CHPRI = 5;

localparam ST_IDLE = 3'h0;
localparam ST_CALC_OCH_FIRST_PH = 3'h1;
localparam ST_CALC_OCH_LEFT_PH = 3'h2;
localparam ST_WAIT_VPROC = 3'h3;
localparam ST_DONE = 3'h4;

reg   [7 : 0]                           ifm_width;
reg   [7 : 0]                           ifm_channel;
reg   [3 : 0]                           wt_width;
reg   [3 : 0]                           wt_height;
reg   [7 : 0]                           stride_w;
reg   [7 : 0]                           dilation_w;
reg   [4 : 0]                           clip_data;
reg                                     relu_en;
reg                                     bias_en;
reg   [1 : 0]                           channel_shuffle_type;
reg                                     channel64_priority;
reg   [1 : 0]                           ld_calc_type;
reg   [MRX_ADDR_WTH-1 : 0]              pad_left;
reg   [MRX_ADDR_WTH-1 : 0]              pad_offset;
reg   [MRX_IND_WTH-1 : 0]               wt_mr_index;
reg   [MRX_ADDR_WTH-1 : 0]              wt_mr_addr;
reg   [MRX_IND_WTH-1 : 0]               bias_mr_index;
reg   [MRX_ADDR_WTH-1 : 0]              bias_mr_addr;
reg   [MRX_IND_WTH-1 : 0]               ofm_mr_index;
reg   [MRX_ADDR_WTH-1 : 0]              ofm_mr_addr;
reg   [MRX_IND_WTH-1 : 0]               core0_ifm_line0_mr_index;
reg   [MRX_ADDR_WTH-1 : 0]              core0_ifm_line0_mr_addr;
reg   [MRX_IND_WTH-1 : 0]               core1_ifm_line0_mr_index;
reg   [MRX_ADDR_WTH-1 : 0]              core1_ifm_line0_mr_addr;
reg   [MRX_IND_WTH-1 : 0]               core0_ifm_line1_mr_index;
reg   [MRX_ADDR_WTH-1 : 0]              core0_ifm_line1_mr_addr;
reg   [MRX_IND_WTH-1 : 0]               core1_ifm_line1_mr_index;
reg   [MRX_ADDR_WTH-1 : 0]              core1_ifm_line1_mr_addr;
reg   [MRX_IND_WTH-1 : 0]               core0_ifm_line2_mr_index;
reg   [MRX_ADDR_WTH-1 : 0]              core0_ifm_line2_mr_addr;
reg   [MRX_IND_WTH-1 : 0]               core1_ifm_line2_mr_index;
reg   [MRX_ADDR_WTH-1 : 0]              core1_ifm_line2_mr_addr;

reg                                     mcu_set_start;
reg                                     mcu_clr_intr;
reg   [7 : 0]                           ifm_width_reg;
reg   [7 : 0]                           ifm_channel_reg;
reg   [3 : 0]                           wt_width_reg;
reg   [3 : 0]                           wt_height_reg;
reg   [7 : 0]                           stride_w_reg;
reg   [7 : 0]                           dilation_w_reg;
reg   [4 : 0]                           clip_data_reg;
reg                                     relu_en_reg;
reg                                     bias_en_reg;
reg   [1 : 0]                           channel_shuffle_type_reg;
reg                                     channel64_priority_reg;
reg   [1 : 0]                           ld_calc_type_reg;
reg   [MRX_IND_WTH-1 : 0]               wt_mr_index_reg;
reg   [MRX_ADDR_WTH-1 : 0]              wt_mr_addr_reg;
reg   [MRX_IND_WTH-1 : 0]               bias_mr_index_reg;
reg   [MRX_ADDR_WTH-1 : 0]              bias_mr_addr_reg;
reg   [MRX_IND_WTH-1 : 0]               ofm_mr_index_reg;
reg   [MRX_ADDR_WTH-1 : 0]              ofm_mr_addr_reg;
reg   [MRX_ADDR_WTH-1 : 0]              pad_left_reg;
reg   [MRX_ADDR_WTH-1 : 0]              pad_offset_reg;
reg   [MRX_IND_WTH-1 : 0]               core0_ifm_line0_mr_index_reg;
reg   [MRX_ADDR_WTH-1 : 0]              core0_ifm_line0_mr_addr_reg;
reg   [MRX_IND_WTH-1 : 0]               core1_ifm_line0_mr_index_reg;
reg   [MRX_ADDR_WTH-1 : 0]              core1_ifm_line0_mr_addr_reg;
reg   [MRX_IND_WTH-1 : 0]               core0_ifm_line1_mr_index_reg;
reg   [MRX_ADDR_WTH-1 : 0]              core0_ifm_line1_mr_addr_reg;
reg   [MRX_IND_WTH-1 : 0]               core1_ifm_line1_mr_index_reg;
reg   [MRX_ADDR_WTH-1 : 0]              core1_ifm_line1_mr_addr_reg;
reg   [MRX_IND_WTH-1 : 0]               core0_ifm_line2_mr_index_reg;
reg   [MRX_ADDR_WTH-1 : 0]              core0_ifm_line2_mr_addr_reg;
reg   [MRX_IND_WTH-1 : 0]               core1_ifm_line2_mr_index_reg;
reg   [MRX_ADDR_WTH-1 : 0]              core1_ifm_line2_mr_addr_reg;

reg   [2 : 0]                           cur_st;
reg   [2 : 0]                           next_st;

reg   [3 : 0]                           wtw_cnt;
reg   [3 : 0]                           wth_cnt;
reg   [7 : 0]                           och_cnt;
reg   [7 : 0]                           ifmw_cnt;
reg   [5 : 0]                           wait_vproc_cnt;

reg                                     dwc_intr;

wire                                    update_wth_sig;
wire                                    update_och_sig;
wire                                    update_ifmw_sig;

reg   signed  [MRX_ADDR_WTH+1 : 0]              mpu0_line0_mrs0_base_addr;
reg   signed  [MRX_ADDR_WTH+1 : 0]              mpu0_line1_mrs0_base_addr;
reg   signed  [MRX_ADDR_WTH+1 : 0]              mpu0_line2_mrs0_base_addr;
reg   signed  [MRX_ADDR_WTH+1 : 0]              mpu1_line0_mrs0_base_addr;
reg   signed  [MRX_ADDR_WTH+1 : 0]              mpu1_line1_mrs0_base_addr;
reg   signed  [MRX_ADDR_WTH+1 : 0]              mpu1_line2_mrs0_base_addr;

reg   [MRX_IND_WTH-1 : 0]               mpu0_mrs0_base_index;
reg   signed  [MRX_ADDR_WTH+1 : 0]              mpu0_mrs0_base_addr;
reg   signed  [MRX_ADDR_WTH+1 : 0]              mpu0_mrs0_init_addr;
reg   [MRX_IND_WTH-1 : 0]               mpu1_mrs0_base_index;
reg   signed  [MRX_ADDR_WTH+1 : 0]              mpu1_mrs0_base_addr;
reg   signed  [MRX_ADDR_WTH+1 : 0]              mpu1_mrs0_init_addr;

reg   [2 : 0]                           cur_st_dly1;
reg                                     update_wth_sig_dly1;
reg                                     update_och_sig_dly1;
reg   [8 : 0]                           ifm_width_update;
reg   signed  [MRX_ADDR_WTH+1 : 0]              mpu0_mrs0_init_addr_dly1;
reg   signed  [MRX_ADDR_WTH+1 : 0]              mpu1_mrs0_init_addr_dly1;

reg   [MRX_IND_WTH-1 : 0]               mpu0_mrs0_index;
reg   [MRX_IND_WTH-1 : 0]               mpu1_mrs0_index;
reg   signed  [MRX_ADDR_WTH+1 : 0]              mpu0_mrs0_addr;
reg   signed  [MRX_ADDR_WTH+1 : 0]              mpu1_mrs0_addr;
reg   signed  [MRX_ADDR_WTH+1 : 0]              mpu0_mrs0_pre_addr;
reg   signed  [MRX_ADDR_WTH+1 : 0]              mpu1_mrs0_pre_addr;
reg   signed  [MRX_ADDR_WTH+1 : 0]              mpu0_mrs0_post_addr;
reg   signed  [MRX_ADDR_WTH+1 : 0]              mpu1_mrs0_post_addr;

wire  signed  [MRX_ADDR_WTH+1 : 0]              mpu0_mrs0_last_addr_signed;
wire  signed  [MRX_ADDR_WTH+1 : 0]              mpu1_mrs0_last_addr_signed;

reg   [MRX_IND_WTH-1 : 0]               mrs1_index;
reg   [MRX_ADDR_WTH-1 : 0]              mrs1_addr;

reg   [4 : 0]                           vpu_code;
reg   [5 : 0]                           sv_code;

reg   [MRX_ADDR_WTH-1 : 0]              bias_addr;
reg   [MRX_ADDR_WTH-1 : 0]              bias_addr_dly1;
reg   [MRX_ADDR_WTH-1 : 0]              mrd_addr;
reg   [MRX_ADDR_WTH-1 : 0]              mrd_addr_dly1;

//======================================================================================================================
// Instance
//======================================================================================================================

// register map of conv_ctrl
always @(posedge clk_i) begin
    if(rst_i) begin
        ifm_width <= 8'h0;
        ifm_channel <= 8'h0;
        wt_width <= 4'h0;
        wt_height <= 4'h0;
        stride_w <= 8'h0;
        dilation_w <= 8'h0;
        clip_data <= 5'h0;
        relu_en <= 1'b0;
        bias_en <= 1'b0;
        channel_shuffle_type <= 2'h0;
        channel64_priority <= 1'b0;
        ld_calc_type <= 2'h0; // 2'b10: Max pooling; 2'b00: Ave pooling; 2'b01: depth-wise conv;
        pad_left <= {MRX_ADDR_WTH{1'b0}};
        pad_offset <= {MRX_ADDR_WTH{1'b0}};
        wt_mr_index <= {MRX_IND_WTH{1'b0}};
        wt_mr_addr <= {MRX_ADDR_WTH{1'b0}};
        bias_mr_index <= {MRX_IND_WTH{1'b0}};
        bias_mr_addr <= {MRX_ADDR_WTH{1'b0}};
        ofm_mr_index <= {MRX_IND_WTH{1'b0}};
        ofm_mr_addr <= {MRX_ADDR_WTH{1'b0}};
        core0_ifm_line0_mr_index <= {MRX_IND_WTH{1'b0}};
        core0_ifm_line0_mr_addr <= {MRX_ADDR_WTH{1'b0}};
        core1_ifm_line0_mr_index <= {MRX_IND_WTH{1'b0}};
        core1_ifm_line0_mr_addr <= {MRX_ADDR_WTH{1'b0}};
        core0_ifm_line1_mr_index <= {MRX_IND_WTH{1'b0}};
        core0_ifm_line1_mr_addr <= {MRX_ADDR_WTH{1'b0}};
        core1_ifm_line1_mr_index <= {MRX_IND_WTH{1'b0}};
        core1_ifm_line1_mr_addr <= {MRX_ADDR_WTH{1'b0}};
        core0_ifm_line2_mr_index <= {MRX_IND_WTH{1'b0}};
        core0_ifm_line2_mr_addr <= {MRX_ADDR_WTH{1'b0}};
        core1_ifm_line2_mr_index <= {MRX_IND_WTH{1'b0}};
        core1_ifm_line2_mr_addr <= {MRX_ADDR_WTH{1'b0}};
    end else if(regmap_dwc__we_i) begin
        if(regmap_dwc__waddr_i[REGMAP_ADDR_WTH-1 : 2] ==  'h1) ifm_width <= regmap_dwc__wdata_i[7 : 0];
        if(regmap_dwc__waddr_i[REGMAP_ADDR_WTH-1 : 2] ==  'h1) ifm_channel <= regmap_dwc__wdata_i[15 : 8];
        if(regmap_dwc__waddr_i[REGMAP_ADDR_WTH-1 : 2] ==  'h1) wt_width <= regmap_dwc__wdata_i[19 : 16];
        if(regmap_dwc__waddr_i[REGMAP_ADDR_WTH-1 : 2] ==  'h1) wt_height <= regmap_dwc__wdata_i[23 : 20];
        if(regmap_dwc__waddr_i[REGMAP_ADDR_WTH-1 : 2] ==  'h2) stride_w <= regmap_dwc__wdata_i[7 : 0];
        if(regmap_dwc__waddr_i[REGMAP_ADDR_WTH-1 : 2] ==  'h2) dilation_w <= regmap_dwc__wdata_i[15 : 8];
        if(regmap_dwc__waddr_i[REGMAP_ADDR_WTH-1 : 2] ==  'h2) clip_data <= regmap_dwc__wdata_i[20 : 16];
        if(regmap_dwc__waddr_i[REGMAP_ADDR_WTH-1 : 2] ==  'h2) relu_en <= regmap_dwc__wdata_i[24 : 24];
        if(regmap_dwc__waddr_i[REGMAP_ADDR_WTH-1 : 2] ==  'h2) bias_en <= regmap_dwc__wdata_i[25 : 25];
        if(regmap_dwc__waddr_i[REGMAP_ADDR_WTH-1 : 2] ==  'h2) channel_shuffle_type <= regmap_dwc__wdata_i[27 : 26];
        if(regmap_dwc__waddr_i[REGMAP_ADDR_WTH-1 : 2] ==  'h2) channel64_priority <= regmap_dwc__wdata_i[28 : 28];
        if(regmap_dwc__waddr_i[REGMAP_ADDR_WTH-1 : 2] ==  'h2) ld_calc_type <= regmap_dwc__wdata_i[30 : 29];
        if(regmap_dwc__waddr_i[REGMAP_ADDR_WTH-1 : 2] ==  'h3) pad_left <= regmap_dwc__wdata_i[0 +: MRX_ADDR_WTH];
        if(regmap_dwc__waddr_i[REGMAP_ADDR_WTH-1 : 2] ==  'h3) pad_offset <= regmap_dwc__wdata_i[16 +: MRX_ADDR_WTH];
        if(regmap_dwc__waddr_i[REGMAP_ADDR_WTH-1 : 2] ==  'h4) wt_mr_addr <= regmap_dwc__wdata_i[0 +: MRX_ADDR_WTH-1];
        if(regmap_dwc__waddr_i[REGMAP_ADDR_WTH-1 : 2] ==  'h4) wt_mr_index <= regmap_dwc__wdata_i[MRX_ADDR_WTH +: MRX_IND_WTH];
        if(regmap_dwc__waddr_i[REGMAP_ADDR_WTH-1 : 2] ==  'h4) bias_mr_addr <= regmap_dwc__wdata_i[16 +: MRX_ADDR_WTH];
        if(regmap_dwc__waddr_i[REGMAP_ADDR_WTH-1 : 2] ==  'h4) bias_mr_index <= regmap_dwc__wdata_i[MRX_ADDR_WTH+16 +: MRX_IND_WTH];
        if(regmap_dwc__waddr_i[REGMAP_ADDR_WTH-1 : 2] ==  'h5) ofm_mr_addr <= regmap_dwc__wdata_i[0 +: MRX_ADDR_WTH];
        if(regmap_dwc__waddr_i[REGMAP_ADDR_WTH-1 : 2] ==  'h5) ofm_mr_index <= regmap_dwc__wdata_i[MRX_ADDR_WTH +: MRX_IND_WTH];
        if(regmap_dwc__waddr_i[REGMAP_ADDR_WTH-1 : 2] ==  'h6) core0_ifm_line0_mr_addr <= regmap_dwc__wdata_i[0 +: MRX_ADDR_WTH];
        if(regmap_dwc__waddr_i[REGMAP_ADDR_WTH-1 : 2] ==  'h6) core0_ifm_line0_mr_index <= regmap_dwc__wdata_i[MRX_ADDR_WTH +: MRX_IND_WTH];
        if(regmap_dwc__waddr_i[REGMAP_ADDR_WTH-1 : 2] ==  'h6) core1_ifm_line0_mr_addr <= regmap_dwc__wdata_i[16 +: MRX_ADDR_WTH];
        if(regmap_dwc__waddr_i[REGMAP_ADDR_WTH-1 : 2] ==  'h6) core1_ifm_line0_mr_index <= regmap_dwc__wdata_i[MRX_ADDR_WTH+16 +: MRX_IND_WTH];
        if(regmap_dwc__waddr_i[REGMAP_ADDR_WTH-1 : 2] ==  'h7) core0_ifm_line1_mr_addr <= regmap_dwc__wdata_i[0 +: MRX_ADDR_WTH];
        if(regmap_dwc__waddr_i[REGMAP_ADDR_WTH-1 : 2] ==  'h7) core0_ifm_line1_mr_index <= regmap_dwc__wdata_i[MRX_ADDR_WTH +: MRX_IND_WTH];
        if(regmap_dwc__waddr_i[REGMAP_ADDR_WTH-1 : 2] ==  'h7) core1_ifm_line1_mr_addr <= regmap_dwc__wdata_i[16 +: MRX_ADDR_WTH];
        if(regmap_dwc__waddr_i[REGMAP_ADDR_WTH-1 : 2] ==  'h7) core1_ifm_line1_mr_index <= regmap_dwc__wdata_i[MRX_ADDR_WTH+16 +: MRX_IND_WTH];
        if(regmap_dwc__waddr_i[REGMAP_ADDR_WTH-1 : 2] ==  'h8) core0_ifm_line2_mr_addr <= regmap_dwc__wdata_i[0 +: MRX_ADDR_WTH];
        if(regmap_dwc__waddr_i[REGMAP_ADDR_WTH-1 : 2] ==  'h8) core0_ifm_line2_mr_index <= regmap_dwc__wdata_i[MRX_ADDR_WTH +: MRX_IND_WTH];
        if(regmap_dwc__waddr_i[REGMAP_ADDR_WTH-1 : 2] ==  'h8) core1_ifm_line2_mr_addr <= regmap_dwc__wdata_i[16 +: MRX_ADDR_WTH];
        if(regmap_dwc__waddr_i[REGMAP_ADDR_WTH-1 : 2] ==  'h8) core1_ifm_line2_mr_index <= regmap_dwc__wdata_i[MRX_ADDR_WTH+16 +: MRX_IND_WTH];
    end
end

// generate mcu control signal, such as: set_start, clr_intr.
// store the copy of all parameters once receiving set_start signal.
always @(posedge clk_i) begin
    if(rst_i) begin
        mcu_set_start <= 1'b0;
        mcu_clr_intr <= 1'b0;
        ifm_width_reg <= 8'h0;
        ifm_channel_reg <= 8'h0;
        wt_width_reg <= 4'h0;
        wt_height_reg <= 4'h0;
        stride_w_reg <= 8'h0;
        dilation_w_reg <= 8'h0;
        clip_data_reg <= 5'h0;
        relu_en_reg <= 1'b0;
        bias_en_reg <= 1'b0;
        channel_shuffle_type_reg <= 2'h0;
        channel64_priority_reg <= 1'b0;
        ld_calc_type_reg <= 2'h0;
        wt_mr_index_reg <= {MRX_IND_WTH{1'b0}};
        wt_mr_addr_reg <= {MRX_ADDR_WTH{1'b0}};
        bias_mr_index_reg <= {MRX_IND_WTH{1'b0}};
        bias_mr_addr_reg <= {MRX_ADDR_WTH{1'b0}};
        ofm_mr_index_reg <= {MRX_IND_WTH{1'b0}};
        ofm_mr_addr_reg <= {MRX_ADDR_WTH{1'b0}};
        pad_left_reg <= 'h0;
        pad_offset_reg <= 'h0;
        core0_ifm_line0_mr_index_reg <= {MRX_IND_WTH{1'b0}};
        core0_ifm_line0_mr_addr_reg <= {MRX_ADDR_WTH{1'b0}};
        core1_ifm_line0_mr_index_reg <= {MRX_IND_WTH{1'b0}};
        core1_ifm_line0_mr_addr_reg <= {MRX_ADDR_WTH{1'b0}};
        core0_ifm_line1_mr_index_reg <= {MRX_IND_WTH{1'b0}};
        core0_ifm_line1_mr_addr_reg <= {MRX_ADDR_WTH{1'b0}};
        core1_ifm_line1_mr_index_reg <= {MRX_IND_WTH{1'b0}};
        core1_ifm_line1_mr_addr_reg <= {MRX_ADDR_WTH{1'b0}};
        core0_ifm_line2_mr_index_reg <= {MRX_IND_WTH{1'b0}};
        core0_ifm_line2_mr_addr_reg <= {MRX_ADDR_WTH{1'b0}};
        core1_ifm_line2_mr_index_reg <= {MRX_IND_WTH{1'b0}};
        core1_ifm_line2_mr_addr_reg <= {MRX_ADDR_WTH{1'b0}};
    end else begin
        mcu_set_start <= 1'b0;
        mcu_clr_intr <= 1'b0;
        if(regmap_dwc__we_i && (|regmap_dwc__waddr_i == 1'b0)) begin
            if(regmap_dwc__wdata_i[SET_START]) begin
                mcu_set_start <= 1'b1;
                ifm_width_reg <= ifm_width;
                ifm_channel_reg <= ifm_channel;
                wt_width_reg <= wt_width;
                wt_height_reg <= wt_height;
                stride_w_reg <= stride_w;
                dilation_w_reg <= dilation_w;
                clip_data_reg <= clip_data;
                relu_en_reg <= relu_en;
                bias_en_reg <= bias_en;
                channel_shuffle_type_reg <= channel_shuffle_type;
                channel64_priority_reg <= channel64_priority;
                ld_calc_type_reg <= ld_calc_type;
                wt_mr_index_reg <= wt_mr_index;
                wt_mr_addr_reg <= wt_mr_addr;
                bias_mr_index_reg <= bias_mr_index;
                bias_mr_addr_reg <= bias_mr_addr;
                ofm_mr_index_reg <= ofm_mr_index;
                ofm_mr_addr_reg <= ofm_mr_addr;
                pad_left_reg <= pad_left;
                pad_offset_reg <= pad_offset;
                core0_ifm_line0_mr_index_reg <= core0_ifm_line0_mr_index;
                core0_ifm_line0_mr_addr_reg <= core0_ifm_line0_mr_addr;
                core1_ifm_line0_mr_index_reg <= core1_ifm_line0_mr_index;
                core1_ifm_line0_mr_addr_reg <= core1_ifm_line0_mr_addr;
                core0_ifm_line1_mr_index_reg <= core0_ifm_line1_mr_index;
                core0_ifm_line1_mr_addr_reg <= core0_ifm_line1_mr_addr;
                core1_ifm_line1_mr_index_reg <= core1_ifm_line1_mr_index;
                core1_ifm_line1_mr_addr_reg <= core1_ifm_line1_mr_addr;
                core0_ifm_line2_mr_index_reg <= core0_ifm_line2_mr_index;
                core0_ifm_line2_mr_addr_reg <= core0_ifm_line2_mr_addr;
                core1_ifm_line2_mr_index_reg <= core1_ifm_line2_mr_index;
                core1_ifm_line2_mr_addr_reg <= core1_ifm_line2_mr_addr;
            end
            if(regmap_dwc__wdata_i[CLR_INTR]) begin
                mcu_clr_intr <= 1'b1;
            end
        end
    end
end

// dwc FSM
always @(posedge clk_i) begin
    if(rst_i) begin
        cur_st <= ST_IDLE;
    end else begin
        cur_st <= next_st;
    end
end

always @(*) begin
    next_st = cur_st;
    case(cur_st)
        ST_IDLE: begin
            if(mcu_set_start) begin
                next_st = ST_CALC_OCH_FIRST_PH;
            end
        end
        ST_CALC_OCH_FIRST_PH: begin
            if( (wt_width_reg == 4'h0) && (wt_height_reg == 4'h0) ) begin
                if( (och_cnt == ifm_channel_reg) && (ifmw_cnt == ifm_width_reg) ) begin
                    next_st = ST_WAIT_VPROC;
                end else begin
                    next_st = ST_CALC_OCH_FIRST_PH;
                end
            end else begin
                next_st = ST_CALC_OCH_LEFT_PH;
            end
        end
        ST_CALC_OCH_LEFT_PH: begin
            if( (wtw_cnt == wt_width_reg) && (wth_cnt == wt_height_reg) ) begin
                if( (och_cnt == ifm_channel_reg) && (ifmw_cnt == ifm_width_reg) ) begin
                    next_st = ST_WAIT_VPROC;
                end else begin
                    next_st = ST_CALC_OCH_FIRST_PH;
                end
            end
        end
        ST_WAIT_VPROC: begin
            if(wait_vproc_cnt == 'd27) begin //TODO: replace the delay by accurate delay
                next_st = ST_DONE;
            end
        end
        ST_DONE: begin
            next_st = ST_IDLE;
        end
    endcase
end

always @(posedge clk_i) begin
    if(rst_i) begin
        wtw_cnt <= 4'h0;
        wth_cnt <= 4'h0;
        och_cnt <= 8'h0;
        ifmw_cnt <= 8'h0;
    end else begin
        if( (cur_st == ST_CALC_OCH_FIRST_PH) || (cur_st == ST_CALC_OCH_LEFT_PH) ) begin
            if(wtw_cnt == wt_width_reg) begin
                if(wth_cnt == wt_height_reg) begin
                    if(och_cnt == ifm_channel_reg) begin
                        och_cnt <= 8'h0;
                        ifmw_cnt <= ifmw_cnt + 1'b1;
                    end else begin
                        och_cnt <= och_cnt + 1'b1;
                    end
                    wth_cnt <= 4'h0;
                end else begin
                    wth_cnt <= wth_cnt + 1'b1;
                end
                wtw_cnt <= 4'h0;
            end else begin
                wtw_cnt <= wtw_cnt + 1'b1;
            end
        end else begin
            wtw_cnt <= 4'h0;
            wth_cnt <= 4'h0;
            och_cnt <= 8'h0;
            ifmw_cnt <= 8'h0;
        end
    end
end

always @(posedge clk_i) begin
    if(rst_i) begin
        wait_vproc_cnt <= 6'h0;
    end else if(cur_st == ST_WAIT_VPROC) begin
        wait_vproc_cnt <= wait_vproc_cnt + 1'b1;
    end
end

// generate the interrupt signal
always @(posedge clk_i) begin
    if(rst_i) begin
        dwc_intr <= 1'b0;
    end else begin
        if(cur_st == ST_DONE) begin
            dwc_intr <= 1'b1;
        end else if(mcu_clr_intr) begin
            dwc_intr <= 1'b0;
        end
    end
end
assign regmap_dwc__intr_o = dwc_intr;

// In order to simplify the expression of judging conditions, define below signals.
assign update_wth_sig = (wtw_cnt == wt_width_reg) && ((cur_st == ST_CALC_OCH_FIRST_PH) || (cur_st == ST_CALC_OCH_LEFT_PH));
assign update_och_sig = (wth_cnt == wt_height_reg) && update_wth_sig;
assign update_ifmw_sig = (och_cnt == ifm_channel_reg) && update_och_sig;

// generate mrs0 addr/index
always @(posedge clk_i) begin
    if( (cur_st == ST_CALC_OCH_FIRST_PH) || (cur_st == ST_CALC_OCH_LEFT_PH) ) begin
        if(update_ifmw_sig) begin
            mpu0_line0_mrs0_base_addr <= mpu0_line0_mrs0_base_addr + stride_w_reg;
            mpu0_line1_mrs0_base_addr <= mpu0_line1_mrs0_base_addr + stride_w_reg;
            mpu0_line2_mrs0_base_addr <= mpu0_line2_mrs0_base_addr + stride_w_reg;
            mpu1_line0_mrs0_base_addr <= mpu1_line0_mrs0_base_addr + stride_w_reg;
            mpu1_line1_mrs0_base_addr <= mpu1_line1_mrs0_base_addr + stride_w_reg;
            mpu1_line2_mrs0_base_addr <= mpu1_line2_mrs0_base_addr + stride_w_reg;
        end
    end else begin
        mpu0_line0_mrs0_base_addr <= {2'h0, core0_ifm_line0_mr_addr_reg} - pad_left_reg;
        mpu0_line1_mrs0_base_addr <= {2'h0, core0_ifm_line1_mr_addr_reg} - pad_left_reg;
        mpu0_line2_mrs0_base_addr <= {2'h0, core0_ifm_line2_mr_addr_reg} - pad_left_reg;
        mpu1_line0_mrs0_base_addr <= {2'h0, core1_ifm_line0_mr_addr_reg} - pad_left_reg;
        mpu1_line1_mrs0_base_addr <= {2'h0, core1_ifm_line1_mr_addr_reg} - pad_left_reg;
        mpu1_line2_mrs0_base_addr <= {2'h0, core1_ifm_line2_mr_addr_reg} - pad_left_reg;
    end
end

always @(*) begin
    case(wth_cnt)
        3'h0: begin
            mpu0_mrs0_base_index = core0_ifm_line0_mr_index_reg;
            mpu0_mrs0_base_addr = mpu0_line0_mrs0_base_addr;
            mpu0_mrs0_init_addr = {2'h0, core0_ifm_line0_mr_addr_reg};
            mpu1_mrs0_base_index = core1_ifm_line0_mr_index_reg;
            mpu1_mrs0_base_addr = mpu1_line0_mrs0_base_addr;
            mpu1_mrs0_init_addr = {2'h0, core1_ifm_line0_mr_addr_reg};
        end
        3'h1: begin
            mpu0_mrs0_base_index = core0_ifm_line1_mr_index_reg;
            mpu0_mrs0_base_addr = mpu0_line1_mrs0_base_addr;
            mpu0_mrs0_init_addr = {2'h0, core0_ifm_line1_mr_addr_reg};
            mpu1_mrs0_base_index = core1_ifm_line1_mr_index_reg;
            mpu1_mrs0_base_addr = mpu1_line1_mrs0_base_addr;
            mpu1_mrs0_init_addr = {2'h0, core1_ifm_line1_mr_addr_reg};
        end
        3'h2: begin
            mpu0_mrs0_base_index = core0_ifm_line2_mr_index_reg;
            mpu0_mrs0_base_addr = mpu0_line2_mrs0_base_addr;
            mpu0_mrs0_init_addr = {2'h0, core0_ifm_line2_mr_addr_reg};
            mpu1_mrs0_base_index = core1_ifm_line2_mr_index_reg;
            mpu1_mrs0_base_addr = mpu1_line2_mrs0_base_addr;
            mpu1_mrs0_init_addr = {2'h0, core1_ifm_line2_mr_addr_reg};
        end
        default: begin
            mpu0_mrs0_base_index = core0_ifm_line0_mr_index_reg;
            mpu0_mrs0_base_addr = mpu0_line0_mrs0_base_addr;
            mpu0_mrs0_init_addr = {2'h0, core0_ifm_line0_mr_addr_reg};
            mpu1_mrs0_base_index = core1_ifm_line0_mr_index_reg;
            mpu1_mrs0_base_addr = mpu1_line0_mrs0_base_addr;
            mpu1_mrs0_init_addr = {2'h0, core1_ifm_line0_mr_addr_reg};
        end
    endcase
end

always @(posedge clk_i) begin
    cur_st_dly1 <= cur_st;
    update_wth_sig_dly1 <= update_wth_sig;
    update_och_sig_dly1 <= update_och_sig;
    ifm_width_update <= ifm_channel_reg + dilation_w_reg + 1'b1;
    mpu0_mrs0_init_addr_dly1 <= mpu0_mrs0_init_addr;
    mpu1_mrs0_init_addr_dly1 <= mpu1_mrs0_init_addr;
end

always @(posedge clk_i) begin
    mpu0_mrs0_index <= mpu0_mrs0_base_index;
    mpu1_mrs0_index <= mpu1_mrs0_base_index;
end

always @(posedge clk_i) begin
    if( (cur_st_dly1 == ST_CALC_OCH_FIRST_PH) || (cur_st_dly1 == ST_CALC_OCH_LEFT_PH) ) begin
        if(update_wth_sig_dly1) begin
            mpu0_mrs0_addr <= mpu0_mrs0_base_addr + och_cnt;
            mpu1_mrs0_addr <= mpu1_mrs0_base_addr + och_cnt;
        end else begin
            mpu0_mrs0_addr <= mpu0_mrs0_addr + ifm_width_update;
            mpu1_mrs0_addr <= mpu1_mrs0_addr + ifm_width_update;
        end
    end else begin
        mpu0_mrs0_addr <= mpu0_mrs0_base_addr;
        mpu1_mrs0_addr <= mpu1_mrs0_base_addr;
    end
end

always @(posedge clk_i) begin
    if( (cur_st_dly1 == ST_CALC_OCH_FIRST_PH) || (cur_st_dly1 == ST_CALC_OCH_LEFT_PH) ) begin
        if(update_wth_sig_dly1) begin
            mpu0_mrs0_pre_addr <= mpu0_mrs0_base_addr + pad_offset_reg + och_cnt;
            mpu1_mrs0_pre_addr <= mpu1_mrs0_base_addr + pad_offset_reg + och_cnt;
        end else begin
            mpu0_mrs0_pre_addr <= mpu0_mrs0_pre_addr + ifm_width_update;
            mpu1_mrs0_pre_addr <= mpu1_mrs0_pre_addr + ifm_width_update;
        end
    end else begin
        mpu0_mrs0_pre_addr <= mpu0_mrs0_base_addr + pad_offset_reg;
        mpu1_mrs0_pre_addr <= mpu1_mrs0_base_addr + pad_offset_reg;
    end
end

always @(posedge clk_i) begin
    if( (cur_st_dly1 == ST_CALC_OCH_FIRST_PH) || (cur_st_dly1 == ST_CALC_OCH_LEFT_PH) ) begin
        if(update_wth_sig_dly1) begin
            mpu0_mrs0_post_addr <= mpu0_mrs0_base_addr - pad_offset_reg + och_cnt;
            mpu1_mrs0_post_addr <= mpu1_mrs0_base_addr - pad_offset_reg + och_cnt;
        end else begin
            mpu0_mrs0_post_addr <= mpu0_mrs0_post_addr + ifm_width_update;
            mpu1_mrs0_post_addr <= mpu1_mrs0_post_addr + ifm_width_update;
        end
    end else begin
        mpu0_mrs0_post_addr <= mpu0_mrs0_base_addr - pad_offset_reg;
        mpu1_mrs0_post_addr <= mpu1_mrs0_base_addr - pad_offset_reg;
    end
end

assign mpu0_mrs0_last_addr_signed = mpu0_mrs0_init_addr_dly1 + pad_offset_reg;
assign dwcctl_vputy0__mrs0_sl_o = (mpu0_mrs0_addr >= mpu0_mrs0_last_addr_signed) ? 1'b1 : 1'b0;
assign dwcctl_vputy0__mrs0_sr_o = (mpu0_mrs0_addr < mpu0_mrs0_init_addr_dly1) ? 1'b1 : 1'b0;
assign dwcctl_vputy0__mrs0_index_o = (channel64_priority_reg && dwcctl_vputy0__mrs0_sl_o) ? {MRX_IND_WTH{1'b1}}
                                   : (channel64_priority_reg && dwcctl_vputy0__mrs0_sr_o) ? {MRX_IND_WTH{1'b1}}
                                   : mpu0_mrs0_index;
assign dwcctl_vputy0__mrs0_addr_o = (dwcctl_vputy0__mrs0_sl_o) ? mpu0_mrs0_post_addr[MRX_ADDR_WTH-1 : 0]
                                  : (dwcctl_vputy0__mrs0_sr_o) ? mpu0_mrs0_pre_addr[MRX_ADDR_WTH-1 : 0]
                                  : mpu0_mrs0_addr[MRX_ADDR_WTH-1 : 0];

assign mpu1_mrs0_last_addr_signed = mpu1_mrs0_init_addr_dly1 + pad_offset_reg;
assign dwcctl_vputy1__mrs0_sl_o = (mpu1_mrs0_addr >= mpu1_mrs0_last_addr_signed) ? 1'b1 : 1'b0;
assign dwcctl_vputy1__mrs0_sr_o = (mpu1_mrs0_addr < mpu1_mrs0_init_addr_dly1) ? 1'b1 : 1'b0;
assign dwcctl_vputy1__mrs0_index_o = (channel64_priority_reg && dwcctl_vputy1__mrs0_sl_o) ? {MRX_IND_WTH{1'b1}}
                                   : (channel64_priority_reg && dwcctl_vputy1__mrs0_sr_o) ? {MRX_IND_WTH{1'b1}}
                                   : mpu1_mrs0_index;
assign dwcctl_vputy1__mrs0_addr_o = (dwcctl_vputy1__mrs0_sl_o) ? mpu1_mrs0_post_addr[MRX_ADDR_WTH-1 : 0]
                                  : (dwcctl_vputy1__mrs0_sr_o) ? mpu1_mrs0_pre_addr[MRX_ADDR_WTH-1 : 0]
                                  : mpu1_mrs0_addr[MRX_ADDR_WTH-1 : 0];

// generate mrs1 addr/index
always @(posedge clk_i) begin
    if( (cur_st_dly1 == ST_CALC_OCH_FIRST_PH) || (cur_st_dly1 == ST_CALC_OCH_LEFT_PH) ) begin
        if(update_och_sig_dly1) begin
            mrs1_addr <= wt_mr_addr_reg + och_cnt;
            mrs1_index <= wt_mr_index_reg;
        end else begin
            mrs1_addr <= mrs1_addr + ifm_channel_reg + 1'b1;
            mrs1_index <= mrs1_index + ((&mrs1_addr == 1'b1) ? 1'b1 : 1'b0);
        end
    end else begin
        mrs1_addr <= wt_mr_addr_reg;
        mrs1_index <= wt_mr_index_reg;
    end
end

assign dwcctl_vputy__mrs1_index_o = mrs1_index;
assign dwcctl_vputy__mrs1_addr_o = mrs1_addr;

// generate op_code of vputy
always @(posedge clk_i) begin
    if(rst_i) begin
        vpu_code <= 'h0;
    end else begin
        vpu_code[0] <= (cur_st == ST_CALC_OCH_FIRST_PH) || (cur_st == ST_CALC_OCH_LEFT_PH);
        vpu_code[1] <= ld_calc_type_reg[0];
        vpu_code[2] <= (cur_st == ST_CALC_OCH_LEFT_PH);
        vpu_code[3] <= 1'b0;
        vpu_code[4] <= (cur_st == ST_CALC_OCH_LEFT_PH) && (ld_calc_type_reg[1]);
    end
end
assign dwcctl_vputy__code_o = vpu_code;

always @(posedge clk_i) begin
    if(rst_i) begin
        sv_code <= 'h0;
    end else begin
        sv_code[EN_ACT] <= update_och_sig;
        sv_code[EN_SEL] <= 1'b0;
        sv_code[EN_BIAS] <= bias_en_reg;
        sv_code[EN_RELU] <= relu_en_reg;
        sv_code[EN_SHFL] <= channel_shuffle_type_reg[0];
        sv_code[EN_CHPRI] <= channel64_priority_reg;
    end
end
assign dwcctl_vputy__sv_code_o = sv_code;

// generate br addr/index
always @(posedge clk_i) begin
    if( (cur_st == ST_CALC_OCH_FIRST_PH) || (cur_st == ST_CALC_OCH_LEFT_PH) ) begin
        if(update_och_sig) begin
            bias_addr <= bias_addr + 1'b1;
            if(update_ifmw_sig) begin
                bias_addr <= bias_mr_addr_reg;
            end
        end
    end else begin
        bias_addr <= bias_mr_addr_reg;
    end
end

always @(posedge clk_i) begin
    bias_addr_dly1 <= bias_addr;
end
assign dwcctl_vputy__br_addr_o = bias_addr_dly1;
assign dwcctl_vputy__br_index_o = bias_mr_index_reg;

// generate sv prameters
assign dwcctl_vputy__clip_o = clip_data_reg;
assign dwcctl_vputy__shfl_o = channel_shuffle_type_reg[1];

// generate mrd addr/index
always @(posedge clk_i) begin
    if( (cur_st == ST_CALC_OCH_FIRST_PH) || (cur_st == ST_CALC_OCH_LEFT_PH) ) begin
        if(update_och_sig) begin
            if(channel_shuffle_type_reg[0]) begin
                mrd_addr <= mrd_addr + 2'h2;
            end else begin
                mrd_addr <= mrd_addr + 1'b1;
            end
        end
    end else begin
        mrd_addr <= ofm_mr_addr_reg;
    end
end

always @(posedge clk_i) begin
    mrd_addr_dly1 <= mrd_addr;
end
assign dwcctl_vputy__mrd_addr_o = mrd_addr_dly1;
assign dwcctl_vputy__mrd_index_o = ofm_mr_index_reg;

// generate strobe_h
assign dwcctl_vputy__strobe_h_o = 8'hff;

//======================================================================================================================
// just for simulation
//======================================================================================================================
// synthesis translate_off

// synthesis translate_on

//======================================================================================================================
// probe signals
//======================================================================================================================

endmodule   
