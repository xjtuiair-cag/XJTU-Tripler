// +FHDR------------------------------------------------------------------------
// XJTU IAIR Corporation All Rights Reserved
// -----------------------------------------------------------------------------
// FILE NAME  : conv_ctrl.v
// DEPARTMENT : CAG of IAIR
// AUTHOR     : XXXX
// AUTHOR'S EMAIL :XXXX@mail.xjtu.edu.cn
// -----------------------------------------------------------------------------
// Ver 1.0  2019--01--01 initial version.
// -----------------------------------------------------------------------------
// KEYWORDS   : convolution, controlling,
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

module conv_ctrl #(
    parameter REGMAP_ADDR_WTH = 8,
    parameter REGMAP_DATA_WTH = 32,
    parameter MRX_IND_WTH = 5,
    parameter MRX_ADDR_WTH = 9,
    parameter VR_IND_WTH = 4,
    parameter VPR_IND_WTH = 3,
    parameter SR_DATA_WTH = 32
) (
    // clock & reset
    input                                   clk_i,
    input                                   rst_i,

    // from register_map module
    input [REGMAP_ADDR_WTH-1 : 0]           regmap_conv__waddr_i,
    input [REGMAP_DATA_WTH-1 : 0]           regmap_conv__wdata_i,
    input                                   regmap_conv__we_i,
    output                                  regmap_conv__intr_o,

    // to mpu_ctrl module
    output[1 : 0]                           convctl_mpu__code_o,
    output[0 : 0]                           convctl_mpu__type_o,
    output                                  convctl_mpu0__mrs0_sl_o,
    output                                  convctl_mpu0__mrs0_sr_o,
    output[MRX_IND_WTH-1 : 0]               convctl_mpu0__mrs0_index_o,
    output[MRX_ADDR_WTH-1 : 0]              convctl_mpu0__mrs0_addr_o,
    output                                  convctl_mpu1__mrs0_sl_o,
    output                                  convctl_mpu1__mrs0_sr_o,
    output[MRX_IND_WTH-1 : 0]               convctl_mpu1__mrs0_index_o,
    output[MRX_ADDR_WTH-1 : 0]              convctl_mpu1__mrs0_addr_o,
    output[MRX_IND_WTH-1 : 0]               convctl_mpu__mrs1_index_o,
    output[MRX_ADDR_WTH-1 : 0]              convctl_mpu__mrs1_addr_o,
    output[VR_IND_WTH-1 : 0]                convctl_mpu__vrd_index_o,
    output[6 : 0]                           convctl_mpu__mac_len_o,

    // to vpu_ctrl module
    output[5 : 0]                           convctl_vpu__code_o,
    output[MRX_IND_WTH-1 : 0]               convctl_vpu__br_index_o,
    output[MRX_ADDR_WTH-1 : 0]              convctl_vpu__br_addr_o,
    output[4 : 0]                           convctl_vpu__clip_o,
    output[0 : 0]                           convctl_vpu__shfl_o,
    output[MRX_IND_WTH-1 : 0]               convctl_vpu__sv_index_o,
    output[MRX_ADDR_WTH-1 : 0]              convctl_vpu__sv_addr_o,
    output[7 : 0]                           convctl_vpu__sv_strobe_h_o
);

//======================================================================================================================
// Wire & Reg declaration
//======================================================================================================================
localparam SET_START = 0;
localparam CLR_INTR = 1;

localparam EN_ACT = 0;
localparam EN_SUM = 1;
localparam EN_BIAS = 2;
localparam EN_RELU = 3;
localparam EN_SHFL = 4;
localparam EN_CHPRI = 5;

localparam VPU_DLY = 17;

localparam ST_IDLE = 3'h0;
localparam ST_CALC_OCH_FIRST_PH = 3'h1;
localparam ST_CALC_OCH_LEFT_PH = 3'h2;
localparam ST_WAIT_VPROC = 3'h3;
localparam ST_DONE = 3'h4;

localparam MPU_CODE_MMUL = 2'h1;
localparam MPU_CODE_MMAC = 2'h3;

localparam MPU_TYPE_MM = 0;
localparam MPU_TYPE_VM = 1;

