// cpu_pipeline.v

module cpu_pipeline (
    input clk,          // System Clock
    input rst_n,        // Asynchronous reset active low

    output [127:0] cipher_output
);

wire [63:0] IF_ID;
wire [190:0] ID_EX;
wire [105:0] EX_MEM;
wire [103:0] MEM_WB;

// IF
wire PC_IF_ID_Write; 
wire [31:0] branch_target;
wire [31:0] jump_target;
wire [31:0] jr_target;
wire Z, J, JR;  // To select next PC
wire interrupt, exception;  // Status of CPU

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

// ID
wire [4:0] EX_WriteRegister;
wire [31:0] EX_ALUResult;

wire [1:0] WB_MemtoReg;
wire [31:0] WB_RegWriteData;

assign WB_MemtoReg = MEM_WB[71:70];
assign WB_RegWriteData = (WB_MemtoReg == 2'b00) ? MEM_WB[31:0] :    // MEM_ALUResult
                         (WB_MemtoReg == 2'b01) ? MEM_WB[63:32] :   // MEM_ReadData
                         (WB_MemtoReg == 2'b10) ? MEM_WB[103:72] :  // PC_plus4, jal
                         32'hffffffff;  // Unexpected behavior

wire irq;   // Interrupt request from MEM

ID ID1(
    // Input
    .clk              (clk),
    .rst_n            (rst_n),
    .irq              (irq),
    .instruction      (IF_ID[31:0]),
    .PC_plus4         (IF_ID[63:32]),
    .WB_WriteRegister (MEM_WB[68:64]),
    .WB_RegWrite      (MEM_WB[69]),
    .WB_RegWriteData  (WB_RegWriteData),
    .EX_WriteRegister (EX_WriteRegister),
    .EX_ALUResult     (EX_ALUResult),
    .MEM_RegWrite     (EX_MEM[71]),
    .MEM_WriteRegister(EX_MEM[68:64]),
    .MEM_ALUResult    (EX_MEM[63:32]),
    // Output
    .Z                (Z),
    .J                (J),
    .JR               (JR),
    .PC_IF_ID_Write   (PC_IF_ID_Write),
    .branch_target    (branch_target),
    .jump_target      (jump_target),
    .jr_target        (jr_target),
    .interrupt        (interrupt),
    .exception        (exception),
    .ID_EX            (ID_EX)
);

EX EX1(
    // Input
    .clk              (clk),
    .rst_n            (rst_n),
    .PC_plus4         (ID_EX[190:159]),
    .EX_MemtoReg      (ID_EX[158:157]),
    .EX_RegWrite      (ID_EX[156]),
    .EX_MemRead       (ID_EX[155]),
    .EX_MemWrite      (ID_EX[154]),
    .EX_ALUCtl        (ID_EX[153:148]),
    .EX_ALUSign       (ID_EX[147]),
    .EX_ALUSrc1       (ID_EX[146]),
    .EX_ALUSrc2       (ID_EX[145]),
    .EX_RegDst        (ID_EX[144:143]),
    .EX_Shamt32       (ID_EX[142:111]),
    .EX_LuOut         (ID_EX[110:79]),
    .EX_Rd            (ID_EX[78:74]),
    .EX_Rs            (ID_EX[73:69]),
    .EX_Rt            (ID_EX[68:64]),
    .EX_RsData        (ID_EX[63:32]),
    .EX_RtData        (ID_EX[31:0]),
    .MEM_RegWrite     (EX_MEM[71]),
    .MEM_WriteRegister(EX_MEM[68:64]),
    .MEM_RegWriteData (EX_MEM[63:32]),
    .WB_RegWrite      (MEM_WB[69]),
    .WB_WriteRegister (MEM_WB[68:64]),
    .WB_RegWriteData  (WB_RegWriteData),
    // Output
    .EX_WriteRegister (EX_WriteRegister),
    .EX_ALUResult     (EX_ALUResult),
    .EX_MEM           (EX_MEM)
);

MEM MEM1(
    // Input
    .clk              (clk),
    .rst_n            (rst_n),
    .PC_plus4         (EX_MEM[105:74]),
    .MEM_MemtoReg     (EX_MEM[73:72]),
    .MEM_RegWrite     (EX_MEM[71]),
    .MEM_MemWrite     (EX_MEM[70]),
    .MEM_MemRead      (EX_MEM[69]),
    .MEM_WriteRegister(EX_MEM[68:64]),
    .MEM_ALUResult    (EX_MEM[63:32]),
    .MEM_WriteData    (EX_MEM[31:0]),
    // Output
    .irqout           (irq),
    .MEM_WB           (MEM_WB),

    // Display
    .cipher_output    (cipher_output)
);

endmodule
