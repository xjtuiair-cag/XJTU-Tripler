// +FHDR------------------------------------------------------------------------
// XJTU IAIR Corporation All Rights Reserved
// -----------------------------------------------------------------------------
// FILE NAME  : vecreg.v
// DEPARTMENT : CAG of IAIR
// AUTHOR     : XXXX
// AUTHOR'S EMAIL :XXXX@mail.xjtu.edu.cn
// -----------------------------------------------------------------------------
// Ver 1.0  2019--01--01 initial version.
// -----------------------------------------------------------------------------
// KEYWORDS   : vecreg, memory,
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

module vecreg #(
    parameter VR_PROC_WTH = 32,
    parameter VR_PROC_PARAL = 64,
    parameter VR_IND_WTH = 4,
    parameter VR_DATA_WTH = VR_PROC_PARAL * VR_PROC_WTH,
    parameter VPR_IND_WTH = 3,
    parameter VPR_DATA_WTH = VR_PROC_PARAL
) (
    // clock & reset
    input                                   clk_i,
    input                                   rst_i,

    // from mpu_ctrl module
    input [VR_IND_WTH-1 : 0]                mpu_vr__windex_i,
    input                                   mpu_vr__we_i,
    input [VR_IND_WTH-1 : 0]                mpu_vr__rindex_i,
    input                                   mpu_vr__re_i,

    // from mpu module
    input [VR_DATA_WTH-1 : 0]               mpu_vr__wdata_i,
    input                                   mpu_vr__wdata_act_i,
    // to mpu module
    output[VR_DATA_WTH-1 : 0]               mpu_vr__rdata_o,
    output                                  mpu_vr__rdata_act_o,

    // from vpu_ctrl module
    input [VR_IND_WTH-1 : 0]                vpu_vr__rd_windex_i,
    input                                   vpu_vr__rd_we_i,
    input [VR_IND_WTH-1 : 0]                vpu_vr__rs0_rindex_i,
    input [VR_IND_WTH-1 : 0]                vpu_vr__rs1_rindex_i,
    input                                   vpu_vr__rs_re_i,
    input [VPR_IND_WTH-1 : 0]               vpu_vr__rpd_windex_i,
    input                                   vpu_vr__rpd_we_i,
    input [VPR_IND_WTH-1 : 0]               vpu_vr__rps0_rindex_i,
    input [VPR_IND_WTH-1 : 0]               vpu_vr__rps1_rindex_i,
    input                                   vpu_vr__rps_re_i,

    // from vpu module
    input [VR_DATA_WTH-1 : 0]               vpu_vr__rd_wdata_i,
    input                                   vpu_vr__rd_wdata_act_i,
    input [VPR_DATA_WTH-1 : 0]              vpu_vr__rpd_wdata_i,
    input                                   vpu_vr__rpd_wdata_act_i,

    // to vpu module
    output[VR_DATA_WTH-1 : 0]               vpu_vr__rs0_rdata_o,
    output[VR_DATA_WTH-1 : 0]               vpu_vr__rs1_rdata_o,
    output                                  vpu_vr__rs_rdata_act_o,
    output[VPR_DATA_WTH-1 : 0]              vpu_vr__rps0_rdata_o,
    output[VPR_DATA_WTH-1 : 0]              vpu_vr__rps1_rdata_o,
    output                                  vpu_vr__rps_rdata_act_o
);

//======================================================================================================================
// Wire & Reg declaration
//======================================================================================================================
localparam VR_IND_SIZE = 1<<VR_IND_WTH;
localparam VPR_IND_SIZE = 1<<VPR_IND_WTH;

`define REDUCED_IMPLEMENTATION

wire  [VR_IND_SIZE-1 : 0]           mpu_windex_onehot;
wire  [VR_IND_SIZE-1 : 0]           mpu_rindex_onehot;
wire  [VR_IND_SIZE-1 : 0]           vpu_rd_windex_onehot;
wire  [VR_IND_SIZE-1 : 0]           vpu_rs0_rindex_onehot;
wire  [VR_IND_SIZE-1 : 0]           vpu_rs1_rindex_onehot;

`ifdef REDUCED_IMPLEMENTATION
reg   [VR_DATA_WTH-1 : 0]           vecreg[0 : VR_IND_SIZE-1];

`elsif SIMPLE_IMPLEMENTATION
reg   [VR_DATA_WTH-1 : 0]           vecreg[0 : VR_IND_SIZE-1];
reg   [VR_DATA_WTH-1 : 0]           mpu_vr_rdata;
reg   [VR_DATA_WTH-1 : 0]           vpu_rs0_rdata;
reg   [VR_DATA_WTH-1 : 0]           vpu_rs1_rdata;

reg   [VPR_DATA_WTH-1 : 0]          vecpredreg[0 : VPR_IND_SIZE-1];
reg   [VPR_DATA_WTH-1 : 0]          vpu_rps0_rdata;
reg   [VPR_DATA_WTH-1 : 0]          vpu_rps1_rdata;

`else
reg   [VR_IND_SIZE*VR_PROC_WTH-1 : 0]   vecreg[0 : VR_PROC_PARAL-1];
reg   [VR_IND_SIZE*VR_PROC_WTH-1 : 0]   mpu_vr_rdata;
reg   [VR_IND_SIZE*VR_PROC_WTH-1 : 0]   vpu_rs0_rdata;
reg   [VR_IND_SIZE*VR_PROC_WTH-1 : 0]   vpu_rs1_rdata;

