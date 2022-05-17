function unfair_fight!(state::BattleState, elf_count::Int)
    return fight!(state) && state.elves == elf_count
end

function power_up!(state::BattleState, boost::Int)
    for unit in get_units(state)
        unit.kind == Elf || continue
        unit.attack += boost
    end
end

function try_combat!(battle_state::BattleState)
    starting_elves = battle_state.elves
    rounds = 0

    while unfair_fight!(battle_state, starting_elves)
        rounds += 1
    end

    if battle_state.elves == starting_elves
        (
            hp_remaining =
                get_units(battle_state) |> (x -> Iterators.map(c -> c.hp, x)) |> sum
        )
        return hp_remaining * rounds
    end
    return nothing
end

function part2(input)
    elven_boost = 0
    outcome = nothing

    while isnothing(outcome)
        battle_state = deepcopy(input)
        elven_boost += 1
        power_up!(battle_state, elven_boost)
        outcome = try_combat!(battle_state)
    end

    return outcome
end
