"""
    part2(input)

Given an adjacency matrix, calculate the distance traveled for each permutation
of the destinations and return the longest path length.
"""
function part2(input)
    route(p) = triplength(input, p)
    return mapreduce(route, max, permutations(input))
end