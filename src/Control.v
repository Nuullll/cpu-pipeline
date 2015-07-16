module Control(Instruction, PCH, stall, UI,
	            PCSrc, Branch, RegWrite, RegDst, 
	            MemRead, MemWrite, MemtoReg, 
	            ALUSrc1, ALUSrc2, ExtOp, LuOp, ALUOp);
	input             PCH;
   input      [31:0] Instruction;
	input             stall;
	output reg        UI;
	output reg [2:0]  PCSrc;
	output reg        Branch;
	output reg        RegWrite;
	output reg [1:0]  RegDst;
	output reg        MemRead;
	output reg        MemWrite;
	output reg [1:0]  MemtoReg;
	output reg        ALUSrc1;
	output reg        ALUSrc2;
	output reg        ExtOp;
	output reg        LuOp;
	output     [4:0]  ALUOp;
	
	always @(*)
	begin
	   if (stall) PCSrc <= 3'b100;  //stall
		else 
		begin
       case (Instruction[31:26])//opcode[5:0]
	        6'h23: PCSrc <= 3'b000;
		     6'h2b: PCSrc <= 3'b000;
		     6'h0f: PCSrc <= 3'b000;
		     6'h08: PCSrc <= 3'b000;
		     6'h09: PCSrc <= 3'b000;
		     6'h0c: PCSrc <= 3'b000;
		     6'h0a: PCSrc <= 3'b000;
		     6'h0b: PCSrc <= 3'b000;
		     6'h04: PCSrc <= 3'b011;//beq
		     6'h02: PCSrc <= 3'b001;//j
		     6'h03: PCSrc <= 3'b001;//jal
		     6'h06: PCSrc <= 3'b011;//blez
		     6'h07: PCSrc <= 3'b011;//bgtz
		     6'h01: begin
			             if(Instruction[20:16] == 00001) 
							     PCSrc <= 3'b011;//bgez
							 else 
							     PCSrc <= PCH? 3'b000: 3'b101;//UI
						end
			  6'h05: PCSrc <= 3'b011;//bne
		     6'h0: case (Instruction[5:0])//funct[5:0]
		               6'h20: PCSrc <= 3'b000;
					      6'h21: PCSrc <= 3'b000;
					      6'h22: PCSrc <= 3'b000;
					      6'h23: PCSrc <= 3'b000;
					      6'h24: PCSrc <= 3'b000;
					      6'h25: PCSrc <= 3'b000;
					      6'h26: PCSrc <= 3'b000;
					      6'h27: PCSrc <= 3'b000;
					      6'h00: PCSrc <= 3'b000;
					      6'h02: PCSrc <= 3'b000;
					      6'h03: PCSrc <= 3'b000;
					      6'h2a: PCSrc <= 3'b000;
					      6'h2b: PCSrc <= 3'b000;
					      6'h08: PCSrc <= 3'b010;//jr
					      6'h09: PCSrc <= 3'b001;//jalr
					      default: begin 
							             PCSrc <= PCH? 3'b000: 3'b101;//UI
										end
				     endcase 
		     default: begin 
			               PCSrc <= PCH? 3'b000: 3'b101;//UI
						  end
	    endcase
		 UI <= PCSrc[2];
		end
		case (Instruction[31:26])
			6'b000_100: Branch <= 1;  //beq
			6'b000_101: Branch <= 1;  //bne
			6'b000_110: Branch <= 1;  //blez
			6'b000_111: Branch <= 1;  //bgtz
			6'b000_001: Branch <= 1;  //bgez
			default: Branch <= 0;
		endcase
		case (Instruction[31:26])
			6'b101_011: RegWrite <= 0;  //sw
			6'b000_100: RegWrite <= 0;  //beq
			6'b000_101: RegWrite <= 0;  //bne
			6'b000_110: RegWrite <= 0;  //blez
			6'b000_111: RegWrite <= 0;  //bgtz
			6'b000_001: RegWrite <= 0;  //bgez
			6'b000_010: RegWrite <= 0;  //j
			6'b000_000: begin 
			                 if (Instruction[5:0]==6'b001_000) RegWrite <= 0;  //jr
			                 else RegWrite <= 1;
							end
			default: RegWrite <= 1;
		endcase
		case (Instruction[31:26])
			6'b100_011: RegDst <= 0;  //lw
			6'b001_111: RegDst <= 0;  //lui
			6'b001_000: RegDst <= 0;  //addi
			6'b001_001: RegDst <= 0;  //addiu
			6'b001_100: RegDst <= 0;  //andi
			6'b001_010: RegDst <= 0;  //slti
			6'b001_011: RegDst <= 0;  //sltiu
			6'b000_011: RegDst <= 2;  //jal
			default: RegDst <= 1;
		endcase
		case (Instruction[31:26])
			6'b100_011: MemRead <= 1;  //lw
			default: MemRead <= 0;
		endcase
		case (Instruction[31:26])
			6'b101_011: MemWrite <= 1;  //sw
			default: MemWrite <= 0;
		endcase
		case (Instruction[31:26])
			6'b100_011: MemtoReg <= 1;  //lw
			6'b000_011: MemtoReg <= 2;  //jal
			6'b000_000: begin 
			                 if (Instruction[5:0]==6'b001_001) MemtoReg <= 2;  //jalr
			                 else MemtoReg <= 0;
							end
			default: MemtoReg <= 0;
		endcase
		case (Instruction[31:26])
			6'b000_000: begin
			                 if (Instruction[5:0]==6'b000_000) ALUSrc1 <= 1;  //sll
								  else if (Instruction[5:0]==6'b000_010) ALUSrc1 <= 1;  //srl
								  else if (Instruction[5:0]==6'b000_011) ALUSrc1 <= 1;  //sra
								  else ALUSrc1 <= 0;
							end
			default: ALUSrc1 <= 0;
		endcase
		case (Instruction[31:26])
			6'b100_011: ALUSrc2 <= 1;  //lw
			6'b101_011: ALUSrc2 <= 1;  //sw
			6'b001_111: ALUSrc2 <= 1;  //lui
			6'b001_000: ALUSrc2 <= 1;  //addi
			6'b001_001: ALUSrc2 <= 1;  //addiu
			6'b001_100: ALUSrc2 <= 1;  //andi
			6'b001_010: ALUSrc2 <= 1;  //slti
			6'b001_011: ALUSrc2 <= 1;  //sltiu
			default: ALUSrc2 <= 0;
		endcase
		case (Instruction[31:26])
			6'b001_100: ExtOp <= 0;  //andi
			default: ExtOp <= 1;
		endcase
		case (Instruction[31:26])
			6'b001_111: LuOp <= 1;  //lui
			default: LuOp <= 0;
		endcase		
	end
	
	assign ALUOp[3:0] = 
		(Instruction[31:26] == 6'h00)? 4'b0010: 
		(Instruction[31:26] == 6'h04)? 4'b0001:   //beq
		(Instruction[31:26] == 6'h05)? 4'b0011:   //bne
		(Instruction[31:26] == 6'h06)? 4'b0110:   //blez
		(Instruction[31:26] == 6'h07)? 4'b0111:   //bgtz
		(Instruction[31:26] == 6'h01)? 4'b1000:   //bgez
		(Instruction[31:26] == 6'h0c)? 4'b0100:   //andi
		(Instruction[31:26] == 6'h0a || Instruction[31:26] == 6'h0b)? 4'b0101:   //slti || sltiu
		4'b0000;
	assign ALUOp[4] = Instruction[26];
	
endmodule
