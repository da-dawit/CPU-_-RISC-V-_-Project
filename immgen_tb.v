`timescale 1ns / 1ps

module immgen_tb;

  reg  [31:0] inst;
  reg         imm_sel;
  reg  [6:0]  opcode;
  wire [31:0] imm;
  
  immgen dut (
    .inst(inst),
    .imm_sel(imm_sel),
    .opcode(opcode),
    .imm(imm)
  );
  
  initial begin
    $dumpfile("immgen_tb.vcd");
    $dumpvars(0, immgen_tb);
  end
  
  // Helper function to create B-type instruction
  function [31:0] make_btype;
    input [12:0] imm_val;  // 13-bit immediate (multiple of 2)
    input [4:0] rs2, rs1;
    input [2:0] funct3;
    begin
      make_btype = {imm_val[12], imm_val[10:5], rs2, rs1, funct3, imm_val[4:1], imm_val[11], 7'b1100011};
    end
  endfunction
  
  // Helper function to create J-type instruction
  function [31:0] make_jtype;
    input [20:0] imm_val;  // 21-bit immediate (multiple of 2)
    input [4:0] rd;
    begin
      make_jtype = {imm_val[20], imm_val[10:1], imm_val[11], imm_val[19:12], rd, 7'b1101111};
    end
  endfunction
  
  initial begin
    $display("Immediate Generator Testbench");
    $display(">>>>>>\n");
    
    // Test with imm_sel = 0
    $display("Test 1: imm_sel = 0 (disabled)");
    imm_sel = 0;
    inst = 32'hFFFFFFFF;
    opcode = 7'b0010011;
    #10;
    $display("  imm=0x%h (Expected: 0x00000000)\n", imm);
    
    imm_sel = 1;
    
    // I-type tests
    $display("Test 2: I-type ADDI x1, x2, 100");
    opcode = 7'b0010011;
    inst = {12'd100, 5'd2, 3'b000, 5'd1, 7'b0010011};
    #10;
    $display("  imm=%d (Expected: 100)\n", $signed(imm));
    
    $display("Test 3: I-type ADDI x1, x2, -1");
    opcode = 7'b0010011;
    inst = {12'hFFF, 5'd2, 3'b000, 5'd1, 7'b0010011};
    #10;
    $display("  imm=%d (Expected: -1)\n", $signed(imm));
    
    $display("Test 4: I-type LW x1, 8(x2)");
    opcode = 7'b0000011;
    inst = {12'd8, 5'd2, 3'b010, 5'd1, 7'b0000011};
    #10;
    $display("  imm=%d (Expected: 8)\n", $signed(imm));
    
    // S-type tests
    $display("Test 5: S-type SW x3, 12(x4)");
    opcode = 7'b0100011;
    inst = {7'd0, 5'd3, 5'd4, 3'b010, 5'd12, 7'b0100011};
    #10;
    $display("  imm=%d (Expected: 12)\n", $signed(imm));
    
    $display("Test 6: S-type SW x3, -4(x4)");
    opcode = 7'b0100011;
    inst = {7'h7F, 5'd3, 5'd4, 3'b010, 5'h1C, 7'b0100011};  // -4 = 0xFFC
    #10;
    $display("  imm=%d (Expected: -4)\n", $signed(imm));
    
    // B-type tests  
    $display("Test 7: B-type BEQ x5, x6, 16");
    opcode = 7'b1100011;
    inst = make_btype(13'd16, 5'd6, 5'd5, 3'b000);
    #10;
    $display("  imm=%d (Expected: 16)\n", $signed(imm));
    
    $display("Test 8: B-type BEQ x5, x6, -4");
    opcode = 7'b1100011;
    inst = make_btype(13'h1FFC, 5'd6, 5'd5, 3'b000);  // -4 in 13 bits
    #10;
    $display("  imm=%d (Expected: -4)\n", $signed(imm));
    
    $display("Test 9: B-type BEQ x5, x6, 32");
    opcode = 7'b1100011;
    inst = make_btype(13'd32, 5'd6, 5'd5, 3'b000);
    #10;
    $display("  imm=%d (Expected: 32)\n", $signed(imm));
    
    // J-type tests
    $display("Test 10: J-type JAL x1, 32");
    opcode = 7'b1101111;
    inst = make_jtype(21'd32, 5'd1);
    #10;
    $display("  imm=%d (Expected: 32)\n", $signed(imm));
    
    $display("Test 11: J-type JAL x1, -4");
    opcode = 7'b1101111;
    inst = make_jtype(21'h1FFFFC, 5'd1);  // -4 in 21 bits
    #10;
    $display("  imm=%d (Expected: -4)\n", $signed(imm));
    
    $display("Test 12: J-type JAL x1, 2048");
    opcode = 7'b1101111;
    inst = make_jtype(21'd2048, 5'd1);
    #10;
    $display("  imm=%d (Expected: 2048)\n", $signed(imm));
    
    // U-type tests
    $display("Test 13: U-type LUI x5, 0x12345");
    opcode = 7'b0110111;
    inst = {20'h12345, 5'd5, 7'b0110111};
    #10;
    $display("  imm=0x%h (Expected: 0x12345000)\n", imm);
    
    $display("Test 14: U-type AUIPC x6, 0x01000");
    opcode = 7'b0010111;
    inst = {20'h01000, 5'd6, 7'b0010111};
    #10;
    $display("  imm=0x%h (Expected: 0x01000000)\n", imm);
    
    $display("\n>>>>>>");
    $display("Immediate Generator Test Complete");
    $finish;
  end

endmodule