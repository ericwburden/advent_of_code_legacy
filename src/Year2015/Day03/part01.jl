const Address = NTuple{2,Int}
const HousesVisited = Set{Address}

asoffset(::North) = (1, 0)
asoffset(::South) = (-1, 0)
asoffset(::East) = (0, 1)
asoffset(::West) = (0, -1)

"""
    part1(input)

Given the input as a `Vector{Direction}`, counts the number of unique houses
visited if the directions are followed. The `Address` of each house is given as
it's (North/South, East/West) offset from the start (0, 0).
"""
function part1(input)
    address = (0, 0)
    visited = HousesVisited([address])

    for direction in input
        address = address .+ asoffset(direction)
        push!(visited, address)
    end

    return length(visited)
end
