#=------------------------------------------------------------------------------
| Instead of using `Set`s and `struct`s to represent the microchips, generators,
| and floors of the facility, this strategy represents each floor as an 
| unsigned integer whose bits indicate which microchips and generators are
| present on the floor. This speeds up the calculations considerably.
------------------------------------------------------------------------------=#

using DataStructures: PriorityQueue, dequeue!, enqueue!

"""
Use a UInt to represent a given floor in the facility, whose bits represent
the components present on that floor. Bits alternate between generators and 
microchips, paired per element such that every other bit starting with 1
represents a Microchip, interleaved with Generators. Elements can be accessed
as multiples of 4 according to the following mapping:

4⁰ =>     1 => Curium   
4¹ =>     4 => Elerium  
4² =>    16 => Dilithium
4³ =>    64 => Hydrogen 
4⁴ =>   256 => Lithium  
4⁵ =>  1024 => Plutonium
4⁶ =>  4096 => Ruthenium
4⁷ => 16384 => Strontium
4⁸ => 65536 => Thulium  

This results in the following example relationships:
- All microchips    => sum(4 .^ (0:8))      => 87381
- All generators    => sum(4 .^ (0:8)) << 1 => 174762
- Lithium Microchip => 4⁴                   => 256
- Lithium Generator => 4⁴ × 2               => 512
"""
const MAX_ELEMENTS = 9
const MICROCHIP_LIST = 4 .^ (0:(MAX_ELEMENTS-1))
const GENERATOR_LIST = MICROCHIP_LIST .<< 1
const SHIELDED_PAIRS = MICROCHIP_LIST .+ GENERATOR_LIST
const ALL_MICROCHIPS = sum(MICROCHIP_LIST)
const ALL_GENERATORS = sum(GENERATOR_LIST)

const Facility = Tuple{Int,Vector{UInt}}

const TEST_START = (1, [UInt(320), UInt(128), UInt(512), UInt(0)])
const TEST_GOAL = (4, [UInt(0), UInt(0), UInt(0), UInt(960)])

const INPUT1_START = (1, [UInt(52224), UInt(143363), UInt(65536), UInt(0)])
const INPUT1_GOAL = (4, [UInt(0), UInt(0), UInt(0), UInt(261123)])

const INPUT2_START = (1, [UInt(52284), UInt(143363), UInt(65536), UInt(0)])
const INPUT2_GOAL = (4, [UInt(0), UInt(0), UInt(0), UInt(261183)])


"""
    is_stable(repr::UInt)

Check a floor for any un-matched microchips in the presence of one or more
generators. If there are no generators on a floor, it's inherently stable. 
Unmatched generators are also ok, but a microchip on a floor without it's 
matching generator in the presence of a second generator will fail.
"""
function is_stable(repr::UInt)
    generators = repr & ALL_GENERATORS
    generators == 0 && return true
    microchips = repr & ALL_MICROCHIPS
    unmatched = (generators >> 1) ⊻ microchips
    return (unmatched & microchips == 0)
end


"""
    shielded_pairs(repr::UInt) 

Given a representation of a set of components, return an iterator yielding each
matched pair of microchip/generator, wherein the generator protects the 
microchip from irradiation.
"""
function shielded_pairs(repr::UInt)
    return filter(sp -> repr & sp == sp, SHIELDED_PAIRS)
end


"""
    microchip_pairs(repr::UInt)

Given a representation of a set of components, return a list of the unique
pairs of microchips.
"""
function microchip_pairs(repr::UInt)
    sent = UInt(0)
    microchips = repr & ALL_MICROCHIPS
    output = []
    for chip1 in microchips .& MICROCHIP_LIST
        chip1 == 0 && continue
        for chip2 in microchips .& MICROCHIP_LIST
            chip2 == 0 && continue
            chip1 == chip2 && continue
            microchips = chip1 + chip2
            sent & microchips == microchips && continue
            push!(output, microchips)
            sent |= microchips
        end
    end
    return output
end


"""
    generator_pairs(repr::UInt)

Given a representation of a set of components, return a list of the unique
pairs of generators.
"""
function generator_pairs(repr::UInt)
    sent = UInt(0)
    generators = repr & ALL_GENERATORS
    output = []
    for gen1 in generators .& GENERATOR_LIST
        gen1 == 0 && continue
        for gen2 in generators .& GENERATOR_LIST
            gen2 == 0 && continue
            gen1 == gen2 && continue
            generators = gen1 + gen2
            sent & generators == generators && continue
            push!(output, generators)
            sent |= generators
        end
    end
    return output
