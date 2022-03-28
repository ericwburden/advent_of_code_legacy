"""
    part2(input)

Given the list of execution functions parsed from the input, apply each function
to a set of `Registers` and return the maximum value held in any register at
any point in the process.
"""
function part2(input)
    registers = Registers()
    max_value = typemin(Int)
    for fn in input
        max_value = max(max_value, fn(registers))
    end
    return max_value
end
