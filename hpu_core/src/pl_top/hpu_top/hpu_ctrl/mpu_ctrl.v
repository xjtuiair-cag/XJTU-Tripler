// +FHDR------------------------------------------------------------------------
// XJTU IAIR Corporation All Rights Reserved
// -----------------------------------------------------------------------------
// FILE NAME  : mpu_ctrl.v
// DEPARTMENT : CAG of IAIR
// AUTHOR     : XXXX
// AUTHOR'S EMAIL :XXXX@mail.xjtu.edu.cn
// -----------------------------------------------------------------------------
// Ver 1.0  2019--01--01 initial version.
// -----------------------------------------------------------------------------
// KEYWORDS   : matrix processing unit, controlling,
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

module mpu_ctrl #(
    parameter MRA_IND_WTH = 3,
    parameter MRA_ADDR_WTH = 9,
    parameter MRB_IND_WTH = 3,
    parameter MRB_ADDR_WTH = 9,
    parameter VR_IND_WTH = 4,
    parameter MRX_IND_WTH = 5,
    parameter MRX_ADDR_WTH = 9
) (
    // clock & reset
    input                                   clk_i,
    input                                   rst_i,

    // from conv_ctrl module
    input [1 : 0]                           convctl_mpu__code_i,
    input [0 : 0]                           convctl_mpu__type_i,
    input                                   convctl_mpu0__mrs0_sl_i,
    input                                   convctl_mpu0__mrs0_sr_i,
    input [MRX_IND_WTH-1 : 0]               convctl_mpu0__mrs0_index_i,
    input [MRX_ADDR_WTH-1 : 0]              convctl_mpu0__mrs0_addr_i,
    input                                   convctl_mpu1__mrs0_sl_i,
    input                                   convctl_mpu1__mrs0_sr_i,
    input [MRX_IND_WTH-1 : 0]               convctl_mpu1__mrs0_index_i,
    input [MRX_ADDR_WTH-1 : 0]              convctl_mpu1__mrs0_addr_i,
    input [MRX_IND_WTH-1 : 0]               convctl_mpu__mrs1_index_i,
    input [MRX_ADDR_WTH-1 : 0]              convctl_mpu__mrs1_addr_i,
    input [VR_IND_WTH-1 : 0]                convctl_mpu__vrd_index_i,
    input [6 : 0]                           convctl_mpu__mac_len_i,

    // to mpu module
    output                                  mpu_op_extacc_act_o,
    output                                  mpu_op_bypass_act_o,
    output[0 : 0]                           mpu_op_type_o,

    // to mtxrega module
    output[MRA_IND_WTH-1 : 0]               mpu0_mra__rindex_o,
    output[MRA_ADDR_WTH-1 : 0]              mpu0_mra__raddr_o,
    output                                  mpu0_mra__sl_o,
    output                                  mpu0_mra__sr_o,
    output                                  mpu0_mra__frcz_o,
    output[MRA_IND_WTH-1 : 0]               mpu1_mra__rindex_o,
    output[MRA_ADDR_WTH-1 : 0]              mpu1_mra__raddr_o,
    output                                  mpu1_mra__sl_o,
    output                                  mpu1_mra__sr_o,
    output                                  mpu1_mra__frcz_o,
    output                                  mpu_mra__re_o,
    input                                   mpu_mra__rdata_act_i,

    // to mtxregb module
    output[MRB_IND_WTH-1 : 0]               mpu_mrb__rindex_o,
    output[MRB_ADDR_WTH-1 : 0]              mpu_mrb__raddr_o,
    output                                  mpu_mrb__re_o,
    output[0 : 0]                           mpu_mrb__type_o,
    input                                   mpu_mrb__rdata_act_i,
    input                                   mpu_mrb__vmode_rdata_act_i,

    // to vecreg module
    output[VR_IND_WTH-1 : 0]                mpu_vr__windex_o,
    output                                  mpu_vr__we_o,
    output[VR_IND_WTH-1 : 0]                mpu_vr__rindex_o,
    output                                  mpu_vr__re_o
);

