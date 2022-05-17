"""
    part2(skip)

Given the skip value as the input, assume that zero stays at the front of a
buffer (like the example, not like our part 1 solution). Repeatedly identify
which position to insert new values into (50 million times!), and whenever
it's the position following zero, track that value. Return the last value
inserted after zero.
"""
function part2(skip)
    numbers = 50_000_000
    after_zero = nothing
    position = 0

    for curr_len = 1:numbers
        position = 1 + (position + skip) % curr_len
        if (position == 1)
            after_zero = curr_len
        end
    end

    return after_zero
end
