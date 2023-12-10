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
	input btnU,
	output Hsync, 
	output Vsync,
	output [3:0] vgaRed,    
	output [3:0] vgaBlue,
	output [3:0] vgaGreen
    );
    
    wire [11:0] rgb;
    wire [1:0] reset;
    wire [1:0] start;
    
	assign rgb = {vgaRed, vgaGreen, vgaBlue};
	btn reset_btn(.clk(clk), .btn_in(btnC), .btn_out(reset));
	btn start_btn(.clk(clk), .btn_in(btnU), .btn_out(start));
	
	wire tick;
	wire [9:0] x, y;
	reg [11:0] rgb_reg;    // register for Basys 3 12-bit RGB DAC 
	// wire state;
	wire p1_score, p2_score;
	wire [11:0] rgb_next;
	wire video_on;         // Same signal as in controller

    vga_controller vga_c(.clk(clk), .reset(reset), .hsync(Hsync), .vsync(Vsync),
                         .video_on(video_on), .p_tick(tick), .x(x), .y(y));
                         
    pong p(.clk(clk), .reset(reset), .start(start), .up(reset), 
           .down(reset),  .video_on(video_on), .x(x), .y(y), 
           .p1_score(p1_score), .p2_score(p2_score), .rgb(rgb_next));
           
    always @(posedge clk)
        if(tick)
            rgb_reg <= rgb_next;
    
    assign rgb = rgb_reg;
     
endmodule
