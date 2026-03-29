`timescale 1ns/1ps

// ==============================
// 🔐 LOCK FSM MODULE
// ==============================
module lock_fsm(
    input clk, reset,
    input S1, S2, S3,
    output reg unlocked,
    output reg error
);

    typedef enum reg [2:0] {
        IDLE,
        WAIT_S1,
        WAIT_S2,
        UNLOCKED,
        ERROR
    } state_t;

    state_t current, next;

    // State register
    always @(posedge clk or posedge reset) begin
        if (reset)
            current <= IDLE;
        else
            current <= next;
    end

    // Next state logic
    always @(*) begin
        case (current)
            IDLE:
                if (S3) next = WAIT_S1;
                else if (S1 || S2) next = ERROR;
                else next = IDLE;

            WAIT_S1:
                if (S1) next = WAIT_S2;
                else if (S2 || S3) next = ERROR;
                else next = WAIT_S1;

            WAIT_S2:
                if (S2) next = UNLOCKED;
                else if (S1 || S3) next = ERROR;
                else next = WAIT_S2;

            UNLOCKED:
                next = UNLOCKED;

            ERROR:
                next = ERROR;

            default:
                next = IDLE;
        endcase
    end

    // Output logic
    always @(*) begin
        unlocked = (current == UNLOCKED);
        error    = (current == ERROR);
    end

endmodule



// ==============================
// ⚙️ ALU MODULE
// ==============================
module alu(
    input [3:0] a, b,
    input [1:0] m,
    input enable,
    output reg [7:0] y,
    output reg invalid
);

    always @(*) begin
        if (!enable) begin
            y = 0;
            invalid = 0;
        end
        else begin
            case (m)
                2'b01: begin
                    y = a + b;
                    invalid = 0;
                end
                2'b10: begin
                    y = a * b;
                    invalid = 0;
                end
                default: begin
                    y = 0;
                    invalid = 1;
                end
            endcase
        end
    end

endmodule



// ==============================
// 💡 BLINK MODULE
// ==============================
module blink(
    input clk,
    input invalid,
    output reg led
);

    reg [25:0] counter = 0;

    always @(posedge clk) begin
        if (invalid) begin
            counter <= counter + 1;

            if (counter == 50_000_000) begin
                led <= ~led;
                counter <= 0;
            end
        end
        else begin
            led <= 0;
            counter <= 0;
        end
    end

endmodule



// ==============================
// 🔗 TOP MODULE
// ==============================
module top(
    input clk, reset,
    input S1, S2, S3,
    input [3:0] a, b,
    input [1:0] m,
    output [7:0] y,
    output active_led,
    output error_led,
    output invalid_led
);

    wire unlocked, error, invalid;

    // FSM Instance
    lock_fsm fsm(
        .clk(clk),
        .reset(reset),
        .S1(S1),
        .S2(S2),
        .S3(S3),
        .unlocked(unlocked),
        .error(error)
    );

    // ALU Instance
    alu alu_unit(
        .a(a),
        .b(b),
        .m(m),
        .enable(unlocked),
        .y(y),
        .invalid(invalid)
    );

    // Blink Instance
    blink blink_unit(
        .clk(clk),
        .invalid(invalid),
        .led(invalid_led)
    );

    // Outputs
    assign active_led = unlocked;
    assign error_led  = error;

endmodule












`timescale 1ns/1ps

