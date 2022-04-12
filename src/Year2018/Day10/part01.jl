const Points = Vector{Point}

"""
    extrema(points::Points)

Returns a tuple of tuples representing the top left and bottom right of the
range containing all the `Point`s in `Points`.
"""
function Base.extrema(points::Points)
    min_x = min_y = typemax(Int)
    max_x = max_y = typemin(Int)
    for point in points
        px, py = point.position
        min_x = min(min_x, px)
        min_y = min(min_y, py)
        max_x = max(max_x, px)
        max_y = max(max_y, py)
    end
    return ((min_x, min_y), (max_x, max_y))
end

"""
    dims(points::Points)

Returns the width and height of the area containing all `points`.
"""
function dims(points::Points)
    ((min_x, min_y), (max_x, max_y)) = extrema(points)
    return (max_x - min_x, max_y - min_y)
end

"""
    area(points::Points)

Returns the size of the area containing all `points`.
"""
function area(points::Points)
    x_length, y_length = dims(points)
    return x_length * y_length
end

"""
    move((; position, velocity)::Point)

Move the point forward by one second.
"""
function move((; position, velocity)::Point)
    position = position .+ velocity
    return Point(position, velocity)
end

"""
    rewind((; position, velocity)::Point)

Move the point backward by one second.
"""
function rewind((; position, velocity)::Point)
    position = position .- velocity
    return Point(position, velocity)
end

"""
    pretty_print(points::Points)

Print a collection of `Points` to the console, so you can read the message.
"""
function pretty_print(points::Points)
    ((min_x, min_y), (_, _)) = extrema(points)
    cols, rows = dims(points)
    space = fill(' ', rows + 1, cols + 1)
    for point in points
        px, py = point.position .- (min_x, min_y) .+ 1
        space[py, px] = '#'
    end

    for row in eachrow(space)
        for char in row
            print(char)
        end
        println()
    end
end


"""
    part1(input)

Given the starting `Point`s, move all points forward one second at a time
until they stop converging and start to diverge. Then reverse the points by
one tick and return the list of points.
"""
function part1(input)
    last_area = typemax(Int)
    points    = input
    while true
        current_area = area(points)
        current_area > last_area && break
        last_area    = current_area

        points = map(move, points)
    end
    return map(rewind, points) # pretty_print() for answer
end
