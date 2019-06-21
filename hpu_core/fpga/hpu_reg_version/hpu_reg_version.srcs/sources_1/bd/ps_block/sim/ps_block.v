//Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2018.2 (lin64) Build 2258646 Thu Jun 14 20:02:38 MDT 2018
//Date        : Thu May 30 15:36:44 2019
//Host        : xjtuair0011 running 64-bit Ubuntu 18.04.2 LTS
//Command     : generate_target ps_block.bd
//Design      : ps_block
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CORE_GENERATION_INFO = "ps_block,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=ps_block,x_ipVersion=1.00.a,x_ipLanguage=VERILOG,numBlks=3,numReposBlks=3,numNonXlnxBlks=0,numHierBlks=0,maxHierDepth=0,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=0,numPkgbdBlks=0,bdsource=USER,da_axi4_cnt=3,da_clkrst_cnt=1,da_zynq_ultra_ps_e_cnt=1,synth_mode=OOC_per_IP}" *) (* HW_HANDOFF = "ps_block.hwdef" *) 
module ps_block
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
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_ddr ARADDR" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME axi_ddr, ADDR_WIDTH 49, ARUSER_WIDTH 1, AWUSER_WIDTH 1, BUSER_WIDTH 0, CLK_DOMAIN ps_block_zynq_ultra_ps_e_0_0_pl_clk0, DATA_WIDTH 128, FREQ_HZ 233333338, HAS_BRESP 1, HAS_BURST 1, HAS_CACHE 1, HAS_LOCK 1, HAS_PROT 1, HAS_QOS 1, HAS_REGION 0, HAS_RRESP 1, HAS_WSTRB 1, ID_WIDTH 6, MAX_BURST_LENGTH 256, NUM_READ_OUTSTANDING 16, NUM_READ_THREADS 1, NUM_WRITE_OUTSTANDING 16, NUM_WRITE_THREADS 1, PHASE 0.000, PROTOCOL AXI4, READ_WRITE_MODE READ_WRITE, RUSER_BITS_PER_BYTE 0, RUSER_WIDTH 0, SUPPORTS_NARROW_BURST 1, WUSER_BITS_PER_BYTE 0, WUSER_WIDTH 0" *) input [48:0]axi_ddr_araddr;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_ddr ARBURST" *) input [1:0]axi_ddr_arburst;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_ddr ARCACHE" *) input [3:0]axi_ddr_arcache;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_ddr ARID" *) input [5:0]axi_ddr_arid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_ddr ARLEN" *) input [7:0]axi_ddr_arlen;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_ddr ARLOCK" *) input axi_ddr_arlock;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_ddr ARPROT" *) input [2:0]axi_ddr_arprot;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_ddr ARQOS" *) input [3:0]axi_ddr_arqos;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_ddr ARREADY" *) output axi_ddr_arready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_ddr ARSIZE" *) input [2:0]axi_ddr_arsize;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_ddr ARUSER" *) input axi_ddr_aruser;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_ddr ARVALID" *) input axi_ddr_arvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_ddr AWADDR" *) input [48:0]axi_ddr_awaddr;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_ddr AWBURST" *) input [1:0]axi_ddr_awburst;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_ddr AWCACHE" *) input [3:0]axi_ddr_awcache;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_ddr AWID" *) input [5:0]axi_ddr_awid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_ddr AWLEN" *) input [7:0]axi_ddr_awlen;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_ddr AWLOCK" *) input axi_ddr_awlock;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_ddr AWPROT" *) input [2:0]axi_ddr_awprot;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_ddr AWQOS" *) input [3:0]axi_ddr_awqos;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_ddr AWREADY" *) output axi_ddr_awready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_ddr AWSIZE" *) input [2:0]axi_ddr_awsize;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_ddr AWUSER" *) input axi_ddr_awuser;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_ddr AWVALID" *) input axi_ddr_awvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_ddr BID" *) output [5:0]axi_ddr_bid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_ddr BREADY" *) input axi_ddr_bready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_ddr BRESP" *) output [1:0]axi_ddr_bresp;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_ddr BVALID" *) output axi_ddr_bvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_ddr RDATA" *) output [127:0]axi_ddr_rdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_ddr RID" *) output [5:0]axi_ddr_rid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_ddr RLAST" *) output axi_ddr_rlast;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_ddr RREADY" *) input axi_ddr_rready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_ddr RRESP" *) output [1:0]axi_ddr_rresp;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_ddr RVALID" *) output axi_ddr_rvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_ddr WDATA" *) input [127:0]axi_ddr_wdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_ddr WLAST" *) input axi_ddr_wlast;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_ddr WREADY" *) output axi_ddr_wready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_ddr WSTRB" *) input [15:0]axi_ddr_wstrb;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_ddr WVALID" *) input axi_ddr_wvalid;
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.CLK_100M CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.CLK_100M, ASSOCIATED_BUSIF axi_ddr, ASSOCIATED_RESET rst_n, CLK_DOMAIN ps_block_zynq_ultra_ps_e_0_0_pl_clk0, FREQ_HZ 233333338, PHASE 0.000" *) output clk_100m;
  (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 ps_rvram ADDR" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME ps_rvram, MASTER_TYPE BRAM_CTRL, MEM_ECC NONE, MEM_SIZE 4096, MEM_WIDTH 32, READ_WRITE_MODE READ_WRITE" *) output [11:0]ps_rvram_addr;
  (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 ps_rvram CLK" *) output ps_rvram_clk;
  (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 ps_rvram DIN" *) output [31:0]ps_rvram_din;
  (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 ps_rvram DOUT" *) input [31:0]ps_rvram_dout;
  (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 ps_rvram EN" *) output ps_rvram_en;
  (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 ps_rvram RST" *) output ps_rvram_rst;
  (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 ps_rvram WE" *) output [3:0]ps_rvram_we;
  (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 RST.RST_N RST" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME RST.RST_N, POLARITY ACTIVE_LOW" *) output rst_n;

  wire [48:0]axi_ddr_1_ARADDR;
  wire [1:0]axi_ddr_1_ARBURST;
  wire [3:0]axi_ddr_1_ARCACHE;
  wire [5:0]axi_ddr_1_ARID;
  wire [7:0]axi_ddr_1_ARLEN;
  wire axi_ddr_1_ARLOCK;
  wire [2:0]axi_ddr_1_ARPROT;
  wire [3:0]axi_ddr_1_ARQOS;
  wire axi_ddr_1_ARREADY;
  wire [2:0]axi_ddr_1_ARSIZE;
  wire axi_ddr_1_ARUSER;
  wire axi_ddr_1_ARVALID;
  wire [48:0]axi_ddr_1_AWADDR;
  wire [1:0]axi_ddr_1_AWBURST;
  wire [3:0]axi_ddr_1_AWCACHE;
  wire [5:0]axi_ddr_1_AWID;
  wire [7:0]axi_ddr_1_AWLEN;
  wire axi_ddr_1_AWLOCK;
  wire [2:0]axi_ddr_1_AWPROT;
  wire [3:0]axi_ddr_1_AWQOS;
  wire axi_ddr_1_AWREADY;
  wire [2:0]axi_ddr_1_AWSIZE;
  wire axi_ddr_1_AWUSER;
  wire axi_ddr_1_AWVALID;
  wire [5:0]axi_ddr_1_BID;
  wire axi_ddr_1_BREADY;
  wire [1:0]axi_ddr_1_BRESP;
  wire axi_ddr_1_BVALID;
  wire [127:0]axi_ddr_1_RDATA;
  wire [5:0]axi_ddr_1_RID;
  wire axi_ddr_1_RLAST;
  wire axi_ddr_1_RREADY;
  wire [1:0]axi_ddr_1_RRESP;
  wire axi_ddr_1_RVALID;
  wire [127:0]axi_ddr_1_WDATA;
  wire axi_ddr_1_WLAST;
  wire axi_ddr_1_WREADY;
  wire [15:0]axi_ddr_1_WSTRB;
  wire axi_ddr_1_WVALID;
  wire [11:0]bram_ctrl_BRAM_PORTA_ADDR;
  wire bram_ctrl_BRAM_PORTA_CLK;
  wire [31:0]bram_ctrl_BRAM_PORTA_DIN;
  wire [31:0]bram_ctrl_BRAM_PORTA_DOUT;
  wire bram_ctrl_BRAM_PORTA_EN;
  wire bram_ctrl_BRAM_PORTA_RST;
  wire [3:0]bram_ctrl_BRAM_PORTA_WE;
  wire [0:0]rst_ps8_0_100M_peripheral_aresetn;
  wire [39:0]zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARADDR;
  wire [1:0]zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARBURST;
  wire [3:0]zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARCACHE;
  wire [15:0]zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARID;
  wire [7:0]zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARLEN;
  wire zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARLOCK;
  wire [2:0]zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARPROT;
  wire zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARREADY;
  wire [2:0]zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARSIZE;
  wire zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARVALID;
  wire [39:0]zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWADDR;
  wire [1:0]zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWBURST;
  wire [3:0]zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWCACHE;
  wire [15:0]zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWID;
  wire [7:0]zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWLEN;
  wire zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWLOCK;
  wire [2:0]zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWPROT;
  wire zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWREADY;
  wire [2:0]zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWSIZE;
  wire zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWVALID;
  wire [15:0]zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_BID;
  wire zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_BREADY;
  wire [1:0]zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_BRESP;
  wire zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_BVALID;
  wire [31:0]zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_RDATA;
  wire [15:0]zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_RID;
  wire zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_RLAST;
  wire zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_RREADY;
  wire [1:0]zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_RRESP;
  wire zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_RVALID;
  wire [31:0]zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_WDATA;
  wire zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_WLAST;
  wire zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_WREADY;
  wire [3:0]zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_WSTRB;
  wire zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_WVALID;
  wire zynq_ultra_ps_e_0_pl_clk0;
  wire zynq_ultra_ps_e_0_pl_resetn0;

  assign axi_ddr_1_ARADDR = axi_ddr_araddr[48:0];
  assign axi_ddr_1_ARBURST = axi_ddr_arburst[1:0];
  assign axi_ddr_1_ARCACHE = axi_ddr_arcache[3:0];
  assign axi_ddr_1_ARID = axi_ddr_arid[5:0];
  assign axi_ddr_1_ARLEN = axi_ddr_arlen[7:0];
  assign axi_ddr_1_ARLOCK = axi_ddr_arlock;
  assign axi_ddr_1_ARPROT = axi_ddr_arprot[2:0];
  assign axi_ddr_1_ARQOS = axi_ddr_arqos[3:0];
  assign axi_ddr_1_ARSIZE = axi_ddr_arsize[2:0];
  assign axi_ddr_1_ARUSER = axi_ddr_aruser;
  assign axi_ddr_1_ARVALID = axi_ddr_arvalid;
  assign axi_ddr_1_AWADDR = axi_ddr_awaddr[48:0];
  assign axi_ddr_1_AWBURST = axi_ddr_awburst[1:0];
  assign axi_ddr_1_AWCACHE = axi_ddr_awcache[3:0];
  assign axi_ddr_1_AWID = axi_ddr_awid[5:0];
  assign axi_ddr_1_AWLEN = axi_ddr_awlen[7:0];
  assign axi_ddr_1_AWLOCK = axi_ddr_awlock;
  assign axi_ddr_1_AWPROT = axi_ddr_awprot[2:0];
  assign axi_ddr_1_AWQOS = axi_ddr_awqos[3:0];
  assign axi_ddr_1_AWSIZE = axi_ddr_awsize[2:0];
  assign axi_ddr_1_AWUSER = axi_ddr_awuser;
  assign axi_ddr_1_AWVALID = axi_ddr_awvalid;
  assign axi_ddr_1_BREADY = axi_ddr_bready;
  assign axi_ddr_1_RREADY = axi_ddr_rready;
  assign axi_ddr_1_WDATA = axi_ddr_wdata[127:0];
  assign axi_ddr_1_WLAST = axi_ddr_wlast;
  assign axi_ddr_1_WSTRB = axi_ddr_wstrb[15:0];
  assign axi_ddr_1_WVALID = axi_ddr_wvalid;
  assign axi_ddr_arready = axi_ddr_1_ARREADY;
  assign axi_ddr_awready = axi_ddr_1_AWREADY;
  assign axi_ddr_bid[5:0] = axi_ddr_1_BID;
  assign axi_ddr_bresp[1:0] = axi_ddr_1_BRESP;
  assign axi_ddr_bvalid = axi_ddr_1_BVALID;
  assign axi_ddr_rdata[127:0] = axi_ddr_1_RDATA;
  assign axi_ddr_rid[5:0] = axi_ddr_1_RID;
  assign axi_ddr_rlast = axi_ddr_1_RLAST;
  assign axi_ddr_rresp[1:0] = axi_ddr_1_RRESP;
  assign axi_ddr_rvalid = axi_ddr_1_RVALID;
  assign axi_ddr_wready = axi_ddr_1_WREADY;
  assign bram_ctrl_BRAM_PORTA_DOUT = ps_rvram_dout[31:0];
  assign clk_100m = zynq_ultra_ps_e_0_pl_clk0;
  assign ps_rvram_addr[11:0] = bram_ctrl_BRAM_PORTA_ADDR;
  assign ps_rvram_clk = bram_ctrl_BRAM_PORTA_CLK;
  assign ps_rvram_din[31:0] = bram_ctrl_BRAM_PORTA_DIN;
  assign ps_rvram_en = bram_ctrl_BRAM_PORTA_EN;
  assign ps_rvram_rst = bram_ctrl_BRAM_PORTA_RST;
  assign ps_rvram_we[3:0] = bram_ctrl_BRAM_PORTA_WE;
  assign rst_n = zynq_ultra_ps_e_0_pl_resetn0;
  ps_block_axi_bram_ctrl_0_0 bram_ctrl
       (.bram_addr_a(bram_ctrl_BRAM_PORTA_ADDR),
        .bram_clk_a(bram_ctrl_BRAM_PORTA_CLK),
        .bram_en_a(bram_ctrl_BRAM_PORTA_EN),
        .bram_rddata_a(bram_ctrl_BRAM_PORTA_DOUT),
        .bram_rst_a(bram_ctrl_BRAM_PORTA_RST),
        .bram_we_a(bram_ctrl_BRAM_PORTA_WE),
        .bram_wrdata_a(bram_ctrl_BRAM_PORTA_DIN),
        .s_axi_aclk(zynq_ultra_ps_e_0_pl_clk0),
        .s_axi_araddr(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARADDR[11:0]),
        .s_axi_arburst(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARBURST),
        .s_axi_arcache(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARCACHE),
        .s_axi_aresetn(rst_ps8_0_100M_peripheral_aresetn),
        .s_axi_arid(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARID),
        .s_axi_arlen(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARLEN),
        .s_axi_arlock(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARLOCK),
        .s_axi_arprot(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARPROT),
        .s_axi_arready(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARREADY),
        .s_axi_arsize(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARSIZE),
        .s_axi_arvalid(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARVALID),
        .s_axi_awaddr(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWADDR[11:0]),
        .s_axi_awburst(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWBURST),
        .s_axi_awcache(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWCACHE),
        .s_axi_awid(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWID),
        .s_axi_awlen(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWLEN),
        .s_axi_awlock(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWLOCK),
        .s_axi_awprot(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWPROT),
        .s_axi_awready(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWREADY),
        .s_axi_awsize(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWSIZE),
        .s_axi_awvalid(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWVALID),
        .s_axi_bid(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_BID),
        .s_axi_bready(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_BREADY),
        .s_axi_bresp(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_BRESP),
        .s_axi_bvalid(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_BVALID),
        .s_axi_rdata(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_RDATA),
        .s_axi_rid(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_RID),
        .s_axi_rlast(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_RLAST),
        .s_axi_rready(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_RREADY),
        .s_axi_rresp(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_RRESP),
        .s_axi_rvalid(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_RVALID),
        .s_axi_wdata(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_WDATA),
        .s_axi_wlast(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_WLAST),
        .s_axi_wready(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_WREADY),
        .s_axi_wstrb(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_WSTRB),
        .s_axi_wvalid(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_WVALID));
  ps_block_rst_ps8_0_100M_0 rst_ps8_0_100M
       (.aux_reset_in(1'b1),
        .dcm_locked(1'b1),
        .ext_reset_in(zynq_ultra_ps_e_0_pl_resetn0),
        .mb_debug_sys_rst(1'b0),
        .peripheral_aresetn(rst_ps8_0_100M_peripheral_aresetn),
        .slowest_sync_clk(zynq_ultra_ps_e_0_pl_clk0));
  ps_block_zynq_ultra_ps_e_0_0 zynq_ultra_ps_e_0
       (.maxigp0_araddr(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARADDR),
        .maxigp0_arburst(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARBURST),
        .maxigp0_arcache(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARCACHE),
        .maxigp0_arid(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARID),
        .maxigp0_arlen(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARLEN),
        .maxigp0_arlock(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARLOCK),
        .maxigp0_arprot(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARPROT),
        .maxigp0_arready(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARREADY),
        .maxigp0_arsize(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARSIZE),
        .maxigp0_arvalid(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARVALID),
        .maxigp0_awaddr(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWADDR),
        .maxigp0_awburst(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWBURST),
        .maxigp0_awcache(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWCACHE),
        .maxigp0_awid(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWID),
        .maxigp0_awlen(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWLEN),
        .maxigp0_awlock(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWLOCK),
        .maxigp0_awprot(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWPROT),
        .maxigp0_awready(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWREADY),
        .maxigp0_awsize(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWSIZE),
        .maxigp0_awvalid(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWVALID),
        .maxigp0_bid(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_BID),
        .maxigp0_bready(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_BREADY),
        .maxigp0_bresp(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_BRESP),
        .maxigp0_bvalid(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_BVALID),
        .maxigp0_rdata(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_RDATA),
        .maxigp0_rid(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_RID),
        .maxigp0_rlast(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_RLAST),
        .maxigp0_rready(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_RREADY),
        .maxigp0_rresp(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_RRESP),
        .maxigp0_rvalid(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_RVALID),
        .maxigp0_wdata(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_WDATA),
        .maxigp0_wlast(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_WLAST),
        .maxigp0_wready(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_WREADY),
        .maxigp0_wstrb(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_WSTRB),
        .maxigp0_wvalid(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_WVALID),
        .maxihpm0_fpd_aclk(zynq_ultra_ps_e_0_pl_clk0),
        .pl_clk0(zynq_ultra_ps_e_0_pl_clk0),
        .pl_resetn0(zynq_ultra_ps_e_0_pl_resetn0),
        .saxigp2_araddr(axi_ddr_1_ARADDR),
        .saxigp2_arburst(axi_ddr_1_ARBURST),
        .saxigp2_arcache(axi_ddr_1_ARCACHE),
        .saxigp2_arid(axi_ddr_1_ARID),
        .saxigp2_arlen(axi_ddr_1_ARLEN),
        .saxigp2_arlock(axi_ddr_1_ARLOCK),
        .saxigp2_arprot(axi_ddr_1_ARPROT),
        .saxigp2_arqos(axi_ddr_1_ARQOS),
        .saxigp2_arready(axi_ddr_1_ARREADY),
        .saxigp2_arsize(axi_ddr_1_ARSIZE),
        .saxigp2_aruser(axi_ddr_1_ARUSER),
        .saxigp2_arvalid(axi_ddr_1_ARVALID),
        .saxigp2_awaddr(axi_ddr_1_AWADDR),
        .saxigp2_awburst(axi_ddr_1_AWBURST),
        .saxigp2_awcache(axi_ddr_1_AWCACHE),
        .saxigp2_awid(axi_ddr_1_AWID),
        .saxigp2_awlen(axi_ddr_1_AWLEN),
        .saxigp2_awlock(axi_ddr_1_AWLOCK),
        .saxigp2_awprot(axi_ddr_1_AWPROT),
        .saxigp2_awqos(axi_ddr_1_AWQOS),
        .saxigp2_awready(axi_ddr_1_AWREADY),
        .saxigp2_awsize(axi_ddr_1_AWSIZE),
        .saxigp2_awuser(axi_ddr_1_AWUSER),
        .saxigp2_awvalid(axi_ddr_1_AWVALID),
        .saxigp2_bid(axi_ddr_1_BID),
        .saxigp2_bready(axi_ddr_1_BREADY),
        .saxigp2_bresp(axi_ddr_1_BRESP),
        .saxigp2_bvalid(axi_ddr_1_BVALID),
        .saxigp2_rdata(axi_ddr_1_RDATA),
        .saxigp2_rid(axi_ddr_1_RID),
        .saxigp2_rlast(axi_ddr_1_RLAST),
        .saxigp2_rready(axi_ddr_1_RREADY),
        .saxigp2_rresp(axi_ddr_1_RRESP),
        .saxigp2_rvalid(axi_ddr_1_RVALID),
        .saxigp2_wdata(axi_ddr_1_WDATA),
        .saxigp2_wlast(axi_ddr_1_WLAST),
        .saxigp2_wready(axi_ddr_1_WREADY),
        .saxigp2_wstrb(axi_ddr_1_WSTRB),
        .saxigp2_wvalid(axi_ddr_1_WVALID),
        .saxihp0_fpd_aclk(zynq_ultra_ps_e_0_pl_clk0));
endmodule
