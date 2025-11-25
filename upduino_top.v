module upduino_top (
    output wire led_blue,
    output wire led_green,
    output wire led_red
);
    wire clk;

    //internal 12Mhz
    SB_HFOSC inthosc (
        .CLKHFPU(1'b1),
        .CLKHFEN(1'b1),
        .CLKHF(clk)
    );
    // CLKHF_DIV = "0b10" divides 48MHz by 4 -> 12 MHz Clock
    defparam inthosc.CLKHF_DIV = "0b10";

    // reset
    reg [23:0] reset_counter = 24'hFFFFFF; // Force 1.39 seconds of Red/Reset
    wire reset = (reset_counter != 0);

    always @(posedge clk) begin
        if (reset_counter != 0)
            reset_counter <= reset_counter - 1;
    end

    // CPU instantiatoin
    wire [31:0] cpu_pc;
    wire cpu_reg_wr;

    cpu_top cpu (
        .clk(clk),
        .reset(reset),
        .pc_current_out(cpu_pc),
        .reg_write_en_out(cpu_reg_wr)
    );

    // halt detection
    reg cpu_halted = 0;

    always @(posedge clk) begin
        if (reset) begin
            cpu_halted <= 0;
        end
        // FIX 1: Detect address 0x14 (20), which is where the infinite loop sits.
        // If your CPU uses Word Addressing (0,1,2,3), change this to 32'h5.
        else if (cpu_pc == 32'h00000010) begin
            cpu_halted <= 1;
        end
    end

    // LED control
    // While Running (halted=0): Red ON, Blue OFF
    // When Done    (halted=1): Red OFF, Blue ON
    
    wire pwm_blue  = (cpu_halted) ? 1'b1 : 1'b0;
    wire pwm_red   = (cpu_halted) ? 1'b0 : 1'b1;
    wire pwm_green = 1'b0; // Keep Green OFF to save power

    //rgb driver
    SB_RGBA_DRV rgb (
        .RGBLEDEN(1'b1),
        .CURREN(1'b1),
        .RGB0PWM(pwm_green), // Hardware pin mapping: RGB0 is Green
        .RGB1PWM(pwm_blue),  // Hardware pin mapping: RGB1 is Blue
        .RGB2PWM(pwm_red),   // Hardware pin mapping: RGB2 is Red
        .RGB0(led_green),
        .RGB1(led_blue),
        .RGB2(led_red)
    );

    // FIX 2: Lower the current to prevent USB voltage drop (Brownout)
    defparam rgb.CURRENT_MODE  = "0b1";      // 0=Full, 1=Half (use Half)
    defparam rgb.RGB0_CURRENT  = "0b000001"; // Lowest setting (Green)
    defparam rgb.RGB1_CURRENT  = "0b000001"; // Lowest setting (Blue)
    defparam rgb.RGB2_CURRENT  = "0b000001"; // Lowest setting (Red)

endmodule

//BRAM