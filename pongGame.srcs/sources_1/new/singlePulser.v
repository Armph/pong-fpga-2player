`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/09/2023 08:12:34 PM
// Design Name: 
// Module Name: singlePulser
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


module singlePulser(
    input clk,
    input btn_in,
    output reg btn_out
    );
    
    reg state;

    initial state = 0;
    
    always@(posedge clk)
        begin
            btn_out = 0;
            case({btn_in, state})
                2'b01: state = 0;
                2'b10: 
                    begin
                        state = 1;
                        btn_out = 1;
                    end
            endcase
        end
endmodule
