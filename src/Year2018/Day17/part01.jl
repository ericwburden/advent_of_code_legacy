"More handy type aliases"
const Sand    = Union{DrySand,WetSand}
const Surface = Union{Clay,Water}
const Wet     = Union{Water,WetSand}
const Offset  = Tuple{Int,Int}

"Always default to a `DrySand` when fetching from the `ScanMap`"
function Base.get(scan_map::ScanMap, position::Position)
    return get(scan_map, position, DrySand())
end

"""
    get_environment(scan_map::ScanMap, position::Position)

Get the type of material at and below the current position
"""
function get_environment(scan_map::ScanMap, position::Position)
    offsets = [(0, 0), (0, 1)]
    return map(offset -> get(scan_map, position .+ offset), offsets)
end

"""
    flow!(scan_map::ScanMap, position::Position)

Given the mapped slice of ground and a current position, flow the water
from its current position to the next position, based on nearby materials.
Return the next positions to flow water through.
"""
function flow!(scan_map::ScanMap, position::Position)
    current, down = get_environment(scan_map, position)
    current isa DrySand && setindex!(scan_map, WetSand(), position)

    # If somehow the position is already wet, do nothing. Likewise
    # if the space below the current position is wet sand, meaning
    # water has already flowed through that way.
    current isa Water   && return []
    down    isa WetSand && return []

    # If there is dry sand below, flow down into it
    down isa DrySand && return [position .+ (0, 1)]

    # If there is a surface below, flow to either side, filling
    # any enclosed row with water
    down isa Surface && return fill!(scan_map, position)
end

"""
    fill!(scan_map::ScanMap, position::Position)

Given the mapped slice of ground and a current position, attempt to fill
the row of the current position with water if it is bounded on both sides
by clay and on the bottom by either clay or water. If either end of the
row is unbounded, return that position so water can continue to flow from
that point.
"""
function fill!(scan_map::ScanMap, position::Position)
    bounded_left,  left_positions,  left  = scan_row(scan_map, position, (-1, 0))
    bounded_right, right_positions, right = scan_row(scan_map, position, ( 1, 0))
    row_positions = vcat(left_positions, right_positions)

    # If bounded on the left and right, fill in the bounded row with water
    if bounded_left && bounded_right
        foreach(p -> scan_map[p] = Water(), row_positions)
        return [position .+ (0, -1)]
    end

    # Otherwise, return the unbounded positions
    next_positions = Position[]
    bounded_left  || push!(next_positions, left)
    bounded_right || push!(next_positions, right)
    return next_positions
end

"""
    scan_row(scan_map::ScanMap, position::Position, offset::Offset)

Check to the left or right (based on `offset`) of a given position to
determine which positions are in the row, whether it is bounded by
clay, and the position reached at the end of the row, returning all 
three in a tuple.
"""
function scan_row(scan_map::ScanMap, position::Position, offset::Offset)
    row_positions = Position[position]

    current, _, down, _ = get_environment(scan_map, position)
    while down isa Surface && current isa Sand
        scan_map[position] = WetSand()
        push!(row_positions, position) 
        position = position .+ offset
        current, _, down, _ = get_environment(scan_map, position)
    end

    bounded = current isa Clay
    return (bounded, row_positions, position)
end

"""
    part1(input)

Given the input as a scanned map of a slice of ground, simulate water
flowing through the ground, count the number of water and wet sand
positions at the end, and return the count.
"""
function part1(input)
    highest_level, lowest_level = extrema(p -> p[2], keys(input))
    flowing_squares = Position[(500, highest_level)]
    lowest_level = maximum(p -> p[2], keys(input))

    while !isempty(flowing_squares)
        water = pop!(flowing_squares)
        next = flow!(input, water)
        for position in next
            position[2] > lowest_level && continue
            push!(flowing_squares, position)
        end
    end

    total_wet = 0
    for square in values(input)
        square isa Wet && (total_wet += 1)
    end
    return total_wet
end

