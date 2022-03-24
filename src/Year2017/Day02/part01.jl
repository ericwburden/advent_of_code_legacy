"""
    max_diff(itr)

Given an iterable collection, return the difference between the maximum and 
minimum values.
"""
function max_diff(itr)
    small, large = extrema(itr)
    return large - small
end

"""
    part1(input)

Given the input as a matrix of integers representing the values in some 
spreadsheet, calculate the 'checksum' as the total of the maximum difference
in each column. (Recall, rows were converted to columns when reading the
input).
"""
part1(input::Matrix{Int}) = mapreduce(max_diff, +, eachcol(input))
