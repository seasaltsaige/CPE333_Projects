`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/24/2026 09:56:18 PM
// Design Name: 
// Module Name: riscv_alu
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


module riscv_alu(
    input [3:0] alu_fun,
    input [31:0] srcA,
    input [31:0] srcB,
    output reg [31:0] result
);

    parameter [3:0] alu_add=4'b0000, 
                   alu_sub=4'b1000, 
                   alu_or=4'b0110, 
                   alu_and=4'b0111, 
                   alu_xor=4'b0100,
                   alu_srl=4'b0101,
                   alu_sll=4'b0001,
                   alu_sra=4'b1101,
                   alu_slt=4'b0010,
                   alu_sltu=4'b0011,
                   alu_lui=4'b1001;


    always @(*) begin
        case (alu_fun)
        
            alu_add: begin
                result = srcA + srcB;
            end
            
            alu_sub: begin
                result = srcA - srcB;
            end
            
            alu_or: begin
                result = srcA | srcB;
            end
            
            alu_and: begin
                result = srcA & srcB;
            end
            
            alu_xor: begin
                result = srcA ^ srcB;
            end
            
            alu_srl: begin
                result = srcA >> srcB[4:0];
            end
            
            alu_sll: begin
                result = srcA << srcB[4:0];
            end
            
            alu_sra: begin
                result = $signed(srcA) >>> srcB[4:0];
            end
        
            alu_slt: begin
                if ($signed(srcA) < $signed(srcB)) begin
                    result = 32'd1;
                end else begin 
                    result = 32'd0;
                end
            end
            
            alu_sltu: begin
                if (srcA < srcB) begin
                    result = 32'd1;
                end else begin
                    result = 32'd0;
                end
            end
            
            alu_lui: begin
                result = srcA;
            end
            
            default: begin
                result = 32'hDEADBEEF;
            end
        
        endcase
    end
    
    
    
endmodule
