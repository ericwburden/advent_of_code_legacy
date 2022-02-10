"""
    FaultyLights(m::BitMatrix)

Wrapper type for a BitMatrix to support function overloading. For `FaultyLights`,
the lights in the four corners are stuck on and functions that operate on 
`FaultyLights` reflect that.
"""
struct FaultyLights <: Lights
    m::BitMatrix
end

"""
    iscorner((; m)::FaultyLights, i::CartesianIndex)

Helper function to identify whether a given index is in a 'corner' of a 
`FaultyLights` array.
"""
function iscorner((; m)::FaultyLights, i::CartesianIndex)
    (rows, cols) = size(m)
    return (i[1] ∈ [1, rows]) && (i[2] ∈ [1, cols])
end

"""
    nextstate(f::FaultyLights, i::CartesianIndex) 

Given a `FaultyLights` and an index `i`, determine whether the given index
should be 1 or 0 in the next state of `FaultyLights`. Lights in the corner
are stuck on.
"""
function nextstate(f::FaultyLights, i::CartesianIndex) 
    iscorner(f, i)         && return true
    neighborson(f, i) == 3 && return true
    neighborson(f, i) == 2 && return f[i] 
    return false
end

# Overloads of `Base` functions to apply them to `FaultyLights`, so they can be
# treated as a regular `BitMatrix` where it makes sense to do so.
Base.similar((; m)::FaultyLights)         = similar(m) |> FaultyLights
Base.setindex!((; m)::FaultyLights, v, i) = setindex!(m, v, i) |> FaultyLights

"""
    part2(input)

Given the `input` as a `BitMatrix` where true values represent a light turned
on, wrap the `input` in a `FaultyLights`, advance to the 100th state, then
return the sum total of the number of lights on at the end. Models behavior
where the four corners are stuck on.
"""
function part2(input)
    target_state(m) = nth_state(m, 100)
    FaultyLights(input) |> target_state |> count
end
