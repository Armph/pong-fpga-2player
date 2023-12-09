`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/09/2023 08:22:49 PM
// Design Name: 
// Module Name: btn
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


module btn(
    input clk,
    input btn_in,
    output btn_out
    );
    
    wire debounced_btn;
    wire pulsed_btn;

    debounce deb_inst (
        .clk(clk),
        .btn_in(btn_in),
        .btn_out(debounced_btn)
    );

    singlePulser pulser_inst (
        .clk(clk),
        .btn_in(debounced_btn),
        .btn_out(pulsed_btn)
    );

    assign btn_out = pulsed_btn;
    
endmodule
