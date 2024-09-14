module dropping_object (
	input clock,   
	input go,      
	output reg lose,        // Signal indicating if the player has lost
	input resetn,      
	input [5:0] addr_plyr,  // Player's x-coordinate
	input [7:0] data_plyr,    
	input [5:0] in_addr,
	input [7:0] in_data,
	input [5:0] speed,
	output reg [5:0] out_addr,
	output reg done,
	output reg ground   
);

	reg go_increment;
	reg go_increment_init;
	
	parameter [2:0] WAIT = 3'b000, SHIFT = 3'b010, CHECK = 3'b100;
	
	// State machine logic
	reg [2:0] PresentState, NextState;
	always @(*) begin : StateTable
		case (PresentState)
			WAIT: begin
				done = 0;
				NextState = go ? SHIFT : WAIT;
				lose = 0;
			end
			SHIFT: begin
				NextState = CHECK;
				done = 0;
				lose = 0;
				ground = 0;
			end
			CHECK: begin
				if (out_addr - 1 == 6'd7  | out_addr - 1 == 6'd15 | out_addr - 1 == 6'd23 | out_addr - 1 == 6'd31 | out_addr - 1 == 6'd39 | out_addr - 1 == 6'd47 | out_addr - 1 == 6'd55 | out_addr - 1 == 6'd63) begin // check if the game is endornot
					if (in_data != data_plyr || out_addr - 1 != addr_plyr) begin
						NextState = WAIT;
						ground = 1;
						lose = 1;
						done = 0;
					end else begin
						NextState = WAIT;
						lose = 0;
						done = 1;
					end
				end else begin
					NextState = SHIFT;
					done = 1;
					lose = 0;
				end
			end
			default: begin 
				NextState = WAIT;
				done = 0;
				lose = 0;
			end
		endcase
	end
	
	always @(posedge clock) begin
		if (go_increment_init) out_addr = in_addr; //start from the y = 10
		if (go_increment) out_addr = out_addr + speed; //start to dropping down
	end
	
	// Output logic for the state machine
	always @(*) begin: output_logic
		go_increment_init = 0;
		go_increment = 0;
		case (PresentState)
			WAIT: begin
				go_increment_init = 1;
			end
			SHIFT: go_increment = 1;
		endcase
	end
	
	//state update
	always @(posedge clock) begin: state_FF
		PresentState <= resetn ? NextState : WAIT;
	end
					
endmodule
