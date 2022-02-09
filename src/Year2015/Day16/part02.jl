"""
    PartialRange(operators::Dict{Symbol,Function})

Represents a matching strategy where some compounds are matched using operators
other than `==`. Any compound symbol included in `operators` uses the included
funcion, all other compounds default to `==` comparison.
"""
struct PartialRange <: MatchingStrategy
    operators::Dict{Symbol,Function}
end
PartialRange(ops...) = PartialRange(Dict(ops))

"""
    match(s::PartialRange, a::Int, b::Int, c::Symbol)

Matches integers using the `PartialRange` strategy.
"""
match(s::PartialRange, a::Int, b::Int, c::Symbol) = get(s.operators, c, ==)(a, b)


"""
    part2(input)

Given the input as a list of `AuntSue`s, check each value against the set of 
detected compounds using the `PartialRange` matching strategy as described in
the puzze instructions. If only one aunt matches, return her number. Otherwise,
raise an error.
"""
function part2(input)
    strategy = PartialRange(
        :cats => >,
        :trees => >,
        :pomeranians => <,
        :goldfish => <
    )
    found    = filter(x -> match(strategy, x, DETECTED), input)
    length(found) > 1 && error("Matched too many aunts!")
    length(found) < 1 && error("Could not find a match!")

    return found[1].number
end