//======================================================================================================================
// Wire & Reg declaration
//======================================================================================================================
localparam MPU_CODE_MMUL = 2'h1;
localparam MPU_CODE_MMAC = 2'h3;
localparam EN_ACT = 0;
localparam EN_MAC = 1;

localparam MPU_TYPE_MM = 0;
localparam MPU_TYPE_VM = 1;

localparam ST_IDLE = 3'b001;
localparam ST_MMAC = 3'b010;
localparam ST_MMUL = 3'b100;

localparam RMR_DLY= 4;
localparam ACC_DLY= 16;
localparam RVR_DLY= 14;
localparam WVR_DLY= 16;

wire  [1 : 0]                           mpu_code;
wire  [0 : 0]                           mpu_type;
wire                                    mpu0_mrs0_sl;
wire                                    mpu0_mrs0_sr;
wire  [MRX_IND_WTH-1 : 0]               mpu0_mrs0_index;
wire  [MRX_ADDR_WTH-1 : 0]              mpu0_mrs0_addr;
wire                                    mpu1_mrs0_sl;
wire                                    mpu1_mrs0_sr;
wire  [MRX_IND_WTH-1 : 0]               mpu1_mrs0_index;
wire  [MRX_ADDR_WTH-1 : 0]              mpu1_mrs0_addr;
wire  [MRX_IND_WTH-1 : 0]               mpu_mrs1_index;
wire  [MRX_ADDR_WTH-1 : 0]              mpu_mrs1_addr;
wire  [VR_IND_WTH-1 : 0]                mpu_vrd_index;
wire  [6 : 0]                           mpu_mac_len;

reg   [2 : 0]                           dec_st;
reg   [2 : 0]                           cur_st;
reg   [6 : 0]                           mac_cnt;

reg   [MRA_IND_WTH-1 : 0]               mpu0_mra_index_reg;
reg   [MRA_ADDR_WTH-1 : 0]              mpu0_mra_addr_reg;
reg                                     mpu0_mra_sl_reg;
reg                                     mpu0_mra_sr_reg;
reg                                     mpu0_mra_frcz_reg;
reg   [MRA_IND_WTH-1 : 0]               mpu1_mra_index_reg;
reg   [MRA_ADDR_WTH-1 : 0]              mpu1_mra_addr_reg;
reg                                     mpu1_mra_sl_reg;
reg                                     mpu1_mra_sr_reg;
reg                                     mpu1_mra_frcz_reg;
reg   [MRB_IND_WTH-1 : 0]               mpu_mrb_index_reg;
reg   [MRB_ADDR_WTH-1 : 0]              mpu_mrb_addr_reg;

wire                                    mr_re;
wire                                    vr_re;
wire                                    vr_we;

reg   [VR_IND_WTH-1 : 0]                vrd_index_r;
wire  [VR_IND_WTH-1 : 0]                vrd_index;

reg   [RMR_DLY : 0]                     mpu_type_dlychain;
reg   [(ACC_DLY+1)*2-1 : 0]             mpu_code_dlychain;

reg   [(WVR_DLY+1)*VR_IND_WTH-1 : 0]    vrd_index_dlychain;
reg   [RVR_DLY : 0]                     vr_re_dlychain;
reg   [WVR_DLY : 0]                     vr_we_dlychain;

//======================================================================================================================
// Instance
//======================================================================================================================

assign mpu_code = convctl_mpu__code_i;
assign mpu_type = convctl_mpu__type_i;
assign mpu0_mrs0_sl = convctl_mpu0__mrs0_sl_i;
assign mpu0_mrs0_sr = convctl_mpu0__mrs0_sr_i;
assign mpu0_mrs0_index = convctl_mpu0__mrs0_index_i;
assign mpu0_mrs0_addr = convctl_mpu0__mrs0_addr_i;
assign mpu1_mrs0_sl = convctl_mpu1__mrs0_sl_i;
assign mpu1_mrs0_sr = convctl_mpu1__mrs0_sr_i;
assign mpu1_mrs0_index = convctl_mpu1__mrs0_index_i;
assign mpu1_mrs0_addr = convctl_mpu1__mrs0_addr_i;
assign mpu_mrs1_index = convctl_mpu__mrs1_index_i;
assign mpu_mrs1_addr = convctl_mpu__mrs1_addr_i;
assign mpu_vrd_index = convctl_mpu__vrd_index_i;
assign mpu_mac_len = convctl_mpu__mac_len_i;

