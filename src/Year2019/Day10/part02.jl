"Manhattan distance between two points"
distance(a::CartesianIndex, b::CartesianIndex) = sum(abs.(Tuple(a - b)))

const AngleGroups = Dict{Float64, Vector{CartesianIndex}}

"""
    group_by_angle(point::CartesianIndex, others) -> AngleGroups
    
Given a single origin point and a list of other `CartesianIndex`es, group
the `others` by their offset angle from `point`, returning the groups in
a Dict, where the keys are the angles and the values are the `CartesianIndex`es
that lie along that angle.
"""
function group_by_angle(point::CartesianIndex, others::Vector{CartesianIndex})
    mapping = AngleGroups()
    for other in others
        point == other && continue
        angle = angle_between(point, other)
        found = get!(mapping, angle, [])
        push!(found, other)
    end
    return mapping
end


"""
    part2(input) -> Int

Sweep a vaporizing laser out from the monitoring station, clockwise starting from
angle 0.0, destroying asteroids as the laser encounters them. Return an integer
derived from the location of the 200th asteroid to be destroyed.
"""
function part2(input)
    # Identify the monitoring station and other asteroid locations
    asteroids = filter(i -> input[i] == '#', CartesianIndices(input))
    monitoring_station, _ = best_view(asteroids)

    # Group the other asteroid locations by angle from the
    # `monitoring_station`, sorted by angle. Within each group,
    # sort locations by (reverse) distance from the origin.
    angle_groups  = group_by_angle(monitoring_station, asteroids)
    sorted_groups = pairs(angle_groups) |> sort |> values |> collect
    distance_to_station(p) = distance(p, monitoring_station)
    foreach(g -> sort!(g, by = distance_to_station, rev = true), sorted_groups)

    # Loop through the sorted groups, popping off the closest point
    # to the origin in each group and adding it to `destroy_order`.
    # Keep it up until all the locations have been added.
    destroy_order = []
    while !isempty(sorted_groups)
        for group in sorted_groups
            push!(destroy_order, pop!(group))
        end
        sorted_groups = filter(v -> !isempty(v), sorted_groups)
    end

    # Return (X * 100) + Y for the 200th asteroid destroyed
    y, x = Tuple(destroy_order[200]) .- 1
    return (x * 100) + y
end

