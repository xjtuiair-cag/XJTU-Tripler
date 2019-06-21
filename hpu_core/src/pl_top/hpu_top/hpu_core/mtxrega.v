// +FHDR------------------------------------------------------------------------
// XJTU IAIR Corporation All Rights Reserved
// -----------------------------------------------------------------------------
// FILE NAME  : mtxrega.v
// DEPARTMENT : CAG of IAIR
// AUTHOR     : XXXX
// AUTHOR'S EMAIL :XXXX@mail.xjtu.edu.cn
// -----------------------------------------------------------------------------
// Ver 1.0  2019--01--01 initial version.
// -----------------------------------------------------------------------------
// KEYWORDS   : mtxreg, memory,
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

module mtxrega #(
    parameter MRA_IND_WTH = 3,
    parameter MRA_ADDR_WTH = 9,
    parameter MR_PROC_WTH = 8,
    parameter MR_PROC_H_PARAL = 8,
    parameter MR_PROC_V_PARAL = 8,
    parameter MTX_DATA_WTH = MR_PROC_WTH * MR_PROC_V_PARAL,
    parameter MR_DATA_WTH = MTX_DATA_WTH * MR_PROC_H_PARAL,
    parameter VMR_PROC_WTH = 64,
    parameter VMR_DATA_WTH = MR_PROC_H_PARAL * MR_PROC_V_PARAL * VMR_PROC_WTH,
    parameter MR_DSTROB_H_WTH = 8,
    parameter MR_DSTROB_V_WTH = 8
) (
    // clock & reset
    input                                   clk_i,
    input                                   rst_i,

    // from mpu_ctrl module
    input [MRA_IND_WTH-1 : 0]               mpu_mra__rindex_i,
    input [MRA_ADDR_WTH-1 : 0]              mpu_mra__raddr_i,
    input                                   mpu_mra__sl_i,
    input                                   mpu_mra__sr_i,
    input                                   mpu_mra__frcz_i,
    input                                   mpu_mra__re_i,

    // to mpu module
    output[MR_DATA_WTH-1 : 0]               mpu_mra__rdata_o,
    output                                  mpu_mra__rdata_act_o,

    // from vpu_ctrl module
      input [MRA_IND_WTH-1 : 0]               vpu_mra__windex_i,
      input [MRA_ADDR_WTH-1 : 0]              vpu_mra__waddr_i,
      input                                   vpu_mra__we_i,

    // from vpu module
      input [MR_DATA_WTH-1 : 0]               vpu_mra__wdata_i,
    input [MR_DSTROB_H_WTH-1 : 0]           vpu_mra__wdata_strob_h_i,
    input [MR_DSTROB_V_WTH-1 : 0]           vpu_mra__wdata_strob_v_i,
    input                                   vpu_mra__wdata_act_i,

    // from vputy_ctrl module
    input [MRA_IND_WTH-1 : 0]               vputy_mra__rindex_i,
    input [MRA_ADDR_WTH-1 : 0]              vputy_mra__raddr_i,
    input                                   vputy_mra__sl_i,
    input                                   vputy_mra__sr_i,
    input                                   vputy_mra__frcz_i,
    input                                   vputy_mra__re_i,
    input [MRA_IND_WTH-1 : 0]               vputy_mra__windex_i,
   input [MRA_ADDR_WTH-1 : 0]              vputy_mra__waddr_i,
    input                                   vputy_mra__we_i,

    // to vputy module
    output[MR_DATA_WTH-1 : 0]               vputy_mra__rdata_o,
    output                                  vputy_mra__rdata_act_o,

    // from vputy module
    input [MR_DATA_WTH-1 : 0]               vputy_mra__wdata_i,
    input [MR_DSTROB_H_WTH-1 : 0]           vputy_mra__wdata_strob_h_i,
    input [MR_DSTROB_V_WTH-1 : 0]           vputy_mra__wdata_strob_v_i,
    input                                   vputy_mra__wdata_act_i,

    // from save_mtxreg_ctrl module
    input [MRA_IND_WTH-1 : 0]               svmr_mra__rindex_i,
     input [MRA_ADDR_WTH-1 : 0]              svmr_mra__raddr_i,
     input                                   svmr_mra__re_i,

    // to ddr_intf module
     output[MR_DATA_WTH-1 : 0]               svmr_mra__rdata_o,
    output                                  svmr_mra__rdata_act_o,

    // from load_mtxreg_ctrl module
    input [MRA_IND_WTH-1 : 0]               ldmr_mra__windex_i,
    input [MRA_ADDR_WTH-1 : 0]              ldmr_mra__waddr_i,
    input                                   ldmr_mra__we_i,

    // from ddr_intf module
    input [MR_DATA_WTH-1 : 0]               ldmr_mra__wdata_i,
    input                                   ldmr_mra__wdata_act_i
);

