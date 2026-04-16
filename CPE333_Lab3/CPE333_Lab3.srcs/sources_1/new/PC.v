`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: CAL POLY SLO
// Engineer: Saige Sloan
// 
// Create Date: 01/15/2026 02:21:53 PM
// Design Name: Program Counter
// Module Name: main
// Project Name: RISCV Otter Program Counter
// Target Devices: Basys3 (xc7a35tcpg236-1)
// Tool  Versions: Vivado 2025.2
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module PC(
        input clk,
        input PC_RESET, // Reset signal used to set PC to 32'h0 address
        input PC_LD, // Load signal used to load next "MUX'd" address value 
        input [31:0] ADDR_MUX_OUT,
        output [31:0] PC_ADDR
    );
    
    
    // Main storage element for the program counter
    // Accepts input from the PC Mux
    // PC_LD will load whatever value is at the ADDR_MUX_OUT
    // PC_RESET will reset the PC to 32'h0
    reg_nb #(.n(32)) PROGRAM_CTR_REG (
        .data_in  (ADDR_MUX_OUT), 
        .ld       (PC_LD), 
        .clk      (clk), 
        .clr      (PC_RESET), 
        .data_out (PC_ADDR)
    ); 
    
endmodule