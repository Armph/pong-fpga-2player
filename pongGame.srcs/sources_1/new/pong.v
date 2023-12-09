`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/09/2023 08:46:32 PM
// Design Name: 
// Module Name: pong
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


module pong(
    input clk,  
    input reset,
    input start,    
    input up,
    input down,
    input video_on,
    input [9:0] x,
    input [9:0] y,
    output reg hit, p1_score, p2_score,
    output reg [11:0] rgb
    );
    
    // maximum x, y values in display area
    parameter X_MAX = 639;
    parameter Y_MAX = 479;
    
    // create 60Hz refresh tick
    wire refresh_tick;
    assign refresh_tick = ((y == 481) && (x == 0)) ? 1 : 0; // start of vsync(vertical retrace)
    
    // WALL
    // wall boundaries
    parameter X_WALL_L = 32;    
    parameter X_WALL_R = 39;    // 8 pixels wide
    
    // PADDLE P1
    // paddle horizontal boundaries
    parameter X_PAD_L = 36;
    parameter X_PAD_R = 42;    // 6 pixels wide
    // paddle vertical boundary signals
    wire [9:0] y_pad_t, y_pad_b;
    // register to track top boundary and buffer
    reg [9:0] y_pad_reg, y_pad_next;
    // paddle moving velocity when a button is pressed
    
    // PADDLE P2
    parameter X_PAD2_L = 597;
    parameter X_PAD2_R = 603;    // 4 pixels wide
    // paddle vertical boundary signals
    wire [9:0] y_pad2_t, y_pad2_b;
    // register to track top boundary and buffer
    reg [9:0] y_pad2_reg, y_pad2_next;
    // paddle moving velocity when a button is pressed
    
    parameter PAD_HEIGHT = 69;  // 72 pixels high
    parameter PAD_VELOCITY = 3;     // change to speed up or slow down paddle movement
    
    // BALL
    // square rom boundaries
    parameter BALL_SIZE = 8;
    // ball horizontal boundary signals
    wire [9:0] x_ball_l, x_ball_r;
    // ball vertical boundary signals
    wire [9:0] y_ball_t, y_ball_b;
    // register to track top left position
    reg [9:0] y_ball_reg, x_ball_reg;
    // signals for register buffer
    wire [9:0] y_ball_next, x_ball_next;
    // registers to track ball speed and buffers
    reg [9:0] x_delta_reg, x_delta_next;
    reg [9:0] y_delta_reg, y_delta_next;
    // positive or negative ball velocity
    parameter BALL_VELOCITY_POS = 2;
    parameter BALL_VELOCITY_NEG = -2;
    // round ball from square image
    wire [2:0] rom_addr, rom_col;    // 3-bit rom address and rom column
    wire [7:0] rom_data;             // data at current rom address
    wire rom_bit;                    // signify when rom data is 1 or 0 for ball rgb control
    
    // Register Control
    always @(posedge clk or posedge reset)
        if(reset) begin
            y_pad_reg <= 0;
            x_ball_reg <= 0;
            y_ball_reg <= 0;
            x_delta_reg <= 10'h002;
            y_delta_reg <= 10'h002;
        end
        else begin
            y_pad_reg <= y_pad_next;
            y_pad2_reg <= y_pad2_next;
            x_ball_reg <= x_ball_next;
            y_ball_reg <= y_ball_next;
            x_delta_reg <= x_delta_next;
            y_delta_reg <= y_delta_next;
        end
    
    // ball rom
    ball Ball(.addr(rom_addr), .data(rom_data));
    
    // OBJECT STATUS SIGNALS
    wire wall_on, pad_on, pad2_on, sq_ball_on, ball_on;
    wire [11:0] wall_rgb, pad_rgb, pad2_rgb, ball_rgb, bg_rgb;
    
    // pixel within wall boundaries
    assign wall_on = ((X_WALL_L <= x) && (x <= X_WALL_R)) ? 1 : 0;
    
    // assign object colors
    assign wall_rgb = 12'hAAA;      // gray wall
    assign pad_rgb = 12'hD78;       // gray paddle
    assign pad2_rgb = 12'h7BF;
    assign ball_rgb = 12'hFFF;      // white ball
    assign bg_rgb = 12'h111;       // close to black background
    
    // paddle 
    assign y_pad_t = y_pad_reg;                             // paddle top position
    assign y_pad_b = y_pad_t + PAD_HEIGHT - 1;              // paddle bottom position
    assign pad_on = (X_PAD_L <= x) && (x <= X_PAD_R) &&     // pixel within paddle boundaries
                    (y_pad_t <= y) && (y <= y_pad_b);
                    
    // Paddle Control
    always @* begin
        y_pad_next = y_pad_reg;     // no move
        if(refresh_tick)
            if(up & (y_pad_t > PAD_VELOCITY))
                y_pad_next = y_pad_reg - PAD_VELOCITY;  // move up
            else if(down & (y_pad_b < (Y_MAX - PAD_VELOCITY)))
                y_pad_next = y_pad_reg + PAD_VELOCITY;  // move down
    end
    
    // paddle2 
    assign y_pad2_t = y_pad2_reg;                             // paddle top position
    assign y_pad2_b = y_pad2_t + PAD_HEIGHT - 1;              // paddle bottom position
    assign pad2_on = (X_PAD2_L <= x) && (x <= X_PAD2_R) &&     // pixel within paddle boundaries
                    (y_pad2_t <= y) && (y <= y_pad2_b);
    
    
    // rom data square boundaries
    assign x_ball_l = x_ball_reg;
    assign y_ball_t = y_ball_reg;
    assign x_ball_r = x_ball_l + BALL_SIZE - 1;
    assign y_ball_b = y_ball_t + BALL_SIZE - 1;
    // pixel within rom square boundaries
    assign sq_ball_on = (x_ball_l <= x) && (x <= x_ball_r) &&
                        (y_ball_t <= y) && (y <= y_ball_b);
    // map current pixel location to rom addr/col
    assign rom_addr = y[2:0] - y_ball_t[2:0];   // 3-bit address
    assign rom_col = x[2:0] - x_ball_l[2:0];    // 3-bit column index
    assign rom_bit = rom_data[rom_col];         // 1-bit signal rom data by column
    // pixel within round ball
    assign ball_on = sq_ball_on & rom_bit;      // within square boundaries AND rom data bit == 1
    // new ball position
    assign x_ball_next = (refresh_tick) ? x_ball_reg + x_delta_reg : x_ball_reg;
    assign y_ball_next = (refresh_tick) ? y_ball_reg + y_delta_reg : y_ball_reg;
    
    // change ball direction after collision
    always @* begin
        hit = 1'b0;
        p1_score = 1'b0;
        p2_score = 1'b0;
        x_delta_next = x_delta_reg;
        y_delta_next = y_delta_reg;
        if(y_ball_t < 1)                                            // collide with top
            y_delta_next = BALL_VELOCITY_POS;                       // move down
        else if(y_ball_b > Y_MAX)                                   // collide with bottom
            y_delta_next = BALL_VELOCITY_NEG;                       // move up
        else if((X_PAD_L <= x_ball_r) && (x_ball_r <= X_PAD_R) &&
                (y_pad_t <= y_ball_b) && (y_ball_t <= y_pad_b))     // collide with paddle 1
            x_delta_next = BALL_VELOCITY_POS;                       // move left
        else if((X_PAD2_L <= x_ball_r) && (x_ball_r <= X_PAD2_R) &&
                (y_pad2_t <= y_ball_b) && (y_ball_t <= y_pad2_b))   // collide with paddle 2
            x_delta_next = BALL_VELOCITY_NEG;                       // move right
    end                    
    
    // rgb multiplexing circuit
    always @*
        if(~video_on)
            rgb = 12'h000;      // no value, blank
        else
            if(pad2_on)
                rgb = pad2_rgb;     // wall color
            else if(pad_on)
                rgb = pad_rgb;      // paddle color
            else if(ball_on)
                rgb = ball_rgb;     // ball color
            else
                rgb = bg_rgb;       // background
                
endmodule
