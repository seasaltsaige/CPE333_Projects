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


module OTTER_MCU(
    input clk,
    input intr,
    input rst,
    input [31:0] iobus_in,
    output [31:0] iobus_out,
    output [31:0] iobus_addr,
    output logic iobus_wr
);

    // Pipeline registers
    DE_instr DE_instr_reg;
    EM_instr EM_instr_reg;
    MW_instr MW_instr_reg;

    // Instruction Fetch

    // FD 'register'
    logic [31:0] FD_pc, FD_ir;
    logic mem_re_1 = 1'b1; // always enabled in this lab

    logic [1:0] pc_sel;
    logic pc_we = 1'b1; // always enabled in this lab

    logic [31:0] pc_out, pc_mux_out, pc_branch, pc_jal, pc_jalr;

    mux_4t1_nb #(.n(32)) PC_mux_4t1_nb(
        .SEL   (pc_sel),
        .D0    (pc_out + 4),
        .D1    (pc_jalr),
        .D2    (pc_branch),
        .D3    (pc_jal),
        .D_OUT (pc_mux_out)
    );

    PC OTTER_PC(
        .clk          (clk),
        .PC_RESET     (rst),
        .PC_LD        (pc_we),
        .ADDR_MUX_OUT (pc_mux_out),
        .PC_ADDR      (pc_out)
    );
    
    // FD pipeline register
    always_ff @( posedge clk ) begin
        FD_pc <= pc_out;
    end


    // Decode Stage
    logic [3:0] alu_fn;
    logic srcA_sel;
    logic [1:0] srcB_sel, rf_mux_sel;

    logic [31:0] rs1, rs2;

    CU_DCDR OTTER_CU_DCDR(
        .opcode    (FD_ir[6:0]),
        .func7     (FD_ir[30]),
        .func3     (FD_ir[14:12]),
        .int_taken (1'b0), // no interrupts
        .ALU_FUN   (alu_fn),
        .srcA_SEL  (srcA_sel),
        .srcB_SEL  (srcB_sel),
        .RF_SEL    (rf_mux_sel)
    );

    RegFile OTTER_RegFile(
        .w_data (rf_data), // from writeback stage
        .clk    (clk),
        .en     (MW_instr_reg.reg_we), // from writeback stage
        .adr1   (FD_ir[19:15]),
        .adr2   (FD_ir[24:20]),
        .w_adr  (MW_instr_reg.ir[11:7]), // from writeback stage
        .rs1    (rs1),
        .rs2    (rs2)
    );


    // Temporary
    // To be replaced by 'extender'
    // Decoder will select a single immediate output
    logic [31:0] j_immed, b_immed, u_immed, i_immed, s_immed;
    logic [31:0] DE_j_immed, DE_b_immed, DE_u_immed, DE_i_immed, DE_s_immed;

    immed_gen OTTER_immed_gen(
        .ir     (FD_ir),
        .j_type (j_immed),
        .b_type (b_immed),
        .u_type (u_immed),
        .i_type (i_immed),
        .s_type (s_immed)
    );
    

    opcode_t opcode;
    logic rs1_used, rs2_used, rd_used, mem_we, mem_re_2, reg_we;
    assign opcode = opcode_t'(FD_ir[6:0]);

    // rs1 used on everything except lui, auipc, and jal
    assign rs1_used = ((opcode != LUI) && (opcode != AUIPC) && (opcode != JAL));
    // rs2 used on branch, store, and rg3 instructions
    assign rs2_used = ((opcode == BRANCH) || (opcode == STORE) || (opcode == OP_RG3));

    // write to regs on all instructions except branch and store 
    assign rd_used = ((opcode != BRANCH) && (opcode != STORE));

    assign mem_we = (opcode == STORE); // write to memory on store instructions
    assign mem_re_2 = (opcode == LOAD); // read from data memory on loads
    // write to regs on all instructions except branch and store
    assign reg_we = ((opcode != BRANCH) && (opcode != STORE)); 



    // DE pipeline register
    always_ff @( posedge clk ) begin
        DE_instr_reg.ir <= FD_ir;
        DE_instr_reg.pc <= FD_pc;
        DE_instr_reg.alu_fun <= alu_fn;
        DE_instr_reg.mem_we <= mem_we;
        DE_instr_reg.mem_re_2 <= mem_re_2;
        DE_instr_reg.reg_we <= reg_we;
        DE_instr_reg.rf_sel <= rf_mux_sel;
        DE_instr_reg.alu_src_A_sel <= srcA_sel;
        DE_instr_reg.alu_src_B_sel <= srcB_sel;
        DE_instr_reg.rs1 <= rs1;
        DE_instr_reg.rs2 <= rs2;
        DE_instr_reg.rs1_used <= rs1_used;
        DE_instr_reg.rs2_used <= rs2_used;
        DE_instr_reg.rd_used <= rd_used;

        // Temporary
        // To be replaced by single immediate register (in DE_instr_reg i thinks)
        DE_j_immed <= j_immed;
        DE_b_immed <= b_immed;
        DE_u_immed <= u_immed;
        DE_i_immed <= i_immed;
        DE_s_immed <= s_immed;

    end


    // = Execute Stage =

    logic [31:0] aluA, aluB, alu_result;

    mux_2t1_nb #(.n(32)) alu_src_A_mux_2t1_nb(
        .SEL   (DE_instr_reg.alu_src_A_sel),
        .D0    (DE_instr_reg.rs1),
        .D1    (DE_u_immed),
        .D_OUT (aluA)
    );

    mux_4t1_nb #(.n(32)) alu_src_B_mux_4t1_nb(
        .SEL   (DE_instr_reg.alu_src_B_sel),
        .D0    (DE_instr_reg.rs2),
        .D1    (DE_i_immed),
        .D2    (DE_s_immed),
        .D3    (DE_instr_reg.pc),
        .D_OUT (aluB)
    );


    // Temporarily in execute, to be moved to decode
    branch_gen OTTER_branch_gen(
        .pc_addr (DE_instr_reg.pc),
        .j_type  (DE_j_immed),
        .b_type  (DE_b_immed),
        .i_type  (DE_i_immed),
        .rs      (DE_instr_reg.rs1),
        .jal     (pc_jal),
        .branch  (pc_branch),
        .jalr    (pc_jalr)
    );

    logic br_eq, br_lt, br_ltu, branch_taken;

    BRANCH_COND_GEN OTTER_BRANCH_COND_GEN(
        .rs1    (DE_instr_reg.rs1),
        .rs2    (DE_instr_reg.rs2),
        .br_eq  (br_eq),
        .br_lt  (br_lt),
        .br_ltu (br_ltu)
    );

    branch_f3_t func3;
    assign func3 = branch_f3_t'(DE_instr_reg.ir[14:12]);

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

    opcode_t ex_opcode;
    assign ex_opcode = opcode_t'(DE_instr_reg.ir[6:0]);

    always_comb begin
        case (ex_opcode)
            JAL: pc_sel = PC_SEL_JAL;
            JALR: pc_sel = PC_SEL_JALR;
            BRANCH: pc_sel = (branch_taken) ? (PC_SEL_BRANCH) : (PC_SEL_PC);
            default: pc_sel = PC_SEL_PC;
        endcase
    end

    // End temp in execute


    riscv_alu OTTER_riscv_alu(
        .alu_fun (DE_instr_reg.alu_fun),
        .srcA    (aluA),
        .srcB    (aluB),
        .result  (alu_result)
    );

    // EM pipeline register
    always_ff @( posedge clk ) begin
        EM_instr_reg.ir <= DE_instr_reg.ir;
        EM_instr_reg.pc <= DE_instr_reg.pc;
        EM_instr_reg.mem_we <= DE_instr_reg.mem_we;
        EM_instr_reg.mem_re_2 <= DE_instr_reg.mem_re_2;
        EM_instr_reg.reg_we <= DE_instr_reg.reg_we;
        EM_instr_reg.rf_sel <= DE_instr_reg.rf_sel;
        EM_instr_reg.alu_result <= alu_result;
        EM_instr_reg.rs1 <= DE_instr_reg.rs1;
        EM_instr_reg.rs2 <= DE_instr_reg.rs2;
        EM_instr_reg.rs1_used <= DE_instr_reg.rs1_used;
        EM_instr_reg.rs2_used <= DE_instr_reg.rs2_used;
        EM_instr_reg.rd_used <= DE_instr_reg.rd_used;
    end


    // Memory stage

    assign iobus_addr = EM_instr_reg.alu_result;
    assign iobus_out = EM_instr_reg.rs2;

    logic [31:0] MW_dmem_out;

    Memory OTTER_Memory(
        .MEM_CLK   (clk),
        .MEM_RDEN1 (mem_re_1),
        .MEM_RDEN2 (EM_instr_reg.mem_re_2),
        .MEM_WE2   (EM_instr_reg.mem_we),
        .MEM_ADDR1 (FD_pc[15:2]), // from fetch stage
        .MEM_ADDR2 (EM_instr_reg.alu_result),
        .MEM_DIN2  (EM_instr_reg.rs2),
        .MEM_SIZE  (EM_instr_reg.ir[13:12]),
        .MEM_SIGN  (EM_instr_reg.ir[14]),
        .IO_IN     (iobus_in), // from io
        .IO_WR     (iobus_wr), // from io
        .MEM_DOUT1 (FD_ir), // to fetch stage
        .MEM_DOUT2 (MW_dmem_out)
    );

    // MW pipeline reg
    always_ff @( posedge clk ) begin
        MW_instr_reg.ir <= EM_instr_reg.ir;
        MW_instr_reg.pc <= EM_instr_reg.pc;
        MW_instr_reg.reg_we <= EM_instr_reg.reg_we;
        MW_instr_reg.rf_sel <= EM_instr_reg.rf_sel;
        MW_instr_reg.alu_result <= EM_instr_reg.alu_result;
    end


    // Writeback stage
    logic [31:0] rf_data;   
    mux_4t1_nb #(.n(32)) WB_regfile_mux_4t1_nb(
        .SEL   (MW_instr_reg.rf_sel),
        .D0    (MW_instr_reg.pc + 4),
        .D1    (32'b0),
        .D2    (MW_dmem_out),
        .D3    (MW_instr_reg.alu_result),
        .D_OUT (rf_data)
    );
    



endmodule