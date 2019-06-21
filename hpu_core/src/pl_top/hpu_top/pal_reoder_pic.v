// +FHDR------------------------------------------------------------------------
// XJTU IAIR Corporation All Rights Reserved
// -----------------------------------------------------------------------------
// FILE NAME  : pal_reoder_pic.v
// DEPARTMENT : CAG of IAIR
// AUTHOR     : chenfei
// AUTHOR'S EMAIL :fei.chen@mail.xjtu.edu.cn
// -----------------------------------------------------------------------------
// Ver 1.0  2019--04--25
// -----------------------------------------------------------------------------
// KEYWORDS   : pal_reoder_pic
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

module pal_reoder_pic #(
    parameter DDRIF_DATA_WTH  =   512,
    parameter MRA_ADDR_WTH    =   9,
    parameter PAL_W_NUM       =   8,
    parameter PAL_C_EXTEN_NUM =   16,
    parameter PIC_LINE_LEN    =   320
)(
    // clock & reset
    input                                   clk_i,
    input                                   rst_i,
    input                                   intr_clr_i,                
    output                                  regmap_ldmr_intr_reoder_o, 
    
    // data reoder enable
    input                                   reoder_en_i,
    // to mtrix write enable
    output                                  ldmr_mrx__we_o,
    output[MRA_ADDR_WTH-1 : 0]              ldmr_mrx__waddr_o,
    // to mtrix data
    output[DDRIF_DATA_WTH-1:  0]            ldmr_ddrintf__rdata_o,
    // to ddr_intf module
    input                                   ldmr_ddrintf__rdata_last_i,
    input                                   ldmr_ddrintf__rdata_vld_i,
    input [DDRIF_DATA_WTH-1:  0]            ldmr_ddrintf__rdata_i,
    output                                  ldmr_ddrintf__rdata_rdy_o
);
//======================================================================================================================
// Wire & Reg declaration
//======================================================================================================================
reg   [4:0]                                 line_3cycle_cnt;
reg   [1:0]                                 cycle_cnt;
reg   [8:0]                                 shift_cnt; 
reg   [8:0]                                 wea_cnt; 
reg                                         line_last_padding_en;
reg   [7:0]                                 wea_en;
wire  [7:0]                                 wea;

reg   [3*DDRIF_DATA_WTH -1 : 0]             ddr_intf_3data_shift;
reg   [48 -1 : 0]                           tail_2pixel_data;
wire  [71:0]                                ram_dina;
reg   [8:0]                                 ram_addra_offset; 
wire  [7:0]                                 ram_addra; 
reg   [7:0]                                 ram_addrb;
wire  [72*8-1:0]                            ram_doutb;

reg                                         ram_rd_en;
reg                                         ram_rd_en_dly0;
reg                                         ram_rd_en_dly1;
reg                                         ram_rd_en_dly2;
reg   [7:0]                                 ram_rd_cnt;
reg   [7:0]                                 ram_rd_cnt_dly0;
reg   [7:0]                                 ram_rd_cnt_dly1;
reg   [7:0]                                 ram_rd_cnt_dly2;

reg                                         line_last_padding_en_dly0;
reg                                         line_last_padding_en_dly1;
reg                                         line_last_padding_en_dly2;
reg                                         regmap_ldmr_intr;
reg                                         tail_en;

wire  [DDRIF_DATA_WTH-1:  0]                ldmr_ddrintf__rdata_minus;

