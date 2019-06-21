`include "picorv_defines.v"

`timescale 1 ns / 1 ps

`ifndef VERILATOR
module testbench #(
	parameter AXI_TEST = 0,
	parameter VERBOSE = 0
);
	reg clk = 1;
	reg resetn = 0;
	wire trap;

	always #5 clk = ~clk;
	
	always @(posedge clk) begin
	   if (resetn && trap) begin
	       $display("ERROR!");
	       $finish;
	   end
	end
	
  
   always @(posedge clk) begin
       if(top.uut.dtcm_ram_cs && top.uut.dtcm_ram_wen[0]) begin
           if (top.uut.mem_addr >= 32'h0010_0da4 && top.uut.mem_addr <=32'h0010_0dbc) begin
               $display("IRQ WRITE DATA %08x to %08x", top.uut.dtcm_ram_wdata, top.uut.mem_addr);
           end
       end
   end
  
	
	initial begin
            $display("============ 0 ===========");
    end

	initial begin
		repeat (100) @(posedge clk);
		resetn <= 1;
	end

	initial begin
		if ($test$plusargs("vcd")) begin
			$dumpfile("testbench.vcd");
			$dumpvars(0, testbench);
		end
		repeat (1000000) @(posedge clk);
		$display("TIMEOUT");
		$finish;
	end

	wire trace_valid;
	wire [35:0] trace_data;
	integer trace_file;

	initial begin
		if ($test$plusargs("trace")) begin
			trace_file = $fopen("testbench.trace", "w");
			repeat (10) @(posedge clk);
			while (!trap) begin
				@(posedge clk);
				if (trace_valid)
					$fwrite(trace_file, "%x\n", trace_data);
			end
			$fclose(trace_file);
			$display("Finished writing testbench.trace.");
		end
	end
	
	initial begin
    	$display("============ 1 ===========");
    end

	picorv32_wrapper top (
		.clk(clk),
		.resetn(resetn),
		.trap(trap),
		.trace_valid(trace_valid),
		.trace_data(trace_data)
	);
endmodule
`endif

