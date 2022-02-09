"The volume of eggnog specified in the puzzle description"
const EGGNOG_VOLUME = 150

"""
    distribute(total::Int, vessels::AbstractVector{Int}, found=[])

Given a `total` volume and the capacities of a number of `vessels`, recursively
search for all combinations of vessel volumes that can hold exactly `total`. 
Numbers in `vessels` may be used as many times as they appear, as each
represents a unique vessel to be filled.

# Examples
```jldoctest
julia> distribute(10, [6, 4, 2, 2])
2-element Vector{Vector{Int64}}:
 [6, 4]
 [6, 2, 2]
```
```jldoctest
julia> distribute(25, [20, 15, 10, 5, 5])
4-element Vector{Vector{Int64}}:
 [20, 5]
 [20, 5]
 [15, 10]
 [15, 5, 5]
```
"""
function distribute(total::Int, vessels::AbstractVector{Int}, found=Int[])
    total == 0       && return [found]
    isempty(vessels) && return Int[]

    output = Vector{Int}[]
    for (idx, vessel) in enumerate(vessels)
        vessel > total && continue
        used = [found..., vessel]
        left = @view vessels[idx+1:end]
        append!(output, distribute(total - vessel, left, used))
    end
    return output
end

"""
    part1(vessels)

Given the input as a list of integers representing the capacities of a series
of vessels for storing eggnog, return the number of different combinations of
vessels among which the eggnog can be evenly and completely distributed.
"""
function part1(vessels)
    combinations = distribute(EGGNOG_VOLUME, vessels)
    return length(combinations)
end
