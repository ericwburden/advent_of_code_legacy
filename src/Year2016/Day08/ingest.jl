using Match

"""
    Rectangle(width::Int, height::Int) <: Instruction
    RotateRow(row::Int,   shift::Int)  <: Instruction
    RotateCol(col::Int,   shift::Int)  <: Instruction

Represents one of the instructions for lighting up the 'screen' we'll be 
operating.
"""
abstract type Instruction end

struct Rectangle <: Instruction
    width::Int
    height::Int
end

struct RotateRow <: Instruction
    row::Int
    shift::Int
end

struct RotateCol <: Instruction
    col::Int
    shift::Int
end

# Gnarly regex for parsing the input
const RE = r"^(?<type>rect|rotate (row|column))\s?(?<rect>\d+x\d+)?(?<rot>(x|y)=\d+ by \d+)?$"

"""
    Base.parse(::Type{Instruction}, s::AbstractString)

Parse a string from the input into one of the sub-types of `Instruction`, 
depending on the contents of the string.
"""
function Base.parse(::Type{Instruction}, s::AbstractString)
    m = match(RE, s)
    return @match m["type"] begin
        "rect"          => parse(Rectangle, m["rect"])
        "rotate row"    => parse(RotateRow, m["rot"])
        "rotate column" => parse(RotateCol, m["rot"])
    end
end

"""
    Base.parse(::Type{Rectangle}, s::AbstractString)

Parse a string formatted like "<number>x<number>" into a `Rectangle` instruction
"""
function Base.parse(::Type{Rectangle}, s::AbstractString)
    re = r"(\d+)x(\d+)"
    width, height = parse.(Int, match(re, s).captures)
    return Rectangle(width, height)
end

"""
    Base.parse(::Type{RotateRow}, s::AbstractString)

Parse a string formatted like "y=<number> by <number>" into a `RotateRow`
instruction
"""
function Base.parse(::Type{RotateRow}, s::AbstractString)
    re = r"y=(\d+) by (\d+)"
    row, shift = parse.(Int, match(re, s).captures)
    return RotateRow(row, shift)
end

"""
    Base.parse(::Type{RotateCol}, s::AbstractString)

Parse a string formatted like "x=<number> by <number>" into a `RotateCol`
instruction
"""
function Base.parse(::Type{RotateCol}, s::AbstractString)
    re = r"x=(\d+) by (\d+)"
    col, shift = parse.(Int, match(re, s).captures)
    return RotateCol(col, shift)
end

"""
    ingest(path)

Given a path to the input file, parse each line into an `Instruction` and return
the list of `Instruction`s.
"""
function ingest(path)
    instructions = Instruction[]
    open(path) do f
        for line in eachline(f)
            push!(instructions, parse(Instruction, line))
        end
    end
    return instructions
end
