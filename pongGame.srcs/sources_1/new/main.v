`timescale 1ns / 1ps

module main(
    input clk,             
	input btnC,            // for reset
	input btnU,            // for start
	input RsRx,
	output Hsync, 
	output Vsync,
	output RsTx,
	output [3:0] vgaRed,    
	output [3:0] vgaBlue,
	output [3:0] vgaGreen,
	output [6:0] seg,
	output [3:0] an
    );
    
     // states
    parameter newball = 1'b0;
    parameter play    = 1'b1;
           
    wire [11:0] rgb;
    wire an0, an1, an2, an3;
    assign rgb = {vgaRed, vgaGreen, vgaBlue};
    assign an = {an3, an2, an1, an0};
    
    reg [0:0] state_reg, state_next;
    wire [9:0] w_x, w_y;
    wire p1u, p1d, p2u, p2d, newB;
    wire [4:0] kb;
    wire [1:0] btn1, btn2;
    wire w_vid_on, w_p_tick, graph_on, text_on, p1_score, p2_score;
    wire [11:0] graph_rgb, text_rgb;
    reg [11:0] rgb_reg, rgb_next;
    wire [3:0] num0, num1, num2, num3;
    reg gra_still, p1_inc, p2_inc;
    wire reset;
    wire start;
    wire start2;
    assign {p1u, p1d, p2u, p2d, newB} = kb;
    
    // reg [2:0] btn;
    assign btn1 = {p1d, p1u};
    assign btn2 = {p2d, p2u};
    
    btn reset_btn(.clk(clk), .btn_in(btnC), .btn_out(reset));
	btn start_btn(.clk(clk), .btn_in(btnU), .btn_out(start));
	btn start2_btn(.clk(clk), .btn_in(newB), .btn_out(start2));
    uart(.clk(clk), .RsRx(RsRx), .RsTx(RsTx), .kb(kb));
    
    // module
    vga_controller vga_unit(
        .clk_100MHz(clk),
        .reset(reset),
        .video_on(w_vid_on),
        .hsync(Hsync),
        .vsync(Vsync),
        .p_tick(w_p_tick),
        .x(w_x),
        .y(w_y));
        
    pong(
        .clk(clk),
        .reset(reset),
        .btn1(btn1),
        .btn2(btn2),
        .gra_still(gra_still),
        .video_on(w_vid_on),
        .x(w_x),
        .y(w_y),
        .p1_score(p1_score),
        .p2_score(p2_score),
        .graph_on(graph_on),
        .graph_rgb(graph_rgb));
    
    pongScore(
        .clk(clk),
        .reset(reset),
        .p1_inc(p1_inc),
        .p2_inc(p2_inc),
        .num0(num0),
        .num1(num1),
        .num2(num2),
        .num3(num3));
    
    pongTxt(
        .clk(clk),
        .x(w_x),
        .y(w_y),
        .num0(num0),
        .num1(num1),
        .num2(num2),
        .num3(num3),
        .text_on(text_on),
        .text_rgb(text_rgb));
    
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
       
    quad7seg(.clk(targetClk), 
             .num0(num0),
             .num1(num1),
             .num2(num2),
             .num3(num3), 
             .an0(an0), 
             .an1(an1),
             .an2(an2), 
             .an3(an3), 
             .seg_out(seg));
                 
    // state machine
    always @(posedge clk or posedge reset)
        if(reset) begin
            state_reg <= newball;
            rgb_reg <= 0;
        end
    
        else begin
            state_reg <= state_next;
            if(w_p_tick)
                rgb_reg <= rgb_next;
        end
    
    // state machine
    always @* begin
        gra_still = 1'b1;
        p1_inc = 1'b0;
        p2_inc = 1'b0;
        state_next = state_reg;
        
        case(state_reg)
            newball: begin
                if(start | newB) state_next = play;
            end
            
            play: begin
                gra_still = 1'b0;   
                
                if(p1_score) begin
                    p1_inc = 1'b1;
                    state_next = newball;
                end
                
                else if(p2_score) begin
                    p2_inc = 1'b1;
                    state_next = newball;
                end
            end
        endcase           
    end
    
    always @*
        if(~w_vid_on) rgb_next = 12'h000;
        else
            //if (graph_on)
            if (text_on)
                rgb_next = text_rgb;
            else
                rgb_next = graph_rgb;
    
    assign rgb = rgb_reg;
    
endmodule
