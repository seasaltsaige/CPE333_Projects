`timescale 1ns / 1ps
`include "riscv_instruction_types.svh";
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/23/2026 04:18:22 PM
// Design Name: 
// Module Name: control_hazard_unit
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


module hazard_unit(
        input stage_info DE, EX, MEM, WB,

        input logic branch_taken,
        
        output logic pc_en,
        output logic pc_sel,
        output logic FD_en,
        output logic flush_DE,
        output logic flush_EX,

        output forward_sel forward_a_sel, forward_b_sel
    );


    logic stall_FE, stall_DE, stall_flush_EX, ctrl_flush_EX;


    forwarding_unit hazard_forwarding_unit(
        .EX            (EX),
        .MEM           (MEM),
        .WB            (WB),
        .forward_a_sel (forward_a_sel),
        .forward_b_sel (forward_b_sel)
    );

    stall_unit hazard_stall_unit(
        .DE       (DE),
        .EX       (EX),
        .stall_FE (stall_FE),
        .stall_DE (stall_DE),
        .flush_EX (stall_flush_EX)
    );

    control_hazard_unit hzrd_control_hazard_unit(
        .branch_taken (branch_taken),
        .pc_sel       (pc_sel),
        .flush_DE     (flush_DE),
        .flush_EX     (ctrl_flush_EX)
    );

    assign pc_en = ~stall_FE;
    assign FD_en = ~stall_DE;
    
    assign flush_EX = stall_flush_EX | ctrl_flush_EX;
    
endmodule
