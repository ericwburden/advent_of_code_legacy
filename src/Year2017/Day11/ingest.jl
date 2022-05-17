using Match

abstract type AbstractDirection end

struct North <: AbstractDirection end
struct NorthEast <: AbstractDirection end
struct NorthWest <: AbstractDirection end
struct South <: AbstractDirection end
struct SouthEast <: AbstractDirection end
struct SouthWest <: AbstractDirection end

"""
    Base.parse(::Type{AbstractDirection}, s::AbstractString)

Parse a string into a struct that derives from AbstractDirection.
"""
function Base.parse(::Type{AbstractDirection}, s::AbstractString)
    return @match s begin
        "n" => North()
        "ne" => NorthEast()
        "nw" => NorthWest()
        "s" => South()
        "se" => SouthEast()
        "sw" => SouthWest()
    end
end

"""
    ingest(path)

Given a path to the input file, parse each string indicating a direction into
one of the `AbstractDirection`s, then return the resulting list.
"""
function ingest(path)
    read_file(x) = split(readline(x), ",")
    return [parse(AbstractDirection, s) for s in read_file(path)]
end
