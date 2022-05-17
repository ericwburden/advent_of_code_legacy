"""
An `AbstractPort` represents a port in a component, that can be connected
to another port. An `OpenPort` is one that can be connected, a `UsedPort`
is one that cannot be connected to any longer.
"""
abstract type AbstractPort end
struct OpenPort <: AbstractPort
    pins::Int
end
struct UsedPort <: AbstractPort
    pins::Int
end

"""
Represents one of the bridge components.
"""
struct Component{T<:AbstractPort,V<:AbstractPort}
    id::Int
    p1::T
    p2::V
end

"""
    ingest(path)

Given a path to the input file, return a list of components parsed from input.
"""
function ingest(path)
    components = Component[]
    for (index, line) in enumerate(readlines(path))
        m = match(r"(\d+)/(\d+)", line)
        p1, p2 = OpenPort.(parse.(Int, m.captures))

        push!(components, Component(index, p1, p2))
    end
    return components
end
