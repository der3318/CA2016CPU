module ALU
(
	data1_i,
	data2_i,
	ALUCtrl_i,
	data_o,
	zero_o
);

    // Ports
    input   [31:0]  data1_i;
	input	[31:0]	data2_i;
    input   [2:0]   ALUCtrl_i;
    output  [31:0]  data_o;
    output  zero_o;

    assign  data_o =    (ALUCtrl_i == 3'd0)?    data1_i + data2_i : 
                        (ALUCtrl_i == 3'd1)?    data1_i - data2_i : 
                        (ALUCtrl_i == 3'd2)?    data1_i * data2_i : 
                        (ALUCtrl_i == 3'd3)?    data1_i & data2_i : 
                        (ALUCtrl_i == 3'd4)?    data1_i | data2_i : 
												32'd0;

    assign  zero_o = 1'd0;

endmodule
