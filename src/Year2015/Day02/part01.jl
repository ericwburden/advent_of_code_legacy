"""
    paperrequired((; l, w, h)::Box)

Given a `Box`, calculate the square inches of paper needed to wrap the box. 
This is the surface area of the box plus the area of the smallest side.
"""
function paperrequired((; l, w, h)::Box)
    surface = 2 * l * w + 2 * l * h + 2 * w * h
    extra = w * h
    return surface + extra
end


"""
    part1(input)

Given the input as a vector of `Box`es, calculate the total square inches of 
paper needed to wrap them all.
"""
function part1(input)
    mapreduce(paperrequired, +, input)
end
