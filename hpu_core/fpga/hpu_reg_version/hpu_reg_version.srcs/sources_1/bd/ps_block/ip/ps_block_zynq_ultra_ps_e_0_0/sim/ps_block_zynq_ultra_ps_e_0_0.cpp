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

#include "ps_block_zynq_ultra_ps_e_0_0.h"

#include "zynq_ultra_ps_e_tlm.h"

#include <map>
#include <string>

ps_block_zynq_ultra_ps_e_0_0::ps_block_zynq_ultra_ps_e_0_0(const sc_module_name& nm) : sc_module(nm), mp_impl(NULL)
{
  // configure connectivity manager
  xsc::utils::xsc_sim_manager::addInstance("ps_block_zynq_ultra_ps_e_0_0", this);

  // initialize module
  xsc::common::properties model_param_props;
  model_param_props._long_property_map["C_DP_USE_AUDIO"] = 0;
  model_param_props._long_property_map["C_DP_USE_VIDEO"] = 0;
  model_param_props._long_property_map["C_MAXIGP0_DATA_WIDTH"] = 32;
  model_param_props._long_property_map["C_MAXIGP1_DATA_WIDTH"] = 128;
  model_param_props._long_property_map["C_MAXIGP2_DATA_WIDTH"] = 32;
  model_param_props._long_property_map["C_SAXIGP0_DATA_WIDTH"] = 128;
  model_param_props._long_property_map["C_SAXIGP1_DATA_WIDTH"] = 128;
  model_param_props._long_property_map["C_SAXIGP2_DATA_WIDTH"] = 128;
  model_param_props._long_property_map["C_SAXIGP3_DATA_WIDTH"] = 128;
  model_param_props._long_property_map["C_SAXIGP4_DATA_WIDTH"] = 128;
  model_param_props._long_property_map["C_SAXIGP5_DATA_WIDTH"] = 128;
  model_param_props._long_property_map["C_SAXIGP6_DATA_WIDTH"] = 128;
  model_param_props._long_property_map["C_USE_DIFF_RW_CLK_GP0"] = 0;
  model_param_props._long_property_map["C_USE_DIFF_RW_CLK_GP1"] = 0;
  model_param_props._long_property_map["C_USE_DIFF_RW_CLK_GP2"] = 0;
  model_param_props._long_property_map["C_USE_DIFF_RW_CLK_GP3"] = 0;
  model_param_props._long_property_map["C_USE_DIFF_RW_CLK_GP4"] = 0;
  model_param_props._long_property_map["C_USE_DIFF_RW_CLK_GP5"] = 0;
  model_param_props._long_property_map["C_USE_DIFF_RW_CLK_GP6"] = 0;
  model_param_props._long_property_map["C_TRACE_PIPELINE_WIDTH"] = 8;
  model_param_props._long_property_map["C_EN_EMIO_TRACE"] = 0;
  model_param_props._long_property_map["C_TRACE_DATA_WIDTH"] = 32;
  model_param_props._long_property_map["C_USE_DEBUG_TEST"] = 0;
  model_param_props._long_property_map["C_SD0_INTERNAL_BUS_WIDTH"] = 4;
  model_param_props._long_property_map["C_SD1_INTERNAL_BUS_WIDTH"] = 4;
  model_param_props._long_property_map["C_NUM_F2P_0_INTR_INPUTS"] = 1;
  model_param_props._long_property_map["C_NUM_F2P_1_INTR_INPUTS"] = 1;
  model_param_props._long_property_map["C_EMIO_GPIO_WIDTH"] = 1;
  model_param_props._long_property_map["C_NUM_FABRIC_RESETS"] = 1;
  model_param_props._string_property_map["C_EN_FIFO_ENET0"] = "0";
  model_param_props._string_property_map["C_EN_FIFO_ENET1"] = "0";
  model_param_props._string_property_map["C_EN_FIFO_ENET2"] = "0";
  model_param_props._string_property_map["C_EN_FIFO_ENET3"] = "0";
  model_param_props._string_property_map["C_PL_CLK0_BUF"] = "TRUE";
  model_param_props._string_property_map["C_PL_CLK1_BUF"] = "FALSE";
  model_param_props._string_property_map["C_PL_CLK2_BUF"] = "FALSE";
  model_param_props._string_property_map["C_PL_CLK3_BUF"] = "FALSE";
  mp_impl = new zynq_ultra_ps_e_tlm("inst", model_param_props);

  // initialize sockets
  M_AXI_HPM0_FPD_wr_socket = mp_impl->M_AXI_HPM0_FPD_wr_socket;
  M_AXI_HPM0_FPD_rd_socket = mp_impl->M_AXI_HPM0_FPD_rd_socket;
  S_AXI_HP0_FPD_wr_socket = mp_impl->S_AXI_HP0_FPD_wr_socket;
  S_AXI_HP0_FPD_rd_socket = mp_impl->S_AXI_HP0_FPD_rd_socket;

  // initialize pins
  mp_impl->maxihpm0_fpd_aclk(maxihpm0_fpd_aclk);
  mp_impl->saxihp0_fpd_aclk(saxihp0_fpd_aclk);
  mp_impl->pl_resetn0(pl_resetn0);
  mp_impl->pl_clk0(pl_clk0);

  // initialize transactors
  mp_M_AXI_HPM0_FPD_transactor = NULL;
  mp_S_AXI_HP0_FPD_transactor = NULL;
  mp_saxigp2_aruser_converter = NULL;
  mp_saxigp2_awuser_converter = NULL;
}

