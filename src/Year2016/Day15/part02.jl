"""
    part2(input)

Given the input as a list of `Disc`s, add the additional `Disc` described in 
part two of the puzzle, then identify and return the first instant
where a dropped capsule will be able to pass all the discs, even the new one.
"""
function part2(input)
    discs = [input..., Disc(11, 0)]
    return part1(discs)
end
