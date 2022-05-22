"Encapsulates the layer and index of a space in the maze"
const RecursiveIndex = Tuple{Int,CartesianIndex}

Base.:+(a::RecursiveIndex, b::CartesianIndex) = (a.first, a.second + b)

"""
    neighbors_of((; spaces, warps)::DonutMaze, recursive_idx::RecursiveIndex) -> Vector{RecursiveIndex}

Return a list of the indices that can be reached from `idx`, taking portals
and recursive layering into account.
"""
function neighbors_of((; spaces, warps)::DonutMaze, recursive_idx::RecursiveIndex)
    neighbors  = RecursiveIndex[]
    level, idx = recursive_idx
    for offset in OFFSETS
        position = idx + offset
        position ∈ keys(spaces) || continue
        push!(neighbors, (level, position))
    end

    # Outer portals only work below the top layer, returning the
    # walker to a previous layer. Inner portals take the walker to
    # a deeper layer.
    if idx ∈ keys(warps)
        portal = spaces[idx]
        if portal == Portal(inner)
            push!(neighbors, (level + 1, warps[idx]))
        end
        if level > 0 && portal == Portal(outer)
            push!(neighbors, (level - 1, warps[idx]))
        end
    end

    return neighbors
end

"""
    part2(input) -> Int

Find and return the number of steps in the shortest path through the maze
derived from the input character matrix. Takes into account the recursive
layering of Plutionan mazes.
"""
function part2(input)
    maze  = DonutMaze(input)
    start = find_start(maze)
    open  = BinaryMinHeap{Tuple{Int,RecursiveIndex}}([(0, (0, start))])
    steps = Dict{RecursiveIndex,Int}((0, start) => 0)

    while !isempty(open)
        _, (level, current) = pop!(open)
        if level == 0 && maze.spaces[current] == Portal(exit) 
            return steps[(level, current)]
        end

        for neighbor in neighbors_of(maze, (level, current))
            next_steps = steps[(level, current)] + 1
            next_steps < get(steps, neighbor, typemax(Int)) || continue
            push!(open, (next_steps, neighbor))
            steps[neighbor] = next_steps
        end
    end
end