reg   [VR_IND_SIZE-1 : 0]           vecpredreg[0 : VR_PROC_PARAL-1];
reg   [VR_IND_SIZE-1 : 0]           vpu_rps0_rdata;
reg   [VR_IND_SIZE-1 : 0]           vpu_rps1_rdata;
`endif

reg                                 mpu_vr_rdata_act;
reg                                 vpu_rs_rdata_act;
reg                                 vpu_rps_rdata_act;

integer  i;

//======================================================================================================================
// Instance
//======================================================================================================================

dec_bin_to_onehot #(VR_IND_WTH, VR_IND_SIZE) mpu_windex_inst (mpu_vr__windex_i, mpu_windex_onehot);
dec_bin_to_onehot #(VR_IND_WTH, VR_IND_SIZE) mpu_rindex_inst (mpu_vr__rindex_i, mpu_rindex_onehot);
dec_bin_to_onehot #(VR_IND_WTH, VR_IND_SIZE) vpu_rd_windex_inst (vpu_vr__rd_windex_i, vpu_rd_windex_onehot);
dec_bin_to_onehot #(VR_IND_WTH, VR_IND_SIZE) vpu_rs0_rindex_inst (vpu_vr__rs0_rindex_i, vpu_rs0_rindex_onehot);
dec_bin_to_onehot #(VR_IND_WTH, VR_IND_SIZE) vpu_rs1_rindex_inst (vpu_vr__rs1_rindex_i, vpu_rs1_rindex_onehot);

// In register version, the vector regsiter can be reduced to just 1 group
// DFF.
`ifdef REDUCED_IMPLEMENTATION

