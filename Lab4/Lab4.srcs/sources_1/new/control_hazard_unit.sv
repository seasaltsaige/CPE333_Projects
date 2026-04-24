`timescale 1ns / 1ps
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


module control_hazard_unit(
    input logic branch_taken,

    output logic pc_sel,
    output logic flush_DE,
    output logic flush_EX
    );

    assign pc_sel = branch_taken;
    assign flush_DE = branch_taken;
    assign flush_EX = branch_taken;
endmodule
