module alu (input [2:0] oc,
            input [3:0] a,
            input [3:0] b,
            output reg [3:0] f);

always @(a,b,oc) begin
    case (oc)
        3'd0: f=a+b;
        3'd1: f=a-b;
        3'd2: f=a*b;
        3'd3: f=a/b;
        3'd4: f=~a;
        3'd5: f=a^b;
        3'd6: f=a|b;
        3'd7: f=a&b;
    endcase
end

endmodule
