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
    input p1_score,
    input p2_score,
    input reset,
    output wire [12:0] quad
    );
    
    reg [3:0] p1_dig0, p1_dig1, p2_dig0, p2_dig1;
    
    assign quad = {p1_dig1, p1_dig0, p2_dig1, p2_dig0};
    
    always @(posedge p1_score) begin
        if (p1_dig0 == 9) p1_dig1 <= (p1_dig1+1)%0;
        p1_dig0 <= (p1_dig0+1)%10;
    end
    
    always @(posedge p2_score) begin
        if (p2_dig0 == 9) p2_dig1 <= (p2_dig1+1)%0;
        p2_dig0 <= (p2_dig0+1)%10;
    end
    
    always @(posedge reset) begin
        p1_dig0 <= 0;
        p1_dig1 <= 0;
        p2_dig0 <= 0;
        p2_dig1 <= 0;
    end
    
endmodule
