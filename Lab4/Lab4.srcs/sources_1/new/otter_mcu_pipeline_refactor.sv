`timescale 1ns / 1ps
`include "riscv_instruction_types.svh";

module OTTER_MCU(
    input clk,
    input intr,
    input rst,
    input [31:0] iobus_in,
    output [31:0] iobus_out,
    output [31:0] iobus_addr,
    output logic iobus_wr
);

    stage_info DE_info, EX_info, MEM_info, WB_info;

    // Pipeline registers
    DE_instr DE_instr_reg;
    EM_instr EM_instr_reg;
    MW_instr MW_instr_reg;

    // ========================== BEGIN FETCH STAGE ========================== //

    // FD 'register'
    logic [31:0] FD_pc, FD_ir;
    logic [31:0] mem_ir;
    logic mem_re_1 = 1'b1; // always enabled in this lab

    // logic [1:0] pc_sel;
    logic pc_sel;
    logic pc_we, FD_en, flush_DE, flush_EX;

    logic [31:0] pc_out, pc_mux_out, pc_branch, pc_jal, pc_jalr;
    logic [31:0] branch_target;


    mux_2t1_nb #(.n(32)) PC_mux_2t1_nb(
        .SEL   (pc_sel),
        .D0    (pc_out + 4),
        .D1    (branch_target),
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
        if (rst || flush_DE) begin 
            FD_pc <= 32'b0;
            FD_ir <= 32'b0;
        end else if (FD_en) begin 
            FD_pc <= pc_out;
            FD_ir <= mem_ir;
        end
    end
    // ========================== END FETCH STAGE ========================== //



    // ========================== BEGIN DECODE STAGE ========================== //
    logic [3:0] alu_fn;
    alu_src_a_t srcA_sel;
    alu_src_b_t srcB_sel; 
    rf_sel_t rf_mux_sel;
    logic [2:0] immed_sel;
    logic [31:0] rf_data;

    logic [31:0] rs1, rs2;

    logic bag_sel;

    CU_DCDR OTTER_CU_DCDR(
        .opcode         (FD_ir[6:0]),
        .func7          (FD_ir[30]),
        .func3          (FD_ir[14:12]),
        .int_taken      (1'b0), // no interrupts
        .ALU_FUN        (alu_fn),
        .srcA_SEL       (srcA_sel),
        .srcB_SEL       (srcB_sel),
        .extender_SEL   (immed_sel),
        .bag_SEL        (bag_sel),
        .RF_SEL         (rf_mux_sel)
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


    logic [31:0] immed;

    Extender OTTER_Extender(
        .immed_sel(immed_sel),
        .ir(FD_ir),
        .immed(immed)
    );

    opcode_t opcode;
    logic rs1_used, rs2_used, mem_we, mem_re_2, reg_we;
    assign opcode = opcode_t'(FD_ir[6:0]);

    // rs1 used on everything except lui, auipc, and jal
    assign rs1_used = ((opcode != LUI) && (opcode != AUIPC) && (opcode != JAL));
    // rs2 used on branch, store, and rg3 instructions
    assign rs2_used = ((opcode == BRANCH) || (opcode == STORE) || (opcode == OP_RG3));

    assign mem_we = (opcode == STORE); // write to memory on store instructions
    assign mem_re_2 = (opcode == LOAD); // read from data memory on loads
    // write to regs on all instructions except branch and store
    assign reg_we = ((opcode != BRANCH) && (opcode != STORE)); 

    // DE pipeline register
    always_ff @( posedge clk ) begin
        if (flush_EX) begin
            DE_instr_reg <= '0;
        end else begin
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
            DE_instr_reg.immed <= immed;
            DE_instr_reg.bag_sel <= bag_sel;
        end  
    end

    // ============= DE INFO FOR HAZARD UNIT ============= //
    always_comb begin
        DE_info = '0;
        DE_info.rs1 = FD_ir[19:15];
        DE_info.rs2 = FD_ir[24:20];
        DE_info.rd = FD_ir[11:7];
        DE_info.rs1_used = rs1_used;
        DE_info.rs2_used = rs2_used;
        DE_info.reg_we = reg_we;
        DE_info.mem_re_2 = mem_re_2;
    end
    // ============= DE INFO FOR HAZARD UNIT ============= //
    // ========================== END DECODE STAGE ========================== //


    // ========================== BEGIN EXECUTE STAGE ========================== //
    // ALU MUX's w/ hazard data forward mux's, BAG, BCG, and ALU
    logic [31:0] aluA, aluB, alu_result;
    logic [31:0] forward_a_out, forward_b_out;
    logic [1:0] forward_a_sel, forward_b_sel;



    mux_4t1_nb #(.n(32)) forward_A_mux_4t1_nb(
        .SEL   (forward_a_sel),
        .D0    (DE_instr_reg.rs1),
        .D1    (EM_instr_reg.alu_result),
        .D2    (rf_data),
        .D3    (32'b0),
        .D_OUT (forward_a_out)
    );

    mux_2t1_nb #(.n(32)) alu_src_A_mux_2t1_nb(
        .SEL   (DE_instr_reg.alu_src_A_sel),
        .D0    (forward_a_out),
        .D1    (immed),
        .D_OUT (aluA)
    );


    mux_4t1_nb #(.n(32)) forward_B_mux_4t1_nb(
        .SEL   (forward_b_sel),
        .D0    (DE_instr_reg.rs2),
        .D1    (EM_instr_reg.alu_result),
        .D2    (rf_data),
        .D3    (32'b0),
        .D_OUT (forward_b_out)
    );

    mux_4t1_nb #(.n(32)) alu_src_B_mux_4t1_nb(
        .SEL   (DE_instr_reg.alu_src_B_sel),
        .D0    (forward_b_out),
        .D1    (DE_instr_reg.immed),
        .D2    (DE_instr_reg.immed),
        .D3    (DE_instr_reg.pc),
        .D_OUT (aluB)
    );

    logic [31:0] base_addr;

    // Temporarily in execute, to be moved to decode
    mux_2t1_nb #(.n(32)) BASE_ADDR_mux_2t1_nb(
        .SEL   (DE_instr_reg.bag_sel),
        .D0    (DE_instr_reg.pc),
        .D1    (forward_a_out),
        .D_OUT (base_addr)
    );
    
    branch_addr_gen OTTER_branch_addr_gen(
        .base_addr     (base_addr),
        .immed         (DE_instr_reg.immed),
        .branch_target (branch_target)
    );

    logic br_eq, br_lt, br_ltu, branch_taken;

    BRANCH_COND_GEN OTTER_BRANCH_COND_GEN(
        .rs1    (forward_a_out),
        .rs2    (forward_b_out),
        .br_eq  (br_eq),
        .br_lt  (br_lt),
        .br_ltu (br_ltu)
    );


    opcode_t ex_opcode;
    assign ex_opcode = opcode_t'(DE_instr_reg.ir[6:0]);
    branch_f3_t func3;
    assign func3 = branch_f3_t'(DE_instr_reg.ir[14:12]);

    always_comb begin
        if (ex_opcode == BRANCH) begin
            case (func3)
                BEQ: branch_taken = br_eq;
                BNE: branch_taken = ~br_eq;
                BLT: branch_taken = br_lt;
                BGE: branch_taken = ~br_lt;
                BLTU: branch_taken = br_ltu;
                BGEU: branch_taken = ~br_ltu;
                default: branch_taken = DISABLE;
            endcase
        end else begin
            branch_taken = DISABLE;
        end
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
        EM_instr_reg.rs1 <= forward_a_out;
        EM_instr_reg.rs2 <= forward_b_out;
        EM_instr_reg.rs1_used <= DE_instr_reg.rs1_used;
        EM_instr_reg.rs2_used <= DE_instr_reg.rs2_used;
    end

    // ============= EX INFO FOR HAZARD UNIT ============= //
    always_comb begin
        EX_info = '0;
        EX_info.rs1 = DE_instr_reg.ir[19:15];
        EX_info.rs2 = DE_instr_reg.ir[24:20];
        EX_info.rd = DE_instr_reg.ir[11:7];
        EX_info.rs1_used = DE_instr_reg.rs1_used;
        EX_info.rs2_used = DE_instr_reg.rs2_used;
        EX_info.reg_we = DE_instr_reg.reg_we;
        EX_info.mem_re_2 = DE_instr_reg.mem_re_2;
    end
    // ============= EX INFO FOR HAZARD UNIT ============= //
    // ========================== END EXECUTE STAGE ========================== //


    // ========================== BEGIN MEMORY STAGE ========================== //
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
        .MEM_DOUT1 (mem_ir), // to fetch stage
        .MEM_DOUT2 (MW_dmem_out)
    );


    always_ff @( posedge clk ) begin
        MW_instr_reg.ir <= EM_instr_reg.ir;
        MW_instr_reg.pc <= EM_instr_reg.pc;
        MW_instr_reg.mem_we <= EM_instr_reg.mem_we;
        MW_instr_reg.mem_re_2 <= EM_instr_reg.mem_re_2;
        MW_instr_reg.reg_we <= EM_instr_reg.reg_we;
        MW_instr_reg.rf_sel <= EM_instr_reg.rf_sel;
        MW_instr_reg.alu_result <= EM_instr_reg.alu_result;
        MW_instr_reg.rs1_used <= EM_instr_reg.rs1_used;
        MW_instr_reg.rs2_used <= EM_instr_reg.rs2_used;
    end

    // ============= MEM INFO FOR HAZARD UNIT ============= //
    always_comb begin
        MEM_info = '0;
        MEM_info.rs1 = EM_instr_reg.ir[19:15];
        MEM_info.rs2 = EM_instr_reg.ir[24:20];
        MEM_info.rd = EM_instr_reg.ir[11:7];
        MEM_info.rs1_used = EM_instr_reg.rs1_used;
        MEM_info.rs2_used = EM_instr_reg.rs2_used;
        MEM_info.reg_we = EM_instr_reg.reg_we;
        MEM_info.mem_re_2 = EM_instr_reg.mem_re_2;
    end
    // ============= MEM INFO FOR HAZARD UNIT ============= //
    // ========================== END MEMORY STAGE ========================== //


    // ========================== BEGIN WRITEBACK STAGE ========================== //   
    mux_4t1_nb #(.n(32)) WB_regfile_mux_4t1_nb(
        .SEL   (MW_instr_reg.rf_sel),
        .D0    (MW_instr_reg.pc + 4),
        .D1    (32'b0),
        .D2    (MW_dmem_out),
        .D3    (MW_instr_reg.alu_result),
        .D_OUT (rf_data)
    );
    
    // ============= WB INFO FOR HAZARD UNIT ============= //
    always_comb begin
        WB_info = '0;
        WB_info.rs1 = MW_instr_reg.ir[19:15];
        WB_info.rs2 = MW_instr_reg.ir[24:20];
        WB_info.rd = MW_instr_reg.ir[11:7];
        WB_info.rs1_used = MW_instr_reg.rs1_used;
        WB_info.rs2_used = MW_instr_reg.rs2_used;
        WB_info.reg_we = MW_instr_reg.reg_we;
        WB_info.mem_re_2 = MW_instr_reg.mem_re_2;
    end
    // ============= WB INFO FOR HAZARD UNIT ============= //
    // ========================== END WRITEBACK STAGE ========================== //

    // ============= HAZARD UNIT ============= //
    hazard_unit OTTER_hazard_unit(
        .DE            (DE_info),
        .EX            (EX_info),
        .MEM           (MEM_info),
        .WB            (WB_info),
        .branch_taken  (branch_taken),
        .pc_en         (pc_we),
        .pc_sel        (pc_sel),
        .FD_en         (FD_en),
        .flush_DE      (flush_DE),
        .flush_EX      (flush_EX),
        .forward_a_sel (forward_a_sel),
        .forward_b_sel (forward_b_sel)
    );
    // ============= HAZARD UNIT ============= //

endmodule