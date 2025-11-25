`timescale 1ns / 1ps

module bc_tb;

  // Inputs
  reg  [31:0] d1;
  reg  [31:0] d2;
  reg  br_un;
  
  // Outputs
  wire br_eq;
  wire br_l;
  
  // Instantiate the branch comparator
  bc dut (
    .d1(d1),
    .d2(d2),
    .br_un(br_un),
    .br_eq(br_eq),
    .br_l(br_l)
  );
  
  // Dump waveforms
  initial begin
    $dumpfile("bc_tb.vcd");
    $dumpvars(0, bc_tb);
  end
  
  // Test cases
  initial begin
    $display("Branch Comparator Testbench");
    $display(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n");
    
    // Test 1: Equal values
    $display("Test 1: Equal values");
    d1 = 32'd100; d2 = 32'd100; br_un = 0;
    #10;
    $display("  d1=%d, d2=%d, signed   -> eq=%b, lt=%b (Expected: eq=1, lt=0)", d1, d2, br_eq, br_l);
    
    d1 = 32'd100; d2 = 32'd100; br_un = 1;
    #10;
    $display("  d1=%d, d2=%d, unsigned -> eq=%b, lt=%b (Expected: eq=1, lt=0)\n", d1, d2, br_eq, br_l);
    
    // Test 2: d1 > d2 (positive numbers)
    $display("Test 2: d1 > d2 (positive)");
    d1 = 32'd200; d2 = 32'd50; br_un = 0;
    #10;
    $display("  d1=%d, d2=%d, signed   -> eq=%b, lt=%b (Expected: eq=0, lt=0)", d1, d2, br_eq, br_l);
    
    d1 = 32'd200; d2 = 32'd50; br_un = 1;
    #10;
    $display("  d1=%d, d2=%d, unsigned -> eq=%b, lt=%b (Expected: eq=0, lt=0)\n", d1, d2, br_eq, br_l);
    
    // Test 3: d1 < d2 (positive numbers)
    $display("Test 3: d1 < d2 (positive)");
    d1 = 32'd50; d2 = 32'd200; br_un = 0;
    #10;
    $display("  d1=%d, d2=%d, signed   -> eq=%b, lt=%b (Expected: eq=0, lt=1)", d1, d2, br_eq, br_l);
    
    d1 = 32'd50; d2 = 32'd200; br_un = 1;
    #10;
    $display("  d1=%d, d2=%d, unsigned -> eq=%b, lt=%b (Expected: eq=0, lt=1)\n", d1, d2, br_eq, br_l);
    
    // Test 4: Signed comparison with negative numbers
    $display("Test 4: Negative vs positive (signed)");
    d1 = -32'd10; d2 = 32'd5; br_un = 0;
    #10;
    $display("  d1=%d, d2=%d, signed   -> eq=%b, lt=%b (Expected: eq=0, lt=1)", $signed(d1), d2, br_eq, br_l);
    
    d1 = 32'd5; d2 = -32'd10; br_un = 0;
    #10;
    $display("  d1=%d, d2=%d, signed   -> eq=%b, lt=%b (Expected: eq=0, lt=0)\n", d1, $signed(d2), br_eq, br_l);
    
    // Test 5: Both negative (signed)
    $display("Test 5: Both negative (signed)");
    d1 = -32'd100; d2 = -32'd50; br_un = 0;
    #10;
    $display("  d1=%d, d2=%d, signed   -> eq=%b, lt=%b (Expected: eq=0, lt=1)", $signed(d1), $signed(d2), br_eq, br_l);
    
    d1 = -32'd50; d2 = -32'd100; br_un = 0;
    #10;
    $display("  d1=%d, d2=%d, signed   -> eq=%b, lt=%b (Expected: eq=0, lt=0)\n", $signed(d1), $signed(d2), br_eq, br_l);
    
    // Test 6: Unsigned comparison with large values
    $display("Test 6: Unsigned comparison (0xFFFFFFFF)");
    d1 = 32'hFFFFFFFF; d2 = 32'd1; br_un = 1;
    #10;
    $display("  d1=0x%h, d2=%d, unsigned -> eq=%b, lt=%b (Expected: eq=0, lt=0)", d1, d2, br_eq, br_l);
    
    d1 = 32'd1; d2 = 32'hFFFFFFFF; br_un = 1;
    #10;
    $display("  d1=%d, d2=0x%h, unsigned -> eq=%b, lt=%b (Expected: eq=0, lt=1)\n", d1, d2, br_eq, br_l);
    
    // Test 7: Same values as Test 6 but signed
    $display("Test 7: Signed comparison (0xFFFFFFFF = -1)");
    d1 = 32'hFFFFFFFF; d2 = 32'd1; br_un = 0;
    #10;
    $display("  d1=%d, d2=%d, signed   -> eq=%b, lt=%b (Expected: eq=0, lt=1)", $signed(d1), d2, br_eq, br_l);
    
    d1 = 32'd1; d2 = 32'hFFFFFFFF; br_un = 0;
    #10;
    $display("  d1=%d, d2=%d, signed   -> eq=%b, lt=%b (Expected: eq=0, lt=0)\n", d1, $signed(d2), br_eq, br_l);
    
    // Test 8: Edge case - zero
    $display("Test 8: Zero comparisons");
    d1 = 32'd0; d2 = 32'd0; br_un = 0;
    #10;
    $display("  d1=%d, d2=%d, signed   -> eq=%b, lt=%b (Expected: eq=1, lt=0)", d1, d2, br_eq, br_l);
    
    d1 = 32'd0; d2 = 32'd5; br_un = 0;
    #10;
    $display("  d1=%d, d2=%d, signed   -> eq=%b, lt=%b (Expected: eq=0, lt=1)", d1, d2, br_eq, br_l);
    
    d1 = -32'd5; d2 = 32'd0; br_un = 0;
    #10;
    $display("  d1=%d, d2=%d, signed   -> eq=%b, lt=%b (Expected: eq=0, lt=1)\n", $signed(d1), d2, br_eq, br_l);
    
    $display(">>>>>>>>>>>>>>>>>>>>>");
    $display("Branch Comparator Test Complete");
    $finish;
  end

endmodule