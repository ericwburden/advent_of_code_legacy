abstract type Direction end
struct North <: Direction end
struct South <: Direction end
struct East  <: Direction end
struct West  <: Direction end

const Directions = Vector{Direction}

function Base.parse(::Type{Direction}, c::Char)::Direction
    c == '^' && return North()
    c == '>' && return East()
    c == 'v' && return South()
    c == '<' && return West()
    error("Cannot parse $c to a Direction")
end

"""
    ingest(path)

Given the path to the input file, parses the single line of characters into
a vector of `Direction`s with the following mapping:
    - '^' => North
    - 'v' => South
    - '>' => East
    - '<' => West
"""
function ingest(path)
    directions = Directions()
    open(path) do f
        while !eof(f)
            nextchar = read(f, Char)
            push!(directions, parse(Direction, nextchar))
        end
    end
    return directions
end
