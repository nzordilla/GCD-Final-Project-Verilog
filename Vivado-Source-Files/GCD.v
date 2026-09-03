`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/01/2025 08:50:03 PM
// Design Name: 
// Module Name: GCD
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


module GCD(input [7:0]inA,inB, input clk,start,reset, output reg [7:0]GCD, output done); //top module
    reg [7:0]regA,regB;
    wire [7:0]muxA,muxB,muxGCD,subAB;
    wire [1:0]selAB; //selA=selB, //done=selGCD
    wire state,lt,Beq0;
    reg regstate;
    
    assign state=(regstate|~start)&~done; //handles wait run logic
    assign selAB={2{start&~regstate}}|{2{~done}}&{~lt,lt};
    assign done=Beq0; //clears GCD at time 0
    
    sub8 subab(.in1(regA),.in2(regB),.out(subAB));
    mux2bit rega(.in({inA,subAB,regB,regA}),.sel(selAB),.out(muxA));
    mux2bit regb(.in({inB,regB,regA,regB}),.sel(selAB),.out(muxB));
    cmp8 less(.in1(regA),.in2(regB),.L(lt));
    cmp2zero b0(.in(regB),.out(Beq0));
    mux1bit reggcd(.in({regA,GCD}),.sel(done),.out(muxGCD));
    
    always@(posedge clk or posedge reset) begin
        if (reset) begin
            regstate<=1'b0;
            regA<=8'b0;
            regB<=8'b0;
            GCD<=8'b0;
        end else begin
            regstate<=state;
            regA<=muxA;
            regB<=muxB;
            GCD<=muxGCD;
        end
    end
/*    always@(posedge reset) begin
        regstate<=1'b0;
        regA<=8'b0;
        regB<=8'b0;
        GCD<=8'b0;
    end*/
endmodule

module mux2bit(input [31:0]in, input [1:0]sel, output [7:0]out);
    assign out= {8{~sel[1]&~sel[0]}}&in[7:0]|
                {8{~sel[1]&sel[0]}}&in[15:8]|
                {8{sel[1]&~sel[0]}}&in[23:16]|
                {8{sel[1]&sel[0]}}&in[31:24];
endmodule

module mux1bit(input [15:0]in, input sel, output [7:0]out);
    assign out= {8{~sel}}&in[7:0]|
                {8{sel}}&in[15:8];
endmodule

module sub8 #(parameter i=0) (input [7:0]in1,in2, input [8:0]c, output [7:0]out, output cout);
    assign out[i]=in1[i]^(in2[i]^c[0])^c[i];
    assign c[i+1]=in1[i]&(in2[i]^c[0])|c[i]&(in1[i]^(in2[i]^c[0]));
    generate
        if(i==0)
            assign c[0]=1'b1;
            assign cout=c[8];
        if(i+1<8)
            sub8 #(.i(i+1)) subab(.in1(in1),.in2(in2),.c(c),.out(out));
    endgenerate
endmodule

module cmp8(input [7:0]in1,in2, output L,c); //test in1(A)<in2(B)
    assign L=~c;
    sub8 cmp(.in1(in1),.in2(in2),.cout(c));
endmodule

module cmp2zero(input [7:0]in, output reg out);
    integer i;
    always@(*) begin
        out=1'b0;
        for(i=0;i<8;i=i+1)
            out=out|in[i];
        out=~out;
    end
endmodule
