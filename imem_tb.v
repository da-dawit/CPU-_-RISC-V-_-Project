`timescale 1ns/1ps

module tb_imem;

    reg clk = 0;
    reg [31:0] addr = 0;
    wire [31:0] inst;

    // Instantiate IMEM
    imem dut (
        .clk(clk),
        .addr(addr),
        .inst(inst)
    );

    // 100 MHz clock for simulation
    always #5 clk = ~clk;

    //vcd
    initial begin
        $dumpfile("imem_tb.vcd");
        $dumpvars(0, tb_imem);
    end

    // Step helper
    task step;
        begin
            #10;   // one full clock period
        end
    endtask

    initial begin
        $display("\n===== START IMEM TEST =====");

        // allow $readmemh to load
        step;
        step;

        // sweep PC addresses: 0x00, 0x04, 0x08, ...
        repeat(16) begin
            $display("PC = %h | inst = %h | mem[%0d]",
                addr, inst, addr[9:2]
            );
            addr = addr + 32'd4;
            step;
        end

        $display("===== END IMEM TEST =====\n");
        $finish;
    end

endmodule
