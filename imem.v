module imem (
    input clk,
    input [31:0] addr,
    output reg [31:0] inst
);
    reg [31:0] mem [0:255];

    initial begin
        $readmemh("prog.hex", mem);
    end

    always @(posedge clk) begin
        inst <= mem[addr[9:2]];  // No byte swapping needed!
    end

endmodule

//bottlenecked by BRAM size
//where yosys maps the memory 
//DMA, SPRAM connected to output