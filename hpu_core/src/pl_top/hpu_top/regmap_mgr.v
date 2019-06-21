// +FHDR------------------------------------------------------------------------
// XJTU IAIR Corporation All Rights Reserved
// -----------------------------------------------------------------------------
// FILE NAME  : regmap_mgr.v
// DEPARTMENT : CAG of IAIR
// AUTHOR     : chenfei
// AUTHOR'S EMAIL :fei.chen@mail.xjtu.edu.cn
// -----------------------------------------------------------------------------
// Ver 1.0  2018--12--03
// -----------------------------------------------------------------------------
// KEYWORDS   : regmap_mgr
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

module regmap_mgr #(
    parameter DPU_REG_ADDR_WTH = 13,
    parameter DPU_REG_DATA_WTH = 32,
    parameter REGMAP_ADDR_WTH = 8,
    parameter REGMAP_DATA_WTH = 32
) (
    // clock & reset
    input                                   clk_i,
    input                                   rst_i,

    // regmap interface: from mcu_core module
    input [DPU_REG_ADDR_WTH-1 : 0]          riscv_regmap__waddr_i,
    input                                   riscv_regmap__we_i,
    input [DPU_REG_DATA_WTH-1 : 0]          riscv_regmap__wdata_i,
    input [DPU_REG_ADDR_WTH-1 : 0]          riscv_regmap__raddr_i,
    input                                   riscv_regmap__re_i,
    output[DPU_REG_DATA_WTH-1 : 0]          riscv_regmap__rdata_o,
    output                                  riscv_regmap__rdata_act_o,
    output[7 : 0]                           riscv_regmap__intr_o,

    // to hpu_ctrl module
    output[REGMAP_ADDR_WTH-1 : 0]           regmap_conv__waddr_o,
    output[REGMAP_DATA_WTH-1 : 0]           regmap_conv__wdata_o,
    output                                  regmap_conv__we_o,
    input                                   regmap_conv__intr_i,

    output[REGMAP_ADDR_WTH-1 : 0]           regmap_dwc__waddr_o,
    output[REGMAP_DATA_WTH-1 : 0]           regmap_dwc__wdata_o,
    output                                  regmap_dwc__we_o,
    input                                   regmap_dwc__intr_i,

    output[REGMAP_ADDR_WTH-1 : 0]           regmap_dtrans__waddr_o,
    output[REGMAP_DATA_WTH-1 : 0]           regmap_dtrans__wdata_o,
    output                                  regmap_dtrans__we_o,
    input                                   regmap_dtrans__intr_i,

    output[REGMAP_ADDR_WTH-1 : 0]           regmap_ftrans__waddr_o,
    output[REGMAP_DATA_WTH-1 : 0]           regmap_ftrans__wdata_o,
    output                                  regmap_ftrans__we_o,
    input                                   regmap_ftrans__intr_i,

    // to load_mtxreg_ctrl module
    output[REGMAP_ADDR_WTH-1 : 0]           regmap_ldmr__waddr_o,
    output[REGMAP_DATA_WTH-1 : 0]           regmap_ldmr__wdata_o,
    output                                  regmap_ldmr__we_o,
    input                                   regmap_ldmr__intr_i,

    // to save_mtxreg_ctrl module
    output[REGMAP_ADDR_WTH-1 : 0]           regmap_svmr__waddr_o,
    output[REGMAP_DATA_WTH-1 : 0]           regmap_svmr__wdata_o,
    output                                  regmap_svmr__we_o,
    input                                   regmap_svmr__intr_i,

    // to initial the download data module
    output[REGMAP_ADDR_WTH-1 : 0]           regmap_dldata__waddr_o,
    output[REGMAP_DATA_WTH-1 : 0]           regmap_dldata__wdata_o,
    output                                  regmap_dldata__we_o,

    // to initial the upload data module
    output[REGMAP_ADDR_WTH-1 : 0]           regmap_upldata__waddr_o,
    output[REGMAP_DATA_WTH-1 : 0]           regmap_upldata__wdata_o,
    output                                  regmap_upldata__we_o,

    // to tell ps all the layer is finish 
    output                                  fshflg_ps_o
);

//======================================================================================================================
// Wire & Reg declaration
//======================================================================================================================
reg   [REGMAP_ADDR_WTH-1 : 0]           regmap_conv_waddr;
reg   [REGMAP_DATA_WTH-1 : 0]           regmap_conv_wdata;
reg                                     regmap_conv_we;

reg   [REGMAP_ADDR_WTH-1 : 0]           regmap_dwc_waddr;
reg   [REGMAP_DATA_WTH-1 : 0]           regmap_dwc_wdata;
reg                                     regmap_dwc_we;