always @(*) begin
    if(mpu_code == MPU_CODE_MMAC) begin
        dec_st = ST_MMAC;
    end else if(mpu_code == MPU_CODE_MMUL) begin
        dec_st = ST_MMUL;
    end else begin
        dec_st = ST_IDLE;
    end
end

always @(posedge clk_i) begin
    if(rst_i) begin
        cur_st <= ST_IDLE;
        mac_cnt <= 7'h0;
    end else begin
        case(cur_st)
            ST_IDLE: begin
                cur_st <= dec_st;
                mac_cnt <= 7'h0;
                // if(dec_st == ST_MMAC || dec_st == ST_MMUL) begin
                mpu0_mra_index_reg <= mpu0_mrs0_index[MRA_IND_WTH-1 : 0];
                mpu0_mra_addr_reg <= mpu0_mrs0_addr;
                mpu0_mra_sl_reg <= mpu0_mrs0_sl;
                mpu0_mra_sr_reg <= mpu0_mrs0_sr;
                mpu0_mra_frcz_reg <= (&mpu0_mrs0_index);
                mpu1_mra_index_reg <= mpu1_mrs0_index[MRA_IND_WTH-1 : 0];
                mpu1_mra_addr_reg <= mpu1_mrs0_addr;
                mpu1_mra_sl_reg <= mpu1_mrs0_sl;
                mpu1_mra_sr_reg <= mpu1_mrs0_sr;
                mpu1_mra_frcz_reg <= (&mpu1_mrs0_index);
                mpu_mrb_index_reg <= mpu_mrs1_index[MRX_IND_WTH-1 : 0] - 'h8;
                mpu_mrb_addr_reg <= mpu_mrs1_addr;
                //end
            end
            ST_MMAC: begin
                mac_cnt <= mac_cnt + 1'b1;
                mpu0_mra_addr_reg <= mpu0_mra_addr_reg + 1'b1;
                mpu1_mra_addr_reg <= mpu1_mra_addr_reg + 1'b1;
                mpu_mrb_addr_reg <= mpu_mrb_addr_reg + 1'b1;
                if(mac_cnt == mpu_mac_len-1) begin
                    cur_st <= dec_st;
                    mac_cnt <= 7'h0;
                    mpu0_mra_index_reg <= mpu0_mrs0_index[MRA_IND_WTH-1 : 0];
                    mpu0_mra_addr_reg <= mpu0_mrs0_addr;
                    mpu0_mra_sl_reg <= mpu0_mrs0_sl;
                    mpu0_mra_sr_reg <= mpu0_mrs0_sr;
                    mpu0_mra_frcz_reg <= (&mpu0_mrs0_index);
                    mpu1_mra_index_reg <= mpu1_mrs0_index[MRA_IND_WTH-1 : 0];
                    mpu1_mra_addr_reg <= mpu1_mrs0_addr;
                    mpu1_mra_sl_reg <= mpu1_mrs0_sl;
                    mpu1_mra_sr_reg <= mpu1_mrs0_sr;
                    mpu1_mra_frcz_reg <= (&mpu1_mrs0_index);
                    mpu_mrb_index_reg <= mpu_mrs1_index[MRX_IND_WTH-1 : 0] - 'h8;
                    mpu_mrb_addr_reg <= mpu_mrs1_addr;
                end
            end
            ST_MMUL: begin
                cur_st <= dec_st;
                mac_cnt <= 7'h0;
                mpu0_mra_index_reg <= mpu0_mrs0_index[MRA_IND_WTH-1 : 0];
                mpu0_mra_addr_reg <= mpu0_mrs0_addr;
                mpu0_mra_sl_reg <= mpu0_mrs0_sl;
                mpu0_mra_sr_reg <= mpu0_mrs0_sr;
                mpu0_mra_frcz_reg <= (&mpu0_mrs0_index);
                mpu1_mra_index_reg <= mpu1_mrs0_index[MRA_IND_WTH-1 : 0];
                mpu1_mra_addr_reg <= mpu1_mrs0_addr;
                mpu1_mra_sl_reg <= mpu1_mrs0_sl;
                mpu1_mra_sr_reg <= mpu1_mrs0_sr;
                mpu1_mra_frcz_reg <= (&mpu1_mrs0_index);
                mpu_mrb_index_reg <= mpu_mrs1_index[MRX_IND_WTH-1 : 0] - 'h8;
                mpu_mrb_addr_reg <= mpu_mrs1_addr;
            end
        endcase
    end
