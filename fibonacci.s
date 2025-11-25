# Fibonacci Calculator with LED Output
# Compatible with basic assemblers

# Calculate F(10) = 55
main:
    addi x1, x0, 0         # F(0) = 0
    addi x2, x0, 1         # F(1) = 1
    addi x3, x0, 10        # Counter: n = 10
    addi x5, x0, 55        # Expected result
    
    # Check if n == 0
    beq x3, x0, result_zero
    
    # Check if n == 1
    addi x4, x0, 1
    beq x3, x4, result_one
    
    # Initialize loop counter
    addi x4, x0, 2         # Start from index 2

fib_loop:
    add x6, x1, x2         # x6 = F(n-1) + F(n-2)
    add x1, x2, x0         # x1 = x2 (shift)
    add x2, x6, x0         # x2 = x6 (shift)
    addi x4, x4, 1         # counter++
    blt x4, x3, fib_loop   # if counter < n, continue
    beq x4, x3, compare    # if counter == n, compare
    jal x0, fib_loop       # else continue loop

result_zero:
    addi x6, x0, 0         # Result = 0
    jal x0, compare

result_one:
    addi x6, x0, 1         # Result = 1
    jal x0, compare

compare:
    beq x5, x6, match      # If expected == result, match

mismatch:
    # Set GREEN LED
    lui x7, 0x10000        # x7 = 0x10000000 (upper 20 bits)
    addi x8, x0, 2         # GREEN = 0b010
    sw x8, 0(x7)           # Store to LED register
    jal x0, halt

match:
    # Set BLUE LED
    lui x7, 0x10000        # x7 = 0x10000000
    addi x8, x0, 1         # BLUE = 0b001
    sw x8, 0(x7)           # Store to LED register

halt:
    jal x0, halt           # Infinite loop