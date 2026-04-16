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
//   .br_eq     (xxxx), 
//   .br_lt     (xxxx), 
//   .br_ltu    (xxxx),
//   .opcode    (xxxx),    
//   .func7     (xxxx),    
//   .func3     (xxxx),    
//   .ALU_FUN   (xxxx),
//   .PC_SEL    (xxxx),
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
   input br_eq, 
   input br_lt, 
   input br_ltu,
   input [6:0] opcode,   //-  ir[6:0]
   input func7,          //-  ir[30]
   input [2:0] func3,    //-  ir[14:12]
   
   input int_taken,


   output logic [3:0] ALU_FUN,
   output logic [2:0] PC_SEL,
   output logic [1:0] srcA_SEL, 
   output logic [2:0] srcB_SEL, 
   output logic [1:0] RF_SEL
	);

   // Cast opcode to opcode_t enum type   
   opcode_t OPCODE; 
   assign OPCODE = opcode_t'(opcode);  

   // Cast input func3/func7 to enum types
   // for different opcodes
   branch_f3_t BRANCH_F3;
   assign BRANCH_F3 = branch_f3_t'(func3);
   
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

   sys_f3_t SYS_F3;
   assign SYS_F3 = sys_f3_t'(func3);
       
   always_comb
   begin 
      //- schedule all values to avoid latch
      PC_SEL   = PC_SEL_PC;
      srcA_SEL = RS1;
      srcB_SEL = RS2;
      RF_SEL   = PC4;
      ALU_FUN  = ALU_ADD;
		
      if (int_taken) begin
         PC_SEL = PC_SEL_MTVEC;
      end else begin

         case(OPCODE)
            LUI: begin
               ALU_FUN = ALU_LUI; 
               srcA_SEL = UTYPE;
               RF_SEL = ALU_RES; 
            end

            AUIPC: begin
               srcA_SEL = UTYPE;
               srcB_SEL = ALU_PC;
               ALU_FUN = ALU_ADD;
               RF_SEL = ALU_RES;
            end

            JAL: begin
               PC_SEL = PC_SEL_JAL;
               RF_SEL = PC4;
            end

         JALR: begin
               PC_SEL = PC_SEL_JALR;
               RF_SEL = PC4;
            end

            BRANCH: begin
               case(BRANCH_F3)  
                  BEQ: begin
                     if (br_eq) begin
                        PC_SEL = PC_SEL_BRANCH;
                     end else begin
                        PC_SEL = PC_SEL_PC;
                     end
                  end

                  BNE: begin
                     if (!br_eq) begin
                        PC_SEL = PC_SEL_BRANCH;;
                     end else begin
                        PC_SEL = PC_SEL_PC;
                     end
                  end

                  BLT: begin
                     if (br_lt) begin
                        PC_SEL = PC_SEL_BRANCH;
                     end else begin
                        PC_SEL = PC_SEL_PC;
                     end
                  end

                  BGE: begin
                     if (!br_lt) begin
                        PC_SEL = PC_SEL_BRANCH;
                     end else begin
                        PC_SEL = PC_SEL_PC;
                     end
                  end

                  BLTU: begin
                     if (br_ltu) begin
                        PC_SEL = PC_SEL_BRANCH;
                     end else begin
                        PC_SEL = PC_SEL_PC;
                     end
                  end

                  BGEU: begin
                     if (!br_ltu) begin
                        PC_SEL = PC_SEL_BRANCH;
                     end else begin
                        PC_SEL = PC_SEL_PC;
                     end
                  end

                  default: begin
                     PC_SEL = PC_SEL_PC;
                  end
               endcase
            end

            LOAD: begin
               ALU_FUN = ALU_ADD; 
               srcA_SEL = RS1; 
               srcB_SEL = ITYPE; 
               RF_SEL = DOUT2;
            end

            STORE: begin
               ALU_FUN = ALU_ADD; 
               srcA_SEL = RS1; 
               srcB_SEL = STYPE;
            end


            OP_IMM: begin
               
               srcA_SEL = RS1; 
               srcB_SEL = ITYPE;
               RF_SEL = ALU_RES; 
               
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
                     PC_SEL = PC_SEL_PC; 
                     ALU_FUN = ALU_DEADBEEF;
                     srcA_SEL = RS1; 
                     srcB_SEL = RS2; 
                     RF_SEL = PC4; 
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

            OP_SYS: begin

               case (SYS_F3) 
                  CSRRW: begin
                     RF_SEL = CSR; // write csr rd to reg file
                     srcA_SEL = RS1; // copy rs1 to alu_res
                     srcB_SEL = RS2; // not used, just setting for completeness
                     ALU_FUN = ALU_LUI; // LUI is just a copy in the ALU
                     PC_SEL = PC_SEL_PC;
                  end

                  CSRRC: begin
                     ALU_FUN = ALU_AND; // clear bits
                     srcA_SEL = NRS1; // inverted rs1
                     srcB_SEL = CSR_RD; // current rd
                     RF_SEL = CSR; // write csr to reg file
                     PC_SEL = PC_SEL_PC;
                  end

                  CSRRS: begin
                     ALU_FUN = ALU_OR; // set bits
                     srcA_SEL = RS1; // rs1
                     srcB_SEL = CSR_RD; // current rd
                     RF_SEL = CSR; // write csr to reg file
                     PC_SEL = PC_SEL_PC;
                  end

                  MRET: begin
                     PC_SEL = PC_SEL_MEPC; // Return to MEPC

                  end
               endcase

            end

            default:
            begin
               PC_SEL = PC_SEL_PC;
               srcA_SEL = RS1; 
               srcB_SEL = RS2; 
               RF_SEL = PC4;  
               ALU_FUN = ALU_DEADBEEF;
            end
         endcase
      end
   end

endmodule