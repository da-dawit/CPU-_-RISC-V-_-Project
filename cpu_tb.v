`timescale 1ns/1ps

// simple smoke test for cpu_top
module cpu_test;

    reg clk = 0;
    reg reset = 1;

    wire [31:0] pc_out;
    wire reg_wr_out;

    // just a basic clock, 10ns period (100MHz)
    always #5 clk = ~clk;

    // cpu instance we’re testing
    cpu_top cpu (
        .clk(clk),
        .reset(reset),
        .pc_current_out(pc_out),
        .reg_write_en_out(reg_wr_out)
    );

    integer cycle;

    initial begin
        $dumpfile("cpu_tb.vcd");
        $dumpvars(0, cpu_test);

        // hold reset for a lil bit
        #20 reset = 0;

        $display("\n>>>>>> CPU TEST START >>>>>>\n");

        // run for 200 cycles just to see whats going on
        for (cycle = 0; cycle < 200; cycle = cycle + 1) begin
            @(posedge clk);

            // printing PC every cycle like a heartbeat
            $display("Cycle %0d | PC = 0x%08h | RegWrite = %0d",
                     cycle, pc_out, reg_wr_out);

            // if something weird happens (pc not aligned or whatever)
            if (pc_out[1:0] != 2'b00) begin
                $display("Warning: PC not word-aligned lol");
            end
        end

        $display("\n>>>>>> CPU TEST DONE >>>>>>\n");

        $finish;
    end

endmodule
