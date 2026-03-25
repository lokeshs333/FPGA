module loadable_updown_counter (
    input clk,              // system clock (100 MHz)
    input reset,            // async reset
    input load,
    input [1:0] m,          // mode
    input [3:0] data_in,
    output reg [3:0] count
);

reg [26:0] clk_count;   // for 1 Hz generation
reg en_1hz;

// 1 Hz enable generation
always @(posedge clk or posedge reset) begin
    if (reset) begin
        clk_count <= 0;
        en_1hz <= 0;
    end else begin
        if (clk_count == 100_000_000 - 1) begin
            clk_count <= 0;
            en_1hz <= 1;
        end 
      else begin
            clk_count <= clk_count + 1;
            en_1hz <= 0;
        end
    end
end

// Counter logic
always @(posedge clk or posedge reset) begin
    if (reset)
        count <= 4'b0000;
    else if (en_1hz) begin
        if (load)
            count <= data_in;
        else begin
            case (m)
                2'b10: count <= count + 1;  // UP
                2'b01: count <= count - 1;  // DOWN
                2'b00: count <= count;      // NO OP
                2'b11: count <= count;      // HOLD
            endcase
        end
    end
end

endmodule









#TestBench
`timescale 1ns/1ps

module tb_loadable_updown_counter;

reg clk;
reg reset;
reg load;
reg [1:0] m;
reg [3:0] data_in;
wire [3:0] count;

// Instantiate DUT
loadable_updown_counter uut (.clk(clk),.reset(reset),.load(load),.m(m),.data_in(data_in),.count(count));

// Clock generation (10ns period → 100 MHz)
always #5 clk = ~clk;

initial begin
    // Initialize
    clk = 0;
    reset = 1;
    load = 0;
    m = 2'b00;
    data_in = 4'b0000;

    // Reset pulse
    #20 reset = 0;

    // -------- LOAD --------
    #20 load = 1;
        data_in = 4'b1010;   // load 10
    #20 load = 0;

    // -------- UP COUNT --------
    m = 2'b10;
    #200;

    // -------- DOWN COUNT --------
    m = 2'b01;
    #200;

    // -------- HOLD --------
    m = 2'b11;
    #100;

    // -------- NO OP --------
    m = 2'b00;
    #100;

    // -------- LOAD AGAIN --------
    load = 1;
    data_in = 4'b0101;
    #20 load = 0;

    // -------- UP AGAIN --------
    m = 2'b10;
    #200;

    $finish;
end

// Monitor values
initial begin
    $monitor("Time=%0t | reset=%b load=%b m=%b data_in=%b count=%b",
              $time, reset, load, m, data_in, count);
end

endmodule









# xdc file
## Clock
set_property PACKAGE_PIN W5 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]

## Reset button
set_property PACKAGE_PIN U18 [get_ports reset]

## Load button
set_property PACKAGE_PIN T18 [get_ports load]

## Mode switches
set_property PACKAGE_PIN V17 [get_ports {m[0]}]
set_property PACKAGE_PIN V16 [get_ports {m[1]}]

## Data input switches
set_property PACKAGE_PIN W16 [get_ports {data_in[0]}]
set_property PACKAGE_PIN W17 [get_ports {data_in[1]}]
set_property PACKAGE_PIN W15 [get_ports {data_in[2]}]
set_property PACKAGE_PIN V15 [get_ports {data_in[3]}]

## LEDs
set_property PACKAGE_PIN U16 [get_ports {count[0]}]
set_property PACKAGE_PIN E19 [get_ports {count[1]}]
set_property PACKAGE_PIN U19 [get_ports {count[2]}]
set_property PACKAGE_PIN V19 [get_ports {count[3]}]