module top_tb;

    reg clk;
    reg reset;
    reg S1, S2, S3;
    reg [3:0] a, b;
    reg [1:0] m;

    wire [7:0] y;
    wire active_led;
    wire error_led;
    wire invalid_led;

    // Instantiate DUT
    top uut (
        .clk(clk),
        .reset(reset),
        .S1(S1), .S2(S2), .S3(S3),
        .a(a), .b(b),
        .m(m),
        .y(y),
        .active_led(active_led),
        .error_led(error_led),
        .invalid_led(invalid_led)
    );

    // Clock generation (10ns period)
    always #5 clk = ~clk;

    // Button press tasks (IMPORTANT: separate tasks)
    task press_S1; begin S1 = 1; #10; S1 = 0; #20; end endtask
    task press_S2; begin S2 = 1; #10; S2 = 0; #20; end endtask
    task press_S3; begin S3 = 1; #10; S3 = 0; #20; end endtask

    initial begin
        // Dump waveform
        $dumpfile("wave.vcd");
        $dumpvars(0, top_tb);

        // Monitor (THIS FIXES YOUR ISSUE 🔥)
        $monitor("T=%0t | S1=%b S2=%b S3=%b | active=%b error=%b invalid=%b | y=%d",
                  $time, S1, S2, S3, active_led, error_led, invalid_led, y);

        // Initial values
        clk = 0;
        reset = 1;
        S1 = 0; S2 = 0; S3 = 0;
        a = 4'd3;
        b = 4'd2;
        m = 2'b00;

        #20;
        reset = 0;

        // -----------------------------
        // ❌ TEST 1: Wrong sequence
        // -----------------------------
        $display("\n--- TEST 1: WRONG SEQUENCE ---");
        press_S1;   // wrong start
        #50;

        // Reset
        reset = 1; #20; reset = 0;

        // -----------------------------
        // ✅ TEST 2: Correct unlock
        // -----------------------------
        $display("\n--- TEST 2: CORRECT SEQUENCE ---");
        press_S3;
        press_S1;
        press_S2;
        #50;

        // -----------------------------
        // ➕ TEST 3: Addition
        // -----------------------------
        $display("\n--- TEST 3: ADDITION ---");
        m = 2'b01;
        #50;

        // -----------------------------
        // ✖ TEST 4: Multiplication
        // -----------------------------
        $display("\n--- TEST 4: MULTIPLICATION ---");
        m = 2'b10;
        #50;

        // -----------------------------
        // ⚠ TEST 5: Invalid Mode
        // -----------------------------
        $display("\n--- TEST 5: INVALID MODE ---");
        m = 2'b11;
        #200;

        // -----------------------------
        // 🔁 TEST 6: Reset
        // -----------------------------
        $display("\n--- TEST 6: RESET ---");
        reset = 1; #20; reset = 0;
        #50;

        $display("\nSimulation Finished");
        $finish;
    end

endmodule











// this is my xcd filr
## ==============================
## 🔥 CLOCK (100 MHz)
## ==============================
set_property PACKAGE_PIN W5 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -add -name sys_clk -period 10.00 [get_ports clk]


## ==============================
## 🔁 RESET (use a switch)
## ==============================
set_property PACKAGE_PIN R2 [get_ports reset]
set_property IOSTANDARD LVCMOS33 [get_ports reset]


## ==============================
## 🎮 INPUT BUTTONS (S1, S2, S3)
## ==============================
# Using push buttons (recommended)
set_property PACKAGE_PIN U18 [get_ports S1]   ## BTN0
set_property PACKAGE_PIN T18 [get_ports S2]   ## BTN1
set_property PACKAGE_PIN W19 [get_ports S3]   ## BTN2

set_property IOSTANDARD LVCMOS33 [get_ports {S1 S2 S3}]


## ==============================
## 🔢 INPUT a[3:0] (switches)
## ==============================
set_property PACKAGE_PIN V17 [get_ports {a[0]}]
set_property PACKAGE_PIN V16 [get_ports {a[1]}]
set_property PACKAGE_PIN W16 [get_ports {a[2]}]
set_property PACKAGE_PIN W17 [get_ports {a[3]}]

set_property IOSTANDARD LVCMOS33 [get_ports a[*]]


## ==============================
## 🔢 INPUT b[3:0] (switches)
## ==============================
set_property PACKAGE_PIN W15 [get_ports {b[0]}]
set_property PACKAGE_PIN V15 [get_ports {b[1]}]
set_property PACKAGE_PIN W14 [get_ports {b[2]}]
set_property PACKAGE_PIN W13 [get_ports {b[3]}]

set_property IOSTANDARD LVCMOS33 [get_ports b[*]]


## ==============================
## ⚙️ MODE m[1:0] (switches)
## ==============================
set_property PACKAGE_PIN V2 [get_ports {m[0]}]
set_property PACKAGE_PIN T3 [get_ports {m[1]}]

set_property IOSTANDARD LVCMOS33 [get_ports m[*]]


## ==============================
## 💡 OUTPUT y[7:0] (LEDs)
## ==============================
set_property PACKAGE_PIN U16 [get_ports {y[0]}]
set_property PACKAGE_PIN E19 [get_ports {y[1]}]
set_property PACKAGE_PIN U19 [get_ports {y[2]}]
set_property PACKAGE_PIN V19 [get_ports {y[3]}]
set_property PACKAGE_PIN W18 [get_ports {y[4]}]
set_property PACKAGE_PIN U15 [get_ports {y[5]}]
set_property PACKAGE_PIN U14 [get_ports {y[6]}]
set_property PACKAGE_PIN V14 [get_ports {y[7]}]

set_property IOSTANDARD LVCMOS33 [get_ports y[*]]


## ==============================
## 💡 STATUS LEDS
## ==============================
set_property PACKAGE_PIN V13 [get_ports active_led]
set_property PACKAGE_PIN V3  [get_ports error_led]
set_property PACKAGE_PIN W3  [get_ports invalid_led]

set_property IOSTANDARD LVCMOS33 [get_ports {active_led error_led invalid_led}]






