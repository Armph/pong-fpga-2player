`timescale 1ns / 1ps

module pong(
    input clk,  
    input reset,    
    input [1:0] btn,        // btn[0] = up, btn[1] = down
    input gra_still,        // still graphics - newgame, game over states
    input video_on,
    input [9:0] x,
    input [9:0] y,
    output graph_on,
    output reg p1_score, p2_score,   // ball hit or miss
    output reg [11:0] graph_rgb
    );
    
    // maximum x, y values in display area
    parameter X_MAX = 639;
    parameter Y_MAX = 479;
    
    // create 60Hz refresh tick
    wire refresh_tick;
    assign refresh_tick = ((y == 481) && (x == 0)) ? 1 : 0; // start of vsync(vertical retrace)
    
    
    // WALLS
    // TOP wall boundaries
    parameter T_WALL_T = 10;    
    parameter T_WALL_B = 17;    // 8 pixels wide
    // BOTTOM wall boundaries
    parameter B_WALL_T = 472;    
    parameter B_WALL_B = 479;    // 8 pixels wide
    
    // PADDLE
    parameter PAD_HEIGHT = 72;      // 72 pixels high
    parameter PAD_VELOCITY = 3;     // change to speed up or slow down paddle movement
    
    // paddle horizontal boundaries
    parameter X_PAD_L = 36;
    parameter X_PAD_R = 42;         // 6 pixels wide
    wire [9:0] y_pad_t, y_pad_b;
    reg [9:0] y_pad_reg = 204;      // Paddle starting position
    reg [9:0] y_pad_next;
    
    // PADDLE P2
    parameter X_PAD2_L = 597;
    parameter X_PAD2_R = 603;      // 6 pixels wide
    wire [9:0] y_pad2_t, y_pad2_b;
    reg [9:0] y_pad2_reg = 204;    // Paddle starting position
    reg [9:0] y_pad2_next;
     
    
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
    parameter BALL_VELOCITY_POS = 2;    // ball speed positive pixel direction(down, right)
    parameter BALL_VELOCITY_NEG = -2;   // ball speed negative pixel direction(up, left)
    // round ball from square image
    wire [2:0] rom_addr, rom_col;   // 3-bit rom address and rom column
    reg [7:0] rom_data;             // data at current rom address
    wire rom_bit;                   // signify when rom data is 1 or 0 for ball rgb control
    
    
    // Register Control
    always @(posedge clk or posedge reset)
        if(reset) begin
            y_pad_reg <= 204;
            x_ball_reg <= 0;
            y_ball_reg <= 0;
            x_delta_reg <= 10'h002;
            y_delta_reg <= 10'h002;
        end
        else begin
            y_pad_reg <= y_pad_next;
            x_ball_reg <= x_ball_next;
            y_ball_reg <= y_ball_next;
            x_delta_reg <= x_delta_next;
            y_delta_reg <= y_delta_next;
        end
    
    
    // ball rom
    always @*
        case(rom_addr)
            3'b000 :    rom_data = 8'b00111100; //   ****  
            3'b001 :    rom_data = 8'b01111110; //  ******
            3'b010 :    rom_data = 8'b11111111; // ********
            3'b011 :    rom_data = 8'b11111111; // ********
            3'b100 :    rom_data = 8'b11111111; // ********
            3'b101 :    rom_data = 8'b11111111; // ********
            3'b110 :    rom_data = 8'b01111110; //  ******
            3'b111 :    rom_data = 8'b00111100; //   ****
        endcase
    
    
    // OBJECT STATUS SIGNALS
    wire t_wall_on, b_wall_on, pad_on, pad2_on, sq_ball_on, ball_on;
    wire [11:0] wall_rgb, pad_rgb, pad2_rgb, ball_rgb, bg_rgb;
    
    
    // pixel within wall boundaries
    assign t_wall_on = ((T_WALL_T <= y) && (y <= T_WALL_B)) ? 1 : 0;
    assign b_wall_on = ((B_WALL_T <= y) && (y <= B_WALL_B)) ? 1 : 0;
    
    
    // assign object colors
    assign wall_rgb   = 12'hEEE;    
    assign pad_rgb    = 12'hD78;   
    assign pad2_rgb   = 12'h7BF;
    assign ball_rgb   = 12'hFFF;    
    assign bg_rgb     = 12'h111;
    
    
    // paddle 
    assign y_pad_t = y_pad_reg;                            
    assign y_pad_b = y_pad_t + PAD_HEIGHT - 1;             
    assign pad_on = (X_PAD_L <= x) && (x <= X_PAD_R) &&     
                    (y_pad_t <= y) && (y <= y_pad_b);
                    
    // Paddle Control
    always @* begin
        y_pad_next = y_pad_reg;
        if(refresh_tick)
            if(btn[1] & (y_pad_b < (B_WALL_T - 1 - PAD_VELOCITY)))
                y_pad_next = y_pad_reg + PAD_VELOCITY;  // move down
            else if(btn[0] & (y_pad_t > (T_WALL_B - 1 - PAD_VELOCITY)))
                y_pad_next = y_pad_reg - PAD_VELOCITY;  // move up
    end
    
    // paddle2 
    assign y_pad2_t = y_pad2_reg;                            
    assign y_pad2_b = y_pad2_t + PAD_HEIGHT - 1;             
    assign pad2_on = (X_PAD2_L <= x) && (x <= X_PAD2_R) &&     
                    (y_pad2_t <= y) && (y <= y_pad2_b);
                    
    // Paddle Control
    always @* begin
        y_pad2_next = y_pad2_reg;
        if(refresh_tick)
            if(btn[1] & (y_pad2_b < (B_WALL_T - 1 - PAD_VELOCITY)))
                y_pad2_next = y_pad2_reg + PAD_VELOCITY;  // move down
            else if(btn[0] & (y_pad2_t > (T_WALL_B - 1 - PAD_VELOCITY)))
                y_pad2_next = y_pad2_reg - PAD_VELOCITY;  // move up
    end
    
    
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
    assign x_ball_next = (gra_still) ? X_MAX / 2 :
                         (refresh_tick) ? x_ball_reg + x_delta_reg : x_ball_reg;
    assign y_ball_next = (gra_still) ? Y_MAX / 2 :
                         (refresh_tick) ? y_ball_reg + y_delta_reg : y_ball_reg;
    
    // change ball direction after collision
    always @* begin
        p1_score = 1'b0;
        p2_score = 1'b0;
        x_delta_next = x_delta_reg;
        y_delta_next = y_delta_reg;
        
        if(gra_still) begin
            x_delta_next = BALL_VELOCITY_NEG;
            y_delta_next = BALL_VELOCITY_POS;
        end
        
        else if(y_ball_t < T_WALL_B)            // reach top
            y_delta_next = BALL_VELOCITY_POS;   // move down
        
        else if(y_ball_b > (B_WALL_T))         // reach bottom wall
            y_delta_next = BALL_VELOCITY_NEG;   // move up
        
        else if((X_PAD_L <= x_ball_r) && (x_ball_r <= X_PAD_R) &&
                (y_pad_t <= y_ball_b) && (y_ball_t <= y_pad_b)) begin
                    x_delta_next = BALL_VELOCITY_POS;  
        end
        
        else if((X_PAD2_L <= x_ball_r) && (x_ball_r <= X_PAD2_R) &&
                (y_pad2_t <= y_ball_b) && (y_ball_t <= y_pad2_b)) begin
                    x_delta_next = BALL_VELOCITY_NEG;  
        end
        
        else if(x_ball_r < 1) p2_score = 1'b1;
        
        else if(x_ball_r > X_MAX) p1_score = 1'b1;
    end                    
    
    // output status signal for graphics 
    assign graph_on = t_wall_on | b_wall_on | pad_on | pad2_on | ball_on;
    
    
    // rgb multiplexing circuit
    always @*
        if(~video_on)
            graph_rgb = 12'h000;      // no value, blank
        else
            if(t_wall_on | b_wall_on)
                graph_rgb = wall_rgb;     // wall color
            else if(pad_on)
                graph_rgb = pad_rgb;      // paddle color
            else if(pad2_on)
                graph_rgb = pad2_rgb;
            else if(ball_on)
                graph_rgb = ball_rgb;     // ball color
            else
                graph_rgb = bg_rgb;       // background
       
endmodule