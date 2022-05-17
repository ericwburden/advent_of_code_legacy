using DataStructures: Queue, enqueue!, dequeue!

"""
    values_in_group(input, origin)

Given the input as an adjacency list and a program (Int) to begin searching
from, identify and return a set of all programs that can be reached from
the `origin`. Uses a pretty standard BFS.
"""
function values_in_group(input, origin)
    queue = Queue{Int}()
    enqueue!(queue, origin)
    found = Set([origin])
    seen = Set()

    while !isempty(queue)
        current = dequeue!(queue)
        current ∈ seen && continue

        for next in input[current]
            push!(found, next)
            enqueue!(queue, next)
        end
        push!(seen, current)
    end

    return found
end

"""
    part1(input)

Given the input as an adjacency list, search the list for all programs that 
are reachable from program `0` and return the size of that group.
"""
function part1(input)
    in_group = values_in_group(input, 0)
    return length(in_group)
end
