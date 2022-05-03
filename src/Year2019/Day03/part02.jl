"""
    minimum_steps_to(wire1::WireTrace, wire2::WireTrace, point::Point)

Count the minimum number of steps to get to a particular intersection by
following the path of `wire1` and `wire2`.
"""
function minimum_steps_to(wire1::WireTrace, wire2::WireTrace, point::Point)
    minsteps1 = minimum(wire1.points[point])
    minsteps2 = minimum(wire2.points[point])
    return minsteps1 + minsteps2
end

"""
    part2(input)

Given two lists of directions for two wires, trace each, identify the points
where they intersect, and return the minimum total number of steps for both
wires to create an intersection.
"""
function part2(input)
    wire1, wire2  = input
    wire1trace    = trace(wire1)
    wire2trace    = trace(wire2)
    min_steps(i)  = minimum_steps_to(wire1trace, wire2trace, i)
    return minimum(min_steps, intersections(wire1trace, wire2trace))
end
