# From src/Year2019/IntCode.jl
# Most of the code for this puzzle was added to the IntCode module
using .IntCode: Computer, run!, add_input!, get_output!

"""
    part1(input)

Run the IntCode program given in `input` with an input of `1`, and
return the value output from a successful run.
"""
function part1(input)
    values = [input...]
    computer = Computer(values)
    add_input!(computer, 1)
    run!(computer)
    return get_output!(computer)
end
