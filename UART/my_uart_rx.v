module my_uart_rx(clk,rst_n,UART_RX,rx_data,rx_int,clk_bps,start,flag,signal);

input        clk;
input        rst_n;
input        UART_RX;
input        clk_bps;
output       start;
output [7:0] rx_data;
output       rx_int;
output       flag;
output       signal;

reg       start_r;
reg [3:0] num;
reg       rx_int;
reg       UART_RX_r1,UART_RX_r2;
wire      reg_UART_RX;

reg    	  flag;

assign signal = ~rx_int;

//assign signal = reg_UART_RX;

assign reg_UART_RX=~UART_RX_r1&UART_RX_r2;

always @ (posedge clk or negedge rst_n)
if(!rst_n) begin
    UART_RX_r1<=1'b0;
	 UART_RX_r2<=1'b0;
end
else begin
    UART_RX_r2<=UART_RX_r1;
    UART_RX_r1<=UART_RX;	
end

always @ (posedge clk or negedge rst_n)
if(!rst_n) begin
    start_r<=1'b0;
	 rx_int<=1'b0;
end
else if(reg_UART_RX) begin
    start_r<=1'b1;
	 rx_int<=1'b1;
end
else if(num==4'd9) begin
    start_r<=1'b0;
	 rx_int<=1'b0;
end

assign start = start_r;

reg [7:0]rx_data_r;
reg [7:0]rx_temp_data;

always @ (posedge clk or negedge rst_n)
if(!rst_n) begin
    rx_temp_data<=8'd0;
	 num<=4'd0;
	 rx_data_r<=8'd0;
	 flag<=0;
	 //signal<=0;
end
else if(rx_int) begin
    //signal<=0;
    if(clk_bps) begin
	     num<=num+1'b1;
		  case(num)
		      4'd1: rx_temp_data[0]<=UART_RX;
		      4'd2: rx_temp_data[1]<=UART_RX;
		      4'd3: rx_temp_data[2]<=UART_RX;
		      4'd4: rx_temp_data[3]<=UART_RX;
		      4'd5: rx_temp_data[4]<=UART_RX;
		      4'd6: rx_temp_data[5]<=UART_RX;
		      4'd7: rx_temp_data[6]<=UART_RX;
		      4'd8: rx_temp_data[7]<=UART_RX;
		      default: ;
		  endcase
	 end
	 else if(num==4'd9) begin
	     num<=4'd0;
		  rx_data_r<=rx_temp_data;
		  flag<=~flag;
		  //signal<=1;
	 end
end
//else signal<=0;

assign rx_data = rx_data_r;

endmodule
