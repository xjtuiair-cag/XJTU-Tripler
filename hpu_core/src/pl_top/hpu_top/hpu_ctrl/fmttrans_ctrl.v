// +FHDR------------------------------------------------------------------------
// XJTU IAIR Corporation All Rights Reserved
// -----------------------------------------------------------------------------
// FILE NAME  : fmttrans_ctrl.v
// DEPARTMENT : CAG of IAIR
// AUTHOR     : XXXX
// AUTHOR'S EMAIL :XXXX@mail.xjtu.edu.cn
// -----------------------------------------------------------------------------
// Ver 1.0  2019--01--01 initial version.
// -----------------------------------------------------------------------------
// KEYWORDS   : data trans, controlling,
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

module fmttrans_ctrl #(
    parameter REGMAP_ADDR_WTH = 8,
    parameter REGMAP_DATA_WTH = 32,
    parameter MRX_IND_WTH = 5,
    parameter MRX_ADDR_WTH = 9
) (
    // clock & reset
    input                                   clk_i,
    input                                   rst_i,

    // from register_map module
    input [REGMAP_ADDR_WTH-1 : 0]           regmap_ftrans__waddr_i,
    input [REGMAP_DATA_WTH-1 : 0]           regmap_ftrans__wdata_i,
    input                                   regmap_ftrans__we_i,
    output                                  regmap_ftrans__intr_o,

    // to vputy_ctrl module
    output[4 : 0]                           ftransctl_vputy__code_o,
    output[MRX_IND_WTH-1 : 0]               ftransctl_vputy__mrs0_index_o,
    output[MRX_ADDR_WTH-1 : 0]              ftransctl_vputy__mrs0_addr_o,
    output[5 : 0]                           ftransctl_vputy__sv_code_o,
    output[2 : 0]                           ftransctl_vputy__mtx_sel_h_o,
    output[MRX_IND_WTH-1 : 0]               ftransctl_vputy__mrd_index_o,
    output[MRX_ADDR_WTH-1 : 0]              ftransctl_vputy__mrd_addr_o,
    output[7 : 0]                           ftransctl_vputy__strobe_h_o
);

//======================================================================================================================
// Wire & Reg declaration
//======================================================================================================================
localparam SET_START = 0;
localparam CLR_INTR = 1;

localparam OP_LOAD = 5'b00001;
localparam OP_MUL  = 5'b00011;
localparam OP_ACC  = 5'b00101;
localparam OP_MACC = 5'b00111;
localparam OP_MAX  = 5'b10101;
localparam OP_LDSL = 5'b01001;
localparam OP_LDSR = 5'b11001;

localparam EN_ACT  = 0;
localparam EN_SEL  = 1;
localparam EN_BIAS = 2;
localparam EN_RELU = 3;
localparam EN_SHFL = 4;
localparam EN_CHPRI = 5;

localparam ST_IDLE = 3'h0;
localparam ST_TRANS = 3'h1;
localparam ST_WAIT_TRANS = 3'h2;
localparam ST_DONE = 3'h3;

reg   [7 : 0]                           src_step;
reg   [7 : 0]                           src_sect_step;
reg   [7 : 0]                           dest_step;
reg   [7 : 0]                           dest_sect_step;
reg   [7 : 0]                           sect_num;
reg   [MRX_IND_WTH-1 : 0]               src_mr_index;
reg   [MRX_ADDR_WTH-1 : 0]              src_mr_addr;
reg   [MRX_IND_WTH-1 : 0]               dest_mr_index;
reg   [MRX_ADDR_WTH-1 : 0]              dest_mr_addr;

reg                                     mcu_set_start;
reg                                     mcu_clr_intr;

reg   [7 : 0]                           src_step_reg;
reg   [7 : 0]                           src_sect_step_reg;
reg   [7 : 0]                           dest_step_reg;
reg   [7 : 0]                           dest_sect_step_reg;
reg   [7 : 0]                           sect_num_reg;
reg   [MRX_IND_WTH-1 : 0]               src_mr_index_reg;
reg   [MRX_ADDR_WTH-1 : 0]              src_mr_addr_reg;
reg   [MRX_IND_WTH-1 : 0]               dest_mr_index_reg;
reg   [MRX_ADDR_WTH-1 : 0]              dest_mr_addr_reg;

reg   [2 : 0]                           cur_st;
reg   [2 : 0]                           next_st;
reg   [7 : 0]                           sect_cnt;
reg   [2 : 0]                           sect_ld_cnt;
reg   [2 : 0]                           sect_sv_cnt;
reg   [4 : 0]                           wait_trans_cnt;

reg                                     ftrans_intr;
wire  [7 : 0]                           sv_strobe_h;

wire                                    update_sect_ld_sig;
wire                                    update_sect_sig;

reg   [MRX_ADDR_WTH-1 : 0]              src_base_addr;
reg   [MRX_ADDR_WTH-1 : 0]              src_addr;

