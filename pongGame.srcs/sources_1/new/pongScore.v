`timescale 1ns / 1ps

module pongScore(
    input clk,
    input reset,
    input p1_inc, p2_inc,
    output [3:0] num0, num1, num2, num3
    );
    
    
    reg [3:0] r_p1_dig0, r_p1_dig1, p1_dig0_next, p1_dig1_next;
    reg [3:0] r_p2_dig0, r_p2_dig1, p2_dig0_next, p2_dig1_next;
    
    // register control
    always @(posedge clk or posedge reset)
        if(reset) begin
            r_p1_dig1 <= 0;
            r_p1_dig0 <= 0;
            r_p2_dig1 <= 0;
            r_p2_dig0 <= 0;
        end
        else begin
            r_p1_dig1 <= p1_dig1_next;
            r_p1_dig0 <= p1_dig0_next;
            r_p2_dig1 <= p2_dig1_next;
            r_p2_dig0 <= p2_dig0_next;
        end
    
    // next state logic
    always @* begin
        p1_dig0_next = r_p1_dig0;
        p1_dig1_next = r_p1_dig1;
        p2_dig0_next = r_p2_dig0;
        p2_dig1_next = r_p2_dig1;
        
        if (p1_inc) begin
            if(r_p1_dig0 == 9) begin
                p1_dig0_next = 0;
                if(r_p1_dig1 == 9)
                    p1_dig1_next = 0;
                else
                    p1_dig1_next = r_p1_dig1 + 1;
            end
            else
                p1_dig0_next = r_p1_dig0 + 1;
         end
         else if (p2_inc) begin
            if(r_p2_dig0 == 9) begin
                p2_dig0_next = 0;
                if(r_p2_dig1 == 9)
                    p2_dig1_next = 0;
                else
                    p2_dig1_next = r_p2_dig1 + 1;
            end
            else
                p2_dig0_next = r_p2_dig0 + 1;
         end
    end
    
    assign num2 = r_p1_dig0;
    assign num3 = r_p1_dig1;
    assign num0 = r_p2_dig0;
    assign num1 = r_p2_dig1;
    
endmodule