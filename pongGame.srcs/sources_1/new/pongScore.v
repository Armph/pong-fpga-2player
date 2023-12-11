`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/10/2023 10:26:13 AM
// Design Name: 
// Module Name: pongScore
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


module pongScore(
    input clk,
    input p1_score,
    input p2_score,
    input reset,
    output wire [12:0] quad
    );
    
    reg [3:0] p1_dig0, p1_dig1, p2_dig0, p2_dig1;
    
    assign quad = {p1_dig1, p1_dig0, p2_dig1, p2_dig0};
    
    always @* begin
        if (p1_score) begin
            if (p1_dig0 === 4'b1001) p1_dig1 = (p1_dig1+1)%10;
            p1_dig0 = p1_dig0+1;
        end
        else if (p2_score) begin
            if (p2_dig0 === 4'b1001) p2_dig1 = (p2_dig1+1)%10;
            p2_dig0 = (p2_dig0+1);
        end
    end
    
    always @(posedge clk) begin
        if (reset) begin
            p1_dig0 <= 4'b0000;
            p1_dig1 <= 4'b0000;
            p2_dig0 <= 4'b0000;
            p2_dig1 <= 4'b0000;
        end
    end
    
endmodule
