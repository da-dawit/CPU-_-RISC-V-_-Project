`timescale 1ns / 1ps

module alu_tb;

  //sigs
  reg  [31:0] operand_a;
  reg  [31:0] operand_b;
  reg  [3:0]  alu_ctrl;
  wire [31:0] result;
  wire zero;
  
  localparam ALU_ADD  = 4'b0000;
  localparam ALU_SUB  = 4'b0001;
  localparam ALU_AND  = 4'b0010;
  localparam ALU_OR   = 4'b0011;
  localparam ALU_XOR  = 4'b0100;
  localparam ALU_SLT  = 4'b0101;
  localparam ALU_SLTU = 4'b0110;
  localparam ALU_SLL  = 4'b0111;
  localparam ALU_SRL  = 4'b1000;
  localparam ALU_SRA  = 4'b1001;
  
  //alu
  alu dut (
    .operand_a(operand_a),
    .operand_b(operand_b),
    .alu_ctrl(alu_ctrl),
    .result(result),
    .zero(zero)
  );

  //dump files are necessary
  initial begin
    $dumpfile("alu_tb.vcd");
    $dumpvars(0, alu_tb);
  end
  
  initial begin
    $display("Starting ALU Testbench>>>>");
    
    // Test ADD operation
    $display("\nTesting ADD operation:");
    operand_a = 32'd15; operand_b = 32'd10; alu_ctrl = ALU_ADD;
    #10;
    $display("  %d + %d = %d (Expected: 25)", operand_a, operand_b, result);
    
    operand_a = 32'hFFFFFFFF; operand_b = 32'd1; alu_ctrl = ALU_ADD;
    #10;
    $display("  0x%h + %d = 0x%h (Expected: 0, overflow)", operand_a, operand_b, result);
    
    // Test SUB operation
    $display("\nTesting SUB operation:");
    operand_a = 32'd20; operand_b = 32'd5; alu_ctrl = ALU_SUB;
    #10;
    $display("  %d - %d = %d (Expected: 15)", operand_a, operand_b, result);
    
    operand_a = 32'd5; operand_b = 32'd5; alu_ctrl = ALU_SUB;
    #10;
    $display("  %d - %d = %d, zero = %b (Expected: 0, zero = 1)", operand_a, operand_b, result, zero);
    
    // Test AND operation
    $display("\nTesting AND operation:");
    operand_a = 32'hF0F0F0F0; operand_b = 32'h0F0F0F0F; alu_ctrl = ALU_AND;
    #10;
    $display("  0x%h & 0x%h = 0x%h (Expected: 0x00000000)", operand_a, operand_b, result);
    
    operand_a = 32'hFFFFFFFF; operand_b = 32'h12345678; alu_ctrl = ALU_AND;
    #10;
    $display("  0x%h & 0x%h = 0x%h (Expected: 0x12345678)", operand_a, operand_b, result);
    
    // Test OR operation
    $display("\nTesting OR operation:");
    operand_a = 32'hF0F0F0F0; operand_b = 32'h0F0F0F0F; alu_ctrl = ALU_OR;
    #10;
    $display("  0x%h | 0x%h = 0x%h (Expected: 0xFFFFFFFF)", operand_a, operand_b, result);
    
    // Test XOR operation
    $display("\nTesting XOR operation:");
    operand_a = 32'hAAAAAAAA; operand_b = 32'h55555555; alu_ctrl = ALU_XOR;
    #10;
    $display("  0x%h ^ 0x%h = 0x%h (Expected: 0xFFFFFFFF)", operand_a, operand_b, result);
    
    // Test SLT (Set Less Than - signed)
    $display("\nTesting SLT operation:");
    operand_a = 32'd10; operand_b = 32'd20; alu_ctrl = ALU_SLT;
    #10;
    $display("  %d < %d = %d (Expected: 1)", $signed(operand_a), $signed(operand_b), result);
    
    operand_a = 32'd20; operand_b = 32'd10; alu_ctrl = ALU_SLT;
    #10;
    $display("  %d < %d = %d (Expected: 0)", $signed(operand_a), $signed(operand_b), result);
    
    operand_a = -32'd5; operand_b = 32'd10; alu_ctrl = ALU_SLT;
    #10;
    $display("  %d < %d = %d (Expected: 1)", $signed(operand_a), $signed(operand_b), result);
    
    // Test SLTU (Set Less Than Unsigned)
    $display("\nTesting SLTU operation:");
    operand_a = 32'd10; operand_b = 32'd20; alu_ctrl = ALU_SLTU;
    #10;
    $display("  %d < %d = %d (unsigned, Expected: 1)", operand_a, operand_b, result);
    
    operand_a = 32'hFFFFFFFF; operand_b = 32'd1; alu_ctrl = ALU_SLTU;
    #10;
    $display("  0x%h < %d = %d (unsigned, Expected: 0)", operand_a, operand_b, result);
    
    // Test SLL (Shift Left Logical)
    $display("\nTesting SLL operation:");
    operand_a = 32'h00000001; operand_b = 32'd4; alu_ctrl = ALU_SLL;
    #10;
    $display("  0x%h << %d = 0x%h (Expected: 0x00000010)", operand_a, operand_b[4:0], result);
    
    operand_a = 32'hAAAAAAAA; operand_b = 32'd1; alu_ctrl = ALU_SLL;
    #10;
    $display("  0x%h << %d = 0x%h (Expected: 0x55555554)", operand_a, operand_b[4:0], result);
    
    // Test SRL (Shift Right Logical)
    $display("\nTesting SRL operation:");
    operand_a = 32'h80000000; operand_b = 32'd4; alu_ctrl = ALU_SRL;
    #10;
    $display("  0x%h >> %d = 0x%h (logical, Expected: 0x08000000)", operand_a, operand_b[4:0], result);
    
    // Test SRA (Shift Right Arithmetic)
    $display("\nTesting SRA operation:");
    operand_a = 32'h80000000; operand_b = 32'd4; alu_ctrl = ALU_SRA;
    #10;
    $display("  0x%h >>> %d = 0x%h (arithmetic, Expected: 0xF8000000)", operand_a, operand_b[4:0], result);
    
    operand_a = 32'h40000000; operand_b = 32'd4; alu_ctrl = ALU_SRA;
    #10;
    $display("  0x%h >>> %d = 0x%h (arithmetic, Expected: 0x04000000)", operand_a, operand_b[4:0], result);
    
    // Test default case
    $display("\nTesting default operation:");
    operand_a = 32'd100; operand_b = 32'd50; alu_ctrl = 4'b1111;
    #10;
    $display("  Invalid operation (ctrl=0x%h) = %d (Expected: 0)", alu_ctrl, result);
    
    $display("\n>>>>>>>>>>>>>>>>>>>>");
    $display("ALU Testbench Complete");
    $finish;
  end
  
  //see changes
  initial begin
    $monitor("Time=%0t | A=0x%h | B=0x%h | Ctrl=%b | Result=0x%h | Zero=%b", 
             $time, operand_a, operand_b, alu_ctrl, result, zero);
  end

endmodule