reg   [MRX_ADDR_WTH-1 : 0]              dest_base_addr;
reg   [MRX_ADDR_WTH-1 : 0]              dest_addr;

//======================================================================================================================
// Instance
//======================================================================================================================

// register map of conv_ctrl
always @(posedge clk_i) begin
    if(rst_i) begin
        src_step <= 8'h0;
        src_sect_step <= 8'h0;
        dest_step <= 8'h0;
        dest_sect_step <= 8'h0;
        sect_num <= 8'h0;
        src_mr_index <= {MRX_IND_WTH{1'b0}};
        src_mr_addr <= {MRX_ADDR_WTH{1'b0}};
        dest_mr_index <= {MRX_IND_WTH{1'b0}};
        dest_mr_addr <= {MRX_ADDR_WTH{1'b0}};
    end else if(regmap_ftrans__we_i) begin
        if(regmap_ftrans__waddr_i[REGMAP_ADDR_WTH-1 : 2] ==  'h1) src_step <= regmap_ftrans__wdata_i[7 : 0];
        if(regmap_ftrans__waddr_i[REGMAP_ADDR_WTH-1 : 2] ==  'h1) src_sect_step <= regmap_ftrans__wdata_i[15 : 8];
        if(regmap_ftrans__waddr_i[REGMAP_ADDR_WTH-1 : 2] ==  'h1) dest_step <= regmap_ftrans__wdata_i[23 : 16];
        if(regmap_ftrans__waddr_i[REGMAP_ADDR_WTH-1 : 2] ==  'h1) dest_sect_step <= regmap_ftrans__wdata_i[31 : 24];
        if(regmap_ftrans__waddr_i[REGMAP_ADDR_WTH-1 : 2] ==  'h2) sect_num <= regmap_ftrans__wdata_i[7 : 0];
        if(regmap_ftrans__waddr_i[REGMAP_ADDR_WTH-1 : 2] ==  'h3) src_mr_addr <= regmap_ftrans__wdata_i[0 +: MRX_ADDR_WTH];
        if(regmap_ftrans__waddr_i[REGMAP_ADDR_WTH-1 : 2] ==  'h3) src_mr_index <= regmap_ftrans__wdata_i[MRX_ADDR_WTH +: MRX_IND_WTH];
        if(regmap_ftrans__waddr_i[REGMAP_ADDR_WTH-1 : 2] ==  'h4) dest_mr_addr <= regmap_ftrans__wdata_i[0 +: MRX_ADDR_WTH];
        if(regmap_ftrans__waddr_i[REGMAP_ADDR_WTH-1 : 2] ==  'h4) dest_mr_index <= regmap_ftrans__wdata_i[MRX_ADDR_WTH +: MRX_IND_WTH];
    end
end

// generate mcu control signal, such as: set_start, clr_intr.
// store the copy of all parameters once receiving set_start signal.
always @(posedge clk_i) begin
    if(rst_i) begin
        mcu_set_start <= 1'b0;
        mcu_clr_intr <= 1'b0;
        src_step_reg <= 8'h0;
        src_sect_step_reg <= 8'h0;
        dest_step_reg <= 8'h0;
        dest_sect_step_reg <= 8'h0;
        sect_num_reg <= 8'h0;
        src_mr_index_reg <= {MRX_IND_WTH{1'b0}};
        src_mr_addr_reg <= {MRX_ADDR_WTH{1'b0}};
        dest_mr_index_reg <= {MRX_IND_WTH{1'b0}};
        dest_mr_addr_reg <= {MRX_ADDR_WTH{1'b0}};
    end else begin
        mcu_set_start <= 1'b0;
        mcu_clr_intr <= 1'b0;
        if(regmap_ftrans__we_i && (|regmap_ftrans__waddr_i == 1'b0)) begin
            if(regmap_ftrans__wdata_i[SET_START]) begin
                mcu_set_start <= 1'b1;
                src_step_reg <= src_step;
                src_sect_step_reg <= src_sect_step;
                dest_step_reg <= dest_step;
                dest_sect_step_reg <= dest_sect_step;
                sect_num_reg <= sect_num;
                src_mr_index_reg <= src_mr_index;
                src_mr_addr_reg <= src_mr_addr;
                dest_mr_index_reg <= dest_mr_index;
                dest_mr_addr_reg <= dest_mr_addr;
            end
            if(regmap_ftrans__wdata_i[CLR_INTR]) begin
                mcu_clr_intr <= 1'b1;
            end
        end
    end
end

// dtrans FSM
always @(posedge clk_i) begin
    if(rst_i) begin
        cur_st <= ST_IDLE;
    end else begin
        cur_st <= next_st;
    end
end

always @(*) begin
    next_st = cur_st;
    case(cur_st)
        ST_IDLE: begin
            if(mcu_set_start) begin
                next_st = ST_TRANS;
            end
        end
        ST_TRANS: begin
            if( (sect_cnt == sect_num_reg) && (&sect_ld_cnt) && (&sect_sv_cnt) ) begin
                next_st = ST_WAIT_TRANS;
            end
        end
        ST_WAIT_TRANS: begin
            if(wait_trans_cnt == 'h8) begin
                next_st = ST_DONE;
            end
        end
        ST_DONE: begin
            next_st = ST_IDLE;
        end
    endcase
end

always @(posedge clk_i) begin
    if(rst_i) begin
        sect_cnt <= 8'h0;
        sect_ld_cnt <= 3'h0;
        sect_sv_cnt <= 3'h0;
    end else begin
        if(cur_st == ST_TRANS) begin
            if(&sect_sv_cnt) begin
                if(&sect_ld_cnt) begin
                    sect_cnt <= sect_cnt + 1'b1;
                    sect_ld_cnt <= 3'h0;
                end else begin
                    sect_ld_cnt <= sect_ld_cnt + 1'b1;
                end
                sect_sv_cnt <= 3'h0;
            end else begin
                sect_sv_cnt <= sect_sv_cnt + 1'b1;
            end
        end else begin
            sect_cnt <= 8'h0;
            sect_ld_cnt <= 3'h0;
            sect_sv_cnt <= 3'h0;
        end
    end
end

always @(posedge clk_i) begin
    if(rst_i) begin
        wait_trans_cnt <= 5'h0;
    end else if(cur_st == ST_WAIT_TRANS) begin
        wait_trans_cnt <= wait_trans_cnt + 1'b1;
    end
end

// the interrupt signal
always @(posedge clk_i) begin
    if(rst_i) begin
        ftrans_intr <= 1'b0;
    end else begin
        if(cur_st == ST_DONE) begin
            ftrans_intr <= 1'b1;
        end else if(mcu_clr_intr) begin
            ftrans_intr <= 1'b0;
        end
    end
end
assign regmap_ftrans__intr_o = ftrans_intr;

// define some update signal to simplify expression.
assign update_sect_ld_sig = (sect_sv_cnt == 3'h7) && (cur_st == ST_TRANS);
assign update_sect_sig = (sect_ld_cnt == 3'h7) && update_sect_ld_sig;

// generate op_code
assign ftransctl_vputy__code_o[0] = (cur_st == ST_TRANS);
assign ftransctl_vputy__code_o[4:1] = 4'h0;

assign ftransctl_vputy__sv_code_o[EN_ACT] = ftransctl_vputy__code_o[0];
assign ftransctl_vputy__sv_code_o[EN_SEL] = 1'b1;
assign ftransctl_vputy__sv_code_o[EN_BIAS] = 1'b0;
assign ftransctl_vputy__sv_code_o[EN_RELU] = 1'b0;
assign ftransctl_vputy__sv_code_o[EN_SHFL] = 1'b0;
assign ftransctl_vputy__sv_code_o[EN_CHPRI] = 1'b0;

assign ftransctl_vputy__mtx_sel_h_o = sect_sv_cnt;
dec_bin_to_onehot #(3, 8) sv_strob_gen (sect_ld_cnt, sv_strobe_h);
assign ftransctl_vputy__strobe_h_o = sv_strobe_h;

// generate source addr/index
always @(posedge clk_i) begin
    if(cur_st == ST_TRANS) begin
        if(update_sect_ld_sig) begin
            if(update_sect_sig) begin
                src_addr <= src_base_addr + src_sect_step_reg;
                src_base_addr <= src_base_addr + src_sect_step_reg;
            end else begin
                src_addr <= src_addr + src_step_reg;
            end
        end
    end else begin
        src_addr <= src_mr_addr_reg;
        src_base_addr <= src_mr_addr_reg;
    end
end
assign ftransctl_vputy__mrs0_addr_o = src_addr;
assign ftransctl_vputy__mrs0_index_o = src_mr_index_reg;

// generate destiny addr/index
always @(posedge clk_i) begin
    if(cur_st == ST_TRANS) begin
        if(update_sect_ld_sig) begin
            if(update_sect_sig) begin
                dest_addr <= dest_base_addr + dest_sect_step_reg;
                dest_base_addr <= dest_base_addr + dest_sect_step_reg;
            end else begin
                dest_addr <= dest_base_addr;
            end
        end else begin
            dest_addr <= dest_addr + dest_step_reg;
        end
    end else begin
        dest_addr <= dest_mr_addr_reg;
        dest_base_addr <= dest_mr_addr_reg;
    end
end
assign ftransctl_vputy__mrd_addr_o = dest_addr;
assign ftransctl_vputy__mrd_index_o = dest_mr_index_reg;


//======================================================================================================================
// just for simulation
//======================================================================================================================
// synthesis translate_off

// synthesis translate_on

//======================================================================================================================
// probe signals
//======================================================================================================================

endmodule   

