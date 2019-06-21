// (c) Copyright 1995-2019 Xilinx, Inc. All rights reserved.
// 
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
// 
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
// 
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
// 
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
// 
// DO NOT MODIFY THIS FILE.

//-----------------------------------------------------------------------------
// Filename:    ps_block_zynq_ultra_ps_e_0_0_stub.sv
// Description: This HDL file is intended to be used with Xilinx Vivado Simulator (XSIM) only.
//-----------------------------------------------------------------------------
`ifdef XILINX_SIMULATOR

`ifndef XILINX_SIMULATOR_BITASBOOL
`define XILINX_SIMULATOR_BITASBOOL
typedef bit bit_as_bool;
`endif

(* SC_MODULE_EXPORT *)
module ps_block_zynq_ultra_ps_e_0_0 (
  input bit_as_bool maxihpm0_fpd_aclk,
  output bit [15 : 0] maxigp0_awid,
  output bit [39 : 0] maxigp0_awaddr,
  output bit [7 : 0] maxigp0_awlen,
  output bit [2 : 0] maxigp0_awsize,
  output bit [1 : 0] maxigp0_awburst,
  output bit_as_bool maxigp0_awlock,
  output bit [3 : 0] maxigp0_awcache,
  output bit [2 : 0] maxigp0_awprot,
  output bit_as_bool maxigp0_awvalid,
  output bit [15 : 0] maxigp0_awuser,
  input bit_as_bool maxigp0_awready,
  output bit [31 : 0] maxigp0_wdata,
  output bit [3 : 0] maxigp0_wstrb,
  output bit_as_bool maxigp0_wlast,
  output bit_as_bool maxigp0_wvalid,
  input bit_as_bool maxigp0_wready,
  input bit [15 : 0] maxigp0_bid,
  input bit [1 : 0] maxigp0_bresp,
  input bit_as_bool maxigp0_bvalid,
  output bit_as_bool maxigp0_bready,
  output bit [15 : 0] maxigp0_arid,
  output bit [39 : 0] maxigp0_araddr,
  output bit [7 : 0] maxigp0_arlen,
  output bit [2 : 0] maxigp0_arsize,
  output bit [1 : 0] maxigp0_arburst,
  output bit_as_bool maxigp0_arlock,
  output bit [3 : 0] maxigp0_arcache,
  output bit [2 : 0] maxigp0_arprot,
  output bit_as_bool maxigp0_arvalid,
  output bit [15 : 0] maxigp0_aruser,
  input bit_as_bool maxigp0_arready,
  input bit [15 : 0] maxigp0_rid,
  input bit [31 : 0] maxigp0_rdata,
  input bit [1 : 0] maxigp0_rresp,
  input bit_as_bool maxigp0_rlast,
  input bit_as_bool maxigp0_rvalid,
  output bit_as_bool maxigp0_rready,
  output bit [3 : 0] maxigp0_awqos,
  output bit [3 : 0] maxigp0_arqos,
  input bit_as_bool saxihp0_fpd_aclk,
  input bit_as_bool saxigp2_aruser,
  input bit_as_bool saxigp2_awuser,
  input bit [5 : 0] saxigp2_awid,
  input bit [48 : 0] saxigp2_awaddr,
  input bit [7 : 0] saxigp2_awlen,
  input bit [2 : 0] saxigp2_awsize,
  input bit [1 : 0] saxigp2_awburst,
  input bit_as_bool saxigp2_awlock,
  input bit [3 : 0] saxigp2_awcache,
  input bit [2 : 0] saxigp2_awprot,
  input bit_as_bool saxigp2_awvalid,
  output bit_as_bool saxigp2_awready,
  input bit [127 : 0] saxigp2_wdata,
  input bit [15 : 0] saxigp2_wstrb,
  input bit_as_bool saxigp2_wlast,
  input bit_as_bool saxigp2_wvalid,
  output bit_as_bool saxigp2_wready,
  output bit [5 : 0] saxigp2_bid,
  output bit [1 : 0] saxigp2_bresp,
  output bit_as_bool saxigp2_bvalid,
  input bit_as_bool saxigp2_bready,
  input bit [5 : 0] saxigp2_arid,
  input bit [48 : 0] saxigp2_araddr,
  input bit [7 : 0] saxigp2_arlen,
  input bit [2 : 0] saxigp2_arsize,
  input bit [1 : 0] saxigp2_arburst,
  input bit_as_bool saxigp2_arlock,
  input bit [3 : 0] saxigp2_arcache,
  input bit [2 : 0] saxigp2_arprot,
  input bit_as_bool saxigp2_arvalid,
  output bit_as_bool saxigp2_arready,
  output bit [5 : 0] saxigp2_rid,
  output bit [127 : 0] saxigp2_rdata,
  output bit [1 : 0] saxigp2_rresp,
  output bit_as_bool saxigp2_rlast,
  output bit_as_bool saxigp2_rvalid,
  input bit_as_bool saxigp2_rready,
  input bit [3 : 0] saxigp2_awqos,
  input bit [3 : 0] saxigp2_arqos,
  output bit_as_bool pl_resetn0,
  output bit_as_bool pl_clk0
);
endmodule
`endif
