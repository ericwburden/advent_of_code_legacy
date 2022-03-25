"""
    which_layer(n)

Returns the 'layer' of a spiral where `n` appears. For this function, a 'layer'
is considered the number of square rings away from the center of the spiral on
which `n` can be found. 
"""
which_layer(n) = ceil(Int, sqrt(n)/2 - 0.5)

"""
    spiral_distance_to(n)

Assuming `n` falls on a square spiral, calculate the distance from `n` to the
center of the spiral. Based on the formula found here: [https://oeis.org/A214526]
"""
function spiral_distance_to(n) 
    n == 1 && return 0
    l = which_layer(n)
    return l + abs(((n - 1) % 2l - l))
end

"""
    part1(input)

Given the input as a number, return the manhattan distance of that number from
the center of a square spiral.
"""
part1(input) = spiral_distance_to(input)
