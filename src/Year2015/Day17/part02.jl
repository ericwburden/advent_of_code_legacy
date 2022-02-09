"""
    part2(vessels)

Given the input as a list of integers representing the capacities of a series
of vessels for storing eggnog, return the number of different combinations of
vessels among which the eggnog can be evenly and completely distributed, using
the fewest possible vessels.
"""
function part2(vessels)
    combinations = distribute(EGGNOG_VOLUME, vessels)
    min_vessels  = minimum(length.(combinations))
    return count(v -> length(v) == min_vessels, combinations)
end
