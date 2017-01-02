module CPU
(
    clk_i,
	rst_i,
    start_i,

	mem_data_i, 
	mem_ack_i, 	
	mem_data_o, 
	mem_addr_o, 	
	mem_enable_o, 
	mem_write_o
);

// Ports
input	clk_i;
input	rst_i;
input	start_i;
input	[256-1:0]	mem_data_i; 
input				mem_ack_i; 	
output	[256-1:0]	mem_data_o; 
output	[32-1:0]	mem_addr_o; 	
output				mem_enable_o; 
output				mem_write_o; 

wire	[31:0]  inst_addr, added_inst_addr;
wire	[31:0]	jump_addr;
wire	[31:0]	inst;
wire			control_branch, control_jump;
wire			eq_result;
wire	[4:0]	mux3_result;
wire	[31:0]	mux1_result, mux2_result, mux4_result, mux5_result, mux6_result, mux7_result, mux8_result, mux9_result, mux10_result;
wire	[31:0]	add_result, extend_result, shift32_result, control_result;
wire	[31:0]	RS_data, RT_data;
wire	[31:0]	alu_result, mem_result;
wire    		zero, hazard;
wire			stall, cache_stall;				// 0: no stall, 1: stall
wire	[1:0]	flush;				// 0: keep value (stall), 1: flush, 2: read new value

wire	[1:0]	mux6select;
wire	[1:0]	mux7select;
wire	mux9select;
wire	mux10select;
wire   [2:0]   ALUCtrl_result;

// Registers
// 	IF_ID REGISTERS
reg	[31:0]	IF_ID_pc;
reg	[31:0]	IF_ID_inst;

// 	ID_EX REGISTERS
reg			ID_EX_RegWrite;
reg			ID_EX_MemToReg;
reg			ID_EX_MemWrite;
reg			ID_EX_MemRead;
reg			ID_EX_RegDst;
reg	[1:0]	ID_EX_ALUOp;			
reg			ID_EX_ALUSrc;
reg	[31:0]	ID_EX_pc;
reg	[31:0]	ID_EX_RSdata;
reg	[31:0]	ID_EX_RTdata;
reg	[31:0]	ID_EX_extend;
reg	[31:0]	ID_EX_inst;
  
// 	EX_M REGISTERS
reg			EX_M_RegWrite;
reg			EX_M_MemToReg;
reg			EX_M_MemWrite;
reg			EX_M_MemRead;
reg	[31:0]	EX_M_ALUresult;
reg	[31:0]	EX_M_writedata;
reg	[4:0]	EX_M_rd;

// 	M_WB REGISTERS
reg			M_WB_RegWrite;
reg			M_WB_MemToReg;
reg	[31:0]	M_WB_readdata;
reg	[31:0]	M_WB_ALUresult;
reg	[4:0]	M_WB_rd;

initial begin
// 	IF_ID REGISTERS
	IF_ID_pc	<= 32'd0;
	IF_ID_inst 	<= 32'd0;

// 	ID_EX REGISTERS
	ID_EX_RegWrite	<= 1'b0;
	ID_EX_MemToReg	<= 1'b0;
	ID_EX_MemWrite	<= 1'b0;
	ID_EX_MemRead	<= 1'b0;
	ID_EX_RegDst	<= 1'b0;
	ID_EX_ALUOp		<= 2'b00;
	ID_EX_ALUSrc	<= 1'b0;
	ID_EX_pc		<= 32'd0;
	ID_EX_RSdata	<= 32'd0;
	ID_EX_RTdata	<= 32'd0;
	ID_EX_extend	<= 32'd0;
	ID_EX_inst		<= 32'd0;
  
// 	EX_M REGISTERS
	EX_M_RegWrite	<= 1'b0;
	EX_M_MemToReg	<= 1'b0;
	EX_M_MemWrite	<= 1'b0;
	EX_M_MemRead	<= 1'b0;
	EX_M_ALUresult	<= 32'd0;
	EX_M_writedata	<= 32'd0;
	EX_M_rd			<= 5'd0;

// 	M_WB REGISTERS
	M_WB_RegWrite	<= 1'b0;
	M_WB_MemToReg	<= 1'b0;
	M_WB_readdata	<= 32'd0;
	M_WB_ALUresult	<= 32'd0;
	M_WB_rd			<= 5'd0;	
end

