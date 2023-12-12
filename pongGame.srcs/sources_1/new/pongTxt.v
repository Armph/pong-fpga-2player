`timescale 1ns / 1ps

module pongTxt(
    input clk,
    input [3:0] num0, num1, num2, num3,
    input [9:0] x, y,
    output text_on,
    output reg [11:0] text_rgb
    );
    
    wire [10:0] rom_addr;
    reg [6:0] char_addr, char_addr_s;
    reg [3:0] row_addr;
    wire [3:0] row_addr_s;
    reg [2:0] bit_addr;
    wire [2:0] bit_addr_s;
    wire [7:0] ascii_word;
    wire ascii_bit;
    wire [7:0] rule_rom_addr;
    
    parameter X_MAX = 639;
    parameter Y_MAX = 479;
    
    ascii_rom ascii_unit(.clk(clk), .addr(rom_addr), .data(ascii_word));
    
    // assign text_on = (x[9:7] == 2) && (y[9:6] == 2);
    assign text_on = (x[9:7] == 2) && (y >=34) && (y < 64);
    assign row_addr_s = y[4:1];
    assign bit_addr_s = x[3:1];
    always @* begin
        case(x[6:4])
            3'b000 : char_addr_s = 7'h00; 
            3'b001 : char_addr_s = {3'b011, num1};    // 1p1
            3'b010 : char_addr_s = {3'b011, num0};    // 0p1
            3'b011 : char_addr_s = 7'h00;             //
            3'b100 : char_addr_s = 7'h3A;             // :
            3'b101 : char_addr_s = 7'h00;             //
            3'b110 : char_addr_s = {3'b011, num3};    // 1p2
            3'b111 : char_addr_s = {3'b011, num2};    // 0p2
        endcase
    end
    
    always @* begin
        text_rgb = 12'h111;
        if (text_on) begin
            char_addr = char_addr_s;
            row_addr = row_addr_s;
            bit_addr = bit_addr_s;
            if (ascii_bit)
                text_rgb = 12'hFFA;
        end
    end
        
    assign rom_addr = {char_addr, row_addr};
    assign ascii_bit = ascii_word[~bit_addr];
    
endmodule
