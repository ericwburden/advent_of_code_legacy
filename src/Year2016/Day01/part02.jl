function part2(input)
    heading = North
    location = (0, 0)
    visited = Set{Location}()
    for direction in input
        heading = turn(heading, direction)
        for _ = 1:direction.distance
            location = move(heading, 1, location)
            location ∈ visited && return distance(location)
            push!(visited, location)
        end
    end
    error("Did not find an answer!")
end
