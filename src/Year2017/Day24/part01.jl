"Overloaded functions used to determine whether two ports are compatible"
can_attach(::UsedPort, ::UsedPort) = false
can_attach(::OpenPort, ::UsedPort) = false
can_attach(::UsedPort, ::OpenPort) = false
can_attach(p1::OpenPort, p2::OpenPort) = p1.pins == p2.pins

"Overloaded functions to return the open port of a `Component`"
open_port((; p1, p2)::Component{OpenPort, OpenPort}) = error("Should be attached.")
open_port((; p1, p2)::Component{OpenPort, UsedPort}) = p1
open_port((; p1, p2)::Component{UsedPort, OpenPort}) = p2
open_port((; p1, p2)::Component{UsedPort, UsedPort}) = nothing

"Changes a `OpenPort` to a `UsedPort`"
use_port((; pins)::OpenPort) = UsedPort(pins)

"""
    try_attach(c1::Component, c2::Component)
    try_attach(::Nothing, (; id, p1, p2)::Component)
    try_attach((; terminus, component_ids, strength)::Bridge, c::Component)

Attempt to attach one component to another, and return the 'connected' version
of the second component. A component with a '0' port can be connected to 
`nothing`. If no connection can be made, returns `nothing`. If connecting a
component to a bridge, return the updated `Bridge`.
"""
function try_attach(c1::Component, c2::Component)
    c1_open_port = open_port(c1)
    can_attach(c1_open_port, c2.p1) && return Component(c2.id, use_port(c2.p1), c2.p2)
    can_attach(c1_open_port, c2.p2) && return Component(c2.id, c2.p1, use_port(c2.p2))
    return nothing
end

function try_attach(::Nothing, (; id, p1, p2)::Component)
    p1.pins == 0 && return Component(id, use_port(p1), p2)
    p2.pins == 0 && return Component(id, p1, use_port(p2))
    return nothing
end

function try_attach((; terminus, component_ids, strength)::Bridge, c::Component)
    c.id ∈ component_ids && return nothing
    terminus = try_attach(terminus, c)
    isnothing(terminus) && return nothing
    component_ids = Set([component_ids..., c.id])
    strength += strength_of(c)
    return Bridge(terminus, component_ids, strength)
end

"Returns the strength of a component or bridge"
strength_of((; p1, p2)::Component) = p1.pins + p2.pins
strength_of(bridge::Bridge)        = bridge.strength

"""
Represents a `Bridge` spanning to the CPU, keeping track of the last available
component to connect to, a set of connected component ID's, and the strength
of the bridge.
"""
struct Bridge
    terminus::Union{Nothing,Component}
    component_ids::Set{Int}
    strength::Int
end
Bridge() = Bridge(nothing, Set{Int}(), 0)

"""
    possible_bridges(bridge::Bridge, components::Vector{Component})

Given a `Bridge`, attempt to connect each component in `components` and return
an iterator of all the bridges that can be made this way.
"""
function possible_bridges(bridge::Bridge, components::Vector{Component})
    (result
        = components
        |> (x -> Iterators.map(c -> try_attach(bridge, c), x))
        |> (x -> Iterators.filter(b -> !isnothing(b), x)))
    return result
end

"""
    part1(components)

Given a list of components, search all the possible bridges that can be made 
(via DFS) and return the strength of the strongest possible bridge.
"""
function part1(components)
    start = Bridge()
    max_strength = 0
    stack = [start]

    while !isempty(stack)
        current = pop!(stack)
        max_strength = max(max_strength, current.strength)
        for bridge in possible_bridges(current, components)
            push!(stack, bridge)
        end
    end

    return max_strength
end
