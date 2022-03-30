"""
    neighbors(bit_grid, idx)

Given a `bit_grid` (BitMatrix) and a cartesian index into that matrix, 
return a list of the valid indices that surround `idx`, in the four
cardinal directions.
"""
function neighbors(bit_grid, idx)
    neighbor_indices = []
    offsets = [(-1, 0), (1, 0), (0, -1), (0, 1)] 
    for offset in offsets
        neighbor = idx + CartesianIndex(offset...)
        checkbounds(Bool, bit_grid, neighbor) || continue
        bit_grid[neighbor] && push!(neighbor_indices, neighbor)
    end
    return neighbor_indices
end

"""
    get_group(bit_grid, idx)

Given a `bit_grid` (BitMatrix) and a cartesian index into that matrix,
return a set of all the cartesian indices that can be reached from that
index that contain `true`.
"""
function get_group(bit_grid, idx)
    stack = CartesianIndex[idx]
    seen  = Set{CartesianIndex}()

    while !isempty(stack)
        current = pop!(stack)
        current ∈ seen && continue
        push!(seen, current)

        for neighbor in neighbors(bit_grid, current)
            bit_grid[neighbor] || continue
            push!(stack, neighbor)
        end
    end

    return seen
end

"""
    count_groups(bit_grid)

Given a `bit_grid` (BitMatrix), search the grid for groups of `true` values
and return the count of groups.
"""
function count_groups(bit_grid)
    grouped_coords = Set{CartesianIndex}()
    found_groups   = 0

    for idx in CartesianIndices(bit_grid)
        bit_grid[idx]        || continue
        idx ∈ grouped_coords && continue
        group = get_group(bit_grid, idx)
        union!(grouped_coords, group)
        found_groups += 1
    end

    return found_groups
end

"""
    part2(input)

Given the input string, sequentially hash it and return the total number
of groups of 'on' bits.
"""
function part2(input)
    bitify(n) = seq2bits(input, n)
    bit_grid  = mapreduce(bitify, hcat, 0:127)
    return count_groups(bit_grid)
end
