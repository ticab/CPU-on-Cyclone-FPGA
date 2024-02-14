module register #(
    parameter DATA_WIDTH = 16
) (
    input clk,
    input rst_n,
    input cl,
    input ld,
    input [DATA_WIDTH-1:0] in,
    input inc,
    input dec,
    input sr,
    input ir,
    input sl,
    input il,
    output [DATA_WIDTH-1:0] out
);

    reg [DATA_WIDTH-1:0] out_reg, out_next;
    integer temp;

    assign out = out_reg;

    always @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            out_reg <= {DATA_WIDTH{1'd0}};
        end else begin
            out_reg <= out_next;
        end
    end    

    always @(*) begin
        out_next = out_reg;
        if (cl)
            out_next = {DATA_WIDTH{1'd0}};
        else if (ld)
            out_next = in;
        else if (inc)
            out_next = out_next + {{(DATA_WIDTH-1){1'd0}}, 1'd1};
        else if(dec)
            out_next = out_next - {{(DATA_WIDTH-1){1'd0}}, 1'd1};
        else if(sr)
            out_next = (out_next>>1) + {ir, {(DATA_WIDTH-1){1'd0}}};
        else if(sl)
            out_next = (out_next<<1) + {{(DATA_WIDTH-1){1'd0}}, il};
    end

endmodule

