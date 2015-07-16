module UART(clk,rst_n,UART_RX,rx_data,flag,signal,UART_TX,result_data,result_start);

input        clk;
input        rst_n;
input        UART_RX;
input  [7:0] result_data;
input        result_start;
output [7:0] rx_data;
output       flag;
output       signal;
output       UART_TX;

wire       start1,start2;
wire       clk_bps1,clk_bps2;
wire [7:0] rx_data;
wire       rx_int;

speed_select speed_rx(
                       .clk(clk),
							  .rst_n(rst_n),
							  .start(start1),
							  .clk_bps(clk_bps1)
							 );
						
my_uart_rx my_uart_rx(
                       .clk(clk),
							  .rst_n(rst_n),
							  .UART_RX(UART_RX),
							  .rx_data(rx_data),
							  .rx_int(rx_int),
							  .clk_bps(clk_bps1),
							  .start(start1),
							  .flag(flag),
							  
.signal(signal)
                      );	
								
speed_select speed_tx(
                       .clk(clk),
							  .rst_n(rst_n),
							  .start(start2),
							  .clk_bps(clk_bps2)
							 );
							 
my_uart_tx my_uart_tx(
                       .clk(clk),
							  .rst_n(rst_n),
							  .UART_TX(UART_TX),
							  .rx_data(result_data),
							  .rx_int(result_start),
							  .clk_bps(clk_bps2),
							  .start(start2)
                      );

endmodule
