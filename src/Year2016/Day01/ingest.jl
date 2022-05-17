using Match

abstract type AbstractTurn end

struct Right <: AbstractTurn
    distance::Int
end
struct Left <: AbstractTurn
    distance::Int
end

function Base.parse(::Type{AbstractTurn}, s::AbstractString)
    m = match(r"^(R|L)(\d+)$", s)
    (direction, distance) = m.captures
    @match direction begin
        "R" => Right(distance)
        "L" => Left(distance)
    end
end

Right(s::AbstractString) = parse(Int, s) |> Right
Left(s::AbstractString) = parse(Int, s) |> Left


function ingest(path)
    directions = AbstractTurn[]
    open(path) do f
        for d in split(readline(f), ", ")
            push!(directions, parse(AbstractTurn, d))
        end
    end
    return directions
end
