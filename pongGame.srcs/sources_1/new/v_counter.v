`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/09/2023 02:55:22 PM
// Design Name: 
// Module Name: v_counter
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


module v_counter(
    input wire clk,
    input wire VMAX,
    input wire v_enable,
    output reg [15:0] v_count = 0
    );
    
    always @(posedge clk)
        begin
            if (v_count < VMAX + 1 && v_enable == 1'b1) v_count <= v_count + 1;
            else v_count <= 0;
        end
endmodule
