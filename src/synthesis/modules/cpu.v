module cpu #(
    parameter ADDR_WIDTH = 6,
    parameter DATA_WIDTH = 16
)(
    input clk,
    input rst_n,
    input [DATA_WIDTH-1 : 0] mem_in,
    input [DATA_WIDTH-1 : 0] in,
    output reg mem_we,
    output reg [ADDR_WIDTH - 1:0] mem_addr,
    output reg [DATA_WIDTH - 1:0] mem_data,
    output [DATA_WIDTH - 1:0] out,
    output [ADDR_WIDTH - 1:0] pc,
    output [ADDR_WIDTH - 1:0] sp
);

assign out = out_reg;

reg [DATA_WIDTH-1 : 0] out_next, out_reg;
reg [2:0] state_next, state_reg;
reg [3:0] cnt_next, cnt_reg;

reg pc_ld, pc_inc;
reg [5:0] pc_in;
//6b datawidth
register #(.DATA_WIDTH(6)) PC(
    .clk(clk),
    .rst_n(rst_n),
    .cl(1'b0),
    .ld(pc_ld),
    .in(pc_in),
    .inc(pc_inc),
    .dec(1'b0),
    .sr(1'b0),
    .ir(1'b0),
    .sl(1'b0),
    .il(1'b0),
    .out(pc)
);

reg sp_cl, sp_ld, sp_inc, sp_dec;
reg [5:0] sp_in;
//6b datawidth
register #(.DATA_WIDTH(6)) SP(
    .clk(clk),
    .rst_n(rst_n),
    .cl(sp_cl),
    .ld(sp_ld),
    .in(sp_in),
    .inc(sp_inc),
    .dec(sp_dec),
    .sr(1'b0),
    .ir(1'b0),
    .sl(1'b0),
    .il(1'b0),
    .out(sp)
);

reg ir1_cl, ir1_ld, ir1_inc, ir1_dec, ir1_sr, ir1_ir, ir1_sl, ir1_il;
reg [15:0] ir1_in;
wire [15:0] ir1_out;
//16b datawidth
register #(.DATA_WIDTH(16)) IR1(
    .clk(clk),
    .rst_n(rst_n),
    .cl(ir1_cl),
    .ld(ir1_ld),
    .in(ir1_in),
    .inc(ir1_inc),
    .dec(ir1_dec),
    .sr(ir1_sr),
    .ir(ir1_ir),
    .sl(ir1_sl),
    .il(ir1_il),
    .out(ir1_out)
);

reg ir2_cl, ir2_ld, ir2_inc, ir2_dec, ir2_sr, ir2_ir, ir2_sl, ir2_il;
reg [15:0] ir2_in;
wire [15:0] ir2_out;
//16b datawidth
register #(.DATA_WIDTH(16)) IR2(
    .clk(clk),
    .rst_n(rst_n),
    .cl(ir2_cl),
    .ld(ir2_ld),
    .in(ir2_in),
    .inc(ir2_inc),
    .dec(ir2_dec),
    .sr(ir2_sr),
    .ir(ir2_ir),
    .sl(ir2_sl),
    .il(ir2_il),
    .out(ir2_out)
);

reg a_cl, a_ld, a_inc, a_dec, a_sr, a_ir, a_sl, a_il;
reg [15:0] a_in;
wire [15:0] a_out;
//16b datawidth
register #(.DATA_WIDTH(16)) A(
    .clk(clk),
    .rst_n(rst_n),
    .cl(a_cl),
    .ld(a_ld),
    .in(a_in),
    .inc(a_inc),
    .dec(a_dec),
    .sr(a_sr),
    .ir(a_ir),
    .sl(a_sl),
    .il(a_il),
    .out(a_out)
);

reg [2:0] alu_oc;
reg [15:0] alu_a, alu_b;
wire [15:0] alu_f;

alu #(.DATA_WIDTH(16)) ALU( 
    .oc(alu_oc),
    .a(alu_a),
    .b(alu_b),
    .f(alu_f)
);

always @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
        out_reg <= {DATA_WIDTH{1'b0}};
        state_reg <= {3{1'b0}};
        cnt_reg <= 4'd0;
    end
    else begin
        out_reg <= out_next;
        state_reg <= state_next;
        cnt_reg <= cnt_next;
    end
end

localparam setup = 3'd0;
localparam fetch = 3'd1;
localparam decode = 3'd2;
localparam execute = 3'd3;
localparam halt = 3'd4;
reg [3:0] help;
reg [3:0] help2;

always @(*) begin
    {mem_we, mem_addr, mem_data} = 23'd0;
    {pc_ld, pc_inc, pc_in} = 8'd0;
    {sp_cl, sp_ld, sp_inc, sp_dec, sp_in} = 10'd0;
    {ir1_cl, ir1_ld, ir1_inc, ir1_dec, ir1_sr, ir1_ir, ir1_sl, ir1_il, ir1_in} = 24'd0;
    {ir2_cl, ir2_ld, ir2_inc, ir2_dec, ir2_sr, ir2_ir, ir2_sl, ir2_il, ir2_in} = 24'd0;
    {a_cl, a_ld, a_inc, a_dec, a_sr, a_ir, a_sl, a_il, a_in} = 24'd0;
    {alu_oc, alu_a, alu_b} = 35'd0;
    help = 4'd0;
    help2 = 4'd0;
    state_next = state_reg;
    cnt_next = cnt_reg;
    out_next = out_reg;
    case (state_reg)
        setup: begin
            pc_in <= 6'd8;
            sp_in <= {ADDR_WIDTH{1'b1}};
            pc_ld = 1'b1;
            sp_ld = 1'b1;
            a_ld = 1'b1;
            state_next = fetch;
        end
        fetch: begin
            if(cnt_next==4'd0) begin
                mem_addr = pc;
                mem_we = 1'b0;
                cnt_next = cnt_next + 4'd1;
                pc_inc = 1'b1;
            end
            else if(cnt_next==4'd1) begin
                ir1_ld = 1'd1;
                ir1_in = mem_in;
                help = 4'd0;
                help = mem_in[15:12];
                if(help == 4'd0) begin //MOV
                    help = mem_in[3:0];
                    if(help == 4'b1000) begin //2B op
                        cnt_next = cnt_next + 4'd1;
                    end
                    else begin
                        state_next = decode;
                        cnt_next = 4'd0;
                    end
                end
                else begin
                    state_next = decode;
                    cnt_next = 4'd0;
                end
            end
            else if(cnt_next==4'd2) begin
                mem_addr = pc;
                mem_we = 1'b0;
                cnt_next = cnt_next + 4'd1;
            end
            else if(cnt_next==4'd3) begin
                ir2_ld = 1'd1;
                ir2_in = mem_in;
                state_next = decode;
                cnt_next = 4'd0;
                pc_inc = 1'b1;
            end
        end
        decode: begin
            help = 4'd0;
            help = ir1_out[15:12];
            case (help)
                4'b0111: begin //IN
                    mem_we = 1'b1;
                    mem_addr = {{3{1'b0}}, ir1_out[10:8]};
                    mem_data = in;
                    state_next = fetch;
                end
                4'b1000: begin //OUT
                    if(cnt_next == 4'd0) begin
                        mem_we = 1'b0;
                        mem_addr = {{3{1'b0}}, ir1_out[10:8]};
                        cnt_next = cnt_next + 4'd1;
                    end
                    else if(cnt_next == 4'd1) begin
                        out_next = mem_in;
                        cnt_next = 4'd0;
                        state_next = fetch;
                    end
                end
                4'b0001, 4'b0010, 4'b0011: begin //ADD, SUB, MUL
                    if(cnt_next == 4'd0) begin
                        mem_addr = {{3{1'b0}}, ir1_out[6:4]};
                        mem_we = 1'b0;
                        cnt_next = cnt_next + 4'd1;
                    end 
                    else if(cnt_next == 4'd1) begin
                        a_in = mem_in;
                        a_ld = 1'b1;
                        mem_addr = {{3{1'b0}}, ir1_out[2:0]};
                        mem_we = 1'b0;
                        state_next = execute;
                        cnt_next = 4'd0;
                    end
                    /*//1.takt podatak 2.op
                    if(cnt_next == 4'd0) begin
                        mem_addr = {{3{1'b0}}, ir1_out[6:4]};
                        mem_we = 1'b0;
                        if(ir1_out[7]==1'b0) 
                            cnt_next = 4'd2; //2.op direktno, prelazak na 3.op
                        else 
                            cnt_next = 4'd1; //2.op indireknto
                    end 
                    else if(cnt_next == 4'd1) begin
                        mem_addr = mem_in[5:0];
                        mem_we = 1'b0;
                        cnt_next = cnt_next + 4'd1;
                    end
                    else if(cnt_next == 4'd2) begin
                        alu_a = mem_in;
                        mem_addr = {{3{1'b0}}, ir1_out[2:0]};
                        mem_we = 1'b0;
                        if(ir1_out[3]==1'b0) begin //3.op direktno, prelazak na execute
                            state_next = execute;
                            cnt_next = 4'd0;
                        end
                        else
                            cnt_next = 4'd3; //3.op indirektno
                    end
                    else if(cnt_next == 4'd3) begin
                        mem_addr = mem_in[5:0];
                        mem_we = 1'b0;
                        cnt_next = 4'd0;
                        state_next = execute;
                    end*/
                end
                4'b0100: //DIV - skip
                    state_next = fetch;
                4'b0000: begin //MOV
                    if(cnt_next == 4'd0) begin
                        help2 = 4'd0;
                        help2 = ir1_out[3:0];
                        if(help2 == 4'd0) begin //MOV sa 1B
                            if(ir1_out[7] == 1'b1) begin
                                mem_addr = {{3{1'b0}}, ir1_out[6:4]}; //procitaj podatak sa adrese 2.op, indir
                                mem_we = 1'b0;
                                cnt_next = cnt_next + 4'd1;
                            end
                            else begin //direktno
                                mem_addr = {{3{1'b0}}, ir1_out[6:4]}; //procitaj podatak sa adrese 2.op, dir
                                mem_we = 1'b0;
                                state_next = execute; 
                            end
                        end
                        else begin //MOV sa 2B
                            state_next = execute;
                        end 
                    end
                    else begin
                        mem_addr = mem_in[5:0]; //mov 1B indir
                        mem_we = 1'b0;
                        state_next = execute;
                    end
                end
                4'b1111: begin //STOP
                    if(cnt_next == 4'd0) begin
                        help2 = 4'd0;
                        help2 = ir1_out[11:8];
                        if(help2 != 4'b0000) begin
                            mem_addr = {{3{1'b0}}, ir1_out[10:8]}; //procitaj podatak sa adrese 1.op
                            mem_we = 1'b0;
                            cnt_next = 4'd1;
                        end
                        else begin
                            cnt_next = 4'd2;
                        end
                    end
                    else if(cnt_next == 4'd1) begin
                        out_next = mem_in;
                        cnt_next = 4'd2;
                    end
                    else if(cnt_next == 4'd2) begin
                        help2 = 4'd0;
                        help2 = ir1_out[7:4];
                        if(help2 != 4'b0000) begin
                            mem_addr = {{3{1'b0}}, ir1_out[6:4]}; //procitaj podatak sa adrese 2.op
                            mem_we = 1'b0;
                            cnt_next = 4'd3;
                        end
                        else begin
                            cnt_next = 4'd4;
                        end
                    end
                    else if(cnt_next == 4'd3) begin
                        out_next = mem_in;
                        cnt_next = 4'd4;
                    end
                    else if(cnt_next == 4'd4) begin
                        help2 = 4'd0;
                        help2 = ir1_out[3:0];
                        if(help2 != 4'b0000) begin
                            mem_addr = {{3{1'b0}}, ir1_out[2:0]}; //procitaj podatak sa adrese 3.op
                            mem_we = 1'b0;
                            cnt_next = 4'd5;
                        end
                        else begin
                            cnt_next = 4'd0;
                            state_next = halt;
                        end
                    end
                    else if(cnt_next == 4'd5) begin
                        out_next = mem_in;
                        cnt_next = 4'd0;
                        state_next = halt;
                    end
                end
                default: ;
            endcase
        end
        execute: begin
            help = 4'd0;
            help = ir1_out[15:12];
            case (help)
                4'b0001, 4'b0010, 4'b011: begin
                    //operacija u alu
                    if(cnt_next == 4'd0) begin
                        case(help)
                            4'b0001:
                                alu_oc = 3'd0;
                            4'b0010:
                                alu_oc = 3'd1;
                            4'b0011:
                                alu_oc = 3'd2;
                            default: ;
                        endcase
                        alu_a = a_out;
                        alu_b = mem_in;
                        mem_we = 1'b1;
                        mem_addr = {{3{1'b0}}, ir1_out[10:8]};
                        mem_data = alu_f;
                        cnt_next = 4'd0;
                        state_next = fetch;
                    end
                end
                4'b0000: begin
                    help2 = 4'd0;
                    help2 = ir1_out[3:0];
                    if(help2 == 4'd0) begin //MOV sa 1B, procitan podatak iz mem
                        mem_we = 1'b1;
                        mem_addr = {{3{1'b0}}, ir1_out[10:8]}; //upis u adresu 1.op
                        mem_data = mem_in; //iz mem adr 2.op
                        cnt_next = 4'd0;
                        state_next = fetch;
                    end
                    else begin //MOV sa 2B
                        mem_we = 1'b1;
                        mem_addr = {{3{1'b0}}, ir1_out[10:8]}; //upis u adresu 1.op
                        mem_data = ir2_out; //konstanta
                        cnt_next = 4'd0;
                        state_next = fetch;
                    end
                end
                default: ;
            endcase
        end
        halt: begin
            
        end
        default: ;
    endcase
end
endmodule