`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/10/2023 10:57:27 AM
// Design Name: 
// Module Name: quad7seg
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


module quad7seg(
    input clk,
    input [12:0] quad,
    output an0,
    output an1,
    output an2,
    output an3,
    output [6:0] seg
    );
    
    reg [1:0] ns;
    reg [1:0] ps;
    reg [3:0] dispEn;
    
    reg [3:0] hex;
    
    hexTo7seg h27s(.hex(hex), .seg(seg));
    
    assign {an3, an2, an1, an0} = ~dispEn;
    assign {num0, num1, num2, num3} = quad;
    
    always @(posedge clk)
    begin
        ps = ns;
    end
    
    always @(ps)
    begin
        ns = ps + 1;
    end
    
    always @(ps)
    begin 
        case(ps)
            2'b00: dispEn = 4'b0001;
            2'b01: dispEn = 4'b0010;
            2'b10: dispEn = 4'b0100;
            2'b11: dispEn = 4'b1000;
        endcase
    end
    
    always @(ps)
    begin
        case(ps)
            2'b00: hex = num0;
            2'b01: hex = num1;
            2'b10: hex = num2;
            2'b11: hex = num3;       
        endcase
    end 
    
    
endmodule
