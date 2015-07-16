// MEM.v

module MEM (
    input clk,    // Clock
    input rst_n,  // Asynchronous reset active low
    
    input MEM_MemWrite,         // From EX_MEM[70]
    input MEM_MemRead,          // From EX_MEM[69]
    input [31:0] MEM_ALUResult, // From EX_MEM[63:32]
    input [31:0] MEM_WriteData, // From EX_MEM[31:0]

    // Pass from EX_MEM to MEM_WB
    input [31:0] PC_plus4,      // From EX_MEM[105:74]
    input [1:0] MEM_MemtoReg,   // From EX_MEM[73:72]
    input MEM_RegWrite,         // From EX_MEM[71]
    input [4:0] MEM_WriteRegister,  // From EX_MEM[68:64]

    output result_start,        // For uart, to receive result
    output [7:0] led,
    output [11:0] digi,

    output [103:0] MEM_WB
);

wire [31:0] MEM_ReadData;

DataMemory D1(
    // Input
    .reset       (rst_n),
    .clk         (clk),
    .Address     (MEM_ALUResult),
    .Write_data  (MEM_WriteData),
    .MemRead     (MEM_MemRead),
    .MemWrite    (MEM_MemWrite),
    // Output
    .Read_data   (MEM_ReadData),
    .result_start(result_start),
    .led         (led),
    .digi        (digi),
    .irqout      (irqout)       // T.B.C
);

always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        MEM_WB <= 0;
    end else begin
        MEM_WB[31:0] <= MEM_ALUResult;
        MEM_WB[63:32] <= MEM_ReadData;
        MEM_WB[68:64] <= MEM_WriteRegister;
        MEM_WB[71:69] <= {MEM_MemtoReg, MEM_RegWrite};
        MEM_WB[103:72] <= PC_plus4;
    end
end

endmodule
