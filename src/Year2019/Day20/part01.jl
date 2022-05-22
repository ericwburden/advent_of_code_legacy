"""
An `AbstractMazeSpace` represents a walkable space in the `DonutMaze`,
either a simple `Path`, or a `Portal` to another location.
"""
abstract type  AbstractMazeSpace end

struct Path <: AbstractMazeSpace end

"The different kinds of portals"
@enum PortalPlace begin 
    inner
    outer
    entrance
    exit
end

struct Portal <: AbstractMazeSpace
    place::PortalPlace
end

"Handy constants"
const NORTH   = CartesianIndex(-1,  0)
const SOUTH   = CartesianIndex( 1,  0)
const EAST    = CartesianIndex( 0,  1)
const WEST    = CartesianIndex( 0, -1)
const OFFSETS = (NORTH, SOUTH, EAST, WEST)

"""
A `DonutMaze` encapsulates the locations of the spaces in the
maze and the connections between portals.
"""
struct DonutMaze
    spaces::Dict{CartesianIndex,AbstractMazeSpace}
    warps::Dict{CartesianIndex,CartesianIndex}
end

"""
A constructor that takes a character matrix and produces a `DonutMaze`
"""
function DonutMaze(chars::Matrix{Char})
    spaces  = Dict{CartesianIndex,AbstractMazeSpace}()
    portals = Dict{String,CartesianIndex}()
    warps   = Dict{CartesianIndex,CartesianIndex}()

    for idx in CartesianIndices(chars)
        chars[idx] == '.' || continue

        label = label_at(chars, idx)

        if isnothing(label)
            spaces[idx] = Path()
            continue
        end

        if label == "AA"
            spaces[idx] = Portal(entrance)
        elseif label == "ZZ"
            spaces[idx] = Portal(exit)
        else
            place = place_at(chars, idx)
            spaces[idx] = Portal(place)
        end

        if label ∈ keys(portals)
            warps[idx] = portals[label]
            warps[portals[label]] = idx
        else
            portals[label] = idx
        end
    end

    return DonutMaze(spaces, warps)
end

"""
    place_at(chars::Matrix{Char}, idx::CartesianIndex) -> PortalPlace

Returns the type of portal that can be found at a given index.
"""
function place_at(chars::Matrix{Char}, idx::CartesianIndex)
    rows, cols  = size(chars)
    top, bottom = (3, rows - 2)
    left, right = (3, cols - 2)
    is_outer = idx[1] == top || idx[1] == bottom || idx[2] == left || idx[2] == right
    return is_outer ? outer : inner
end

"""
    label_at(chars::Matrix{Char}, idx::CartesianIndex) -> Union{String,Nothing}

Returns the label for a portal at a given index, or `nothing` if the
`idx` doesn't refer to a portal.
"""
function label_at(chars::Matrix{Char}, idx::CartesianIndex)
    isletter(chars[idx + NORTH]) && return join([chars[idx + NORTH + NORTH], chars[idx + NORTH]])
    isletter(chars[idx + SOUTH]) && return join([chars[idx + SOUTH], chars[idx + SOUTH + SOUTH]])
    isletter(chars[idx + EAST])  && return join([chars[idx + EAST],  chars[idx + EAST  + EAST]])
    isletter(chars[idx + WEST])  && return join([chars[idx + WEST + WEST],   chars[idx + WEST]])
    return nothing
end

using DataStructures: BinaryMinHeap

"""
    find_start((; spaces)::DonutMaze) -> CartesianIndex

Find and return the index of the entrance portal to the maze.
"""
function find_start((; spaces)::DonutMaze)
    for (k, v) in spaces
        v == Portal(entrance) && return k
    end
end

"""
    neighbors_of((; spaces, warps)::DonutMaze, idx::CartesianIndex) -> Vector{CartesianIndex}

Return a list of the indices that can be reached from `idx`, taking portals
into account.
"""
function neighbors_of((; spaces, warps)::DonutMaze, idx::CartesianIndex)
    neighbors = CartesianIndex[]
    for offset in OFFSETS
        position = idx + offset
        position ∈ keys(spaces) || continue
        push!(neighbors, position)
    end

    idx ∈ keys(warps) && push!(neighbors, warps[idx])
    return neighbors
end

"""
    part1(input) -> Int

Find and return the number of steps in the shortest path through the maze
derived from the input character matrix.
"""
function part1(input)
    maze  = DonutMaze(input)
    start = find_start(maze)
    open  = BinaryMinHeap{Tuple{Int,CartesianIndex}}([(0, start)])
    steps = Dict{CartesianIndex,Int}(start => 0)

    while !isempty(open)
        _, current = pop!(open)
        maze.spaces[current] == Portal(exit) && return steps[current]

        for neighbor in neighbors_of(maze, current)
            next_steps = steps[current] + 1
            next_steps < get(steps, neighbor, typemax(Int)) || continue
            push!(open, (next_steps, neighbor))
            steps[neighbor] = next_steps
        end
    end
end
