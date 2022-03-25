"""
    part2(input)

Given the input as a list of numbers representing jumps, follow each jump
(increasing or decreasing each jump length as indicated by the puzzle each
time) until a jump leads outside the bounds of the input array. Return the
number of steps taken.
"""
function part2(input)
    jumps = deepcopy(input)
    len   = length(input)
    ptr   = 1
    steps = 0

    while 0 < ptr <= len
        old    = ptr
        ptr   += jumps[ptr]
        steps += 1
        jumps[old] += jumps[old] >= 3 ? -1 : 1
    end

    return steps
end

