module HD(
	IF_ID_rs_i,
	IF_ID_rt_i,
	ID_EX_rt_i,
	RegWrite_i,
	MemRead_i,
	jump_i,
	branch_i,
	c_branch_i,
	stall_o,
	flush_o,
	pc_hazard_o
);

input	[4:0]	IF_ID_rs_i;
input	[4:0]	IF_ID_rt_i;
input	[4:0]	ID_EX_rt_i;
input	RegWrite_i, MemRead_i;
input	jump_i, branch_i, c_branch_i;
output	stall_o;
output	[1:0]	flush_o;
output	pc_hazard_o;

reg		stall_o;
reg		[1:0]	flush_o; //01: flush, 00: stall, 10: new inst
reg 	pc_hazard_o;

always @(c_branch_i or RegWrite_i or MemRead_i or ID_EX_rt_i or IF_ID_rs_i or IF_ID_rt_i or jump_i or branch_i)
begin
	if( (MemRead_i == 1'b1 || (c_branch_i == 1'b1 && RegWrite_i == 1'b1) ) && ( (ID_EX_rt_i == IF_ID_rs_i) || (ID_EX_rt_i == IF_ID_rt_i) ) )
	begin
		stall_o <= 1'b1;
		flush_o <= 2'b00;
		pc_hazard_o <= 1'b1;
    end
	else if(jump_i || branch_i)
	begin
		stall_o <= 1'b1;
		flush_o <= 2'b01;
		pc_hazard_o <= 1'b0;
	end
	else
	begin
        stall_o <= 1'b0;
        flush_o <= 2'b10;
        pc_hazard_o <= 1'b0;
	end 
end

endmodule