//======================================================================================================================
// Wire & Reg declaration
//======================================================================================================================
localparam MR_PROC_N_PARAL = 8;

localparam TOT_DLY = 3;
localparam MRA_DLY = 2;

wire  [MR_PROC_N_PARAL-1 : 0]           vpu_mra_windex_onehot;
wire  [MR_PROC_N_PARAL-1 : 0]           vputy_mra_windex_onehot;
wire  [MR_PROC_N_PARAL-1 : 0]           ldmr_mra_windex_onehot;

wire  [MR_PROC_N_PARAL-1 : 0]           mpu_mra_rindex_onehot;
wire  [MR_PROC_N_PARAL-1 : 0]           vputy_mra_rindex_onehot;
wire  [MR_PROC_N_PARAL-1 : 0]           svmr_mra_rindex_onehot;

wire                                    mra_we[0 : MR_PROC_N_PARAL-1];
wire  [MRA_ADDR_WTH-1 : 0]              mra_waddr[0 : MR_PROC_N_PARAL-1];
wire  [MR_DATA_WTH-1 : 0]               mra_wdata[0 : MR_PROC_N_PARAL-1];
wire  [MR_DSTROB_H_WTH-1 : 0]           mra_wdata_strob_h[0 : MR_PROC_N_PARAL-1];
wire  [MR_DSTROB_V_WTH-1 : 0]           mra_wdata_strob_v[0 : MR_PROC_N_PARAL-1];
wire                                    mra_re[0 : MR_PROC_N_PARAL-1];
wire  [MRA_ADDR_WTH-1 : 0]              mra_raddr[0 : MR_PROC_N_PARAL-1];

reg                                     mra_we_r[0 : MR_PROC_N_PARAL-1];
reg   [MRA_ADDR_WTH-1 : 0]              mra_waddr_r[0 : MR_PROC_N_PARAL-1];
reg   [MR_DSTROB_H_WTH-1 : 0]           mra_wdata_strob_h_r[0 : MR_PROC_N_PARAL-1];
reg   [MR_DSTROB_V_WTH-1 : 0]           mra_wdata_strob_v_r[0 : MR_PROC_N_PARAL-1];
reg   [MR_DATA_WTH-1 : 0]               mra_wdata_r[0 : MR_PROC_N_PARAL-1];
reg                                     mra_re_r[0 : MR_PROC_N_PARAL-1];
reg   [MRA_ADDR_WTH-1 : 0]              mra_raddr_r[0 : MR_PROC_N_PARAL-1];

wire  [MR_DATA_WTH-1 : 0]               mra_rdata[0 : MR_PROC_N_PARAL-1];

reg   [MRA_IND_WTH*(MRA_DLY+1)-1 : 0]   mpu_mra_rindex_dlychain;
reg   [MRA_DLY : 0]                     mpu_mra_sl_dlychain;
reg   [MRA_DLY : 0]                     mpu_mra_sr_dlychain;
reg   [MRA_DLY : 0]                     mpu_mra_frcz_dlychain;
reg   [MRA_IND_WTH*(MRA_DLY+1)-1 : 0]   vputy_mra_rindex_dlychain;
reg   [MRA_DLY : 0]                     vputy_mra_sl_dlychain;
reg   [MRA_DLY : 0]                     vputy_mra_sr_dlychain;
reg   [MRA_DLY : 0]                     vputy_mra_frcz_dlychain;
reg   [MRA_IND_WTH*(MRA_DLY+1)-1 : 0]   svmr_mra_rindex_dlychain;

reg   [MR_DATA_WTH-1 : 0]               mpu_mra_rdata;
reg   [MR_DATA_WTH-1 : 0]               vputy_mra_rdata;
reg   [MR_DATA_WTH-1 : 0]               svmr_mra_rdata;

reg   [VMR_DATA_WTH-1 : 0]              vmode_rdata;

reg   [TOT_DLY : 0]                     mpu_mra_re_dlychain;
reg   [TOT_DLY : 0]                     vputy_mra_re_dlychain;
reg   [TOT_DLY : 0]                     svmr_mra_re_dlychain;

genvar gi;
integer i, j;

//======================================================================================================================
// Instance
//======================================================================================================================

dec_bin_to_onehot #(3, 8) vpu_mra_windex_inst (vpu_mra__windex_i, vpu_mra_windex_onehot);
dec_bin_to_onehot #(3, 8) vputy_mra_windex_inst (vputy_mra__windex_i, vputy_mra_windex_onehot);
dec_bin_to_onehot #(3, 8) ldmr_mra_windex_inst (ldmr_mra__windex_i, ldmr_mra_windex_onehot);

