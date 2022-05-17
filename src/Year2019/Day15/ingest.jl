# Include path for testing in the REPL
# include("src/Year2019/IntCode.jl")

using .IntCode: Computer, Running, Halted, add_input!, get_output!, run!

"Read a comma-separated list of numbers"
ingest(path) = parse.(Int, split(readline(path), ","))

const Position = NTuple{2,Int}

"Used to sub-type a Tile"
abstract type AbstractTileKind end
struct Hall <: AbstractTileKind end
struct O₂Sensor <: AbstractTileKind end

"An open space in the maze, either a hallway or the oxygen sensor"
struct Tile{K<:AbstractTileKind}
    kind::Type{K}
    pos::Position
end

"""
    move_bot!(computer::Computer, direction::Int) -> (Computer, Int)

Given the computer running the robot and an integer specifying direction
(according to puzzle instructions), pass the integer to the computer as
input and return the computer and output as the result.
"""
function move_bot!(computer::Computer, direction::Int)
    add_input!(computer, direction)
    computer = run!(computer)
    found = get_output!(computer)
    return (computer, found)
end

"""
    trace_map!(input::Vector{Int}) -> Dict{Position,Vector{Tile}}

Given the input program, pass the program to a `Computer` controlling a
robot and trace the path through the ship, returning a Dict as an 
adjacency list of positions and reachable `Tile`s.
"""
function trace_map!(input::Vector{Int})
    computer = Computer(input)
    ship_map = Dict{Position,Vector{Tile}}()

    # Up, down, left, and right
    offsets = Dict(1 => (-1, 0), 2 => (1, 0), 3 => (0, -1), 4 => (0, 1))

    # This inner recursive function attempts to follow the paths
    # branching from the input position, moving the bot back to 
    # it's starting position afterward.
    function inner_rec(pos::Position)
        # (up, down), (down, up), (left, right), (right, left)
        for (there, back) in ((1, 2), (2, 1), (3, 4), (4, 3))
            next_pos = pos .+ offsets[there]

            computer, found = move_bot!(computer, there)
            current = get!(ship_map, pos, [])

            found == 0 && continue
            found == 1 && push!(current, Tile(Hall, next_pos))
            found == 2 && push!(current, Tile(O₂Sensor, next_pos))

            next_pos ∈ keys(ship_map) || inner_rec(next_pos)
            computer, _ = move_bot!(computer, back)
        end
    end

    inner_rec((0, 0))
    return ship_map
end
