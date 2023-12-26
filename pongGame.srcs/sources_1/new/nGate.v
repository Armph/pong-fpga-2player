`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/11/2023 10:00:12 AM
// Design Name: 
// Module Name: nGate
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


module nGate(
    input clk,
    output reg clkDiv
    );
    
    initial
    begin
        clkDiv = 0;
    end
    
    always @(posedge clk)
    begin
        clkDiv = ~clkDiv;
    end
    
endmodule
