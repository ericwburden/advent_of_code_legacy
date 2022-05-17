"""
    part2(input)

Over time, the state of potted plants stabilizes, just shifted to the 
right by a consistent amount. Given the initial state of pots and 
grow rules, simulate growth until the change in the index sum between
generations stabilizes. From there, just calculate the total increase
in index sum for the remaining generations, and add the index sum
of the last simulated generation to it.
"""
function part2(input)
    pots, grow_rules = input
    last_pot_sum = sum(pots.filled)
    plant_gen_diff = 0
    generations = 0

    # Simulate generations until the difference between generations
    # stabilizes.
    while true
        pots = next_state(pots, grow_rules)
        pot_sum = sum(pots.filled)
        current_diff = pot_sum - last_pot_sum
        plant_gen_diff == current_diff && break
        plant_gen_diff = current_diff
        last_pot_sum = pot_sum
        generations += 1
    end

    # Add the last simulated index sum to the cumulative increase
    # over the remaining generations.
    remaining_generations = 50_000_000_000 - generations
    return last_pot_sum + (plant_gen_diff * remaining_generations)
end
