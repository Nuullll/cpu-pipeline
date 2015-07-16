module ALUControl(ALUOp, Funct, ALUCtl, Sign);
	input      [4:0] ALUOp;
	input      [5:0] Funct;
	output reg [5:0] ALUCtl;
	output Sign;
	
	parameter aluAND = 6'b011_000;
	parameter aluOR  = 6'b011_110;
	parameter aluADD = 6'b000_000;
	parameter aluSUB = 6'b000_001;
	parameter aluNOR = 6'b010_001;
	parameter aluXOR = 6'b010_110;
	parameter aluSLL = 6'b100_000;
	parameter aluSRL = 6'b100_001;
	parameter aluSRA = 6'b100_011;
	parameter aluA   = 6'b011_010;////////////
	parameter aluEQ  = 6'b110_011;
	parameter aluNEQ = 6'b110_001;
	parameter aluLT  = 6'b110_101;
	parameter aluLEZ = 6'b111_101;
	parameter aluGEZ = 6'b111_001;
	parameter aluGTZ = 6'b111_111;
	
	assign Sign = (ALUOp[3:0] == 3'b0010)? ~Funct[0]: ~ALUOp[4];
	
	reg [5:0] aluFunct;
	always @(*)
		case (Funct)
			6'b00_0000: aluFunct <= aluSLL;
			6'b00_0010: aluFunct <= aluSRL;
			6'b00_0011: aluFunct <= aluSRA;
			6'b10_0000: aluFunct <= aluADD;
			6'b10_0001: aluFunct <= aluADD;
			6'b10_0010: aluFunct <= aluSUB;
			6'b10_0011: aluFunct <= aluSUB;
			6'b10_0100: aluFunct <= aluAND;
			6'b10_0101: aluFunct <= aluOR;
			6'b10_0110: aluFunct <= aluXOR;
			6'b10_0111: aluFunct <= aluNOR;
			default: aluFunct <= aluADD;
		endcase
	
	always @(*)
		case (ALUOp[3:0])
			4'b0000: ALUCtl <= aluADD;
			4'b0001: ALUCtl <= aluEQ;//beq
			4'b0100: ALUCtl <= aluAND;
			4'b0101: ALUCtl <= aluLT;
			4'b0010: ALUCtl <= aluFunct;
			4'b0011: ALUCtl <= aluNEQ;//bne
			4'b0110: ALUCtl <= aluLEZ;//blez
			4'b0111: ALUCtl <= aluGTZ;//bgtz
			4'b1000: ALUCtl <= aluGEZ;//bgez
			default: ALUCtl <= aluADD;
		endcase

endmodule
