const Position   = NTuple{2,Int}
const CONST_A = 20183
const CONST_B = 16807
const CONST_C = 48271

"""
A `AbstractRegionKind` is used for sub-typing a region of the cave,
indicating what kind of terrain is in that region.
"""
abstract type     AbstractRegionKind end
struct Rocky   <: AbstractRegionKind end
struct Wet     <: AbstractRegionKind end
struct Narrow  <: AbstractRegionKind end
struct Unknown <: AbstractRegionKind end

"""
A `Region` represents one of the regions in the cave, including its
kind, position, and other metadata.
"""
struct Region{K <: AbstractRegionKind}
    kind::Type{K}
    position::Position
    geologic_index::Int
    erosion_level::Int
    risk::Int
end

"A default, unknown Region"
Region() = Region(Unknown, (-1, -1), -1, -1, -1)

"Useful constructor"
function Region(position::Position, geologic_index::Int, erosion_level::Int)
    risk = erosion_level % 3
    kind = if (risk == 0) Rocky elseif (risk == 1) Wet else Narrow end
    return Region(kind, position, geologic_index, erosion_level, risk)
end

"""
A `CaveMap` represents the map of the cave system, including the overall
depth and mapping of position to region.
"""
struct CaveMap
    depth::Int
    regions::Dict{Position,Region}
end

"Constructor for initial CaveMap state."
function CaveMap(depth::Int, target::Position)
    # Need to include `start_region` as an anchor point
    start_region  = Region(Rocky, (0, 0), 0, depth % CONST_A, 0)

    # Need to include `target_region` for special handling
    target_region = Region(Rocky, target, 0, depth % CONST_A, 0)

    regions = Dict((0, 0) => start_region, target => target_region)
    return CaveMap(depth, regions)
end

"""
    region_at!(cave_map::CaveMap, position::Position)

Given a position, returns the region at that position in the cave. Regions
are generate lazily, only being added to the set of mapped regions if
queried directly or required to generate another queried region.
"""
function region_at!(cave_map::CaveMap, position::Position)
    (; regions, depth) = cave_map
    haskey(regions, position) && return regions[position]
    geologic_index = if position[2] == 0
        (position[1] * CONST_B)
    elseif position[1] == 0
        (position[2] * CONST_C)
    else
        region_above   = region_at!(cave_map, position .+ (0, -1))
        region_left    = region_at!(cave_map, position .+ (-1, 0))
        region_above.erosion_level * region_left.erosion_level
    end
    erosion_level = (geologic_index + depth) % CONST_A
    region = Region(position, geologic_index, erosion_level)
    regions[position] = region
    return region
end

"""
    total_risk_to(cave_map::CaveMap, position::Position)

Calculate the total risk of a rectangular area of the cave map, anchored 
by the (0, 0) coordinate in the top left and by `position` in the bottom
right, inclusive.
"""
function total_risk_to(cave_map::CaveMap, position::Position)
    total_risk = 0
    max_x, max_y = position
    for xidx in 0:max_x, yidx in 0:max_y
        region = region_at!(cave_map, (xidx, yidx))
        total_risk += region.risk
    end
    return total_risk
end

"""
    part1(input)

Given the tuple of depth and target position as input, generate and calculate
the total risk of a rectangular region bounded by the start and target
coordinates.
"""
function part1(input)
    depth, target = input
    cave_map = CaveMap(depth, target)
    return total_risk_to(cave_map, target)
end

"Pretty printing"
function Base.show((; regions)::CaveMap)
    max_x, max_y = maximum(keys(regions))
    for row_idx in 0:max_y
        for col_idx in 0:max_x
            region = get(regions, (col_idx, row_idx), Region())
            region.kind isa Type{Rocky}   && print('.')
            region.kind isa Type{Wet}     && print('~')
            region.kind isa Type{Narrow}  && print('|')
            region.kind isa Type{Unknown} && print('?')
        end
        println()
    end
    println()
end
