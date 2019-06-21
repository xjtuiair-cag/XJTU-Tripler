`timescale  1ns/1ps                                                             
// +FHDR------------------------------------------------------------------------
// XJTU IAIR Corporation All Rights Reserved                                    
// -----------------------------------------------------------------------------
// FILE NAME  : reg_dly.v                                                 
// DEPARTMENT : CAG of IAIR                                                     
// AUTHOR     : chenfei                                                         
// AUTHOR'S EMAIL :fei.chen@mail.xjtu.edu.cn                                    
// -----------------------------------------------------------------------------
// Ver 1.0  2018--12--03                                                        
// -----------------------------------------------------------------------------
// KEYWORDS   : reg_dly   XXX0  XXX2                                      
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



module reg_dly
#(
parameter width     = 8,  // width of register
parameter offset    = 0, // offset (left index) of register 
parameter delaynum  = 4
)
(
input                            clk   ,
input  [offset:(offset+width)-1] d     ,// data input   
output [offset:(offset+width)-1] q      // data output
);
     
reg [offset:(offset+width)-1]   q_delay[delaynum-1:0]; 
   
genvar i;  
generate   
    for (i = 0 ;i < delaynum; i=i+1) begin
        if(i == 0) begin
            always @(posedge clk)
                q_delay[i] <= d;
        end else begin
            always @(posedge clk)
                q_delay[i] <= q_delay[i-1];
        end 
    end
endgenerate

generate
    if(delaynum>0)    
    assign q=q_delay[delaynum-1];
    else 
    assign   q=d;
endgenerate
    
endmodule
