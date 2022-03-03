using DataStructures: PriorityQueue, enqueue!, dequeue!
using IterTools: subsets

match(microchip::Microchip, generator::Generator) = microchip.element == generator.element

has_complement((; element)::Microchip, components::Components) = Generator(element) ∈ components
has_complement((; element)::Generator, components::Components) = Microchip(element) ∈ components


function matched(components::Components)
    matched_components = Components()
    for (component1, component2) in Iterators.product(components, components)
        typeof(component1) == typeof(component2) && continue
        component1.element == component2.element || continue
        push!(matched_components, component1)
        push!(matched_components, component2)
    end
    return matched_components
end

unmatched(components::Components) = setdiff(components, matched(components))

function is_stable(components::Components)
    unmatched_components = unmatched(components)
    unmatched_chip = any(x -> x isa Microchip, unmatched_components)
    any_generator  = any(x -> x isa Generator, components)
    return !(unmatched_chip && any_generator)
end

const MovableSets = Set{NTuple{2,Components}}
function movable(components::Components)
    movable_sets = MovableSets()

    # Get the individual movable components
    for component in components
        moving    = Components([component])
        remaining = setdiff(components, moving)
        is_stable(remaining) && push!(movable_sets, (moving, remaining))
    end

    # Get the pairs of movable components
    for subset in subsets(collect(components), 2)
        moving    = Components(subset)
        remaining = setdiff(components, moving)
        if is_stable(moving) && is_stable(remaining) 
            push!(movable_sets, (moving, remaining))
        end
    end

    return movable_sets
end

function movable_up(components::Components)
    # We never want to move more than one item away from the goal floor at
    # a time
    movable_sets = MovableSets()

    for component in components
        moving    = Components([component])
        remaining = setdiff(components, moving)
        is_stable(remaining) && push!(movable_sets, (moving, remaining))
    end

    return movable_sets
end

function movable_down(components::Components)
    moved        = Components()
    movable_sets = MovableSets()

    # Get the pairs of movable components
    for subset in subsets(collect(components), 2)
        moving    = Components(subset)
        remaining = setdiff(components, moving)
        (is_stable(moving) && is_stable(remaining)) || continue
        push!(movable_sets, (moving, remaining))
        moved = moved ∪ moving
    end

    # Only consider moving individual components towards the goal if that
    # component is not already being moved as a pair.
    for component in components
        component ∈ moved && continue
        moving    = Components([component])
        remaining = setdiff(components, moving)
        is_stable(remaining) && push!(movable_sets, (moving, remaining))
    end

    return movable_sets
end


function next_states((; current, floors)::Facility)
    possibilities = Facility[]

    params = []
    current > 1 && push!(params, (current - 1, movable_up))
    current < 4 && push!(params, (current + 1, movable_down))

    for (next, fn) in params
        for (movable, remaining) in fn(floors[current])
            possible_components = floors[next] ∪ movable
            is_stable(possible_components) || continue

            next_floors          = deepcopy(floors)
            next_floors[current] = remaining
            next_floors[next]    = possible_components
            possibility          = Facility(next, next_floors)

            push!(possibilities, possibility)
        end
    end


    return possibilities
end

function heuristic((; current, floors)::Facility)
    total = 0
    for (idx, floor) in enumerate(floors)
        multiplier = (length(floors) - idx) + abs(current - idx)
        total += multiplier * length(floor)
    end
    return total
end

function Base.:(==)(a::Facility, b::Facility)
    a.current == b.current || return false
    for (a_floor, b_floor) in zip(a.floors, b.floors)
        issetequal(a_floor, b_floor) || return false
    end
    return true
end

function Base.hash((; current, floors)::Facility)
    current_hash = hash(current)
    for floor in floors
        current_hash = hash(floor, current_hash)
    end
    return current_hash
end

const Directions = Dict{Facility,Union{Nothing,Facility}}
function shortest_path(start::Facility, goal::Facility)
    frontier = PriorityQueue{Facility,Int}()
    enqueue!(frontier, start, 0)

    steps = Dict{Facility,Int}()
    steps[start] = 0

    while !isempty(frontier)
        current = dequeue!(frontier)
        current == goal && return steps[current]

        for next in next_states(current)
            next ∈ keys(steps) && continue
            new_steps = steps[current] + 1
            if get!(steps, next, typemax(Int)) > new_steps
                priority       = new_steps + heuristic(next)
                steps[next]    = new_steps
                frontier[next] = priority
            end
        end
    end
    error("Could not find a path!")
end

part1() = shortest_path(INPUT1_START, INPUT1_GOAL)
part2() = shortest_path(INPUT2_START, INPUT2_GOAL)
