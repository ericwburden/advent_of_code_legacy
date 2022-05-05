# From src/Year2019/IntCode.jl
using .IntCode: Computer, run!, add_input!, get_output!
using Combinatorics: permutations

"""
    run_amplifiers(code::Vector{Int}, phases::Vector{Int})

Run five computers, in series, each taking in it's assigned phase and
the output from the previous computer as input (the first computer gets
an input of zero). Returns the output from the fifth computer.
"""
function run_amplifiers(code::Vector{Int}, phases::Vector{Int})
    input = 0
    for phase in phases
        computer = (Computer ∘ deepcopy)(code)
        add_input!(computer, phase)
        add_input!(computer, input)
        run!(computer)
        input = get_output!(computer)
    end
    return input
end

"""
    part1(input)

Run all permutations of the phases 0-4 through the amplifiers and 
return the maximum output found.
"""
function part1(input)
    series_output(p) = run_amplifiers(input, p)
    return maximum(series_output, permutations((0, 1, 2, 3, 4)))
end
