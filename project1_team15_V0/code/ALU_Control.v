module ALU_Control
(
    funct_i,
    ALUOp_i,
    ALUCtrl_o
);

    // Ports
    input   [5:0]   funct_i;
    input   [1:0]   ALUOp_i;
    output  [2:0]   ALUCtrl_o;

    assign  ALUCtrl_o = (ALUOp_i == 2'd0)?							3'd0 : // add
                        (ALUOp_i == 2'd1)?							3'd1 : // sub
                        (ALUOp_i == 2'd2 && funct_i == 6'b100000)?	3'd0 : // R-type: +
                        (ALUOp_i == 2'd2 && funct_i == 6'b100010)?	3'd1 : // R-type: -
                        (ALUOp_i == 2'd2 && funct_i == 6'b011000)?	3'd2 : // R-type: *
                        (ALUOp_i == 2'd2 && funct_i == 6'b100100)?	3'd3 : // R-type: &
                        (ALUOp_i == 2'd2 && funct_i == 6'b100101)?	3'd4 : // R-type: |
																	3'd5;

endmodule
