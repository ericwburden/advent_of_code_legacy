"""
    part2(input)

Given the input as a `Vector{Direction}`, counts the number of unique houses
visited if the directions are followed, alternating, by Santa and Robo-Santa.
We maintain two locations, one for Santa and one for Robo-Santa, and alternate
moving them.
"""
function part2(input)
    santa   = (0, 0)
    robo    = (0, 0)
    visited = HousesVisited([santa])

    for (idx, direction) in enumerate(input)
        if idx % 2 == 0
            santa  = santa .+ asoffset(direction)
            push!(visited, santa)
        else
            robo   = robo .+ asoffset(direction)
            push!(visited, robo)
        end
    end

    return length(visited)
end