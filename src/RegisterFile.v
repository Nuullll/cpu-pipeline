module RegisterFile(
	input clk,
	input rst_n,
	input stall, 		// interrupt
	input UI, 			// exception
	input RegWrite,
	input [4:0] Read_register1,
	input [4:0] Read_register2,
	input [4:0] Write_register1,
	input [4:0] Write_register2,
	input [4:0] Write_register3,
	input [31:0] Write_data1,
	input [31:0] Write_data2,
	input [31:0] Write_data3,

	output [31:0] Read_data1,
	output [31:0] Read_data2
);
	
	reg    [31:0] RF_data[31:1];
	
	assign Read_data1 = (Read_register1 == 5'b00000)? 32'h00000000: RF_data[Read_register1];
	assign Read_data2 = (Read_register2 == 5'b00000)? 32'h00000000: RF_data[Read_register2];
	
	integer i;
	always @(negedge rst_n or negedge clk)
		if (~rst_n)
			 for (i = 1; i < 32; i = i + 1)
				  RF_data[i] <= 32'h00000000;
		else begin
		    if (RegWrite && (Write_register1 != 5'b00000))
			     RF_data[Write_register1] <= Write_data1;
		    if ((stall) && (Write_register2 != 5'b00000) && (~RegWrite | (Write_register2 != Write_register1)))//stall
		        RF_data[Write_register2] <= Write_data2;
		    if ((UI) && (Write_register3 != 5'b00000) && (~RegWrite | (Write_register3 != Write_register1)))//UI
			     RF_data[Write_register3] <= Write_data3;
		end
    	
endmodule
			