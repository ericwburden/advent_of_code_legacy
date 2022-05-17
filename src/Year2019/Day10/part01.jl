"""
    angle_between(a::CartesianIndex, b::CartesianIndex) -> Float64

Calculate the angle formed between two `CartesianIndex`es, with 0.0 being
straight up along the y-axis and 90.0 being along the positive x-axis, 
clockwise from 0.0.
"""
function angle_between(a::CartesianIndex, b::CartesianIndex)
    dy, dx = Tuple(b - a)
    radians = atan(dy, dx)
    degrees = radians * (180 / π)
    rounded = round(degrees, digits = 2) + 90
    return rounded >= 0 ? rounded : 360 + rounded
end

"""
    best_view(asteroids::Vector{CartesianIndex{2}}) -> (CartesianIndex, Int)

Identify the asteroid which has line of sight to the most other asteroids,
return the location of that asteroid and the number of asteroids visible.
"""
function best_view(asteroids::Vector{CartesianIndex{2}})
    best_location = nothing
    most_detected = typemin(Int)

    for outer in asteroids
        angles = Set{Float64}()

        for inner in asteroids
            inner == outer && continue
            push!(angles, angle_between(inner, outer))
        end

        if length(angles) > most_detected
            best_location = outer
            most_detected = length(angles)
        end
    end

    return (best_location, most_detected)

end

"""
    part1(input) -> Int

Given the input as a character matrix, identify the asteroid which has line of
sight to the most other asteroids. Return the number of visible asteroids.
"""
function part1(input)
    asteroids = filter(i -> input[i] == '#', CartesianIndices(input))
    _, most_detected = best_view(asteroids)
    return most_detected
end
