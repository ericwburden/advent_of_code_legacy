const PointGraph = Dict{Point,Vector{Point}}

"Distance between two points"
distance(a::Point, b::Point) = sum(abs.(a .- b))

"""
    get_neighbors(point::Point, points::Vector{Point})

Given a single `point` and the list of `points`, return a sublist of `points`
that includes all points within a manhattan distance of 3 from `point`.
"""
function get_neighbors(point::Point, points::Vector{Point})
    neighbors = Point[]
    for other_point in points
        point == other_point && continue
        distance(point, other_point) > 3 && continue
        push!(neighbors, other_point)
    end
    return neighbors
end

"""
    part1(input)

Given the input as a list of `Point`s, count and return the number of 
'constellations'. A 'constellation' is a clique of points where each point
is within a manhattan distance of 3 of some other point in the clique.
"""
function part1(input)
    open_set   = Set(input)
    closed_set = Set{Point}()
    constellations = 0

    # Until we've removed all points from the open set...
    while !isempty(open_set)
        # Start up a depth-first search with any point from the open set, it
        # doesn't really matter which one.
        stack = [first(open_set)]

        # For each set of connected points, add one to the number of constellations.
        constellations += 1

        # Identify all points that can be reached from the starting point,
        # shifting them from the open set to the closed set as they are found.
        while !isempty(stack)
            current = pop!(stack)
            current ∈ closed_set && continue
            push!(closed_set, current)
            delete!(open_set, current)

            for neighbor in get_neighbors(current, input)
                neighbor ∈ closed_set && continue
                push!(stack, neighbor)
            end
        end
    end

    return constellations
end
