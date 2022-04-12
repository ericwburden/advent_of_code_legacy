"Regular expressions for parsing the input"
const POSITION_RE = r"position=<\s*(?<px>-?\d+),\s*(?<py>-?\d+)>"
const VELOCITY_RE = r"velocity=<\s*(?<vx>-?\d+),\s*(?<vy>-?\d+)>"

"Represents one of the points of light"
struct Point
    position::Tuple{Int,Int}
    velocity::Tuple{Int,Int}
end

"""
    parse(::Type{Point}, s::AbstractString)

Parse a line from the input file into a `Point`.
"""
function Base.parse(::Type{Point}, s::AbstractString)
    px, py = parse.(Int, match(POSITION_RE, s).captures)
    vx, vy = parse.(Int, match(VELOCITY_RE, s).captures)
    return Point((px, py), (vx, vy))
end

ingest(path)::Vector{Point} = parse.(Point, readlines(path))
