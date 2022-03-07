using DataStructures: Queue, enqueue!, dequeue!

"""
    neighbors(idx::CartesianIndex, code::String) 

Given an index into the floor map and the current code (plus path), return a 
list of tuples in the format (<step>, <new index>).
"""
function neighbors(idx::CartesianIndex, code::String) 
    doors  = open_doors(FLOOR_MAP[idx], code)
    result = Tuple{Char,CartesianIndex}[]

    doors & 8 != 8 && push!(result, ('U', idx + CartesianIndex(-1, 0)))
    doors & 4 != 4 && push!(result, ('D', idx + CartesianIndex(1, 0)))
    doors & 2 != 2 && push!(result, ('L', idx + CartesianIndex(0, -1)))
    doors & 1 != 1 && push!(result, ('R', idx + CartesianIndex(0, 1)))

    return result
end

"""
    shortest_path(code::String, start::CartesianIndex, goal::CartesianIndex)

Given the initial passcode, a start index, and an goal index, determine the
shortest path (list of steps) from `start` to `goal`. Uses a breadth-first
search.
"""
function shortest_path(code::String, start::CartesianIndex, goal::CartesianIndex)
    queue = Queue{Tuple{String,CartesianIndex}}()
    enqueue!(queue, ("", start))

    while !isempty(queue)
        path, current = dequeue!(queue)
        current == goal && return path

        for (step, neighbor) in neighbors(current, code * path)
            enqueue!(queue, (path * step, neighbor))
        end
    end
    error("Could not find a path")
end

"""
    part1(input)

Given the input as a string representing the passcode, return a string
representing the lists of steps in the shortest path from the start to
the vault.
"""
function part1(input)
    return shortest_path(input, CartesianIndex(1, 1), CartesianIndex(4, 4))
end
