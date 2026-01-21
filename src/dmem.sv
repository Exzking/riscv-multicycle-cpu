module dmem(
  input  logic        clk,
  input  logic        we,
  input  logic [31:0] addr,
  input  logic [31:0] wdata,
  output logic [31:0] rdata
);
  logic [31:0] mem [0:255];
  assign rdata = mem[addr[31:2]];

  always_ff @(posedge clk)
    if (we)
      mem[addr[31:2]] <= wdata;
endmodule
