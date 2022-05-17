"""
    part2(input)

Tests each permutation of a list of the points of interest (starting with `0`)
to determine the total path length of a path that visits all points of interest
before traveling back to `0`, then returns the smallest path length.
"""
function part2(input)
    grid, poi = input
    poi_labels = keys(poi) |> collect |> sort
    distances = get_distances(grid, poi)
    min_path = typemax(Int)

    for stops in permutations(poi_labels)
        stops[1] == 0 || continue
        push!(stops, 0)
        path_length = mapreduce(x -> distances[x], +, zip(stops, stops[2:end]))
        min_path = min(min_path, path_length)
    end

    return min_path
end
