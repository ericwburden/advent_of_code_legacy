"""
    part2(input)

Given the starting `Point`s, move all points forward one second at a time
until they stop converging and start to diverge. Then reverse the points by
one tick and return the number of ticks it took to display the sky message.
"""
function part2(input)
    last_area = typemax(Int)
    points    = input
    ticks     = 0
    while true
        current_area = area(points)
        current_area > last_area && break
        last_area    = current_area

        ticks += 1
        points = map(move, points)
    end
    return ticks - 1
end