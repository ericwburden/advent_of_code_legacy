using IterTools: iterated, nth

"""
    digest(s::AbstractString, ::Long)

The `Long` hashing approach is 2017 accumulating hashes of the original string.
"""
function digest(s::AbstractString, ::Long)
    fn(x) = hexdigest("md5", x)
    digests = iterated(fn, s)
    # nth(xs, 1) is the original input, 2017 + 1 = 2018
    return nth(digests, 2018) 
end

"""
    part2(input)

Repeat part 1, just using the `Long` hashing strategy.
"""
function part2(input)
    keys = find_keys(input, 1000, 64, Long())
    return keys[64][1]
end
