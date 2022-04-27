"""
    part2(input)

Parse the input string into a facility map, calculate the distances to all reachable
rooms from the origin, and return the number of rooms at least 1000 steps from the
origin.
"""
function part2(input)
    facility = parse(FacilityMap, input)
    distances = walk_facility(facility)
    return count(d -> d >= 1000, values(distances))
end
