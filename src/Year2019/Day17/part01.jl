const Position = NTuple{2,Int}

function is_intersection(m::Matrix{Char}, p::CartesianIndex)
    offsets = map(CartesianIndex, [(-1, 0), (1, 0), (0, -1), (0, 1)])
    for offset in offsets
        check_pos = p + offset
        checkbounds(Bool, m, check_pos) || continue
        m[check_pos] == '.' && return false
    end
    return true
end

function find_intersections(scaffold::Matrix{Char})
    intersections = Position[]
    for p in CartesianIndices(scaffold)
        scaffold[p] == '#' || continue
        is_intersection(scaffold, p) || continue
        push!(intersections, Tuple(p) .- 1)
    end
    return intersections
end

function part1(input)
    scaffold      = scaffolds(input)
    intersections = find_intersections(scaffold)
    return mapreduce(prod, +, intersections)
end
