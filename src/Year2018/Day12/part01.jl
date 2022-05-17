using IterTools: iterated, nth

"""
    next_state(pots::Pots, grow_rules::GrowRules)

Given a `Pots` representing the state of observed pots and a set
of `grow_rules`, return a `Pots` representing the next generation
of plant growth.
"""
function next_state((; filled, first, last)::Pots, grow_rules::GrowRules)
    range = (first-2):(last+2)    # The range to check for growth
    new_plants = Set{Int}()            # The indices of new generation plants
    first, last = (nothing, 0)          # The first/last of the next generation range

    # For each pot in the range to check for growth...
    for idx in range

        # Derive an integer representing the state of the 
        # target pot and surrounding pots, consistent with
        # the process for producing the `GrowRules`.
        grow_rule = 0
        for (pow, offset) in zip(0:4, -2:2)
            (idx + offset) ∈ filled || continue
            grow_rule += 10^pow
        end

        # If the environment of the current pot matches one
        # of the grow rules, add a value to the set of new
        # plants and update the next generation range
        grow_rule ∈ grow_rules.inner || continue
        push!(new_plants, idx)
        if (isnothing(first))
            first = idx
        end
        last = idx
    end

    return Pots(new_plants, first, last)
end


"""
    part1(input)

Given the initial state of potted plants and the grow rules, determine
the state of potted plants in the 20th subsequent generation and return
the sum of the indices of the planted pots.
"""
function part1(input, steps = 21)
    pots, grow_rules = input
    (
        total_plants =
            iterated(x -> next_state(x, grow_rules), pots) |>
            (x -> nth(x, steps)) |>
            (x -> sum(x.filled))
    )
    return total_plants
end
