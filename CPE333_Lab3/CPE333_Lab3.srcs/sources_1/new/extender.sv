module extender (
    input [31:0] ir,
    input [2:0] ir_type,
    output [31:0] immed
);
    logic [31:0] j_type, b_type, u_type, i_type, s_type;

    always_comb begin
        i_type = { {21{ir[31]}}, ir[30:25], ir[24:20] };
        s_type = { {21{ir[31]}}, ir[30:25], ir[11:7] };
        b_type = { {20{ir[31]}}, ir[7], ir[30:25], ir[11:8], {1'b0} };
        u_type = { ir[31:12], {12'b0} };
        j_type = { {12{ir[31]}}, ir[19:12], ir[20], ir[30:21], {1'b0} };
    end

    mux_8t1_nb #(.n(32)) extender_mux_8t1_nb(
        .SEL   (ir_type),
        .D0    (D0    ),
        .D1    (D1    ),
        .D2    (D2    ),
        .D3    (D3    ),
        .D4    (D4    ),
        .D5    (D5    ),
        .D6    (D6    ),
        .D7    (D7    ),
        .D_OUT (D_OUT )
    );
    
endmodule