"""
    ingest(path) -> Dict{String,Vector{String}}

Given the path to the input file, parse each line into an entry in
a Dict where the keys are individual objects and the values are a list
of objects that orbit the key object.
"""
ingest(path) =
    open(path) do f
        orbits = Dict{String,Vector{String}}()
        for line in eachline(f)
            left, right = split(line, ")")
            current = get!(orbits, left, [])
            push!(current, right)
        end
        orbits
    end
