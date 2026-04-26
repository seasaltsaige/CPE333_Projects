`timescale 1ns / 1ps
`include "riscv_instruction_types.svh";
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/23/2026 04:18:22 PM
// Design Name: 
// Module Name: stall_unit
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


module stall_unit(
    input stage_info DE, EX,
    output logic stall_FE,
    output logic stall_DE,
    output logic flush_EX
    );


    logic is_hazard;
    assign is_hazard = (
        EX.mem_re_2 && (
         (EX.rd == DE.rs1 && DE.rs1_used) || 
         (EX.rd == DE.rs2 && DE.rs2_used)
        ) && (EX.rd != 0) 
    );

    assign stall_FE = is_hazard;
    assign stall_DE = is_hazard;
    assign flush_EX = is_hazard;

endmodule
