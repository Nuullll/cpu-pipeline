// IF.v

module IF (
    input clk,      // Clock
    input rst_n,    // Asynchronous reset active low
    input PC_IF_ID_Write,          // Whether PC and IF_ID can be changed
    input [31:0] branch_target,
    input [31:0] jump_target,   
    input [31:0] jr_target,     
    input [2:0] select_PC_next, // {Z, J, Jr} to select next PC
    input [1:0] status,         // 00: normal, 01: Reset, 10: Interrupt, 11: Exception
    
    output reg [63:0] IF_ID     // Register between IF and ID stage
);

reg [31:0] PC;
wire [31:0] PC_plus4;
wire [31:0] instruction;
wire flush_IF_ID;               // whether to flush IF_ID

assign PC_plus4 = {PC[31], PC[30:0] + 4};   // keep PC[31]

InstructionMemory ROM(
    .Address    (PC),
    .Instruction(instruction)
);

// whether to flush IF_ID
assign flush_IF_ID = (select_PC_next[2]) ? 1 : 0;

always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        PC <= 32'b0;
        IF_ID <= 0;
    end else begin
        if(PC_IF_ID_Write) begin   // enable to write PC and IF_ID
            case (select_PC_next)
                3'b000  : begin     // not branch, not j, not jr
                    case (status)
                        2'b00   : PC <= PC_plus4;
                        2'b01   : PC <= 32'b0;  // Reset
                        2'b10   : PC <= 32'h4;  // Interrupt
                        2'b11   : PC <= 32'h8;  // Exception
                        default : PC <= 32'hffff_ffff;  // Unexpected behavior
                    endcase
                end
                3'b100  : PC <= branch_target;  // branch
                3'b010  : PC <= jump_target;    // j
                3'b001  : PC <= jr_target;      // jr
                default : PC <= 32'hffff_ffff;  // Unexpected behavior
            endcase

            if(flush_IF_ID) IF_ID <= 0;
            else IF_ID <= {PC_plus4, instruction};
        end else if(flush_IF_ID) IF_ID <= 0;
    end
end

endmodule