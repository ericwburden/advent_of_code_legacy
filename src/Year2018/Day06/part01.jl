const Location = CartesianIndex{2}
const Locations = Vector{Location}

"Manhattan distance between two cartesian indices"
distance(a::CartesianIndex, b::CartesianIndex) = abs.(Tuple(a - b)) |> sum

"""
    find_closest_destination(location::Location, destinations::Locations)

Given a `location` and the list of `destinations` from the input, identify and
return the destination that is closest to `location`. If two or more destinations
are equally close, return `nothing`.
"""
function find_closest_destination(location::Location, destinations::Locations)
    closest_destination = nothing
    minimum_distance = typemax(Int)
    for destination in destinations
        distance_to_destination = distance(location, destination)
        if distance_to_destination == minimum_distance
            closest_destination = nothing
        end
        if distance_to_destination < minimum_distance
            closest_destination = destination
            minimum_distance = distance_to_destination
        end
    end
    return closest_destination
end

"""
    assign_areas(destinations::Locations)

Given the list of `destinations` from the input, assign locations in a grid 
starting from (1, 1) down to the destination that is furthest from the origin
to the destination each location is closest to.
"""
function assign_areas(destinations::Locations)
    assignments::Dict{Location,Vector{Location}} = Dict()
    for location = CartesianIndex(1, 1):maximum(destinations)
        closest_destination = find_closest_destination(location, destinations)
        isnothing(closest_destination) && continue
        assigned_locations = get!(assignments, closest_destination, [])
        push!(assigned_locations, location)
    end
    return assignments
end

"""
    is_finite_area(locations::Locations, bounds::NTuple{4,Int})

Given the locations assigned to a particular destination and the bounds of the
grid we're observing, determine whether the locations represent a finitely
bounded region. Accomplish this by checking to be sure all locations fall within
the indicated bounds.
"""
function is_finite_area(locations::Locations, bounds::NTuple{4,Int})
    top_row, left_col, bottom_row, right_col = bounds
    for location in locations
        row, col = Tuple(location)
        top_row < row < bottom_row || return false
        left_col < col < right_col || return false
    end
    return true
end

"""
    part1(input)

Given the input as a list of possible destinations, identify the size of the
largest finite region centered on one of the destinations and return the size.
"""
function part1(input)
    assigned_areas = assign_areas(input)
    bounds = (1, 1, Tuple(maximum(input))...)
    (
        result =
            values(assigned_areas) |>
            (x -> Iterators.filter(l -> is_finite_area(l, bounds), x)) |>
            (x -> mapreduce(length, max, x))
    )
    return result
end
