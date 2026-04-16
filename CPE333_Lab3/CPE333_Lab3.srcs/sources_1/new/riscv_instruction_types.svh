`ifndef __TYPES
`define __TYPES

parameter ENABLE = 1'b1;
parameter DISABLE = 1'b0;

typedef enum logic [1:0] {
    PC4     = 2'b00,
    CSR     = 2'b01,
    DOUT2   = 2'b10,
    ALU_RES = 2'b11
} rf_sel_t;

typedef enum logic [1:0] {
    RS1   = 2'b00,
    UTYPE = 2'b01,
    NRS1  = 2'b10
} alu_src_a_t;

typedef enum logic [2:0] {
    RS2    = 3'b000,
    ITYPE  = 3'b001,
    STYPE  = 3'b010,
    ALU_PC = 3'b011,
    CSR_RD = 3'b100
} alu_src_b_t;

typedef enum logic [2:0] {
    PC_SEL_PC     = 3'b000,
    PC_SEL_JALR   = 3'b001,
    PC_SEL_BRANCH = 3'b010,
    PC_SEL_JAL    = 3'b011,
    PC_SEL_MTVEC  = 3'b100,
    PC_SEL_MEPC   = 3'b101
} pc_sel_t;

typedef enum logic [6:0] {
    LUI    = 7'b0110111,
    AUIPC  = 7'b0010111,
    JAL    = 7'b1101111,
    JALR   = 7'b1100111,
    BRANCH = 7'b1100011,
    LOAD   = 7'b0000011,
    STORE  = 7'b0100011,
    OP_IMM = 7'b0010011,
    OP_RG3 = 7'b0110011,
    OP_SYS = 7'b1110011
} opcode_t;

typedef enum logic [3:0] {
    ALU_ADD      = 4'b0000,
    ALU_SUB      = 4'b1000,
    ALU_OR       = 4'b0110,
    ALU_AND      = 4'b0111,
    ALU_XOR      = 4'b0100,
    ALU_SRL      = 4'b0101,
    ALU_SLL      = 4'b0001,
    ALU_SRA      = 4'b1101,
    ALU_SLT      = 4'b0010,
    ALU_SLTU     = 4'b0011,
    ALU_LUI      = 4'b1001,
    ALU_DEADBEEF = 4'b1111
} alu_fun;


typedef enum logic [2:0] {
    BEQ  = 3'b000,
    BNE  = 3'b001,
    BLT  = 3'b100,
    BGE  = 3'b101,
    BLTU = 3'b110,
    BGEU = 3'b111
} branch_f3_t;


typedef enum logic [2:0] {
    ADDI   = 3'b000,
    SLTI   = 3'b010,
    SLTIU  = 3'b011,
    ORI    = 3'b110,
    XORI   = 3'b100,
    ANDI   = 3'b111,
    SLLI   = 3'b001,
    IMMED_R_SHFT = 3'b101
} immed_f3_t;

typedef enum logic {
    IMMED_SRLI = 1'b0,
    IMMED_SRA  = 1'b1
} immed_f7_t;


typedef enum logic [2:0] {
    ADD_SUB = 3'b000,
    SLL     = 3'b001,
    SLT     = 3'b010,
    SLTU    = 3'b011,
    XOR     = 3'b100,
    REG_R_SHFT  = 3'b101,
    OR      = 3'b110,
    AND     = 3'b111
} reg_f3_t;

typedef enum logic {
    ADD = 1'b0,
    SUB = 1'b1
} reg_add_sub_f7_t;

typedef enum logic {
    REG_SRL = 1'b0,
    REG_SRA = 1'b1
} reg_r_shft_f7_t;


typedef enum logic [2:0] { 
    CSRRW = 3'b001,
    CSRRC = 3'b011,
    CSRRS = 3'b010,
    MRET  = 3'b000
} sys_f3_t;

`endif