always @ (posedge clk_i) begin
    if(rst_i) begin
        vecreg[0] <= {VR_DATA_WTH{1'b0}};
    end else begin
        if(mpu_vr__we_i) begin
            vecreg[0] <= mpu_vr__wdata_i;
        end else if(vpu_vr__rd_we_i) begin
            vecreg[0] <= vpu_vr__rd_wdata_i;
        end
    end
end
assign mpu_vr__rdata_o = vecreg[0];
assign vpu_vr__rs0_rdata_o = vecreg[0];
assign vpu_vr__rs1_rdata_o = vecreg[0];

assign vpu_vr__rps0_rdata_o = 'h0;
assign vpu_vr__rps1_rdata_o = 'h0;

`elsif SIMPLE_IMPLEMENTATION
always @ (posedge clk_i) begin
    if(rst_i) begin
        for(i = 0; i < VR_IND_SIZE; i = i+1) begin
            vecreg[i] <= {VR_DATA_WTH{1'b0}};
        end
    end else begin
        for(i = 0; i < VR_IND_SIZE; i = i+1) begin
            if(mpu_windex_onehot[i] && mpu_vr__we_i) begin
                vecreg[i] <= mpu_vr__wdata_i;
            end else if(vpu_rd_windex_onehot[i] & vpu_vr__rd_we_i) begin
                vecreg[i] <= vpu_vr__rd_wdata_i;
            end
        end
    end
end
always @ (posedge clk_i) begin
    if(rst_i) begin
        mpu_vr_rdata <= {VR_DATA_WTH{1'b0}};
        vpu_rs0_rdata <= {VR_DATA_WTH{1'b0}};
        vpu_rs1_rdata <= {VR_DATA_WTH{1'b0}};
    end else begin
        mpu_vr_rdata <= vecreg[mpu_vr__rindex_i];
        vpu_rs0_rdata <= vecreg[vpu_vr__rs0_rindex_i];
        vpu_rs1_rdata <= vecreg[vpu_vr__rs1_rindex_i];
    end
end
assign mpu_vr__rdata_o = mpu_vr_rdata;
assign vpu_vr__rs0_rdata_o = vpu_rs0_rdata;
assign vpu_vr__rs1_rdata_o = vpu_rs1_rdata;

always @ (posedge clk_i) begin
    if(rst_i) begin
        for(i = 0; i < VPR_IND_SIZE; i = i+1) begin
            vecpredreg[i] <= {VPR_DATA_WTH{1'b0}};
        end
    end else begin
        for(i = 0; i < VPR_IND_SIZE; i = i+1) begin
            if(vpu_rd_windex_onehot[i] && vpu_vr__rd_we_i) begin
                vecpredreg[i] <= vpu_vr__rpd_wdata_i;
            end
        end
    end
end
always @ (posedge clk_i) begin
    if(rst_i) begin
        vpu_rps0_rdata <= {VPR_DATA_WTH{1'b0}};
        vpu_rps1_rdata <= {VPR_DATA_WTH{1'b0}};
    end else begin
        vpu_rps0_rdata <= vecreg[vpu_vr__rps0_rindex_i];
        vpu_rps1_rdata <= vecreg[vpu_vr__rps1_rindex_i];
    end
end
assign vpu_vr__rps0_rdata_o = vpu_rps0_rdata;
assign vpu_vr__rps1_rdata_o = vpu_rps1_rdata;

`else
generate
    for(gi = 0; gi < VR_PROC_PARAL; gi = gi+1) begin : vr
        always @ (posedge clk_i) begin
            if(rst_i) begin
                for(i = 0; i < VR_IND_SIZE; i = i+1) begin
                    vecreg[gi][VR_PROC_WTH*i +: VR_PROC_WTH] <= {VR_PROC_WTH*VR_IND_SIZE{1'b0}};
                end
            end else begin
                for(i = 0; i < VR_IND_SIZE; i = i+1) begin
                    if(mpu_vr_index_onehot[i] && mpu_vr__we_i) begin
                        vecreg[gi][VR_PROC_WTH*i +: VR_PROC_WTH] <= mpu_vr__wdata_i[VR_PROC_WTH*i +: VR_PROC_WTH];
                    end else if(vpu_rd_windex_onehot[i] && vpu_vr__rd_we_i) begin
                        vecreg[gi][VR_PROC_WTH*i +: VR_PROC_WTH] <= vpu_vr__rd_wdata_i[VR_PROC_WTH*i +: VR_PROC_WTH];
                    end
                end
            end
        end
        always @ (posedge clk_i) begin
            mpu_vr_rdata[VR_PROC_WTH*gi +: VR_PROC_WTH] <= vecreg[gi][VR_PROC_WTH*mpu_vr__rindex_i +: VR_PROC_WTH];
            vpu_rs0_rdata[VR_PROC_WTH*gi +: VR_PROC_WTH] <= vecreg[gi][VR_PROC_WTH*vpu_vr__rs0_rindex_i +: VR_PROC_WTH];
            vpu_rs1_rdata[VR_PROC_WTH*gi +: VR_PROC_WTH] <= vecreg[gi][VR_PROC_WTH*vpu_vr__rs1_rindex_i +: VR_PROC_WTH];
        end
        assign mpu_vr__rdata_o = mpu_vr_rdata;
        assign vpu_vr__rs0_rdata_o = vpu_rs0_rdata;
        assign vpu_vr__rs1_rdata_o = vpu_rs1_rdata;
    end

    for(gi = 0; gi < VPR_PROC_PARAL; gi = gi+1) begin : vpr
        always @ (posedge clk_i) begin
            for(i = 0; i < VPR_IND_SIZE; i = i+1) begin
                if(vpu_rpd_windex_onehot[i] && vpu_vr__rpd_we_i) begin
                    vecpredreg[gi][VR_PROC_WTH*i +: VR_PROC_WTH] <= vpu_vr__rpd_wdata_i[VR_PROC_WTH*i +: VR_PROC_WTH];
                end
            end
        end
        always @ (posedge clk_i) begin
            vpu_rps0_rdata[VPR_PROC_WTH*gi +: VPR_PROC_WTH] <= vecpredreg[gi][VPR_PROC_WTH*vpu_vr__rps0_rindex_i +: VPR_PROC_WTH];
            vpu_rps1_rdata[VPR_PROC_WTH*gi +: VPR_PROC_WTH] <= vecpredreg[gi][VPR_PROC_WTH*vpu_vr__rps1_rindex_i +: VPR_PROC_WTH];
        end
        assign vpu_vr__rps0_rdata_o = vpu_rps0_rdata;
        assign vpu_vr__rps1_rdata_o = vpu_rps1_rdata;
    end
endgenerate
`endif

always @ (posedge clk_i) begin
    if(rst_i) begin
        mpu_vr_rdata_act <= 1'b0;
    end else begin
        mpu_vr_rdata_act <= mpu_vr__re_i;
    end
end
assign mpu_vr__rdata_act_o = mpu_vr_rdata_act;

always @ (posedge clk_i) begin
    if(rst_i) begin
        vpu_rs_rdata_act <= 1'b0;
        vpu_rps_rdata_act <= 1'b0;
    end else begin
        vpu_rs_rdata_act <= vpu_vr__rs_re_i;
        vpu_rps_rdata_act <= vpu_vr__rps_re_i;
    end
end
assign vpu_vr__rs_rdata_act_o = vpu_rs_rdata_act;
assign vpu_vr__rps_rdata_act_o = vpu_rps_rdata_act;

//======================================================================================================================
// just for simulation
//======================================================================================================================
// synthesis translate_off

// synthesis translate_on

//======================================================================================================================
// probe signals
//======================================================================================================================

endmodule   
