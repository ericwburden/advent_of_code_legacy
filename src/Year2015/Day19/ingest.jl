"""
    ingest(path)

Given the path to the input file, parse the top part (lines in the format of 
<string> => <string>) into a Dict{String,Vector{String}}, where each entry
represents an element that can be replaced (key) and a list of compounds
that can replace that element (value). 

The last line is just parsed as a string. Returns a tuple of the Dict and
last line, which represents the target molecule.
"""
function ingest(path)
    replacements = Dict{String,Vector{String}}()

    open(path) do f
        for line in eachline(f)
            isempty(line) && continue

            if contains(line, "=>")
                left, right = split(line, " => ")
                current = get!(replacements, left, String[])
                push!(current, right)
            else
                return (replacements, line)
            end
        end
    end
end
