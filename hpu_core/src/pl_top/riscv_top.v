`timescale 1ns / 1ps
`include "e203_defines.v"
module riscv_top #(
    parameter DPU_REG_ADDR_WTH = 13,
    parameter DPU_REG_DATA_WTH = 32,
    parameter REGMAP_ADDR_WTH = 8,
    parameter REGMAP_DATA_WTH = 32
) (
    // clock & reset
    input                                   clk_i,
    input                                   rst_i,

    // interface from ps
    // ...
    input                                   ps_riscv__start_conv_i,
    
    //chenfei add for test instrction fetch enable 20190219 begin
    input                                  ps_pl_fetch_en_i,
    //chenfei add for test instrction fetch enable 20190219 end
    // internal connection
     // External-agent ICB to ITCM
        //    * Bus cmd channel
    input                                  ext2itcm_icb_cmd_valid_i,
    output                                 ext2itcm_icb_cmd_ready_o,
    input   [`E203_ITCM_ADDR_WIDTH-1:0]    ext2itcm_icb_cmd_addr_i ,
    input                                  ext2itcm_icb_cmd_read_i ,
    input   [`E203_XLEN-1:0]               ext2itcm_icb_cmd_wdata_i,
    input   [`E203_XLEN/8-1:0]             ext2itcm_icb_cmd_wmask_i,
        //
        //    * Bus RSP channel
    output                                 ext2itcm_icb_rsp_valid_o,
    input                                  ext2itcm_icb_rsp_ready_i,
    output                                 ext2itcm_icb_rsp_err_o  ,
    output[`E203_XLEN-1:0]                 ext2itcm_icb_rsp_rdata_o,
        //endif//
    // internal connection
         // External-agent ICB to DTCM
            //    * Bus cmd channel
    input                                  ext2dtcm_icb_cmd_valid_i,
    output                                 ext2dtcm_icb_cmd_ready_o,
    input   [`E203_ITCM_ADDR_WIDTH-1:0]    ext2dtcm_icb_cmd_addr_i ,
    input                                  ext2dtcm_icb_cmd_read_i ,
    input   [`E203_XLEN-1:0]               ext2dtcm_icb_cmd_wdata_i,
    input   [`E203_XLEN/8-1:0]             ext2dtcm_icb_cmd_wmask_i,
        ////
        ////    * Bus RSP channel
    output                                 ext2dtcm_icb_rsp_valid_o,
    input                                  ext2dtcm_icb_rsp_ready_i,
    output                                 ext2dtcm_icb_rsp_err_o  ,
    output[`E203_XLEN-1:0]                 ext2dtcm_icb_rsp_rdata_o,
            //endif//
    // regmap interface: from mcu_core module
 output[DPU_REG_ADDR_WTH-1 : 0]          riscv_regmap__waddr_o,
 output                                  riscv_regmap__we_o,
 output[DPU_REG_DATA_WTH-1 : 0]          riscv_regmap__wdata_o,
 output[DPU_REG_ADDR_WTH-1 : 0]          riscv_regmap__raddr_o,
 output                                  riscv_regmap__re_o,
 input [DPU_REG_DATA_WTH-1 : 0]          riscv_regmap__rdata_i,
 input                                   riscv_regmap__rdata_act_i,
 input [7 : 0]                           riscv_regmap__intr_i
);

//======================================================================================================================
// Wire & Reg declaration
//======================================================================================================================


//======================================================================================================================
// Instance
//======================================================================================================================

