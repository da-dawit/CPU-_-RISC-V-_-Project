module dmem (
    input  clk,
    input  mem_wr,         // 1 = store, 0 = load
    input  [31:0] addr,           // address
    input  [31:0] write_data,     // rs2
    output reg [31:0] read_data
);

    reg [31:0] mem [0:255];   // 1KB data memory for upduino 3.1, memory mapping

    // Synchronous read/write memory
    always @(posedge clk) begin
        if (mem_wr)
            mem[addr[9:2]] <= write_data;   // store
        else
            read_data <= mem[addr[9:2]];    // load only when not writing
    end

endmodule

//git to update and save version; version control