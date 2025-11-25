`timescale 1ns/1ps

module rf_tb;

    // basic clock + signals for the register file
    reg clk;
    reg we;
    reg [4:0] rs1, rs2, rd;
    reg [31:0] wd;
    wire [31:0] rd1, rd2;

    // hook up the register file (UUT = unit under test)
    rf uut (
        .clk(clk),
        .we(we),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .wd(wd),
        .rd1(rd1),
        .rd2(rd2)
    );

    // generate a 100MHz clock (10ns period), kinda overkill but fine
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    integer i;
    integer errors;

    // main testing sequence
    initial begin
        $dumpfile("rf_tb.vcd");
        $dumpvars(0, rf_tb);

        // init everything to zero (just being safe)
        errors = 0;
        we = 0;
        rs1 = 0;
        rs2 = 0;
        rd = 0;
        wd = 0;

        // wait a few cycles for stuff to settle
        repeat(3) @(posedge clk);

        $display("\n>>>>>>>");
        $display("Register File Testbench");
        $display(">>>>>>>\n");

        // Test 1: read x0 — always 0 no matter what
        @(negedge clk);
        rs1 = 0;
        rs2 = 0;
        @(posedge clk);
        #1;
        $display("x0 = 0x%08h (Expected 0x00000000)  OK", rd1);
        if (rd1 != 32'h0) errors++;

        // Test 2: write 0xDEADBEEF to x1
        @(negedge clk);
        we = 1;
        rd = 1;
        wd = 32'hDEADBEEF;
        @(posedge clk);

        @(negedge clk);
        we = 0;
        rs1 = 1;
        @(posedge clk);
        #1;
        $display("Read x1 = 0x%08h (Expected 0xDEADBEEF)  OK", rd1);
        if (rd1 != 32'hDEADBEEF) errors++;

        // Test 3: write x2, x3, x4 just making sure everything is consistent
        @(negedge clk);
        we = 1;
        rd = 2;
        wd = 32'h12345678;
        @(posedge clk);

        @(negedge clk);
        rd = 3;
        wd = 32'hCAFEBABE;
        @(posedge clk);

        @(negedge clk);
        rd = 4;
        wd = 32'hAAAAAAAA;
        @(posedge clk);

        @(negedge clk);
        we = 0;

        // read x2
        rs1 = 2;
        @(posedge clk);
        #1;
        $display("x2 = 0x%08h (Expected 0x12345678)  OK", rd1);
        if (rd1 != 32'h12345678) errors++;

        // read x3
        @(negedge clk);
        rs1 = 3;
        @(posedge clk);
        #1;
        $display("x3 = 0x%08h (Expected 0xCAFEBABE)  OK", rd1);
        if (rd1 != 32'hCAFEBABE) errors++;

        // read x4
        @(negedge clk);
        rs1 = 4;
        @(posedge clk);
        #1;
        $display("x4 = 0x%08h (Expected 0xAAAAAAAA)  OK", rd1);
        if (rd1 != 32'hAAAAAAAA) errors++;

        // Test 4: writing to x0 — should ignore write
        @(negedge clk);
        we = 1;
        rd = 0;
        wd = 32'hFFFFFFFF;
        @(posedge clk);

        @(negedge clk);
        we = 0;
        rs1 = 0;
        @(posedge clk);
        #1;
        $display("x0 = 0x%08h (Expected 0x00000000)  OK", rd1);
        if (rd1 != 32'h0) errors++;

        // Test 5: write attempt with we=0 — should not change reg
        @(negedge clk);
        we = 0;
        rd = 6;
        wd = 32'h99999999;
        @(posedge clk);

        @(negedge clk);
        rs1 = 6;
        @(posedge clk);
        #1;
        $display("x6 = 0x%08h (Expected 0x00000000)  OK", rd1);
        if (rd1 != 32'h0) errors++;

        // Test 6: overwrite x1 with a new value
        @(negedge clk);
        we = 1;
        rd = 1;
        wd = 32'h11111111;
        @(posedge clk);

        @(negedge clk);
        we = 0;
        rs1 = 1;
        @(posedge clk);
        #1;
        $display("x1 = 0x%08h (Expected 0x11111111)  OK", rd1);
        if (rd1 != 32'h11111111) errors++;

        // Test 7: dual-read rs1 and rs2 at same time
        @(negedge clk);
        rs1 = 1;
        rs2 = 2;
        @(posedge clk);
        #1;
        $display("x1 = 0x%08h | x2 = 0x%08h", rd1, rd2);
        if (rd1 != 32'h11111111) errors++;
        if (rd2 != 32'h12345678) errors++;

        // Test 8: pattern write to all regs x1–x31
        @(negedge clk);
        we = 1;
        for (i = 1; i < 32; i = i + 1) begin
            @(negedge clk);
            rd = i;
            wd = 32'h10000000 | i;
            @(posedge clk);
        end
        @(negedge clk);
        we = 0;

        // verify pattern
        for (i = 1; i < 32; i = i + 1) begin
            @(negedge clk);
            rs1 = i;
            @(posedge clk);
            #1;
            if (rd1 != (32'h10000000 | i)) begin
                $display("x%02d WRONG (got 0x%08h)", i, rd1);
                errors++;
            end else begin
                $display("x%02d OK", i);
            end
        end

        // Clear all registers so Test 9 can work
        @(negedge clk);
        we = 1;
        for (i = 1; i < 32; i = i + 1) begin
            @(negedge clk);
            rd = i;
            wd = 0;
            @(posedge clk);
        end
        @(negedge clk);
        we = 0;

        // Test 9: back-to-back writes to x7 and x8
        @(negedge clk);
        we = 1;
        rd = 7;
        wd = 32'h77777777;
        @(posedge clk);

        @(negedge clk);
        rd = 8;
        wd = 32'h88888888;
        @(posedge clk);

        @(negedge clk);
        we = 0;

        // verify x7
        rs1 = 7;
        @(posedge clk);
        #1;
        if (rd1 == 32'h77777777)
            $display("x7 = 0x%08h (Expected 0x77777777)  OK", rd1);
        else begin
            errors++;
            $display("x7 WRONG = 0x%08h", rd1);
        end

        // verify x8
        @(negedge clk);
        rs1 = 8;
        @(posedge clk);
        #1;
        if (rd1 == 32'h88888888)
            $display("x8 = 0x%08h (Expected 0x88888888)  OK", rd1);
        else begin
            errors++;
            $display("x8 WRONG = 0x%08h", rd1);
        end

        // Test 10: combinational reads
        @(negedge clk);
        rs1 = 3;
        #1;
        if (rd1 != 32'h0) errors++; // because x3 was cleared
        rs1 = 4;
        #1;
        if (rd1 != 32'h0) errors++;

        repeat(5) @(posedge clk);

        $display("\n>>>>>>>");
        if (errors == 0)
            $display("ALL TESTS PASSED OK");
        else
            $display("FAILED with %0d errors", errors);
        $display(">>>>>>>\n");

        $finish;
    end

    // simple simulation timeout watchdog
    initial begin
        #10000;
        $display("\nERROR: Testbench timeout!");
        $finish;
    end

endmodule
