"""
An `AbstractHeading` represents the direction a `Carrier` is currently facing,
one of the cardinal directions.
"""
abstract type AbstractHeading end
struct North <: AbstractHeading end
struct East  <: AbstractHeading end
struct South <: AbstractHeading end
struct West  <: AbstractHeading end

"""
A `Carrier` moves about the nodes, spreading the infection.
"""
struct Carrier{H <: AbstractHeading}
    position::Tuple{Int,Int}
    heading::Type{H}
end

const InfectedNodes = Set{Tuple{Int,Int}}

"""
    ingest(path)

Given a path to the input file, parse the character grid into a list of node
positions (only the infected nodes) and create a `Carrier` at the center of
the map heading `North`.
"""
function ingest(path)
    infected_nodes   = Set{Tuple{Int,Int}}()
    rows, cols = (0, 0)
    for (lat, line) in enumerate(readlines(path))
        rows += 1
        cols  = 0
        for (lon, char) in enumerate(collect(line))
            cols += 1
            char == '#' && push!(infected_nodes, (lat, lon))
        end
    end
    carrier_pos = (ceil(Int, rows / 2), ceil(Int, cols / 2))
    carrier = Carrier(carrier_pos, North)
    return (carrier, infected_nodes)
end
