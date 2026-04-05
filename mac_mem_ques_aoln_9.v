`timescale 1ns / 1ps
module adder (
    input [7:0] a,         // 12-bit input A
    input [7:0] b,         // 12-bit input B
    output [7:0] sum       // 12-bit sum output
);
    // Perform addition  producing a 12-bit sum
    assign sum = a + b;

endmodule



`timescale 1ns / 1ps
module addr_generator (
    input clk,            // Clock signal
    input reset,          // Synchronous reset signal
    input addr_inc,         // Enable signal
    output reg [3:0] addr // 4-bit counter output
);
    // Always block triggered on the rising edge of the clock
    always @(posedge clk, posedge reset) begin
        if (reset)
            addr <= 4'b0000;  // Reset the counter to 0
        else if (addr_inc)
            addr <= addr + 1; // Increment the counter when enabled
    end
endmodule




`timescale 1ns / 1ps
module comparator (
    input [3:0] a,       // 4-bit input
    output reg result    // Output: 1 if a == 9, else 0
);
    always @(a) begin
        if (a == 4'b1001) // 4'b1001 is the binary representation of 9
            result = 1;
        else
            result = 0;
    end
endmodule




`timescale 1ns / 1ps

module controller(
    input clk,           // Clock signal
    input rst,           // Synchronous reset
    input go,            // Start signal
    input cmp,           // Comparator output
    output reg ld_m,     // Load memory register
    output reg ld_acc,   // Load accumulator register
    output reg ld_out,   // Load output register
    output reg addr_inc, // Address increment signal
    output reg done,     // Done signal
    output reg rw,       // Read/Write control
    output reg [2:0] ps  // Present state output (for debug/observation)
);

reg [2:0] ns;
parameter s0=3'b000;
parameter s1=3'b001;
parameter s2=3'b010;
parameter s3=3'b011;
parameter s4=3'b100;
parameter s5=3'b101;


// modelling the state register

// 1. State Register (Sequential)
    always @(posedge clk or posedge rst) begin
        if (rst == 1'b1)
            ps <= s0;
        else
            ps <= ns;
    end

    // 2. Next State Logic (Combinational)
    always @(*) begin
        case (ps)
            s0: begin
                if (go == 1'b0) ns = s0;
                else            ns = s1;
            end
            
            s1: ns = s2;
            s2: ns = s3;
            s3: ns = s4;
            
            s4: begin
                if (cmp == 1'b1) ns = s5;
                else             ns = s1;
            end
            
            default: ns = s0;
        endcase
    end

// 3. Output Logic (Combinational)
    always @(*) begin
        // Default values to prevent latches
        ld_m     = 1'b0;
        ld_acc   = 1'b0;
        ld_out   = 1'b0;
        done     = 1'b0;
        addr_inc = 1'b0;
        rw       = 1'b1; // Default to Read mode instead of 'x' for safety

        case (ps)
            s0: begin
                rw = 1'bx;
            end
            
            s1: begin
                addr_inc = 1'b1;
                rw       = 1'b1;
            end
            
            s2: begin
                ld_m = 1'b1;
                rw   = 1'bx;
            end
            
            s3: begin
                ld_acc = 1'b1;
                rw     = 1'bx;
            end
            
            s4: begin
                rw = 1'bx;
            end
            
            s5: begin
                ld_out = 1'b1;
                done   = 1'b1;
                rw     = 1'bx;
            end
            
            default: ; // Use default values defined above
        endcase
    end

endmodule


// 12
// 34
// 56
// 78
// 9A
// BC
// DE
// F0
// AA
// 55
// 11
// 22
// 33
// 44
// 66
// 77






`timescale 1ns/1ps
module datapath(clk,rst,data_in,ld_m,ld_acc,ld_out,rw,addr_inc,cmp,out,tacc,addr);
input clk,rst,ld_m,ld_acc,ld_out,rw,addr_inc;
output cmp;
output [7:0] out;
output [7:0] tacc;
wire [7:0] tmout;
wire [7:0] tadd,tmin;
output [3:0] addr;
input [7:0] data_in;

adder a1(tmout,tacc,tadd);
addr_generator ag1(clk,rst,addr_inc,addr);
comparator comp1(addr,cmp);  
register_8bit rm(clk,rst,tmin,ld_m,tmout);
register_8bit racc(clk,rst,tadd,ld_acc,tacc);
register_8bit rout(clk,rst,tacc,ld_out,out);
memory mem1(clk,rw,addr,data_in,tmin);
endmodule








module memory (
    input wire clk,          // Clock signal
    input wire rw,           // Read/Write control (1 = Read, 0 = Write)
    input wire [3:0] addr,   // 4-bit address (16 locations)
    input wire [7:0] data_in,// 8-bit input data (for write)
    output reg [7:0] data_out // 8-bit output data (for read)
);

    reg [7:0] mem [0:15]; // 16x8 memory array

    // Load memory with 10 predefined values
 
   
    // Load memory from a file at startup
    initial begin
       $readmemh("data.mem", mem); // Load hexadecimal data from file
    end
        // Initialize memory with values directly in Verilog
   /*
    initial begin
        mem[0] = 8'h0A; // 10
        mem[1] = 8'h14; // 20
        mem[2] = 8'h1E; // 30
        mem[3] = 8'h28; // 40
        mem[4] = 8'h32; // 50
        mem[5] = 8'h3C; // 60
        mem[6] = 8'h46; // 70
        mem[7] = 8'h50; // 80
        mem[8] = 8'h5A; // 90
        mem[9] = 8'h64; // 100
    end
    */
     
    always @(posedge clk) begin
        if (rw) 
            data_out <= mem[addr]; // Read operation (rw = 1)
        else if (!rw)
            mem[addr] <= data_in;  // Write operation (rw = 0)
    end

endmodule





`timescale 1ns / 1ps

module register_8bit(clk,rst,data_in,ld,out);
input clk,rst;
input [7:0] data_in;
input ld;
output reg [7:0] out;
always @(posedge clk or posedge rst)
begin
if (rst==1'b1)
out<=1'b0;
else if (ld==1'b1)
out<=data_in;
end
endmodule







`timescale 1ns/1ps
module top_module(clk,rst,go,data_in,out,done,ps,rw,ld_acc,tacc,addr);
input clk,rst,go;
input [7:0] data_in;
output [7:0] out;
output done,rw;
wire ld_m,ld_out; // output from controller to datapath
wire add_inc,cmp;
output [3:0] addr;
output [2:0] ps;
output ld_acc;
output [7:0] tacc;
// instantiate datapath and controller

controller c1(clk,rst,go,cmp,ld_m,ld_acc,ld_out,addr_inc,done,rw,ps);
datapath d1(clk,rst,data_in,ld_m,ld_acc,ld_out,rw,addr_inc,cmp,out,tacc,addr);

endmodule 




