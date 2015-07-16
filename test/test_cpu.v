`timescale 1 ns/1 ns

module test_cpu();
	
	reg reset, clk, uart_rx;
	wire uart_tx;
	wire [7:0] led;
	wire [6:0] digi1, digi2, digi3, digi4;
	
	cpu_pipeline cpu1(clk,reset,led, uart_rx, uart_tx, digi1, digi2, digi3, digi4);
	
	always #1 clk <= ~clk;

   initial begin
    clk = 0;
    reset = 1;
    uart_rx = 1;
    #1 reset = 0;
    #1 reset = 1;
    //pc = 0x8000000c;
    #10000 uart_rx = 0;

    #10000 uart_rx = 1;
    #10000 uart_rx = 0;
    #10000 uart_rx = 0;
    #10000 uart_rx = 1;

    #10000 uart_rx = 0;
    #10000 uart_rx = 0;
    #10000 uart_rx = 0;
    #10000 uart_rx = 0;

    #10000 uart_rx = 1;

    #10000 uart_rx = 0;

    #10000 uart_rx = 1;
    #10000 uart_rx = 0;
    #10000 uart_rx = 1;
    #10000 uart_rx = 0;

    #10000 uart_rx = 0;
    #10000 uart_rx = 0;
    #10000 uart_rx = 0;
    #10000 uart_rx = 0;

    #10000 uart_rx = 1;

    

    #300000 $stop;
    // #2600 uart_rx = ~uart_rx;
    // #2600 uart_rx = ~uart_rx;
    // #2600 uart_rx = ~uart_rx;
    // #2600 uart_rx = ~uart_rx;
    // #2600 uart_rx = ~uart_rx;
    // #2600 uart_rx = ~uart_rx;
    // #2600 uart_rx = ~uart_rx;
    // #2600 uart_rx = ~uart_rx;
    // #2600 $stop;
   end
		
endmodule
