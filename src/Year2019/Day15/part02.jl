"""
    find_sensor(tiles::Vector{Vector{Tile}}) -> Tile

Given the list of values from a mapping of the ship, identify and return
the tile for the oxygen sensor.
"""
function find_sensor(tiles::Vector{Vector{Tile}})
    (tiles
        |> (x -> Iterators.flatten(x))
        |> (x -> Iterators.filter(t -> t isa Tile{O₂Sensor}, x))
        |> first)
end

"""
    part2(input) -> Int

Trace the ship using the robot to generate an adjancency list of `Tile`s, then,
using that adjacency list, conduct a breadth-first search from the oxygen sensor
to all other `Tile`s, returning the maximum number of steps to any other tile.
"""
function part2(input)
    ship_map = trace_map!(input)
    queue    = Queue{Tile}()
    start    = find_sensor(values(ship_map))
    steps    = Dict{Tile,Int}(start => 0)
    enqueue!(queue, start)

    while !isempty(queue)
        current = dequeue!(queue)
        
        steps_so_far = steps[current]
        for neighbor in ship_map[current.pos]
            neighbor ∈ keys(steps) && continue
            enqueue!(queue, neighbor)
            steps[neighbor] = steps_so_far + 1
        end
    end

    return maximum(values(steps))
end