reg   [7 : 0]                           ifm_width;
reg   [7 : 0]                           ifm_channel;
reg   [3 : 0]                           wt_width;
reg   [3 : 0]                           wt_height;
reg   [7 : 0]                           ofm_channel;
reg   [7 : 0]                           stride_w;
reg   [7 : 0]                           dilation_w;
reg   [4 : 0]                           clip_data;
reg                                     relu_en;
reg                                     bias_en;
reg   [1 : 0]                           channel_shuffle_type;
reg                                     channel64_priority;
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
reg   [MRX_IND_WTH-1 : 0]               core0_ifm_line1_mr_index;
reg   [MRX_ADDR_WTH-1 : 0]              core0_ifm_line1_mr_addr;
reg   [MRX_IND_WTH-1 : 0]               core0_ifm_line2_mr_index;
reg   [MRX_ADDR_WTH-1 : 0]              core0_ifm_line2_mr_addr;
reg   [MRX_IND_WTH-1 : 0]               core1_ifm_line0_mr_index;
reg   [MRX_ADDR_WTH-1 : 0]              core1_ifm_line0_mr_addr;
reg   [MRX_IND_WTH-1 : 0]               core1_ifm_line1_mr_index;
reg   [MRX_ADDR_WTH-1 : 0]              core1_ifm_line1_mr_addr;
reg   [MRX_IND_WTH-1 : 0]               core1_ifm_line2_mr_index;
reg   [MRX_ADDR_WTH-1 : 0]              core1_ifm_line2_mr_addr;

reg                                     mcu_set_start;
reg                                     mcu_clr_intr;
reg   [7 : 0]                           ifm_width_reg;
reg   [7 : 0]                           ifm_channel_reg;
reg   [3 : 0]                           wt_width_reg;
reg   [3 : 0]                           wt_height_reg;
reg   [7 : 0]                           ofm_channel_reg;
reg   [7 : 0]                           stride_w_reg;
reg   [7 : 0]                           dilation_w_reg;
reg   [4 : 0]                           clip_data_reg;
reg                                     relu_en_reg;
reg                                     bias_en_reg;
reg   [1 : 0]                           channel_shuffle_type_reg;
reg                                     channel64_priority_reg;
reg   [MRX_ADDR_WTH-1 : 0]              pad_left_reg;
reg   [MRX_ADDR_WTH-1 : 0]              pad_offset_reg;
reg   [MRX_IND_WTH-1 : 0]               wt_mr_index_reg;
reg   [MRX_ADDR_WTH-1 : 0]              wt_mr_addr_reg;
reg   [MRX_IND_WTH-1 : 0]               bias_mr_index_reg;
reg   [MRX_ADDR_WTH-1 : 0]              bias_mr_addr_reg;
reg   [MRX_IND_WTH-1 : 0]               ofm_mr_index_reg;
reg   [MRX_ADDR_WTH-1 : 0]              ofm_mr_addr_reg;
reg   [MRX_IND_WTH-1 : 0]               core0_ifm_line0_mr_index_reg;
reg   [MRX_ADDR_WTH-1 : 0]              core0_ifm_line0_mr_addr_reg;
reg   [MRX_IND_WTH-1 : 0]               core0_ifm_line1_mr_index_reg;
reg   [MRX_ADDR_WTH-1 : 0]              core0_ifm_line1_mr_addr_reg;
reg   [MRX_IND_WTH-1 : 0]               core0_ifm_line2_mr_index_reg;
reg   [MRX_ADDR_WTH-1 : 0]              core0_ifm_line2_mr_addr_reg;
reg   [MRX_IND_WTH-1 : 0]               core1_ifm_line0_mr_index_reg;
reg   [MRX_ADDR_WTH-1 : 0]              core1_ifm_line0_mr_addr_reg;
reg   [MRX_IND_WTH-1 : 0]               core1_ifm_line1_mr_index_reg;
reg   [MRX_ADDR_WTH-1 : 0]              core1_ifm_line1_mr_addr_reg;
reg   [MRX_IND_WTH-1 : 0]               core1_ifm_line2_mr_index_reg;
reg   [MRX_ADDR_WTH-1 : 0]              core1_ifm_line2_mr_addr_reg;

reg   [2 : 0]                           cur_st;
reg   [2 : 0]                           next_st;
reg   [7 : 0]                           ich_cnt;
reg   [3 : 0]                           wtw_cnt;
reg   [3 : 0]                           wth_cnt;
reg   [7 : 0]                           och_cnt;
reg   [7 : 0]                           ifmw_cnt;
reg   [5 : 0]                           wait_vproc_cnt;

reg                                     conv_intr;

wire                                    update_wtw_sig;
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
reg                                     update_wtw_sig_dly1;
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
reg   [MRX_IND_WTH-1 : 0]               mrs1_index_dly1;
reg   [MRX_ADDR_WTH-1 : 0]              mrs1_addr_dly1;

reg   [1 : 0]                           mpu_code;

reg   [MRX_ADDR_WTH-1 : 0]              vpu_br_addr;
reg   [MRX_ADDR_WTH*(VPU_DLY+1)-1 : 0]  vpu_br_addr_dlychain;

wire  [5 : 0]                           vpu_code;
wire  [4 : 0]                           vpu_clip;
wire  [0 : 0]                           vpu_shfl;
reg   [6*(VPU_DLY+1)-1 : 0]             vpu_code_dlychain;
reg   [5*(VPU_DLY+1)-1 : 0]             vpu_clip_dlychain;
reg   [VPU_DLY : 0]                     vpu_shfl_dlychain;

