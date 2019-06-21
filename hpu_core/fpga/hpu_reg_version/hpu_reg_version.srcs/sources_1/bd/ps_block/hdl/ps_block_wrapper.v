//Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2018.2 (lin64) Build 2258646 Thu Jun 14 20:02:38 MDT 2018
//Date        : Thu May 30 15:36:44 2019
//Host        : xjtuair0011 running 64-bit Ubuntu 18.04.2 LTS
//Command     : generate_target ps_block_wrapper.bd
//Design      : ps_block_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module ps_block_wrapper
   (axi_ddr_araddr,
    axi_ddr_arburst,
    axi_ddr_arcache,
    axi_ddr_arid,
    axi_ddr_arlen,
    axi_ddr_arlock,
    axi_ddr_arprot,
    axi_ddr_arqos,
    axi_ddr_arready,
    axi_ddr_arsize,
    axi_ddr_aruser,
    axi_ddr_arvalid,
    axi_ddr_awaddr,
    axi_ddr_awburst,
    axi_ddr_awcache,
    axi_ddr_awid,
    axi_ddr_awlen,
    axi_ddr_awlock,
    axi_ddr_awprot,
    axi_ddr_awqos,
    axi_ddr_awready,
    axi_ddr_awsize,
    axi_ddr_awuser,
    axi_ddr_awvalid,
    axi_ddr_bid,
    axi_ddr_bready,
    axi_ddr_bresp,
    axi_ddr_bvalid,
    axi_ddr_rdata,
    axi_ddr_rid,
    axi_ddr_rlast,
    axi_ddr_rready,
    axi_ddr_rresp,
    axi_ddr_rvalid,
    axi_ddr_wdata,
    axi_ddr_wlast,
    axi_ddr_wready,
    axi_ddr_wstrb,
    axi_ddr_wvalid,
    clk_100m,
    ps_rvram_addr,
    ps_rvram_clk,
    ps_rvram_din,
    ps_rvram_dout,
    ps_rvram_en,
    ps_rvram_rst,
    ps_rvram_we,
    rst_n);
  input [48:0]axi_ddr_araddr;
  input [1:0]axi_ddr_arburst;
  input [3:0]axi_ddr_arcache;
  input [5:0]axi_ddr_arid;
  input [7:0]axi_ddr_arlen;
  input axi_ddr_arlock;
  input [2:0]axi_ddr_arprot;
  input [3:0]axi_ddr_arqos;
  output axi_ddr_arready;
  input [2:0]axi_ddr_arsize;
  input axi_ddr_aruser;
  input axi_ddr_arvalid;
  input [48:0]axi_ddr_awaddr;
  input [1:0]axi_ddr_awburst;
  input [3:0]axi_ddr_awcache;
  input [5:0]axi_ddr_awid;
  input [7:0]axi_ddr_awlen;
  input axi_ddr_awlock;
  input [2:0]axi_ddr_awprot;
  input [3:0]axi_ddr_awqos;
  output axi_ddr_awready;
  input [2:0]axi_ddr_awsize;
  input axi_ddr_awuser;
  input axi_ddr_awvalid;
  output [5:0]axi_ddr_bid;
  input axi_ddr_bready;
  output [1:0]axi_ddr_bresp;
  output axi_ddr_bvalid;
  output [127:0]axi_ddr_rdata;
  output [5:0]axi_ddr_rid;
  output axi_ddr_rlast;
  input axi_ddr_rready;
  output [1:0]axi_ddr_rresp;
  output axi_ddr_rvalid;
  input [127:0]axi_ddr_wdata;
  input axi_ddr_wlast;
  output axi_ddr_wready;
  input [15:0]axi_ddr_wstrb;
  input axi_ddr_wvalid;
  output clk_100m;
  output [11:0]ps_rvram_addr;
  output ps_rvram_clk;
  output [31:0]ps_rvram_din;
  input [31:0]ps_rvram_dout;
  output ps_rvram_en;
  output ps_rvram_rst;
  output [3:0]ps_rvram_we;
  output rst_n;

  wire [48:0]axi_ddr_araddr;
  wire [1:0]axi_ddr_arburst;
  wire [3:0]axi_ddr_arcache;
  wire [5:0]axi_ddr_arid;
  wire [7:0]axi_ddr_arlen;
  wire axi_ddr_arlock;
  wire [2:0]axi_ddr_arprot;
  wire [3:0]axi_ddr_arqos;
  wire axi_ddr_arready;
  wire [2:0]axi_ddr_arsize;
  wire axi_ddr_aruser;
  wire axi_ddr_arvalid;
  wire [48:0]axi_ddr_awaddr;
  wire [1:0]axi_ddr_awburst;
  wire [3:0]axi_ddr_awcache;
  wire [5:0]axi_ddr_awid;
  wire [7:0]axi_ddr_awlen;
  wire axi_ddr_awlock;
  wire [2:0]axi_ddr_awprot;
  wire [3:0]axi_ddr_awqos;
  wire axi_ddr_awready;
  wire [2:0]axi_ddr_awsize;
  wire axi_ddr_awuser;
  wire axi_ddr_awvalid;
  wire [5:0]axi_ddr_bid;
  wire axi_ddr_bready;
  wire [1:0]axi_ddr_bresp;
  wire axi_ddr_bvalid;
  wire [127:0]axi_ddr_rdata;
  wire [5:0]axi_ddr_rid;
  wire axi_ddr_rlast;
  wire axi_ddr_rready;
  wire [1:0]axi_ddr_rresp;
  wire axi_ddr_rvalid;
  wire [127:0]axi_ddr_wdata;
  wire axi_ddr_wlast;
  wire axi_ddr_wready;
  wire [15:0]axi_ddr_wstrb;
  wire axi_ddr_wvalid;
  wire clk_100m;
  wire [11:0]ps_rvram_addr;
  wire ps_rvram_clk;
  wire [31:0]ps_rvram_din;
  wire [31:0]ps_rvram_dout;
  wire ps_rvram_en;
  wire ps_rvram_rst;
  wire [3:0]ps_rvram_we;
  wire rst_n;

  ps_block ps_block_i
       (.axi_ddr_araddr(axi_ddr_araddr),
        .axi_ddr_arburst(axi_ddr_arburst),
        .axi_ddr_arcache(axi_ddr_arcache),
        .axi_ddr_arid(axi_ddr_arid),
        .axi_ddr_arlen(axi_ddr_arlen),
        .axi_ddr_arlock(axi_ddr_arlock),
        .axi_ddr_arprot(axi_ddr_arprot),
        .axi_ddr_arqos(axi_ddr_arqos),
        .axi_ddr_arready(axi_ddr_arready),
        .axi_ddr_arsize(axi_ddr_arsize),
        .axi_ddr_aruser(axi_ddr_aruser),
        .axi_ddr_arvalid(axi_ddr_arvalid),
        .axi_ddr_awaddr(axi_ddr_awaddr),
        .axi_ddr_awburst(axi_ddr_awburst),
        .axi_ddr_awcache(axi_ddr_awcache),
        .axi_ddr_awid(axi_ddr_awid),
        .axi_ddr_awlen(axi_ddr_awlen),
        .axi_ddr_awlock(axi_ddr_awlock),
        .axi_ddr_awprot(axi_ddr_awprot),
        .axi_ddr_awqos(axi_ddr_awqos),
        .axi_ddr_awready(axi_ddr_awready),
        .axi_ddr_awsize(axi_ddr_awsize),
        .axi_ddr_awuser(axi_ddr_awuser),
        .axi_ddr_awvalid(axi_ddr_awvalid),
        .axi_ddr_bid(axi_ddr_bid),
        .axi_ddr_bready(axi_ddr_bready),
        .axi_ddr_bresp(axi_ddr_bresp),
        .axi_ddr_bvalid(axi_ddr_bvalid),
        .axi_ddr_rdata(axi_ddr_rdata),
        .axi_ddr_rid(axi_ddr_rid),
        .axi_ddr_rlast(axi_ddr_rlast),
        .axi_ddr_rready(axi_ddr_rready),
        .axi_ddr_rresp(axi_ddr_rresp),
        .axi_ddr_rvalid(axi_ddr_rvalid),
        .axi_ddr_wdata(axi_ddr_wdata),
        .axi_ddr_wlast(axi_ddr_wlast),
        .axi_ddr_wready(axi_ddr_wready),
        .axi_ddr_wstrb(axi_ddr_wstrb),
        .axi_ddr_wvalid(axi_ddr_wvalid),
        .clk_100m(clk_100m),
        .ps_rvram_addr(ps_rvram_addr),
        .ps_rvram_clk(ps_rvram_clk),
        .ps_rvram_din(ps_rvram_din),
        .ps_rvram_dout(ps_rvram_dout),
        .ps_rvram_en(ps_rvram_en),
        .ps_rvram_rst(ps_rvram_rst),
        .ps_rvram_we(ps_rvram_we),
        .rst_n(rst_n));
endmodule
