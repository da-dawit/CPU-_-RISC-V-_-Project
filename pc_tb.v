`timescale 1ns / 1ps

module pc_tb;

  // Inputs
  reg         clk;
  reg         reset;
  reg         pc_sel;
  reg  [31:0] alu_out;
  
  // Outputs
  wire [31:0] pc;
  
  // Instantiate the PC
  pc dut (
    .clk(clk),
    .reset(reset),
    .pc_sel(pc_sel),
    .alu_out(alu_out),
    .pc(pc)
  );
  
  // Clock generation
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end
  
  // Dump waveforms
  initial begin
    $dumpfile("pc_tb.vcd");
    $dumpvars(0, pc_tb);
  end
  
  // Test procedure
  initial begin
    $display("Program Counter Testbench");
    $display("=========================\n");
    
    // Test 1: Reset
    $display("Test 1: Reset");
    reset = 1;
    pc_sel = 0;
    alu_out = 32'hDEADBEEF;
    #10;
    @(posedge clk);
    #1;
    $display("  After reset: PC = 0x%h (Expected: 0x00000000)\n", pc);
    
    // Release reset
    reset = 0;
    
    // Test 2: Sequential execution (PC + 4)
    $display("Test 2: Sequential execution");
    pc_sel = 0;
    alu_out = 32'h12345678;
    
    repeat(5) begin
      @(posedge clk);
      #1;
      $display("  PC = 0x%h", pc);
    end
    $display("  (Expected: 0x00, 0x04, 0x08, 0x0C, 0x10)\n");
    
    // Test 3: Branch/Jump (use ALU output)
    $display("Test 3: Branch to 0x00001000");
    @(posedge clk);
    pc_sel = 1;
    alu_out = 32'h00001000;
    @(posedge clk);
    #1;
    $display("  PC = 0x%h (Expected: 0x00001000)\n", pc);
    
    // Test 4: Continue sequential from new address
    $display("Test 4: Continue sequential from 0x1000");
    pc_sel = 0;
    repeat(3) begin
      @(posedge clk);
      #1;
      $display("  PC = 0x%h", pc);
    end
    $display("  (Expected: 0x1004, 0x1008, 0x100C)\n");
    
    // Test 5: Jump backward
    $display("Test 5: Jump backward to 0x00000100");
    @(posedge clk);
    pc_sel = 1;
    alu_out = 32'h00000100;
    @(posedge clk);
    #1;
    $display("  PC = 0x%h (Expected: 0x00000100)\n", pc);
    
    // Test 6: Sequential from new address
    $display("Test 6: Sequential from 0x100");
    pc_sel = 0;
    repeat(3) begin
      @(posedge clk);
      #1;
      $display("  PC = 0x%h", pc);
    end
    $display("  (Expected: 0x104, 0x108, 0x10C)\n");
    
    // Test 7: Jump to odd address (misaligned)
    $display("Test 7: Jump to misaligned address 0x00000203");
    @(posedge clk);
    pc_sel = 1;
    alu_out = 32'h00000203;
    @(posedge clk);
    #1;
    $display("  PC = 0x%h (Note: misaligned address)\n", pc);
    
    // Test 8: Multiple consecutive branches
    $display("Test 8: Consecutive branches");
    @(posedge clk);
    pc_sel = 1;
    alu_out = 32'h00002000;
    @(posedge clk);
    #1;
    $display("  PC = 0x%h", pc);
    
    @(posedge clk);
    pc_sel = 1;
    alu_out = 32'h00003000;
    @(posedge clk);
    #1;
    $display("  PC = 0x%h", pc);
    
    @(posedge clk);
    pc_sel = 1;
    alu_out = 32'h00004000;
    @(posedge clk);
    #1;
    $display("  PC = 0x%h (Expected: 0x2000, 0x3000, 0x4000)\n", pc);
    
    // Test 9: Reset during execution
    $display("Test 9: Reset during execution");
    pc_sel = 0;
    @(posedge clk);
    @(posedge clk);
    #1;
    $display("  Before reset: PC = 0x%h", pc);
    
    reset = 1;
    @(posedge clk);
    #1;
    $display("  After reset: PC = 0x%h (Expected: 0x00000000)\n", pc);
    
    reset = 0;
    
    // Test 10: pc_sel toggling
    $display("Test 10: Rapid pc_sel changes");
    pc_sel = 0;
    @(posedge clk);
    #1;
    $display("  Sequential: PC = 0x%h", pc);
    
    @(posedge clk);
    pc_sel = 1;
    alu_out = 32'h00005000;
    @(posedge clk);
    #1;
    $display("  Branch: PC = 0x%h", pc);
    
    @(posedge clk);
    pc_sel = 0;
    @(posedge clk);
    #1;
    $display("  Sequential: PC = 0x%h (Expected: 0x5004)\n", pc);
    
    // Wait a few more cycles
    repeat(3) @(posedge clk);
    
    $display("=========================");
    $display("Program Counter Test Complete");
    $finish;
  end
  
  // Monitor
  initial begin
    $monitor("Time=%0t | clk=%b | reset=%b | pc_sel=%b | alu_out=0x%h | pc=0x%h",
             $time, clk, reset, pc_sel, alu_out, pc);
  end

endmodule