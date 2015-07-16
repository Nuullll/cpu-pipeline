
module DataMemory(reset, clk, Address, Write_data, Read_data, MemRead, MemWrite, 
                  led, digi, irqout, result_start);
	input             reset, clk;
	input      [31:0] Address, Write_data;
	input             MemRead, MemWrite;
	// input      [7:0]  switch;
	output            result_start;
	output reg [7:0]  led;
	output reg [11:0] digi;
	output wire       irqout;
	output reg [31:0] Read_data;
	
	parameter RAM_SIZE = 16;
	parameter RAM_SIZE_BIT = 8;
	
	reg [31:0] RAM_data[RAM_SIZE - 1: 0];
	reg [31:0] TH,TL;
	reg [2:0]  TCON;
	reg        TCON_r1, TCON_r2;
	wire       result_start;
	assign irqout = TCON[2];
	assign result_start = TCON_r1 & ~TCON_r2;
	
	always @(*) 
	begin
	    case(Address)
			  32'h40000000: Read_data <= MemRead? TH: 32'd0;
			  32'h40000004: Read_data <= MemRead? TL: 32'd0;
			  32'h40000008: Read_data <= MemRead? {29'b0,TCON}: 32'd0;
			  32'h4000000c: Read_data <= MemRead? {24'b0,led}: 32'd0;
			  // 32'h40000010: Read_data <= MemRead? {24'b0,switch}: 32'd0;
			  32'h40000014: Read_data <= MemRead? {20'b0,digi}: 32'd0;
			  default: Read_data <= MemRead? RAM_data[Address[31:2]]: 32'd0;
		 endcase
	end
	
	always@(negedge reset or posedge clk) 
	begin
	    if(~reset) 
		 begin
		    TH <= 32'b0;
		    TL <= 32'b0;
		    TCON <= 3'b0;	
	    end
	    else 
		 begin
		     TCON_r1 <= TCON[1];	 
	        TCON_r2 <= TCON_r1;
		     if(TCON[0]) 
			  begin	    //timer is enabled
			      if(TL==32'hffffffff) 
					begin
				       TL <= TH;
				       if(TCON[1]) TCON[2] <= 1'b1;		//irq is enabled
			      end
			      else TL <= TL + 1;
		     end
		     if(MemWrite) begin
			      case(Address)
				       32'h40000000: TH <= Write_data;
				       32'h40000004: TL <= Write_data;
				       32'h40000008: TCON <= Write_data[2:0];		
				       32'h4000000C: led <= Write_data[7:0];			
				       32'h40000014: digi <= Write_data[11:0];
				       default: ;
			      endcase
		     end
	    end
   end
	
	integer i;
	always @(negedge reset or posedge clk)
	   if (~reset)
	       for (i = 0; i < RAM_SIZE; i = i + 1)
		        RAM_data[i] <= 32'h00000000;
		else if (MemWrite && Address[31:2] < RAM_SIZE)
		begin 
		    RAM_data[Address[31:2]] <= Write_data;
		end		

			
endmodule
