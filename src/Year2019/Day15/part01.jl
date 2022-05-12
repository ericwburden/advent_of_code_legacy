using DataStructures: Queue, enqueue!, dequeue!

"""
    part1(input) -> Int

Trace the ship using the robot to generate an adjancency list of `Tile`s, then,
using that adjacency list, conduct a breadth-first search from the origin to
find the oxygen sensor, returning the minimum number of steps to reach the
oxygen sensor.
"""
function part1(input)
    ship_map = trace_map!(input)
    queue    = Queue{Tile}()
    start    = Tile(Hall, (0, 0)) # Origin
    steps    = Dict{Tile,Int}(start => 0)
    enqueue!(queue, start)

    while !isempty(queue)
        current = dequeue!(queue)
        current isa Tile{O₂Sensor} && return steps[current]
        
        steps_so_far = steps[current]
        for neighbor in ship_map[current.pos]
            neighbor ∈ keys(steps) && continue
            enqueue!(queue, neighbor)
            steps[neighbor] = steps_so_far + 1
        end
    end
end
