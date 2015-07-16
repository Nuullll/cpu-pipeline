// EX.v

module EX (
    input clk,    // Clock
    input rst_n,  // Asynchronous reset active low

    input [5:0] EX_ALUFun,  // From ID_EX[184:179]; Select ALU operation type
    input EX_ALUSrc1,       // From ID_EX[178]
    input EX_ALUSrc2,       // From ID_EX[177]
    input [1:0] EX_RegDst,  // From ID_EX[176:175]; 00: rt, 01: rd, 10: ra, 11: k0

    input [31:0] EX_LuOut,  // From ID_EX[174:143]
    input [31:0] EX_Shamt32,    // From ID_EX[142:111]
    input [31:0] EX_Imm32,  // From ID_EX[110:79]

    input [4:0] EX_Rd,      // From ID_EX[78:74]
    input [4:0] EX_Rs,      // From ID_EX[73:69]
    input [4:0] EX_Rt,      // From ID_EX[68:64]

    input [31:0] EX_RsData, // From ID_EX[63:32]
    input [31:0] EX_RtData, // From ID_EX[31:0]

    // Input for forward
    input MEM_RegWrite,
    input [4:0] MEM_WriteRegister,
    input [31:0] MEM_RegWriteData,
    input WB_RegWrite,
    input [4:0] WB_WriteRegister, 
    input [31:0] WB_RegWriteData,

    // Output for ID
    output EX_MemRead,
    output [4:0] EX_WriteRegister,

    output [63:0] EX_MEM    // {ALUOut[31:0], EX_MemWriteData[31:0]}
);



endmodule


module Forward (
    input MEM_RegWrite,
    input [4:0] MEM_WriteRegister,
    input WB_RegWrite,
    input [4:0] WB_WriteRegister,

    output reg [1:0] forward1,  // 00: NOT forward, 01: forward WB, 10: forward MEM
    output reg [1:0] forward2   // 00: NOT forward, 01: forward WB, 10: forward MEM
);

always @(*) begin
    if (MEM_RegWrite && MEM_WriteRegister != 0 && MEM_WriteRegister == EX_Rs) begin
        forward1 <= 2'b01;  // Forward MEM_RegWriteData to src1
    end else if (WB_RegWrite && WB_WriteRegister != 0 && WB_WriteRegister == EX_Rs) begin
        forward1 <= 2'b10;  // Forward WB_RegWriteData to src1
    end else begin
        forward1 <= 2'b00;
    end
end

always @(*) begin
    if (MEM_RegWrite && MEM_WriteRegister != 0 && MEM_WriteRegister == EX_Rt) begin
        forward2 <= 2'b01;  // Forward MEM_RegWriteData to src2
    end else if (WB_RegWrite && WB_WriteRegister != 0 && WB_WriteRegister == EX_Rt) begin
        forward2 <= 2'b10;  // Forward WB_RegWriteData to src2
    end else begin
        forward2 <= 2'b00;
    end
end

endmodule