reg   [REGMAP_ADDR_WTH-1 : 0]           regmap_dtrans_waddr;
reg   [REGMAP_DATA_WTH-1 : 0]           regmap_dtrans_wdata;
reg                                     regmap_dtrans_we;

reg   [REGMAP_ADDR_WTH-1 : 0]           regmap_ftrans_waddr;
reg   [REGMAP_DATA_WTH-1 : 0]           regmap_ftrans_wdata;
reg                                     regmap_ftrans_we;

// to initial the download data module
reg   [REGMAP_ADDR_WTH-1 : 0]           regmap_dldata_waddr;
reg   [REGMAP_DATA_WTH-1 : 0]           regmap_dldata_wdata;
reg                                     regmap_dldata_we;

// to initial the upload data module
reg   [REGMAP_ADDR_WTH-1 : 0]           regmap_upldata_waddr;
reg   [REGMAP_DATA_WTH-1 : 0]           regmap_upldata_wdata;
reg                                     regmap_upldata_we;

// to load_mtxreg_ctrl module
reg   [REGMAP_ADDR_WTH-1 : 0]           regmap_ldmr_waddr;
reg   [REGMAP_DATA_WTH-1 : 0]           regmap_ldmr_wdata;
reg                                     regmap_ldmr_we;

// to save_mtxreg_ctrl module
reg   [REGMAP_ADDR_WTH-1 : 0]           regmap_svmr_waddr;
reg   [REGMAP_DATA_WTH-1 : 0]           regmap_svmr_wdata;
reg                                     regmap_svmr_we;

reg   [DPU_REG_DATA_WTH-1 : 0]          riscv_regmap_rdata;
reg                                     riscv_regmap_rdata_act;

/************************************************************/
reg                                     fshflg_ps       ;
reg                                     fshflg_ps_r1    ;
reg                                     fshflg_ps_r2    ;
reg                                     fshflg_ps_r3    ;
reg                                     fshflg_ps_r4    ;
reg                                     fshflg_ps_r5    ;
reg                                     fshflg_ps_r6    ;

always @(posedge clk_i) begin
    if(rst_i) begin  
    fshflg_ps_r1    <=      1'b0;     
    fshflg_ps_r2    <=      1'b0; 
    fshflg_ps_r3    <=      1'b0; 
    fshflg_ps_r4    <=      1'b0; 
    fshflg_ps_r5    <=      1'b0; 
    fshflg_ps_r6    <=      1'b0;
    end
    else begin
    fshflg_ps_r1    <=   fshflg_ps       ;    
    fshflg_ps_r2    <=   fshflg_ps_r1    ;
    fshflg_ps_r3    <=   fshflg_ps_r2    ;
    fshflg_ps_r4    <=   fshflg_ps_r3    ;
    fshflg_ps_r5    <=   fshflg_ps_r4    ;
    fshflg_ps_r6    <=   fshflg_ps_r5    ;    
    end
end    

assign  fshflg_ps_o = fshflg_ps;
/************************************************************/

//======================================================================================================================
// Instance
//======================================================================================================================

