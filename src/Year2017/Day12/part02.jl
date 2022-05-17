"""
    part2(input)

Given the input as an adjacency list, identify how many disconnected groups
are present amongst all the programs and return that number.
"""
function part2(input)
    # Start with a set of all the programs
    all_values = Set(keys(input))
    groups = 0

    # Until all programs are accounted for, take one program from the set and
    # identify all programs that are reachable from that one. Remove those
    # programs from the set of all programs and increment the number of groups
    # by one.
    while !isempty(all_values)
        start_at = first(all_values)
        in_group = values_in_group(input, start_at)
        groups += 1
        setdiff!(all_values, in_group)
    end

    return groups
end
