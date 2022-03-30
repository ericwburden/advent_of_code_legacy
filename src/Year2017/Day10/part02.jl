"Convert string characters to ASCII codes and append the given values"
preprocess(input) = [Int.(collect(input))..., 17, 31, 73, 47, 23]

"""
    knot_hash_multi!(marks, knot_lengths, rounds=64)

Perform `rounds` number of `knot_hash!`es sequentially on `marks` using the
lengths in `knot_lengths`, without resetting the position or skip amount 
between rounds. Return the final 'twisted' result.
"""
function knot_hash_multi!(marks, knot_lengths, rounds=64)
    pos  = 1
    skip = 0
    for _ in 1:rounds
        marks, pos, skip = knot_hash!(marks, knot_lengths, pos, skip)
    end
    return marks
end

"""
    condense(sparse_hash)

Given a list of 'twisted' values, xor-reduce chunks of 16 values to produce
a list of 16 'dense' values, then convert those values to hex codes and 
return the joined result.
"""
function condense(sparse_hash)
    dense_hash = Int[]
    for chunk in Iterators.partition(sparse_hash, 16)
        dense_value = reduce(⊻, chunk)
        push!(dense_hash, dense_value)
    end

    return join(string(v, base = 16, pad = 2) for v in dense_hash)
end

"""
    part2(input)

Given the input as a string, `knot_hash_multi!` the ASCII code representations
of the input, condense the result as described in the puzzle, then return the
resulting string of hex characters.
"""
function part2(input)
    knot_lengths  = preprocess(input)
    marks         = knot_hash_multi!(collect(0:255), knot_lengths)
    return condense(marks)
end
