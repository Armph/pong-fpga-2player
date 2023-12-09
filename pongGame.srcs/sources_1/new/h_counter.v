`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/09/2023 02:54:59 PM
// Design Name: 
// Module Name: h_counter
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


module h_counter(
    input wire clk,
    input wire HMAX,
    output reg v_enable = 0,
    output reg [15:0] h_count = 0
    );
    
    always @(posedge clk)
        begin
            if (h_count < HMAX + 1) begin
                h_count <= h_count + 1;
                v_enable <= 0;
            end
            else begin
                h_count <= 0;
                v_enable <= 1;
            end 
        end
endmodule
