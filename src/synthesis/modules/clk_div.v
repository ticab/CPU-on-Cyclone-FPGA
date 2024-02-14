module clk_div #(
	parameter DIVISOR = 50_000_000
)(
	input clk,
	input rst_n,
	output out
);

    reg out_next, out_reg;
    integer timer_next, timer_reg;

    assign out = out_reg;

    always @(posedge clk, negedge rst_n)
        if (!rst_n) begin
            out_reg <= 1'd0;
            timer_reg <= 0;
        end
        else begin
            out_reg <= out_next;
            timer_reg <= timer_next;
        end

    always @(*) begin
        out_next = out_reg;
        timer_next = timer_reg;
        if (timer_reg == DIVISOR)
            timer_next = 0;
        else 
            timer_next = timer_reg + 1;
        if(timer_next < DIVISOR/2)
            out_next = 1'd1;
        else 
            out_next = 1'd0;
    end

endmodule
