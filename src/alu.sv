module alu(
  input  logic [31:0] a, b,
  input  logic [3:0]  ctrl,
  output logic [31:0] y,
  output logic        zero);
  
  localparam ALU_ADD = 4'd0;
  localparam ALU_SUB = 4'd1;
  localparam ALU_AND = 4'd2;
  localparam ALU_OR  = 4'd3;

  always_comb begin
    case (ctrl)
      ALU_ADD: y = a + b;
      ALU_SUB: y = a - b;
      ALU_AND: y = a & b;
      ALU_OR : y = a | b;
      default: y = 32'b0;
    endcase
  end

  assign zero = (y == 32'b0);
endmodule
