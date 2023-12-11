`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/12/2023 04:13:47 AM
// Design Name: 
// Module Name: uart
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


module uart(
    input clk,
    input RsRx,
    output RsTx,
    output [4:0] kb
    );
    
    reg en, last_rec;
    reg [7:0] data_in;
    reg [3:0] movement = 4'b0000;
    reg l = 1'b0;
    reg lState = 1'b0; 
    wire [7:0] data_out;
    wire sent, received, baud;
    
    assign kb = {movement,l}; 
    
    baudrate_gen baudrate_gen(clk, baud); // generate baud rate
    uart_rx rx(baud, RsRx, received, data_out); // encode data to 8 bits
    uart_tx tx(baud, data_in, en, sent, RsTx); // check if input is valid
    
    always @(posedge baud) begin
        if (en) en = 0;
        if (~last_rec & received) begin
            data_in = data_out;
            if (data_in == 8'h77  // w
             || data_in == 8'h73  // s
             || data_in == 8'h69  // i 
             || data_in == 8'h6B  // k
             || data_in == 8'h20) // sp
                en = 1;
        end
        last_rec = received;
    end
    
    always @(posedge sent) begin
        if (sent) begin
            case (data_in)
                8'h77: movement[3:2] = 2'b10; 
                8'h73: movement[3:2] = 2'b01; 
                8'h69: movement[1:0] = 2'b10; 
                8'h6B: movement[1:0] = 2'b01; 
            endcase
        end
    end
    
    always @(posedge baud) begin
        if(sent) begin // l key to throw ball
            if(data_in == 8'h20 && lState == 1'b0) begin // l key pressed
                l = 1'b1;
                lState = 1'b1;
            end
            else if(data_in == 8'h20 && lState == 1'b1) begin // allow only 1 l key press (single pulse)
                l = 1'b0;
            end
            else lState = 1'b0; // l key released
        end
    end

endmodule
