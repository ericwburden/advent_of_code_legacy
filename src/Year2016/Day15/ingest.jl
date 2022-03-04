"""
    Disc(positions::Int, start::Int)

Represents one of the spinning discs in the 'kinetic sculpture'. Includes the
number of positions in the disc and which position is aligned with the drop
chute at time = 0.
"""
struct Disc
    positions::Int
    start::Int
end

"Regular expression for parsing `Disc` from file"
const DISC_RE = r"Disc #\d has (?<pos>\d+) positions; at time=0, it is at position (?<start>\d+)"

"""
    Base.parse(::Type{Disc}, s::AbstractString)

Given a line from the input file, parse it into a `Disc`.
"""
function Base.parse(::Type{Disc}, s::AbstractString)
    m = match(DISC_RE, s)
    positions, start = parse.(Int, m.captures)
    return Disc(positions, start)
end

"""
    ingest(path)

Given a path to the input file, parse each line into a `Disc` and return the 
list of `Disc`s.
"""
function ingest(path)
    return parse.(Disc, readlines(path))
end
