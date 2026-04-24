`timescale 1ns / 1ps
`include "riscv_instruction_types.svh";
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


module branch_addr_gen(
        input [31:0] base_addr,
        input [31:0] immed, 
        output logic [31:0] branch_target
    );
    
    assign branch_target = base_addr + immed;
    
endmodule
