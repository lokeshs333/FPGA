`timescale 1ns/1ps

//////////////////////////////////////////////////
// TOP MODULE
//////////////////////////////////////////////////
module gcd_top (
    input clk,
    input reset,
    input start,
    input [7:0] data_in,
    output [7:0] gcd_out,
    output done,
    output error_led
);

wire ldA, ldB, sel_sub, sel_in;
wire gt, lt, eq;
wire [7:0] Aout, Bout, Bus;
wire error;

//////////////////////
// 1 Hz CLOCK DIVIDER
//////////////////////
reg [26:0] count;
reg clk_1hz;

// ⚠️ For FPGA use 100_000_000
// ⚠️ For simulation use small value like 1000

parameter DIV = 1000;  // change to 100_000_000 on FPGA

always @(posedge clk or posedge reset) begin
    if (reset) begin
        count <= 0;
        clk_1hz <= 0;
    end else if (count == DIV - 1) begin
        count <= 0;
        clk_1hz <= ~clk_1hz;
    end else begin
        count <= count + 1;
    end
end

//////////////////////
// REGISTERS
//////////////////////
pipo A_reg (Aout, Bus, ldA, clk);
pipo B_reg (Bout, Bus, ldB, clk);

//////////////////////
// SUBTRACTION
//////////////////////
wire [7:0] subAB = Aout - Bout;
wire [7:0] subBA = Bout - Aout;

//////////////////////
// BUS CONTROL
//////////////////////
assign Bus = (sel_in == 0) ? data_in :
             (sel_sub == 0 ? subAB : subBA);

//////////////////////
// COMPARATOR
//////////////////////
compare COMP (lt, gt, eq, Aout, Bout);

//////////////////////
// CONTROLLER
//////////////////////
controller CTRL (
    ldA, ldB, sel_sub, sel_in,
    done, error,
    clk, reset, start,
    lt, gt, eq,
    Aout, Bout
);

//////////////////////
// OUTPUT
//////////////////////
assign gcd_out = Aout;
assign error_led = error & clk_1hz;  // blinking

endmodule


//////////////////////////////////////////////////
// PIPO
//////////////////////////////////////////////////
module pipo (dataout, datain, load, clk);
input [7:0] datain;
input load, clk;
output reg [7:0] dataout;

always @(posedge clk)
    if (load) dataout <= datain;

endmodule


//////////////////////////////////////////////////
// COMPARATOR
//////////////////////////////////////////////////
module compare (lt, gt, eq, data1, data2);
input [7:0] data1, data2;
output lt, gt, eq;

assign lt = (data1 < data2);
assign gt = (data1 > data2);
assign eq = (data1 == data2);

endmodule


//////////////////////////////////////////////////
// CONTROLLER (FINAL FSM)
//////////////////////////////////////////////////
module controller (
    ldA, ldB, sel_sub, sel_in,
    done, error,
    clk, reset, start,
    lt, gt, eq,
    A, B
);

input clk, reset, start;
input lt, gt, eq;
input [7:0] A, B;

output reg ldA, ldB, sel_sub, sel_in;
output reg done, error;

reg [2:0] state;

parameter S0=0, S1=1, S2=2, S3=3, S4=4, S5=5, S6=6, S7=7;

always @(posedge clk or posedge reset) begin
    if (reset) state <= S0;
    else begin
        case(state)
            S0: if (start) state <= S1;
            S1: state <= S2;
            S2: state <= S3;
            S3: begin
                if (A==0 || B==0) state <= S7;
                else if (eq) state <= S6;
                else if (gt) state <= S4;
                else state <= S5;
            end
            S4: state <= S3;
            S5: state <= S3;
            S6: state <= S6;
            S7: state <= S7;
        endcase
    end
end

always @(*) begin
    ldA=0; ldB=0;
    sel_sub=0;
    sel_in=0;
    done=0; error=0;

    case(state)

        // LOAD A
        S1: begin ldA=1; sel_in=0; end

        // LOAD B
        S2: begin ldB=1; sel_in=0; end

        // A = A - B
        S4: begin ldA=1; sel_sub=0; sel_in=1; end

        // B = B - A
        S5: begin ldB=1; sel_sub=1; sel_in=1; end

        // DONE
        S6: done=1;

        // ERROR
        S7: error=1;

    endcase
end

endmodule


//////////////////////////////////////////////////
// TESTBENCH
//////////////////////////////////////////////////
module tb;

reg clk, reset, start;
reg [7:0] data_in;

wire [7:0] gcd_out;
wire done;
wire error_led;

gcd_top uut(clk, reset, start, data_in, gcd_out, done, error_led);

always #5 clk = ~clk;

initial begin
    $dumpfile("gcd.vcd");
    $dumpvars(0, tb);

    clk=0; reset=1; start=0; data_in=0;

    #20 reset=0;

    $display("TEST: A=26, B=65");

    // LOAD A
    @(posedge clk);
    data_in=26;
    start=1;

    @(posedge clk);
    start=0;

    // HOLD A
    @(posedge clk);

    // LOAD B
    data_in=65;

    @(posedge clk);

    wait(done);

    $display("✅ GCD = %d", gcd_out);

    #20 $finish;
end

endmodule

module top_basys3 (
    input clk,              // 100 MHz clock
    input btnC,             // reset
    input btnU,             // start
    input [7:0] sw,         // switches (data input)

    output [7:0] led,       // GCD output
    output led_done,        // done indicator
    output led_error        // error indicator
);

wire [7:0] gcd_out;
wire done, error_led;

gcd_top uut (
    .clk(clk),
    .reset(btnC),
    .start(btnU),
    .data_in(sw),
    .gcd_out(gcd_out),
    .done(done),
    .error_led(error_led)
);

// OUTPUT MAPPING
assign led = gcd_out;
assign led_done = done;
assign led_error = error_led;

endmodule






// xcd file
## CLOCK
set_property PACKAGE_PIN W5 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]

## SWITCHES
set_property PACKAGE_PIN V17 [get_ports {sw[0]}]
set_property PACKAGE_PIN V16 [get_ports {sw[1]}]
set_property PACKAGE_PIN W16 [get_ports {sw[2]}]
set_property PACKAGE_PIN W17 [get_ports {sw[3]}]
set_property PACKAGE_PIN W15 [get_ports {sw[4]}]
set_property PACKAGE_PIN V15 [get_ports {sw[5]}]
set_property PACKAGE_PIN W14 [get_ports {sw[6]}]
set_property PACKAGE_PIN W13 [get_ports {sw[7]}]

## BUTTONS
set_property PACKAGE_PIN U18 [get_ports btnC]   # reset
set_property PACKAGE_PIN T18 [get_ports btnU]   # start

## LED OUTPUT (GCD)
set_property PACKAGE_PIN U16 [get_ports {led[0]}]
set_property PACKAGE_PIN E19 [get_ports {led[1]}]
set_property PACKAGE_PIN U19 [get_ports {led[2]}]
set_property PACKAGE_PIN V19 [get_ports {led[3]}]
set_property PACKAGE_PIN W18 [get_ports {led[4]}]
set_property PACKAGE_PIN U15 [get_ports {led[5]}]
set_property PACKAGE_PIN U14 [get_ports {led[6]}]
set_property PACKAGE_PIN V14 [get_ports {led[7]}]

## STATUS LEDs
set_property PACKAGE_PIN V13 [get_ports led_done]
set_property PACKAGE_PIN V3  [get_ports led_error]




