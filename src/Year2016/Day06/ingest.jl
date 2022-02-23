"""
    ingest(path)

Given a path to the input file, parse each line into a vector of characters, and
return a matrix resulting from concatenating the individual character vectors.
"""
function ingest(path)
    messages = Vector{Char}[]
    open(path) do f
        for line in eachline(f)
            push!(messages, collect(line))
        end
    end
    return hcat(messages...)
end
