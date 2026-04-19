`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/12/2026 02:51:57 PM
// Design Name: 
// Module Name: TB
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module TB();
    
    logic CLK=0,BTNL,BTNC,PS2Clk,PS2Data,VGA_HS,VGA_VS,Tx;
    logic [15:0] SWITCHES,LEDS;
    logic [7:0] CATHODES,VGA_RGB;
    logic [3:0] ANODES;
    
    logic [63:0] counter;
   
    OTTER_Wrapper wrapper (
       .CLK(CLK),
       .BTNL(BTNL),
       .BTNC(BTNC),
       .SWITCHES(SWITCHES),
       .PS2Clk(PS2Clk),
       .PS2Data(PS2Data),
       .LEDS(LEDS),
       .CATHODES(CATHODES),
       .ANODES(ANODES),
       .VGA_RGB(VGA_RGB),
       .VGA_HS(VGA_HS),
       .VGA_VS(VGA_VS),
       .Tx(Tx)
   );

    initial forever  #1  CLK =  ! CLK; 
   
       
    initial begin
        counter = 0;
        BTNC=1;
        #600 
        BTNC=0;
        SWITCHES=15'd0;
    end
    
   
    always @(*) begin
        if (CLK == 1) begin
            counter = counter + 1;
        end
    end
    
       
  /*  initial begin
         if(ld_use_hazard)
            $display("%t -------> Stall ",$time);
        if(branch_taken)
            $display("%t -------> branch taken",$time); 
      end*/

endmodule
