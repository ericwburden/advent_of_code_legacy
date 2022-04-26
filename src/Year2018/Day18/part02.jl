"""
    part2(input)

Given the input as a character matrix, convert it to a landscape and
simulate changes in the landscape until a cycle is observed. With the
knowledge of the state of the landscape at the start of the cycle and
the length of the cycle, we can determine which state the landscape
will be in after the 1,000,000,000th minute and return the resource
value of that state.
"""
function part2(input)
    landscape   = convert(Landscape, input)
    seen_states = Dict{Landscape,Int}()
    generation  = 0

    while landscape ∉ keys(seen_states)
        seen_states[landscape] = generation
        generation += 1
        landscape   = next_state(landscape)
    end

    cycle_len   = generation - seen_states[landscape]
    remaining   = (1_000_000_000 - generation) % cycle_len
    
    last_state  = nth(iterated(next_state, landscape), remaining + 1)
    trees       = count(a -> a isa Trees, last_state)
    lumberyards = count(a -> a isa Lumberyard, last_state)
    return trees * lumberyards
end

