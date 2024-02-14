module register (
    input clk,
    input rst_n,
    input cl,
    input ld,
    input [3:0] in,
    input inc,
    input dec,
    input sr,
    input ir,
    input sl,
    input il,
    output [3:0] out
);

    reg [3:0] out_reg, out_next;

    assign out = out_reg;

    always @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            out_reg <= 4'd0;
        end else begin
            out_reg <= out_next;
        end
    end    

    always @(*) begin
        out_next = out_reg;
        if (cl)
            out_next = 4'd0;
        else if (ld)
            out_next = in;
        else if (inc)
            out_next = out_reg + 4'd1;
        else if(dec)
            out_next = out_reg - 4'd1;
        else if(sr)
            out_next = {ir, out_reg[3:1]};
        else if(sl)
            out_next = {out_reg[2:0], il};
    end

endmodule

