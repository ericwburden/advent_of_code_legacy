const ACCEPTABLE_DISTANCE = 10_000

"""
    part2(input)

Given the input as a list of possible destinations, determine and return the
size of a region where each location's cumulative distance from all destinations
is less than the `ACCEPTABLE_DISTANCE`.
"""
function part2(input)
    safe_region = Location[]
    for location = CartesianIndex(1, 1):maximum(input)
        total_distance = sum(d -> distance(location, d), input)
        total_distance < ACCEPTABLE_DISTANCE && push!(safe_region, location)
    end
    return length(safe_region)
end
