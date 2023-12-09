`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/09/2023 03:33:11 PM
// Design Name: 
// Module Name: vga_controller
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


module vga_controller(
    input clk,   
    input reset,        
    output video_on,
    output hsync,      
    output vsync,      
    output p_tick,      
    output [9:0] x,     
    output [9:0] y
    );
    
    // 640x480 resolution
    // Total horizontal width of screen = 800 pixels
    parameter HD = 640;             // horizontal display area width in pixels
    parameter HF = 48;              // horizontal front porch width in pixels
    parameter HB = 16;              // horizontal back porch width in pixels
    parameter HR = 96;              // horizontal retrace width in pixels
    parameter HMAX = HD+HF+HB+HR-1; // 799
    
    // Total vertical length of screen = 525 pixels
    parameter VD = 480;             // vertical display area length in pixels 
    parameter VF = 10;              // vertical front porch length in pixels  
    parameter VB = 33;              // vertical back porch length in pixels   
    parameter VR = 2;               // vertical retrace length in pixels  
    parameter VMAX = VD+VF+VB+VR-1; // 524
    
    clkDiv clk_divider (
        .clk(clk),
        .reset(reset),
        .tick(p_tick)
    );
    
    reg [9:0] h_count_reg, h_count_next;
    reg [9:0] v_count_reg, v_count_next;
    
    // Output Buffers
    reg v_sync_reg, h_sync_reg;
    wire v_sync_next, h_sync_next;
    
    // Register Control
    always @(posedge clk or posedge reset)
        if(reset) begin
            v_count_reg <= 0;
            h_count_reg <= 0;
            v_sync_reg  <= 1'b0;
            h_sync_reg  <= 1'b0;
        end
        else begin
            v_count_reg <= v_count_next;
            h_count_reg <= h_count_next;
            v_sync_reg  <= v_sync_next;
            h_sync_reg  <= h_sync_next;
        end
         
    //Logic for horizontal counter
    always @(posedge p_tick or posedge reset)      // pixel tick
        if(reset)
            h_count_next = 0;
        else
            if(h_count_reg == HMAX)                 // end of horizontal scan
                h_count_next = 0;
            else
                h_count_next = h_count_reg + 1;         
  
    // Logic for vertical counter
    always @(posedge p_tick or posedge reset)
        if(reset)
            v_count_next = 0;
        else
            if(h_count_reg == HMAX)                 // end of horizontal scan
                if((v_count_reg == VMAX))           // end of vertical scan
                    v_count_next = 0;
                else
                    v_count_next = v_count_reg + 1;
        
    // h_sync_next asserted within the horizontal retrace area
    assign h_sync_next = (h_count_reg >= (HD+HB) && h_count_reg <= (HD+HB+HR-1));
    
    // v_sync_next asserted within the vertical retrace area
    assign v_sync_next = (v_count_reg >= (VD+VB) && v_count_reg <= (VD+VB+VR-1));
    
    // Video ON/OFF - only ON while pixel counts are within the display area
    assign video_on = (h_count_reg < HD) && (v_count_reg < VD); // 0-639 and 0-479 respectively
            
    // Outputs
    assign hsync  = h_sync_reg;
    assign vsync  = v_sync_reg;
    assign x      = h_count_reg;
    assign y      = v_count_reg;
    
    /*
    
    
    wire v_enable;
    wire h_count;
    wire v_count;
    
    h_counter(
        .clk(p_tick),
        .HMAX(HMAX),
        .v_enable(v_enable),
        .h_count(h_count)
    );
    
    v_counter(
        .clk(p_tick),
        .VMAX(VMAX),
        .v_enable(v_enable),
        .v_count(v_count)
    );
    */
endmodule
