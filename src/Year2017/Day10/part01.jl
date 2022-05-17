"""
    wrap_indices(marks, range::UnitRange{Int})

Given an iterable collection `marks` and an integer range, convert that range 
to a list of indices in the range of indices for `marks`. Ranges that extend
beyond the bounds of `marks` are 'wrapped' around, such that
`wrap_indices([1, 2, 3, 4, 5], 4:7)` produces `[4, 5, 1, 2]`.
"""
function wrap_indices(marks, range::UnitRange{Int})
    return (collect(range) .- 1) .% length(marks) .+ 1
end

"""
    flip!(marks, range::UnitRange{Int})

Given an iterable collection `marks` and an integer range, reverse the values
indicated by wrapping the indices given in `range`. Ranges are wrapped such 
that `flip!([1, 2, 3, 4, 5], 5:8)` produces `[2, 1, 5, 4, 3]`.
"""
function flip!(marks, range::UnitRange{Int})
    indices = wrap_indices(marks, range)
    p1, p2 = 1, length(indices)
    while p1 < p2
        i1, i2 = indices[p1], indices[p2]
        marks[i1], marks[i2] = marks[i2], marks[i1]
        p1 += 1
        p2 -= 1
    end
end

"""
    knot_hash!(marks, knot_lengths, pos=1, skip=0)

Given an iterable collection `marks` and a list of lengths `knot_lengths`, 
iteratively progress through `marks`, flipping ranges of values as described
in the puzzle input. Returns a tuple of (<modified marks>, <final position>, 
<final skip amount>).
"""
function knot_hash!(marks, knot_lengths, pos = 1, skip = 0)
    for len in knot_lengths
        range = pos:(pos+len-1)
        pos += len + skip
        skip += 1
        flip!(marks, range)
    end
    return (marks, pos, skip)
end

"""
    part1(input)

Given the input as a string, perform the 'knot hash' described in the puzzle 
and return the result of multiplying the first two values in the 'twisted' list.
"""
function part1(input)
    knot_lengths = parse.(Int, split(input, ","))
    marks, _, _ = knot_hash!(collect(0:255), knot_lengths)
    return marks[1] * marks[2]
end
