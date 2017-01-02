module FW
(
	EX_M_rd_i,
	EX_M_RegWrite_i,
	M_WB_rd_i,
	M_WB_RegWrite_i,
	ID_EX_rs_i,
	ID_EX_rt_i,
	IF_ID_rs_i,
	IF_ID_rt_i,
	mux6select_o,
	mux7select_o,
	mux9select_o,
	mux10select_o
);

input	EX_M_RegWrite_i;
input	M_WB_RegWrite_i;
input	[4:0]	M_WB_rd_i;
input	[4:0]	EX_M_rd_i;
input	[4:0]	ID_EX_rs_i;
input	[4:0]	ID_EX_rt_i;
input	[4:0]	IF_ID_rs_i;
input	[4:0]	IF_ID_rt_i;
output	[1:0]	mux6select_o;
output	[1:0]	mux7select_o;
output	mux9select_o;
output	mux10select_o;

reg	[1:0]	mux6select_o;
reg	[1:0]	mux7select_o;
reg	mux9select_o;
reg	mux10select_o;

always @(IF_ID_rs_i or IF_ID_rt_i or ID_EX_rs_i or ID_EX_rt_i or EX_M_rd_i or M_WB_rd_i or EX_M_RegWrite_i or M_WB_RegWrite_i)
begin
	if(M_WB_RegWrite_i && M_WB_rd_i != 5'd0 && M_WB_rd_i == IF_ID_rs_i)
	begin
		mux9select_o <= 1'b1;
	end
	else
	begin
		mux9select_o <= 1'b0;
	end
	if(M_WB_RegWrite_i && M_WB_rd_i != 5'd0 && M_WB_rd_i == IF_ID_rt_i)
	begin
		mux10select_o <= 1'b1;
	end
	else
	begin
		mux10select_o <= 1'b0;
	end
	if(EX_M_RegWrite_i && EX_M_rd_i != 5'd0 && EX_M_rd_i == ID_EX_rs_i)
	begin
		mux6select_o <= 2'b10;
	end
	else if(M_WB_RegWrite_i && M_WB_rd_i != 5'd0 && M_WB_rd_i == ID_EX_rs_i)
	begin
		mux6select_o <= 2'b01;
	end
	else
	begin
    	mux6select_o <= 2'b00;
	end
	if(EX_M_RegWrite_i && EX_M_rd_i != 5'd0 && EX_M_rd_i == ID_EX_rt_i)
	begin
		mux7select_o <= 2'b10;
	end
	else if(M_WB_RegWrite_i && M_WB_rd_i != 5'd0 && M_WB_rd_i == ID_EX_rt_i)
	begin
		mux7select_o <= 2'b01;
	end
	else
	begin
		mux7select_o <= 2'b00;
	end
end

endmodule
