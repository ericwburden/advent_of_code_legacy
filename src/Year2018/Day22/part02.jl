using DataStructures: PriorityQueue, enqueue!, dequeue_pair!

"""
An `AbstractEquipmentKind` represents the kinds of equipment the traveler
may have for navigating the terrain, used for sub-typing `Traveler`.
"""
abstract type AbstractEquipmentKind end
struct ClimbingGear <: AbstractEquipmentKind end
struct Torch <: AbstractEquipmentKind end
struct Neither <: AbstractEquipmentKind end

"Making my way through caves, walking slow, wet and narrow, I'm climbing down..."
struct Traveler{E<:AbstractEquipmentKind}
    equipped::Type{E}
    position::Position
end

"Confirms a position is in the cave system"
function inbounds(position::Position)
    x, y = position
    return x >= 0 && y >= 0
end

"""
    get_nearby_regions(cave_map::CaveMap, position::Position)

Returns the regions surrounding `position` in cardinal directions that
are part of the cave system, accounting for edges.
"""
function get_nearby_regions(cave_map::CaveMap, position::Position)
    (
        nearby_regions =
            [(-1, 0), (1, 0), (0, -1), (0, 1)] |>
            (x -> Iterators.map(o -> position .+ o, x)) |>
            (x -> Iterators.filter(inbounds, x)) |>
            (x -> Iterators.map(p -> region_at!(cave_map, p), x))
    )
    return nearby_regions
end

"""
    can_move(::Traveler, ::Region)

These functions provide the set of rules as to whether a given traveler
(with their current equipment) can move into a given region.
"""
can_move(::Traveler{ClimbingGear}, ::Region{Rocky}) = true
can_move(::Traveler{ClimbingGear}, ::Region{Wet}) = true
can_move(::Traveler{ClimbingGear}, ::Region{Narrow}) = false
can_move(::Traveler{Torch}, ::Region{Rocky}) = true
can_move(::Traveler{Torch}, ::Region{Wet}) = false
can_move(::Traveler{Torch}, ::Region{Narrow}) = true
can_move(::Traveler{Neither}, ::Region{Rocky}) = false
can_move(::Traveler{Neither}, ::Region{Wet}) = true
can_move(::Traveler{Neither}, ::Region{Narrow}) = true

"Move a traveler to a region, unchecked"
function move_to_region((; equipped)::Traveler, (; position)::Region)
    return Traveler(equipped, position)
end

"""
    get_possible_moves(cave_map::CaveMap, traveler::Traveler)

Returns a list of (<traveler>, <cost>) tuples indicating possible next states
for the given traveler assuming they only move to a neighboring region with 
their current equipment.
"""
function get_possible_moves(cave_map::CaveMap, traveler::Traveler)
    (
        moves_to_nearby_locations =
            get_nearby_regions(cave_map, traveler.position) |>
            (x -> Iterators.filter(r -> can_move(traveler, r), x)) |>
            (x -> Iterators.map(r -> move_to_region(traveler, r), x)) |>
            (x -> Iterators.map(t -> (t, 1), x))
    )
    return moves_to_nearby_locations
end

"""
    get_equip_change(traveler::Traveler, ::Region)

Returns a (<traveler>, <cost>) tuple indicating the one next state a traveler
can be in if they change their equipment in place. The given puzzle rules mean
that there can only be one valid change for a given combination of traveler
equipment and region kind.
"""
function get_equip_change((; position)::Traveler{ClimbingGear}, ::Region{Rocky})
    return (Traveler(Torch, position), 7)
end

function get_equip_change((; position)::Traveler{Torch}, ::Region{Rocky})
    return (Traveler(ClimbingGear, position), 7)
end

function get_equip_change((; position)::Traveler{ClimbingGear}, ::Region{Wet})
    return (Traveler(Neither, position), 7)
end

function get_equip_change((; position)::Traveler{Neither}, ::Region{Wet})
    return (Traveler(ClimbingGear, position), 7)
end

function get_equip_change((; position)::Traveler{Torch}, ::Region{Narrow})
    return (Traveler(Neither, position), 7)
end

function get_equip_change((; position)::Traveler{Neither}, ::Region{Narrow})
    return (Traveler(Torch, position), 7)
end

"""
    get_next_states(cave_map::CaveMap, traveler::Traveler)

Returns an iterator over the (<traveler>, <cost>) pairs representing all the possible
states a traveler can reach from their given state, either by moving or changing
equipment.
"""
function get_next_states(cave_map::CaveMap, traveler::Traveler)
    region = region_at!(cave_map, traveler.position)
    equip_change = get_equip_change(traveler, region)
    possible_moves = get_possible_moves(cave_map, traveler)
    return Iterators.flatten((possible_moves, [equip_change]))
end

"Simple cost calculation, manhattan distance."
heuristic(a::Traveler, b::Traveler) = sum(abs.(a.position .- b.position))

"""
    shortest_path(cave_map::CaveMap, start::Traveler, target::Traveler)

A* implementation for finding the cost of the shortest path from the traveler's
`start` state and their `target` state, at the location of the injured friend.
"""
function shortest_path(cave_map::CaveMap, start::Traveler, target::Traveler)
    priority_queue = PriorityQueue{Traveler,Int}()
    travel_cost = Dict{Traveler,Int}(start => 0)
    enqueue!(priority_queue, start => 0)

    while !isempty(priority_queue)
        current, _ = dequeue_pair!(priority_queue)
        current == target && break

        for (next_state, cost) in get_next_states(cave_map, current)
            next_cost = travel_cost[current] + cost
            if next_cost < get!(travel_cost, next_state, typemax(Int))
                priority = next_cost + heuristic(next_state, target)
                priority_queue[next_state] = priority
                travel_cost[next_state] = next_cost
            end
        end
    end

    return travel_cost[target]
end

"""
    part2(input)

Given the input as a tuple of depth and target location, find the quickest path
from the start to the target location given the equipment and terrain constraints
described in the puzzle input. Return the time taken on the quickest path.
"""
function part2(input)
    depth, target = input
    cave_map = CaveMap(depth, target)
    traveler = Traveler(Torch, (0, 0))
    target = Traveler(Torch, target)
    return shortest_path(cave_map, traveler, target)
end
