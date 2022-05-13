const Position = NTuple{2,Int}

"""
    is_intersection(m::Matrix{Char}, p::CartesianIndex) -> Bool
    
Indicates whether a given coordinate represents an intersection, that is,
there is a scaffolding tile in all four cardinal directions.
"""
function is_intersection(m::Matrix{Char}, p::CartesianIndex)
    offsets = map(CartesianIndex, [(-1, 0), (1, 0), (0, -1), (0, 1)])
    for offset in offsets
        check_pos = p + offset
        checkbounds(Bool, m, check_pos) || continue
        m[check_pos] == '.' && return false
    end
    return true
end

"""
    find_intersections(scaffold::Matrix{Char}) -> Int

Given a character matrix representation of the scaffolding, count and
return the number of intersections.
"""
function find_intersections(scaffold::Matrix{Char})
    intersections = Position[]
    for p in CartesianIndices(scaffold)
        scaffold[p] == '#' || continue
        is_intersection(scaffold, p) || continue
        push!(intersections, Tuple(p) .- 1)
    end
    return intersections
end

"""
    part1(input) -> Int

Given the input program, run it through the ASCII program to generate a
map of the scaffolding, then count and return the number of intersections.
"""
function part1(input)
    scaffold      = scaffolds(input)
    intersections = find_intersections(scaffold)
    return mapreduce(prod, +, intersections)
end
