const UP     = CartesianIndex(-1,  0)
const DOWN   = CartesianIndex( 1,  0)
const LEFT   = CartesianIndex( 0, -1)
const RIGHT  = CartesianIndex( 0,  1)

const Robots      = NTuple{4,AbstractTile}
const CostKeyBots = Tuple{Int,UInt32,Robots}

Base.isless(a::CostKeyBots, b::CostKeyBots) = a[1] == b[1] ? a[2] < b[2] : a[1] < b[1]

"""
    shortest_path(graph::CaveGraph, starts::Robots) -> Int

Given a `CaveGraph` and all the `start` tiles, use a modified Dijkstra's algorithm
to find the shortest path that touches all the keys and return the number of
steps in that path. Differs from part one by maintaining multiple paths at one
time, returning the combined length of all paths.
"""
function shortest_path(graph::CaveGraph, starts::Robots)
    all_keys = reduce(|, t.id for t in keys(graph) if t isa Key)
    open_set = BinaryMinHeap{CostKeyBots}([(0, UInt32(0), starts)])
    steps    = Dict{Tuple{UInt32,Robots},Int}((UInt32(0), starts) => 0)

    while !isempty(open_set)
        _, keyring, current = pop!(open_set)
        keyring == all_keys && return steps[(keyring, current)]

        for (idx, bot) in enumerate(current), (cost, keys_needed, next_key) in get(graph, bot, [])
            # If we don't have the keys needed to get there, skip it
            keys_needed & keyring == keys_needed || continue

            # If the found cost to the next tile is less than any 
            # previously found cost, add it to the heap with the new cost
            next_cost = steps[(keyring, current)] + cost
            next_keyring = next_key.id | keyring
            next_state   = Tuple(idx == i ? next_key : b for (i, b) in enumerate(current))
            prev_cost    = get(steps, (next_keyring, next_state), typemax(Int))

            if next_cost < prev_cost
                steps[(next_keyring, next_state)] = next_cost
                push!(open_set, (next_cost, next_keyring, next_state))
            end
        end
    end
end

"""
    part2(input) -> Int

Given the input as a matrix of `AbstractTile`s, modify the input by introducing walls
into the center and adding four `Entrances` around the walls. Convert the input into
a graph and find the shortest path through the graph that touches all keys.
Returns the number of steps in that path.
"""
function part2(input)
    # Create and update a copy of the cave system to split the
    # start into four separate starting zones
    caves = deepcopy(input)
    start_idx  = findfirst(t -> t isa Entrance, caves)
    caves[start_idx]         = Wall()
    caves[start_idx + UP]    = Wall()
    caves[start_idx + DOWN]  = Wall()
    caves[start_idx + LEFT]  = Wall()
    caves[start_idx + RIGHT] = Wall()
    caves[start_idx + UP   + LEFT]  = Entrance(start_idx + UP   + LEFT)
    caves[start_idx + DOWN + LEFT]  = Entrance(start_idx + DOWN + LEFT)
    caves[start_idx + UP   + RIGHT] = Entrance(start_idx + UP   + RIGHT)
    caves[start_idx + DOWN + RIGHT] = Entrance(start_idx + DOWN + RIGHT)

    cave_graph = graph_caves(caves)
    starts = Tuple(tile for tile in caves if tile isa Entrance)
    
    return shortest_path(cave_graph, starts)
end
