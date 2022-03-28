"""
    part1(input)

Given the list of execution functions parsed from the input, apply each function
to a set of `Registers` and return the maximum value held in any register at
the end of the process.
"""
function part1(input)
    registers = Registers()
    foreach(fn -> fn(registers), input)
    return maximum(values(registers))
end
