"""
    part2(input)

Given a string representing a polymer, determine the smallest polymer that 
can be obtained from reacting if all instances of a unit (character) are 
removed. Return the lenght of that smallest polymer.
"""
function part2(input)
    min_length = typemax(Int)
    for char = 'A':'Z'
        pattern = Regex("$char|$(char+32)")
        (reacted_length = replace(input, pattern => "") |> react_polymer |> length)
        min_length = min(min_length, reacted_length)
    end
    return min_length
end
