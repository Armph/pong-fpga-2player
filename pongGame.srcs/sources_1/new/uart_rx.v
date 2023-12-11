`timescale 1ns / 1ps

module uart_rx (
    input clk,
    input in,
    output reg received,
    output reg [7:0] data_out
    );
    
    reg last;
    reg receiving = 0;
    reg [7:0] count;
    
    always@(posedge clk) begin
        if (~receiving & last & ~in) begin
            receiving <= 1;
            received <= 0;
            count <= 0;
        end

        last <= in;
        count <= (receiving) ? count+1 : 0;
        
        case (count)
            8'd24:  data_out[0] <= in;
            8'd40:  data_out[1] <= in;
            8'd56:  data_out[2] <= in;
            8'd72:  data_out[3] <= in;
            8'd88:  data_out[4] <= in;
            8'd104: data_out[5] <= in;
            8'd120: data_out[6] <= in;
            8'd136: data_out[7] <= in;
            8'd152: begin received <= 1; receiving <= 0; end
        endcase
    end
    
endmodule
  