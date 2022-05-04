"""
    part_two_valid((; inner)::Digits)

Determine whether or not a `Digits` is valid according to part two instructions.
"""
function part_two_valid((; inner)::Digits)
    doubles = Int[]
    triples = Int[]
    for (previous, current, next) in zip(inner, inner[2:end], inner[3:end])
        previous  == current && current == next  && push!(triples, current)
        (previous == current || current == next) && push!(doubles, current)
        current  > next      && return false
        previous > current   && return false
    end
    return any(d -> d ∉ triples, doubles)
end

part2(input) = count_valid(input, part_two_valid)
