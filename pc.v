module pc (
    input clk,
    input reset,
    input pc_sel,
    input [31:0] alu_out,
    output reg [31:0] pc
);
    reg [31:0] next_pc;

    //FSM
    always @(posedge clk or posedge reset) begin
        if (reset)
            pc <= 32'h0000_0000;
        else
            pc <= next_pc;
    end

    //Next PC logic
    always @(*) begin
        if (pc_sel)
            next_pc = alu_out; //branch or jump
        else
            next_pc = pc + 32'd4; //sequential
    end

endmodule