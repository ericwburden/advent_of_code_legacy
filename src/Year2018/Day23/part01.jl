function Base.isless(a::NanoBot, b::NanoBot)
    a.range == b.range && return a.position < b.position
    return a.range < b.range
end

"""
    distance(a, b)

Calculate the manhattan distance between `NanoBot`s or `Position`s.
"""
distance(a::NanoBot, b::NanoBot) = distance(a.position, b.position)
distance(a::NanoBot, b::Position) = distance(a.position, b)
distance(a::Position, b::Position) = sum(abs.(a .- b))

"""
    in_range_of(a, b)

Determine whether a `NanoBot` or `Position` is within range of a `NanoBot`.
"""
in_range_of(a::NanoBot, b::Position) = a.range >= distance(a, b)
in_range_of(a::NanoBot, b::NanoBot) = a.range >= distance(a, b)

"""
    part1(input)

Find the `NanoBot` with the largest range and return the number of bots in
range of that `NanoBot`.
"""
function part1(input)
    max_bot = maximum(input)
    in_range_of_max_bot(bot) = in_range_of(max_bot, bot)
    return count(in_range_of_max_bot, input)
end