void ps_block_zynq_ultra_ps_e_0_0::before_end_of_elaboration()
{
  // configure 'M_AXI_HPM0_FPD' transactor
  if (xsc::utils::xsc_sim_manager::getInstanceParameterInt("ps_block_zynq_ultra_ps_e_0_0", "M_AXI_HPM0_FPD_TLM_MODE") != 1)
  {
    xsc::common::properties M_AXI_HPM0_FPD_transactor_param_props;
    M_AXI_HPM0_FPD_transactor_param_props._long_property_map["DATA_WIDTH"] = 32;
    M_AXI_HPM0_FPD_transactor_param_props._long_property_map["FREQ_HZ"] = 233333338;
    M_AXI_HPM0_FPD_transactor_param_props._long_property_map["ID_WIDTH"] = 16;
    M_AXI_HPM0_FPD_transactor_param_props._long_property_map["ADDR_WIDTH"] = 40;
    M_AXI_HPM0_FPD_transactor_param_props._long_property_map["AWUSER_WIDTH"] = 16;
    M_AXI_HPM0_FPD_transactor_param_props._long_property_map["ARUSER_WIDTH"] = 16;
    M_AXI_HPM0_FPD_transactor_param_props._long_property_map["WUSER_WIDTH"] = 0;
    M_AXI_HPM0_FPD_transactor_param_props._long_property_map["RUSER_WIDTH"] = 0;
    M_AXI_HPM0_FPD_transactor_param_props._long_property_map["BUSER_WIDTH"] = 0;
    M_AXI_HPM0_FPD_transactor_param_props._long_property_map["HAS_BURST"] = 1;
    M_AXI_HPM0_FPD_transactor_param_props._long_property_map["HAS_LOCK"] = 1;
    M_AXI_HPM0_FPD_transactor_param_props._long_property_map["HAS_PROT"] = 1;
    M_AXI_HPM0_FPD_transactor_param_props._long_property_map["HAS_CACHE"] = 1;
    M_AXI_HPM0_FPD_transactor_param_props._long_property_map["HAS_QOS"] = 1;
    M_AXI_HPM0_FPD_transactor_param_props._long_property_map["HAS_REGION"] = 0;
    M_AXI_HPM0_FPD_transactor_param_props._long_property_map["HAS_WSTRB"] = 1;
    M_AXI_HPM0_FPD_transactor_param_props._long_property_map["HAS_BRESP"] = 1;
    M_AXI_HPM0_FPD_transactor_param_props._long_property_map["HAS_RRESP"] = 1;
    M_AXI_HPM0_FPD_transactor_param_props._long_property_map["SUPPORTS_NARROW_BURST"] = 1;
    M_AXI_HPM0_FPD_transactor_param_props._long_property_map["MAX_BURST_LENGTH"] = 256;
    M_AXI_HPM0_FPD_transactor_param_props._long_property_map["NUM_READ_THREADS"] = 4;
    M_AXI_HPM0_FPD_transactor_param_props._long_property_map["NUM_WRITE_THREADS"] = 4;
    M_AXI_HPM0_FPD_transactor_param_props._long_property_map["RUSER_BITS_PER_BYTE"] = 0;
    M_AXI_HPM0_FPD_transactor_param_props._long_property_map["WUSER_BITS_PER_BYTE"] = 0;
    M_AXI_HPM0_FPD_transactor_param_props._float_property_map["PHASE"] = 0.000;
    M_AXI_HPM0_FPD_transactor_param_props._string_property_map["NUM_WRITE_OUTSTANDING"] = "8";
    M_AXI_HPM0_FPD_transactor_param_props._string_property_map["NUM_READ_OUTSTANDING"] = "8";
    M_AXI_HPM0_FPD_transactor_param_props._string_property_map["PROTOCOL"] = "AXI4";
    M_AXI_HPM0_FPD_transactor_param_props._string_property_map["READ_WRITE_MODE"] = "READ_WRITE";
    M_AXI_HPM0_FPD_transactor_param_props._string_property_map["CLK_DOMAIN"] = "ps_block_zynq_ultra_ps_e_0_0_pl_clk0";
    mp_M_AXI_HPM0_FPD_transactor = new xtlm::xaximm_xtlm2pin_t<32,40,16,16,1,1,16,1>("M_AXI_HPM0_FPD_transactor", M_AXI_HPM0_FPD_transactor_param_props);
    mp_M_AXI_HPM0_FPD_transactor->ARADDR(maxigp0_araddr);
    mp_M_AXI_HPM0_FPD_transactor->ARBURST(maxigp0_arburst);
    mp_M_AXI_HPM0_FPD_transactor->ARCACHE(maxigp0_arcache);
    mp_M_AXI_HPM0_FPD_transactor->ARID(maxigp0_arid);
    mp_M_AXI_HPM0_FPD_transactor->ARLEN(maxigp0_arlen);
    mp_M_AXI_HPM0_FPD_transactor->ARLOCK(maxigp0_arlock);
    mp_M_AXI_HPM0_FPD_transactor->ARPROT(maxigp0_arprot);
    mp_M_AXI_HPM0_FPD_transactor->ARQOS(maxigp0_arqos);
    mp_M_AXI_HPM0_FPD_transactor->ARREADY(maxigp0_arready);
    mp_M_AXI_HPM0_FPD_transactor->ARSIZE(maxigp0_arsize);
    mp_M_AXI_HPM0_FPD_transactor->ARUSER(maxigp0_aruser);
    mp_M_AXI_HPM0_FPD_transactor->ARVALID(maxigp0_arvalid);
    mp_M_AXI_HPM0_FPD_transactor->AWADDR(maxigp0_awaddr);
    mp_M_AXI_HPM0_FPD_transactor->AWBURST(maxigp0_awburst);
    mp_M_AXI_HPM0_FPD_transactor->AWCACHE(maxigp0_awcache);
    mp_M_AXI_HPM0_FPD_transactor->AWID(maxigp0_awid);
    mp_M_AXI_HPM0_FPD_transactor->AWLEN(maxigp0_awlen);
    mp_M_AXI_HPM0_FPD_transactor->AWLOCK(maxigp0_awlock);
    mp_M_AXI_HPM0_FPD_transactor->AWPROT(maxigp0_awprot);
    mp_M_AXI_HPM0_FPD_transactor->AWQOS(maxigp0_awqos);
    mp_M_AXI_HPM0_FPD_transactor->AWREADY(maxigp0_awready);
    mp_M_AXI_HPM0_FPD_transactor->AWSIZE(maxigp0_awsize);
    mp_M_AXI_HPM0_FPD_transactor->AWUSER(maxigp0_awuser);
    mp_M_AXI_HPM0_FPD_transactor->AWVALID(maxigp0_awvalid);
    mp_M_AXI_HPM0_FPD_transactor->BID(maxigp0_bid);
    mp_M_AXI_HPM0_FPD_transactor->BREADY(maxigp0_bready);
    mp_M_AXI_HPM0_FPD_transactor->BRESP(maxigp0_bresp);
    mp_M_AXI_HPM0_FPD_transactor->BVALID(maxigp0_bvalid);
    mp_M_AXI_HPM0_FPD_transactor->RDATA(maxigp0_rdata);
    mp_M_AXI_HPM0_FPD_transactor->RID(maxigp0_rid);
    mp_M_AXI_HPM0_FPD_transactor->RLAST(maxigp0_rlast);
    mp_M_AXI_HPM0_FPD_transactor->RREADY(maxigp0_rready);
    mp_M_AXI_HPM0_FPD_transactor->RRESP(maxigp0_rresp);
    mp_M_AXI_HPM0_FPD_transactor->RVALID(maxigp0_rvalid);
    mp_M_AXI_HPM0_FPD_transactor->WDATA(maxigp0_wdata);
    mp_M_AXI_HPM0_FPD_transactor->WLAST(maxigp0_wlast);
    mp_M_AXI_HPM0_FPD_transactor->WREADY(maxigp0_wready);
    mp_M_AXI_HPM0_FPD_transactor->WSTRB(maxigp0_wstrb);
    mp_M_AXI_HPM0_FPD_transactor->WVALID(maxigp0_wvalid);
    mp_M_AXI_HPM0_FPD_transactor->CLK(maxihpm0_fpd_aclk);
    m_M_AXI_HPM0_FPD_transactor_rst_signal.write(1);
    mp_M_AXI_HPM0_FPD_transactor->RST(m_M_AXI_HPM0_FPD_transactor_rst_signal);

    mp_impl->M_AXI_HPM0_FPD_wr_socket->bind(*(mp_M_AXI_HPM0_FPD_transactor->wr_socket));
    mp_impl->M_AXI_HPM0_FPD_rd_socket->bind(*(mp_M_AXI_HPM0_FPD_transactor->rd_socket));
  }
  // configure 'S_AXI_HP0_FPD' transactor
  if (xsc::utils::xsc_sim_manager::getInstanceParameterInt("ps_block_zynq_ultra_ps_e_0_0", "S_AXI_HP0_FPD_TLM_MODE") != 1)
  {
    xsc::common::properties S_AXI_HP0_FPD_transactor_param_props;
    S_AXI_HP0_FPD_transactor_param_props._long_property_map["DATA_WIDTH"] = 128;
    S_AXI_HP0_FPD_transactor_param_props._long_property_map["FREQ_HZ"] = 233333338;
    S_AXI_HP0_FPD_transactor_param_props._long_property_map["ID_WIDTH"] = 6;
    S_AXI_HP0_FPD_transactor_param_props._long_property_map["ADDR_WIDTH"] = 49;
    S_AXI_HP0_FPD_transactor_param_props._long_property_map["AWUSER_WIDTH"] = 1;
    S_AXI_HP0_FPD_transactor_param_props._long_property_map["ARUSER_WIDTH"] = 1;
    S_AXI_HP0_FPD_transactor_param_props._long_property_map["WUSER_WIDTH"] = 0;
    S_AXI_HP0_FPD_transactor_param_props._long_property_map["RUSER_WIDTH"] = 0;
    S_AXI_HP0_FPD_transactor_param_props._long_property_map["BUSER_WIDTH"] = 0;
    S_AXI_HP0_FPD_transactor_param_props._long_property_map["HAS_BURST"] = 1;
    S_AXI_HP0_FPD_transactor_param_props._long_property_map["HAS_LOCK"] = 1;
    S_AXI_HP0_FPD_transactor_param_props._long_property_map["HAS_PROT"] = 1;
    S_AXI_HP0_FPD_transactor_param_props._long_property_map["HAS_CACHE"] = 1;
    S_AXI_HP0_FPD_transactor_param_props._long_property_map["HAS_QOS"] = 1;
    S_AXI_HP0_FPD_transactor_param_props._long_property_map["HAS_REGION"] = 0;
    S_AXI_HP0_FPD_transactor_param_props._long_property_map["HAS_WSTRB"] = 1;
    S_AXI_HP0_FPD_transactor_param_props._long_property_map["HAS_BRESP"] = 1;
    S_AXI_HP0_FPD_transactor_param_props._long_property_map["HAS_RRESP"] = 1;
    S_AXI_HP0_FPD_transactor_param_props._long_property_map["SUPPORTS_NARROW_BURST"] = 1;
    S_AXI_HP0_FPD_transactor_param_props._long_property_map["MAX_BURST_LENGTH"] = 256;
    S_AXI_HP0_FPD_transactor_param_props._long_property_map["NUM_READ_THREADS"] = 1;
    S_AXI_HP0_FPD_transactor_param_props._long_property_map["NUM_WRITE_THREADS"] = 1;
    S_AXI_HP0_FPD_transactor_param_props._long_property_map["RUSER_BITS_PER_BYTE"] = 0;
    S_AXI_HP0_FPD_transactor_param_props._long_property_map["WUSER_BITS_PER_BYTE"] = 0;
    S_AXI_HP0_FPD_transactor_param_props._float_property_map["PHASE"] = 0.000;
    S_AXI_HP0_FPD_transactor_param_props._string_property_map["NUM_WRITE_OUTSTANDING"] = "16";
    S_AXI_HP0_FPD_transactor_param_props._string_property_map["NUM_READ_OUTSTANDING"] = "16";
    S_AXI_HP0_FPD_transactor_param_props._string_property_map["PROTOCOL"] = "AXI4";
    S_AXI_HP0_FPD_transactor_param_props._string_property_map["READ_WRITE_MODE"] = "READ_WRITE";
    S_AXI_HP0_FPD_transactor_param_props._string_property_map["CLK_DOMAIN"] = "ps_block_zynq_ultra_ps_e_0_0_pl_clk0";
    mp_S_AXI_HP0_FPD_transactor = new xtlm::xaximm_pin2xtlm_t<128,49,6,1,1,1,1,1>("S_AXI_HP0_FPD_transactor", S_AXI_HP0_FPD_transactor_param_props);
    mp_S_AXI_HP0_FPD_transactor->ARADDR(saxigp2_araddr);
    mp_S_AXI_HP0_FPD_transactor->ARBURST(saxigp2_arburst);
    mp_S_AXI_HP0_FPD_transactor->ARCACHE(saxigp2_arcache);
    mp_S_AXI_HP0_FPD_transactor->ARID(saxigp2_arid);
    mp_S_AXI_HP0_FPD_transactor->ARLEN(saxigp2_arlen);
    mp_S_AXI_HP0_FPD_transactor->ARLOCK(saxigp2_arlock);
    mp_S_AXI_HP0_FPD_transactor->ARPROT(saxigp2_arprot);
    mp_S_AXI_HP0_FPD_transactor->ARQOS(saxigp2_arqos);
    mp_S_AXI_HP0_FPD_transactor->ARREADY(saxigp2_arready);
    mp_S_AXI_HP0_FPD_transactor->ARSIZE(saxigp2_arsize);
    mp_saxigp2_aruser_converter = new xsc::common::scalar2vector_converter("saxigp2_aruser_converter");
    mp_S_AXI_HP0_FPD_transactor->ARUSER(m_saxigp2_aruser_converter_signal);
    (*mp_saxigp2_aruser_converter)(saxigp2_aruser, m_saxigp2_aruser_converter_signal);
    mp_S_AXI_HP0_FPD_transactor->ARVALID(saxigp2_arvalid);
    mp_S_AXI_HP0_FPD_transactor->AWADDR(saxigp2_awaddr);
    mp_S_AXI_HP0_FPD_transactor->AWBURST(saxigp2_awburst);
    mp_S_AXI_HP0_FPD_transactor->AWCACHE(saxigp2_awcache);
    mp_S_AXI_HP0_FPD_transactor->AWID(saxigp2_awid);
    mp_S_AXI_HP0_FPD_transactor->AWLEN(saxigp2_awlen);
    mp_S_AXI_HP0_FPD_transactor->AWLOCK(saxigp2_awlock);
    mp_S_AXI_HP0_FPD_transactor->AWPROT(saxigp2_awprot);
    mp_S_AXI_HP0_FPD_transactor->AWQOS(saxigp2_awqos);
    mp_S_AXI_HP0_FPD_transactor->AWREADY(saxigp2_awready);
    mp_S_AXI_HP0_FPD_transactor->AWSIZE(saxigp2_awsize);
    mp_saxigp2_awuser_converter = new xsc::common::scalar2vector_converter("saxigp2_awuser_converter");
    mp_S_AXI_HP0_FPD_transactor->AWUSER(m_saxigp2_awuser_converter_signal);
    (*mp_saxigp2_awuser_converter)(saxigp2_awuser, m_saxigp2_awuser_converter_signal);
    mp_S_AXI_HP0_FPD_transactor->AWVALID(saxigp2_awvalid);
    mp_S_AXI_HP0_FPD_transactor->BID(saxigp2_bid);
    mp_S_AXI_HP0_FPD_transactor->BREADY(saxigp2_bready);
    mp_S_AXI_HP0_FPD_transactor->BRESP(saxigp2_bresp);
    mp_S_AXI_HP0_FPD_transactor->BVALID(saxigp2_bvalid);
    mp_S_AXI_HP0_FPD_transactor->RDATA(saxigp2_rdata);
    mp_S_AXI_HP0_FPD_transactor->RID(saxigp2_rid);
    mp_S_AXI_HP0_FPD_transactor->RLAST(saxigp2_rlast);
    mp_S_AXI_HP0_FPD_transactor->RREADY(saxigp2_rready);
    mp_S_AXI_HP0_FPD_transactor->RRESP(saxigp2_rresp);
    mp_S_AXI_HP0_FPD_transactor->RVALID(saxigp2_rvalid);
    mp_S_AXI_HP0_FPD_transactor->WDATA(saxigp2_wdata);
    mp_S_AXI_HP0_FPD_transactor->WLAST(saxigp2_wlast);
    mp_S_AXI_HP0_FPD_transactor->WREADY(saxigp2_wready);
    mp_S_AXI_HP0_FPD_transactor->WSTRB(saxigp2_wstrb);
    mp_S_AXI_HP0_FPD_transactor->WVALID(saxigp2_wvalid);
    mp_S_AXI_HP0_FPD_transactor->CLK(saxihp0_fpd_aclk);
    m_S_AXI_HP0_FPD_transactor_rst_signal.write(1);
    mp_S_AXI_HP0_FPD_transactor->RST(m_S_AXI_HP0_FPD_transactor_rst_signal);

    mp_impl->S_AXI_HP0_FPD_wr_socket->bind(*(mp_S_AXI_HP0_FPD_transactor->wr_socket));
    mp_impl->S_AXI_HP0_FPD_rd_socket->bind(*(mp_S_AXI_HP0_FPD_transactor->rd_socket));
  }
}

ps_block_zynq_ultra_ps_e_0_0::~ps_block_zynq_ultra_ps_e_0_0()
{
  xsc::utils::xsc_sim_manager::clean();

  delete mp_impl;
  delete mp_M_AXI_HPM0_FPD_transactor;
  delete mp_S_AXI_HP0_FPD_transactor;
  delete mp_saxigp2_aruser_converter;
  delete mp_saxigp2_awuser_converter;
}

#ifdef MTI_SYSTEMC
SC_MODULE_EXPORT(ps_block_zynq_ultra_ps_e_0_0);
#endif