end


"""
    can_move_up(repr::UInt)

Given representation of a set of components (bare or in a `Floor`), return 
an iterator yielding each individual microchip and generator, in turn. We should
never consider moving more than one component away from the target floor at a
time.
"""
function can_move_up(repr::UInt)
    chips = Iterators.filter(m -> m & repr == m, MICROCHIP_LIST)
    gens = Iterators.filter(g -> g & repr == g, GENERATOR_LIST)
    return Iterators.flatten((chips, gens))
end


"""
    can_move_down(repr::UInt)

Given representation of a set of components (bare or in a `Floor`), return 
an iterator yielding each combination of one or two components that can be
transported on an elevator. Moving pairs of components towards the goal is 
preferable to moving single components, so single components will only be 
provided when that single component was not previously yielded as part of a 
pair.
"""
function can_move_down(repr::UInt)
    # Send all shielded pairs of microchip/generator, all unduplicated
    # pairs of microchips, all unduplicated pairs of generators, and 
    # each individual component
    iter_fns = (shielded_pairs, microchip_pairs, generator_pairs, can_move_up)
    iters = Iterators.map(fn -> fn(repr), iter_fns)
    return Iterators.flatten(iters)
end


"""
    next_states(facility::Facility)

Given the current state of the components and elevator, return a list of the
possible stable states that can be reached by moving one or two components 
up or down in the elevator.
"""
function next_states(facility::Facility)
    current, floors = facility
    possibilities = Facility[]
    for (offset, fn) in ((-1, can_move_up), (1, can_move_down))
        next = current + offset
        (next < 1 || next > 4) && continue
        for movable in fn(floors[current])
            remaining = floors[current] & ~movable
            is_stable(remaining) || continue

            new_floor = floors[next] | movable
            is_stable(new_floor) || continue

            next_floors = [floors...]
            next_floors[current] = remaining
            next_floors[next] = new_floor
            push!(possibilities, (next, next_floors))
        end
    end
    return possibilities
end


"""
    heuristic(facility::Facility)

Given the current state of the components and elevator, calculate the estimated
number of steps remaining to find the solution. This estimate is used in the 
A* search algorithm.
"""
function heuristic(facility::Facility)
    _, floors = facility
    total = 0
    for (idx, floor) in enumerate(floors)
        multiplier = (length(floors) - idx)
        total += count_ones(floor) * multiplier
    end
    return total
end


"""
    floor_id(floor::UInt)

Given the bits representing the components on a floor, produce bits representing
the identity of that floor, treating all shielded pairs as equivalent.
"""
function floor_id(floor::UInt)
    shielded_pair_count = 0
    for shielded_pair in SHIELDED_PAIRS
        floor & shielded_pair == shielded_pair || continue
        shielded_pair_count += 1
        floor = floor & ~shielded_pair
    end

    # Store the count of shielded pairs in the largest 4 bits
    shielded_pair_bits = UInt(shielded_pair_count) << 60
    return (shielded_pair_bits | floor)
end


"""
    Base.hash(facility::Facility)
    Base.:(==)(a::Facility, b::Facility)
    Base.isequal(a::Facility, b::Facility)

Instead of using the default hashing and equality for a `Facility`, modify 
so that all shielded pairs are treated equivalently, reducing the total search
space.
"""
function Base.hash(facility::Facility)
    current, floors = facility
    current_hash = hash(current)
    for floor in floors
        current_hash = hash(floor_id(floor), current_hash)
    end
    return current_hash
end

Base.:(==)(a::Facility, b::Facility) = hash(a) == hash(b)
Base.isequal(a::Facility, b::Facility) = hash(a) == hash(b)



"""
    shortest_path(start::Facility, goal::Facility)

Given a starting and ending `Facility`, calculate and return the number of steps
needed to bring all components to the fourth floor.
"""
function shortest_path(start::Facility, goal::Facility)
    frontier = PriorityQueue{Facility,Int}(start => 0)
    steps = Dict{Facility,Int}(start => 0)

    while !isempty(frontier)
        current = dequeue!(frontier)
        current == goal && return steps[current]

        for next in next_states(current)
            next ∈ keys(steps) && continue
            new_steps = steps[current] + 1
            if get!(steps, next, typemax(Int)) > new_steps
                priority = new_steps + heuristic(next)
                steps[next] = new_steps
                frontier[next] = priority
            end
        end
    end
end

part1() = shortest_path(INPUT1_START, INPUT1_GOAL)
part2() = shortest_path(INPUT2_START, INPUT2_GOAL)
