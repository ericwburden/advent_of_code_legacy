"""
    part2(input)

Given the input as a list of numbers, repeatedly redistribute the largest value
until a state is reached more than once, and return the number of redistribution
cycles between .
"""
function part2(input)
    values = deepcopy(input)
    seen   = Dict()
    cycles = 0

    while true
        hashed_values = hash(values)
        if hashed_values ∈ keys(seen)
            return cycles - seen[hashed_values]
        end
        seen[hashed_values] = cycles
        redistribute!(values)
        cycles += 1
    end
end 