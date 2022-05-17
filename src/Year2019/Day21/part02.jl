# SpringScript derived by hand (gross!) that will run the SpringBot in 'RUN' mode
const RUNSCRIPT = [
    "NOT C J", # J <- There is a hole three away
    "AND D J", # J <- J == TRUE and there is ground four away
    "NOT H T", # T <- There is a hole eight away
    "NOT T T", # T <- T == FALSE
    "OR E T",  # T <- There is ground five away or T == TRUE
    "AND T J", # J <- T == TRUE and J == TRUE
    "NOT A T", # T <- There is a hole one away
    "OR T J",  # J <- T == TRUE or J == TRUE
    "NOT B T", # T <- There is a hole two away
    "NOT T T", # T <- T == FALSE
    "OR E T",  # T <- There is ground five away or T == TRUE
    "NOT T T", # T <- T == FALSE
    "OR T J",  # J <- T == TRUE or J == TRUE
    "RUN",     # Execute the program
    "",         # Empty final line
]


"Check for hull damage using the `RUNSCRIPT` script"
part2(input) = hull_damage(input, RUNSCRIPT)
