using DataStructures: PriorityQueue, enqueue!, dequeue_pair!

"Structs to represent walls or doors for each room"
struct Wall end
struct Door end

"""
A `Room` represents a room in the facility, with either a wall or door
in each cardinal direction.
"""
struct Room
    north::Union{Type{Wall},Type{Door}}
    east::Union{Type{Wall},Type{Door}}
    south::Union{Type{Wall},Type{Door}}
    west::Union{Type{Wall},Type{Door}}
end
Room() = Room(Wall, Wall, Wall, Wall)

"""
    open_north(room::Room)
    open_east(room::Room)
    open_south(room::Room)
    open_west(room::Room)

Given a room, return a copy of that room with the relevant wall converted
into a `Door`.
"""
open_north((;  east, south,  west)::Room) = Room(Door,  east, south, west)
open_east((;  north, south,  west)::Room) = Room(north, Door, south, west)
open_south((; north,  east,  west)::Room) = Room(north, east, Door,  west)
open_west((;  north,  east, south)::Room) = Room(north, east, south, Door)

"Handy type aliases"
const Position    = NTuple{2,Int}
const FacilityMap = Dict{Position,Room}

"""
    parse(::Type{FacilityMap}, s::AbstractString)
    
Given the string from the input file, parse it into a `FacilityMap` and return
"""
function Base.parse(::Type{FacilityMap}, s::AbstractString)
    # Keep track of a stack of positions due to the recursive nature of
    # the directional instructions in the input
    stack    = Position[(0, 0)]
    facility = FacilityMap()

    for char in collect(s)
        current = pop!(stack)
        room    = get!(facility, current, Room())

        # If the current character is a letter indicating a direction, then
        # the room at the `current` position has the corresponding wall opened
        # into a door and the target room has it's complementary wall opened.
        # If there's no complementary room recorded, create one with only walls.
        # Move the `current` position to that next room.
        if     char == 'N'
            facility[current] = open_north(room)
            current = current .+ (-1, 0)
            room    = get!(facility, current, Room())
            facility[current] = open_south(room)
        elseif char == 'E' 
            facility[current] = open_east(room)
            current = current .+ (0, 1)
            room    = get!(facility, current, Room())
            facility[current] = open_west(room)
        elseif char == 'S' 
            facility[current] = open_south(room)
            current = current .+ (1, 0)
            room    = get!(facility, current, Room())
            facility[current] = open_north(room)
        elseif char == 'W' 
            facility[current] = open_west(room)
            current = current .+ (0, -1)
            room    = get!(facility, current, Room())
            facility[current] = open_east(room)
        elseif char == '(' 
            # A '(' indicates the start of a nested group, so we push the
            # `current` position to the stack so we can resume from that 
            # position once we leave the nested group.
            push!(stack, current)
        elseif char == ')' 
            # A ')' indicates the end of a nested group, so we just skip to
            # the next position in the stack, discarding the current position
            continue
        elseif char == '|' 
            # A '|' indicates an option in a nested group, meaning the next
            # direction will start at the same place as the group overall.
            # So, we reset the current position to the position it had when
            # the group started.
            current = last(stack)
        end

        push!(stack, current)
    end
    return facility
end

"""
    get_neighbors(room::Room, position::Position)

Given a room configuration and its current position, return positions for
all the rooms that are reachable from the current room.
"""
function get_neighbors((; north, east, south, west)::Room, position::Position)
    neighbors = Position[]
    north isa Type{Door} && push!(neighbors, position .+ (-1,  0))
    east  isa Type{Door} && push!(neighbors, position .+ ( 0,  1))
    south isa Type{Door} && push!(neighbors, position .+ ( 1,  0))
    west  isa Type{Door} && push!(neighbors, position .+ ( 0, -1))
    return neighbors
end

"""
    walk_facility(facility::FacilityMap)

Calculate the distance from the initial room to all other rooms in the `facility`,
using Dijkstra's algorithm.
"""
function walk_facility(facility::FacilityMap)
    queue = PriorityQueue{Position,Int}()
    enqueue!(queue, (0, 0), 0)
    cost_so_far = Dict{Position,Int}((0, 0) => 0)

    while !isempty(queue)
        position, _ = dequeue_pair!(queue)
        room = facility[position]

        for neighbor in get_neighbors(room, position)
            new_cost = cost_so_far[position] + 1
            if new_cost < get!(cost_so_far, neighbor, typemax(Int))
                cost_so_far[neighbor] = new_cost
                enqueue!(queue, neighbor, new_cost)
            end
        end
    end

    return cost_so_far
end

"""
    part1(input)

Parse the input string into a facility map, calculate the distances to all reachable
rooms from the origin, and return the maximum distance.
"""
function part1(input)
    facility = parse(FacilityMap, input)
    distances = walk_facility(facility)
    return maximum(values(distances))
end


#=------------------------------------------------------------------------------
# The following functions are used for pretty printing a facility map to make it
# easier to compare to the puzzle description and confirm functionality.
------------------------------------------------------------------------------=#

function Base.convert(::Type{Matrix{Char}}, (; north, east, south, west)::Room)
    output = fill('#', 3, 3)
    output[2, 2] = '.'
    north isa Type{Door} && (output[1, 2] = '-')
    east  isa Type{Door} && (output[2, 3] = '|')
    south isa Type{Door} && (output[3, 2] = '-')
    west  isa Type{Door} && (output[2, 1] = '|')
    return output
end

function Base.convert(::Type{Matrix{Char}}, facility::FacilityMap)
    min_idx, max_idx = extrema(keys(facility))
    rows = Matrix{Char}[]
    for row_idx in min_idx[1]:max_idx[1]
        row = fill('#', 3, 1)
        for col_idx in min_idx[2]:max_idx[2]
            room = get(facility, (row_idx, col_idx), Room())
            room_chars = convert(Matrix{Char}, room)
            (row_idx == 0 && col_idx == 0) && (room_chars[2,2] = 'X')
            row = hcat(row, room_chars[:,2:3])
        end
        push!(rows, row)
    end

    output = rows[1]
    for row in rows[2:end]
        output = vcat(output, row[2:3,:])
    end
    return output
end

function Base.show(facility::FacilityMap)
    facility_chars = convert(Matrix{Char}, facility)
    for row in eachrow(facility_chars)
        foreach(print, row)
        println()
    end
    println()
end

