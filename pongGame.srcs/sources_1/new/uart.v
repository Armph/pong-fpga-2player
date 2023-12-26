`timescale 1ns / 1ps

module uart(
    input clk,
    input RsRx,
    output RsTx,
    output [4:0] kb
    );
    
    reg en, last_rec;
    reg [7:0] data_in;
    reg [3:0] keys = 4'b0000;
    reg newB = 1'b0;
    reg lState = 1'b0; 
    wire [7:0] data_out;
    wire sent, received, baud;
    
    assign kb = {keys, newB}; 
    
    baudrate_gen baudrate_gen(clk, baud);
    uart_rx rx(baud, RsRx, received, data_out);
    uart_tx tx(baud, data_in, en, sent, RsTx);
    
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
        case (data_in)
            8'h77: keys[3:2] = 2'b10; 
            8'h73: keys[3:2] = 2'b01; 
            8'h69: keys[1:0] = 2'b10; 
            8'h6B: keys[1:0] = 2'b01;
        endcase
    end
    
    always @(posedge baud) begin
        if(sent) begin
            if(data_in == 8'h20 && lState == 1'b0) begin 
                newB = 1'b1;
                lState = 1'b1;
            end
            else if(data_in == 8'h20 && lState == 1'b1) begin
                newB = 1'b0;
            end
            else lState = 1'b0;
        end
    end

endmodule
