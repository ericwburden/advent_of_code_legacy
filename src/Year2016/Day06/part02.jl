"""
    least_frequent(arr)

Given an iterable collection, identify the least frequently appearing item and
return it.
"""
function least_frequent(arr)
    counts = Dict()

    for item in arr
        count        = get!(counts, item, 0)
        counts[item] = count + 1
    end

    common   = nothing
    mincount = typemax(Int)
    for (item, count) in counts
        if count < mincount
            common   = item
            mincount = count
        end
    end

    return common
end

"""
    part2(input)

Given the input as a character matrix, return a string composed of the least
common letter in each row.
"""
function part2(input)
    message = Char[]
    for row in eachrow(input)
        push!(message, least_frequent(row))
    end
    return join(message)
end
