"""
    part1(input)

Given the input as a list of numbers representing jumps, follow each jump
(increasing each jump length by one each time) until a jump leads outside the
bounds of the input array. Return the number of steps taken.
"""
function part1(input)
    jumps = deepcopy(input)
    len   = length(input)
    ptr   = 1
    steps = 0

    while 0 < ptr <= len
        jumps[ptr] += 1
        ptr        += (jumps[ptr] - 1)
        steps      += 1
    end

    return steps
end
