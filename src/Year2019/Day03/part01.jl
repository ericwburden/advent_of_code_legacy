const Point     = NTuple{2,Int}

"""
A `WireTrace` represents the path of a wire, including the location of the
last point added, a dictionary of points and the number of steps it took
to get to each, and the total steps taken so far.
"""
struct WireTrace
    current::Point
    points::Dict{Point,Vector{Int}}
    total_steps::Int
end

WireTrace() = WireTrace((0, 0), Dict{Point,Vector{Int}}(), 0)


"Offsets for each type of `AbstractDirection`"
offset(::Up)    = (-1,  0)
offset(::Down)  = ( 1,  0)
offset(::Left)  = ( 0, -1)
offset(::Right) = ( 0,  1)

"""
    trace(wire_trace::WireTrace, direction::AbstractDirection)

Given a `direction`, start adding points to the `wire_trace` following that
direction from the point at which the last previous direction ended.
"""
function trace(wire_trace::WireTrace, direction::AbstractDirection)
    (; current, points, total_steps) = wire_trace
    for _ in 1:direction.steps
        current = current .+ offset(direction)
        steps_there = get!(points, current, [])
        total_steps += 1
        push!(steps_there, total_steps)
    end
    return WireTrace(current, points, total_steps)
end

"""
    trace(wire::Vector{AbstractDirection})

Fully trace a wire, converting a list of `AbstractDirection`s into a full
`WireTrace`.
"""
function trace(wire::Vector{AbstractDirection})
    wire_trace = WireTrace()
    foreach(d -> wire_trace = trace(wire_trace, d), wire)
    return wire_trace
end

"Identify the points where the two wires intersect"
function intersections(wire1::WireTrace, wire2::WireTrace)
    return keys(wire1.points) ∩ keys(wire2.points)
end

"""
    part1(input)

Given two lists of directions for two wires, trace each, identify the points
where they intersect, and return the distace to the closest intersection from
the origin.
"""
function part1(input)
    wire1, wire2  = input
    wire1trace    = trace(wire1)
    wire2trace    = trace(wire2)
    distance(p)   = sum(abs.((0, 0) .- p))
    return minimum(distance, intersections(wire1trace, wire2trace))
end
