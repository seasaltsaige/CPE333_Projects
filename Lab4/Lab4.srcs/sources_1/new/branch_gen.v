`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Cal Poly SLO
// Engineer: Saige Sloan 
// 
// Create Date: 01/30/2026 06:17:01 PM
// Design Name: Branch Address Generator
// Module Name: branch_gen
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


module branch_gen(
        input [31:0] pc_addr,
        input [31:0] j_type,
        input [31:0] b_type,
        input [31:0] i_type,
        input [31:0] rs,
        
        output reg [31:0] jal,
        output reg [31:0] branch,
        output reg [31:0] jalr
    );
    
    
    always @(*) begin
        // X[rd] ← PC + 4; 
        // PC ← PC + sext(imm)
        jal <= pc_addr + j_type;

        // X[rd] ← PC+4; 
        // PC ← (X[rs1] + sext(imm)) & ~1
        jalr <= (rs + i_type) & ~1;

        // PC ← PC + sext(imm) 
        branch <= pc_addr + b_type;
    end
    


    
endmodule
