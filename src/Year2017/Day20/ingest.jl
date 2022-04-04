"""
Represents a particle in the system
"""
struct Particle
    index::Int
    position::NTuple{3,Int}
    velocity::NTuple{3,Int}
    acceleration::NTuple{3,Int}
end

"""
    parse(::Type{NTuple{3,Int}}, s::AbstractString)

Parse a string containing three numbers into a 3-tuple.
"""
function Base.parse(::Type{NTuple{3,Int}}, s::AbstractString)
    caps = match(r"<(?<x>-?\d+),(?<y>-?\d+),(?<z>-?\d+)>", s).captures
    x, y, z = [parse(Int, x) for x in caps]
    return (x, y, z)
end

"""
    ingest(path)

Given a path to the input file, parse each line into a Particle with 
accompanying index, then return the list of `Particle`s.
"""
function ingest(path)
    particles = Particle[]
    for (index, line) in enumerate(readlines(path))
        p, v, a = [parse(NTuple{3,Int}, x) for x in split(line, ", ")]
        push!(particles, Particle(index - 1, p, v, a))
    end
    return particles
end
