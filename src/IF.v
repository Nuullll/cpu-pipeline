// IF.v

module IF (
    input clk,      // Clock
    input rst_n,    // Asynchronous reset active low
    input PC_IF_ID_Write,          // Whether PC and IF_ID can be changed
    input [31:0] branch_target,
    input [31:0] jump_target,   
    input [31:0] jr_target,     
    input [2:0] select_PC_next, // {Z, J, JR} to select next PC
    input [1:0] status,         // {interrupt, exception}
    
    output reg [95:0] IF_ID     // Register between IF and ID stage
);

reg [31:0] PC;
wire [31:0] PC_plus4;
wire [31:0] instruction;
wire flush_IF_ID;               // whether to flush IF_ID

// If status is not normal, PC_plus4[31] should be 1
assign PC_plus4 = {(|status)|PC[31], PC[30:0] + 31'd4};   // keep PC[31]

InstructionMemory ROM(
    // Input
    .Address    (PC),
    // Output
    .Instruction(instruction)
);

// Whether to flush IF_ID
// Flush if Z || J || JR and status == 2'b00
assign flush_IF_ID = (|select_PC_next) & ~(|status);

always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        PC <= 32'h8000_0000;
        IF_ID <= 0;
    end else begin
        if(PC_IF_ID_Write) begin   // enable to write PC and IF_ID
            case (status)
                2'b00   : begin
                    case (select_PC_next)
                        3'b000  : PC <= PC_plus4;
                        3'b100  : PC <= branch_target;  // branch
                        3'b010  : PC <= jump_target;    // j
                        3'b001  : PC <= jr_target;      // jr
                        default : PC <= 32'hffff_ffff;  // Unexpected behavior
                    endcase
                end
                2'b10   : PC <= 32'h8000_0004;  // Interrupt
                2'b01   : PC <= 32'h8000_0008;  // Exception
                default : PC <= 32'hffff_ffff;  // Unexpected behavior
            endcase

            if(flush_IF_ID) IF_ID <= {IF_ID[63:32], 64'd0};
            else IF_ID <= {IF_ID[63:32], PC_plus4, instruction};
        end else if(flush_IF_ID) IF_ID <= 0;
    end
end

endmodule
