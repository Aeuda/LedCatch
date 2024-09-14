# LED Cube "Catcher" Game (in FPGA)

## Overview
This project involved designing and developing an interactive "Catcher" game using an 8x8x8 LED cube connected to an FPGA. The game logic was implemented in Verilog, and the LED cube displayed dynamic light patterns based on player interaction. The system also integrated UART-based serial communication to ensure smooth operation between the FPGA and the LED cube.

## Features
- **Game Development on FPGA:**  
  Designed and implemented an interactive "Catcher" game, controlling an 8x8x8 LED cube through Verilog on the FPGA, demonstrating proficiency in hardware description and digital design.
  
- **Finite State Machine (FSM) Design:**  
  Developed the game logic using a state machine in Verilog, ensuring responsive gameplay and smooth transitions for dynamic light patterns on the LED cube.

- **Hardware Integration:**  
  Assembled and soldered the components of the LED cube, enabling precise control of its LEDs and ensuring reliable communication between the FPGA and the cube.

- **UART Communication:**  
  Embedded a UART transmitter for serial communication, facilitating seamless data transmission between the FPGA and the LED cube.

## How it Works
1. **Game Logic:** Players interact with the FPGA to catch light patterns displayed on the LED cube.
2. **State Machine Control:** The game logic, implemented as a finite state machine, controls the LED cube, creating real-time visual feedback.
3. **Hardware and Communication:** The UART transmitter ensures smooth communication between the FPGA and the LED cube for real-time gameplay.

## Technologies Used
- **Verilog:** All game logic and LED control were implemented using Verilog.
- **FPGA:** The core of the game system, managing the LED cube and player interactions.
- **8x8x8 LED Cube:** Used to display dynamic game patterns and real-time feedback.
- **UART Communication:** For data exchange between the FPGA and LED cube.

## Future Enhancements
- Add more game modes and challenges to make the gameplay more engaging.
- Optimize the UART communication for faster data transmission.
  
## Setup and Usage
1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/your-repo-name.git
