`include "tomato_ROM.v"
module draw_object (x, y, startx, starty, color, clock, writeEn, reset, done_print);
	input clock;
	input writeEn;
	input reset;
	input [7:0] startx;
	input [6:0] starty;
	output reg [7:0] x;
	output reg [6:0] y;
	output reg done_print;
	output [7:0] color;
	
	wire [14:0] address;
	
	
	tomato_ROM tomato (
					.address(address),
					.clock(clock),
					.q(color)
					);
	
	reg [6:0] plotCounter;
	always @(posedge clock)
	begin
		if (~reset)
		begin
			x <= 0;
			y <= 0;
			plotCounter <= 0;
		end
		else if (writeEn)
		begin
			if(plotCounter != 7'b1000000)
			begin
                plotCounter <=  plotCounter + 1;
				x <= startx + plotCounter[2:0];
				y <= starty + plotCounter[5:3];
			end
			else
			begin
				plotCounter <= 0;
			end
		end
	end

	
	assign address = x + 8*(y);
	
	
endmodule