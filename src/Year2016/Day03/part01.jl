"""
    istriangle(sides::Tuple{Int,Int,Int})

Given a 3-tuple of integers, determine whether the three integers represent the
sides of a valid triangle, meaning that the sum of any two sides is greater
than the third side.
"""
function istriangle(sides::Tuple{Int,Int,Int})
    a, b, c = sides
    return a+b > c && a+c > b && b+c > a
end

"Check each `Sides` for being a triangle, then return the count of the valid ones"
part1(input) = mapreduce(istriangle, +, input)