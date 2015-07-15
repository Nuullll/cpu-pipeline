// ID.v

module ID (
    input clk,    // Clock
    input rst_n,  // Asynchronous reset active low
    input instruction,  // Get instruction from IF_ID[31:0]
    input PC_plus4,     // Get PC+4 from IF_ID[63:32]
    
    input RegWrite,     // From WB_RegWrite
    input [4:0] WriteRegister,  // From WB_WriteRegister
    input [31:0] RegWriteData,  // From WB_RegWriteData

    input EX_MemRead,   // Input for hazard unit to detect hazard
    input [4:0] EX_WriteRegister,   // Input for hazard unit to detect hazard

    // Output for IF
    output Z,   // Whether goto branch target
    output J,   // Whether it's a Jump instruction
    output JR,  // Whether it's a Jump Register instruction
    output PC_IF_ID_Write,  // Enable for PC and IF_ID
    output [31:0] branch_target, 
    output [31:0] jump_target, 
    output [31:0] jr_target,

    output ID_EX
);

endmodule