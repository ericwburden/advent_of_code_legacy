const MaybeRange = Union{Nothing,Int}

"""
    ingest(path)::Vector{MaybeRange}

Given the path to the input file, produce a model of the firewall that consists
of a list of layer ranges, where the index of the layer indicates its depth 
(minus one, to account for 1-indexing). Layers that don't have a sensor are 
represented by `nothing`.
"""
function ingest(path)::Vector{MaybeRange}
    layers::Vector{MaybeRange} = fill(nothing, 93)
    open(path) do f
        for line in eachline(f)
            depth, range = parse.(Int, split(line, ": "))
            layers[depth + 1] = range
        end
    end
    return layers
end
