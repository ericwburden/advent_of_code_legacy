# From src/Year2019/IntCode.jl
using .IntCode: Program, run!

"""
    part1(input)

Given the input as a list of numbers, replace values with those given in the
puzzle description and run the program, returning the value in memory address
0 at the end of the program.
"""
function part1(input)
    values = [input...]
    program    = Program(values)
    program[1] = 12
    program[2] = 2
    run!(program)
    return program[0]
end
