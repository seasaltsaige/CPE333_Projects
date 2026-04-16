`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Cal Poly SLO
// Engineer: Saige Sloan
// 
// Create Date: 01/30/2026 06:17:01 PM
// Design Name: Immediate Generator
// Module Name: immed_gen
// Project Name: Generators
// Target Devices: Basys3 (xc7a35tcpg236-1)
// Tool Versions: Vivado 2025.2
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module immed_gen(
        input [31:0] ir,
        output reg [31:0] j_type,
        output reg [31:0] b_type,
        output reg [31:0] u_type,
        output reg [31:0] i_type,
        output reg [31:0] s_type
    );
    
    always @(*) begin
        //
        i_type <= { {21{ir[31]}}, ir[30:25], ir[24:20] };
    
        s_type <= { {21{ir[31]}}, ir[30:25], ir[11:7] };
        
        b_type <= { {20{ir[31]}}, ir[7], ir[30:25], ir[11:8], {1'b0} };
        
        u_type <= { ir[31:12], {12'b0} };
        
        j_type <= { {12{ir[31]}}, ir[19:12], ir[20], ir[30:21], {1'b0} };
    end
    
endmodule
