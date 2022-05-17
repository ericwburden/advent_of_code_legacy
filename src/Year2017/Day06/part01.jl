"""
    first_largest(values)

Given an iterable list of numbers, return the largest value and its index. If 
there are multiple largest values, return the first index found. Returns 
(<index>, <value>).
"""
function first_largest(values)
    found = nothing
    largest = first(values) |> typemin

    for (idx, value) in enumerate(values)
        if (value > largest)
            found = (idx, value)
            largest = value
        end
    end

    return found
end

"""
    redistribute(values)

Given an iterable list of numbers, set the largest index to `0` and add its
value to each subsequent index (wrapping around) one at a time.
"""
function redistribute!(values)
    next_idx(i) = (i % length(values)) + 1
    idx, value = first_largest(values)
    values[idx] = 0

    while value > 0
        idx = next_idx(idx)
        values[idx] += 1
        value -= 1
    end
end

"""
    part1(input)

Given the input as a list of numbers, repeatedly redistribute the largest value
until a state is reached more than once, and return the number of redistribution
cycles needed to repeate that state.
"""
function part1(input)
    values = deepcopy(input)
    seen = Set()
    cycles = 0

    while hash(values) ∉ seen
        push!(seen, hash(values))
        redistribute!(values)
        cycles += 1
    end

    return cycles
end
