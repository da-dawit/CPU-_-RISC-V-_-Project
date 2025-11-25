`timescale 1ns / 1ps

module dmem_tb;

  // Inputs
  reg         clk;
  reg         mem_wr;
  reg  [31:0] addr;
  reg  [31:0] write_data;
  
  // Outputs
  wire [31:0] read_data;
  
  // Instantiate the data memory
  dmem dut (
    .clk(clk),
    .mem_wr(mem_wr),
    .addr(addr),
    .write_data(write_data),
    .read_data(read_data)
  );
  
  // Clock generation - 10ns period (100MHz)
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end
  
  // Dump waveforms
  initial begin
    $dumpfile("dmem_tb.vcd");
    $dumpvars(0, dmem_tb);
  end
  
  // Test procedure
  initial begin
    $display("Data Memory Testbench");
    $display(">>>>>>>\n");
    
    // Initialize
    mem_wr = 0;
    addr = 0;
    write_data = 0;
    
    // Wait for a couple cycles + 1 cycle latency
    repeat(2) @(posedge clk);
    
    // Test 1: Write to address 0
    $display("Test 1: Writing to address 0");
    @(posedge clk);
    addr = 32'h00000000;
    write_data = 32'hDEADBEEF;
    mem_wr = 1;
    $display("  Writing 0x%h to addr 0x%h", write_data, addr);
    
    // Test 2: Read back from address 0
    @(posedge clk);
    mem_wr = 0;
    addr = 32'h00000000;
    $display("  Reading from addr 0x%h...", addr);
    
    @(posedge clk); // Wait for read data to appear
    @(posedge clk); // One more cycle for registered output
    $display("  Read data: 0x%h (Expected: 0xDEADBEEF)\n", read_data);
    
    // Test 3: Write to address 4 (word-aligned)
    $display("Test 2: Writing to address 4");
    @(posedge clk);
    addr = 32'h00000004;
    write_data = 32'h12345678;
    mem_wr = 1;
    $display("  Writing 0x%h to addr 0x%h", write_data, addr);
    
    @(posedge clk);
    mem_wr = 0;
    $display("  Reading from addr 0x%h...", addr);
    
    @(posedge clk);
    @(posedge clk);
    $display("  Read data: 0x%h (Expected: 0x12345678)\n", read_data);
    
    // Test 4: Write to address 8
    $display("Test 3: Writing to address 8");
    @(posedge clk);
    addr = 32'h00000008;
    write_data = 32'hCAFEBABE;
    mem_wr = 1;
    $display("  Writing 0x%h to addr 0x%h", write_data, addr);
    
    @(posedge clk);
    mem_wr = 0;
    $display("  Reading from addr 0x%h...", addr);
    
    @(posedge clk);
    @(posedge clk);
    $display("  Read data: 0x%h (Expected: 0xCAFEBABE)\n", read_data);
    
    // Test 5: Verify old data still exists (read addr 0)
    $display("Test 4: Verify data persistence at address 0");
    @(posedge clk);
    addr = 32'h00000000;
    mem_wr = 0;
    $display("  Reading from addr 0x%h...", addr);
    
    @(posedge clk);
    @(posedge clk);
    $display("  Read data: 0x%h (Expected: 0xDEADBEEF)\n", read_data);
    
    // Test 6: Verify old data at address 4
    $display("Test 5: Verify data persistence at address 4");
    @(posedge clk);
    addr = 32'h00000004;
    $display("  Reading from addr 0x%h...", addr);
    
    @(posedge clk);
    @(posedge clk);
    $display("  Read data: 0x%h (Expected: 0x12345678)\n", read_data);
    
    // Test 7: Overwrite existing data
    $display("Test 6: Overwriting address 0");
    @(posedge clk);
    addr = 32'h00000000;
    write_data = 32'hAAAAAAAA;
    mem_wr = 1;
    $display("  Writing 0x%h to addr 0x%h", write_data, addr);
    
    @(posedge clk);
    mem_wr = 0;
    $display("  Reading from addr 0x%h...", addr);
    
    @(posedge clk);
    @(posedge clk);
    $display("  Read data: 0x%h (Expected: 0xAAAAAAAA)\n", read_data);
    
    // Test 8: Test word alignment (addresses are word-indexed)
    $display("Test 7: Testing word-aligned addressing");
    @(posedge clk);
    addr = 32'h00000010;  // This maps to mem[4]
    write_data = 32'h55555555;
    mem_wr = 1;
    $display("  Writing 0x%h to addr 0x%h (mem[%d])", write_data, addr, addr[9:2]);
    
    @(posedge clk);
    mem_wr = 0;
    $display("  Reading from addr 0x%h...", addr);
    
    @(posedge clk);
    @(posedge clk);
    $display("  Read data: 0x%h (Expected: 0x55555555)\n", read_data);
    
    // Test 9: Maximum address test
    $display("Test 8: Testing near maximum address");
    @(posedge clk);
    addr = 32'h000003FC;  // Last word address (mem[255])
    write_data = 32'hFFFFFFFF;
    mem_wr = 1;
    $display("  Writing 0x%h to addr 0x%h (mem[%d])", write_data, addr, addr[9:2]);
    
    @(posedge clk);
    mem_wr = 0;
    $display("  Reading from addr 0x%h...", addr);
    
    @(posedge clk);
    @(posedge clk);
    $display("  Read data: 0x%h (Expected: 0xFFFFFFFF)\n", read_data);
    
    // Test 10: Read uninitialized memory
    $display("Test 9: Reading uninitialized memory location");
    @(posedge clk);
    addr = 32'h00000100;
    mem_wr = 0;
    $display("  Reading from addr 0x%h...", addr);
    
    @(posedge clk);
    @(posedge clk);
    $display("  Read data: 0x%h (may be x or random)\n", read_data);
    
    // Test 11: Back-to-back writes and reads
    $display("Test 10: Back-to-back operations");
    @(posedge clk);
    addr = 32'h00000020;
    write_data = 32'h99999999;
    mem_wr = 1;
    $display("  Writing 0x%h to addr 0x%h", write_data, addr);
    
    @(posedge clk);
    mem_wr = 0;
    $display("  Immediately reading from same address...");
    
    @(posedge clk);
    @(posedge clk);
    $display("  Read data: 0x%h (Expected: 0x99999999)\n", read_data);
    
    // Wait a few more cycles
    repeat(3) @(posedge clk);
    
    $display(">>>>>>>");
    $display("Data Memory Test Complete");
    $finish;
  end

endmodule