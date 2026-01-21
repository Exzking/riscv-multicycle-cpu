// INSTRUCTION MEM
module imem(
  input  logic [31:0] addr,
  output logic [31:0] rdata
);
  logic [31:0] mem [0:255]; 
  assign rdata = mem[addr[31:2]];

  task load_hex(string file);
    $readmemh(file, mem);
  endtask
endmodule
