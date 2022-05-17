using DataStructures: PriorityQueue, enqueue!, dequeue!
using Combinatorics: permutations

"""
    neighbors(grid::BitMatrix, idx::CartesianIndex)

Given a BitMatrix representing movable spaces on the grid and an index into 
that matrix, return a list of all reachable neighboring spaces from that matrix.
"""
function neighbors(grid::BitMatrix, idx::CartesianIndex)
    offsets = [
        CartesianIndex(-1, 0),
        CartesianIndex(1, 0),
        CartesianIndex(0, -1),
        CartesianIndex(0, 1),
    ]
    possibles = filter(x -> checkbounds(Bool, grid, x), [idx] .+ offsets)
    return filter(x -> grid[x], possibles)
end

"""
    heuristic(current::CartesianIndex, goal::CartesianIndex)

A* heuristic, just the Manhattan distance from `current` to `goal`.
"""
function heuristic(current::CartesianIndex, goal::CartesianIndex)
    return mapreduce(abs, +, Tuple(current - goal))
end

"""
    shortest_path(grid::BitMatrix, start::CartesianIndex, goal::CartesianIndex)

A* algorithm, calculates the shortest path from `start` to `goal`. Backtracking
and path bookkeeping have been removed since they're not needed for this puzzle.
"""
function shortest_path(grid::BitMatrix, start::CartesianIndex, goal::CartesianIndex)
    frontier = PriorityQueue{CartesianIndex,Int}(start => 0)
    steps = Dict{CartesianIndex,Int}(start => 0)

    while !isempty(frontier)
        current = dequeue!(frontier)
        current == goal && return steps[current]

        for next in neighbors(grid, current)
            next ∈ keys(steps) && continue
            new_steps = steps[current] + 1
            if get!(steps, next, typemax(Int)) > new_steps
                priority = new_steps + heuristic(next, goal)
                steps[next] = new_steps
                frontier[next] = priority
            end
        end
    end
end

"""
    get_distances(grid::BitMatrix, poi::PointsOfInterest)

Given the grid of movable spaces and the locations of the labelled points of 
interest, calculate and return a mapping of all location pairs and the path
distance between them. Includes mappings for both (x, y) and (y, x) for each
pair of points.
"""
function get_distances(grid::BitMatrix, poi::PointsOfInterest)
    path_lengths = Dict{Tuple{Int,Int},Int}()

    for (start, startidx) in poi, (goal, goalidx) in poi
        start == goal && continue
        path_lengths[(start, goal)] = shortest_path(grid, startidx, goalidx)
        path_lengths[(goal, start)] = shortest_path(grid, startidx, goalidx)
    end

    return path_lengths
end

"""
    part1(input)

Tests each permutation of a list of the points of interest (starting with `0`)
to determine the total path length, then returns the smallest path length.
"""
function part1(input)
    grid, poi = input
    poi_labels = keys(poi) |> collect |> sort
    distances = get_distances(grid, poi)
    min_path = typemax(Int)

    for stops in permutations(poi_labels)
        stops[1] == 0 || continue
        path_length = mapreduce(x -> distances[x], +, zip(stops, stops[2:end]))
        min_path = min(min_path, path_length)
    end

    return min_path
end
