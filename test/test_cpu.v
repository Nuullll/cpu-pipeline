`timescale 1 ns/1 ns

module test_cpu();
	
	reg reset, clk;
    wire [127:0] cipher_output;

	cpu_pipeline cpu1(
        .clk    (clk),
        .rst_n  (reset),
        .cipher_output(cipher_output)
    );
	
	always #1 clk <= ~clk;

   initial begin
    clk = 0;
    reset = 1;
    #1 reset = 0;
    #1 reset = 1;

    #20000 
    #1 reset = 0;
    #1 reset = 1;
    #20000 $stop;
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
