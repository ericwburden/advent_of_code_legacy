"""
Loop through the list of frequency changes, applying them to the current
frequency, and storing the frequency in a Set. If the frequency is already
in the Set, return it. This is the one that has repeated first.
"""
function part2(input)
    index      = 1
    search_set = Set()
    frequency  = 0
    while true
        frequency += input[index]
        frequency ∈ search_set && break
        push!(search_set, frequency)
        index = index < length(input) ? index + 1 : 1
    end
    return frequency
end
