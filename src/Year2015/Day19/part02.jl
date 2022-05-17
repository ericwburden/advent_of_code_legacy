"""
    flip(replacement_map)

Given the replacement mapping from the input, produce a Vector or Pairs where
the first item is a regular expression formed from a single `replacement_map` 
value and the second item is it's corresponding key.
"""
function flip(replacement_map)
    flipped = Pair{Regex,String}[]
    for (key, values) in replacement_map
        for value in values
            push!(flipped, Regex(value) => key)
        end
    end
    return flipped
end

"""
    contract(molecule, replacement_pairs)

Given a string representing a `molecule` and a set of `replacement_pairs` 
(see [`flip`](@ref)), replace all instances of the first element of each
replacement pair with it's second element, reducing the length of the input
molecule. Return a tuple of (`insertions`, `molecule`), where `insertions`
is the total number of replacments made and `molecule` is the resulting string.

This type of contraction only works to yield the final answer if the 
`replacement_pairs` are sorted in order, descending, based on the length of 
the substring being replaced. There's a comment on the r/adventofcode
subreddit (by u/askalski) that explains why this is:
https://www.reddit.com/r/adventofcode/comments/3xflz8/day_19_solutions/
"""
function contract(molecule, replacement_pairs)
    insertions = 0
    for (regex, insert) in replacement_pairs
        regex_match = match(regex, molecule)
        while !isnothing(regex_match)
            molecule = replace_match(molecule, regex_match, insert)
            insertions += 1
            regex_match = match(regex, molecule)
        end
    end
    return (insertions, molecule)
end

"""
    part2(input)

Given the input as parsed, contract the initial molecule by replacing segments 
with the element that produced them in decreasing order of segment length. 
Returns the number of substitutions required to backtrack all the way to a
starting molecule of "e".
"""
function part2(input)
    replacement_map, molecule = input
    replacement_pairs =
        sort!(flip(replacement_map), by = x -> length(x.first.pattern), rev = true)

    total_replacements = 0
    while molecule != "e"
        replacements, molecule = contract(molecule, replacement_pairs)
        total_replacements += replacements
    end
    return total_replacements
end
