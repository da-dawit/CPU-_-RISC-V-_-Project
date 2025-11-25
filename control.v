//IMEM to control, decoder
module control (
    input  [31:0] inst, //from IMEM
    output reg [6:0] opcode,  //last 7 LSBs
    output reg [4:0] rd,
    output reg [4:0] rs1,
    output reg [4:0] rs2,
    output reg [2:0] funct3,
    output reg [6:0] funct7,
    //immediates are done in immgen

    //from branch comp
    input br_eq, 
    input br_l,
    
    // Ctrl sigs
  	output reg       pc_sel,
    output reg       reg_write_en,
    output reg       imm_sel,
    output reg       br_un, // 0 is signed, 1 is unsigned
    output reg       b_sel,
    output reg       a_sel,
    output reg [3:0] alu_sel,
    output reg       mem_wr, //0 is read, 1 is write
    output reg [1:0] wb_sel //2 bits for choosing output from ALU vs PC+4 vs MEM read
);

    // Extract instruction fields--need to check table, based on R. Changes below.
    always @(*) begin
        opcode = inst[6:0];
        rd     = inst[11:7];
        funct3 = inst[14:12];
        rs1    = inst[19:15];
        rs2    = inst[24:20];
        funct7 = inst[31:25];
    end

    reg check;
    
    always @(*) begin //Ctrl Signals
        pc_sel = 1'b0;
        reg_write_en = 1'b0;
        imm_sel = 1'b0;
        br_un = 1'b0; //signed
        b_sel = 1'b0;
        a_sel = 1'b0;
        alu_sel = 4'b0000; //10 main calculations, 2^4 = 16;
        mem_wr = 1'b0; //read init
        wb_sel = 2'b0; //select between ALU, PC+4, or DMEM read
        
        case (opcode)
            7'b011_0011: begin //R
                reg_write_en = 1'b1; //read back to rd
                wb_sel = 2'b1; //ALU output
                case ({funct7, funct3})
                    10'b0000000_000: alu_sel = 4'b0000; // ADD
                    10'b0100000_000: alu_sel = 4'b0001; // SUB
                    10'b0000000_100: alu_sel = 4'b0010; // XOR
                    10'b0000000_110: alu_sel = 4'b0011; // OR
                    10'b0000000_111: alu_sel = 4'b0100; // AND
                    10'b0000000_001: alu_sel = 4'b0101; // << Logical
                    10'b0000000_101: alu_sel = 4'b0110; // >> Logical
                    10'b0100000_101: alu_sel = 4'b0111; // >> Arith, msb extends
                    10'b0000000_010: alu_sel = 4'b1000; // Set Less than
                    10'b0000000_011: begin
                        br_un = 1'b1;
                        alu_sel = 4'b1001; // Set Less than (Unsigned), 0-extends
                    end
                    default: alu_sel = 4'b0000;
                endcase
            end
            
            7'b001_0011: begin //Imm Ops (I); R and these ops are exactly the same.
                reg_write_en = 1'b1;
                imm_sel = 1'b1;
                b_sel = 1'b1;
                wb_sel = 2'b1; //ALU output
                case (funct3)
                    3'b000: alu_sel = 4'b0000; //addi
                    3'b100: alu_sel = 4'b0010; //xori
                    3'b110: alu_sel = 4'b0011; //ori
                    3'b111: alu_sel = 4'b0100; //andi
                    3'b001: alu_sel = 4'b0101; //slli
                    3'b101: begin
                        case (inst[30])
                            1'b0: alu_sel = 4'b0110; //srli
                            1'b1: alu_sel = 4'b0111; //srai
                        endcase
                    end
                    3'b010: alu_sel = 4'b1000; //slti
                    3'b011: begin
                        br_un = 1'b1;
                        alu_sel = 4'b1001; //sltiu
                    end
                    default: alu_sel = 4'b0000;
                endcase
            end

            7'b000_0011: begin //Imm LOAD, load M[imm + rs1]
                reg_write_en = 1'b1;
                imm_sel = 1'b1;
                b_sel = 1'b1; //imm
                alu_sel = 4'b0000; //all adding, [imm + rs1]'s addr in DMEM
                mem_wr = 1'b0; //read only
                wb_sel = 2'b0; //MEM READ
            end

            7'b010_0011: begin //STORE store rs2's value into M[imm + rs1]
                imm_sel = 1'b1;
                b_sel = 1'b1;
                alu_sel = 4'b0000; //all adding
                mem_wr = 1'b1; //STORE, WRITE
            end

            7'b110_0011: begin //BRANCH, PC + imm
                br_un = 1'b0; //signed
                imm_sel = 1'b1;
                b_sel   = 1'b1; // immediate
                a_sel   = 1'b1; // PC
                alu_sel = 4'b0000; // PC + imm
                pc_sel  = 1'b0; // default no-branch
                check = 1'b0;

                case (funct3)
                    3'b000: begin
                        if (br_eq == 1'b1)
                            check = 1'b1;
                    end
                    3'b001: begin
                        if (br_eq == 1'b0)
                            check = 1'b1;
                    end
                    3'b100: begin   
                        if (br_l == 1'b1)
                            check = 1'b1;
                    end
                    3'b101: begin
                        if (br_l == 1'b0)
                            check = 1'b1;
                    end
                    3'b110: begin
                        br_un = 1'b1;
                        if (br_l == 1'b1)
                            check = 1'b1;
                    end
                    3'b111: begin
                        br_un = 1'b1;
                        if (br_l == 1'b0)
                            check = 1'b1;
                    end
                    default: begin
                        br_un = 1'b0; //signed
                        check = 1'b0;
                    end
                endcase

                // Final branch decision
                if (check == 1'b1)
                    pc_sel = 1'b1;

            end

            7'b110_1111: begin //jal
                reg_write_en = 1'b1; //rf write
                imm_sel = 1'b1;
                b_sel = 1'b1;
                a_sel = 1'b1;
                pc_sel = 1'b1; //ALU (PC+ imm)
                mem_wr = 1'b0;
                wb_sel = 2'b10; //PC + 4 to rd
            end

            7'b110_0111: begin //jalr
                reg_write_en = 1'b1;
                imm_sel = 1'b1;
                b_sel = 1'b1;
                a_sel = 1'b0; //rs1
                pc_sel = 1'b1;
                mem_wr = 1'b0;
                wb_sel = 2'b10; //PC + 4
            end

            7'b0110111: begin // LUI rd = imm << 12
                reg_write_en = 1'b1;
                imm_sel = 1'b1;       // tell immgen to use U-type
                b_sel = 1'b1;         // choose immediate
                a_sel = 1'b0;         // ALU input A = 0 (x0)
                alu_sel = 4'b0000;  // ALU adds B (the immediate with 0)
                wb_sel = 2'b01;       // write ALU result to rd
            end

            7'b0010111: begin //auipc rd = PC + (imm << 12)
                reg_write_en = 1'b1;
                imm_sel = 1'b1;
                b_sel = 1'b1;
                a_sel = 1'b1;
                alu_sel = 4'b0000; //add
                wb_sel = 2'b01; //alu
            end
        endcase
    end
  // Control Signals
endmodule