`timescale 1ns / 1ps

// Half Adder Module
module half_adder(
    input a, b,
    output sum, carry
);
    assign sum = a ^ b;
    assign carry = a & b;
endmodule

// Full Adder Structural Module using two Half Adders
module full_adder_structural(
    input A, B, Cin,
    output Sum, Cout
);
    wire s1, c1, c2;

    // First Half Adder (HA1)
    half_adder HA1 (.a(A), .b(B), .sum(s1), .carry(c1));
    
    // Second Half Adder (HA2)
    half_adder HA2 (.a(s1), .b(Cin), .sum(Sum), .carry(c2));

    // Final Carry Out using an OR gate
    assign Cout = c1 | c2;

endmodule









# TestBench
`timescale 1ns / 1ps

module tb_full_adder;
    reg A, B, Cin;
    wire Sum, Cout;

    // Instantiate the Unit Under Test (UUT)
    full_adder_structural uut (
        .A(A),
        .B(B),
        .Cin(Cin),
        .Sum(Sum),
        .Cout(Cout)
    );

    initial begin
        // Print header for clarity
        $display("Time  | A B Cin | Sum Cout");
        $display("--------------------------");
        
        // Monitor changes in inputs and outputs
        $monitor("%0t ns | %b %b %b   |  %b    %b", $time, A, B, Cin, Sum, Cout);

        // Apply all 8 input combinations with 10ns delays
        A=0; B=0; Cin=0; #10;
        A=0; B=0; Cin=1; #10;
        A=0; B=1; Cin=0; #10;
        A=0; B=1; Cin=1; #10;
        A=1; B=0; Cin=0; #10;
        A=1; B=0; Cin=1; #10;
        A=1; B=1; Cin=0; #10;
        A=1; B=1; Cin=1; #10;

        $finish;
    end
endmodule










#XDC

## FPGA LABORATORY – EXPERIMENT-1: Full Adder
## Target Board: Basys-3

# Switches (Inputs: A, B, Cin)
# Mapping A to Switch 0, B to Switch 1, and Cin to Switch 2
set_property PACKAGE_PIN V17 [get_ports A]					
	set_property IOSTANDARD LVCMOS33 [get_ports A]
set_property PACKAGE_PIN V16 [get_ports B]					
	set_property IOSTANDARD LVCMOS33 [get_ports B]
set_property PACKAGE_PIN W16 [get_ports Cin]					
	set_property IOSTANDARD LVCMOS33 [get_ports Cin]

# LEDs (Outputs: Sum, Cout)
# Mapping Sum to LED 0 and Cout to LED 1
set_property PACKAGE_PIN U16 [get_ports Sum]					
	set_property IOSTANDARD LVCMOS33 [get_ports Sum]
set_property PACKAGE_PIN E19 [get_ports Cout]					
	set_property IOSTANDARD LVCMOS33 [get_ports Cout]
