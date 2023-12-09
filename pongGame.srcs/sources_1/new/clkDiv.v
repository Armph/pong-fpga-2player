`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/09/2023 03:41:46 PM
// Design Name: 
// Module Name: clkDiv
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


module clkDiv(
    input wire clk,
    input wire reset,
    output wire tick
    );
    
    reg [1:0] r_25MHz;
    
    always @(posedge clk or posedge reset)
        begin
            if (reset) r_25MHz <= 0;
            else r_25MHz <= r_25MHz + 1;
        end
        
    assign tick = (r_25MHz == 0) ? 1 : 0; // assert tick 1/4 of the time
endmodule
