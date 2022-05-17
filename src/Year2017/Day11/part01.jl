"Represents a location on a hexagonal grid"
struct HexLocation
    x::Int
    y::Int
    z::Int
end
HexLocation() = HexLocation(0, 0, 0)

"""
    Base.:+((; x, y, z)::HexLocation, dir::AbstractDirection)

Given a location and a concrete struct that derives from AbstractDirection, 
return the location that would be arrived at by moving in the given direction.
"""
Base.:+((; x, y, z)::HexLocation, dir::North) = HexLocation(x, y + 1, z - 1)
Base.:+((; x, y, z)::HexLocation, dir::NorthEast) = HexLocation(x + 1, y, z - 1)
Base.:+((; x, y, z)::HexLocation, dir::NorthWest) = HexLocation(x - 1, y + 1, z)
Base.:+((; x, y, z)::HexLocation, dir::South) = HexLocation(x, y - 1, z + 1)
Base.:+((; x, y, z)::HexLocation, dir::SouthEast) = HexLocation(x + 1, y - 1, z)
Base.:+((; x, y, z)::HexLocation, dir::SouthWest) = HexLocation(x - 1, y, z + 1)

"""
    distance_from_origin((; x, y, z)::HexLocation)

Calculate the distance from the origin of a `HexLocation`, which is the maximum
distance along any of the three axes.
"""
function distance_from_origin((; x, y, z)::HexLocation)
    return maximum(abs(d) for d in [x, y, z])
end

"""
    part1(input)

Given the input as a list of directions, follow each direction and return 
the distance of the final location from the origin.
"""
function part1(input)
    final_location = reduce(+, input, init = HexLocation())
    return distance_from_origin(final_location)
end
