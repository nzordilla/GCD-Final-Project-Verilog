`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/01/2025 08:51:57 PM
// Design Name: 
// Module Name: GCD_testbench
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module GCD_tb();
    reg clk=0,start=0,rst=0;
    always#5 clk=~clk;  // Create clock with period=10
    always#10 start=~start; // no matter how often start is pressed, state disables new inputs
    reg [7:0]a=0,b=0;
    wire [7:0]gcd;
    wire done;
    GCD dut(.clk(clk),.start(start),.reset(rst),.inA(a),.inB(b),.GCD(gcd),.done(done));
    initial begin
            rst <= 1;
        #1  rst <= 0;
        a <= 15; b <= 27;   // first test case
        
        @(posedge done);
        a <= 200; b <= 25;  // second test case
        #20 $display ("gcd1=%0d",gcd);
        
        @(posedge done);
        a <= 123; b <= 123; // third test case
        #20 $display ("gcd2=%0d",gcd);
        
        @(posedge done);
        a <= 1; b <= 7;     // fourth test case
        #20 $display ("gcd3=%0d",gcd);
        
        @(posedge done);
        a <= 0; b <= 3;     // fifth test case
        #20 $display ("gcd4=%0d",gcd);
        
        @(posedge done);
        #20 $display ("gcd5=%0d",gcd);
        
        $display ("Hello world! The current time is (%0d ns)", $time);
        $finish;                // quit the simulation
    end
endmodule
