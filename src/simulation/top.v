module top; 
    reg [2:0] dut_oc; //3
    reg [3:0] dut_a; //4
    reg [3:0] dut_b; //4
    wire [3:0] dut_f; //4

    
    reg dut_clk, dut_rst_n, dut_cl, dut_ld, dut_inc, dut_dec, dut_sr, dut_sl, dut_il, dut_ir;
    reg [3:0] dut_in;
    wire [3:0] dut_out;

    reg pr;

    alu dut(
		.oc(dut_oc),
		.a(dut_a),
		.b(dut_b),
		.f(dut_f)
	);

    register dut2(
        .clk(dut_clk),
        .rst_n(dut_rst_n),
        .ld(dut_ld),
        .inc(dut_inc),
        .cl(dut_cl),
        .dec(dut_dec),
        .sr(dut_sr),
        .ir(dut_ir),
        .sl(dut_sl),
        .il(dut_il),
        .in(dut_in),
        .out(dut_out)
    );
    
    integer i;
    
    initial begin
        pr = 1'b0;
        for (i = 0; i < 2**11; i = i + 1) begin
            {dut_oc, dut_a, dut_b} = i;
            #5;
        end
        $stop;
        pr = 1'b1;
        dut_cl = 1'b0; 
        dut_ld = 1'b0; 
        dut_inc = 1'b0;
        dut_dec = 1'b0;
        dut_sr = 1'b0;
        dut_sl = 1'b0; 
        dut_il = 1'b0; 
        dut_in = 4'd0;
        dut_ir = 1'b0;
        #2 dut_rst_n = 1'b1;
        repeat (1000) begin
            {dut_ld, dut_inc, dut_cl, dut_dec, dut_sr, dut_ir, dut_sl, dut_il} = $urandom_range(255);
            dut_in = $urandom_range(15);
            #10;
        end
        $finish;
    end

    initial begin
        $monitor(
			"time = %4d, oc = %b, a = %d, b = %d, f = %d",
			$time, dut_oc, dut_a, dut_b, dut_f
        );
    end

    initial begin
        dut_rst_n = 1'b0;
        dut_clk = 1'b0;
        forever 
            #5 dut_clk = ~dut_clk;
    end

    always @(posedge dut_clk)
        if(pr == 1'b1) begin
            $strobe(
                "time = %4d, in = %d, cl= %d, ld = %d, inc= %d, dec= %d, sr= %d, sl= %d, ir= %d, il= %d, out = %4d",
                $time, dut_in, dut_cl, dut_ld, dut_inc, dut_dec, dut_sr, dut_sl, dut_ir, dut_il, dut_out
            );
        end

endmodule
