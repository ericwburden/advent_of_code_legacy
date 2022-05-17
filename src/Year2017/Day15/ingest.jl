"""
Represents one of the generators, containing everything needed to produce 
the first value.
"""
struct Generator
    seed::Int
    factor::Int
    mod::Int
end

"No need to parse input today!"
const generator_a = Generator(703, 16807, 2147483647)
const generator_b = Generator(516, 48271, 2147483647)