always @(posedge clk_i) begin
    if(rst_i) begin
        regmap_conv_waddr      <= {DPU_REG_ADDR_WTH{1'b0}};
        regmap_conv_wdata      <= {DPU_REG_DATA_WTH{1'b0}};
        regmap_conv_we         <= 1'b0;
        regmap_dwc_waddr       <= {DPU_REG_ADDR_WTH{1'b0}};
        regmap_dwc_wdata       <= {DPU_REG_DATA_WTH{1'b0}};
        regmap_dwc_we          <= 1'b0;
        regmap_dtrans_waddr    <= {DPU_REG_ADDR_WTH{1'b0}};
        regmap_dtrans_wdata    <= {DPU_REG_DATA_WTH{1'b0}};
        regmap_dtrans_we       <= 1'b0;
        regmap_ftrans_waddr    <= {DPU_REG_ADDR_WTH{1'b0}};
        regmap_ftrans_wdata    <= {DPU_REG_DATA_WTH{1'b0}};
        regmap_ftrans_we       <= 1'b0;
        regmap_ldmr_waddr      <= {DPU_REG_ADDR_WTH{1'b0}};
        regmap_ldmr_wdata      <= {DPU_REG_DATA_WTH{1'b0}};
        regmap_ldmr_we         <= 1'b0;
        regmap_svmr_waddr      <= {DPU_REG_ADDR_WTH{1'b0}};
        regmap_svmr_wdata      <= {DPU_REG_DATA_WTH{1'b0}};
        regmap_svmr_we         <= 1'b0;
        regmap_dldata_waddr    <= {DPU_REG_ADDR_WTH{1'b0}};
        regmap_dldata_wdata    <= {DPU_REG_DATA_WTH{1'b0}};
        regmap_dldata_we       <= 1'b0;
        regmap_upldata_waddr   <= {DPU_REG_ADDR_WTH{1'b0}};
        regmap_upldata_wdata   <= {DPU_REG_DATA_WTH{1'b0}};
        regmap_upldata_we      <= 1'b0;
        fshflg_ps              <= 1'b0;
    end else begin
        regmap_conv_waddr      <= {DPU_REG_ADDR_WTH{1'b0}};
        regmap_conv_wdata      <= {DPU_REG_DATA_WTH{1'b0}};
        regmap_conv_we         <= 1'b0;
        regmap_dwc_waddr       <= {DPU_REG_ADDR_WTH{1'b0}};
        regmap_dwc_wdata       <= {DPU_REG_DATA_WTH{1'b0}};
        regmap_dwc_we          <= 1'b0;
        regmap_dtrans_waddr    <= {DPU_REG_ADDR_WTH{1'b0}};
        regmap_dtrans_wdata    <= {DPU_REG_DATA_WTH{1'b0}};
        regmap_dtrans_we       <= 1'b0;
        regmap_ftrans_waddr    <= {DPU_REG_ADDR_WTH{1'b0}};
        regmap_ftrans_wdata    <= {DPU_REG_DATA_WTH{1'b0}};
        regmap_ftrans_we       <= 1'b0;
        regmap_ldmr_waddr      <= {DPU_REG_ADDR_WTH{1'b0}};
        regmap_ldmr_wdata      <= {DPU_REG_DATA_WTH{1'b0}};
        regmap_ldmr_we         <= 1'b0;
        regmap_svmr_waddr      <= {DPU_REG_ADDR_WTH{1'b0}};
        regmap_svmr_wdata      <= {DPU_REG_DATA_WTH{1'b0}};
        regmap_svmr_we         <= 1'b0;
        regmap_dldata_waddr    <= {DPU_REG_ADDR_WTH{1'b0}};
        regmap_dldata_wdata    <= {DPU_REG_DATA_WTH{1'b0}};
        regmap_dldata_we       <= 1'b0;
        regmap_upldata_waddr   <= {DPU_REG_ADDR_WTH{1'b0}};
        regmap_upldata_wdata   <= {DPU_REG_DATA_WTH{1'b0}};
        regmap_upldata_we      <= 1'b0;
        fshflg_ps              <= 1'b0;
        if(riscv_regmap__we_i) begin
            case(riscv_regmap__waddr_i[DPU_REG_ADDR_WTH-1 : REGMAP_ADDR_WTH])
                5'd0: begin
                    fshflg_ps              <= riscv_regmap__wdata_i[0];
                end            
                5'd1: begin
                    regmap_conv_waddr      <= riscv_regmap__waddr_i[REGMAP_ADDR_WTH-1 : 0];
                    regmap_conv_wdata      <= riscv_regmap__wdata_i;
                    regmap_conv_we         <= riscv_regmap__we_i;
                end
                5'd2: begin
                    regmap_dwc_waddr       <= riscv_regmap__waddr_i[REGMAP_ADDR_WTH-1 : 0];
                    regmap_dwc_wdata       <= riscv_regmap__wdata_i;
                    regmap_dwc_we          <= riscv_regmap__we_i;
                end
                5'd3: begin
                    regmap_dtrans_waddr    <= riscv_regmap__waddr_i[REGMAP_ADDR_WTH-1 : 0];
                    regmap_dtrans_wdata    <= riscv_regmap__wdata_i;
                    regmap_dtrans_we       <= riscv_regmap__we_i;
                end
                5'd4: begin
                    regmap_ftrans_waddr    <= riscv_regmap__waddr_i[REGMAP_ADDR_WTH-1 : 0];
                    regmap_ftrans_wdata    <= riscv_regmap__wdata_i;
                    regmap_ftrans_we       <= riscv_regmap__we_i;
                end
                5'd5: begin
                    regmap_ldmr_waddr      <= riscv_regmap__waddr_i[REGMAP_ADDR_WTH-1 : 0];
                    regmap_ldmr_wdata      <= riscv_regmap__wdata_i;
                    regmap_ldmr_we         <= riscv_regmap__we_i;
                end
                5'd6: begin
                    regmap_svmr_waddr      <= riscv_regmap__waddr_i[REGMAP_ADDR_WTH-1 : 0];
                    regmap_svmr_wdata      <= riscv_regmap__wdata_i;
                    regmap_svmr_we         <= riscv_regmap__we_i;
                end
                5'd7: begin
                    regmap_dldata_waddr    <= riscv_regmap__waddr_i[REGMAP_ADDR_WTH-1 : 0];
                    regmap_dldata_wdata    <= riscv_regmap__wdata_i;
                    regmap_dldata_we       <= riscv_regmap__we_i;
                end
                5'd8: begin
                    regmap_upldata_waddr   <= riscv_regmap__waddr_i[REGMAP_ADDR_WTH-1 : 0];
                    regmap_upldata_wdata   <= riscv_regmap__wdata_i;
                    regmap_upldata_we      <= riscv_regmap__we_i;
                end
                // 5'd9-5'd31 are reserved
            endcase
        end
    end
end
assign regmap_conv__waddr_o = regmap_conv_waddr;
assign regmap_conv__wdata_o = regmap_conv_wdata;
assign regmap_conv__we_o    = regmap_conv_we;

assign regmap_dwc__waddr_o = regmap_dwc_waddr;
assign regmap_dwc__wdata_o = regmap_dwc_wdata;
assign regmap_dwc__we_o    = regmap_dwc_we;

assign regmap_dtrans__waddr_o = regmap_dtrans_waddr;
assign regmap_dtrans__wdata_o = regmap_dtrans_wdata;
assign regmap_dtrans__we_o    = regmap_dtrans_we;

assign regmap_ftrans__waddr_o = regmap_ftrans_waddr;
assign regmap_ftrans__wdata_o = regmap_ftrans_wdata;
assign regmap_ftrans__we_o    = regmap_ftrans_we;

// to load_mtxreg_ctrl module
assign regmap_ldmr__waddr_o =  regmap_ldmr_waddr;
assign regmap_ldmr__wdata_o =  regmap_ldmr_wdata;
assign regmap_ldmr__we_o    =  regmap_ldmr_we;

// to save_mtxreg_ctrl module
assign regmap_svmr__waddr_o = regmap_svmr_waddr;
assign regmap_svmr__wdata_o = regmap_svmr_wdata;
assign regmap_svmr__we_o    = regmap_svmr_we;

// to initial the download data module
assign regmap_dldata__waddr_o = regmap_dldata_waddr;
assign regmap_dldata__wdata_o = regmap_dldata_wdata;
assign regmap_dldata__we_o    = regmap_dldata_we;

// to initial the upload data module
assign regmap_upldata__waddr_o = regmap_upldata_waddr;
assign regmap_upldata__wdata_o = regmap_upldata_wdata;
assign regmap_upldata__we_o    = regmap_upldata_we;

// generate the status and interrupt signals
always @(posedge clk_i) begin
    riscv_regmap_rdata <= {DPU_REG_DATA_WTH{1'b0}};
    riscv_regmap_rdata_act <= 1'b0;
    if(riscv_regmap__re_i) begin
        riscv_regmap_rdata_act <= 1'b1;
        case(riscv_regmap__raddr_i[DPU_REG_ADDR_WTH-1 : REGMAP_ADDR_WTH])
            5'd0: begin//special regs and just for read
                case(riscv_regmap__raddr_i[REGMAP_ADDR_WTH-1 : 2])
                    6'd000: ;//Reserved
                    6'd001:riscv_regmap_rdata <= {26'b0,
                                                 regmap_svmr__intr_i,
                                                 regmap_ldmr__intr_i,
                                                 regmap_ftrans__intr_i,
                                                 regmap_dtrans__intr_i,
                                                 regmap_dwc__intr_i,
                                                 regmap_conv__intr_i}; //intrupt status
                    //6'd2-6'd255  Reserved
                endcase
            end
        endcase
    end
end

assign riscv_regmap__rdata_act_o = riscv_regmap_rdata_act;
assign riscv_regmap__rdata_o = riscv_regmap_rdata;

//reg   [7 : 0]                           intr_sel;
//wire  [7 : 0]                           intr_cand;
//assign intr_cand = { 2'h0,
//                     regmap_svmr__intr_i,
//                     regmap_ldmr__intr_i,
//                     regmap_ftrans__intr_i,
//                     regmap_dtrans__intr_i,
//                     regmap_dwc__intr_i,
//                     regmap_conv__intr_i
//                   };

//always @(posedge clk_i) begin
//    if(rst_i) begin
//        intr_sel <= 8'h1;
//    end else begin
//        if(~|riscv_regmap__intr_o) begin
//            intr_sel <= {intr_sel[6:0], intr_sel[7]};
//        end
//    end
//end

//assign riscv_regmap__intr_o = intr_cand & intr_sel;

assign riscv_regmap__intr_o = { 2'h0,
                                regmap_svmr__intr_i,
                                regmap_ldmr__intr_i,
                                regmap_ftrans__intr_i,
                                regmap_dtrans__intr_i,
                                regmap_dwc__intr_i,
                                regmap_conv__intr_i
                              };

//======================================================================================================================
// just for simulation
//======================================================================================================================
// synthesis translate_off

// synthesis translate_on

//======================================================================================================================
// probe signals
//======================================================================================================================

endmodule

