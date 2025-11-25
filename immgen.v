// immgen from inst
module immgen (
    input  [31:0] inst, //from IMEM
    input         imm_sel, //from ctrl
    input  [6:0]  opcode, //from control
    output reg [31:0] imm
);

    always @(*) begin
        imm = 32'd0;

        if (imm_sel) begin
            case (opcode)

                // I-type (ADDI, LW, JALR, etc)
                7'b0010011,
                7'b0000011,
                7'b1100111: begin
                    imm = {{20{inst[31]}}, inst[31:20]};
                end

                // S-type (SW, SH, SB)
                7'b0100011: begin
                    imm = {{20{inst[31]}}, inst[31:25], inst[11:7]};
                end

                // B-type (BEQ, BNE, BLT, etc)
                7'b1100011: begin
                    imm = {{20{inst[31]}}, //one mistake --> was 20 of them, but said it as 19
                           inst[31],
                           inst[7],
                           inst[30:25],
                           inst[11:8],
                           1'b0};
                end

                // J-type (JAL)
                7'b1101111: begin
                    imm = {{11{inst[31]}},
                           inst[31],
                           inst[19:12],
                           inst[20],
                           inst[30:21],
                           1'b0};
                end

                // U-type (LUI, AUIPC)
                7'b0110111,
                7'b0010111: begin
                    imm = {inst[31:12], 12'd0};
                end

                default: imm = 32'd0;

            endcase
        end
    end

endmodule
