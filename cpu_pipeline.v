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

wire [63:0] IF_ID;
wire [158:0] ID_EX;
wire [72:0] EX_MEM;

// ID->IF
wire PC_IF_ID_Write; 
wire [31:0] branch_target;
wire [31:0] jump_target;
wire [31:0] jr_target;
wire Z, J, JR;  // To select next PC
wire interrupt, exception;  // Status of CPU

// UART->ID
wire uart_signal;   // 1: there is new data from uart
wire uart_flag;     // Select uart write target (register)
wire [7:0] uart_rx_data;

IF IF1(
    // Input
    .clk           (clk),
    .rst_n         (rst_n),
    .PC_IF_ID_Write(PC_IF_ID_Write),
    .branch_target (branch_target),
    .jump_target   (jump_target),
    .jr_target     (jr_target),
    .select_PC_next({Z, J, JR}),
    .status        ({interrupt, exception}),
    // Output
    .IF_ID         (IF_ID)
);

ID ID1(
    // Input
    .clk             (clk),
    .rst_n           (rst_n),
    .uart_signal     (uart_signal),
    .uart_flag       (uart_flag),
    .uart_rx_data    (uart_rx_data),
    .instruction     (IF_ID[31:0]),
    .PC_plus4        (IF_ID[63:32]),
    // T.B.C
);

endmodule
