`timescale 1ns / 1ps

module counter_10bit (
    input clk,        // FPGA clock (usually 50MHz or 100MHz)
    input reset,      // Active high reset
    output reg [9:0] count  // 10-bit output
);

always @(posedge clk or posedge reset) begin
    if (reset)
        count <= 10'b0000000000;   // Reset to 0
    else
        count <= count + 1;        // Increment every clock
end

endmodule










module counter_10bit_slow (
    input clk,
    input reset,
    output reg [9:0] count
);

reg [25:0] divider;  // Big divider for slowing down

always @(posedge clk or posedge reset) begin
    if (reset) begin
        divider <= 0;
        count <= 0;
    end else begin
        divider <= divider + 1;

        if (divider == 50_000_000) begin  // Adjust based on clock
            divider <= 0;
            count <= count + 1;
        end
    end
end

endmodule









`timescale 1ns / 1ps

module tb_counter;

reg clk = 0;
reg reset = 1;
wire [9:0] count;

counter_10bit uut (
    .clk(clk),
    .reset(reset),
    .count(count)
);

// Clock generation
always #5 clk = ~clk;

initial begin
    $display("Starting Simulation...");
    
    // Apply reset
    #10 reset = 0;

    // Print values for 20 cycles
    repeat (20) begin
        @(posedge clk);
        $display("Time=%0t | reset=%b | count=%d", $time, reset, count);
    end

    $display("Simulation Finished");
    $finish;
end

endmodule















// xdc file is 
## 🔥 CLOCK (100 MHz)
set_property PACKAGE_PIN W5 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk]


## 🔘 RESET BUTTON (BTNC)
set_property PACKAGE_PIN U18 [get_ports reset]
set_property IOSTANDARD LVCMOS33 [get_ports reset]


## 💡 LED OUTPUT (count[9:0])
set_property PACKAGE_PIN U16 [get_ports {count[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {count[0]}]

set_property PACKAGE_PIN E19 [get_ports {count[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {count[1]}]

set_property PACKAGE_PIN U19 [get_ports {count[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {count[2]}]

set_property PACKAGE_PIN V19 [get_ports {count[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {count[3]}]

set_property PACKAGE_PIN W18 [get_ports {count[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {count[4]}]

set_property PACKAGE_PIN U15 [get_ports {count[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {count[5]}]

set_property PACKAGE_PIN U14 [get_ports {count[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {count[6]}]

set_property PACKAGE_PIN V14 [get_ports {count[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {count[7]}]

set_property PACKAGE_PIN V13 [get_ports {count[8]}]
set_property IOSTANDARD LVCMOS33 [get_ports {count[8]}]

set_property PACKAGE_PIN V3 [get_ports {count[9]}]
set_property IOSTANDARD LVCMOS33 [get_ports {count[9]}]
