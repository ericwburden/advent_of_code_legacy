"""
    even_division(itr)

Given an iterable collection, return the value of the only possible even divison
among the items. If no even division can be found, throws an error.
"""
function even_division(itr)
    sorted = sort(itr)
    for i in 1:length(itr)-1, j in (i+1):length(itr)
        quotient, remainder = divrem(sorted[j], sorted[i])
        remainder == 0 && return quotient
    end
    error("No evenly divisible pair found in:\n\t$itr")
end

"""
    part2(input)

Given the input as a matrix of integers representing the values in some 
spreadsheet, calculate the 'checksum' as the total of the even divisions
in each column. (Recall, rows were converted to columns when reading the
input). For this puzzle, an 'even division' is the result of evenly dividing
two numbers in each row, of which there should be only one instance.
"""
part2(input::Matrix{Int}) = mapreduce(even_division, +, eachcol(input))
