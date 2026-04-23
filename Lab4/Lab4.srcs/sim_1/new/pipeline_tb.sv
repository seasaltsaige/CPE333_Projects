`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/19/2026 12:06:47 PM
// Design Name: 
// Module Name: pipeline_tb
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


module pipeline_tb();

    logic CLK = 0;
    logic [4:0] buttons;
    logic [15:0] switches;
    logic [15:0] leds;
    logic [7:0] segs;
    logic [3:0] an;    

    OTTER_Wrapper TB_OTTER_Wrapper(
        .clk      (CLK),
        .buttons  (buttons),
        .switches (switches),
        .leds     (leds),
        .segs     (segs),
        .an       (an)
    );    

    initial forever #1 CLK = !CLK; 
   
    initial begin
        buttons = 5'b01000; // reset
        #25
        buttons = 5'b00000;
        #100
        $finish;
    end

endmodule
