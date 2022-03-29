"""
    strip_garbage(stream::Vector{Char})

Given a vector of characters, removes all characters that fall between '<' and 
'>' and all pairs of characters that begin with '!'. Returns the remaining
character vector with the 'garbage' removed.
"""
function strip_garbage(stream::Vector{Char})
    cleaned    = Char[]
    is_garbage = false
    index      = 1

    while index <= length(stream)
        char = stream[index]
        if (char == '!') 
            index += 2 
            continue
        end
        if (char == '<') is_garbage = true end
        is_garbage || push!(cleaned, char)
        if (char == '>') is_garbage = false end
        index += 1
    end

    return cleaned
end

"""
    score_groups(stream::Vector{Char})

Given a vector of characters, strip all the garbage and score the remaining
groups according to the puzzle input, where each group is scored according to
how deeply it is nested in other groups.
"""
function score_groups(stream::Vector{Char})
    groups = strip_garbage(stream)
    depth  = 0
    total  = 0
    
    for char in groups
        if char == '{'
            depth += 1
        end
        if char == '}'
            total += depth
            depth -= 1
        end
    end

    return total
end

"Return the scoring for the input vector"
part1(input) = score_groups(input)