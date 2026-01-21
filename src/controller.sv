module controller_fsm(
  input  logic clk,
  input  logic rst_n,
  input  logic [6:0] opcode,
  input  logic [2:0] funct3,
  input  logic [6:0] funct7,
  input  logic       zero,

  output logic ir_write,
  output logic pc_write,
  output logic pc_write_cond,
  output logic reg_write,
  output logic mem_write,
  output logic mdr_write,
  output logic a_write,
  output logic b_write,
  output logic aluout_write,
  output logic [1:0] alu_src_a,
  output logic [1:0] alu_src_b,
  output logic [1:0] pc_src,
  output logic [1:0] wd_src,
  output logic [3:0] alu_ctrl
);

  localparam [6:0] OP_RTYPE  = 7'b0110011;
  localparam [6:0] OP_ITYPE  = 7'b0010011;
  localparam [6:0] OP_LOAD   = 7'b0000011;
  localparam [6:0] OP_STORE  = 7'b0100011;
  localparam [6:0] OP_BRANCH = 7'b1100011;

  localparam [2:0] F3_ADD_SUB = 3'b000;
  localparam [2:0] F3_AND     = 3'b111;
  localparam [2:0] F3_OR      = 3'b110;

  localparam [6:0] F7_SUB     = 7'b0100000;
  localparam [6:0] OP_JAL = 7'b1101111;
  localparam ALU_ADD = 4'd0;
  localparam ALU_SUB = 4'd1;
  localparam ALU_AND = 4'd2;
  localparam ALU_OR  = 4'd3;

  typedef enum logic [3:0] {
    FETCH, DECODE, MEMADR, MEMRD, MEMWB,
    MEMWR, RTYPEEX, RTYPEWB,
    BEQEX, ADDIEX, ADDIWB
  } state_t;

  state_t state, next;

  always_comb begin
    ir_write=0; pc_write=0; pc_write_cond=0; 
    reg_write=0; mem_write=0; 
    mdr_write=0; a_write=0; b_write=0; aluout_write=0;
    alu_src_a=0; alu_src_b=0; pc_src=0; wd_src=0; 
    alu_ctrl=ALU_ADD;
    next = state;
    
    // STATES
    case (state)
      FETCH: begin
        ir_write = 1; pc_write = 1; alu_src_b = 2'd1; next = DECODE;
      end
      DECODE: begin
        a_write = 1; b_write = 1; alu_src_b = 2'd2; aluout_write = 1;
        case (opcode)
          OP_LOAD, OP_STORE: next = MEMADR;
          OP_RTYPE:          next = RTYPEEX;
          OP_BRANCH:         next = BEQEX;
          OP_ITYPE:          next = ADDIEX;
          default:           next = FETCH;
        endcase
      end
      MEMADR: begin
        alu_src_a = 2'd1; alu_src_b = 2'd2; aluout_write = 1;
        next = (opcode == OP_LOAD) ? MEMRD : MEMWR;
      end
      MEMRD: begin
        mdr_write = 1; next = MEMWB;
      end
      MEMWB: begin
        reg_write = 1; wd_src = 2'd1; next = FETCH;
      end
      MEMWR: begin
        mem_write = 1; next = FETCH;
      end
      RTYPEEX: begin
        alu_src_a = 2'd1;
        if (funct3 == F3_ADD_SUB) alu_ctrl = (funct7 == F7_SUB) ? ALU_SUB : ALU_ADD;
        else if (funct3 == F3_AND) alu_ctrl = ALU_AND;
        else if (funct3 == F3_OR)  alu_ctrl = ALU_OR;
        aluout_write = 1; next = RTYPEWB;
      end
      RTYPEWB: begin
        reg_write = 1; next = FETCH;
      end
      BEQEX: begin
        alu_src_a = 2'd1; alu_ctrl = ALU_SUB; pc_write_cond = 1; pc_src = 2'd1; next = FETCH;
      end
      ADDIEX: begin
        alu_src_a = 2'd1; alu_src_b = 2'd2; aluout_write = 1; next = ADDIWB;
      end
      ADDIWB: begin
        reg_write = 1; next = FETCH;
      end
    endcase
  end

  always_ff @(posedge clk or negedge rst_n)
    if (!rst_n) state <= FETCH;
    else state <= next;
endmodule
