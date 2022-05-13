const Position = NTuple{2,Int}

"""
    detect_position(program::Vector{Int}, x::Int, y::Int) -> BigInt

Run the given program, providing the x and y values as input and returning
the output, either 0 or 1.
"""
function detect_position(program::Vector{Int}, x::Int, y::Int)
    computer = Computer(program)
    add_input!(computer, x)
    add_input!(computer, y)
    computer = run!(computer)
    result   = get_output!(computer)
    return result
end

"""
    part1(input) -> Int

Given the input program, repeatedly run it on a computer in the x/y range
from 0-49, returning the total number of positions where the tractor beam
is detected.
"""
function part1(input)
    detected = 0
    for x in 0:49, y in 0:49
        detected += detect_position(input, x, y)
    end
    return detected
end
