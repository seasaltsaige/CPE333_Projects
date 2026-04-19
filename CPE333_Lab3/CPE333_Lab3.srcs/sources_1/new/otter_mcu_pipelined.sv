`timescale 1ns / 1ps
`include "riscv_instruction_types.svh";
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:  J. Callenes
// 
// Create Date: 01/04/2019 04:32:12 PM
// Design Name: 
// Module Name: PIPELINED_OTTER_CPU
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
        
typedef struct packed{
    opcode_t opcode;
    logic [4:0] rs1_addr;
    logic [4:0] rs2_addr;
    logic [4:0] rd_addr;
    logic rs1_used;
    logic rs2_used;
    logic rd_used;
    logic [3:0] alu_fun;
    logic memWrite;
    logic memRead2;
    logic regWrite;
    logic [1:0] rf_wr_sel;
    logic [2:0] mem_type;  //sign, size
    logic [31:0] pc;
} instr_t;

module OTTER_MCU(
    input CLK,
    input INTR,
    input RESET,
    input [31:0] IOBUS_IN,
    output [31:0] IOBUS_OUT,
    output [31:0] IOBUS_ADDR,
    output logic IOBUS_WR
);
    logic memRead1, memRead2;

    logic [31:0] IF_DE_pc;
    logic [31:0] IF_DE_ir;

    instr_t DE_EX_instr;
    instr_t EX_MEM_instr;
    instr_t MEM_WB_instr;

    // logic mepc_we, csr_we, mie, int_taken;
    // logic [31:0] mepc, mtvec, csr_rd;
//==== Instruction Fetch ===========================================

    // logic [31:0] IR;

    logic [1:0] PC_SEL;
    logic PC_WE;

    logic [31:0] next_pc, pc_in, pc_out, jalr_pc, branch_pc, jal_pc;

    mux_4t1_nb #(.n(32)) PC_mux_4t1_nb (
        .SEL(PC_SEL),
        .D0(next_pc),
        .D1(jalr_pc),
        .D2(branch_pc),
        .D3(jal_pc),
        .D_OUT(pc_in)
    );

    PC OTTER_PC (
        .clk(CLK),
        .PC_RESET(RESET),
        .PC_LD(PC_WE),
        .ADDR_MUX_OUT(pc_in),
        .PC_ADDR(pc_out)
    );

   
    assign PC_WE = 1'b1;
    assign memRead1 = 1'b1;
    assign next_pc = pc_out + 4;
    

    // PC pipeline register
    always_ff @(posedge CLK) begin
        IF_DE_pc <= pc_out;
    end
     
//==== Instruction Decode ===========================================
    
    logic rs1_used, rs2_used, rd_used, memWrite, regWrite;
    logic [3:0] alu_fun;
    logic alu_srcA_SEL;
    logic [1:0] rf_wr_sel, alu_srcB_SEL;

    logic [31:0] rs1, rs2, alu_A, alu_B;

    opcode_t opcode;

    CU_DCDR OTTER_CU_DCDR (
        .opcode(IF_DE_ir[6:0]), // instruction opcode
        .func7(IF_DE_ir[30]),
        .func3(IF_DE_ir[14:12]),
        .int_taken(1'b0),
        .ALU_FUN(alu_fun),
        .srcA_SEL(alu_srcA_SEL),
        .srcB_SEL(alu_srcB_SEL),
        .RF_SEL(rf_wr_sel)
    );

    RegFile OTTER_RegFile (
        .w_data(rf_in), // from writeback
        .clk(CLK),
        .en(MEM_WB_instr.regWrite), // from writeback
        .adr1(IF_DE_ir[19:15]),
        .adr2(IF_DE_ir[24:20]),
        .w_adr(MEM_WB_instr.rd_addr), // from writeback
        .rs1(rs1),
        .rs2(rs2)
    );

    // check which rs's are used to pass on
    assign opcode = opcode_t'(IF_DE_ir[6:0]);

    assign rs1_used = ((opcode != LUI) && (opcode != AUIPC) && (opcode != JAL));
    assign rs2_used = ((opcode == BRANCH) || (opcode == STORE) || (opcode == OP_RG3));

    assign rd_used = ((opcode != BRANCH) && (opcode != STORE));

    assign memWrite = (opcode == STORE);
    assign memRead2 = (opcode == LOAD);
    assign regWrite = ((opcode != BRANCH) && (opcode != STORE));

    logic [31:0] j_immed, b_immed, u_immed, i_immed, s_immed;

    immed_gen OTTER_immed_gen (
        .ir(IF_DE_ir),
        .j_type(j_immed),
        .b_type(b_immed),
        .u_type(u_immed),
        .i_type(i_immed),
        .s_type(s_immed)
    );
    
    mux_2t1_nb #(.n(32)) ALU_A_mux_2t1_nb (
        .SEL(alu_srcA_SEL),
        .D0(rs1),
        .D1(u_immed),
        .D_OUT(alu_A)
    );

    mux_4t1_nb #(.n(32)) ALU_B_mux_4t1_nb(
        .SEL(alu_srcB_SEL),
        .D0(rs2),
        .D1(i_immed),
        .D2(s_immed),
        .D3(IF_DE_pc),
        .D_OUT(alu_B)
    );
    
    
    // Decode stage pipeline registers
    
    // push alu stuff to execute stage
    logic [31:0] DE_EX_rs2, 
                 DE_EX_srcA, 
                 DE_EX_srcB, 
                 DE_EX_ir, 
                 DE_EX_i_immed,
                 DE_EX_b_immed,
                 DE_EX_j_immed;

    always_ff @(posedge CLK) begin
        DE_EX_rs2 <= rs2; // needed for memory access
        DE_EX_srcA <= alu_A;
        DE_EX_srcB <= alu_B;
        DE_EX_i_immed <= i_immed;
        DE_EX_b_immed <= b_immed;
        DE_EX_j_immed <= j_immed;
        DE_EX_ir <= IF_DE_ir;
    end

    always_ff @(posedge CLK) begin
        DE_EX_instr.opcode <= opcode;
        DE_EX_instr.rs1_addr <= IF_DE_ir[19:15];
        DE_EX_instr.rs2_addr <= IF_DE_ir[24:20];
        DE_EX_instr.rd_addr <= IF_DE_ir[11:7];

        DE_EX_instr.rs1_used <= rs1_used;
        DE_EX_instr.rs2_used <= rs2_used;
        DE_EX_instr.rd_used <= rd_used;
        DE_EX_instr.alu_fun <= alu_fun;
        DE_EX_instr.memWrite <= memWrite;
        DE_EX_instr.memRead2 <= memRead2;
        DE_EX_instr.regWrite <= regWrite;
        DE_EX_instr.rf_wr_sel <= rf_wr_sel;
        DE_EX_instr.mem_type <= IF_DE_ir[14:12];
        DE_EX_instr.pc <= IF_DE_pc;
    end
    
	
	