dec_bin_to_onehot #(3, 8) mpu_mra_rindex_inst (mpu_mra__rindex_i, mpu_mra_rindex_onehot);
dec_bin_to_onehot #(3, 8) vputy_mra_rindex_inst (vputy_mra__rindex_i, vputy_mra_rindex_onehot);
dec_bin_to_onehot #(3, 8) svmr_mra_rindex_inst (svmr_mra__rindex_i, svmr_mra_rindex_onehot);

generate
    for (gi = 0; gi < MR_PROC_N_PARAL; gi = gi+1) begin : mra
        assign mra_we[gi] = (vpu_mra__we_i & vpu_mra_windex_onehot[gi])
                          | (vputy_mra__we_i & vputy_mra_windex_onehot[gi])
                          | (ldmr_mra__we_i & ldmr_mra_windex_onehot[gi]);
        assign mra_waddr[gi] = (vpu_mra_windex_onehot[gi] & vpu_mra__we_i) ? vpu_mra__waddr_i
                             : (vputy_mra_windex_onehot[gi] & vputy_mra__we_i) ? vputy_mra__waddr_i
                             : ldmr_mra__waddr_i;
        assign mra_wdata[gi] = (vpu_mra_windex_onehot[gi] & vpu_mra__we_i) ? vpu_mra__wdata_i
                             : (vputy_mra_windex_onehot[gi] & vputy_mra__we_i) ? vputy_mra__wdata_i
                             : ldmr_mra__wdata_i;
        assign mra_wdata_strob_h[gi] = (vpu_mra_windex_onehot[gi] & vpu_mra__we_i) ? vpu_mra__wdata_strob_h_i
                                     : (vputy_mra_windex_onehot[gi] & vputy_mra__we_i) ? vputy_mra__wdata_strob_h_i
                                     : 8'hff;
        assign mra_wdata_strob_v[gi] = (vpu_mra_windex_onehot[gi] & vpu_mra__we_i) ? vpu_mra__wdata_strob_v_i
                                     : (vputy_mra_windex_onehot[gi] & vputy_mra__we_i) ? vputy_mra__wdata_strob_v_i
                                     : 8'hff;
        assign mra_re[gi] = (mpu_mra__re_i & mpu_mra_rindex_onehot[gi] & ~mpu_mra__frcz_i)
                          | (vputy_mra__re_i & vputy_mra_rindex_onehot[gi] & ~vputy_mra__frcz_i)
                          | (svmr_mra__re_i & svmr_mra_rindex_onehot[gi]);
        assign mra_raddr[gi] = (mpu_mra_rindex_onehot[gi] & mpu_mra__re_i & ~mpu_mra__frcz_i) ? mpu_mra__raddr_i
                             : (vputy_mra_rindex_onehot[gi] & vputy_mra__re_i & ~vputy_mra__frcz_i) ? vputy_mra__raddr_i
                             : svmr_mra__raddr_i;

        always @(posedge clk_i) begin
            mra_we_r[gi] <= mra_we[gi];
            mra_waddr_r[gi] <= mra_waddr[gi];
            mra_wdata_r[gi] <= mra_wdata[gi];
            mra_wdata_strob_h_r[gi] <= mra_wdata_strob_h[gi];
            mra_wdata_strob_v_r[gi] <= mra_wdata_strob_v[gi];
            mra_re_r[gi] <= mra_re[gi];
            mra_raddr_r[gi] <= mra_raddr[gi];
        end

        sdp_w512x64_r512x64_wrap mtxrega[MR_PROC_H_PARAL-1 : 0] (
            .wr_clk_i                       ({MR_PROC_H_PARAL{clk_i}}),
            .we_i                           ({MR_PROC_H_PARAL{mra_we_r[gi]}} & mra_wdata_strob_h_r[gi]),
            .waddr_i                        ({MR_PROC_H_PARAL{mra_waddr_r[gi]}}),
            .wdata_i                        (mra_wdata_r[gi]),
            .wdata_strob_i                  ({MR_PROC_H_PARAL{mra_wdata_strob_v_r[gi]}}),
            .rd_clk_i                       ({MR_PROC_H_PARAL{clk_i}}),
            .re_i                           ({MR_PROC_H_PARAL{mra_re_r[gi]}}),
            .raddr_i                        ({MR_PROC_H_PARAL{mra_raddr_r[gi]}}),
            .rdata_o                        (mra_rdata[gi])
        );
    end
endgenerate

