// EX.v

module EX (
    input clk,    // Clock
    input rst_n,  // Asynchronous reset active low

    input [5:0] EX_ALUCtl,  // From ID_EX[153:148]; Select ALU operation type
    input EX_ALUSign,       // From ID_EX[147]
    input EX_ALUSrc1,       // From ID_EX[146]
    input EX_ALUSrc2,       // From ID_EX[145]
    input [1:0] EX_RegDst,  // From ID_EX[144:143]; 00: rt, 01: rd, 10: ra, 11: k0

    input [31:0] EX_Shamt32,    // From ID_EX[142:111]
    input [31:0] EX_LuOut,      // From ID_EX[110:79]

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

    // Pass from ID_EX to EX_MEM
    input EX_MemWrite;          // From ID_EX[154]
    input EX_MemRead;           // From ID_EX[155]
    input EX_RegWrite;          // From ID_EX[156]
    input [1:0] EX_MemtoReg;    // From ID_EX[158:157]
    input [31:0] PC_plus4;      // From ID_EX[190:159]

    // Output for ID
    // output EX_MemRead,          // From ID_EX[155]
    output [4:0] EX_WriteRegister,

    output [105:0] EX_MEM
);

wire [1:0] forward1, forward2;

Forward F1(
    // Input
    .MEM_RegWrite     (MEM_RegWrite),
    .MEM_WriteRegister(MEM_WriteRegister),
    .WB_RegWrite      (WB_RegWrite),
    .WB_WriteRegister (WB_WriteRegister),
    // Output
    .forward1         (forward1),
    .forward2         (forward2)
);

wire [31:0] A, B;   // 2 operands after forwarding; NOT final operands of ALU

assign A = (forward1 == 2'b00) ? EX_RsData : 
           (forward1 == 2'b01) ? MEM_RegWriteData :
           (forward1 == 2'b10) ? WB_RegWriteData : 0;
assign B = (forward2 == 2'b00) ? EX_RtData :
           (forward2 == 2'b01) ? MEM_RegWriteData :
           (forward2 == 2'b10) ? WB_RegWriteData : 0;

wire [31:0] operand1, operand2;     // 2 final operands of ALU

assign operand1 = (EX_ALUSrc1) ? EX_Shamt32 : A;    // Shift or not
assign operand2 = (EX_ALUSrc2) ? EX_LuOut : B;

// Write into EX_MEM
wire [31:0] EX_MemWriteData;
wire [31:0] EX_ALUResult;

assign EX_MemWriteData = B;

ALU A1(
    // Input
    .A     (operand1),
    .B     (operand2),
    .sign  (EX_ALUSign),
    .ALUfun(EX_ALUCtl),
    // Output
    .S     (EX_ALUResult)
);

assign EX_WriteRegister = (EX_RegDst == 2'b00) ? EX_Rt :
                          (EX_RegDst == 2'b01) ? EX_Rd :
                          (EX_RegDst == 2'b10) ? 5'd31 :    // $ra
                          5'd26;    // $k0


always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        EX_MEM <= 0;
    end else begin
        EX_MEM[31:0] <= EX_MemWriteData;
        EX_MEM[63:32] <= EX_ALUResult;
        EX_MEM[68:64] <= EX_WriteRegister;
        EX_MEM[70:69] <= {EX_MemWrite, EX_MemRead};     // For MEM
        EX_MEM[73:71] <= {EX_MemtoReg, EX_RegWrite};    // For WB
        EX_MEM[105:74] <= PC_plus4; // For jal
    end
end

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
