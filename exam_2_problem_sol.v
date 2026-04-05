// =======================================================
//                DEBOUNCER MODULE
// =======================================================
// Purpose:
// Removes noise (bouncing) from a mechanical switch.
// Ensures clean, stable button press signal.
//
// Working:
// - First synchronizes input with clock
// - Then checks if input stays stable for a fixed time
// - Only then updates output
// =======================================================

module debouncer (
    input clk,            // System clock
    input noisy_in,       // Raw button input (noisy)
    output reg clean_out  // Debounced stable output
);

    reg [20:0] count;     // Counter for debounce delay
    reg sync;             // Synchronized input

    // Step 1: Synchronize input with clock
    always @(posedge clk)
        sync <= noisy_in;

    // Step 2: Debouncing logic
    always @(posedge clk) begin
        if (sync != clean_out) begin
            // Input changed → start counting
            count <= count + 1;

            // If stable for enough time (~20ms depending on clock)
            if (count == 21'd2_000_000) begin
                clean_out <= sync; // Accept new stable value
                count <= 0;
            end
        end 
        else begin
            // No change → reset counter
            count <= 0;
        end
    end

endmodule



// =======================================================
//              LED BIST SYSTEM MODULE
// =======================================================
// Purpose:
// Implements a simple Built-In Self-Test (BIST) system
// using LEDs with two modes:
//
// Modes:
// 1. MANUAL  → LEDs follow switch input
// 2. COUNTER → LEDs increment automatically every 0.5 sec
//
// Buttons:
// btnC → Reset
// btnL → Switch to MANUAL mode
// btnR → Switch to COUNTER mode
// =======================================================

module led_bist_system (
    input clk,          // 100 MHz clock
    input btnC,         // Reset button
    input btnL,         // Mode select (Manual)
    input btnR,         // Mode select (Counter)
    input [3:0] sw,     // Switch input
    output reg [3:0] led // LED output
);

    // ===================================================
    // FSM STATES
    // ===================================================
    parameter IDLE    = 2'b00,
              MANUAL  = 2'b01,
              COUNTER = 2'b10;

    reg [1:0] state;   // Current state


    // ===================================================
    // COUNTER FOR 0.5 SECOND DELAY
    // ===================================================
    reg [25:0] counter; // Large counter for timing
    reg [3:0] value;    // Value shown on LEDs


    // ===================================================
    // DEBOUNCED BUTTON SIGNALS
    // ===================================================
    wire btnL_db, btnR_db;

    // NOTE: Your debouncer has only 3 ports, but here 4 are used ❗
    // Correct instantiation should be:
    debouncer d1(clk, btnL, btnL_db);
    debouncer d2(clk, btnR, btnR_db);


    // ===================================================
    // EDGE DETECTION (Detect single press pulse)
    // ===================================================
    reg btnL_prev, btnR_prev;

    always @(posedge clk or posedge btnC) begin
        if (btnC) begin
            btnL_prev <= 0;
            btnR_prev <= 0;
        end 
        else begin
            btnL_prev <= btnL_db;
            btnR_prev <= btnR_db;
        end
    end

    // Generate 1-clock pulse when button is pressed
    wire btnL_pulse = btnL_db & ~btnL_prev;
    wire btnR_pulse = btnR_db & ~btnR_prev;


    // ===================================================
    // FSM: MODE SELECTION
    // ===================================================
    always @(posedge clk or posedge btnC) begin
        if (btnC)
            state <= IDLE;   // Reset → go to IDLE
        else begin
            if (btnL_pulse)
                state <= MANUAL;
            else if (btnR_pulse)
                state <= COUNTER;
        end
    end


    // ===================================================
    // COUNTER LOGIC (0.5 SECOND DELAY)
    // ===================================================
    always @(posedge clk or posedge btnC) begin
        if (btnC) begin
            counter <= 0;
            value <= 0;
        end 
        else if (state == COUNTER) begin
            // 100 MHz clock → 50M cycles = 0.5 sec
            if (counter == 50_000_000 - 1) begin
                counter <= 0;
                value <= value + 1;  // Increment LED value
            end 
            else begin
                counter <= counter + 1;
            end
        end 
        else begin
            // Reset counter when not in COUNTER mode
            counter <= 0;
            value <= 0;
        end
    end


    // ===================================================
    // OUTPUT LOGIC
    // ===================================================
    always @(*) begin
        case (state)
            IDLE:    led = 4'b0000; // All LEDs OFF
            MANUAL:  led = sw;      // Show switch value
            COUNTER: led = value;   // Show counter value
            default: led = 4'b0000;
        endcase
    end

endmodule
