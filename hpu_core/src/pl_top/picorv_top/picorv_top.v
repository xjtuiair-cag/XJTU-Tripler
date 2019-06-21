
`include "picorv_defines.v"

module picosoc #(
    parameter DPU_REG_ADDR_WTH = 13,
    parameter DPU_REG_DATA_WTH = 32
) (
	input clk,
	input resetn,
	output trap,

	// regmap interface: from mcu_core module
    output[DPU_REG_ADDR_WTH-1 : 0]          riscv_regmap__waddr_o,
    output                                  riscv_regmap__we_o,
    output[DPU_REG_DATA_WTH-1 : 0]          riscv_regmap__wdata_o,
    output[DPU_REG_ADDR_WTH-1 : 0]          riscv_regmap__raddr_o,
    output                                  riscv_regmap__re_o,
    input [DPU_REG_DATA_WTH-1 : 0]          riscv_regmap__rdata_i,
    input                                   riscv_regmap__rdata_act_i,

	// external interrupts
    input [7:0] riscv_regmap__intr_i,
	input ps_riscv__start_conv_i,

	/* CPU access to external address space */
    // output ext_mem_valid,
	// output [31:0] ext_mem_addr,
	// output [31:0] ext_mem_wdata,
	// output [3:0]  ext_mem_wstrb,
	// input  [31:0] ext_mem_rdata,
	// input  ext_mem_ready,

	/* External access to ITCM/DTCM */
	/* itcm interface */
    input            					ext_itcm_ram_cs  ,
    input  [31:0]    					ext_itcm_ram_addr,
    input  [`PICORV_ITCM_RAM_MW-1:0]    ext_itcm_ram_wen ,
    input  [`PICORV_ITCM_RAM_WW-1:0]    ext_itcm_ram_wdata ,
    output [`PICORV_ITCM_RAM_WW-1:0]    ext_itcm_ram_rdata,
    output            					ext_itcm_ready,
    /* dtcm interface */
    input            					ext_dtcm_ram_cs  ,
    input  [31:0]    					ext_dtcm_ram_addr,
    input  [`PICORV_DTCM_RAM_MW-1:0]    ext_dtcm_ram_wen,
    input  [`PICORV_DTCM_RAM_WW-1:0]    ext_dtcm_ram_wdata,
    output [`PICORV_DTCM_RAM_WW-1:0]    ext_dtcm_ram_rdata,
    output            					ext_dtcm_ready
);
	localparam [0:0] BARREL_SHIFTER = 0;
	localparam [0:0] ENABLE_MULDIV = 1;
	localparam [0:0] ENABLE_COMPRESSED = 0;
	localparam [0:0] ENABLE_COUNTERS = 1;
	localparam [0:0] ENABLE_IRQ_QREGS = 1;
    localparam [0:0] ENABLE_IRQ = 1;

	// parameter integer MEM_WORDS = 256;
	// parameter [`PICORV_ITCM_RAM_AW-1:0] STACKADDR = (4*MEM_WORDS);       // end of memory
	// parameter [31:0] PROGADDR_RESET = 32'h 0000_0000; 
	// parameter [31:0] PROGADDR_IRQ = 32'h 0000_0010;

	wire [31:0] picorv_irq;

    /* picorv32 local memory interface */
	wire mem_valid;
	wire mem_instr;
	wire mem_ready;
	wire [31:0] mem_addr;
	wire [31:0] mem_wdata;
	wire [3:0] mem_wstrb;
	wire [31:0] mem_rdata;


    /* itcm interface */
    // wire            clk_itcm_ram ;
    wire            itcm_ram_cs  ;
    wire  [31:0]    itcm_ram_addr;
    wire  [`PICORV_ITCM_RAM_MW-1:0]    itcm_ram_wen ;
    wire  [`PICORV_ITCM_RAM_WW-1:0]    itcm_ram_wdata ;
    wire  [`PICORV_ITCM_RAM_WW-1:0]    itcm_ram_rdata;
    wire            itcm_ready;

    /* dtcm interface */
    // wire            clk_dtcm_ram ;
    wire            dtcm_ram_cs  ;
    wire  [31:0]    dtcm_ram_addr;
    wire  [`PICORV_DTCM_RAM_MW-1:0]    dtcm_ram_wen ;
    wire  [`PICORV_DTCM_RAM_WW-1:0]    dtcm_ram_wdata ;
    wire  [`PICORV_DTCM_RAM_WW-1:0]    dtcm_ram_rdata;
    wire            dtcm_ready;
    
    /* hpu regmap interface */
    wire            hpu_reg_valid  ;
    wire  [31:0]    hpu_reg_addr;
    wire  [4:0]     hpu_reg_wen ;
    wire  [31:0]    hpu_reg_wdata ;
    wire  [31:0]    hpu_reg_rdata;
    wire            hpu_reg_ready;

    /* picorv interrupts */
	assign picorv_irq = {20'h00000, ps_riscv__start_conv_i, riscv_regmap__intr_i[7:0], 3'b000};

    picorv32 #(
		// .STACKADDR(STACKADDR),
		.PROGADDR_RESET	(`PROGADDR_RESET),
		.PROGADDR_IRQ	(`PROGADDR_IRQ),
		.BARREL_SHIFTER	(BARREL_SHIFTER),
		.COMPRESSED_ISA	(ENABLE_COMPRESSED),
		.ENABLE_COUNTERS(ENABLE_COUNTERS),
		.ENABLE_MUL		(ENABLE_MULDIV),
		.ENABLE_DIV		(ENABLE_MULDIV),
		.ENABLE_IRQ		(ENABLE_IRQ),
		.ENABLE_IRQ_QREGS(ENABLE_IRQ_QREGS)
	) cpu (
		.clk         (clk        ),
		.resetn      (resetn     ),
		.trap        (trap       ),
		.mem_valid   (mem_valid  ),
		.mem_instr   (mem_instr  ),
		.mem_ready   (mem_ready  ),
		.mem_addr    (mem_addr   ),
		.mem_wdata   (mem_wdata  ),
		.mem_wstrb   (mem_wstrb  ),
		.mem_rdata   (mem_rdata  ),
		.irq         (picorv_irq )
	);

    wire is_itcm_domain;
    wire is_dtcm_domain;
    wire is_hpu_domain;
    assign is_itcm_domain = ((mem_addr >> 20) == (`ITCM_START >> 20)); // 0x0 - 0x00100000 (1M)
    assign is_dtcm_domain = ((mem_addr >> 20) == (`DTCM_START >> 20)); // 0x00100000 - 0x00200000 (1M)
    assign is_hpu_domain  = ((mem_addr >> 20) == (`DPU_MAP_START >> 20)); // 0x20000000 - 0x20100000 (1M)

    assign dtcm_ram_cs    = ext_dtcm_ram_cs? 1'b1              : mem_valid && is_dtcm_domain && (~mem_instr);
    assign dtcm_ram_wen   = ext_dtcm_ram_cs? ext_dtcm_ram_wen  : dtcm_ram_cs? mem_wstrb : 4'b0;
    assign dtcm_ram_addr  = ext_dtcm_ram_cs? ext_dtcm_ram_addr : dtcm_ram_cs? (mem_addr - 32'h0010_0000) : 32'hffff_ffff; // offset of dtcm region
    assign dtcm_ram_wdata = ext_dtcm_ram_cs? ext_dtcm_ram_wdata: mem_wdata;
    
    assign itcm_ram_cs    = ext_itcm_ram_cs? 1'b1              :mem_valid && is_itcm_domain && mem_instr;
    assign itcm_ram_wen   = ext_itcm_ram_cs? ext_itcm_ram_wen  :itcm_ram_cs? mem_wstrb : 4'b0;
    assign itcm_ram_addr  = ext_itcm_ram_cs? ext_itcm_ram_addr :itcm_ram_cs? (mem_addr - 32'h0000_0000) : 32'hffff_ffff; // offset of itcm region;
    assign itcm_ram_wdata = ext_itcm_ram_cs? ext_itcm_ram_wdata:mem_wdata;

	/* from rsicv to hpu regs */
    assign hpu_reg_valid = mem_valid && is_hpu_domain && (~mem_instr); // no instruction in hpu regs
    assign hpu_reg_wen   = hpu_reg_valid? mem_wstrb : 4'b0;
    assign hpu_reg_addr  = mem_addr;
    assign hpu_reg_wdata = mem_wdata;
    
	assign riscv_regmap__waddr_o 	= hpu_reg_addr[DPU_REG_ADDR_WTH-1 : 0];
    assign riscv_regmap__we_o 		= hpu_reg_wen[0];
    assign riscv_regmap__wdata_o 	= hpu_reg_wdata;
    assign riscv_regmap__raddr_o 	= hpu_reg_addr[DPU_REG_ADDR_WTH-1 : 0];
    assign riscv_regmap__re_o 		= hpu_reg_valid && (!hpu_reg_wen[0]);
    assign hpu_reg_rdata 			= riscv_regmap__rdata_i;
    assign hpu_reg_ready 			= riscv_regmap__rdata_act_i;

    

	reg latched_ext_itcm_ram_cs;
	reg latched_ext_dtcm_ram_cs;
	always @(posedge clk) begin
		latched_ext_itcm_ram_cs <= ext_itcm_ram_cs;
		latched_ext_dtcm_ram_cs <= ext_dtcm_ram_cs;
    end
    
	assign ext_itcm_ram_rdata = latched_ext_itcm_ram_cs? itcm_ram_rdata : 32'hdead_beaf;
	assign ext_itcm_ready     = latched_ext_itcm_ram_cs? itcm_ready : 1'b0;
	assign ext_dtcm_ram_rdata = latched_ext_dtcm_ram_cs? dtcm_ram_rdata : 32'hdead_beaf;
	assign ext_dtcm_ready     = latched_ext_dtcm_ram_cs? dtcm_ready : 1'b0;
	
    assign mem_rdata = dtcm_ready? dtcm_ram_rdata : itcm_ready? itcm_ram_rdata : hpu_reg_ready? hpu_reg_rdata : 32'hdead_beaf;
    assign mem_ready = (!(latched_ext_itcm_ram_cs || latched_ext_dtcm_ram_cs)) && (dtcm_ready || itcm_ready || hpu_reg_ready);

    pico_mem #(
		.WORD_WIDTH	(`PICORV_ITCM_RAM_WW),
		.ADDR_WIDTH	(`PICORV_ITCM_RAM_AW),
		.DATA_WIDTH	(`PICORV_ITCM_RAM_DW),
		.MASK_WIDTH	(`PICORV_ITCM_RAM_MW),
		.RAM_SIZE	(`PICORV_ITCM_RAM_SZ)
	) itcm_ram (
		.clk(clk),
        .cs(itcm_ram_cs),
		.wen(itcm_ram_wen),
		.addr(itcm_ram_addr[`PICORV_ITCM_RAM_AW-1:0]),
		.wdata(itcm_ram_wdata),
		.rdata(itcm_ram_rdata),
		.ready(itcm_ready)
	);


    pico_mem #(
		.WORD_WIDTH	(`PICORV_DTCM_RAM_WW),
		.ADDR_WIDTH	(`PICORV_DTCM_RAM_AW),
		.DATA_WIDTH	(`PICORV_DTCM_RAM_DW),
		.MASK_WIDTH	(`PICORV_DTCM_RAM_MW),
		.RAM_SIZE	(`PICORV_DTCM_RAM_SZ)
	) dtcm_ram (
		.clk(clk),
        .cs(dtcm_ram_cs),
		.wen(dtcm_ram_wen),
		.addr(dtcm_ram_addr[`PICORV_DTCM_RAM_AW-1:0]),
		.wdata(dtcm_ram_wdata),
		.rdata(dtcm_ram_rdata),
		.ready(dtcm_ready)
	);

endmodule


module pico_mem  #(
	parameter WORD_WIDTH = 32,
	parameter ADDR_WIDTH = 16,
	parameter DATA_WIDTH = 8,
	parameter MASK_WIDTH = 4,
	parameter RAM_SIZE = 1024*64 // 64KB
)(
	input clk,
    input cs,
	input  [MASK_WIDTH-1 :0] wen,
	input  [ADDR_WIDTH-1 :0] addr,
	input  [WORD_WIDTH-1 :0] wdata,
	output [WORD_WIDTH-1 :0] rdata,
	output reg ready
);
    //wire [WORD_WIDTH-1 :0]  ram_din;
    wire [ADDR_WIDTH-3 :0]  ram_addr;
    //wire [WORD_WIDTH-1 :0]  ram_dout;
    wire                    ram_we;
    //wire [MASK_WIDTH-1 :0]  ram_wem;

    always @(posedge clk) begin
		ready <= !ready && cs;
    end
    
    assign ram_addr = addr[ADDR_WIDTH-1 :2];
    assign ram_we = cs && wen[0];
    
    
    /*
	reg [WORD_WIDTH-1: 0] mem_r [0:RAM_SIZE-1];
    
    always @(posedge clk) begin
        if(cs) begin
            rdata[7:   0] <= mem_r[addr];
            rdata[15:  8] <= mem_r[addr + 1];
            rdata[23: 16] <= mem_r[addr + 2];
            rdata[31: 24] <= mem_r[addr + 3];
        end
    end
    
    always @(posedge clk) begin
        if(cs) begin
            if (wen[0]) mem_r[addr]     <= wdata[ 7: 0];
            if (wen[1]) mem_r[addr + 1] <= wdata[15: 8];
            if (wen[2]) mem_r[addr + 2] <= wdata[23:16];
            if (wen[3]) mem_r[addr + 3] <= wdata[31:24];
        end
    end
    */
    
    sirv_sim_ram #(
        .DP(RAM_SIZE/4), // this is word size
        .FORCE_X2ZERO(0),
        .DW(WORD_WIDTH), // r/w data by word
        .MW(MASK_WIDTH),
        .AW(ADDR_WIDTH-2)
    ) ram_block(
        .clk(clk),
        .din(wdata),
        .addr(ram_addr),
        .cs(cs),
        .we(ram_we),
        .wem(wen),
        .dout(rdata)
    );

endmodule
