"""
    most_frequent(arr)

Given an iterable collection, identify the most frequently appearing item and
return it.
"""
function most_frequent(arr)
    counts   = Dict()
    common   = nothing
    maxcount = 0

    for item in arr
        count        = get!(counts, item, 0)
        newcount     = count + 1
        counts[item] = newcount

        if newcount > maxcount
            common   = item
            maxcount = newcount
        end
    end

    return common
end

"""
    part1(input)

Given the input as a character matrix, return a string composed of the most
common letter in each row.
"""
function part1(input)
    message = Char[]
    for row in eachrow(input)
        push!(message, most_frequent(row))
    end
    return join(message)
end