module picorv32_wrapper #(
    parameter DPU_REG_ADDR_WTH = 13,
    parameter DPU_REG_DATA_WTH = 32
)(
	input clk,
	input resetn,
	output trap,
	output trace_valid,
	output [35:0] trace_data
);
    wire [DPU_REG_ADDR_WTH-1 : 0]          riscv_regmap__waddr_o;
    wire                                   riscv_regmap__we_o;
    wire [DPU_REG_DATA_WTH-1 : 0]          riscv_regmap__wdata_o;
    wire [DPU_REG_ADDR_WTH-1 : 0]          riscv_regmap__raddr_o;
    wire                                   riscv_regmap__re_o;
    wire [DPU_REG_DATA_WTH-1 : 0]          riscv_regmap__rdata_i;
    wire                                   riscv_regmap__rdata_act_i;

	// external interrupts
    wire [7:0] 	riscv_regmap__intr_i;
	wire 		ps_riscv__start_conv_i;

	/* External access to ITCM/DTCM */
	/* itcm interface */
    wire            					ext_itcm_ram_cs  ;
    wire  [31:0]    					ext_itcm_ram_addr;
    wire  [`PICORV_ITCM_RAM_MW-1:0]    	ext_itcm_ram_wen ;
    wire  [`PICORV_ITCM_RAM_WW-1:0]   	ext_itcm_ram_wdata ;
    wire  [`PICORV_ITCM_RAM_WW-1:0]    	ext_itcm_ram_rdata;
    wire            					ext_itcm_ready;
    /* dtcm interface */
    wire            					ext_dtcm_ram_cs  ;
    wire  [31:0]    					ext_dtcm_ram_addr;
    wire  [`PICORV_DTCM_RAM_MW-1:0]    	ext_dtcm_ram_wen ;
    wire  [`PICORV_DTCM_RAM_WW-1:0]    	ext_dtcm_ram_wdata ;
    wire  [`PICORV_DTCM_RAM_WW-1:0]    	ext_dtcm_ram_rdata;
    wire            					ext_dtcm_ready;


	reg [31:0] irq;
	always @* begin
		irq = 32'h0000_0000;
	
		if(&uut.cpu.count_cycle[12:0]) begin
		  irq = 8 << uut.cpu.count_cycle[16:13];
		  $display("IRQ %08x IS RAISED", irq);
		end
		if(uut.cpu.count_cycle[17] == 1)begin
		      $finish;
		end
	end
	
	assign ps_riscv__start_conv_i = irq[11];
	assign riscv_regmap__intr_i = irq[10:3];


    picosoc  #(
		.DPU_REG_ADDR_WTH  (DPU_REG_ADDR_WTH),
    	.DPU_REG_DATA_WTH  (DPU_REG_DATA_WTH)
	) uut(
		.clk            (clk            ),
		.resetn         (resetn         ),
		.trap           (trap           ),
		.riscv_regmap__waddr_o		(riscv_regmap__waddr_o		),
		.riscv_regmap__we_o			(riscv_regmap__we_o		),
		.riscv_regmap__wdata_o		(riscv_regmap__wdata_o		),
		.riscv_regmap__raddr_o		(riscv_regmap__raddr_o		),
		.riscv_regmap__re_o			(riscv_regmap__re_o		),
		.riscv_regmap__rdata_i		(riscv_regmap__rdata_i		),
		.riscv_regmap__rdata_act_i	(riscv_regmap__rdata_act_i	),
		.riscv_regmap__intr_i (riscv_regmap__intr_i),
		.ps_riscv__start_conv_i (ps_riscv__start_conv_i),
		.ext_itcm_ram_cs  			(1'b0 			),
		.ext_itcm_ram_addr			(ext_itcm_ram_addr			),
		.ext_itcm_ram_wen 			(ext_itcm_ram_wen 			),
		.ext_itcm_ram_wdata 		(ext_itcm_ram_wdata 		),
		.ext_itcm_ram_rdata			(ext_itcm_ram_rdata		),
		.ext_itcm_ready				(ext_itcm_ready			),
		.ext_dtcm_ram_cs  			(1'b0  			),
		.ext_dtcm_ram_addr			(ext_dtcm_ram_addr			),
		.ext_dtcm_ram_wen 			(ext_dtcm_ram_wen 			),
		.ext_dtcm_ram_wdata 		(ext_dtcm_ram_wdata 		),
		.ext_dtcm_ram_rdata			(ext_dtcm_ram_rdata		),
		.ext_dtcm_ready				(ext_dtcm_ready			)
	);

    external_mem ext_mem(
        .clk    (clk            ),
        .cs     (riscv_regmap__we_o ||  riscv_regmap__re_o),
	    .wen    (riscv_regmap__we_o? 4'b1 : 4'b0  ),
	    .addr   (riscv_regmap__we_o? riscv_regmap__waddr_o: riscv_regmap__re_o? riscv_regmap__raddr_o: 32'hffff_ffff),
	    .wdata  (riscv_regmap__we_o? riscv_regmap__wdata_o: 32'hdead_beef  ),
	    .rdata  (riscv_regmap__rdata_i  ),
		.ready 	(riscv_regmap__rdata_act_i)
    );


	reg [1023:0] itcm_file;
	reg [1023:0] dtcm_file;
	initial begin
		itcm_file = "/home/xiatian/Work/riscv_software/hpu_reg_version_software/picorv/output/1_itcm.verilog";
		$display("READ IN ITCM DATA.");
		$readmemh(itcm_file, uut.itcm_ram.mem);
		$display("FIRST WORD IN ITCM IS %08x", uut.itcm_ram.mem[0]);
		//$display("SCOND WORD IN ITCM IS %08x", picosoc.itcm_ram.mem[1]);
		
		dtcm_file = "/home/xiatian/Work/riscv_software/hpu_reg_version_software/picorv/output/1_dtcm.verilog";
        $display("READ IN DTCM DATA");
        $readmemh(dtcm_file, uut.dtcm_ram.mem);
        $display("FIRST WORD IN DTCM IS %08x", uut.dtcm_ram.mem[0]);
	end
	

endmodule


module external_mem (
    input clk,
    input cs,
	input [3:0] wen,
	input [31:0] addr,
	input [31:0] wdata,
	output reg [31:0] rdata,
	output reg ready
);

	always @(posedge clk) begin
		ready <= !ready && cs;
    end

	always @(posedge clk) begin
        if(cs && (!wen[0]) ) begin
            rdata <= 32'hdeed_dead;
            $display("EXTERNAL MEMORY READ DATA AT %08x", addr);
            $finish;
        end
	end

    always @(posedge clk) begin
        if(cs && (wen[0]) ) begin
            $display("EXTERNAL MEMORY WRITE DATA %08x to %08x", wdata, addr);
            // $finish;
        end
	end
endmodule