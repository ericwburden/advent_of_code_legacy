"""
    part2(input)

Given the input as an array of values either `1` or `-1`, identify the 
index where the cumulative sum first dips below zero.
"""
function part2(input)
    total = 0
    for (idx, val) in enumerate(input)
        total += val
        total < 0 && return idx
    end
    error("Santa never entered the basement!")
end
