"""
    part2(input)

Given the input as a list of directions, follow each direction keeping track
of each location visited. Return the distance from the origin of the furthest
location.
"""
function part2(input)
    all_locations = accumulate(+, input, init = HexLocation())
    return maximum(distance_from_origin(l) for l in all_locations)
end
