`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/09/2023 07:33:07 PM
// Design Name: 
// Module Name: main
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


module main(
    input clk,             
	input btnC,            // for reset
	output Hsync, 
	output Vsync,
	output [3:0] vgaRed,    
	output [3:0] vgaBlue,
	output [3:0] vgaGreen
    );
    
    wire [11:0] rgb;
    wire [1:0] reset;
    
	assign rgb = {vgaRed, vgaGreen, vgaBlue};
	btn reset_btn(.clk(clk), .btn_in(btnC), .btn_out(reset));
	
	wire tick;
	wire [9:0] x, y;
	reg [11:0] rgb_reg;    // register for Basys 3 12-bit RGB DAC 
	wire [11:0] rgb_next;
	wire video_on;         // Same signal as in controller

    vga_controller vga_c(.clk(clk), .reset(reset), .hsync(Hsync), .vsync(Vsync),
                         .video_on(video_on), .p_tick(tick), .x(x), .y(y));
    pong p(.clk(clk), .reset(reset), .up(reset), .down(reset),
           .video_on(video_on), .x(x), .y(y), .rgb(rgb_next));
           
    // RGB Buffer
    always @(posedge clk)
        if(tick)
            rgb_reg <= rgb_next;
    
    // Output
    assign rgb = rgb_reg;
     
endmodule