//======================================================================================================================
// Instance
//======================================================================================================================
pal_reoder_buffer pal_reoder_buffer_ins0(
  .clka  (clk_i ),
  .ena   (reoder_en_i),
  .wea   (wea[0] ),
  .addra (ram_addra ),
  .dina  (ram_dina ),
  .clkb  (clk_i ),
  .enb   (reoder_en_i ),
  .addrb (ram_addrb ),
  .doutb (ram_doutb[72*0+: 72] )
);
pal_reoder_buffer pal_reoder_buffer_ins1(
  .clka  (clk_i ),
  .ena   (reoder_en_i),
  .wea   (wea[1] ),
  .addra (ram_addra ),
  .dina  (ram_dina ),
  .clkb  (clk_i ),
  .enb   (reoder_en_i ),
  .addrb (ram_addrb ),
  .doutb (ram_doutb[72*1+: 72] )
);
pal_reoder_buffer pal_reoder_buffer_ins2(
  .clka  (clk_i ),
  .ena   (reoder_en_i),
  .wea   (wea[2] ),
  .addra (ram_addra ),
  .dina  (ram_dina ),
  .clkb  (clk_i ),
  .enb   (reoder_en_i ),
  .addrb (ram_addrb ),
  .doutb (ram_doutb[72*2+: 72] )
);
pal_reoder_buffer pal_reoder_buffer_ins3(
  .clka  (clk_i ),
  .ena   (reoder_en_i),
  .wea   (wea[3] ),
  .addra (ram_addra ),
  .dina  (ram_dina ),
  .clkb  (clk_i ),
  .enb   (reoder_en_i ),
  .addrb (ram_addrb ),
  .doutb (ram_doutb[72*3+: 72] )
);
pal_reoder_buffer pal_reoder_buffer_ins4(
  .clka  (clk_i ),
  .ena   (reoder_en_i),
  .wea   (wea[4] ),
  .addra (ram_addra ),
  .dina  (ram_dina ),
  .clkb  (clk_i ),
  .enb   (reoder_en_i ),
  .addrb (ram_addrb ),
  .doutb (ram_doutb[72*4+: 72] )
);
pal_reoder_buffer pal_reoder_buffer_ins5(
  .clka  (clk_i ),
  .ena   (reoder_en_i),
  .wea   (wea[5] ),
  .addra (ram_addra ),
  .dina  (ram_dina ),
  .clkb  (clk_i ),
  .enb   (reoder_en_i ),
  .addrb (ram_addrb ),
  .doutb (ram_doutb[72*5+: 72] )
);
pal_reoder_buffer pal_reoder_buffer_ins6(
  .clka  (clk_i ),
  .ena   (reoder_en_i),
  .wea   (wea[6] ),
  .addra (ram_addra ),
  .dina  (ram_dina ),
  .clkb  (clk_i ),
  .enb   (reoder_en_i ),
  .addrb (ram_addrb ),
  .doutb (ram_doutb[72*6+: 72] )
);
pal_reoder_buffer pal_reoder_buffer_ins7(
  .clka  (clk_i ),
  .ena   (reoder_en_i),
  .wea   (wea[7] ),
  .addra (ram_addra ),
  .dina  (ram_dina ),
  .clkb  (clk_i ),
  .enb   (reoder_en_i ),
  .addrb (ram_addrb ),
  .doutb (ram_doutb[72*7+: 72] )
);
assign ldmr_ddrintf__rdata_minus = {
~ldmr_ddrintf__rdata_i[511],ldmr_ddrintf__rdata_i[510:  504 ],
~ldmr_ddrintf__rdata_i[503],ldmr_ddrintf__rdata_i[502:  496 ],
~ldmr_ddrintf__rdata_i[495],ldmr_ddrintf__rdata_i[494:  488 ],
~ldmr_ddrintf__rdata_i[487],ldmr_ddrintf__rdata_i[486:  480 ],
~ldmr_ddrintf__rdata_i[479],ldmr_ddrintf__rdata_i[478:  472 ],
~ldmr_ddrintf__rdata_i[471],ldmr_ddrintf__rdata_i[470:  464 ],
~ldmr_ddrintf__rdata_i[463],ldmr_ddrintf__rdata_i[462:  456 ],
~ldmr_ddrintf__rdata_i[455],ldmr_ddrintf__rdata_i[454:  448 ],
~ldmr_ddrintf__rdata_i[447],ldmr_ddrintf__rdata_i[446:  440 ],
~ldmr_ddrintf__rdata_i[439],ldmr_ddrintf__rdata_i[438:  432 ],
~ldmr_ddrintf__rdata_i[431],ldmr_ddrintf__rdata_i[430:  424 ],
~ldmr_ddrintf__rdata_i[423],ldmr_ddrintf__rdata_i[422:  416 ],
~ldmr_ddrintf__rdata_i[415],ldmr_ddrintf__rdata_i[414:  408 ],
~ldmr_ddrintf__rdata_i[407],ldmr_ddrintf__rdata_i[406:  400 ],
~ldmr_ddrintf__rdata_i[399],ldmr_ddrintf__rdata_i[398:  392 ],
~ldmr_ddrintf__rdata_i[391],ldmr_ddrintf__rdata_i[390:  384 ],
~ldmr_ddrintf__rdata_i[383],ldmr_ddrintf__rdata_i[382:  376 ],
~ldmr_ddrintf__rdata_i[375],ldmr_ddrintf__rdata_i[374:  368 ],
~ldmr_ddrintf__rdata_i[367],ldmr_ddrintf__rdata_i[366:  360 ],
~ldmr_ddrintf__rdata_i[359],ldmr_ddrintf__rdata_i[358:  352 ],
~ldmr_ddrintf__rdata_i[351],ldmr_ddrintf__rdata_i[350:  344 ],
~ldmr_ddrintf__rdata_i[343],ldmr_ddrintf__rdata_i[342:  336 ],
~ldmr_ddrintf__rdata_i[335],ldmr_ddrintf__rdata_i[334:  328 ],
~ldmr_ddrintf__rdata_i[327],ldmr_ddrintf__rdata_i[326:  320 ],
~ldmr_ddrintf__rdata_i[319],ldmr_ddrintf__rdata_i[318:  312 ],
~ldmr_ddrintf__rdata_i[311],ldmr_ddrintf__rdata_i[310:  304 ],
~ldmr_ddrintf__rdata_i[303],ldmr_ddrintf__rdata_i[302:  296 ],
~ldmr_ddrintf__rdata_i[295],ldmr_ddrintf__rdata_i[294:  288 ],
~ldmr_ddrintf__rdata_i[287],ldmr_ddrintf__rdata_i[286:  280 ],
~ldmr_ddrintf__rdata_i[279],ldmr_ddrintf__rdata_i[278:  272 ],
~ldmr_ddrintf__rdata_i[271],ldmr_ddrintf__rdata_i[270:  264 ],
~ldmr_ddrintf__rdata_i[263],ldmr_ddrintf__rdata_i[262:  256 ],
~ldmr_ddrintf__rdata_i[255],ldmr_ddrintf__rdata_i[254:  248 ],
~ldmr_ddrintf__rdata_i[247],ldmr_ddrintf__rdata_i[246:  240 ],
~ldmr_ddrintf__rdata_i[239],ldmr_ddrintf__rdata_i[238:  232 ],
~ldmr_ddrintf__rdata_i[231],ldmr_ddrintf__rdata_i[230:  224 ],
~ldmr_ddrintf__rdata_i[223],ldmr_ddrintf__rdata_i[222:  216 ],
~ldmr_ddrintf__rdata_i[215],ldmr_ddrintf__rdata_i[214:  208 ],
~ldmr_ddrintf__rdata_i[207],ldmr_ddrintf__rdata_i[206:  200 ],
~ldmr_ddrintf__rdata_i[199],ldmr_ddrintf__rdata_i[198:  192 ],
~ldmr_ddrintf__rdata_i[191],ldmr_ddrintf__rdata_i[190:  184 ],
~ldmr_ddrintf__rdata_i[183],ldmr_ddrintf__rdata_i[182:  176 ],
~ldmr_ddrintf__rdata_i[175],ldmr_ddrintf__rdata_i[174:  168 ],
~ldmr_ddrintf__rdata_i[167],ldmr_ddrintf__rdata_i[166:  160 ],
~ldmr_ddrintf__rdata_i[159],ldmr_ddrintf__rdata_i[158:  152 ],
~ldmr_ddrintf__rdata_i[151],ldmr_ddrintf__rdata_i[150:  144 ],
~ldmr_ddrintf__rdata_i[143],ldmr_ddrintf__rdata_i[142:  136 ],
~ldmr_ddrintf__rdata_i[135],ldmr_ddrintf__rdata_i[134:  128 ],
~ldmr_ddrintf__rdata_i[127],ldmr_ddrintf__rdata_i[126:  120 ],
~ldmr_ddrintf__rdata_i[119],ldmr_ddrintf__rdata_i[118:  112 ],
~ldmr_ddrintf__rdata_i[111],ldmr_ddrintf__rdata_i[110:  104 ],
~ldmr_ddrintf__rdata_i[103],ldmr_ddrintf__rdata_i[102:  096 ],
~ldmr_ddrintf__rdata_i[095],ldmr_ddrintf__rdata_i[094:  088 ],
~ldmr_ddrintf__rdata_i[087],ldmr_ddrintf__rdata_i[086:  080 ],
~ldmr_ddrintf__rdata_i[079],ldmr_ddrintf__rdata_i[078:  072 ],
~ldmr_ddrintf__rdata_i[071],ldmr_ddrintf__rdata_i[070:  064 ],
~ldmr_ddrintf__rdata_i[063],ldmr_ddrintf__rdata_i[062:  056 ],
~ldmr_ddrintf__rdata_i[055],ldmr_ddrintf__rdata_i[054:  048 ],
~ldmr_ddrintf__rdata_i[047],ldmr_ddrintf__rdata_i[046:  040 ],
~ldmr_ddrintf__rdata_i[039],ldmr_ddrintf__rdata_i[038:  032 ],
~ldmr_ddrintf__rdata_i[031],ldmr_ddrintf__rdata_i[030:  024 ],
~ldmr_ddrintf__rdata_i[023],ldmr_ddrintf__rdata_i[022:  016 ],
~ldmr_ddrintf__rdata_i[015],ldmr_ddrintf__rdata_i[014:  008 ],
~ldmr_ddrintf__rdata_i[007],ldmr_ddrintf__rdata_i[006:  000 ]};

