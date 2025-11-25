module cpu_top (
    input clk,
    input reset,
    
    // Debug outputs for monitoring
    output [31:0] pc_current_out,
    output reg_write_en_out
);

    // ========== Wires and Registers ==========
    
    // PC signals
    wire [31:0] pc_current;
    wire [31:0] pc_plus_4;
    
    // Instruction memory signals
    wire [31:0] instruction;
    
    // Control signals
    wire [6:0] opcode;
    wire [4:0] rd, rs1, rs2;
    wire [2:0] funct3;
    wire [6:0] funct7;
    wire pc_sel;
    wire reg_write_en;
    wire imm_sel;
    wire br_un;
    wire b_sel;
    wire a_sel;
    wire [3:0] alu_sel;
    wire mem_wr;
    wire [1:0] wb_sel;
    
    // Register file signals
    wire [31:0] rf_rd1;
    wire [31:0] rf_rd2;
    wire [31:0] rf_wd;
    
    // Immediate generator signals
    wire [31:0] immediate;
    
    // Branch comparator signals
    wire br_eq;
    wire br_l;
    
    // ALU signals
    wire [31:0] alu_operand_a;
    wire [31:0] alu_operand_b;
    wire [31:0] alu_result;
    wire alu_zero;
    
    // Data memory signals
    wire [31:0] dmem_read_data;
    
    // ========== PC + 4 Computation ==========
    assign pc_plus_4 = pc_current + 32'd4;
    
    // ========== Module Instantiations ==========
    
    // Program Counter
    pc pc_inst (
        .clk(clk),
        .reset(reset),
        .pc_sel(pc_sel),
        .alu_out(alu_result),
        .pc(pc_current)
    );
    
    // Instruction Memory
    imem imem_inst (
        .clk(clk),
        .addr(pc_current),
        .inst(instruction)
    );
    
    // Control Unit
    control control_inst (
        .inst(instruction),
        .opcode(opcode),
        .rd(rd),
        .rs1(rs1),
        .rs2(rs2),
        .funct3(funct3),
        .funct7(funct7),
        .br_eq(br_eq),
        .br_l(br_l),
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
    
    // Register File
    rf rf_inst (
        .clk(clk),
        .we(reg_write_en),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .wd(rf_wd),
        .rd1(rf_rd1),
        .rd2(rf_rd2)
    );
    
    // Immediate Generator
    immgen immgen_inst (
        .inst(instruction),
        .imm_sel(imm_sel),
        .opcode(opcode),
        .imm(immediate)
    );
    
    // Branch Comparator
    bc bc_inst (
        .d1(rf_rd1),
        .d2(rf_rd2),
        .br_un(br_un),
        .br_eq(br_eq),
        .br_l(br_l)
    );
    
    // ALU Operand A Mux (a_sel: 0 = rs1, 1 = PC)
    assign alu_operand_a = a_sel ? pc_current : rf_rd1;
    
    // ALU Operand B Mux (b_sel: 0 = rs2, 1 = immediate)
    assign alu_operand_b = b_sel ? immediate : rf_rd2;
    
    // ALU
    alu alu_inst (
        .operand_a(alu_operand_a),
        .operand_b(alu_operand_b),
        .alu_ctrl(alu_sel),
        .result(alu_result),
        .zero(alu_zero)
    );
    
    // Data Memory
    dmem dmem_inst (
        .clk(clk),
        .mem_wr(mem_wr),
        .addr(alu_result),
        .write_data(rf_rd2),
        .read_data(dmem_read_data)
    );
    
    // ========== Write-back Mux ==========
    // wb_sel: 00 = DMEM, 01 = ALU, 10 = PC+4
    assign rf_wd = (wb_sel == 2'b00) ? dmem_read_data :
                   (wb_sel == 2'b01) ? alu_result :
                   (wb_sel == 2'b10) ? pc_plus_4 :
                   32'd0;
    
    // ========== Debug Outputs ==========
    assign pc_current_out = pc_current;
    assign reg_write_en_out = reg_write_en;

endmodule