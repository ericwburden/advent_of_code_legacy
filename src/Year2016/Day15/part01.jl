"""
    open_at((; positions, start)::Disc, t::Int)

Return `true` if the given `Disc` will be open at time `t`.
"""
function open_at((; positions, start)::Disc, t::Int)
    return (start + t) % positions == 0
end

"""
    can_pass_at(discs::Vector{Disc}, t::Int)

Return `true` if each of the given discs will be open for a capsule dropped
at time `t`. The capsule reaches each disc at time `t` plus the index of the 
disc, such at the capsure reaches the first disc at `t` + 1, the second disc
at `t` + 2, and so on.
"""
function can_pass_at(discs::Vector{Disc}, t::Int)
    instants = [t + i for i in 1:length(discs)]
    return all(open_at.(discs, instants))
end

"""
    part1(input)

Given the input as a list of `Disc`s, identify and return the first instant
where a dropped capsule will be able to pass all the discs.
"""
function part1(input)
    time = 0
    while !can_pass_at(input, time)
        time += 1
    end
    return time
end