reg   [MRX_ADDR_WTH+2 : 0]              sv_addr;
reg   [(MRX_ADDR_WTH+3)*(VPU_DLY+1)-1 : 0]  sv_addr_dlychain;
wire  [7 : 0]                           sv_strobe_h;

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
        ofm_channel <= 8'h0;
        stride_w <= 8'h0;
        dilation_w <= 8'h0;
        clip_data <= 5'h0;
        relu_en <= 1'b0;
        bias_en <= 1'b0;
        channel_shuffle_type <= 2'h0;
        channel64_priority <= 1'b0;
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
    end else if(regmap_conv__we_i) begin
        if(regmap_conv__waddr_i[REGMAP_ADDR_WTH-1 : 2] ==  'h1) ifm_width <= regmap_conv__wdata_i[7 : 0];
        if(regmap_conv__waddr_i[REGMAP_ADDR_WTH-1 : 2] ==  'h1) ifm_channel <= regmap_conv__wdata_i[15 : 8];
        if(regmap_conv__waddr_i[REGMAP_ADDR_WTH-1 : 2] ==  'h1) wt_width <= regmap_conv__wdata_i[19 : 16];
        if(regmap_conv__waddr_i[REGMAP_ADDR_WTH-1 : 2] ==  'h1) wt_height <= regmap_conv__wdata_i[23 : 20];
        if(regmap_conv__waddr_i[REGMAP_ADDR_WTH-1 : 2] ==  'h1) ofm_channel <= regmap_conv__wdata_i[31 : 24];
        if(regmap_conv__waddr_i[REGMAP_ADDR_WTH-1 : 2] ==  'h2) stride_w <= regmap_conv__wdata_i[7 : 0];
        if(regmap_conv__waddr_i[REGMAP_ADDR_WTH-1 : 2] ==  'h2) dilation_w <= regmap_conv__wdata_i[15 : 8];
        if(regmap_conv__waddr_i[REGMAP_ADDR_WTH-1 : 2] ==  'h2) clip_data <= regmap_conv__wdata_i[20 : 16];
        if(regmap_conv__waddr_i[REGMAP_ADDR_WTH-1 : 2] ==  'h2) relu_en <= regmap_conv__wdata_i[24 : 24];
        if(regmap_conv__waddr_i[REGMAP_ADDR_WTH-1 : 2] ==  'h2) bias_en <= regmap_conv__wdata_i[25 : 25];
        if(regmap_conv__waddr_i[REGMAP_ADDR_WTH-1 : 2] ==  'h2) channel_shuffle_type <= regmap_conv__wdata_i[27 : 26];
        if(regmap_conv__waddr_i[REGMAP_ADDR_WTH-1 : 2] ==  'h2) channel64_priority <= regmap_conv__wdata_i[28 : 28];
        if(regmap_conv__waddr_i[REGMAP_ADDR_WTH-1 : 2] ==  'h3) pad_left <= regmap_conv__wdata_i[0 +: MRX_ADDR_WTH];
        if(regmap_conv__waddr_i[REGMAP_ADDR_WTH-1 : 2] ==  'h3) pad_offset <= regmap_conv__wdata_i[16 +: MRX_ADDR_WTH];
        if(regmap_conv__waddr_i[REGMAP_ADDR_WTH-1 : 2] ==  'h4) wt_mr_addr <= regmap_conv__wdata_i[MRX_ADDR_WTH-1 : 0];
        if(regmap_conv__waddr_i[REGMAP_ADDR_WTH-1 : 2] ==  'h4) wt_mr_index <= regmap_conv__wdata_i[MRX_IND_WTH+MRX_ADDR_WTH-1 : MRX_ADDR_WTH];
        if(regmap_conv__waddr_i[REGMAP_ADDR_WTH-1 : 2] ==  'h4) bias_mr_addr <= regmap_conv__wdata_i[MRX_ADDR_WTH+15 : 16];
        if(regmap_conv__waddr_i[REGMAP_ADDR_WTH-1 : 2] ==  'h4) bias_mr_index <= regmap_conv__wdata_i[MRX_IND_WTH+MRX_ADDR_WTH+15 : MRX_ADDR_WTH+16];
        if(regmap_conv__waddr_i[REGMAP_ADDR_WTH-1 : 2] ==  'h5) ofm_mr_addr <= regmap_conv__wdata_i[MRX_ADDR_WTH-1 : 0];
        if(regmap_conv__waddr_i[REGMAP_ADDR_WTH-1 : 2] ==  'h5) ofm_mr_index <= regmap_conv__wdata_i[MRX_IND_WTH+MRX_ADDR_WTH-1 : MRX_ADDR_WTH];
        if(regmap_conv__waddr_i[REGMAP_ADDR_WTH-1 : 2] ==  'h6) core0_ifm_line0_mr_addr <= regmap_conv__wdata_i[MRX_ADDR_WTH-1 : 0];
        if(regmap_conv__waddr_i[REGMAP_ADDR_WTH-1 : 2] ==  'h6) core0_ifm_line0_mr_index <= regmap_conv__wdata_i[MRX_IND_WTH+MRX_ADDR_WTH-1 : MRX_ADDR_WTH];
        if(regmap_conv__waddr_i[REGMAP_ADDR_WTH-1 : 2] ==  'h6) core1_ifm_line0_mr_addr <= regmap_conv__wdata_i[MRX_ADDR_WTH+15 : 16];
        if(regmap_conv__waddr_i[REGMAP_ADDR_WTH-1 : 2] ==  'h6) core1_ifm_line0_mr_index <= regmap_conv__wdata_i[MRX_IND_WTH+MRX_ADDR_WTH+15 : MRX_ADDR_WTH+16];
        if(regmap_conv__waddr_i[REGMAP_ADDR_WTH-1 : 2] ==  'h7) core0_ifm_line1_mr_addr <= regmap_conv__wdata_i[MRX_ADDR_WTH-1 : 0];
        if(regmap_conv__waddr_i[REGMAP_ADDR_WTH-1 : 2] ==  'h7) core0_ifm_line1_mr_index <= regmap_conv__wdata_i[MRX_IND_WTH+MRX_ADDR_WTH-1 : MRX_ADDR_WTH];
        if(regmap_conv__waddr_i[REGMAP_ADDR_WTH-1 : 2] ==  'h7) core1_ifm_line1_mr_addr <= regmap_conv__wdata_i[MRX_ADDR_WTH+15 : 16];
        if(regmap_conv__waddr_i[REGMAP_ADDR_WTH-1 : 2] ==  'h7) core1_ifm_line1_mr_index <= regmap_conv__wdata_i[MRX_IND_WTH+MRX_ADDR_WTH+15 : MRX_ADDR_WTH+16];
        if(regmap_conv__waddr_i[REGMAP_ADDR_WTH-1 : 2] ==  'h8) core0_ifm_line2_mr_addr <= regmap_conv__wdata_i[MRX_ADDR_WTH-1 : 0];
        if(regmap_conv__waddr_i[REGMAP_ADDR_WTH-1 : 2] ==  'h8) core0_ifm_line2_mr_index <= regmap_conv__wdata_i[MRX_IND_WTH+MRX_ADDR_WTH-1 : MRX_ADDR_WTH];
        if(regmap_conv__waddr_i[REGMAP_ADDR_WTH-1 : 2] ==  'h8) core1_ifm_line2_mr_addr <= regmap_conv__wdata_i[MRX_ADDR_WTH+15 : 16];
        if(regmap_conv__waddr_i[REGMAP_ADDR_WTH-1 : 2] ==  'h8) core1_ifm_line2_mr_index <= regmap_conv__wdata_i[MRX_IND_WTH+MRX_ADDR_WTH+15 : MRX_ADDR_WTH+16];
    end
end

// generate mcu control signal, such as: set_start, clr_intr.
// store the copy of all parameters once receiving set_start signal.
always @(posedge clk_i) begin
    if(rst_i) begin
        mcu_set_start <= 1'b0;
        mcu_clr_intr <= 1'b0;
        ifm_width_reg <= 'h0;
        ifm_channel_reg <= 'h0;
        wt_width_reg <= 'h0;
        wt_height_reg <= 'h0;
        ofm_channel_reg <= 'h0;
        stride_w_reg <= 'h0;
        dilation_w_reg <= 'h0;
        clip_data_reg <= 'h0;
        relu_en_reg <= 'h0;
        bias_en_reg <= 'h0;
        channel_shuffle_type_reg <= 'h0;
        channel64_priority_reg <= 'h0;
        pad_left_reg <= 'h0;
        pad_offset_reg <= 'h0;
        wt_mr_index_reg <= 'h0;
        wt_mr_addr_reg <= 'h0;
        bias_mr_index_reg <= 'h0;
        bias_mr_addr_reg <= 'h0;
        ofm_mr_index_reg <= 'h0;
        ofm_mr_addr_reg <= 'h0;
        core0_ifm_line0_mr_index_reg <= 'h0;
        core0_ifm_line0_mr_addr_reg <= 'h0;
        core0_ifm_line1_mr_index_reg <= 'h0;
        core0_ifm_line1_mr_addr_reg <= 'h0;
        core0_ifm_line2_mr_index_reg <= 'h0;
        core0_ifm_line2_mr_addr_reg <= 'h0;
        core1_ifm_line0_mr_index_reg <= 'h0;
        core1_ifm_line0_mr_addr_reg <= 'h0;
        core1_ifm_line1_mr_index_reg <= 'h0;
        core1_ifm_line1_mr_addr_reg <= 'h0;
        core1_ifm_line2_mr_index_reg <= 'h0;
        core1_ifm_line2_mr_addr_reg <= 'h0;
    end else begin
        mcu_set_start <= 1'b0;
        mcu_clr_intr <= 1'b0;
        if(regmap_conv__we_i && (|regmap_conv__waddr_i == 1'b0)) begin
            if(regmap_conv__wdata_i[SET_START]) begin
                mcu_set_start <= 1'b1;
                ifm_width_reg <= ifm_width;
                ifm_channel_reg <= ifm_channel;
                wt_width_reg <= wt_width;
                wt_height_reg <= wt_height;
                ofm_channel_reg <= ofm_channel;
                stride_w_reg <= stride_w;
                dilation_w_reg <= dilation_w;
                clip_data_reg <= clip_data;
                relu_en_reg <= relu_en;
                bias_en_reg <= bias_en;
                channel_shuffle_type_reg <= channel_shuffle_type;
                channel64_priority_reg <= channel64_priority;
                pad_left_reg <= pad_left;
                pad_offset_reg <= pad_offset;
                wt_mr_index_reg <= wt_mr_index;
                wt_mr_addr_reg <= wt_mr_addr;
                bias_mr_index_reg <= bias_mr_index;
                bias_mr_addr_reg <= bias_mr_addr;
                ofm_mr_index_reg <= ofm_mr_index;
                ofm_mr_addr_reg <= ofm_mr_addr;
                core0_ifm_line0_mr_index_reg <= core0_ifm_line0_mr_index;
                core0_ifm_line0_mr_addr_reg <= core0_ifm_line0_mr_addr;
                core0_ifm_line1_mr_index_reg <= core0_ifm_line1_mr_index;
                core0_ifm_line1_mr_addr_reg <= core0_ifm_line1_mr_addr;
                core0_ifm_line2_mr_index_reg <= core0_ifm_line2_mr_index;
                core0_ifm_line2_mr_addr_reg <= core0_ifm_line2_mr_addr;
                core1_ifm_line0_mr_index_reg <= core1_ifm_line0_mr_index;
                core1_ifm_line0_mr_addr_reg <= core1_ifm_line0_mr_addr;
                core1_ifm_line1_mr_index_reg <= core1_ifm_line1_mr_index;
                core1_ifm_line1_mr_addr_reg <= core1_ifm_line1_mr_addr;
                core1_ifm_line2_mr_index_reg <= core1_ifm_line2_mr_index;
                core1_ifm_line2_mr_addr_reg <= core1_ifm_line2_mr_addr;
            end
            if(regmap_conv__wdata_i[CLR_INTR]) begin
                mcu_clr_intr <= 1'b1;
            end
        end
    end
end

// conv_ctrl FSM
// the FSM and its variant counter define the main calculation phase.
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
            if( (ifm_channel_reg == 8'h0) && (wt_width_reg == 4'h0) && (wt_height_reg == 4'h0) ) begin
                if( (och_cnt == ofm_channel_reg) && (ifmw_cnt == ifm_width_reg) ) begin
                    next_st = ST_WAIT_VPROC;
                end else begin
                    next_st = ST_CALC_OCH_FIRST_PH;
                end
            end else begin
                next_st = ST_CALC_OCH_LEFT_PH;
            end
        end
        ST_CALC_OCH_LEFT_PH: begin
            if( (ich_cnt == ifm_channel_reg) && (wtw_cnt == wt_width_reg) && (wth_cnt == wt_height_reg)) begin
                if( (och_cnt == ofm_channel_reg) && (ifmw_cnt == ifm_width_reg) ) begin
                    next_st = ST_WAIT_VPROC;
                end else begin
                    next_st = ST_CALC_OCH_FIRST_PH;
                end
            end
        end
        ST_WAIT_VPROC: begin
            if(wait_vproc_cnt == 'd30) begin //TODO: replace the delay by calculating the accurate value
                next_st = ST_DONE;
            end
        end
        ST_DONE: begin
            next_st = ST_IDLE;
        end
        default: begin
            next_st = cur_st;
        end
    endcase
end

always @(posedge clk_i) begin
    if(rst_i) begin
        ich_cnt <= 8'h0;
        wtw_cnt <= 4'h0;
        wth_cnt <= 4'h0;
        och_cnt <= 8'h0;
        ifmw_cnt <= 8'h0;
    end else begin
        if( (cur_st == ST_CALC_OCH_FIRST_PH) || (cur_st == ST_CALC_OCH_LEFT_PH) ) begin
            if(ich_cnt == ifm_channel_reg) begin
                if(wtw_cnt == wt_width_reg) begin
                    if(wth_cnt == wt_height_reg) begin
                        if(och_cnt == ofm_channel_reg) begin
                            ifmw_cnt <= ifmw_cnt + 1'b1;
                            och_cnt <= 8'h0;
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
                ich_cnt <= 8'h0;
            end else begin
                ich_cnt <= ich_cnt + 1'b1;
            end
        end else begin
            ich_cnt <= 8'h0;
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

// The interrupt signal is set when the calculation is finished, and is clear when receiving command from register map.
always @(posedge clk_i) begin
    if(rst_i) begin
        conv_intr <= 1'b0;
    end else begin
        if(cur_st == ST_DONE) begin
            conv_intr <= 1'b1;
        end else if(mcu_clr_intr) begin
            conv_intr <= 1'b0;
        end
    end
end
assign regmap_conv__intr_o = conv_intr;

// In convolution schedule, the calculation priority is ifm_channel, wt_width, wt_height, ofm_channel, and ofm_width.
// The address of ifm_channel and wt_width is consecutive.
// When change wt_height, the address jumps. So an update signal is needed.
// So does the ofm_channel and ofm_width changes.
// Below signals indicate 3 abovementioned changes.
assign update_wtw_sig = (ich_cnt == ifm_channel_reg) && ( (cur_st == ST_CALC_OCH_FIRST_PH) || (cur_st == ST_CALC_OCH_LEFT_PH) );
assign update_wth_sig = (wtw_cnt == wt_width_reg) && update_wtw_sig;
assign update_och_sig = (wth_cnt == wt_height_reg) && update_wth_sig;
assign update_ifmw_sig = (och_cnt == ofm_channel_reg) && update_och_sig;

// generate mrs0 addr/index
// The basic mrs0 addr updates when ofm_width changes.
// The mrs0 addr updates every cycle.
// The mrs0 index changes among the 3 lines, which remains const during calculation.
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
    update_wtw_sig_dly1 <= update_wtw_sig;
    mpu0_mrs0_init_addr_dly1 <= mpu0_mrs0_init_addr;
    mpu1_mrs0_init_addr_dly1 <= mpu1_mrs0_init_addr;
end

always @(posedge clk_i) begin
    mpu0_mrs0_index <= mpu0_mrs0_base_index;
    mpu1_mrs0_index <= mpu1_mrs0_base_index;
end

always @(posedge clk_i) begin
    if( (cur_st_dly1 == ST_CALC_OCH_FIRST_PH) || (cur_st_dly1 == ST_CALC_OCH_LEFT_PH) ) begin
        if(update_wtw_sig_dly1) begin
            if(update_wth_sig_dly1) begin
                mpu0_mrs0_addr <= mpu0_mrs0_base_addr;
                mpu1_mrs0_addr <= mpu1_mrs0_base_addr;
            end else begin
                mpu0_mrs0_addr <= mpu0_mrs0_addr + dilation_w_reg + 1'b1;
                mpu1_mrs0_addr <= mpu1_mrs0_addr + dilation_w_reg + 1'b1;
            end
        end else begin
            mpu0_mrs0_addr <= mpu0_mrs0_addr + 1'b1;
            mpu1_mrs0_addr <= mpu1_mrs0_addr + 1'b1;
        end
    end else begin
        mpu0_mrs0_addr <= mpu0_mrs0_base_addr;
        mpu1_mrs0_addr <= mpu1_mrs0_base_addr;
    end
end

always @(posedge clk_i) begin
    if( (cur_st_dly1 == ST_CALC_OCH_FIRST_PH) || (cur_st_dly1 == ST_CALC_OCH_LEFT_PH) ) begin
        if(update_wtw_sig_dly1) begin
            if(update_wth_sig_dly1) begin
                mpu0_mrs0_pre_addr <= mpu0_mrs0_base_addr + pad_offset_reg;
                mpu1_mrs0_pre_addr <= mpu1_mrs0_base_addr + pad_offset_reg;
            end else begin
                mpu0_mrs0_pre_addr <= mpu0_mrs0_pre_addr + dilation_w_reg + 1'b1;
                mpu1_mrs0_pre_addr <= mpu1_mrs0_pre_addr + dilation_w_reg + 1'b1;
            end
        end else begin
            mpu0_mrs0_pre_addr <= mpu0_mrs0_pre_addr + 1'b1;
            mpu1_mrs0_pre_addr <= mpu1_mrs0_pre_addr + 1'b1;
        end
    end else begin
        mpu0_mrs0_pre_addr <= mpu0_mrs0_base_addr + pad_offset_reg;
        mpu1_mrs0_pre_addr <= mpu1_mrs0_base_addr + pad_offset_reg;
    end
end

always @(posedge clk_i) begin
    if( (cur_st_dly1 == ST_CALC_OCH_FIRST_PH) || (cur_st_dly1 == ST_CALC_OCH_LEFT_PH) ) begin
        if(update_wtw_sig_dly1) begin
            if(update_wth_sig_dly1) begin
                mpu0_mrs0_post_addr <= mpu0_mrs0_base_addr - pad_offset_reg;
                mpu1_mrs0_post_addr <= mpu1_mrs0_base_addr - pad_offset_reg;
            end else begin
                mpu0_mrs0_post_addr <= mpu0_mrs0_post_addr + dilation_w_reg + 1'b1;
                mpu1_mrs0_post_addr <= mpu1_mrs0_post_addr + dilation_w_reg + 1'b1;
            end
        end else begin
            mpu0_mrs0_post_addr <= mpu0_mrs0_post_addr + 1'b1;
            mpu1_mrs0_post_addr <= mpu1_mrs0_post_addr + 1'b1;
        end
    end else begin
        mpu0_mrs0_post_addr <= mpu0_mrs0_base_addr - pad_offset_reg;
        mpu1_mrs0_post_addr <= mpu1_mrs0_base_addr - pad_offset_reg;
    end
end

assign mpu0_mrs0_last_addr_signed = mpu0_mrs0_init_addr_dly1 + pad_offset_reg;
assign convctl_mpu0__mrs0_sl_o = (mpu0_mrs0_addr >= mpu0_mrs0_last_addr_signed) ? 1'b1 : 1'b0; 
assign convctl_mpu0__mrs0_sr_o = (mpu0_mrs0_addr < mpu0_mrs0_init_addr_dly1) ? 1'b1 : 1'b0; 
assign convctl_mpu0__mrs0_index_o = (channel64_priority_reg && convctl_mpu0__mrs0_sl_o) ? {MRX_IND_WTH{1'b1}}
                                  : (channel64_priority_reg && convctl_mpu0__mrs0_sr_o) ? {MRX_IND_WTH{1'b1}}
                                  : mpu0_mrs0_index;
assign convctl_mpu0__mrs0_addr_o = (convctl_mpu0__mrs0_sl_o) ? mpu0_mrs0_post_addr
                                 : (convctl_mpu0__mrs0_sr_o) ? mpu0_mrs0_pre_addr
                                 : mpu0_mrs0_addr;

assign mpu1_mrs0_last_addr_signed = mpu1_mrs0_init_addr_dly1 + pad_offset_reg;
assign convctl_mpu1__mrs0_sl_o = (mpu1_mrs0_addr >= mpu1_mrs0_last_addr_signed) ? 1'b1 : 1'b0; 
assign convctl_mpu1__mrs0_sr_o = (mpu1_mrs0_addr < mpu1_mrs0_init_addr_dly1) ? 1'b1 : 1'b0; 
assign convctl_mpu1__mrs0_index_o = (channel64_priority_reg && convctl_mpu1__mrs0_sl_o) ? {MRX_IND_WTH{1'b1}}
                                  : (channel64_priority_reg && convctl_mpu1__mrs0_sr_o) ? {MRX_IND_WTH{1'b1}}
                                  : mpu1_mrs0_index;
assign convctl_mpu1__mrs0_addr_o = (convctl_mpu1__mrs0_sl_o) ? mpu1_mrs0_post_addr
                                 : (convctl_mpu1__mrs0_sr_o) ? mpu1_mrs0_pre_addr
                                 : mpu1_mrs0_addr;

// generate mrs1 addr/index
// The mrs1 is the address of weight.
// The mrs1 index is constant during calculation. While the mrs1 addr increases per cycle, except ofm_width changes.
always @(posedge clk_i) begin
    if( (cur_st == ST_CALC_OCH_FIRST_PH) || (cur_st == ST_CALC_OCH_LEFT_PH) ) begin
        mrs1_addr <= mrs1_addr + 1'b1;
        mrs1_index <= mrs1_index + ((&mrs1_addr == 1'b1) ? 1'b1 : 1'b0);
        if(update_ifmw_sig) begin
            mrs1_addr <= wt_mr_addr_reg;
            mrs1_index <= wt_mr_index_reg;
        end
    end else begin
        mrs1_addr <= wt_mr_addr_reg;
        mrs1_index <= wt_mr_index_reg;
    end
end

always @(posedge clk_i) begin
    mrs1_index_dly1 <= mrs1_index;
    mrs1_addr_dly1 <= mrs1_addr;
end
assign convctl_mpu__mrs1_index_o = mrs1_index_dly1;
assign convctl_mpu__mrs1_addr_o = mrs1_addr_dly1;

// For the first calculation of each ofm point, send MUL instruction. otherwise send MAC instructions.
// MPU type is set as Matrix mode.
always @(posedge clk_i) begin
    if(rst_i) begin
        mpu_code <= 2'h0;
    end else begin
        if(cur_st == ST_CALC_OCH_FIRST_PH) begin
            mpu_code <= MPU_CODE_MMUL;
        end else if(cur_st == ST_CALC_OCH_LEFT_PH) begin
            mpu_code <= MPU_CODE_MMAC;
        end else begin
            mpu_code <= 2'h0;
        end
    end
end
assign convctl_mpu__code_o = mpu_code;
assign convctl_mpu__type_o = channel64_priority_reg ? MPU_TYPE_VM : MPU_TYPE_MM;

// In register version of DPU, the vpu register is sticked to 0, and the MAC length is constant 1.
assign convctl_mpu__vrd_index_o = 'h0;
assign convctl_mpu__mac_len_o = 7'h1;

// generate the controlling signals of vpu_ctrl module
// When update_och_sig is active, one sum comes out.

// ld_bias index is constant during calculation.
// ld_bias addr increases for every sum, and reset for next output featuremap point.
always @(posedge clk_i) begin
    if( (cur_st == ST_CALC_OCH_FIRST_PH) || (cur_st == ST_CALC_OCH_LEFT_PH) ) begin
        if(update_och_sig) begin
            vpu_br_addr <= vpu_br_addr + 1'b1;
            if(update_ifmw_sig) begin
                vpu_br_addr <= bias_mr_addr_reg;
            end
        end
    end else begin
        vpu_br_addr <= bias_mr_addr_reg;
    end
end

always @(posedge clk_i) begin
    vpu_br_addr_dlychain <= {vpu_br_addr_dlychain[VPU_DLY*MRX_ADDR_WTH-1 : 0], vpu_br_addr};
end
assign convctl_vpu__br_addr_o = vpu_br_addr_dlychain[VPU_DLY*MRX_ADDR_WTH +: MRX_ADDR_WTH];
assign convctl_vpu__br_index_o = bias_mr_index_reg;

// Since each bit of vpu_code has different meaning, assign it respectively.
// Other parameters can be assigned directly.
assign vpu_code[EN_ACT] = update_och_sig;
assign vpu_code[EN_SUM] = channel64_priority_reg ? 1'b1 : 1'b0;
assign vpu_code[EN_BIAS] = bias_en_reg;
assign vpu_code[EN_RELU] = relu_en_reg;
assign vpu_code[EN_SHFL] = channel_shuffle_type_reg[0];
assign vpu_code[EN_CHPRI] = channel64_priority_reg;

assign vpu_clip = clip_data_reg;
assign vpu_shfl = channel_shuffle_type_reg[1];

always @(posedge clk_i) begin
    vpu_code_dlychain <= {vpu_code_dlychain[VPU_DLY*6-1 : 0], vpu_code};
    vpu_clip_dlychain <= {vpu_clip_dlychain[VPU_DLY*5-1 : 0], vpu_clip};
    vpu_shfl_dlychain <= {vpu_shfl_dlychain[VPU_DLY-1 : 0], vpu_shfl};
end
assign convctl_vpu__code_o = vpu_code_dlychain[VPU_DLY*6 +: 6];
assign convctl_vpu__clip_o = vpu_clip_dlychain[VPU_DLY*5 +: 5];
assign convctl_vpu__shfl_o = vpu_shfl_dlychain[VPU_DLY];

// generate sv_index/addr
always @(posedge clk_i) begin
    if( (cur_st == ST_CALC_OCH_FIRST_PH) || (cur_st == ST_CALC_OCH_LEFT_PH) ) begin
        if(update_och_sig) begin
            // if channel64 priority is disabled, ofm address is calculated as follow:
            if(channel64_priority_reg) begin
                if(vpu_code[EN_SHFL]) begin
                    sv_addr <= sv_addr + 2'h2;
                end else begin
                    sv_addr <= sv_addr + 1'b1;
                end
            // else if channel64 priority is enabled, ofm address is calculated as follow:
            end else begin
                if(vpu_code[EN_SHFL]) begin
                    sv_addr[3 +: MRX_ADDR_WTH] <= sv_addr[3 +: MRX_ADDR_WTH] + 2'h2;
                end else begin
                    sv_addr[3 +: MRX_ADDR_WTH] <= sv_addr[3 +: MRX_ADDR_WTH] + 1'b1;
                end
            end
        end
    end else begin
        sv_addr <= {ofm_mr_addr_reg, 3'h0};
    end
end

always @(posedge clk_i) begin
    sv_addr_dlychain <= {sv_addr_dlychain[VPU_DLY*(MRX_ADDR_WTH+3)-1 : 0], sv_addr};
end
assign convctl_vpu__sv_index_o = ofm_mr_index_reg;
assign convctl_vpu__sv_addr_o = sv_addr_dlychain[VPU_DLY*(MRX_ADDR_WTH+3)+3 +: MRX_ADDR_WTH];
dec_bin_to_onehot #(3, 8) sv_strob_gen (sv_addr_dlychain[VPU_DLY*(MRX_ADDR_WTH+3) +: 3], sv_strobe_h);
assign convctl_vpu__sv_strobe_h_o = channel64_priority_reg ? sv_strobe_h : 8'hff;

//======================================================================================================================
// just for simulation
//======================================================================================================================
// synthesis translate_off

// synthesis translate_on

//======================================================================================================================
// probe signals
//======================================================================================================================

endmodule   