always  @(posedge clk_i) begin
    if(rst_i) begin
        line_3cycle_cnt <= 5'b0;
    end else if(ldmr_ddrintf__rdata_vld_i && ldmr_ddrintf__rdata_rdy_o && ldmr_ddrintf__rdata_last_i) begin   
        line_3cycle_cnt <= 5'b0;
    end else if(ldmr_ddrintf__rdata_vld_i && ldmr_ddrintf__rdata_rdy_o) begin
        line_3cycle_cnt <= line_3cycle_cnt + 5'b1;       
    end            
end  //notes: if line_3cycle_cnt > 30 ,that is error occuring.(just for line number : 640B x 3 = 64B x 30) 



always  @(posedge clk_i) begin
    if(rst_i) begin
        line_last_padding_en <= 1'b0;
    end else if(reoder_en_i&&ldmr_ddrintf__rdata_vld_i && ldmr_ddrintf__rdata_rdy_o && ldmr_ddrintf__rdata_last_i) begin   
        line_last_padding_en <= 1'b1;
    end else if(&cycle_cnt && (&shift_cnt[4:0])) begin
        line_last_padding_en <= 1'b0;       
    end            
end 

always  @(posedge clk_i) begin
    if(rst_i) begin
        cycle_cnt <= 2'b0;
    end else if(!reoder_en_i) begin
        cycle_cnt <= 2'b0;
    end else if(ldmr_ddrintf__rdata_vld_i && ldmr_ddrintf__rdata_rdy_o) begin
        cycle_cnt <= cycle_cnt + 2'b1;       
    end else if(&cycle_cnt && (&shift_cnt[4:0]))  begin         
        cycle_cnt <= 2'b0;
    end
