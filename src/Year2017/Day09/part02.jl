"""
    collect_garbage(stream::Vector{Char})

Given a vector of characters, return all the 'garbage' characters, which is 
any character inside '<>' brackets and not preceded by '!'.
"""
function collect_garbage(stream::Vector{Char})
    garbage    = Char[]
    is_garbage = false
    index      = 1

    while index <= length(stream)
        char = stream[index]
        if (char == '!') 
            index += 2 
            continue
        end
        if (char == '>') is_garbage = false end
        is_garbage && push!(garbage, char)
        if (char == '<') is_garbage = true end
        index += 1
    end

    return garbage
end

"Collect all the garbage characters and return the resulting length"
part2(input) = collect_garbage(input) |> length 