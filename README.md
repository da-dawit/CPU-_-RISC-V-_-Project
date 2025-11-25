Project Structure:
alu/           ALU
bc/            Branch comparator
control/       Control unit
cpu_top/       CPU datapath integration
dmem/          Data memory
imem/          Instruction memory (hex loader)
immgen/        Immediate generator
pc/            Program counter
rf/            Register file

assembler/     Python assembler → prog.hex
prog.hex        Program for IMEM

*.tb / *.vcd    Testbenches + waveforms
hardware.*      Synthesis outputs
upduino_top/    FPGA wrapper (clock + LED test)

Architecture Summary >>>>>>

PC: 32-bit counter; selects between pc+4 or branch/jump target.

IMEM: Synchronous ROM initialized with prog.hex.

Control Unit: Decodes opcode → ALU/memory/writeback control signals.

Immediate Generator: I/S/B/U/J format immediates with sign-extension.

Register File: 32×32-bit, dual-read, single-write, x0 = 0.

ALU: ADD/SUB, logic ops, shifts, SLT/SLTU.

Branch Comparator: BEQ/BNE/BLT/BGE (signed + unsigned).

DMEM: Load/store RAM.

CPU Top: Single-cycle datapath

IF → ID → EX → MEM → WB (single-cycle)

Misc. >>>>>>>>>>>>>>>>>>>>>>>>>>>>>
Each module has:

*_tb.v testbench

*.vcd waveform

*.out simulation binary

Upduino Top >>>>>>>>>>>>>>>>>>>>>>>>>>>

upduino_top generates a 12 MHz internal clock and provides a hardware check:

Counts ~1.2 seconds of clock cycles (led red)

Turns on blue LED when the clock and CPU are running correctly