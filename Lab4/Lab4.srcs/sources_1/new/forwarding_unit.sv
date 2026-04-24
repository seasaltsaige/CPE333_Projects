`timescale 1ns / 1ps
`include "riscv_instruction_types.svh";
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/23/2026 04:18:22 PM
// Design Name: 
// Module Name: forwarding_unit
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


module forwarding_unit(
    input stage_info EX, MEM, WB,
    output forward_sel forward_a_sel, forward_b_sel
    );

    always_comb begin

        forward_a_sel = DEFAULT;
        forward_b_sel = DEFAULT;
        // RS1 forwarding
        if (EX.rs1_used) begin
            if (MEM.reg_we && (MEM.rd != 0) && (MEM.rd == EX.rs1)) begin
                forward_a_sel = EM;
            end
            else if (WB.reg_we && (WB.rd != 0) && (WB.rd == EX.rs1)) begin
                forward_a_sel = MW;
            end
        end

        // RS2 forwarding
        if (EX.rs2_used) begin
            if (MEM.reg_we && (MEM.rd != 0) && (MEM.rd == EX.rs2)) begin
                forward_b_sel = EM;
            end
            else if (WB.reg_we && (WB.rd != 0) && (WB.rd == EX.rs2)) begin
                forward_b_sel = MW;
            end
        end
            
    end
endmodule
