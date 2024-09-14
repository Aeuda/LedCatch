   `include "vga_adapter/vga_adapter.v"
`include "vga_adapter/vga_controller.v"
`include "vga_adapter/vga_pll.v"
`include "vga_adapter/vga_address_translator.v"
`include "object_related/dropping_object.v"
//`include "player_related/animate_plyr.v"


module LedTop (CLOCK_50, KEY, SW, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, LEDR, GPIO, VGA_CLK, VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_R, VGA_G,VGA_B);
	input CLOCK_50;				
	input [3:0] KEY;
	input [9:0] SW;
	output [6:0] HEX0;
	output [6:0] HEX1;
	output [6:0] HEX2;
	output [6:0] HEX3;
	output [6:0] HEX4;
	output [6:0] HEX5;
	output [9:0] LEDR;
	inout  [3:0] GPIO;
	
	
		/*some notice here:
	address 56 to address 63 is where RNG generate the signal to dropping_object
	address 0 to address 7 is where player can control the signal */
	
	
	wire left, right, up, down; // for control, can be implemented further for PS2 keyboard
	/*assign down = SW[3]; //down means address -8
	assign up = SW[2]; // up means address +8
	assign left = SW[1]; // left means data / 2
	assign right = SW[0]; //right means data * 2

	*/
	wire [6:0] adjust;
	assign adjust = SW[6:0];
	reg exit;
	output			VGA_CLK;   				
	output			VGA_HS;					
	output			VGA_VS;					
	output			VGA_BLANK_N;				
	output			VGA_SYNC_N;				
	output	[7:0]	VGA_R;   			
	output	[7:0]	VGA_G;	 			
	output	[7:0]	VGA_B;   			

	wire resetn;
	wire clock;
	reg writeEn; //call uart module when it's 1
	
	assign clock = CLOCK_50;
	assign resetn = KEY[3];
	
	wire done_object;
	reg done_plyr;
	wire done_gameover;
	reg done_wait;
	wire done_cube;	
	reg done_clear;
	
	reg go_object;
	reg go_cube;
	reg go_plyr;
	reg go_gameover;
	reg go_clear;
	reg go_score;
	reg go_wait;
	
	
	//wire [5:0] addr_object;
	//wire [7:0] data_object;
	wire lose_object;
	
	//wire [5:0] addr_plyr;
	//wire [7:0] data_plyr;
	
	reg [5:0] addr_write;
	reg [7:0] data_write;
	
	wire [7:0] x_gameover; // vga_x value for plyr
	wire [6:0] y_gameover; // vga_y value for plyr
	wire [7:0] colour_gameover;
	
	reg [5:0] start_object_addr = 5'd7;
	reg [7:0] start_object_data = 8'b00001000;
	reg [5:0] start_plyr_addr = 6'd0;
	reg [7:0] start_plyr_data = 8'b0;
		
	
	wire [5:0] out_object_addr;
	//data is the same, so no need to assign here
	wire [5:0] out_plyr_addr = 6'd0;
	wire [7:0] out_plyr_data = 8'b00000000;
	
	
	wire [5:0] object_speed;
	
	assign object_speed = 6'b000001; //keep this for now, can be adjust for difficulty adjustment
	
	wire [22:0] vga_in;
	assign vga_in = {x_gameover, y_gameover, colour_gameover};
	wire [7:0] tx_byte;
	wire [5:0] cur_address;
	wire [6:0] next_address;
	wire  recv_byte_en;
	wire  clocksignal;
	wire is_transmitting;
	wire Enable;




	uart my_uart(.clk(CLOCK_50),
				.rst(~resetn),
				.tx(GPIO[0]),
				.transmit(clocksignal),
				.tx_byte(tx_byte),
				.is_transmitting(is_transmitting)
				);
			
			
	cube my_cube(
				.address(writeEn ? addr_write : cur_address),
				.clock(CLOCK_50),
				.data(data_write),
				.wren(writeEn),
				.q(tx_byte)
				);

	controlPath c(
				.clk(CLOCK_50),
				.resetn(~resetn),
				.go(go_cube),
				.curAddress(next_address),
				.addressClockon(clocksignal)
);

	assign cur_address = next_address;

	dataPath d(
				.clk(CLOCK_50),
				.resetn(~resetn),
				.clockon(clocksignal),
				.transmittingStatu(is_transmitting),
				.addressOut(next_address),
				.done_cube(done_cube)
); 
	wire [2:0] rand2_addr;
	wire [2:0] rand1_data;
	
	wire [5:0] random_start_addr;
	wire [7:0] random_start_data;
	
	RNG r_address(
				.clk(CLOCK_50),
				.reset(~resetn),
				.rand1(rand1_data),
				.rand2(rand2_addr)
);
	data_bit_selector d_gen(
				.rand1(rand1_data),
				.adjust(adjust),
				.result(random_start_data)
	);
	addr_bit_selector a_gen(
				.rand2(rand2_addr),
				.result(random_start_addr)
	);
	/*RNG random_number (
						//...above
						//need output below
						.random_x(x_object),
						.random_y(y_object),
						//.random_speed(object_speed)
						);*/
	
	/*control_plyr plyr (
						.go(go_plyr), 
						.resetn(resetn), 
						.in_addr(start_plyr_addr), 
						.in_data(start_plyr_data),
						.out_addr(out_plyr_addr), 
						.out_data(out_plyr_data), 
						.done(done_plyr), 
						.clock(CLOCK_50), 
						.up(up),
						.down(down),
						.left(left),
						.right(right)	
						); */
						
	
	draw_gameover gameover (
					.enable(go_gameover),
					.clock(CLOCK_50),
					.resetn(resetn),
					.vga_x(x_gameover),
					.vga_y(y_gameover),
					.colour(colour_gameover),
					.done(done_gameover)
					);
					
	
	wire ground;
	
	dropping_object obj (
					.go(go_object),
					.clock(CLOCK_50),
					.lose(lose_object),
					.resetn(resetn), 
					.addr_plyr(out_plyr_addr), 
					.data_plyr(out_plyr_data), 
					.in_addr(ground ? random_start_addr : start_object_addr), 
					.in_data(ground ? random_start_data : start_object_data), 
					.out_addr(out_object_addr), 
					.done(done_object),
					.speed(object_speed),
					.ground(ground)
					);
					
		
	//Score <-finished
	reg [27:0] score_timer = 27'b0;
	reg [23:0] score = 23'b0;
	wire [23:0] w_score;
	always @(posedge clock)
	begin
		if (go_score)
		begin
			score_timer = score_timer + 1'b1;
			if (score_timer == 49999999)
			begin
				score = score + 1'b1;
				score_timer = 27'b0;
			end
		end
		else
			score = 23'b0;
	end
	assign w_score = score;
	
	reg [27:0] wait_timer = 27'b0;
	
	always @(posedge clock)
	begin
		if (go_wait)
		begin
			wait_timer = wait_timer + 1'b1;
			if (wait_timer == 49999999)
			begin
				done_wait = 1;
				wait_timer = 27'b0;
			end
		end
	end
	
	decoder hex0 (
					.c(w_score[3:0]),
					.display(HEX0)
					);
	decoder hex1 (
					.c(w_score[7:4]),
					.display(HEX1)
					);
	decoder hex2 (
					.c(w_score[11:8]),
					.display(HEX2)
					);
	decoder hex3 (
					.c(w_score[15:12]),
					.display(HEX3)
					);
	decoder hex4 (
					.c(w_score[19:16]),
					.display(HEX4)
					);
	decoder hex5 (
					.c(w_score[23:20]),
					.display(HEX5)
					);
	
	//Clear and draw
	reg [5:0] address_clear = 6'b0;
	always @(posedge clock)
	begin
		if (go_clear)
		begin
			address_clear = address_clear + 1'b1;
			done_clear = 0;

			if (address_clear == 6'b111111)
			begin
				address_clear = 6'b0;
				done_clear = 1;
			end
		end
			
	end
	
	//Main controlpath(FSM)
	wire start;
	assign start = KEY[0]; //wait for furture implementing for ps2 decoder
	
	parameter [3:0] MENU = 3'b000, PRINT_OBJECT = 3'b001, PRINT_PLYR = 3'b010, PRINT_CUBE = 3'b011, EXIT = 3'b100,  CLEAR = 3'b101, WAIT = 3'b110;
	reg [3:0] PresentState, NextState;
	
	always @(*)
	begin : StateTable
		case (PresentState)
		MENU:
		begin
			if (start == 1)
				NextState = MENU;
			else
				NextState = PRINT_OBJECT;
		end
		PRINT_OBJECT:
		begin
			if (lose_object)
			begin
				NextState = PRINT_CUBE;
			end
			else
			begin
				if (done_object)
					NextState = PRINT_CUBE;
				else
					NextState = PRINT_OBJECT;
			end
		end
		PRINT_PLYR:
		begin
			if (done_plyr)
				NextState = PRINT_CUBE;
			else
				NextState = PRINT_PLYR;
		end
		PRINT_CUBE:
		begin
			if(done_cube)
				NextState = CLEAR;
			else
				NextState = PRINT_CUBE;
		end
		EXIT:
		begin
			if (start == 1)
				NextState = EXIT;
			else
				NextState = CLEAR;
		end
		CLEAR:
		begin
			if (done_clear)
				NextState = PRINT_OBJECT;
			else
				NextState = CLEAR;
		end
		WAIT:
		begin
			if (done_wait)
				NextState = CLEAR;
			else
				NextState = WAIT;
		end
		default: NextState = MENU;
		endcase
	end
	
	always @(*)
	begin: output_logic
		go_clear = 0;
		go_object = 0;
		go_plyr = 0;
		go_gameover = 0;
		writeEn = 0;
		go_score = 0;
		go_cube = 0;
		exit = 0;
		go_wait = 0;
		addr_write = start_object_addr;
		data_write = start_object_data;
		case (PresentState)
			MENU:
			begin
				writeEn = 0;
			end
			PRINT_OBJECT:
			begin
				go_object = 1;
				writeEn = 1;
				go_score = 1;
				addr_write = out_object_addr;
				start_object_addr = out_object_addr;
				data_write = ground ? random_start_data : start_object_data;
			end
			PRINT_PLYR:
			begin
				go_plyr = 1;
				writeEn = 1;
				go_score = 1;
				addr_write = out_plyr_addr;
				start_plyr_addr = out_plyr_addr;
				data_write = out_plyr_data;
				start_plyr_data = out_plyr_data;
				
				done_plyr = 1; //put here just to check for object_falling
			end
			PRINT_CUBE:
			begin
				writeEn = 0; //ready to transfer data
				go_cube = 1;
				go_score = 1;
			end
			CLEAR:
			begin
				go_clear = 1;
				writeEn = 1;
				go_score = 1;
				addr_write = address_clear;
				data_write = 8'b0;
			end
			EXIT:
			begin
				go_gameover = 1;
				go_clear = 1;
				writeEn = 1;
				exit = 1;
			end
			WAIT:
			begin
				go_wait = 1;
				writeEn = 1;
				go_score = 1;
			end
		endcase
	end
	
	always @(posedge clock)
	begin: state_FFs
		if(resetn == 1'b0)
			PresentState <= MENU;
		else
			PresentState <= NextState;
	end

	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(vga_in[7:0]),
			.x(vga_in[22:15]),
			.y(vga_in[14:8]),
			.plot(writeEn), 
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 8;
		defparam VGA.BACKGROUND_IMAGE = "main_menu.mif"; 
endmodule

module decoder (c, display);

				
	input [0:3] c;     
	output [6:0] display;   
	
	assign display[0] = ~c[0] & ~c[1] & ~c[2] & c[3] | ~c[0] & c[1] & ~c[2] & ~c[3] | c[0] & ~c[1] & c[2] & c[3] | c[0] & c[1] & ~c[2] & c[3];
	assign display[1] = ~c[0] & c[1] & ~c[2] & c[3] | c[1] & c[2] & ~c[3] | c[0] & c[2] & c[3] | c[0] & c[1] & ~c[3];
	assign display[2] = ~c[0] & ~c[1] & c[2] & ~c[3] | c[0] & c[1] & ~c[3] | c[0] & c[1] & c[2];
	assign display[3] = ~c[0] & ~c[1] & ~c[2] & c[3] | ~c[0] & c[1] & ~c[2] & ~c[3] | c[1] & c[2] & c[3] | c[0] & ~c[1] & c[2] & ~c[3];
	assign display[4] = ~c[0] & c[3] | ~c[1] & ~c[2] & c[3] | ~c[0] & c[1] & ~c[2];
	assign display[5] = ~c[0] & ~c[1] & c[3] | ~c[0] & ~c[1] & c[2] | ~c[0] & c[2] & c[3] | c[0] & c[1] & ~c[2] & c[3];
	assign display[6] = ~c[0] & ~c[1] & ~c[2] | ~c[0] & c[1] & c[2] & c[3] | c[0] & c[1] & ~c[2] & ~c[3];

endmodule

module controlPath(
	input wire clk, resetn, go,
	input wire [6:0] curAddress,
	output reg addressClockon
);

reg state, nextState;
	
localparam St0 = 1'b0,
		    St1 = 1'b1;

always @(*) begin
	case(state)
		St0: nextState = (go && curAddress != 7'd64) ? St1 : St0;
		St1: nextState = (curAddress == 7'd64) ? St0 : St1;
		default: nextState = St0;
	endcase
end

always @(*) begin
	case(state)
		St0:addressClockon = 0;
		St1:addressClockon = 1;
	endcase
end

always @(posedge clk) begin
	if(resetn)  
		state <= St0;
	else 
		state <= nextState;
end


endmodule


module dataPath(
	input wire clk, resetn, clockon,
	input wire transmittingStatu,
	output reg [6:0] addressOut,
	output reg done_cube
);

always @(posedge clk) begin
	if(resetn) begin
		addressOut <=  7'b1111111;
		done_cube <= 0;
	end else if (clockon | addressOut == 7'd64) begin
		if(!transmittingStatu) begin
			if (addressOut == 7'd64)
			begin
				addressOut <= 7'b1111111;
				done_cube <= 1;
			end
			else 
			begin
			done_cube <= 0;
			addressOut <= addressOut +1; 
			end
		end
	end
end


endmodule