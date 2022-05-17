"""
The 'rules' provided in the input file are each represented as a 
`Int`, which is obtained by converting the series of characters
into an integer according to the following algorithm:

    - Initialize an integer value to zero
    - Assign a number from 0-4 to each character, left to right
    - For each character that is '#', add 10 raised to the assigned
      number to the initialized value
    - The integer value represents the growing rule

`GrowRules` stores a set of the rules that represent the growth of
a new plant (i.e., the right hand side of the input line is '#').
"""
struct GrowRules
    inner::Set{Int}
end

GrowRules() = GrowRules(Set{Int}())

"""
    push!((; inner)::GrowRules, s::AbstractString)

Adds a new rule to `GrowRules`, parsed from the string `s`.
"""
function Base.push!((; inner)::GrowRules, s::AbstractString)
    value = 0
    for (pow, char) in zip(0:4, s)
        char == '#' || continue
        value += 10^pow
    end
    push!(inner, value)
end

"""
`Pots` represents the current collection of pots, where any value in 
`filled` represents the index of a pot with a plant in it, and the total
range of observed pots is given by `first:last`.
"""
struct Pots
    filled::Set{Int}
    first::Int
    last::Int
end

"""
    parse(::Type{Pots}, s::AbstractString)

Parses the string representing the initial state of the potted plants 
into a `Pots`.
"""
function Base.parse(::Type{Pots}, s::AbstractString)
    filled = Set{Int}()
    first, last = (nothing, nothing)
    for (idx, char) in enumerate(s)
        char == '#' || continue
        push!(filled, idx - 1)
        if (isnothing(first))
            first = idx - 1
        end
        last = idx - 1
    end
    return Pots(filled, first, last)
end

"""
    ingest(path)

Given the path to the input file, parse the first line into a `Pots` and
the remaining lines into `GrowRules`, returning a tuple containing both.
"""
function ingest(path)
    initial_state = ""
    grow_rules = GrowRules()

    open(path) do f
        first_line = readuntil(f, "\n\n")
        _, initial_state = split(first_line, ": ")

        for line in eachline(f)
            left, right = split(line, " => ")
            right == "#" || continue
            push!(grow_rules, left)
        end
        return (parse(Pots, initial_state), grow_rules)
    end
end
