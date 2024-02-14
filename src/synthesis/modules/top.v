module top #(
    parameter DIVISOR = 50_000_000,
    parameter FILE_NAME = "mem_init.mif",
    parameter ADDR_WIDTH = 6,
    parameter DATA_WIDTH = 16
) (
    input clk,
    input rst_n,
    input [2:0] btn,
    input [8:0] sw,
    output [9:0] led,
    output [27:0] hex
);

wire clk_sl;
clk_div #(.DIVISOR(DIVISOR)) clk_div_dut (
    .clk(clk),
	.rst_n(rst_n),
	.out(clk_sl)
);

wire mem_we;
wire [ADDR_WIDTH-1:0] mem_addr;
wire [DATA_WIDTH-1:0] mem_data;
wire [DATA_WIDTH-1:0] mem_out;
wire [ADDR_WIDTH-1:0] pc, sp;

wire [DATA_WIDTH-1:0] cpu_out;

assign led[4:0] = cpu_out[4:0];
memory memory_dut(.clk(clk_sl),.we(mem_we),.addr(mem_addr),.data(mem_data),.out(mem_out));

wire[3:0] tens_sp, ones_sp;
wire[3:0] tens_pc, ones_pc;

bcd bcd_sp_dut(.in(sp), .tens(tens_sp), .ones(ones_sp));
bcd bcd_pc_dut(.in(pc), .tens(tens_pc), .ones(ones_pc));

ssd ssd_tens_sp_dut (.in(tens_sp), .out(hex[27:21]));
ssd ssd_ones_sp_dut (.in(ones_sp), .out(hex[20:14]));
ssd ssd_tens_pc_dut (.in(tens_pc), .out(hex[13:7]));
ssd ssd_ones_pc_dut (.in(ones_pc), .out(hex[6:0]));

cpu #(ADDR_WIDTH, DATA_WIDTH) cpu_dut (
    .clk(clk_sl),
    .rst_n(rst_n),
    .mem_in(mem_out),
    .in({{(DATA_WIDTH-4){1'b0}},sw[3:0]}),
    .mem_we(mem_we),
    .mem_addr(mem_addr),
    .mem_data(mem_data),
    .out(cpu_out),
    .pc(pc),
    .sp(sp)
);

    
endmodule