e203_soc_top u_e203_soc_top(
    .hfextclk                   (clk_i),
    .hfxoscen                   (),

    .lfextclk                   (clk_i),
    .lfxoscen                   (),

    .io_pads_jtag_TCK_i_ival    (1'b0), //jtag_TCK),
    .io_pads_jtag_TMS_i_ival    (1'b0), //jtag_TMS),
    .io_pads_jtag_TDI_i_ival    (1'b0), //jtag_TDI),
    .io_pads_jtag_TDO_o_oval    (), //jtag_TDO),
    .io_pads_jtag_TDO_o_oe (),
    .io_pads_gpio_0_i_ival (1'b1),
    .io_pads_gpio_0_o_oval (),
    .io_pads_gpio_0_o_oe (),
    .io_pads_gpio_0_o_ie (),
    .io_pads_gpio_0_o_pue (),
    .io_pads_gpio_0_o_ds (),
    .io_pads_gpio_1_i_ival (1'b1),
    .io_pads_gpio_1_o_oval (),
    .io_pads_gpio_1_o_oe (),
    .io_pads_gpio_1_o_ie (),
    .io_pads_gpio_1_o_pue (),
    .io_pads_gpio_1_o_ds (),
    .io_pads_gpio_2_i_ival (1'b1),
    .io_pads_gpio_2_o_oval (),
    .io_pads_gpio_2_o_oe (),
    .io_pads_gpio_2_o_ie (),
    .io_pads_gpio_2_o_pue (),
    .io_pads_gpio_2_o_ds (),
    .io_pads_gpio_3_i_ival (1'b1),
    .io_pads_gpio_3_o_oval (),
    .io_pads_gpio_3_o_oe (),
    .io_pads_gpio_3_o_ie (),
    .io_pads_gpio_3_o_pue (),
    .io_pads_gpio_3_o_ds (),
    .io_pads_gpio_4_i_ival (1'b1),
    .io_pads_gpio_4_o_oval (),
    .io_pads_gpio_4_o_oe (),
    .io_pads_gpio_4_o_ie (),
    .io_pads_gpio_4_o_pue (),
    .io_pads_gpio_4_o_ds (),
    .io_pads_gpio_5_i_ival (1'b1),
    .io_pads_gpio_5_o_oval (),
    .io_pads_gpio_5_o_oe (),
    .io_pads_gpio_5_o_ie (),
    .io_pads_gpio_5_o_pue (),
    .io_pads_gpio_5_o_ds (),
    .io_pads_gpio_6_i_ival (1'b1),
    .io_pads_gpio_6_o_oval (),
    .io_pads_gpio_6_o_oe (),
    .io_pads_gpio_6_o_ie (),
    .io_pads_gpio_6_o_pue (),
    .io_pads_gpio_6_o_ds (),
    .io_pads_gpio_7_i_ival (1'b1),
    .io_pads_gpio_7_o_oval (),
    .io_pads_gpio_7_o_oe (),
    .io_pads_gpio_7_o_ie (),
    .io_pads_gpio_7_o_pue (),
    .io_pads_gpio_7_o_ds (),
    .io_pads_gpio_8_i_ival (1'b1),
    .io_pads_gpio_8_o_oval (),
    .io_pads_gpio_8_o_oe (),
    .io_pads_gpio_8_o_ie (),
    .io_pads_gpio_8_o_pue (),
    .io_pads_gpio_8_o_ds (),
    .io_pads_gpio_9_i_ival (1'b1),
    .io_pads_gpio_9_o_oval (),
    .io_pads_gpio_9_o_oe (),
    .io_pads_gpio_9_o_ie (),
    .io_pads_gpio_9_o_pue (),
    .io_pads_gpio_9_o_ds (),
    .io_pads_gpio_10_i_ival (1'b1),
    .io_pads_gpio_10_o_oval (),
    .io_pads_gpio_10_o_oe (),
    .io_pads_gpio_10_o_ie (),
    .io_pads_gpio_10_o_pue (),
    .io_pads_gpio_10_o_ds (),
    .io_pads_gpio_11_i_ival (1'b1),
    .io_pads_gpio_11_o_oval (),
    .io_pads_gpio_11_o_oe (),
    .io_pads_gpio_11_o_ie (),
    .io_pads_gpio_11_o_pue (),
    .io_pads_gpio_11_o_ds (),
    .io_pads_gpio_12_i_ival (1'b1),
    .io_pads_gpio_12_o_oval (),
    .io_pads_gpio_12_o_oe (),
    .io_pads_gpio_12_o_ie (),
    .io_pads_gpio_12_o_pue (),
    .io_pads_gpio_12_o_ds (),
    .io_pads_gpio_13_i_ival (1'b1),
    .io_pads_gpio_13_o_oval (),
    .io_pads_gpio_13_o_oe (),
    .io_pads_gpio_13_o_ie (),
    .io_pads_gpio_13_o_pue (),
    .io_pads_gpio_13_o_ds (),
    .io_pads_gpio_14_i_ival (1'b1),
    .io_pads_gpio_14_o_oval (),
    .io_pads_gpio_14_o_oe (),
    .io_pads_gpio_14_o_ie (),
    .io_pads_gpio_14_o_pue (),
    .io_pads_gpio_14_o_ds (),
    .io_pads_gpio_15_i_ival (1'b1),
    .io_pads_gpio_15_o_oval (),
    .io_pads_gpio_15_o_oe (),
    .io_pads_gpio_15_o_ie (),
    .io_pads_gpio_15_o_pue (),
    .io_pads_gpio_15_o_ds (),
    .io_pads_gpio_16_i_ival (1'b1),
    .io_pads_gpio_16_o_oval (),
    .io_pads_gpio_16_o_oe (),
    .io_pads_gpio_16_o_ie (),
    .io_pads_gpio_16_o_pue (),
    .io_pads_gpio_16_o_ds (),
    .io_pads_gpio_17_i_ival (1'b1),
    .io_pads_gpio_17_o_oval (),
    .io_pads_gpio_17_o_oe (),
    .io_pads_gpio_17_o_ie (),
    .io_pads_gpio_17_o_pue (),
    .io_pads_gpio_17_o_ds (),
    .io_pads_gpio_18_i_ival (1'b1),
    .io_pads_gpio_18_o_oval (),
    .io_pads_gpio_18_o_oe (),
    .io_pads_gpio_18_o_ie (),
    .io_pads_gpio_18_o_pue (),
    .io_pads_gpio_18_o_ds (),
    .io_pads_gpio_19_i_ival (1'b1),
    .io_pads_gpio_19_o_oval (),
    .io_pads_gpio_19_o_oe (),
    .io_pads_gpio_19_o_ie (),
    .io_pads_gpio_19_o_pue (),
    .io_pads_gpio_19_o_ds (),
    .io_pads_gpio_20_i_ival (1'b1),
    .io_pads_gpio_20_o_oval (),
    .io_pads_gpio_20_o_oe (),
    .io_pads_gpio_20_o_ie (),
    .io_pads_gpio_20_o_pue (),
    .io_pads_gpio_20_o_ds (),
    .io_pads_gpio_21_i_ival (1'b1),
    .io_pads_gpio_21_o_oval (),
    .io_pads_gpio_21_o_oe (),
    .io_pads_gpio_21_o_ie (),
    .io_pads_gpio_21_o_pue (),
    .io_pads_gpio_21_o_ds (),
    .io_pads_gpio_22_i_ival (1'b1),
    .io_pads_gpio_22_o_oval (),
    .io_pads_gpio_22_o_oe (),
    .io_pads_gpio_22_o_ie (),
    .io_pads_gpio_22_o_pue (),
    .io_pads_gpio_22_o_ds (),
    .io_pads_gpio_23_i_ival (1'b1),
    .io_pads_gpio_23_o_oval (),
    .io_pads_gpio_23_o_oe (),
    .io_pads_gpio_23_o_ie (),
    .io_pads_gpio_23_o_pue (),
    .io_pads_gpio_23_o_ds (),
    .io_pads_gpio_24_i_ival (1'b1),
    .io_pads_gpio_24_o_oval (),
    .io_pads_gpio_24_o_oe (),
    .io_pads_gpio_24_o_ie (),
    .io_pads_gpio_24_o_pue (),
    .io_pads_gpio_24_o_ds (),
    .io_pads_gpio_25_i_ival (1'b1),
    .io_pads_gpio_25_o_oval (),
    .io_pads_gpio_25_o_oe (),
    .io_pads_gpio_25_o_ie (),
    .io_pads_gpio_25_o_pue (),
    .io_pads_gpio_25_o_ds (),
    .io_pads_gpio_26_i_ival (1'b1),
    .io_pads_gpio_26_o_oval (),
    .io_pads_gpio_26_o_oe (),
    .io_pads_gpio_26_o_ie (),
    .io_pads_gpio_26_o_pue (),
    .io_pads_gpio_26_o_ds (),
    .io_pads_gpio_27_i_ival (1'b1),
    .io_pads_gpio_27_o_oval (),
    .io_pads_gpio_27_o_oe (),
    .io_pads_gpio_27_o_ie (),
    .io_pads_gpio_27_o_pue (),
    .io_pads_gpio_27_o_ds (),
    .io_pads_gpio_28_i_ival (1'b1),
    .io_pads_gpio_28_o_oval (),
    .io_pads_gpio_28_o_oe (),
    .io_pads_gpio_28_o_ie (),
    .io_pads_gpio_28_o_pue (),
    .io_pads_gpio_28_o_ds (),
    .io_pads_gpio_29_i_ival (1'b1),
    .io_pads_gpio_29_o_oval (),
    .io_pads_gpio_29_o_oe (),
    .io_pads_gpio_29_o_ie (),
    .io_pads_gpio_29_o_pue (),
    .io_pads_gpio_29_o_ds (),
    .io_pads_gpio_30_i_ival (1'b1),
    .io_pads_gpio_30_o_oval (),
    .io_pads_gpio_30_o_oe (),
    .io_pads_gpio_30_o_ie (),
    .io_pads_gpio_30_o_pue (),
    .io_pads_gpio_30_o_ds (),
    .io_pads_gpio_31_i_ival (1'b1),
    .io_pads_gpio_31_o_oval (),
    .io_pads_gpio_31_o_oe (),
    .io_pads_gpio_31_o_ie (),
    .io_pads_gpio_31_o_pue (),
    .io_pads_gpio_31_o_ds (),

    .io_pads_qspi_sck_o_oval (),
    .io_pads_qspi_dq_0_i_ival (1'b1),
    .io_pads_qspi_dq_0_o_oval (),
    .io_pads_qspi_dq_0_o_oe (),
    .io_pads_qspi_dq_0_o_ie (),
    .io_pads_qspi_dq_0_o_pue (),
    .io_pads_qspi_dq_0_o_ds (),
    .io_pads_qspi_dq_1_i_ival (1'b1),
    .io_pads_qspi_dq_1_o_oval (),
    .io_pads_qspi_dq_1_o_oe (),
    .io_pads_qspi_dq_1_o_ie (),
    .io_pads_qspi_dq_1_o_pue (),
    .io_pads_qspi_dq_1_o_ds (),
    .io_pads_qspi_dq_2_i_ival (1'b1),
    .io_pads_qspi_dq_2_o_oval (),
    .io_pads_qspi_dq_2_o_oe (),
    .io_pads_qspi_dq_2_o_ie (),
    .io_pads_qspi_dq_2_o_pue (),
    .io_pads_qspi_dq_2_o_ds (),
    .io_pads_qspi_dq_3_i_ival (1'b1),
    .io_pads_qspi_dq_3_o_oval (),
    .io_pads_qspi_dq_3_o_oe (),
    .io_pads_qspi_dq_3_o_ie (),
    .io_pads_qspi_dq_3_o_pue (),
    .io_pads_qspi_dq_3_o_ds (),
    .io_pads_qspi_cs_0_o_oval (),
    .io_pads_aon_erst_n_i_ival (~rst_i),//This is the real reset, active low
    .io_pads_aon_pmu_dwakeup_n_i_ival (1'b1),

    .io_pads_aon_pmu_vddpaden_o_oval (),
    .io_pads_aon_pmu_padrst_o_oval    (),

    .io_pads_bootrom_n_i_ival       (1'b0),// In Simulation we boot from ROM
    .io_pads_dbgmode0_n_i_ival       (1'b1),
    .io_pads_dbgmode1_n_i_ival       (1'b1),
    .io_pads_dbgmode2_n_i_ival       (1'b1),
    
    //`ifdef E203_HAS_ITCM_EXTITF //{
    //////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////
    // External-agent ICB to ITCM
    //    * Bus cmd channel
    .ext2itcm_icb_cmd_valid_i(ext2itcm_icb_cmd_valid_i ),
    .ext2itcm_icb_cmd_ready_o(ext2itcm_icb_cmd_ready_o ),
    .ext2itcm_icb_cmd_addr_i (ext2itcm_icb_cmd_addr_i  ),
    .ext2itcm_icb_cmd_read_i (ext2itcm_icb_cmd_read_i  ),
    .ext2itcm_icb_cmd_wdata_i(ext2itcm_icb_cmd_wdata_i ),
    .ext2itcm_icb_cmd_wmask_i(ext2itcm_icb_cmd_wmask_i ),
    //
    //    * Bus RSP channel
    .ext2itcm_icb_rsp_valid_o(ext2itcm_icb_rsp_valid_o ),
    .ext2itcm_icb_rsp_ready_i(ext2itcm_icb_rsp_ready_i ),
    .ext2itcm_icb_rsp_err_o  (ext2itcm_icb_rsp_err_o   ),
    .ext2itcm_icb_rsp_rdata_o(ext2itcm_icb_rsp_rdata_o ),
    //endif//
    //to itcm external interface
    //to riscv
     //`ifdef E203_HAS_DTCM_EXTITF //{
     //////////////////////////////////////////////////////////////
     //////////////////////////////////////////////////////////////
     // External-agent ICB to DTCM
     //    * Bus cmd channel
     .ext2dtcm_icb_cmd_valid_i(ext2dtcm_icb_cmd_valid_i  ),
     .ext2dtcm_icb_cmd_ready_o(ext2dtcm_icb_cmd_ready_o  ),
     .ext2dtcm_icb_cmd_addr_i (ext2dtcm_icb_cmd_addr_i   ),
     .ext2dtcm_icb_cmd_read_i (ext2dtcm_icb_cmd_read_i   ),
     .ext2dtcm_icb_cmd_wdata_i(ext2dtcm_icb_cmd_wdata_i  ),
     .ext2dtcm_icb_cmd_wmask_i(ext2dtcm_icb_cmd_wmask_i  ),
     //                                                              
     //    * Bus RSP channel                                         
     .ext2dtcm_icb_rsp_valid_o(ext2dtcm_icb_rsp_valid_o ),
     .ext2dtcm_icb_rsp_ready_i(ext2dtcm_icb_rsp_ready_i ),
     .ext2dtcm_icb_rsp_err_o  (ext2dtcm_icb_rsp_err_o   ),
     .ext2dtcm_icb_rsp_rdata_o(ext2dtcm_icb_rsp_rdata_o ),
     //endif//
     //chenfei add for test instrction fetch enable 20190219 begin
     .ps_pl_fetch_en_i(ps_pl_fetch_en_i),
     //chenfei add for test instrction fetch enable 20190219 end
    .riscv_regmap__waddr_o          (riscv_regmap__waddr_o),
    .riscv_regmap__we_o             (riscv_regmap__we_o),
    .riscv_regmap__wdata_o          (riscv_regmap__wdata_o),
    .riscv_regmap__raddr_o          (riscv_regmap__raddr_o),
    .riscv_regmap__re_o             (riscv_regmap__re_o),
    .riscv_regmap__rdata_i          (riscv_regmap__rdata_i),
    .riscv_regmap__rdata_act_i      (riscv_regmap__rdata_act_i),
    .riscv_regmap__intr_i           (riscv_regmap__intr_i),
    .ps_riscv__start_conv_i         (ps_riscv__start_conv_i)
);

//======================================================================================================================
// just for simulation
//======================================================================================================================
// synthesis translate_off

// synthesis translate_on

//======================================================================================================================
// probe signals
//======================================================================================================================

endmodule   