end
assign mr_re = (cur_st == ST_MMAC) || (cur_st == ST_MMUL);
assign vr_re = (cur_st == ST_MMAC) && (mac_cnt == 7'h0);
assign vr_we = (cur_st == ST_MMAC) && (mac_cnt == mpu_mac_len-1) || (cur_st == ST_MMUL);

always @(posedge clk_i) begin
    vrd_index_r <= vrd_index;
end
assign vrd_index = ((cur_st == ST_MMAC) && (mac_cnt != 7'h0)) ? vrd_index_r : mpu_vrd_index;

assign mpu0_mra__rindex_o = mpu0_mra_index_reg;
assign mpu0_mra__raddr_o = mpu0_mra_addr_reg;
assign mpu0_mra__sl_o = mpu0_mra_sl_reg;
assign mpu0_mra__sr_o = mpu0_mra_sr_reg;
assign mpu0_mra__frcz_o = mpu0_mra_frcz_reg;
assign mpu1_mra__rindex_o = mpu1_mra_index_reg;
assign mpu1_mra__raddr_o = mpu1_mra_addr_reg;
assign mpu1_mra__sl_o = mpu1_mra_sl_reg;
assign mpu1_mra__sr_o = mpu1_mra_sr_reg;
assign mpu1_mra__frcz_o = mpu1_mra_frcz_reg;
assign mpu_mrb__rindex_o = mpu_mrb_index_reg;
assign mpu_mrb__raddr_o = mpu_mrb_addr_reg;
assign mpu_mra__re_o = mr_re;
assign mpu_mrb__re_o = mr_re;

always @(posedge clk_i) begin
    mpu_type_dlychain <= {mpu_type_dlychain[RMR_DLY-1 : 0], mpu_type};
    mpu_code_dlychain <= {mpu_code_dlychain[ACC_DLY*2-1 : 0], mpu_code};
end
assign mpu_mrb__type_o = mpu_type_dlychain[0];
assign mpu_op_type_o = mpu_type_dlychain[RMR_DLY];
assign mpu_op_extacc_act_o = mpu_code_dlychain[(ACC_DLY-1)*2 + EN_MAC] & ~mpu_code_dlychain[ACC_DLY*2 + EN_ACT];
assign mpu_op_bypass_act_o = mpu_code_dlychain[(ACC_DLY-1)*2 + EN_MAC] & mpu_code_dlychain[ACC_DLY*2 + EN_ACT];

always @(posedge clk_i) begin
    vrd_index_dlychain <= {vrd_index_dlychain[WVR_DLY*VR_IND_WTH-1 : 0], vrd_index};
    vr_re_dlychain <= {vr_re_dlychain[RVR_DLY-1 : 0], vr_re};
    vr_we_dlychain <= {vr_we_dlychain[WVR_DLY-1 : 0], vr_we};
end
assign mpu_vr__rindex_o = vrd_index_dlychain[RVR_DLY*VR_IND_WTH +: VR_IND_WTH];
assign mpu_vr__re_o = vr_re_dlychain[RVR_DLY];
assign mpu_vr__windex_o = vrd_index_dlychain[WVR_DLY*VR_IND_WTH +: VR_IND_WTH];
assign mpu_vr__we_o = vr_we_dlychain[WVR_DLY];

//======================================================================================================================
// just for simulation
//======================================================================================================================
// synthesis translate_off

// synthesis translate_on

//======================================================================================================================
// probe signals
//======================================================================================================================

endmodule   


