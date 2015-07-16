// EX.v

module EX (
    input clk,    // Clock
    input rst_n,  // Asynchronous reset active low

    input [1:0] EX_RegDst,  // From ID_EX[144:143]; 00: rt, 01: rd, 10: ra, 11: k0
    input [5:0] EX_ALUFun,  // From ID_EX[152:147]; Select ALU operation type
    input EX_ALUSrc1,       // From ID_EX[146];
    input EX_ALUSrc2,       // From ID_EX[145];

);

endmodule