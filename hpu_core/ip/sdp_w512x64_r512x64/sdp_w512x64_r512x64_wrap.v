`timescale 1ns / 1ps

module sdp_w512x64_r512x64_wrap (
    input           wr_clk_i,
    input           we_i,
    input [8:0]     waddr_i,
    input [63:0]    wdata_i,
    input [7:0]     wdata_strob_i,
    input           rd_clk_i,
    input           re_i,
    input [8:0]     raddr_i,
    output[63:0]    rdata_o
);

sdp_w512x64_r512x64 sdp_w512x64_r512x64_inst (
    .clka           (wr_clk_i),
    .ena            (1'b1),
    .wea            ({8{we_i}} & wdata_strob_i),
    .addra          (waddr_i),
    .dina           (wdata_i),
    .clkb           (rd_clk_i),
    .enb            (1'b1),
    .addrb          (raddr_i),
    .doutb          (rdata_o)
);

endmodule

