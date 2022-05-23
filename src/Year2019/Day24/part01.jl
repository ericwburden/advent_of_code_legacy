"List of cardinal direction offsets"
const OFFSETS_2D = CartesianIndex.([(-1, 0), (1, 0), (0, -1), (0, 1)])

"""
    adjacent_bugs(grid::BitMatrix, idx::CartesianIndex) -> NTuple{N,CartesianIndex}

Identify and return a tuple of neighboring tiles that contain a bug.
"""
function adjacent_bugs(grid::BitMatrix, idx::CartesianIndex)
    inbounds(i) = checkbounds(Bool, grid, i)
    Tuple(grid[idx + o] for o in OFFSETS_2D if inbounds(idx + o))
end

"""
    next_state(grid::BitMatrix, idx::CartesianIndex) -> Bool

Determine and return whether the indicated `idx` should contain a bug in
the next state.
"""
function next_state(grid::BitMatrix, idx::CartesianIndex)
    neighbors = sum(adjacent_bugs(grid, idx))
    return neighbors == 1 || (neighbors == 2 && !grid[idx])
end

"""
    next_state(grid::BitMatrix) -> BitMatrix

Calculate and return the next state of the grid after one generation of
bugs has either died or spread.
"""
function next_state(grid::BitMatrix)::BitMatrix
    return map(i -> next_state(grid, i), CartesianIndices(grid))
end

"""
    biodiversity(grid::BitMatrix) -> Int

Calculate and return the biodiversity of the given grid state, as
described in the puzzle description.
"""
function biodiversity(grid::BitMatrix)
    total = 0
    for (r, row) in enumerate(eachrow(grid)), (c, col) in enumerate(row)
        col || continue
        pow = (c + ((r - 1) * 5)) - 1
        total += 2 ^ pow
    end
    return total
end

"""
    part1(input) -> Int

Given the input as a BitMatrix representing the locations of bugs on Eris,
simulate generations of bug growth and death until reaching a previously
seen state, and return the 'biodiversity' of that state.
"""
function part1(input)
    seen  = Set{BitMatrix}()
    state = input

    while state ∉ seen
        push!(seen, state)
        state = next_state(state)
    end

    return biodiversity(state)
end
