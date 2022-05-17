"""
    Base.iterate((; factor, seed, mod)::Generator)
    Base.iterate((; factor, seed, mod)::Generator, state::Int)

Implements iteration for a `Generator`. The first value produced is based on
the `seed` of the Generator, subsequent values are based on the previously 
produced value.
"""
function Base.iterate((; factor, seed, mod)::Generator)
    value = (seed * factor) % mod
    return (value, value)
end
function Base.iterate((; factor, seed, mod)::Generator, state::Int)
    value = (state * factor) % mod
    return (value, value)
end

"Check if the lowest 16 bits of two integers match"
match_16_low(a::Int, b::Int) = (a & (2^16 - 1)) == (b & (2^16 - 1))

"""
    part1()

No input needed, runs both generators in tandem 40 million times and count
how many times the lowest 16 bits match.
"""
function part1()
    rounds = 40_000_000
    matches = 0
    for (a, b) in zip(generator_a, generator_b)
        rounds <= 0 && break
        if (match_16_low(a, b))
            matches += 1
        end
        rounds -= 1
    end
    return matches
end
