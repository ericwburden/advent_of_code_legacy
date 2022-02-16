"Determine sort order for groups of packages, considering length and 'quantum entanglement'"
priority(w::AbstractVector{Int}) = (length(w), prod(w))

"""
    groups(total::Int, weights::AbstractVector{Int}, groups=Int[])

Given a `total` and an iterable collection of `weights`, return a vector 
containing the groups that `weights` can be split into that will sum to `total`
"""
function find_groups(total::Int, weights::AbstractVector{Int}, groups=Int[])
    total == 0       && return [groups]
    isempty(weights) && return Int[]

    output = Vector{Int}[]
    for (idx, weight) in enumerate(weights)
        weight > total && continue
        used = [groups..., weight]
        left = @view weights[idx+1:end]
        append!(output, find_groups(total - weight, left, used))
    end
    return sort(output, by = priority)
end

"""
    check_overlap(group::Set{Int}, others::AbstractVector{Set{Int}}, remaining::Int)

Given a set of integers (`group`) and an iterable collection of other sets of
integers (`others`), recursively check to determine whether the first set can
be unioned with a disjoint subsequent set `remaining` number of times.

In the context of this puzzle, this checks a given grouping of weights against
all the other groups of weights that can be produced to determine if a
number of evenly weighted groups can be produced given `group` is one of them.
"""
function check_overlap(group::Set{Int}, others::AbstractVector{Set{Int}}, remaining=2)
    remaining == 0  && return true
    isempty(others) && return false

    for (idx, other) in enumerate(others)
        if isdisjoint(group, other) 
            already_seen = group ∪ other
            left_to_check = @view others[idx+1:end]
            return check_overlap(already_seen, left_to_check, remaining-1)
        end
    end

    return false
end

"""
    solve(weights::AbstractVector{Int}, compartments::Int)

Given an iterable collection of package `weights` and a number of `compartments`
to evenly divide the weights into, identify the smallest group (by number of
packages and 'quantum entanglement') that can be made while evenly dividing 
the packages.
"""
function solve(weights::AbstractVector{Int}, compartments::Int)
    target_weight   = sum(weights) ÷ compartments
    possible_groups = Set.(find_groups(target_weight, weights))
    for (idx, group) in enumerate(possible_groups)
        other_groups = @view possible_groups[idx+1:end]
        check_overlap(group, other_groups, compartments-1) && return prod(group)
    end
end

"Solve for 3 compartments"
part1(input) = solve(input, 3)