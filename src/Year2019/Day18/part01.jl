using DataStructures: BinaryMinHeap, Queue, enqueue!, dequeue!

const OFFSETS     = CartesianIndex.([(-1, 0), (1, 0), (0, -1), (0, 1)])
const NodeType    = Union{Key,Entrance}
const CostKeyTile = Tuple{Int,UInt32,AbstractTile}
const CaveGraph   = Dict{AbstractTile,Vector{CostKeyTile}}

"""
    graph_caves(caves::Caves)

Converts a `Caves` into an adjacency list, a Dict where the keys are `Key` or
`Entrance` tiles and the values are vectors of `CostKeyTile` tuples indicating
the other keys that can be reached, the number of steps to reach them, and
any keys needed to pass doors on the way to them.
"""
function graph_caves(caves::Caves)
    # The output graph will have one entry for each Key and Entrance
    graph = CaveGraph()
    nodes = [tile for tile in caves if tile isa NodeType]

    for tile in nodes
        # Performs a BFS starting with each Key or Entrance to find
        # the reachable Keys, without stepping over any Keys
        open_set = Queue{CostKeyTile}()
        enqueue!(open_set, (0, UInt32(0), tile))
        visited  = Set{AbstractTile}()
        graph[tile] = CostKeyTile[]

        while !isempty(open_set)
            steps, keyring, current = dequeue!(open_set)
            current ∈ visited && continue
            push!(visited, current)

            for offset in OFFSETS
                position  = current.idx + offset
                checkbounds(Bool, caves, position) || continue
                next_tile = caves[position]
                next_tile isa Wall  && continue
                next_tile ∈ visited && continue
                if next_tile isa Key
                    push!(graph[tile], (steps + 1, keyring, next_tile))
                elseif next_tile isa Door
                    next_keyring = keyring | next_tile.id
                    enqueue!(open_set, (steps + 1, next_keyring, next_tile))
                else
                    enqueue!(open_set, (steps + 1, keyring, next_tile))
                end
            end
        end
    end
    return graph
end

Base.isless(::AbstractTile, ::AbstractTile) = false

"""
    shortest_path(graph::CaveGraph, start::Entrance) -> Int

Given a `CaveGraph` and the `start` tile, use a modified Dijkstra's algorithm
to find the shortest path that touches all the keys and return the number of
steps in that path.
"""
function shortest_path(graph::CaveGraph, start::Entrance)
    open_set = BinaryMinHeap{CostKeyTile}([(0, UInt32(0), start)])
    steps    = Dict{Tuple{UInt32,AbstractTile},Int}((UInt32(0), start) => 0)
    all_keys = reduce(|, t.id for t in keys(graph) if t isa Key)

    while !isempty(open_set)
        _, keyring, current = pop!(open_set)
        keyring == all_keys && return steps[(keyring, current)]

        for (cost, keys_needed, next_key) in get(graph, current, [])
            # If we don't have the keys needed to get there, skip it
            keys_needed & keyring == keys_needed || continue

            # If the found cost to the next tile is less than any 
            # previously found cost, add it to the heap with the new cost
            next_cost = steps[(keyring, current)] + cost
            next_keyring = next_key.id | keyring
            next_cost < get(steps, (next_keyring, next_key), typemax(Int)) || continue
            steps[(next_keyring, next_key)] = next_cost
            push!(open_set, (next_cost, next_keyring, next_key))
        end
    end
end

"""
    part1(input) -> Int

Given the input as a matrix of `AbstractTile`s, convert the input to a 
graph and find the shortest path through the graph that touches all keys.
Returns the number of steps in that path.
"""
function part1(input)
    cave_graph = graph_caves(input)
    start_idx  = findfirst(t -> t isa Entrance, input)
    return shortest_path(cave_graph, input[start_idx])
end
