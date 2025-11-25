_start:
    addi x2, x0, 5      # x2 = 5 (Loop limit)
    addi x1, x0, 0      # x1 = 0 (Counter reset)

loop:
    addi x1, x1, 1      # x1 = x1 + 1 
    blt x1, x2, loop    # If x1 < x2, jump back to loop
    
done:
    beq x0, x0, done    # Infinite loop (Halt)