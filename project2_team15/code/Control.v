module Control
(
    op_i,
    control_o,
	branch_o,
	jump_o
);

    // Ports
    input   [5:0]   op_i;
    output  [31:0]	control_o;
    output  		branch_o, jump_o;

	reg		[31:0]	control_o;
	reg				branch_o, jump_o;

	parameter r 	= 6'b000000;
	parameter lw 	= 6'b100011;
	parameter sw	= 6'b101011;
	parameter beq	= 6'b000100;
	parameter j		= 6'b000010;
	parameter addi	= 6'b001000;
	
	// [0]: RegWrite, [1]: MemToReg, [2]: MemWrite, [3]: MemRead, [4]: RegDst, [6:5]: ALUOp, [7]: ALUSrc 

	always @(op_i)
	begin
		case(op_i)
			r: 
			begin
				control_o	<= { 24'b0, 1'b0, 2'b10, 1'b1, 1'b0, 1'b0, 1'b0, 1'b1 };
				branch_o	<= 1'b0;
				jump_o		<= 1'b0;
			end
			lw: 
			begin
				control_o	<= { 24'b0, 1'b1, 2'b00, 1'b0, 1'b1, 1'b0, 1'b1, 1'b1 };
				branch_o	<= 1'b0;
				jump_o		<= 1'b0;
			end
			sw: 
			begin
				control_o	<= { 24'b0, 1'b1, 2'b00, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0 };
				branch_o	<= 1'b0;
				jump_o		<= 1'b0;
			end
			beq: 
			begin
				control_o	<= 32'b0;
				branch_o	<= 1'b1;
				jump_o		<= 1'b0;
			end
			j:
			begin
				control_o	<= 32'b0;
				branch_o	<= 1'b0;
				jump_o		<= 1'b1;
			end
			addi:
			begin
				control_o	<= { 24'b0, 1'b1, 2'b00, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1 };
				branch_o	<= 1'b0;
				jump_o		<= 1'b0;
			end
			default:
			begin
				control_o	<= 32'b0;
				branch_o	<= 1'b0;
				jump_o		<= 1'b0;
			end
		endcase
	end

endmodule
