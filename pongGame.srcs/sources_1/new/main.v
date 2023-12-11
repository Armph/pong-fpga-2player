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
	input btnU,            // for start
	output Hsync, 
	output Vsync,
	output [3:0] vgaRed,    
	output [3:0] vgaBlue,
	output [3:0] vgaGreen,
	output [6:0] seg,
	output [3:0] an
    );
    
    wire [11:0] rgb;
    wire an0, an1, an2, an3;
    wire reset;
    wire start;
    reg state;
    reg [1:0] state_reg, state_next;
    // reg [1:0] way;
    
	assign rgb = {vgaRed, vgaGreen, vgaBlue};
	assign an = {an3, an2, an1, an0};
	btn reset_btn(.clk(clk), .btn_in(btnC), .btn_out(reset));
	btn start_btn(.clk(clk), .btn_in(btnU), .btn_out(start));
	
	wire tick;
	wire [9:0] x, y;
	reg [11:0] rgb_reg;    // register for Basys 3 12-bit RGB DAC 
	// wire state;
	wire p1_score, p2_score;
	wire [11:0] rgb_next;
	wire video_on;         // Same signal as in controller
	wire [12:0] quad;
	
	wire targetClk;
    wire [18:0] tclk;
    
    assign tclk[0] = clk;
    
    genvar c;
    
    generate for(c = 0; c < 18; c = c + 1)
        begin
            nGate fdiv(tclk[c], tclk[c+1]);
        end
    endgenerate
    
    nGate fdivTarget(tclk[18], targetClk);
    
    
    always @(posedge clk)
        if(tick)
            rgb_reg <= rgb_next;
    
    assign rgb = rgb_reg;
    

    vga_controller vga_c(.clk(clk), .reset(reset), .hsync(Hsync), .vsync(Vsync),
                         .video_on(video_on), .p_tick(tick), .x(x), .y(y));
                         
    pong p(.clk(clk), .state(state), .reset(reset), .up(reset), 
           .down(reset),  .video_on(video_on), .x(x), .y(y), 
           .p1_score(p1_score), .p2_score(p2_score), .rgb(rgb_next));
           
    pongScore ps(.clk(clk), .p1_score(p1_score), .p2_score(p2_score), .reset(reset), .quad(quad));
    
    quad7seg q7s(.clk(targetClk), .quad(quad), .an0(an0), .an1(an1),
                 .an2(an2), .an3(an3), .seg(seg));
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state_reg <= 1'b1;
        end
        else begin
            state_reg <= state_next;
        end
    end
    
    always @* begin
        state = 1'b1;
        state_next = state_reg;
        case(state_reg)
            1'b0: begin
                state = 1'b0;
                if (p1_score | p2_score) begin
                    state_next = 1'b1;
                end
            end
            1'b1: begin
                if (start) begin
                    state_next = 1'b0;
                end
            end
        endcase
    end
    
endmodule
