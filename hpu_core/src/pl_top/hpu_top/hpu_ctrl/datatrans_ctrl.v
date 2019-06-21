// +FHDR------------------------------------------------------------------------
// XJTU IAIR Corporation All Rights Reserved
// -----------------------------------------------------------------------------
// FILE NAME  : datatrans_ctrl.v
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

module datatrans_ctrl #(
    parameter REGMAP_ADDR_WTH = 8,
    parameter REGMAP_DATA_WTH = 32,
    parameter MRX_IND_WTH = 5,
    parameter MRX_ADDR_WTH = 9
) (
    // clock & reset
    input                                   clk_i,
    input                                   rst_i,

    // from register_map module
    input [REGMAP_ADDR_WTH-1 : 0]           regmap_dtrans__waddr_i,
    input [REGMAP_DATA_WTH-1 : 0]           regmap_dtrans__wdata_i,
    input                                   regmap_dtrans__we_i,
    output                                  regmap_dtrans__intr_o,

    // to vputy_ctrl module
    output[4 : 0]                           dtransctl_vputy__code_o,
    output[MRX_IND_WTH-1 : 0]               dtransctl_vputy__mrs0_index_o,
    output[MRX_ADDR_WTH-1 : 0]              dtransctl_vputy__mrs0_addr_o,
    output[5 : 0]                           dtransctl_vputy__sv_code_o,
    output[0 : 0]                           dtransctl_vputy__shfl_o,
    output[MRX_IND_WTH-1 : 0]               dtransctl_vputy__mrd_index_o,
    output[MRX_ADDR_WTH-1 : 0]              dtransctl_vputy__mrd_addr_o,
    output[7 : 0]                           dtransctl_vputy__strobe_h_o
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
localparam ST_TRANS_FIRST_IN_BATCH_PH = 3'h1;
localparam ST_TRANS_LEFT_IN_BATCH_PH = 3'h2;
localparam ST_WAIT_TRANS = 3'h3;
localparam ST_DONE = 3'h4;

reg   [15 : 0]                          src_batch_size;
reg   [7 : 0]                           src_batch_num;
reg   [7 : 0]                           src_dilation;
reg   [15 : 0]                          dest_batch_size;
reg   [7 : 0]                           dest_batch_num;
reg   [7 : 0]                           dest_dilation;
reg   [7 : 0]                           mtx_strobe_h;
reg   [1 : 0]                           mtx_shift_v_type;
reg   [1 : 0]                           channel_shuffle_type;
reg                                     channel64_priority;
reg   [MRX_IND_WTH-1 : 0]               src_mr_index;
reg   [MRX_ADDR_WTH-1 : 0]              src_mr_addr;
reg   [MRX_IND_WTH-1 : 0]               dest_mr_index;
reg   [MRX_ADDR_WTH-1 : 0]              dest_mr_addr;

reg                                     mcu_set_start;
reg                                     mcu_clr_intr;
reg   [15 : 0]                          src_batch_size_reg;
reg   [7 : 0]                           src_batch_num_reg;
reg   [7 : 0]                           src_dilation_reg;
reg   [15 : 0]                          dest_batch_size_reg;
reg   [7 : 0]                           dest_batch_num_reg;
reg   [7 : 0]                           dest_dilation_reg;
reg   [7 : 0]                           mtx_strobe_h_reg;
reg   [1 : 0]                           mtx_shift_v_type_reg;
reg   [1 : 0]                           channel_shuffle_type_reg;
reg                                     channel64_priority_reg;
reg   [MRX_IND_WTH-1 : 0]               src_mr_index_reg;
reg   [MRX_ADDR_WTH-1 : 0]              src_mr_addr_reg;
reg   [MRX_IND_WTH-1 : 0]               dest_mr_index_reg;
reg   [MRX_ADDR_WTH-1 : 0]              dest_mr_addr_reg;

reg   [2 : 0]                           cur_st;
reg   [2 : 0]                           next_st;

reg   [0 : 0]                           shfl_cnt;
reg   [15 : 0]                          dot_cnt;
reg   [7 : 0]                           batch_cnt;
reg   [4 : 0]                           wait_trans_cnt;

reg                                     dtrans_intr;

wire                                    update_dot_sig;
wire                                    update_batch_sig;

reg   [MRX_ADDR_WTH-1 : 0]              src_addr;

reg   [15 : 0]                          dest_dot_cnt;
reg   [7 : 0]                           dest_batch_cnt;

wire                                    update_dest_batch_sig;
reg   [MRX_ADDR_WTH-1 : 0]              dest_addr;

//======================================================================================================================
// Instance
//======================================================================================================================

// register map of conv_ctrl
always @(posedge clk_i) begin
    if(rst_i) begin
        src_batch_size <= 16'h0;
        src_batch_num <= 8'h0;
        src_dilation <= 8'h0;
        dest_batch_size <= 16'h0;
        dest_batch_num <= 8'h0;
        dest_dilation <= 8'h0;
        mtx_strobe_h <= 8'h0;
        mtx_shift_v_type <= 2'h0;
        channel_shuffle_type <= 2'h0;
        channel64_priority <= 1'b0;
        src_mr_index <= {MRX_IND_WTH{1'b0}};
        src_mr_addr <= {MRX_ADDR_WTH{1'b0}};
        dest_mr_index <= {MRX_IND_WTH{1'b0}};
        dest_mr_addr <= {MRX_ADDR_WTH{1'b0}};
    end else if(regmap_dtrans__we_i) begin
        if(regmap_dtrans__waddr_i[REGMAP_ADDR_WTH-1 : 2] ==  'h1) src_batch_size <= regmap_dtrans__wdata_i[15 : 0];
        if(regmap_dtrans__waddr_i[REGMAP_ADDR_WTH-1 : 2] ==  'h1) src_batch_num <= regmap_dtrans__wdata_i[23 : 16];
        if(regmap_dtrans__waddr_i[REGMAP_ADDR_WTH-1 : 2] ==  'h1) src_dilation <= regmap_dtrans__wdata_i[31 : 24];
        if(regmap_dtrans__waddr_i[REGMAP_ADDR_WTH-1 : 2] ==  'h2) dest_batch_size <= regmap_dtrans__wdata_i[15 : 0];
        if(regmap_dtrans__waddr_i[REGMAP_ADDR_WTH-1 : 2] ==  'h2) dest_batch_num <= regmap_dtrans__wdata_i[23 : 16];
        if(regmap_dtrans__waddr_i[REGMAP_ADDR_WTH-1 : 2] ==  'h2) dest_dilation <= regmap_dtrans__wdata_i[31 : 24];
        if(regmap_dtrans__waddr_i[REGMAP_ADDR_WTH-1 : 2] ==  'h3) mtx_strobe_h <= regmap_dtrans__wdata_i[7 : 0];
        if(regmap_dtrans__waddr_i[REGMAP_ADDR_WTH-1 : 2] ==  'h3) mtx_shift_v_type <= regmap_dtrans__wdata_i[9 : 8];
        if(regmap_dtrans__waddr_i[REGMAP_ADDR_WTH-1 : 2] ==  'h3) channel_shuffle_type <= regmap_dtrans__wdata_i[17 : 16];
        if(regmap_dtrans__waddr_i[REGMAP_ADDR_WTH-1 : 2] ==  'h3) channel64_priority <= regmap_dtrans__wdata_i[18 : 18];
        if(regmap_dtrans__waddr_i[REGMAP_ADDR_WTH-1 : 2] ==  'h4) src_mr_addr <= regmap_dtrans__wdata_i[0 +: MRX_ADDR_WTH];
        if(regmap_dtrans__waddr_i[REGMAP_ADDR_WTH-1 : 2] ==  'h4) src_mr_index <= regmap_dtrans__wdata_i[MRX_ADDR_WTH +: MRX_IND_WTH];
        if(regmap_dtrans__waddr_i[REGMAP_ADDR_WTH-1 : 2] ==  'h5) dest_mr_addr <= regmap_dtrans__wdata_i[0 +: MRX_ADDR_WTH];
        if(regmap_dtrans__waddr_i[REGMAP_ADDR_WTH-1 : 2] ==  'h5) dest_mr_index <= regmap_dtrans__wdata_i[MRX_ADDR_WTH +: MRX_IND_WTH];
    end
end

// generate mcu control signal, such as: set_start, clr_intr.
// store the copy of all parameters once receiving set_start signal.
always @(posedge clk_i) begin
    if(rst_i) begin
        mcu_set_start <= 1'b0;
        mcu_clr_intr <= 1'b0;
        src_batch_size_reg <= 16'h0;
        src_batch_num_reg <= 8'h0;
        src_dilation_reg <= 8'h0;
        dest_batch_size_reg <= 16'h0;
        dest_batch_num_reg <= 8'h0;
        dest_dilation_reg <= 8'h0;
        mtx_strobe_h_reg <= 8'h0;
        mtx_shift_v_type_reg <= 2'h0;
        channel_shuffle_type_reg <= 2'h0;
        channel64_priority_reg <= 1'b0;
        src_mr_index_reg <= {MRX_IND_WTH{1'b0}};
        src_mr_addr_reg <= {MRX_ADDR_WTH{1'b0}};
        dest_mr_index_reg <= {MRX_IND_WTH{1'b0}};
        dest_mr_addr_reg <= {MRX_ADDR_WTH{1'b0}};
    end else begin
        mcu_set_start <= 1'b0;
        mcu_clr_intr <= 1'b0;
        if(regmap_dtrans__we_i && (|regmap_dtrans__waddr_i == 1'b0)) begin
            if(regmap_dtrans__wdata_i[SET_START]) begin
                mcu_set_start <= 1'b1;
                src_batch_size_reg <= src_batch_size;
                src_batch_num_reg <= src_batch_num;
                src_dilation_reg <= src_dilation;
                dest_batch_size_reg <= dest_batch_size;
                dest_batch_num_reg <= dest_batch_num;
                dest_dilation_reg <= dest_dilation;
                mtx_strobe_h_reg <= mtx_strobe_h;
                mtx_shift_v_type_reg <= mtx_shift_v_type;
                channel_shuffle_type_reg <= channel_shuffle_type;
                channel64_priority_reg <= channel64_priority;
                src_mr_index_reg <= src_mr_index;
                src_mr_addr_reg <= src_mr_addr;
                dest_mr_index_reg <= dest_mr_index;
                dest_mr_addr_reg <= dest_mr_addr;
            end
            if(regmap_dtrans__wdata_i[CLR_INTR]) begin
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
                next_st = ST_TRANS_FIRST_IN_BATCH_PH;
            end
        end
        ST_TRANS_FIRST_IN_BATCH_PH: begin
            if( (channel_shuffle_type_reg[0] == 1'b0) && (src_batch_size_reg == 16'h0) ) begin
                if(batch_cnt == src_batch_num_reg) begin
                    next_st = ST_WAIT_TRANS;
                end else begin
                    next_st = ST_TRANS_FIRST_IN_BATCH_PH;
                end
            end else begin
                next_st = ST_TRANS_LEFT_IN_BATCH_PH;
            end
        end
        ST_TRANS_LEFT_IN_BATCH_PH: begin
            if( (shfl_cnt == channel_shuffle_type_reg[0]) && (dot_cnt == src_batch_size_reg) ) begin
                if(batch_cnt == src_batch_num_reg) begin
                    next_st = ST_WAIT_TRANS;
                end else begin
                    next_st = ST_TRANS_FIRST_IN_BATCH_PH;
                end
            end
        end
        ST_WAIT_TRANS: begin
            if(wait_trans_cnt == 'he) begin
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
        shfl_cnt <= 1'h0;
        dot_cnt <= 16'h0;
        batch_cnt <= 8'h0;
    end else begin
        if( (cur_st == ST_TRANS_FIRST_IN_BATCH_PH) || (cur_st == ST_TRANS_LEFT_IN_BATCH_PH) ) begin
            if(shfl_cnt == channel_shuffle_type_reg[0]) begin
                if(dot_cnt == src_batch_size_reg) begin
                    batch_cnt <= batch_cnt + 1'b1;
                    dot_cnt <= 16'h0;
                end else begin
                    dot_cnt <= dot_cnt + 1'b1;
                end
                shfl_cnt <= 1'h0;
            end else begin
                shfl_cnt <= shfl_cnt + 1'b1;
            end
        end else begin
            shfl_cnt <= 1'h0;
            dot_cnt <= 16'h0;
            batch_cnt <= 8'h0;
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
        dtrans_intr <= 1'b0;
    end else begin
        if(cur_st == ST_DONE) begin
            dtrans_intr <= 1'b1;
        end else if(mcu_clr_intr) begin
            dtrans_intr <= 1'b0;
        end
    end
end
assign regmap_dtrans__intr_o = dtrans_intr;

// define some update signal to simplify expression.
assign update_dot_sig = (shfl_cnt == channel_shuffle_type_reg[0])
                      && ( (cur_st == ST_TRANS_FIRST_IN_BATCH_PH) || (cur_st == ST_TRANS_LEFT_IN_BATCH_PH) );
assign update_batch_sig = (dot_cnt == src_batch_size_reg) && update_dot_sig;

// generate op_code
assign dtransctl_vputy__code_o[0] = (shfl_cnt == 1'b0) && ( (cur_st == ST_TRANS_FIRST_IN_BATCH_PH)  || (cur_st == ST_TRANS_LEFT_IN_BATCH_PH) );
assign dtransctl_vputy__code_o[2:1] = 2'h0;
assign dtransctl_vputy__code_o[3] = (|mtx_shift_v_type_reg);
assign dtransctl_vputy__code_o[4] = (mtx_shift_v_type_reg== 2'h2);

assign dtransctl_vputy__sv_code_o[EN_ACT] = dtransctl_vputy__code_o[0];
assign dtransctl_vputy__sv_code_o[EN_SEL] = 1'b0;
assign dtransctl_vputy__sv_code_o[EN_BIAS] = 1'b0;
assign dtransctl_vputy__sv_code_o[EN_RELU] = 1'b0;
assign dtransctl_vputy__sv_code_o[EN_SHFL] = channel_shuffle_type_reg[0];
assign dtransctl_vputy__sv_code_o[EN_CHPRI] = channel64_priority_reg;

assign dtransctl_vputy__shfl_o = channel_shuffle_type_reg[1];

// generate source addr/index
always @(posedge clk_i) begin
    if((cur_st == ST_TRANS_FIRST_IN_BATCH_PH) || (cur_st == ST_TRANS_LEFT_IN_BATCH_PH)) begin
        if(update_dot_sig) begin
            if(update_batch_sig) begin
                src_addr <= src_addr + src_dilation_reg + 1'b1;
            end else begin
                src_addr <= src_addr + 1'b1;
            end
        end
    end else begin
        src_addr <= src_mr_addr_reg;
    end
end
assign dtransctl_vputy__mrs0_addr_o = src_addr;
assign dtransctl_vputy__mrs0_index_o = src_mr_index_reg;

// generate destiny addr/index
always @(posedge clk_i) begin
    if(rst_i) begin
        dest_dot_cnt <= 16'h0;
        dest_batch_cnt <= 8'h0;
    end else begin
        if( (cur_st == ST_TRANS_FIRST_IN_BATCH_PH) || (cur_st == ST_TRANS_LEFT_IN_BATCH_PH) ) begin
            if(shfl_cnt == channel_shuffle_type_reg[0]) begin
                if(dest_dot_cnt == dest_batch_size_reg) begin
                    dest_batch_cnt <= dest_batch_cnt + 1'b1;
                    dest_dot_cnt <= 16'h0;
                end else begin
                    dest_dot_cnt <= dest_dot_cnt + 1'b1;
                end
            end
        end else begin
            dest_dot_cnt <= 16'h0;
            dest_batch_cnt <= 8'h0;
        end
    end
end

assign update_dest_batch_sig = (dest_dot_cnt == dest_batch_size_reg) && update_dot_sig;

always @(posedge clk_i) begin
    if((cur_st == ST_TRANS_FIRST_IN_BATCH_PH) || (cur_st == ST_TRANS_LEFT_IN_BATCH_PH)) begin
        if(update_dest_batch_sig) begin
            dest_addr <= dest_addr + dest_dilation_reg + 1'b1;
        end else begin
            dest_addr <= dest_addr + 1'b1;
        end
    end else begin
        dest_addr <= dest_mr_addr_reg;
    end
end
assign dtransctl_vputy__mrd_addr_o = dest_addr;
assign dtransctl_vputy__mrd_index_o = dest_mr_index_reg;

assign dtransctl_vputy__strobe_h_o = mtx_strobe_h_reg;

//======================================================================================================================
// just for simulation
//======================================================================================================================
// synthesis translate_off

// synthesis translate_on

//======================================================================================================================
// probe signals
//======================================================================================================================

endmodule   

