`timescale 1ns / 1ps
///////////////////////////////////////////////////////////////////////////
// Company: Ratner Surf Designs
// Engineer: James Ratner
// 
// Create Date: 01/29/2019 04:56:13 PM
// Design Name: 
// Module Name: CU_DCDR
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies:
// 
// Instantiation Template:
//
// CU_DCDR my_cu_dcdr(
//   .opcode    (xxxx),    
//   .func7     (xxxx),    
//   .func3     (xxxx),    
//   .ALU_FUN   (xxxx),
//   .srcA_SEL  (xxxx),
//   .srcB_SEL  (xxxx), 
//   .RF_SEL    (xxxx)   );
//
// 
// Revision:
// Revision 1.00 - Created (02-01-2020) - from Paul, Joseph, & Celina
//          1.01 - (02-08-2020) - removed  else's; fixed assignments
//          1.02 - (02-25-2020) - made all assignments blocking
//          1.03 - (05-12-2020) - reduced func7 to one bit
//          1.04 - (05-31-2020) - removed misleading code
//          1.05 - (12-10-2020) - added comments
//          1.06 - (02-11-2021) - fixed formatting issues
//          1.07 - (12-26-2023) - changed signal names
//
// Additional Comments:
// 
///////////////////////////////////////////////////////////////////////////

`include "riscv_instruction_types.svh"

module CU_DCDR(   
   input [6:0] opcode,   //-  ir[6:0]
   input func7,          //-  ir[30]
   input [2:0] func3,    //-  ir[14:12]
   
   input int_taken,
   output alu_fun ALU_FUN,
   output alu_src_a_t srcA_SEL, 
   output alu_src_b_t srcB_SEL, 
   output extender_sel_t extender_SEL,
   output bag_base_sel_t bag_SEL,
   output rf_sel_t RF_SEL
	);

   // Cast opcode to opcode_t enum type   
   opcode_t OPCODE; 
   assign OPCODE = opcode_t'(opcode);  

   // Cast input func3/func7 to enum types
   // for different opcodes
   immed_f3_t IMMED_F3;
   assign IMMED_F3 = immed_f3_t'(func3);
   
   reg_f3_t REG_F3;
   assign REG_F3 = reg_f3_t'(func3);

   immed_f7_t IMMED_F7;
   assign IMMED_F7 = immed_f7_t'(func7);
   
   reg_add_sub_f7_t REG_AS_F7;
   assign REG_AS_F7 = reg_add_sub_f7_t'(func7);
    
   reg_r_shft_f7_t REG_RSHFT_F7;
   assign REG_RSHFT_F7 = reg_r_shft_f7_t'(func7);
       
   always_comb
   begin 
      //- schedule all values to avoid latch
      // PC_SEL   = PC_SEL_PC;
      srcA_SEL = RS1;
      srcB_SEL = RS2;
      RF_SEL   = PC4;
      ALU_FUN  = ALU_ADD;
      extender_SEL = EXT_ITYPE;
      bag_SEL = BAG_PC;
		

      case(OPCODE)
         LUI: begin
            ALU_FUN = ALU_LUI; 
            srcA_SEL = UTYPE;
            RF_SEL = ALU_RES;
            extender_SEL = EXT_UTYPE;
         end
         AUIPC: begin
            srcA_SEL = UTYPE;
            srcB_SEL = ALU_PC;
            ALU_FUN = ALU_ADD;
            RF_SEL = ALU_RES;
            extender_SEL = EXT_UTYPE;
         end
         JAL: begin
            RF_SEL = PC4;
            extender_SEL = EXT_JTYPE;
            bag_SEL = BAG_PC;
         end
         JALR: begin
            RF_SEL = PC4;
            extender_SEL = EXT_ITYPE;
            bag_SEL = BAG_RS;
         end
         LOAD: begin
            ALU_FUN = ALU_ADD; 
            srcA_SEL = RS1; 
            srcB_SEL = ITYPE; 
            RF_SEL = DOUT2;
            extender_SEL = EXT_ITYPE;
         end
         STORE: begin
            ALU_FUN = ALU_ADD; 
            srcA_SEL = RS1; 
            srcB_SEL = STYPE;
            extender_SEL = EXT_STYPE;
         end
         BRANCH: begin
            extender_SEL = EXT_BTYPE;
            bag_SEL = BAG_PC;
         end
         OP_IMM: begin
            
            srcA_SEL = RS1; 
            srcB_SEL = ITYPE;
            RF_SEL = ALU_RES; 
            extender_SEL = EXT_ITYPE;
            
            case(IMMED_F3)
               ADDI: begin // ADDI
                  ALU_FUN = ALU_ADD;
               end
               SLTI: begin // SLTI
                  ALU_FUN = ALU_SLT; // slt
               end
               SLTU: begin // SLTIU
                  ALU_FUN = ALU_SLTU; // sltu
               end
               ORI: begin // ORI
                  ALU_FUN = ALU_OR; // or
               end
               XORI: begin // XORI
                  ALU_FUN = ALU_XOR; // xor
               end
               ANDI: begin // ANDI
                  ALU_FUN = ALU_AND; // and
               end
               SLLI: begin // SLLI
                  ALU_FUN = ALU_SLL; // sll
               end
               IMMED_R_SHFT: begin
                  case(IMMED_F7)
                     IMMED_SRLI: begin // SRLI
                        ALU_FUN = ALU_SRL; // srl
                     end
                     IMMED_SRA: begin // SRAI
                        ALU_FUN = ALU_SRA; // sra
                     end
                  endcase
               end
               
               default: begin
                  ALU_FUN = ALU_DEADBEEF;
                  srcA_SEL = RS1; 
                  srcB_SEL = RS2; 
                  RF_SEL = PC4;
                  extender_SEL = EXT_ITYPE; 
               end
            endcase
         end
         OP_RG3: begin
            srcA_SEL = RS1;
            srcB_SEL = RS2;
            RF_SEL = ALU_RES;
            case (REG_F3)
               ADD_SUB: begin // ADD + SUB
                  case (REG_AS_F7)
                     ADD: begin // ADD
                        ALU_FUN = ALU_ADD;
                     end
                     SUB: begin // SUB
                        ALU_FUN = ALU_SUB;
                     end
                  endcase
               end
               SLL: begin // SLL
                  ALU_FUN = ALU_SLL;
               end
               SLT: begin // SLT
                  ALU_FUN = ALU_SLT;
               end
               SLTU: begin // SLTU
                  ALU_FUN = ALU_SLTU;
               end
               XOR: begin // XOR
                  ALU_FUN = ALU_XOR;
               end
               REG_R_SHFT: begin // SRL + SRA
               case (REG_RSHFT_F7) 
                     REG_SRL: begin // SRL
                        ALU_FUN = ALU_SRL;
                     end
                     REG_SRA: begin // SRA
                        ALU_FUN = ALU_SRA;
                     end
                  endcase
               end
               OR: begin // OR
                  ALU_FUN = ALU_OR;
               end
               AND: begin // AND
                  ALU_FUN = ALU_AND;
               end
               default: begin
                  srcA_SEL = RS1;
                  srcB_SEL = RS2;
                  RF_SEL = PC4;
                  ALU_FUN = ALU_DEADBEEF;
               end
            endcase
         end
         default:
         begin
            srcA_SEL = RS1; 
            srcB_SEL = RS2; 
            RF_SEL = PC4;  
            ALU_FUN = ALU_DEADBEEF;
            extender_SEL = EXT_ITYPE;
         end
      endcase
   end

endmodule