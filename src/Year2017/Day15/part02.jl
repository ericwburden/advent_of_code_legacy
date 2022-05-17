"""
In round two, each generator will churn through values and only return the 
ones divisible by `div_by`. Need to keep up with the divisor.
"""
struct Generatorv2
    seed::Int
    factor::Int
    mod::Int
    div_by::Int
end
Generatorv2((; seed, factor, mod)::Generator, div_by::Int) =
    Generatorv2(seed, factor, mod, div_by)

"""
    Base.iterate((; factor, seed, mod, div_by)::Generatorv2)
    Base.iterate((; factor, seed, mod, div_by)::Generatorv2, state::Int)

Implements iteration for a `Generatorv2`. The first value produced is based on
the `seed` of the Generator, subsequent values are based on the previously 
produced value. This version of the generator will only return a value 
that is divisible by `div_by`.
"""
function Base.iterate((; factor, seed, mod, div_by)::Generatorv2)
    value = (seed * factor) % mod
    while value % div_by > 0
        value = (value * factor) % mod
    end
    return (value, value)
end
function Base.iterate((; factor, seed, mod, div_by)::Generatorv2, state::Int)
    value = (state * factor) % mod
    while value % div_by > 0
        value = (value * factor) % mod
    end
    return (value, value)
end

const generator_a_v2 = Generatorv2(generator_a, 4)
const generator_b_v2 = Generatorv2(generator_b, 8)

"""
    part2()

No input needed, runs both generators in tandem 5 million times and count
how many times the lowest 16 bits match, for the values the generators 
actually return.
"""
function part2()
    rounds = 5_000_000
    matches = 0
    for (a, b) in zip(generator_a_v2, generator_b_v2)
        rounds <= 0 && break
        if (match_16_low(a, b))
            matches += 1
        end
        rounds -= 1
    end
    return matches
end
