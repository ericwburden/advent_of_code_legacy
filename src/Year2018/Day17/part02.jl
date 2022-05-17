"""
    part2(input)

Given the input as a scanned map of a slice of ground (where water
flow has already been simulated), count the number of water positions,
and return the count.
"""
function part2(input)
    # NOTE: This only works if `input` has already been modified
    # by `part1()`
    total_water = 0
    for square in values(input)
        square isa Water && (total_water += 1)
    end
    return total_water
end
