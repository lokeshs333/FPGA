`timescale 1ns / 1ps
module bin_to_digit_converter (
    input wire [9:0] bin, // 10-bit binary input
    output reg [3:0] d0, // Ones place
    output reg [3:0] d1,  // Tens place
    output reg [3:0] d2,
    output reg [3:0] d3 
);
    always @(bin) begin
        d0 = bin % 10;
        d1 = (bin / 10) % 10;
        d2 = (bin / 100) % 10;
        d3 = (bin / 1000) % 10;
    end
endmodule


`timescale 1ns / 1ps
module clk_divider (
    input clk,    // 100 MHz input clock
    input rst,    // Reset
    output reg slow_clk// Slower clock output (1 Hz in this case)
);
    reg [25:0] counter; // 27-bit counter (2^26 = 67M > 50M)
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            counter <= 0;
            slow_clk <= 0;end 
            else begin
                counter <= counter + 1;
                if (counter == 49_999_999) begin // Toggle at 50M counts (1 Hz)
                    slow_clk <= ~slow_clk;
                    counter <= 0;
                end
        end
    end
endmodule



`timescale 1ns / 1ps
module counter_10bit (
    input slow_clk,  // Slow clock input
    input rst,       // Reset
    output reg [9:0] count // 10-bit count output
);
    always @(posedge slow_clk or posedge rst) begin
        if (rst)
            count <= 0;
        else if (count==10'd1021)
            count<=0;
        else
            count <= count + 1;
    end
endmodule




`timescale 1ns / 1ps
module seven_seg_decoder(
    input wire [3:0] bin,    // 4-bit binary input
    output reg [6:0] seg     // 7-segment display output
);



always @(*) begin
    case (bin)
        4'h0: seg = 7'b1000000; // 0
        4'h1: seg = 7'b1111001; // 1
        4'h2: seg = 7'b0100100; // 2
        4'h3: seg = 7'b0110000; // 3
        4'h4: seg = 7'b0011001; // 4
        4'h5: seg = 7'b0010010; // 5
        4'h6: seg = 7'b0000010; // 6
        4'h7: seg = 7'b1111000; // 7
        4'h8: seg = 7'b0000000; // 8
        4'h9: seg = 7'b0010000; // 9
        default: seg = 7'b1111111; // blank (all OFF)
    endcase
end

endmodule





`timescale 1ns / 1ps
module tdm_digit_select (
    input wire clk,        // 100 MHz clock
    input wire rst,
    input wire [3:0] d0, // Ones place BCD digit
    input wire [3:0] d1, // Tens place BCD digit
    input wire [3:0] d2,
    input wire [3:0] d3,
    output reg [3:0] digit,  // Seven-segment display output
    output reg [3:0] an    // Anode control for display selection
);
    reg [1:0] digit_select; // Refresh counter
    
    reg [16:0] digit_timer;     // counter for digit refresh 
    
     always @(posedge clk or posedge rst) begin
        if(rst) begin
            digit_timer <= 0; 
        end
        else                                        // 1ms x 4 displays = 4ms refresh period
            if(digit_timer == 49_999) begin         // The period of 100MHz clock is 10ns (1/100,000,000 seconds)
                digit_timer <= 0;                   // 10ns x 100,000 = 1ms
                
            end
            else
                digit_timer <=  digit_timer + 1;
    end                
    
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            digit_select <= 0;
        end
        else if(digit_timer == 49_999) begin        
             digit_select <=  digit_select + 1;
            
            end
        end
    
    always @(digit_select) begin
        case (digit_select) // Rotate through displays
            2'b00: begin
                an <= 4'b1110; // Enable ones place
                digit <= d0;
            end
            2'b01: begin
                an <= 4'b1101; // Enable tens place
                digit <= d1;
            end
            2'b10: begin
                an <= 4'b1011; // Enable hundreds place
                digit <= d2;
            end
            2'b11: begin
                an <= 4'b0111; // Enable thousands place
                digit <= d3;
            end
            default: begin
                an <= 4'b1111; // Turn off all displays
            end
        endcase
    end

endmodule




`timescale 1ns / 1ps
module top_module(
    input wire clk,          // 100 MHz clock
    input wire rst,          // Reset button
    output [6:0] seg,        // 7-segment display output
    output [3:0] an        // Enable signals for multiplexing   
);
    wire clk_slow;
    wire [9:0] count;
    wire [3:0] d0,d1,d2, d3;   
    wire [3:0] digit;

    // Generate 1Hz clock for counting
    clk_divider clk_div1 (.clk(clk),.rst(rst),.slow_clk(clk_slow));

    // 10-bit Counter
    counter_10bit counter1 (.slow_clk(clk_slow),.rst(rst),.count(count));

    // Convert Binary to BCD
    bin_to_digit_converter converter1 (.bin(count),.d0(d0),.d1(d1),.d2(d2),.d3(d3));

    // Multiplexing Display for 3 Digits
    tdm_digit_select (.clk(clk),.rst(rst),.d0(d0),.d1(d1),.d2(d2),.d3(d3),.digit(digit),.an(an));                          
    
    
    // Instantiate the seven-segment decoder
    seven_seg_decoder decoder (.bin(digit),.seg(seg));

endmodule










// xdc file
# Clock signal
set_property PACKAGE_PIN W5 [get_ports clk]							
	set_property IOSTANDARD LVCMOS33 [get_ports clk]
	

# Reset Button
set_property PACKAGE_PIN W19 [get_ports rst]
    set_property IOSTANDARD LVCMOS33 [get_ports rst]


#7 segment display
set_property PACKAGE_PIN W7 [get_ports {seg[6]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {seg[6]}]
set_property PACKAGE_PIN W6 [get_ports {seg[5]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {seg[5]}]
set_property PACKAGE_PIN U8 [get_ports {seg[4]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {seg[4]}]
set_property PACKAGE_PIN V8 [get_ports {seg[3]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {seg[3]}]
set_property PACKAGE_PIN U5 [get_ports {seg[2]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {seg[2]}]
set_property PACKAGE_PIN V5 [get_ports {seg[1]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {seg[1]}]
set_property PACKAGE_PIN U7 [get_ports {seg[0]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {seg[0]}]
	
set_property PACKAGE_PIN U2 [get_ports {an[0]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {an[0]}]
set_property PACKAGE_PIN U4 [get_ports {an[1]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {an[1]}]
set_property PACKAGE_PIN V4 [get_ports {an[2]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {an[2]}]
set_property PACKAGE_PIN W4 [get_ports {an[3]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {an[3]}]	