//==== Execute ======================================================
    logic [31:0] alu_res;
    branch_f3_t func3;
    
    // PC Branch generator
    branch_gen OTTER_branch_gen (
        .pc_addr(DE_EX_instr.pc),
        .j_type(DE_EX_j_immed),
        .b_type(DE_EX_b_immed),
        .i_type(DE_EX_i_immed),
        .rs(DE_EX_srcA), // will be rs1 when generating jalr
        .jal(jal_pc),
        .branch(branch_pc),
        .jalr(jalr_pc)
    );


    logic branch_taken, br_lt, br_ltu, br_eq;

    // Branch condition gen
    BRANCH_COND_GEN OTTER_BRANCH_COND_GEN (
        .rs1(DE_EX_srcA),
        .rs2(DE_EX_srcB),
        .br_eq(br_eq),
        .br_lt(br_lt),
        .br_ltu(br_ltu)
    );

    assign func3 = branch_f3_t'(DE_EX_ir[14:12]);

    // Decide if a branch needs to be taken
    always_comb begin
        case (func3)
            BEQ: branch_taken = br_eq;
            BNE: branch_taken = ~br_eq;
            BLT: branch_taken = br_lt;
            BGE: branch_taken = ~br_lt;
            BLTU: branch_taken = br_ltu;
            BGEU: branch_taken = ~br_ltu;
            default: branch_taken = DISABLE;
        endcase
    end

    // Decide what to do pc
    always_comb begin
        case (DE_EX_instr.opcode)
            JAL: PC_SEL = PC_SEL_JAL;
            JALR: PC_SEL = PC_SEL_JALR;
            BRANCH: PC_SEL = (branch_taken) ? (PC_SEL_BRANCH) : (PC_SEL_PC);
            default: PC_SEL = PC_SEL_PC;
        endcase
    end


    // alu
    riscv_alu OTTER_riscv_alu (
        .alu_fun(DE_EX_instr.alu_fun),
        .srcA(DE_EX_srcA),
        .srcB(DE_EX_srcB),
        .result(alu_res)
    );
    
    
    // Execute pipeline register
    logic [31:0] EX_MEM_alu_res;
    logic [31:0] EX_MEM_rs2;
    always_ff @(posedge CLK) begin
        // Pass instruction info down pipe
        EX_MEM_instr <= DE_EX_instr;
        // Pass da alu result
        EX_MEM_alu_res <= alu_res;
        // Used for memory
        EX_MEM_rs2 <= DE_EX_rs2;
    end



//==== Memory ======================================================
     

    assign IOBUS_ADDR = EX_MEM_alu_res;
    assign IOBUS_OUT = EX_MEM_rs2;
    
    logic [31:0] memory_data;

    Memory OTTER_Memory(
        .MEM_CLK(CLK),
        .MEM_RDEN1(memRead1), // From fetch stage (instr fetch)
        .MEM_RDEN2(EX_MEM_instr.memRead2),
        .MEM_WE2(EX_MEM_instr.memWrite),
        .MEM_ADDR1(pc_out[15:2]), // From fetch stage (instr fetch)
        .MEM_ADDR2(EX_MEM_alu_res),
        .MEM_DIN2(EX_MEM_rs2),
        .MEM_SIZE(EX_MEM_instr.mem_type[1:0]),
        .MEM_SIGN(EX_MEM_instr.mem_type[2]),
        .IO_IN(IOBUS_IN),
        .IO_WR(IOBUS_WR),
        .MEM_DOUT1(IF_DE_ir),
        .MEM_DOUT2(memory_data)
    );

    logic [31:0] MEM_WB_alu_res;
    always_ff @(posedge CLK) begin
        MEM_WB_instr <= EX_MEM_instr;
        MEM_WB_alu_res <= EX_MEM_alu_res;
    end
     
//==== Write Back ==================================================
    
    logic [31:0] rf_in; // to reg file ()

    mux_4t1_nb #(.n(32)) REG_FILE_mux_4t1_nb(
        .SEL(MEM_WB_instr.rf_wr_sel),
        .D0(MEM_WB_instr.pc + 4), // pc + 4
        .D1(32'b0), // no interrupts?
        .D2(memory_data),
        .D3(MEM_WB_alu_res),
        .D_OUT(rf_in)
    );

    

 
 

       
            
endmodule