end
always  @(posedge clk_i) begin
    if(rst_i) begin
        ddr_intf_3data_shift <= 0;
        tail_2pixel_data <= 0;
    end else if(&cycle_cnt && (&shift_cnt[4:0])) begin
        ddr_intf_3data_shift <= 0;
        tail_2pixel_data <= ddr_intf_3data_shift[47:0];
    end else if(!(&cycle_cnt) && ldmr_ddrintf__rdata_vld_i && ldmr_ddrintf__rdata_rdy_o) begin
        ddr_intf_3data_shift <= {ldmr_ddrintf__rdata_minus,ddr_intf_3data_shift[3*DDRIF_DATA_WTH -1:512]};
    end else if(&cycle_cnt && (!(&shift_cnt[4:0])) ) begin
        ddr_intf_3data_shift <= {48'b0,ddr_intf_3data_shift[3*DDRIF_DATA_WTH -1:48]};
    end         
end

always  @(posedge clk_i) begin
    if(rst_i) begin
        shift_cnt <= 'd0;
    end else if(shift_cnt == 9'd319) begin
        shift_cnt <= 'd0;
    end else if(&cycle_cnt ) begin
        shift_cnt <= shift_cnt + 'd1;
    end         
end
always  @(posedge clk_i) begin
    if(rst_i) begin
        wea_cnt <= 9'd0;
    end else if(wea_cnt  == 9'd319 )begin
        wea_cnt <= 9'd0;
    end else if(|wea) begin
        wea_cnt <= wea_cnt +  9'd1;  
    end
end


always  @(posedge clk_i) begin
    if(rst_i) begin
        wea_en <= 8'b0000_0001;
        ram_addra_offset <= 9'b0;
    end else if(|wea)begin
        case(wea_cnt)
            9'd0   : begin wea_en <= 8'b0000_0001; ram_addra_offset <=  9'd0  ; end
            9'd39  : begin wea_en <= 8'b0000_0010; ram_addra_offset <=  9'd40 ; end
            9'd79  : begin wea_en <= 8'b0000_0100; ram_addra_offset <=  9'd80 ; end
            9'd119 : begin wea_en <= 8'b0000_1000; ram_addra_offset <=  9'd120; end
            9'd159 : begin wea_en <= 8'b0001_0000; ram_addra_offset <=  9'd160; end
            9'd199 : begin wea_en <= 8'b0010_0000; ram_addra_offset <=  9'd200; end
            9'd239 : begin wea_en <= 8'b0100_0000; ram_addra_offset <=  9'd240; end
            9'd279 : begin wea_en <= 8'b1000_0000; ram_addra_offset <=  9'd280; end
            9'd319 : begin wea_en <= 8'b0000_0001; ram_addra_offset <=  9'd0; end
            default: begin wea_en <= wea_en;       ram_addra_offset <=  ram_addra_offset; end
        endcase                
    end
end
//always  @(posedge clk_i) begin
//    if(rst_i) begin
//        tail_en <= 1'b0;
//    end else begin
//        if(cycle_cnt==2'b0 && ldmr_ddrintf__rdata_vld_i && ldmr_ddrintf__rdata_rdy_o)begin
//            tail_en <= 1'b0;
//        end
//        case(shift_cnt)
//            9'd032 : begin tail_en <= 1'b1; end
//            9'd064 : begin tail_en <= 1'b1; end
//            9'd096 : begin tail_en <= 1'b1; end
//            9'd128 : begin tail_en <= 1'b1; end
//            9'd160 : begin tail_en <= 1'b1; end
//            9'd192 : begin tail_en <= 1'b1; end
//            9'd224 : begin tail_en <= 1'b1; end
//            9'd256 : begin tail_en <= 1'b1; end
//            9'd288 : begin tail_en <= 1'b1; end
//            default: begin tail_en <= 1'b0; end
//        endcase                
//    end
//end
always  @(posedge clk_i) begin
    if(rst_i) begin
        tail_en <= 1'b0;
    end else if((&shift_cnt[4:0]) && shift_cnt < 9'd319 ) begin
            tail_en <= 1'b1;
    end else if(cycle_cnt==2'b0 && ldmr_ddrintf__rdata_vld_i && ldmr_ddrintf__rdata_rdy_o)begin
            tail_en <= 1'b0;
    end
end

assign  wea =   (wea_en &  {8{(&cycle_cnt && (!(&shift_cnt[4:0])))}} ) 
              | (wea_en &  {8{((tail_en) && ldmr_ddrintf__rdata_vld_i && ldmr_ddrintf__rdata_rdy_o)}} ) 
              | (wea_en &  {8{line_last_padding_en && ((&shift_cnt[4:0])) }});
assign  ram_dina  = tail_en  ? ({ldmr_ddrintf__rdata_minus[23:0],tail_2pixel_data}  ) :
                   (&shift_cnt[4:0]) && line_last_padding_en ? {24'b0,ddr_intf_3data_shift[47:0]}     :  ddr_intf_3data_shift[71:0];
assign  ram_addra = tail_en  ? (shift_cnt-1- ram_addra_offset) : shift_cnt - ram_addra_offset;
assign  ldmr_ddrintf__rdata_rdy_o  =  (cycle_cnt[1:0]!= 2'b11) ? 1'b1 : 1'b0;
 
//read the ram data to hpu

always  @(posedge clk_i) begin
    line_last_padding_en_dly0 <= line_last_padding_en;
    line_last_padding_en_dly1 <= line_last_padding_en_dly0;
    line_last_padding_en_dly2 <= line_last_padding_en_dly1;
end

always  @(posedge clk_i) begin
    if(rst_i) begin
        ram_rd_en <= 1'b0;
    end else if(ram_rd_cnt >= 79) begin
        ram_rd_en <= 1'b0; 
    end else if(line_last_padding_en_dly2 && ( !line_last_padding_en_dly1)) begin
        ram_rd_en <= 1'b1;        
    end    
end

always  @(posedge clk_i) begin
    if(rst_i) begin
        ram_rd_cnt  <= 7'd0;
    end else if(ram_rd_en) begin
        ram_rd_cnt  <= ram_rd_cnt + 1; 
    end else begin
        ram_rd_cnt  <= 7'd0;  
    end
end

always  @(posedge clk_i) begin
    if(rst_i) begin
        ram_addrb <= 8'b0;
    end else if(ram_rd_en && (ram_rd_cnt[0]))begin
        ram_addrb <= ram_addrb + 8'b1;
    end else if(!ram_rd_en) begin
        ram_addrb <= 8'b0;        
    end      
end
always  @(posedge clk_i) begin
    ram_rd_en_dly0 <= ram_rd_en;
    ram_rd_en_dly1 <= ram_rd_en_dly0;
    ram_rd_en_dly2 <= ram_rd_en_dly1;
end
always  @(posedge clk_i) begin
    ram_rd_cnt_dly0 <= ram_rd_cnt;
    ram_rd_cnt_dly1 <= ram_rd_cnt_dly0;
    ram_rd_cnt_dly2 <= ram_rd_cnt_dly1;
end


assign  ldmr_mrx__we_o    = ram_rd_en_dly2  ;
assign  ldmr_mrx__waddr_o = ram_rd_cnt_dly2 ; 
assign  ldmr_ddrintf__rdata_o = ram_rd_en_dly1 && (!ram_rd_cnt_dly1[0])  ?  
                                {ram_doutb[567:504],ram_doutb[495:432],ram_doutb[423:360],ram_doutb[351:288],ram_doutb[279:216],ram_doutb[207:144],ram_doutb[135:072],ram_doutb[063:000]} :
                                ram_rd_en_dly1 && (ram_rd_cnt_dly1[0])   ? 
                                {56'b0,ram_doutb[575:568],56'b0,ram_doutb[503:496],56'b0,ram_doutb[431:424],56'b0,ram_doutb[359:352],56'b0,ram_doutb[287:280],56'b0,ram_doutb[215:208],56'b0,ram_doutb[143:136],56'b0,ram_doutb[071:064]} : 512'b0;

//generate the intr signal
always @(posedge clk_i) begin
    if(rst_i) begin
        regmap_ldmr_intr <= 1'b0;
    end else if(intr_clr_i) begin
        regmap_ldmr_intr <= 1'b0;
    end else if((ram_rd_cnt >= 79) ) begin
        regmap_ldmr_intr <= 1'b1;
    end 
end
assign regmap_ldmr_intr_reoder_o = regmap_ldmr_intr;
//======================================================================================================================
// just for simulation
//======================================================================================================================
// synthesis translate_off

// synthesis translate_on

//======================================================================================================================
// probe signals
//======================================================================================================================

endmodule