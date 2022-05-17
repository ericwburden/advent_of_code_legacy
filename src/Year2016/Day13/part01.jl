using DataStructures: PriorityQueue, dequeue!, enqueue!

"""
    Position(x::Int, y::Int)

Represents a position in the maze of cubicles.
"""
struct Position
    x::Int
    y::Int
end

"Overloaded `+` for adding an offset to a `Position`"
Base.:+((; x, y)::Position, b::Tuple{Int,Int}) = Position(x + b[1], y + b[2])

"""
    is_open(x::Int, y::Int)

Calculates whether a given x/y coordinate is open (not a wall) according to
the algorithm given in the puzzle instructions.
"""
function is_open(x::Int, y::Int)
    binary = (x * x + 3x + 2 * x * y + y + y * y) + MAGIC_NUMBER
    return count_ones(binary) |> iseven
end

"""
    open_neighbors((; x, y)::Position)

Given a `Position`, return the adjacent `Position`s in the four cardinal
directions that are open and traversable. Only yields `Position`s where 
x and y are both non-negative.
"""
function open_neighbors((; x, y)::Position)
    neighbors = Position[]
    for (i, j) in ((1, 0), (0, 1), (-1, 0), (0, -1))
        x == 0 && i == -1 && continue
        y == 0 && j == -1 && continue
        is_open(x + i, y + j) && push!(neighbors, Position(x + i, y + j))
    end
    return neighbors
end

"""
    heuristic(current::Position, goal::Position)

Estimate the remaining distance from the `current` position to the `goal` using
the unobstructed taxicab distance.
"""
function heuristic(current::Position, goal::Position)
    return abs(current.x - goal.x) + abs(current.y - goal.y)
end

"""
    shortest_path(start::Position, goal::Position)

Calculate the shortest path from `start` to `goal` via an A* implementation.
"""
function shortest_path(start::Position, goal::Position)
    frontier = PriorityQueue{Position,Int}(start => 0)
    steps = Dict{Position,Int}(start => 0)

    while !isempty(frontier)
        current = dequeue!(frontier)
        current == goal && return steps[current]

        for next in open_neighbors(current)
            next ∈ keys(steps) && continue
            new_steps = steps[current] + 1
            if get!(steps, next, typemax(Int)) > new_steps
                priority = new_steps + heuristic(next, goal)
                steps[next] = new_steps
                frontier[next] = priority
            end
        end
    end
end

"Solve part one by returning the shortest distance from (1, 1) to (31, 39)"
function part1()
    return shortest_path(Position(1, 1), Position(7, 4))
end
