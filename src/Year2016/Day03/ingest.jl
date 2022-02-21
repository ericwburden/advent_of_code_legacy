"Represents the three sides of a possible triangle"
const Sides = Tuple{Int,Int,Int}

"""
    ingest(path)

Given a path to the input file, parse each line into a 3-tuple of integers and
return the list of tuples.
"""
function ingest(path)
    triangles = Sides[]
    open(path) do f
        for line in eachline(f)
            sides = parse.(Int, split(line)) |> Tuple
            push!(triangles, sides)
        end
    end
    return triangles
end
