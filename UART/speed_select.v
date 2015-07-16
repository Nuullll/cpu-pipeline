module speed_select(clk,rst_n,start,clk_bps);

input  clk;
input  rst_n;
input  start;
output clk_bps;

parameter DIV=(50_000_000/9600);
parameter DIV_half=(DIV/2);

reg [12:0] cnt;
reg        clk_bps_r;

always @ (posedge clk or negedge rst_n)
if(!rst_n) cnt<=13'd0;
else if((cnt==DIV)||!start) cnt<=13'd0;
else cnt<=cnt+1'b1;

always @ (posedge clk or negedge rst_n)
if(!rst_n) clk_bps_r<=1'b0;
else if(cnt==DIV_half) clk_bps_r<=1'b1;
else clk_bps_r<=1'b0;

assign clk_bps = clk_bps_r;

endmodule
