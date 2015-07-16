module RegisterFile(reset, clk, RegWrite, stall, UI,
                    Read_register1, Read_register2, 
						  Write_register1, Write_register2, Write_register3,
						  Write_data1, Write_data2, Write_data3,
						  Read_data1, Read_data2,
						  signal, flag, rx_data, result_data);
	input             reset, clk, stall, UI, signal, flag;
	input      [7:0]  rx_data;
	input             RegWrite;
	input      [4:0]  Read_register1, Read_register2, Write_register1, Write_register2, Write_register3;//Write_register2 stall 3 UI
	input      [31:0] Write_data1, Write_data2, Write_data3;//Write_data2 stall 3 UI
	output     [31:0] Read_data1, Read_data2;
	output reg [7:0]  result_data;
	
	reg    [31:0] RF_data[31:1];
	
	parameter uart_register1 = 16;
	parameter uart_register2 = 17;	
	parameter result_register = 2;
	
	assign Read_data1 = (Read_register1 == 5'b00000)? 32'h00000000: RF_data[Read_register1];
	assign Read_data2 = (Read_register2 == 5'b00000)? 32'h00000000: RF_data[Read_register2];
	
	integer i;
	always @(negedge reset or negedge clk)
		if (~reset)
			 for (i = 1; i < 32; i = i + 1)
				  RF_data[i] <= 32'h00000000;
		else begin
		    if (RegWrite && (Write_register1 != 5'b00000))
			     RF_data[Write_register1] <= Write_data1;
		    if ((stall) && (Write_register2 != 5'b00000) && (~RegWrite | (Write_register2 != Write_register1)))//stall
		        RF_data[Write_register2] <= Write_data2;
		    if ((UI) && (Write_register3 != 5'b00000) && (~RegWrite | (Write_register3 != Write_register1)))//UI
			     RF_data[Write_register3] <= Write_data3;
			 if(signal)       //new data
			 begin
			     if (flag)
		            RF_data[uart_register1] <= rx_data;
		        if (~flag)
		            RF_data[uart_register2] <= rx_data;
			 end
			     result_data <= RF_data[result_register]; 
		end
    	
endmodule
			