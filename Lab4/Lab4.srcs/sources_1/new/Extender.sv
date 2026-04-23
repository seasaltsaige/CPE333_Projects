`timescale 1ns / 1ps
`include "riscv_instruction_types.svh";

module Extender(
  extender_sel_t immed_sel;
  input logic [31:0] ir;
  output logic [31:0] immed;
  );

    always_comb begin
      case(immed_sel)
        EXT_ITYPE: begin
          immed = { {21{ir[31]}}, ir[30:25], ir[24:20] };
        end
        EXT_STYPE: begin
          immed = { {21{ir[31]}}, ir[30:25], ir[11:7] };
        end
        EXT_BTYPE: begin
          immed = { {20{ir[31]}}, ir[7], ir[30:25], ir[11:8], {1'b0} };
        end
        EXT_UTYPE: begin
          immed = { ir[31:12], {12'b0} };
        end
        EXT_JTYPE: begin
          immed = { {12{ir[31]}}, ir[19:12], ir[20], ir[30:21], {1'b0} };
        end
        default: begin
          immed = 32'b0;
        end
      endcase
    end
endmodule