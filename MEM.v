// MEM.v

module MEM (
    input clk,    // Clock
    input rst_n,  // Asynchronous reset active low
    
    input MEM_MemWrite,     // From EX_MEM[69]
    input [31:0] MEM_Address,   // From EX_MEM[63:32]
    input [31:0] MEM_WriteData, // From EX_MEM[31:0]

    output [31:0] MEM_ReadData, 
    output [:0] MEM_WB
);



endmodule
