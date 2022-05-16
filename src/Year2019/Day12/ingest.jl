"""
A `Moon` is a struct representing the position and velocity of one of the
moons being tracked.
"""
struct Moon
    position::NTuple{3,Int}
    velocity::NTuple{3,Int}
end

"Constructor for a `Moon` with given position and no velocit"
Moon(position) = Moon(position, (0, 0, 0))

"""
    parse(::Type{Moon}, s::AbstractString) -> Moon

Parse a line from the input file into a `Moon`.
"""
function Base.parse(::Type{Moon}, s::AbstractString)
    m = match(r"x=(-?\d+), y=(-?\d+), z=(-?\d+)", s)
    x, y, z = parse.(Int, m.captures)
    return Moon((x, y, z))
end

"""Parse lines from the input file into `Moon`s"""
ingest(path) = parse.(Moon, readlines(path))
