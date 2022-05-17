using DataStructures: Queue

"""
    reachable_spaces(start::Position, max_steps::Int)

Count the spaces that are reachable from the `start` in at most `max_steps` 
steps. Uses a standard breadth-first search.
"""
function reachable_spaces(start::Position, max_steps::Int)
    queue = Queue{Position}()
    enqueue!(queue, start)
    steps = Dict{Position,Int}(start => 0)
    visited = Set{Position}()

    while !isempty(queue)
        current = dequeue!(queue)
        current ∈ visited && continue
        steps[current] > max_steps && continue

        for next in open_neighbors(current)
            next ∈ keys(steps) && continue
            steps[next] = steps[current] + 1
            enqueue!(queue, next)
        end
        push!(visited, current)
    end

    return length(visited)
end


"""
Solve part two by returning the count of spaces that can be reached from (1, 1)
in 50 steps or fewer.
"""
function part2()
    return reachable_spaces(Position(1, 1), 50)
end
