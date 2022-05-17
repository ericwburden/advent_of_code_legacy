"""
An `AbstractDirection` represents one of the directions given in the path
for a wire.
"""
abstract type AbstractDirection end
struct Up <: AbstractDirection
    steps::Int
end
struct Down <: AbstractDirection
    steps::Int
end
struct Left <: AbstractDirection
    steps::Int
end
struct Right <: AbstractDirection
    steps::Int
end

"""
    parse(::Type{AbstractDirection}, s::AbstractString)

Parse a direction specification from the input file into an `AbstractDirection`
"""
function Base.parse(::Type{AbstractDirection}, s::AbstractString)
    m = match(r"(U|D|L|R)(\d+)", s)
    steps = parse(Int, m[2])
    m[1] == "U" && return Up(steps)
    m[1] == "D" && return Down(steps)
    m[1] == "L" && return Left(steps)
    m[1] == "R" && return Right(steps)
    error("Cannot parse $s into an `AbstractDirection`!")
end

"""
    ingest(path)

Given the path to the input file, parse each wire entry into a list of 
`AbstractDirection`s indicating that wires path and return a tuple of
wire directions.
"""
function ingest(path)
    wire1, wire2 = readlines(path)
    return [parse.(AbstractDirection, split(wire, ",")) for wire in (wire1, wire2)]
end
