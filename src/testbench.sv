`timescale 1ns / 1ps
module tb_riscv;
  logic clk;
  logic rst_n;
    riscv _top dut(
    .clk(clk),
    .rst_n(rst_n)
  );
  always #5 clk = ~clk;
    initial begin
    clk = 0;
    rst_n = 0;
  begin
    integer f;
    f = $fopen("program.hex", "w");
      $fdisplay(f, "00500093"); // ADDI x1, x0, 5
      $fdisplay(f, "00700113"); // ADDI x2, x0, 7
      $fdisplay(f, "002081b3"); // ADD x3, x1, x2 -> 12
      $fdisplay(f, "00302823"); // SW x3, 16(x0)
      $fdisplay(f, "01002203"); // LW x4, 16(x0) -> 12
      $fdisplay(f, "fe000ce3"); // BEQ LOOP
      $fclose(f);
    end
    dut.load_program("program.hex");
    #20;
    rst_n = 1;
    #600;
// SELF-CHECK TB
    if (dut.RF.regs[3] === 32'd12 && dut.RF.regs[4] === 32'd12) begin
        $display("\n");
        $display("* SUCCESS *");
        $display("* x3 = %0d (EXPECTED: 12) *", dut.RF.regs[3]);
        $display("* x4 = %0d (EXPECTED: 12) *", dut.RF.regs[4]);
        $display("\n");
    end else begin
        $display("\n");
        $display("! FAILED !");
        $display("! EXPECTED: 12 !");
        $display("! READ x3: %0d, x4: %0d !", dut.RF.regs[3], dut.RF.regs[4]);
        $display("\n");
    end
    $finish;
  end
    always @(posedge clk) begin
    if (rst_n) begin
    end
  end
endmodule
