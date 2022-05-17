"""
    part2(input) -> Int

Given the input program, begin searching for points at the top right and 
bottom left of a theoretical 100x100 square. Once both points are confirmed
to be in the tractor beam range, return the value derived from the top left
coordinates.
"""
function part2(input)
    (x, y) = (0, 0)
    while true
        if detect_position(input, x, y + 99) == 0
            x += 1
            continue
        end
        if detect_position(input, x + 99, y) == 1
            return (x * 10_000) + y
        end
        y += 1
    end
end
