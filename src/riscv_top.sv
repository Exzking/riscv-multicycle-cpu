module riscv_top(
  input logic clk,
  input logic rst_n
);
  logic [31:0] PC, IR, MDR, A, B, ALUOut;
  logic [31:0] imem_d, dmem_d;
  logic [31:0] rf_a, rf_b;
  logic [31:0] imm_i, imm_s, imm_b;
  logic [31:0] alu_a, alu_b, alu_y;
  logic zero;

  logic [6:0] opcode;
  logic [2:0] funct3;
  logic [6:0] funct7;
  logic [4:0] rs1, rs2, rd;

  assign opcode = IR[6:0];
  assign rd     = IR[11:7];
  assign funct3 = IR[14:12];
  assign rs1    = IR[19:15];
  assign rs2    = IR[24:20];
  assign funct7 = IR[31:25];

  logic ir_write, pc_write, pc_write_cond;
  logic reg_write, mem_write, mdr_write, a_write, b_write, aluout_write;
  logic [1:0] alu_src_a, alu_src_b, pc_src, wd_src;
  logic [3:0] alu_ctrl;
  logic [31:0] wd;
  
  imem IM(.addr(PC), .rdata(imem_d));
  dmem DM(.clk(clk), .we(mem_write), .addr(ALUOut), .wdata(B), .rdata(dmem_d));
  regfile RF(.clk(clk), .we(reg_write), .rs1(rs1), .rs2(rs2), 
             .rd(rd), .wd(wd), .rd1(rf_a), .rd2(rf_b));
  imm_gen IG(.instr(IR), .imm_i(imm_i), .imm_s(imm_s), .imm_b(imm_b));
  alu AL(.a(alu_a), .b(alu_b), .ctrl(alu_ctrl), .y(alu_y), .zero(zero));
  controller_fsm CTRL(.*);

  assign alu_a = (alu_src_a == 0) ? PC : A;

  // ALU MUX
  always_comb begin
    case (alu_src_b)
      2'd0: alu_b = B;      
      2'd1: alu_b = 32'd4;  
      2'd2: begin           
        if (opcode == 7'b0100011)      alu_b = imm_s; 
        else if (opcode == 7'b1100011) alu_b = imm_b; 
        else                           alu_b = imm_i; 
      end
      default: alu_b = 32'b0;
    endcase
  end

  assign wd = (wd_src == 1) ? MDR : ALUOut;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      PC<=0; IR<=0; MDR<=0; A<=0; B<=0; ALUOut<=0;
    end else begin
      if (ir_write) IR <= imem_d;
      if (pc_write || (pc_write_cond && zero))
        PC <= (pc_src == 1) ? ALUOut : alu_y;
      if (a_write) A <= rf_a;
      if (b_write) B <= rf_b;
      if (aluout_write) ALUOut <= alu_y;
      if (mdr_write) MDR <= dmem_d;
    end
  end

  task load_program(string f);
    IM.load_hex(f);
  endtask
endmodule
