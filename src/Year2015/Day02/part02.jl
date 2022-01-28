"""
    ribbonrequired((; l, w, h)::Box)

Given a `Box`, calculate the linear inches of ribbon needed to complete the
wrapping. The length is the smallest perimeter around any face, plus the 
magnitude of the box's volume. The smallest face will be the box's `w * h`, 
since the box must satisfy box.l >= box.w >= box.h.
"""
function ribbonrequired((; l, w, h)::Box)
    length = 2*w + 2*h
    extra  = l * w * h
    return length + extra
end


"""
    part1(input)

Given the input as a vector of `Box`es, return the total length of ribbon
required to complete wrapping.
"""
function part2(input)
    mapreduce(ribbonrequired, +, input)
end