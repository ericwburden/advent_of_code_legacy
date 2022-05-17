"Abstract supertype for NormalLights and FaultyLights"
abstract type Lights end

"""
    NormalLights(m::BitMatrix)

Wrapper type for a BitMatrix to support function overloading.
"""
struct NormalLights <: Lights
    m::BitMatrix
end

"""
    neighborhood(m::BitMatrix, i::CartesianIndex)

Return a view into `m` of the (up to) nine values surrounding and including `i`.
Fewer values will be returned if `i` is on the 'border' or in a 'corner' of the
`BitMatrix`.
"""
function neighborhood(m::BitMatrix, i::CartesianIndex)
    (rows, cols) = size(m)

    top = i[1] > 1 ? i[1] - 1 : 1
    left = i[2] > 1 ? i[2] - 1 : 1
    bottom = i[1] < rows ? i[1] + 1 : rows
    right = i[2] < cols ? i[2] + 1 : cols

    return @view m[top:bottom, left:right]
end

"Helper function to count the number of 'on' values surrounding `i`"
neighborson((; m)::Lights, i::CartesianIndex) = sum(neighborhood(m, i)) - m[i]

"""
    nextstate(l::NormalLights, i::CartesianIndex) 

Given a `NormalLights` and an index `i`, determine whether the given index
should be 1 or 0 in the next state of `NormalLights`.
"""
function nextstate(l::NormalLights, i::CartesianIndex)
    neighborson(l, i) == 3 && return true
    neighborson(l, i) == 2 && return l[i]
    return false
end

"""
    nextstate(l::Lights)

Given a `Lights`, determine the next state of on/off values in the underlying
`BitMatrix` and return that `BitMatrix`.
"""
function nextstate(l::Lights)
    next = similar(l)
    foreach(idx -> next[idx] = nextstate(l, idx), CartesianIndices(l))
    return next
end

"""
    nth_state(l::Lights, nth::Int)

Given a `Lights` and a number indicating the `nth` state of interest, advance
the state of `l` and return the `nth` state.
"""
function nth_state(l::Lights, nth::Int)
    foreach(_ -> l = nextstate(l), 1:nth)
    return l
end

# A bunch of overloads of `Base` functions to apply them to `Lights` and
# `NormalLights` structs, so they can be treated as a regular `BitMatrix`
# where it makes sense to do so.
Base.similar((; m)::NormalLights) = similar(m) |> NormalLights
Base.setindex!((; m)::NormalLights, v, i) = setindex!(m, v, i) |> NormalLights
Base.CartesianIndices((; m)::Lights) = CartesianIndices(m)
Base.getindex((; m)::Lights, i) = getindex(m, i)
Base.iterate((; m)::Lights) = iterate(m)
Base.iterate((; m)::Lights, i::Int) = iterate(m, i)

"""
    part1(input)

Given the `input` as a `BitMatrix` where true values represent a light turned
on, wrap the `input` in a `NormalLights`, advance to the 100th state, then
return the sum total of the number of lights on at the end.
"""
function part1(input)
    target_state(m) = nth_state(m, 100)
    NormalLights(input) |> target_state |> count
end