// IF Stage
Adder Add_PC(
    .data1_i	(inst_addr),
    .data2_i	(32'd4),
    .data_o     (added_inst_addr)
);

MUX32 MUX1(
    .data1_i    (added_inst_addr),
    .data2_i    (add_result),
    .select_i   (control_branch & eq_result),
    .data_o     (mux1_result)
);

MUX32 MUX2(
    .data1_i    (mux1_result),
    .data2_i    ({mux1_result[31:28], jump_addr[27:0]}), // first 4 bits of PC+4 concatenated with the 28 bits of jump address
    .select_i   (control_jump),
    .data_o     (mux2_result)
);

PC PC(
    .clk_i      	(clk_i),
	.rst_i			(rst_i),
    .start_i    	(start_i),
	.hazard_i		(hazard),
	.cache_stall_i	(cache_stall),
    .pc_i       	(mux2_result),
    .pc_o       	(inst_addr)
);

Instruction_Memory Instruction_Memory(
    .addr_i     (inst_addr), 
    .instr_o    (inst)  
);

// ID Stage
Shift_Left28 Shift_Left28( 				// TO DO
	.data_i		(IF_ID_inst[25:0]),
	.data_o		(jump_addr[27:0])
);

HD HD( 									// TO DO
	.IF_ID_rs_i		(IF_ID_inst[25:21]),
	.IF_ID_rt_i		(IF_ID_inst[20:16]),
	.ID_EX_rt_i		(mux3_result),
	.RegWrite_i		(ID_EX_RegWrite),
	.MemRead_i		(ID_EX_MemRead),
	.jump_i			(control_jump),
	.branch_i		(control_branch & eq_result),
	.c_branch_i		(control_branch),
	.stall_o		(stall),
	.flush_o		(flush),
	.pc_hazard_o	(hazard)
);

Control Control(						// TO DO
    .op_i       	(IF_ID_inst[31:26]),
	.control_o		(control_result),
	.branch_o		(control_branch),
	.jump_o			(control_jump)
);

MUX32 MUX8( 							// TO DO
	.data1_i	(control_result),	// [0]: RegWrite, [1]: MemToReg, [2]: MemWrite, [3]: MemRead, [4]: RegDst, [6:5]: ALUOp, [7]: ALUSrc 
	.data2_i	(32'd0),
	.select_i	(stall),
	.data_o		(mux8_result)
);

Adder ADD(
	.data1_i	(shift32_result),
	.data2_i	(IF_ID_pc),
	.data_o		(add_result)
);

Shift_Left32 Shift_Left32(
	.data_i		(extend_result),
	.data_o		(shift32_result)
);

Registers Registers(
    .clk_i      (clk_i),
    .RSaddr_i   (IF_ID_inst[25:21]),
    .RTaddr_i   (IF_ID_inst[20:16]),
    .RDaddr_i   (M_WB_rd), 
    .RDdata_i   (mux5_result),
    .RegWrite_i (M_WB_RegWrite), 
    .RSdata_o   (RS_data), 
    .RTdata_o   (RT_data) 
);

Equal Eq(		 					// TO DO
	.data1_i	(mux9_result),
	.data2_i	(mux10_result),
	.data_o		(eq_result)
);

Sign_Extend Sign_Extend(
    .data_i     (IF_ID_inst[15:0]),
    .data_o     (extend_result)
);

MUX32 MUX9(
   .data1_i(RS_data),
   .data2_i(mux5_result),
   .select_i(mux9select),
   .data_o(mux9_result)
);

MUX32 MUX10(
   .data1_i(RT_data),
   .data2_i(mux5_result),
   .select_i(mux10select),
   .data_o(mux10_result)
);


// EX Stage
MUX32_3 MUX6( 						// TO DO
	.data1_i	(ID_EX_RSdata),
	.data2_i	(mux5_result),
	.data3_i	(EX_M_ALUresult),
	.select_i	(mux6select),
	.data_o		(mux6_result)
);

MUX32_3 MUX7(
	.data1_i	(ID_EX_RTdata),
	.data2_i	(mux5_result),
	.data3_i	(EX_M_ALUresult),
	.select_i	(mux7select),
	.data_o		(mux7_result)
);

MUX32 MUX4(
	.data1_i	(mux7_result),
	.data2_i	(ID_EX_extend),
	.select_i	(ID_EX_ALUSrc),
	.data_o		(mux4_result)
);

ALU ALU( 							// TO DO
    .data1_i    (mux6_result),
    .data2_i    (mux4_result),
    .ALUCtrl_i  (ALUCtrl_result),	// 000: +, 001: -, 010: *, 011: &, 100: |
    .data_o     (alu_result),
    .zero_o     (zero)
);

ALU_Control ALU_Control(
    .funct_i    (ID_EX_inst[5:0]),
    .ALUOp_i    (ID_EX_ALUOp),				// 00: +, 01: -, 10: R-type
    .ALUCtrl_o  (ALUCtrl_result)				// 000: +, 001: -, 010: *, 011: &, 100: |
);

MUX5 MUX3(
	.data1_i	(ID_EX_inst[20:16]),
	.data2_i	(ID_EX_inst[15:11]),
	.select_i	(ID_EX_RegDst),
	.data_o		(mux3_result)
);

FW FW( 								// TO DO
	.EX_M_rd_i			(EX_M_rd),
	.EX_M_RegWrite_i	(EX_M_RegWrite),
	.M_WB_rd_i			(M_WB_rd),
	.M_WB_RegWrite_i	(M_WB_RegWrite),
	.ID_EX_rs_i			(ID_EX_inst[25:21]),
	.ID_EX_rt_i			(ID_EX_inst[20:16]),
	.IF_ID_rs_i			(IF_ID_inst[25:21]),
	.IF_ID_rt_i			(IF_ID_inst[20:16]),
	.mux6select_o		(mux6select),
	.mux7select_o		(mux7select),
	.mux9select_o		(mux9select),
	.mux10select_o		(mux10select)
);

// M Stage
dcache_top dcache
(
    // System clock, reset and stall
	.clk_i(clk_i), 
	.rst_i(rst_i),
	
	// to Data Memory interface		
	.mem_data_i(mem_data_i), 
	.mem_ack_i(mem_ack_i), 	
	.mem_data_o(mem_data_o), 
	.mem_addr_o(mem_addr_o), 	
	.mem_enable_o(mem_enable_o), 
	.mem_write_o(mem_write_o), 
	
	// to CPU interface	
	.p1_data_i(EX_M_writedata), 
	.p1_addr_i(EX_M_ALUresult), 	
	.p1_MemRead_i(EX_M_MemRead), 
	.p1_MemWrite_i(EX_M_MemWrite), 
	.p1_data_o(mem_result), 
	.p1_stall_o(cache_stall)
);

// WB Stage
MUX32 MUX5(
	.data1_i	(M_WB_ALUresult),
	.data2_i	(M_WB_readdata),
	.select_i	(M_WB_MemToReg),
	.data_o		(mux5_result)
);

always @(posedge clk_i)
begin
if (cache_stall == 1'b1)
begin
// 	M_WB REGISTERS
	M_WB_RegWrite	<= 1'b0;
	M_WB_MemToReg	<= 1'b0;
	M_WB_readdata	<= 32'b0;
	M_WB_ALUresult	<= 32'b0;
	M_WB_rd			<= 5'b0;	
end
else
begin
// 	IF_ID REGISTERS
	if (flush == 2'b01) 					// flush
	begin
//		IF_ID_pc	<= 32'd0;
		IF_ID_inst 	<= 32'd0;
	end
	else if (flush == 2'b10)				// read new (normal)
	begin
		IF_ID_pc	<= added_inst_addr;
		IF_ID_inst	<= inst;
	end

// 	ID_EX REGISTERS
	ID_EX_RegWrite	<= mux8_result[0];
	ID_EX_MemToReg	<= mux8_result[1];
	ID_EX_MemWrite	<= mux8_result[2];
	ID_EX_MemRead	<= mux8_result[3];
	ID_EX_RegDst	<= mux8_result[4];
	ID_EX_ALUOp		<= mux8_result[6:5];
	ID_EX_ALUSrc	<= mux8_result[7];
	ID_EX_pc		<= IF_ID_pc;
	ID_EX_RSdata	<= mux9_result;
	ID_EX_RTdata	<= mux10_result;
	ID_EX_extend	<= extend_result;
	if(stall == 1'b0)
	begin
		ID_EX_inst		<= IF_ID_inst;
	end
	else
	begin
   		ID_EX_inst		<= 32'h00000000;
	end
  
// 	EX_M REGISTERS
	EX_M_RegWrite	<= ID_EX_RegWrite;
	EX_M_MemToReg	<= ID_EX_MemToReg;
	EX_M_MemWrite	<= ID_EX_MemWrite;
	EX_M_MemRead	<= ID_EX_MemRead;
	EX_M_ALUresult	<= alu_result;
	EX_M_writedata	<= mux7_result;
	EX_M_rd			<= mux3_result;

// 	M_WB REGISTERS
	M_WB_RegWrite	<= EX_M_RegWrite;
	M_WB_MemToReg	<= EX_M_MemToReg;
	M_WB_readdata	<= mem_result;
	M_WB_ALUresult	<= EX_M_ALUresult;
	M_WB_rd			<= EX_M_rd;	
end
end

endmodule

