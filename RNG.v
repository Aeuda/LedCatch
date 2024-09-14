module random_number_generator ( //this can't compile
  input wire clock,         // Clock input
  output wire [2:0] rand1,  // 6-bit random number output (0 to 63)
  output wire [2:0] rand2  
);

reg [3:0] counter;          // 4-bit counter for clock cycles
reg [2:0] shift_register;   // 6-bit shift register for random number
reg [2:0] shift_register2;   // 6-bit shift register for random number

always @(posedge clock) begin
  if (counter < 4'd9) begin
    counter <= counter + 1;
  end else begin
    counter <= 4'd0;
    // Shift the shift register and generate a new random bit
    shift_register <= {shift_register[4:0], shift_register[5] ^ shift_register[3]};
    shift_register2 <= {shift_register2[4:0], shift_register2[5] ^ shift_register2[3]};
  end
end

assign rand1 = shift_register;
assign rand2 = shift_register2; 
endmodule



module RNG(
    input clk,
    input reset,
    output [2:0] rand1,
    output [2:0] rand2  
);


reg [2:0] lfsr1 = 3'b001; 
reg [2:0] lfsr2 = 3'b010; 


always @(posedge clk or posedge reset) begin
    if (reset) begin
        lfsr1 <= 3'b001;
        lfsr2 <= 3'b010; 
    end else begin
        lfsr1 <= {lfsr1[1:0], lfsr1[2] ^ lfsr1[0]};

        lfsr2 <= {lfsr2[1:0], lfsr2[2] ^ lfsr2[1]};
    end
end

// Assign the outputs
assign rand1 = lfsr1;
assign rand2 = lfsr2;

endmodule



module data_bit_selector (
  input wire [2:0] rand1,     // 3-bit random number input (0-7)
  input wire [6:0] adjust,
  output wire [7:0] result     // 8-bit result output
);

reg [7:0] result_reg; // 8-bit register to store the special bits

always @(*) begin
    case (rand1)
      3'b000: result_reg = 8'b00000001 + adjust; // Set least significant bit to 1 when rand2 is 000
      3'b001: result_reg = 8'b00000010 + adjust;  // Set the next bit to 1 when rand2 is 001
      3'b010: result_reg = 8'b00000100 + adjust; // Set the next bit to 1 when rand2 is 010
      3'b011: result_reg = 8'b00001000 + adjust; // Set the next bit to 1 when rand2 is 011
      3'b100: result_reg = 8'b00010000 + adjust; // Set the next bit to 1 when rand2 is 100
      3'b101: result_reg = 8'b00100000 + adjust; // Set the next bit to 1 when rand2 is 101
      3'b110: result_reg = 8'b01000000 + adjust; // Set the next bit to 1 when rand2 is 110
      3'b111: result_reg = 8'b10000000 + adjust; // Set all bits to 1 when rand2 is 111
    endcase

end

assign result = result_reg; // Connect the output to the result register

endmodule


module addr_bit_selector (
  input wire [2:0] rand2,     // 3-bit random number input (0-7)
  output wire [5:0] result     // 8-bit result output
);

reg [5:0] result_reg; // 8-bit register to store the special bits

always @(*) begin
    case (rand2)
      3'b000: result_reg = 6'd0; // Set least significant bit to 1 when rand2 is 000
      3'b001: result_reg = 6'd8; // Set the next bit to 1 when rand2 is 001
      3'b010: result_reg = 6'd16; // Set the next bit to 1 when rand2 is 010
      3'b011: result_reg = 6'd24; // Set the next bit to 1 when rand2 is 011
      3'b100: result_reg = 6'd32; // Set the next bit to 1 when rand2 is 100
      3'b101: result_reg = 6'd40; // Set the next bit to 1 when rand2 is 101
      3'b110: result_reg = 6'd48; // Set the next bit to 1 when rand2 is 110
      3'b111: result_reg = 6'd56; // Set all bits to 1 when rand2 is 111
    endcase
end

assign result = result_reg; // Connect the output to the result register

endmodule
