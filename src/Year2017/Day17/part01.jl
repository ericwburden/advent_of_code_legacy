using DataStructures: CircularDeque

"Move the first value in a CircularDeque to the end"
advance!(buffer) = push!(buffer, popfirst!(buffer))

"""
    circinsert!(buffer::CircularDeque{Int}, value, skip)
    
Skip forward in a `buffer` `skip` times, and insert `value` at the end.
Simulates inserting a value `skip` spaces forward from the last inserted
value.
"""
function circinsert!(buffer::CircularDeque{Int}, value, skip)
    length(buffer) > 1 && foreach(_ -> advance!(buffer), 1:skip)
    push!(buffer, value)
end

"""
    part1(skip)

Repeatedly skip and insert values as described in the puzzle, and return the 
value just after where `2017` is inserted.
"""
function part1(skip)
    buffer = CircularDeque{Int}(2018)
    foreach(n -> circinsert!(buffer, n, skip), 0:2017)
    return popfirst!(buffer)
end
