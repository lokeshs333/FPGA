`timescale 1ns / 1ps

module multi_mode_logic(
    input [3:0] A,          // 4-bit input A
    input [3:0] B,          // 4-bit input B
    input [1:0] Mode,       // 2-bit control signal
    output reg [7:0] Y      // 8-bit output
    );

    always @(*) begin
        case(Mode)
            2'b00: Y = A + B;             // Addition
            2'b01: Y = A * B;             // Multiplication
            2'b10: Y = A / 2;            // Scaling (A/4 is equivalent to right shift by 2)
            2'b11: Y = 8'b11111111;       // Invalid mode: all LEDs turn on
            default: Y = 8'b00000000;
        endcase
    end
    
endmodule









#Testbenches
`timescale 1ns / 1ps

module tb_multi_mode_logic;

    // Inputs
    reg [3:0] A;
    reg [3:0] B;
    reg [1:0] Mode;

    // Output
    wire [7:0] Y;

    // Instantiate the Unit Under Test (UUT)
    multi_mode_logic uut (
        .A(A), 
        .B(B), 
        .Mode(Mode), 
        .Y(Y)
    );

    initial begin
        // Initialize Inputs
        A = 0; B = 0; Mode = 0;

        $display("Time 	| Mode 	| A    	| B    	| Y (Result)");
        $display("---------------------------------------");
        $monitor("%0t ns |  %b   | %d    | %d    | %d (%b)", $time, Mode, A, B, Y, Y);

        // --- Test Mode 00: Addition ---
        Mode = 2'b00; A = 4'd5; B = 4'd3; #20; // Expected Y = 8
        A = 4'd10; B = 4'd10; #20;             // Expected Y = 20

        // --- Test Mode 01: Multiplication ---
        Mode = 2'b01; A = 4'd4; B = 4'd3; #20; // Expected Y = 12
        A = 4'd15; B = 4'd2; #20;              // Expected Y = 30

        // --- Test Mode 10: Scaling (A/4) ---
        Mode = 2'b10; A = 4'd12; #20;          // Expected Y = 3
        A = 4'd8; #20;                         // Expected Y = 2

        // --- Test Mode 11: Invalid Mode ---
        Mode = 2'b11; #20;                     // Expected Y = 255 (All LEDs ON)

        $finish;
    end
      
endmodule









#xdc file
## Switches for Input A [3:0]
set_property PACKAGE_PIN V17 [get_ports {A[0]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {A[0]}]
set_property PACKAGE_PIN V16 [get_ports {A[1]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {A[1]}]
set_property PACKAGE_PIN W16 [get_ports {A[2]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {A[2]}]
set_property PACKAGE_PIN W17 [get_ports {A[3]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {A[3]}]

## Switches for Input B [3:0]
set_property PACKAGE_PIN W15 [get_ports {B[0]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {B[0]}]
set_property PACKAGE_PIN V15 [get_ports {B[1]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {B[1]}]
set_property PACKAGE_PIN W14 [get_ports {B[2]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {B[2]}]
set_property PACKAGE_PIN W13 [get_ports {B[3]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {B[3]}]

## Switches for Mode Selection [1:0]
set_property PACKAGE_PIN T1 [get_ports {Mode[0]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {Mode[0]}]
set_property PACKAGE_PIN R2 [get_ports {Mode[1]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {Mode[1]}]

## LEDs for 8-bit Output Y [7:0]
set_property PACKAGE_PIN U16 [get_ports {Y[0]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {Y[0]}]
set_property PACKAGE_PIN E19 [get_ports {Y[1]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {Y[1]}]
set_property PACKAGE_PIN U19 [get_ports {Y[2]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {Y[2]}]
set_property PACKAGE_PIN V19 [get_ports {Y[3]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {Y[3]}]
set_property PACKAGE_PIN W18 [get_ports {Y[4]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {Y[4]}]
set_property PACKAGE_PIN U15 [get_ports {Y[5]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {Y[5]}]
set_property PACKAGE_PIN U14 [get_ports {Y[6]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {Y[6]}]
set_property PACKAGE_PIN V14 [get_ports {Y[7]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {Y[7]}]
