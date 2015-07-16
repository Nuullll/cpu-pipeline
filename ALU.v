module ALU(A,B,ALUfun,S,sign);
    input [31:0] A,B;
    input [5:0]  ALUfun;
    input        sign;
    output [31:0] S;
    wire  [31:0] addout,compareout,logicout,shifterout;
    wire         Z,V,N;
	 
    adder addmodule(.A(A),.B(B),.S(addout),.addorsub(ALUfun[0]),. Z(Z),.V(V),.N(N),.sign(sign));
	 
    cmp comparemodule(.V(V),.Z(Z),.N(N),.ALUfun(ALUfun[2:0]),.S(compareout));
	 
    logicer logicmodule(.A(A),.B(B),.ALUfun(ALUfun[3:0]),.Z(logicout));
	 
    shifter shiftmodule(.A(A),.B(B),.Z(shifterout),.ALUfun(ALUfun[1:0]));
	 
    mux_4 m(.A(addout),.B(logicout),.C(shifterout),.D(compareout),.s(ALUfun[5:4]),.Z(S));
	 
endmodule

module mux_4(A,B,C,D,s,Z);
	input      [31:0] A,B,C,D;
	input      [1:0]  s;
	output reg [31:0] Z;
	always@(*)
	case(s)
		2'b00:Z = A;
		2'b01:Z = B;
		2'b10:Z = C;
		default:Z = D;
	endcase
endmodule

module adder(A,B,S,addorsub,Z,V,N,sign);
	input      [31:0] A,B;
	input             sign,addorsub;
	output reg        Z,V,N;
	output reg [31:0] S;
	
	always @(*)
	begin
	case(addorsub)
		1'b0:
		begin
			S = A + B;
			if(S == 0)
			begin
				Z = 1;
				N = 0;
			end
			else if(S < 0)
			begin
				Z = 0;
				N = 1;
			end
			else
			begin
				Z = 0;
				N = 0;
			end
			
			if((A > 0&& B>0 && S<0)||(A < 0&& B<0 && S>0))
				V = 1;
			else
				V = 0;
		end
		
		1'b1:
		begin
			S = A + (~B+1);
			if(S == 0)
			begin
				Z = 1;
				N = 0;
			end
			else if(S[31])
			begin
				Z = 0;
				N = 1;
			end
			else
			begin
				Z = 0;
				N = 0;
			end
			
			if((A > 0&& (~B+1)>0 && S<0)||(A < 0&& (~B+1)<0 && S>0))
				V = 1;
			else
				V = 0;
		end
	endcase
	end
	
endmodule

module cmp(Z,V,N,ALUfun,S);
	input             Z,V,N;
	input      [2:0]  ALUfun;
	output reg [31:0] S;
	always @(*)
	case(ALUfun)
		3'b001:
			if(Z == 0)
				S = 1;
			else
				S = 0;
		3'b000:
			if(Z == 0)
				S = 0;
			else
				S = 1;
		3'b010:
			if(N == 1)
				S = 1;
			else
				S = 0;
		3'b011:
			if(Z == 1)
				S = 1;
			else
				S = 0;
		3'b111:
		   if(N == 1) // bgtz
		      S = 0;
		   else
		      S = 1;
	endcase
endmodule

module logicer(A,B,ALUfun,Z);
	input [31:0]A,B;
	input [3:0]	ALUfun;
	output reg [31:0] Z;
	always@(*)
	case(ALUfun)
		4'b1000:
			Z = A&B;
		4'b1110:
			Z = A|B;
		4'b0110:
			Z = A^B;
		4'b0110:
			Z = ~(A|B);
		4'b1010:
			Z = A;
	endcase
endmodule

module shifter(A,B,Z,ALUfun);
	input      [31:0] A,B;
	input      [1:0]  ALUfun;
	output reg [31:0] Z;
	always@(*)
	begin
	case(ALUfun)
		2'b00:
			Z <= (B << A[4:0]);
		2'b01:
			Z <= (B >> A[4:0]);
		2'b11:
			Z <= ({{32{B[31]}}, B} >> A[4:0]);
	endcase
	end
endmodule
	
		
