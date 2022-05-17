# The compounds detected by the My First Crime Scene Analysis Machine
const DETECTED = Dict(
    :children => 3,
    :cats => 7,
    :samoyeds => 2,
    :pomeranians => 3,
    :akitas => 0,
    :vizslas => 0,
    :goldfish => 5,
    :trees => 3,
    :cars => 2,
    :perfumes => 1,
)

# Having peeked into the future (by coming back after finishing part 2), I know
# that I'll need to use a different matching strategy for parts 1 and 2. This
# abstract type represents the parent type for both strategies.
abstract type MatchingStrategy end

"""
    Equals()

A struct with no data, representing a matching strategy where all values are
compared with `==`.
"""
struct Equals <: MatchingStrategy end

# Shorthand to make function signatures shorter
const MaybeInt = Union{Nothing,Int}

# Shorthand to use domain terminology for this puzzle
const Compounds = Dict{Symbol,Int}

"""
    match(::EqualsIgnoreMissing, a::MaybeInt, b::MaybeInt, ::Symbol)

The real workhorse of Part 1. Given values `a` and `b`, if either is `nothing`,
return `true`, essentially skipping any pairs where `a` or `b` is unknown. 
Otherwise, return `a == b`.
"""
match(::MatchingStrategy, a::Nothing, b::MaybeInt, ::Symbol) = true
match(::MatchingStrategy, a::MaybeInt, b::Nothing, ::Symbol) = true
match(::Equals, a::Int, b::Int, ::Symbol) = return a == b
match(s::MatchingStrategy, a::AuntSue, b::Compounds) = match(s, a.compounds, b)


"""
    match(s::MatchingStrategy, a::Compounds, b::Compounds)

Given a `MatchingStrategy` and two sets of compounds `a` and `b`, determine
whether these sets of compounds match in light of the strategy proposed. If 
any compound doesn't match, the function returns `false` early.
"""
function match(s::MatchingStrategy, a::Compounds, b::Compounds)
    compounds = keys(a) ∪ keys(b)
    for compound in compounds
        a_value = get(a, compound, nothing)
        b_value = get(b, compound, nothing)
        !match(s, a_value, b_value, compound) && return false
    end
    return true
end

"""
    part1(input)

Given the input as a list of `AuntSue`s, check each value against the set of 
detected compounds using the `Equals` matching strategy. If only one aunt 
matches, return her number. Otherwise, raise an error.
"""
function part1(input)
    strategy = Equals()
    found = filter(x -> match(strategy, x, DETECTED), input)
    length(found) > 1 && error("Matched too many aunts!")
    length(found) < 1 && error("Could not find a match!")

    return found[1].number
end
