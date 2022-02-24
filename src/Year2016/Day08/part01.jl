"""
    apply!(screen::BitMatrix, (; width, height)::Rectangle)
    apply!(screen::BitMatrix, (; row, shift)::RotateRow)
    apply!(screen::BitMatrix, (; col, shift)::RotateCol)

Apply an instruction to a `BitMatrix` representing the doorpad screen, where
`true` values represent lights that have been turned on.
"""
function apply!(screen::BitMatrix, (; width, height)::Rectangle)
    screen[1:height, 1:width] .= true
end

function apply!(screen::BitMatrix, (; row, shift)::RotateRow)
    screen[row+1, :] .= circshift(screen[row+1, :], shift)
end

function apply!(screen::BitMatrix, (; col, shift)::RotateCol)
    screen[:, col+1] .= circshift(screen[:, col+1], shift)
end

"""
    process_instructions!(screen::BitMatrix, instructions::Vector{Instruction})

Apply a set of instructions to a screen, one after the other.
"""
function process_instructions!(screen::BitMatrix, instructions::Vector{Instruction})
    foreach(instruction -> apply!(screen, instruction), instructions)
end

"""
    part1(input)

Given the input as a list of `Instruction`s, apply all the instructions to a
'screen' of the appropriate size and return the number of lit pixels.
"""
function part1(input)
    screen = falses(6, 50)
    process_instructions!(screen, input)
    return count(screen)
end
