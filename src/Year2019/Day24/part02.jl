"Handy static mappings of grid spaces to spaces in a parent recursive grid"
const OUTER_MAP = Dict(
    CartesianIndex(1, 1) => [CartesianIndex(2, 3), CartesianIndex(3, 2)],
    CartesianIndex(1, 5) => [CartesianIndex(2, 3), CartesianIndex(3, 4)],
    CartesianIndex(5, 1) => [CartesianIndex(3, 2), CartesianIndex(4, 3)],
    CartesianIndex(5, 5) => [CartesianIndex(3, 4), CartesianIndex(4, 3)],
    CartesianIndex(1, 2) => [CartesianIndex(2, 3)],
    CartesianIndex(1, 3) => [CartesianIndex(2, 3)],
    CartesianIndex(1, 4) => [CartesianIndex(2, 3)],
    CartesianIndex(2, 1) => [CartesianIndex(3, 2)],
    CartesianIndex(3, 1) => [CartesianIndex(3, 2)],
    CartesianIndex(4, 1) => [CartesianIndex(3, 2)],
    CartesianIndex(2, 5) => [CartesianIndex(3, 4)],
    CartesianIndex(3, 5) => [CartesianIndex(3, 4)],
    CartesianIndex(4, 5) => [CartesianIndex(3, 4)], 
    CartesianIndex(5, 2) => [CartesianIndex(4, 3)],
    CartesianIndex(5, 3) => [CartesianIndex(4, 3)],
    CartesianIndex(5, 4) => [CartesianIndex(4, 3)],
)

"Handy static mappings of grid spaces to spaces in a child recursive grid"
const INNER_MAP = Dict(
    CartesianIndex(2, 3) => CartesianIndex.([(1, 1), (1, 2), (1, 3), (1, 4), (1, 5)]),
    CartesianIndex(3, 2) => CartesianIndex.([(1, 1), (2, 1), (3, 1), (4, 1), (5, 1)]),
    CartesianIndex(3, 4) => CartesianIndex.([(1, 5), (2, 5), (3, 5), (4, 5), (5, 5)]),
    CartesianIndex(4, 3) => CartesianIndex.([(5, 1), (5, 2), (5, 3), (5, 4), (5, 5)]),
)

"Represents tiles on a recursive grid (layer, index) that have a bug"
const RecursiveGrid = Set{Tuple{Int,CartesianIndex}}

"""
    recursive_grid(grid::BitMatrix) -> RecursiveGrid

Convert a BitMatrix parsed from the input file into a `RecursiveGrid`, where
each entry represents a tile with a bug on it.
"""
function recursive_grid(grid::BitMatrix)
    new_grid = RecursiveGrid()
    for idx in CartesianIndices(grid)
        grid[idx] || continue
        push!(new_grid, (0, idx))
    end
    return new_grid
end

"""
    next_state(grid::RecursiveGrid) -> RecursiveGrid

Calculate and return a `RecursiveGrid` representing the next state after
a generation of bug growth/death.
"""
function next_state(grid::RecursiveGrid)::RecursiveGrid
    neighbors = Dict()

    # Calculate the number of neighbors each tile has
    for tile in grid
        layer, idx = tile

        # For any recursive parent tiles
        for parent_idx in get(OUTER_MAP, idx, [])
            key = (layer - 1, parent_idx)
            key ∈ keys(neighbors) || (neighbors[key] = 0)
            neighbors[key] += 1
        end

        # For any recursive child tiles
        for child_idx in get(INNER_MAP, idx, [])
            key = (layer + 1, child_idx)
            key ∈ keys(neighbors) || (neighbors[key] = 0)
            neighbors[key] += 1
        end

        # For any same-layer neighbors
        for offset in OFFSETS_2D
            neighbor_idx = idx + offset
            1 <= neighbor_idx[1] <= 5 || continue
            1 <= neighbor_idx[2] <= 5 || continue
            neighbor_idx == CartesianIndex(3, 3) && continue
            key = (layer, neighbor_idx)
            key ∈ keys(neighbors) || (neighbors[key] = 0)
            neighbors[key] += 1
        end
    end

    # Return tiles that will have a bug on them in the next generation
    return Set(k for (k, v) in neighbors if (v == 1 || (v == 2 && k ∉ grid)))
end

"""
    part2(input) -> Int

Simulate 200 generations of bug growth/death, returning the number of tiles
with bugs on them after 200 generations.
"""
function part2(input)
    state = recursive_grid(input)
    foreach(_ -> state = next_state(state), 1:200)
    return length(state)
end
