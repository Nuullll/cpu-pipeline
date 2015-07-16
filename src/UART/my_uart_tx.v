module my_uart_tx(clk,rst_n,rx_data,rx_int,UART_TX,clk_bps,start);

input       clk;
input       rst_n;
input       clk_bps;
input [7:0] rx_data;
input       rx_int;
output      UART_TX;
output      start;
reg tx_end;

reg         rx_int_r1,rx_int_r2;
wire        reg_rx_int;
assign      reg_rx_int=~rx_int_r1&rx_int_r2;

always @ (posedge clk or negedge rst_n)
if(!rst_n) begin
    rx_int_r1<=1'b0;
    rx_int_r2<=1'b0;
end
else begin
    rx_int_r1<=rx_int;
	 rx_int_r2<=rx_int_r1;
end

reg [7:0]tx_data;
reg start_r;
reg tx_en;
reg [3:0]num;

always @ (posedge clk or negedge rst_n)
if(!rst_n) begin
    start_r<=1'bz;
	 tx_en<=1'b0;
	 tx_data<=8'd0;
end
else if(reg_rx_int & tx_end) begin///////////
    start_r<=1'b1;
	 tx_data<=rx_data;
	 tx_en<=1'b1;
end
else if(num==4'd11) begin
    start_r<=1'b0;
	 tx_en<=1'b0;
end

assign start = start_r;

reg UART_TX_r;

always @ (posedge clk or negedge rst_n)
if(!rst_n) begin
    num<=4'd0;
	UART_TX_r<=1'b1;
	tx_end<=1;
end
else if(tx_en) begin
    if(clk_bps) begin
	     tx_end<=0;//////////
	     num<=num+1'b1;
		  case(num)
		      4'd0: UART_TX_r<=1'b0;
				4'd1: UART_TX_r<=tx_data[0];
				4'd2: UART_TX_r<=tx_data[1];
				4'd3: UART_TX_r<=tx_data[2];
				4'd4: UART_TX_r<=tx_data[3];
				4'd5: UART_TX_r<=tx_data[4];
				4'd6: UART_TX_r<=tx_data[5];
				4'd7: UART_TX_r<=tx_data[6];
				4'd8: UART_TX_r<=tx_data[7];
				4'd9: UART_TX_r<=1'b1;
				default: UART_TX_r<=1'b1;
		  endcase
	 end
	 else if(num==4'd11) 
	 begin 
	     num<=4'd0;
		  tx_end<=1;
	 end
end

assign UART_TX = UART_TX_r;

endmodule
