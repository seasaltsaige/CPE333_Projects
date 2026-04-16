`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/12/2026 02:54:44 PM
// Design Name: 
// Module Name: BRANCH_COND_GEN
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


module BRANCH_COND_GEN(
        input [31:0] rs1,
        input [31:0] rs2,
        output reg br_eq,
        output reg br_lt,
        output reg br_ltu
    );
    
    always @(*) begin
        br_eq = $signed(rs1) == $signed(rs2);
        br_lt = $signed(rs1) < $signed(rs2);
        br_ltu = rs1 < rs2;
    end

endmodule
