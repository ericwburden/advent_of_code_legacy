using IterTools: iterated

"""
    unfold(v::BitVector)

Given a BitVector `v`, reverse its order, flip its bits, and concatenate it
to its original with a 0 (false) in between.
"""
function unfold(v::BitVector)
    return vcat(v, false, .~reverse(v))
end

"""
    unfold_to(v::BitVector, len::Int)

Given a BitVector, continually `unfold()` it until it is at least as long as 
`n`, then return the first `n` bits.
"""
function unfold_to(v::BitVector, len::Int)
    for data in iterated(unfold, v)
        length(data) >= len && return data[1:len]
    end
end

"""
    compress(pair)

Given an iterable pair of `Bool`, return the inverted xor of the two values.
"""
function compress(pair)
    a, b = pair
    return !(a ⊻ b)
end

"""
    checksum(v::BitVector)

Repeatedly convert non-overlapping pairs of bits in `v` to their compressed
form, as stated in the puzzle input, until the resulting `BitVector` has an 
odd number of bits.
"""
function checksum(v::BitVector)
    result = map(compress, Iterators.partition(v, 2)) |> BitVector
    return isodd(length(result)) ? result : checksum(result)
end

"""
    repr(v::BitVector)

Convert a `BitVector` into a string of the 1's and 0's it is comprised of.
"""
function repr(v::BitVector)
    return filter(c -> c != ' ', bitstring(v))
end

"""
    part1(input)

Given the input as a `BitVector`, expand and contract the bits according to the
puzzle rules and return the resulting bits as a string.
"""
function part1(input)
    data  = unfold_to(input, 272)
    check = checksum(data)
    return repr(check)
end
