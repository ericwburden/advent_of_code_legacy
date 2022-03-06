"""
    part2(input)

Given the input as a `BitVector`, expand and contract the bits according to the
puzzle rules and return the resulting bits as a string.
"""
function part2(input)
    data  = unfold_to(input, 35651584)
    check = checksum(data)
    return repr(check)
end