always @(posedge clk_i) begin
    mpu_mra_rindex_dlychain <= {mpu_mra_rindex_dlychain[MRA_IND_WTH*MRA_DLY-1 : 0], mpu_mra__rindex_i};
    mpu_mra_sl_dlychain <= {mpu_mra_sl_dlychain[MRA_DLY-1 : 0], mpu_mra__sl_i};
    mpu_mra_sr_dlychain <= {mpu_mra_sr_dlychain[MRA_DLY-1 : 0], mpu_mra__sr_i};
    mpu_mra_frcz_dlychain <= {mpu_mra_frcz_dlychain[MRA_DLY-1 : 0], mpu_mra__frcz_i};
    vputy_mra_rindex_dlychain <= {vputy_mra_rindex_dlychain[MRA_IND_WTH*MRA_DLY-1 : 0], vputy_mra__rindex_i};
    vputy_mra_sl_dlychain <= {vputy_mra_sl_dlychain[MRA_DLY-1 : 0], vputy_mra__sl_i};
    vputy_mra_sr_dlychain <= {vputy_mra_sr_dlychain[MRA_DLY-1 : 0], vputy_mra__sr_i};
    vputy_mra_frcz_dlychain <= {vputy_mra_frcz_dlychain[MRA_DLY-1 : 0], vputy_mra__frcz_i};
    svmr_mra_rindex_dlychain <= {svmr_mra_rindex_dlychain[MRA_IND_WTH*MRA_DLY-1 : 0], svmr_mra__rindex_i};
end

always @(posedge clk_i) begin
    mpu_mra_rdata <= mpu_mra_frcz_dlychain[2] ? 'h0
                   : mpu_mra_sl_dlychain[2]? {{MTX_DATA_WTH{1'b0}}, mra_rdata[mpu_mra_rindex_dlychain[MRA_IND_WTH*MRA_DLY +: MRA_IND_WTH]][MTX_DATA_WTH +: (MR_PROC_H_PARAL-1) * MTX_DATA_WTH]}
                   : mpu_mra_sr_dlychain[2]? {mra_rdata[mpu_mra_rindex_dlychain[MRA_IND_WTH*MRA_DLY +: MRA_IND_WTH]][0 +: (MR_PROC_H_PARAL-1) * MTX_DATA_WTH], {MTX_DATA_WTH{1'b0}}}
                   : mra_rdata[mpu_mra_rindex_dlychain[MRA_IND_WTH*MRA_DLY +: MRA_IND_WTH]];
    vputy_mra_rdata <= vputy_mra_frcz_dlychain[2] ? 'h0
                   : vputy_mra_sl_dlychain[2]? {{MTX_DATA_WTH{1'b0}}, mra_rdata[vputy_mra_rindex_dlychain[MRA_IND_WTH*MRA_DLY +: MRA_IND_WTH]][MTX_DATA_WTH +: (MR_PROC_H_PARAL-1) * MTX_DATA_WTH]}
                   : vputy_mra_sr_dlychain[2]? {mra_rdata[vputy_mra_rindex_dlychain[MRA_IND_WTH*MRA_DLY +: MRA_IND_WTH]][0 +: (MR_PROC_H_PARAL-1) * MTX_DATA_WTH], {MTX_DATA_WTH{1'b0}}}
                   : mra_rdata[vputy_mra_rindex_dlychain[MRA_IND_WTH*MRA_DLY +: MRA_IND_WTH]];
    svmr_mra_rdata <= mra_rdata[svmr_mra_rindex_dlychain[MRA_IND_WTH*MRA_DLY +: MRA_IND_WTH]];
end
assign mpu_mra__rdata_o = mpu_mra_rdata;
assign vputy_mra__rdata_o = vputy_mra_rdata;
assign svmr_mra__rdata_o = svmr_mra_rdata;

always @(posedge clk_i) begin
    if(rst_i) begin
        mpu_mra_re_dlychain <= {(TOT_DLY+1){1'b0}};
        vputy_mra_re_dlychain <= {(TOT_DLY+1){1'b0}};
        svmr_mra_re_dlychain <= {(TOT_DLY+1){1'b0}};
    end else begin
        mpu_mra_re_dlychain <= {mpu_mra_re_dlychain[TOT_DLY-1 : 0], mpu_mra__re_i};
        vputy_mra_re_dlychain <= {vputy_mra_re_dlychain[TOT_DLY-1 : 0], vputy_mra__re_i};
        svmr_mra_re_dlychain <= {svmr_mra_re_dlychain[TOT_DLY-1 : 0], svmr_mra__re_i};
    end
end
assign mpu_mra__rdata_act_o = mpu_mra_re_dlychain[TOT_DLY];
assign vputy_mra__rdata_act_o = vputy_mra_re_dlychain[TOT_DLY];
assign svmr_mra__rdata_act_o = svmr_mra_re_dlychain[TOT_DLY];

//======================================================================================================================
// just for simulation
//======================================================================================================================
// synthesis translate_off

// synthesis translate_on

//======================================================================================================================
// probe signals
//======================================================================================================================

endmodule   
