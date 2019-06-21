// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module vputy(clk_i, clk_2x_i, rst_i, vputy_op_mul_sel_i, 
  vputy_op_ldsl_sel_i, vputy_op_ldsr_sel_i, vputy_op_acc_sel_i, vputy_op_max_sel_i, 
  vputy_sv_sel_act_i, vputy_sv_mtx_sel_h_i, vputy_sv_clip_i, vputy_sv_bias_act_i, 
  vputy_sv_relu_act_i, vputy_sv_shfl_act_i, vputy_sv_chpri_act_i, vputy_sv_shfl_up_act_i, 
  vputy_sv_strobe_h_i, vputy_sv_strobe_v_i, vputy_mra__rdata_i, vputy_mra__rdata_act_i, 
  vputy_mrc__rdata_i, vputy_mrc__rdata_act_i, vputy_brc__rdata_i, vputy_brc__rdata_act_i, 
  vputy_mra__wdata_o, vputy_mra__wdata_strob_h_o, vputy_mra__wdata_strob_v_o, 
  vputy_mra__wdata_act_o);
  input clk_i;
  input clk_2x_i;
  input rst_i;
  input vputy_op_mul_sel_i;
  input vputy_op_ldsl_sel_i;
  input vputy_op_ldsr_sel_i;
  input vputy_op_acc_sel_i;
  input vputy_op_max_sel_i;
  input vputy_sv_sel_act_i;
  input [2:0]vputy_sv_mtx_sel_h_i;
  input [4:0]vputy_sv_clip_i;
  input vputy_sv_bias_act_i;
  input vputy_sv_relu_act_i;
  input vputy_sv_shfl_act_i;
  input vputy_sv_chpri_act_i;
  input vputy_sv_shfl_up_act_i;
  input [7:0]vputy_sv_strobe_h_i;
  input [7:0]vputy_sv_strobe_v_i;
  input [511:0]vputy_mra__rdata_i;
  input vputy_mra__rdata_act_i;
  input [511:0]vputy_mrc__rdata_i;
  input vputy_mrc__rdata_act_i;
  input [511:0]vputy_brc__rdata_i;
  input vputy_brc__rdata_act_i;
  output [511:0]vputy_mra__wdata_o;
  output [7:0]vputy_mra__wdata_strob_h_o;
  output [7:0]vputy_mra__wdata_strob_v_o;
  output vputy_mra__wdata_act_o;
endmodule
