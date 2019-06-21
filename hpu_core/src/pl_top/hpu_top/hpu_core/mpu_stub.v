// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module mpu(clk_i, clk_2x_i, rst_i, mpu_op_extacc_act_i, 
  mpu_op_bypass_act_i, mpu_op_type_i, mpu_mra__rdata_i, mpu_mra__rdata_act_i, 
  mpu_mrb__rdata_i, mpu_mrb__rdata_act_i, mpu_mrb__vmode_rdata_i, 
  mpu_mrb__vmode_rdata_act_i, mpu_vr__wdata_o, mpu_vr__wdata_act_o, mpu_vr__rdata_i, 
  mpu_vr__rdata_act_i);
  input clk_i;
  input clk_2x_i;
  input rst_i;
  input mpu_op_extacc_act_i;
  input mpu_op_bypass_act_i;
  input [0:0]mpu_op_type_i;
  input [511:0]mpu_mra__rdata_i;
  input mpu_mra__rdata_act_i;
  input [511:0]mpu_mrb__rdata_i;
  input mpu_mrb__rdata_act_i;
  input [4095:0]mpu_mrb__vmode_rdata_i;
  input mpu_mrb__vmode_rdata_act_i;
  output [2047:0]mpu_vr__wdata_o;
  output mpu_vr__wdata_act_o;
  input [2047:0]mpu_vr__rdata_i;
  input mpu_vr__rdata_act_i;
endmodule
