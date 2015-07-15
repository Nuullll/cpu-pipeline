// cpu_pipeline.v

module cpu_pipeline (
    input clk,          // System Clock
    input rst_n,        // Asynchronous reset active low
    input uart_rx,      // UART receive data

    output uart_tx,     // UART transmit data
    output [7:0] led,   // Result
    output [6:0] digi1, // part I of operand1
    output [6:0] digi2, // part II of operand1
    output [6:0] digi3, // part I of operand2
    output [6:0] digi4  // part II of operand2
);



endmodule
