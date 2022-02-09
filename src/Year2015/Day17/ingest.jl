"""
    ingest(path)

Parse each line of the input file to a number and return the vector of numbers.
"""
function ingest(path)
    vessels = Int[]
    open(path) do f
        for line in eachline(f)
            push!(vessels, parse(Int, line))
        end
    end
    return vessels
end