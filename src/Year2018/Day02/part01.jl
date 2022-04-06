using DataStructures: Accumulator, counter

"""
    contains_2_or_3(counts::Accumulator{Char,Int})

Given an `Accumulator` mapping character to count, returns a tuple in the 
form of (<contains a letter 2 times>, <contains a letter 3 times>) of type
Tuple{Bool,Bool}.
"""
function contains_2_or_3(counts::Accumulator{Char,Int})
    contains_2, contains_3 = (false, false)
    for value in values(counts)
        contains_2 && contains_3 && break
        if (value == 2) contains_2 = true end
        if (value == 3) contains_3 = true end
    end
    return (contains_2, contains_3)
end

"""
    part1(input)

Given the input as a list of strings, identify which strings contain exactly
two of the same character and which strings contain exactly three of the same
character, count each independently, and return the result of multiplying
the two counts together.
"""
function part1(input)
    (input
        |> (x -> map(counter, x))
        |> (x -> map(contains_2_or_3, x))
        |> (x -> reduce(.+, x))
        |> prod)
end
