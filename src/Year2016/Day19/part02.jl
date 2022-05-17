using DataStructures: Deque, enqueue!, dequeue!

"""
    fill_deque(t::Type, v)

Helper function to make creating and filling a Deque easier.
"""
function fill_deque(t::Type, v)
    deque = Deque{t}()
    foreach(x -> push!(deque, x), v)
    return deque
end

"""
    part2(input)

Now, the elves are stealing presents from the elf directly across the circle. To
simulate this, create two `Deque`s, each containing half the elves (represented
as unsigned integers indicating their place value). The current elf will be the
first in the first half, and the elf they steal from will be the first in the
second half. Each round, the elf stolen from will be removed, and the stealing
elf will be moved to the last position in the second half. If there's an odd
number of elves remaining, then the next elf will be skipped, moving from the
first position in the second half to the last position in the first half. This
process continues until only one elf remains.
"""
function part2(input)
    halfway = input ÷ 2
    half_one = fill_deque(UInt32, UInt32(1):halfway)
    half_two = fill_deque(UInt32, (halfway+1):input)
    remaining = input

    while remaining > 1
        popfirst!(half_two) # Discard this one
        push!(half_two, popfirst!(half_one))
        isodd(remaining) && push!(half_one, popfirst!(half_two))
        remaining -= 1
    end

    return pop!(half_two) |> Int
end
