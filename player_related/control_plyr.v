module catcher_control(  //not working
  input wire clock,           // Clock input
  input wire reset,           // Reset input
  input wire up_switch,       // Input switch for moving the catcher up
  input wire down_switch,     // Input switch for moving the catcher down
  input wire left_switch,     // Input switch for moving the catcher left
  input wire right_switch,    // Input switch for moving the catcher right
  output wire go_plyr,        // Output for control module to indicate the start of the player control
  input wire start_plyr_addr, // Input from control module for starting player address
  input wire start_plyr_data, // Input from control module for starting player data
  output wire out_plyr_addr,  // Output to control module for player address
  output wire out_plyr_data,  // Output to control module for player data
  output wire done_plyr       // Output to control module indicating completion
);

reg [5:0] memory_address;     // Address for memory access
reg [7:0] memory_data;        // Data for memory access

assign out_plyr_addr = memory_address;
assign out_plyr_data = memory_data;

always @(posedge clock or posedge reset) begin
  if (reset) begin
    memory_address <= 6'b000000; // Initialize memory address
    memory_data <= 8'b00000000;  // Initialize memory data
    go_plyr <= 1'b0;             // Deassert go_plyr on reset
  end else begin
    // Move the memory address and data based on switch input
    if (left_switch) begin
      if (memory_address[5:0] != 6'b000000) begin
        memory_data <= ~memory_data; // Toggle memory data between 0 and 1
        memory_address <= memory_address - 1;
      end
    end else if (right_switch) begin
      if (memory_address[5:0] != 6'b111111) begin
        memory_data <= ~memory_data; // Toggle memory data between 0 and 1
        memory_address <= memory_address + 1;
      end
    end else if (up_switch) begin
      if (memory_address[5:0] < 6'b110000) begin
        memory_data <= ~memory_data; // Toggle memory data between 0 and 1
        memory_address <= (memory_address + 8) % 64; // Move address up by 8, handling wrap-around
      end
    end else if (down_switch) begin
      if (memory_address[5:0] >= 6'b100000) begin
        memory_data <= ~memory_data; // Togglse memory data between 0 and 1
        memory_address <= (memory_address - 8 + 64) % 64; // Move address down by 8, handling wrap-around
      end
    end
    go_plyr <= 1'b1; // Set go_plyr to 1 to indicate that the control module can start processing
    done_plyr <= 1'b0; // Set done_plyr to 0 to indicate that the processing is ongoing
  end
end

endmodule