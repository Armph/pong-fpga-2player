`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/09/2023 11:39:03 AM
// Design Name: 
// Module Name: lfsr4
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


module lfsr4(
    input wire clk,
    input wire reset,
    output wire [3:0] rand_out
    );
    
    reg [3:0] lfsr;
    
    always @(posedge clk) begin
        if(reset) lfsr <= 4'b0000;
        else lfsr <= {lfsr[2:0], lfsr[3]};
    end
    
    assign rand_out = lfsr;
    
endmodule
