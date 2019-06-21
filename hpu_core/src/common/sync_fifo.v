// +FHDR------------------------------------------------------------------------
// XJTU IAIR Corporation All Rights Reserved
// -----------------------------------------------------------------------------
// FILE NAME  : sync_fifo.v
// DEPARTMENT : CAG of IAIR
// AUTHOR     : XXXX
// AUTHOR'S EMAIL :XXXX@mail.xjtu.edu.cn
// -----------------------------------------------------------------------------
// Ver 1.0  2019--01--01 initial version.
// -----------------------------------------------------------------------------
// KEYWORDS   : common, fifo,
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

module sync_fifo #(
    parameter FIFO_LEN = 16,
    parameter DATA_WTH = 8,
    parameter ADDR_WTH = 4,
    parameter FULL_ASSERT_VALUE = FIFO_LEN,
    parameter FULL_NEGATE_VALUE = FIFO_LEN,
    parameter EMPTY_ASSERT_VALUE = 0,
    parameter EMPTY_NEGATE_VALUE = 0
) (
    // clock & reset
    input                               clk_i,
    input                               rst_i,
    // write interface
    input [DATA_WTH-1 : 0]              wr_data_i,
    input                               wr_en_i,
    output                              full_o,
    output                              a_full_o,
    // read interface
    output[DATA_WTH-1 : 0]              rd_data_o,
    input                               rd_en_i,
    output                              empty_o,
    output                              a_empty_o
);

//=============================================================================
// variables declaration
//=============================================================================
reg   [DATA_WTH-1 : 0]          mem[0 : FIFO_LEN-1];
wire                            wr_en;
reg   [ADDR_WTH : 0]            wr_addr;
reg                             wr_mark;
wire                            rd_en;
reg   [ADDR_WTH : 0]            rd_addr;
reg                             rd_mark;
wire                            empty, full;
reg                             a_empty, a_full;

//=============================================================================
// instance
//=============================================================================
// write logic
assign wr_en = wr_en_i & (~full);

always @(posedge clk_i) begin
    if(rst_i) begin
        wr_addr <= {(ADDR_WTH+1){1'b0}};
        wr_mark <= 1'b0;
    end else begin
        if(wr_en) begin
            if(wr_addr == FIFO_LEN - 1'b1) begin
                wr_addr <= {(ADDR_WTH+1){1'b0}};
                wr_mark <= ~wr_mark;
            end else begin
                wr_addr <= wr_addr + 'h1;
            end
            mem[wr_addr[ADDR_WTH-1:0]] <= wr_data_i;
        end
    end
end

// read logic
assign rd_en = rd_en_i & (~empty);
always @(posedge clk_i) begin
    if(rst_i) begin
        rd_addr <= {(ADDR_WTH+1){1'b0}};
        rd_mark <= 1'b0;
    end else begin
        if(rd_en) begin
            if(rd_addr == FIFO_LEN - 1'b1) begin
                rd_addr <= {(ADDR_WTH+1){1'b0}};
                rd_mark <= ~rd_mark;
            end else begin
                rd_addr <= rd_addr + 'h1;
            end
        end
    end
end
assign rd_data_o = mem[rd_addr[ADDR_WTH-1:0]];

// full/empty signal logic
assign empty = (wr_addr == rd_addr) && (wr_mark == rd_mark);
assign full = (wr_addr == rd_addr) && (wr_mark != rd_mark);

assign empty_o = empty;
assign full_o = full;

// almost full/empty signal logic
always @(posedge clk_i) begin
    if(rst_i) begin
        a_empty <= 1'b1;
        a_full <= 1'b0;
    end else begin
        if(rd_en & (~wr_en)) begin
            if(wr_addr < rd_addr) begin
                if(wr_addr + FIFO_LEN - rd_addr == EMPTY_ASSERT_VALUE + 1'b1)
                    a_empty <= 1'b1;
                if(wr_addr + FIFO_LEN - rd_addr == FULL_NEGATE_VALUE)
                    a_full <= 1'b0;
            end else begin
                if(wr_addr - rd_addr == EMPTY_ASSERT_VALUE + 1'b1)
                    a_empty <= 1'b1;
                if(wr_addr - rd_addr == FULL_NEGATE_VALUE)
                    a_full <= 1'b0;
            end
        end else if((~rd_en) & wr_en) begin
            if(wr_addr < rd_addr) begin
                if(wr_addr + FIFO_LEN - rd_addr == EMPTY_NEGATE_VALUE)
                    a_empty <= 1'b0;
                if(wr_addr + FIFO_LEN - rd_addr == FULL_ASSERT_VALUE - 1'b1)
                    a_full <= 1'b1;
            end else begin
                if(wr_addr - rd_addr == EMPTY_NEGATE_VALUE)
                    a_empty <= 1'b0;
                if(wr_addr - rd_addr == FULL_ASSERT_VALUE - 1'b1)
                    a_full <= 1'b1;
            end
        end
    end
end

assign a_empty_o = a_empty;
assign a_full_o = a_full;

endmodule
