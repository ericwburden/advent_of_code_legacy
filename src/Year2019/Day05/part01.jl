# From src/Year2019/IntCode.jl
using .IntCode: Computer, run!, add_input!, get_output!

"""
    part1(input)

Given the input as a list of numbers, create an IntCode computer with
the values as the program. Set the input of the computer to `1` and 
run the program to completion. Return the diagnostic code: the only
non-zero value output.
"""
function part1(input)
    values = [input...]
    computer    = Computer(values)
    add_input!(computer, 1)
    run!(computer)
    output = get_output!(computer)
    while output == 0
        output = get_output!(computer)
    end
    return output
end
