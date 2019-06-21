// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module vpu(clk_i, clk_2x_i, rst_i, vpu_op_sum_act_i, 
  vpu_op_clip_i, vpu_op_bias_act_i, vpu_op_relu_act_i, vpu_op_shfl_act_i, 
  vpu_op_shfl_up_act_i, vpu_op_strobe_h_i, vpu_op_strobe_v_i, vpu_vr__rs0_rdata_i, 
  vpu_vr__rs1_rdata_i, vpu_vr__rs_rdata_act_i, vpu_brb__rdata_i, vpu_brb__rdata_act_i, 
  vpu_mra__wdata_o, vpu_mra__wdata_strob_h_o, vpu_mra__wdata_strob_v_o, 
  vpu_mra__wdata_act_o);
  input clk_i;
  input clk_2x_i;
  input rst_i;
  input vpu_op_sum_act_i;
  input [4:0]vpu_op_clip_i;
  input vpu_op_bias_act_i;
  input vpu_op_relu_act_i;
  input vpu_op_shfl_act_i;
  input vpu_op_shfl_up_act_i;
  input [7:0]vpu_op_strobe_h_i;
  input [7:0]vpu_op_strobe_v_i;
  input [2047:0]vpu_vr__rs0_rdata_i;
  input [2047:0]vpu_vr__rs1_rdata_i;
  input vpu_vr__rs_rdata_act_i;
  input [63:0]vpu_brb__rdata_i;
  input vpu_brb__rdata_act_i;
  output [511:0]vpu_mra__wdata_o;
  output [7:0]vpu_mra__wdata_strob_h_o;
  output [7:0]vpu_mra__wdata_strob_v_o;
  output vpu_mra__wdata_act_o;
endmodule
