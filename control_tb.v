`timescale 1ns / 1ps

module control_tb;

  // Inputs
  reg  [31:0] inst;
  reg         br_eq;
  reg         br_l;
  
  // Outputs
  wire [6:0]  opcode;
  wire [4:0]  rd;
  wire [4:0]  rs1;
  wire [4:0]  rs2;
  wire [2:0]  funct3;
  wire [6:0]  funct7;
  wire        pc_sel;
  wire        reg_write_en;
  wire        imm_sel;
  wire        br_un;
  wire        b_sel;
  wire        a_sel;
  wire [3:0]  alu_sel;
  wire        mem_wr;
  wire [1:0]  wb_sel;
  
  // Instantiate control unit
  control dut (
    .inst(inst),
    .br_eq(br_eq),
    .br_l(br_l),
    .opcode(opcode),
    .rd(rd),
    .rs1(rs1),
    .rs2(rs2),
    .funct3(funct3),
    .funct7(funct7),
    .pc_sel(pc_sel),
    .reg_write_en(reg_write_en),
    .imm_sel(imm_sel),
    .br_un(br_un),
    .b_sel(b_sel),
    .a_sel(a_sel),
    .alu_sel(alu_sel),
    .mem_wr(mem_wr),
    .wb_sel(wb_sel)
  );
  
  // Dump waveforms
  initial begin
    $dumpfile("control_tb.vcd");
    $dumpvars(0, control_tb);
  end
  
  // Helper task to display control signals
  task display_signals;
    input [80*8:1] test_name;
    begin
      $display("  %s", test_name);
      $display("    Instruction fields: opcode=%b rd=%d rs1=%d rs2=%d funct3=%b funct7=%b",
               opcode, rd, rs1, rs2, funct3, funct7);
      $display("    Control signals: pc_sel=%b reg_wr=%b imm_sel=%b br_un=%b",
               pc_sel, reg_write_en, imm_sel, br_un);
      $display("    ALU/MEM: a_sel=%b b_sel=%b alu_sel=%b mem_wr=%b wb_sel=%b",
               a_sel, b_sel, alu_sel, mem_wr, wb_sel);
    end
  endtask
  
  initial begin
    $display("Control Unit Testbench");
    $display(">>>>>>>>>>>>>>>>>>>>\n");
    
    // Initialize branch comparator inputs
    br_eq = 0;
    br_l = 0;
    
    //  R-TYPE INSTRUCTIONS 
    $display("--- R-TYPE Instructions ---");
    
    // ADD: add x1, x2, x3
    inst = 32'b0000000_00011_00010_000_00001_0110011;
    #10;
    display_signals("ADD x1, x2, x3");
    $display("");
    
    // SUB: sub x4, x5, x6
    inst = 32'b0100000_00110_00101_000_00100_0110011;
    #10;
    display_signals("SUB x4, x5, x6");
    $display("");
    
    // XOR: xor x7, x8, x9
    inst = 32'b0000000_01001_01000_100_00111_0110011;
    #10;
    display_signals("XOR x7, x8, x9");
    $display("");
    
    // OR: or x10, x11, x12
    inst = 32'b0000000_01100_01011_110_01010_0110011;
    #10;
    display_signals("OR x10, x11, x12");
    $display("");
    
    // AND: and x13, x14, x15
    inst = 32'b0000000_01111_01110_111_01101_0110011;
    #10;
    display_signals("AND x13, x14, x15");
    $display("");
    
    // SLL: sll x16, x17, x18
    inst = 32'b0000000_10010_10001_001_10000_0110011;
    #10;
    display_signals("SLL x16, x17, x18");
    $display("");
    
    // SRL: srl x19, x20, x21
    inst = 32'b0000000_10101_10100_101_10011_0110011;
    #10;
    display_signals("SRL x19, x20, x21");
    $display("");
    
    // SRA: sra x22, x23, x24
    inst = 32'b0100000_11000_10111_101_10110_0110011;
    #10;
    display_signals("SRA x22, x23, x24");
    $display("");
    
    // SLT: slt x25, x26, x27
    inst = 32'b0000000_11011_11010_010_11001_0110011;
    #10;
    display_signals("SLT x25, x26, x27");
    $display("");
    
    // SLTU: sltu x28, x29, x30
    inst = 32'b0000000_11110_11101_011_11100_0110011;
    #10;
    display_signals("SLTU x28, x29, x30");
    $display("");
    
    //  I-TYPE INSTRUCTIONS 
    $display("--- I-TYPE Instructions (Immediate) ---");
    
    // ADDI: addi x1, x2, 100
    inst = 32'b000001100100_00010_000_00001_0010011;
    #10;
    display_signals("ADDI x1, x2, 100");
    $display("");
    
    // XORI: xori x3, x4, -1
    inst = 32'b111111111111_00100_100_00011_0010011;
    #10;
    display_signals("XORI x3, x4, -1");
    $display("");
    
    // ORI: ori x5, x6, 0xFF
    inst = 32'b000011111111_00110_110_00101_0010011;
    #10;
    display_signals("ORI x5, x6, 0xFF");
    $display("");
    
    // ANDI: andi x7, x8, 0xF0
    inst = 32'b000011110000_01000_111_00111_0010011;
    #10;
    display_signals("ANDI x7, x8, 0xF0");
    $display("");
    
    // SLLI: slli x9, x10, 4
    inst = 32'b0000000_00100_01010_001_01001_0010011;
    #10;
    display_signals("SLLI x9, x10, 4");
    $display("");
    
    // SRLI: srli x11, x12, 2
    inst = 32'b0000000_00010_01100_101_01011_0010011;
    #10;
    display_signals("SRLI x11, x12, 2");
    $display("");
    
    // SRAI: srai x13, x14, 3
    inst = 32'b0100000_00011_01110_101_01101_0010011;
    #10;
    display_signals("SRAI x13, x14, 3");
    $display("");
    
    // SLTI: slti x15, x16, -10
    inst = 32'b111111110110_10000_010_01111_0010011;
    #10;
    display_signals("SLTI x15, x16, -10");
    $display("");
    
    // SLTIU: sltiu x17, x18, 20
    inst = 32'b000000010100_10010_011_10001_0010011;
    #10;
    display_signals("SLTIU x17, x18, 20");
    $display("");
    
    //  LOAD INSTRUCTIONS 
    $display("--- LOAD Instructions ---");
    
    // LW: lw x1, 8(x2)
    inst = 32'b000000001000_00010_010_00001_0000011;
    #10;
    display_signals("LW x1, 8(x2)");
    $display("");
    
    //  STORE INSTRUCTIONS 
    $display("--- STORE Instructions ---");
    
    // SW: sw x3, 12(x4)
    inst = 32'b0000000_00011_00100_010_01100_0100011;
    #10;
    display_signals("SW x3, 12(x4)");
    $display("");
    
    //  BRANCH INSTRUCTIONS 
    $display("--- BRANCH Instructions ---");
    
    // BEQ taken
    $display("  BEQ x5, x6, offset (taken)");
    inst = 32'b0_000010_00110_00101_000_0100_0_1100011;
    br_eq = 1; br_l = 0;
    #10;
    $display("    br_eq=%b br_l=%b -> pc_sel=%b (Expected: 1)", br_eq, br_l, pc_sel);
    $display("");
    
    // BEQ not taken
    $display("  BEQ x5, x6, offset (not taken)");
    inst = 32'b0_000010_00110_00101_000_0100_0_1100011;
    br_eq = 0; br_l = 0;
    #10;
    $display("    br_eq=%b br_l=%b -> pc_sel=%b (Expected: 0)", br_eq, br_l, pc_sel);
    $display("");
    
    // BNE taken
    $display("  BNE x7, x8, offset (taken)");
    inst = 32'b0_000010_01000_00111_001_0100_0_1100011;
    br_eq = 0; br_l = 0;
    #10;
    $display("    br_eq=%b br_l=%b -> pc_sel=%b (Expected: 1)", br_eq, br_l, pc_sel);
    $display("");
    
    // BLT taken
    $display("  BLT x9, x10, offset (taken)");
    inst = 32'b0_000010_01010_01001_100_0100_0_1100011;
    br_eq = 0; br_l = 1;
    #10;
    $display("    br_eq=%b br_l=%b -> pc_sel=%b (Expected: 1)", br_eq, br_l, pc_sel);
    $display("");
    
    // BGE taken
    $display("  BGE x11, x12, offset (taken)");
    inst = 32'b0_000010_01100_01011_101_0100_0_1100011;
    br_eq = 0; br_l = 0;
    #10;
    $display("    br_eq=%b br_l=%b -> pc_sel=%b (Expected: 1)", br_eq, br_l, pc_sel);
    $display("");
    
    // BLTU taken
    $display("  BLTU x13, x14, offset (taken)");
    inst = 32'b0_000010_01110_01101_110_0100_0_1100011;
    br_eq = 0; br_l = 1;
    #10;
    $display("    br_eq=%b br_l=%b br_un=%b -> pc_sel=%b (Expected: br_un=1, pc_sel=1)", 
             br_eq, br_l, br_un, pc_sel);
    $display("");
    
    // BGEU taken
    $display("  BGEU x15, x16, offset (taken)");
    inst = 32'b0_000010_10000_01111_111_0100_0_1100011;
    br_eq = 0; br_l = 0;
    #10;
    $display("    br_eq=%b br_l=%b br_un=%b -> pc_sel=%b (Expected: br_un=1, pc_sel=1)", 
             br_eq, br_l, br_un, pc_sel);
    $display("");
    
    //  JUMP INSTRUCTIONS 
    $display("--- JUMP Instructions ---");
    
    // JAL: jal x1, offset
    inst = 32'b00000000010000000000_00001_1101111;
    br_eq = 0; br_l = 0;
    #10;
    display_signals("JAL x1, offset");
    $display("");
    
    // JALR: jalr x2, x3, 4
    inst = 32'b000000000100_00011_000_00010_1100111;
    #10;
    display_signals("JALR x2, x3, 4");
    $display("");
    
    //  U-TYPE INSTRUCTIONS 
    $display("--- U-TYPE Instructions ---");
    
    // LUI: lui x5, 0x12345
    inst = 32'b00010010001101000101_00101_0110111;
    #10;
    display_signals("LUI x5, 0x12345");
    $display("");
    
    // AUIPC: auipc x6, 0x1000
    inst = 32'b00000001000000000000_00110_0010111;
    #10;
    display_signals("AUIPC x6, 0x1000");
    $display("");
    
    $display(">>>>>>>>>>>>>>>>>>>>");
    $display("Control Unit Test Complete");
    $finish;
  end

endmodule