`timescale 1ns / 1ps

module majority_gate(
    input A,
    input B,
    input C,
    output Y
    );

    // Implementation using logical operators
    assign Y = (A & B) | (B & C) | (A & C);

endmodule









#TestBench
`timescale 1ns / 1ps

module tb_majority_gate;
    reg A, B, C;
    wire Y;

    majority_gate uut (.A(A), .B(B), .C(C), .Y(Y));

    initial begin
        $display("A B C | Y");
        $monitor("%b %b %b | %b", A, B, C, Y);

        // Test all 8 combinations
        {A, B, C} = 3'b000; #10;
        {A, B, C} = 3'b001; #10;
        {A, B, C} = 3'b010; #10;
        {A, B, C} = 3'b011; #10;
        {A, B, C} = 3'b100; #10;
        {A, B, C} = 3'b101; #10;
        {A, B, C} = 3'b110; #10;
        {A, B, C} = 3'b111; #10;
        $finish;
    end
endmodul









#XDC File
# Inputs (Switches 0, 1, 2)
set_property PACKAGE_PIN V17 [get_ports A]					
	set_property IOSTANDARD LVCMOS33 [get_ports A]
set_property PACKAGE_PIN V16 [get_ports B]					
	set_property IOSTANDARD LVCMOS33 [get_ports B]
set_property PACKAGE_PIN W16 [get_ports C]					
	set_property IOSTANDARD LVCMOS33 [get_ports C]

# Output (LED 0)
set_property PACKAGE_PIN U16 [get_ports Y]					
	set_property IOSTANDARD LVCMOS33 [get_ports Y]
