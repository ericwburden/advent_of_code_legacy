const Position = NTuple{3,Int}

"Represents the position and range of a nanobot"
struct NanoBot
    position::Position
    range::Int
end

"""
    parse(::Type{NanoBot}, s::AbstractString)

Parse a line from the input file into a `NanoBot`.
"""
function Base.parse(::Type{NanoBot}, s::AbstractString)
    m = match(r"pos=<(-?\d+),(-?\d+),(-?\d+)>, r=(\d+)", s)
    p1, p2, p3, range = parse.(Int, m.captures)
    return NanoBot((p1, p2, p3), range)
end

"Parse each line of the input into a `NanoBot` and return the list"
ingest(path) = parse.(NanoBot, readlines(path))
