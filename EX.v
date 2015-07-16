// EX.v

module EX (
    input clk,    // Clock
    input rst_n,  // Asynchronous reset active low

    input [1:0] EX_RegDst,  // From ID_EX[176:175]; 00: rt, 01: rd, 10: ra, 11: k0
    input [5:0] EX_ALUFun,  // From ID_EX[184:179]; Select ALU operation type
    input EX_ALUSrc1,       // From ID_EX[178]
    input EX_ALUSrc2,       // From ID_EX[177]

    input [31:0] EX_Imm32,  // From ID_EX[110:79]
    input [31:0] EX_Shamt32,    // From ID_EX[142:111]
    input [31:0] EX_LuOut,  // From ID_EX[174:143]

    input [4:0] EX_Rd,      // From ID_EX[78:74]
    input [4:0] EX_Rs,      // From ID_EX[73:69]
    input [4:0] EX_Rt,      // From ID_EX[68:64]
);

endmodule