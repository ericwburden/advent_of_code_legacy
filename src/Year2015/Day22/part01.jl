using DataStructures: BinaryMinHeap

# Helper functions
has_ended(battle::BattleState) = battle.player.hp <= 0 || battle.boss.hp <= 0
player_wins(battle::BattleState) = battle.player.hp > 0 && battle.boss.hp <= 0

"""
    process_effects!(battle::BattleState)

Given a `BattleState`, iterate over the active effects of the battle, applying
each one in order. Also resets player stats (just armor, really) before 
applying effects.
"""
function process_effects!(battle::BattleState)
    # Reset player armor before applying effects
    battle.player.armor = 0

    for (spell_name, (rounds_remaining, effect)) in battle.effects
        activate!(battle, effect)
        if rounds_remaining > 1
            battle.effects[spell_name] = (rounds_remaining - 1, effect)
        else
            delete!(battle.effects, spell_name)
        end
    end
end


"""
    activate!(battle::BattleState, (; amount)::Damage)
    activate!(battle::BattleState, (; amount)::Siphon)
    activate!(battle::BattleState, (; amount)::Armor)
    activate!(battle::BattleState, (; amount)::Regen)

Applies a given effect to the `BattleState`.
"""
function activate!(battle::BattleState, (; amount)::Damage)
    battle.boss.hp -= amount
end

function activate!(battle::BattleState, (; amount)::Siphon)
    battle.boss.hp -= amount
    battle.player.hp += amount
end

function activate!(battle::BattleState, (; amount)::Armor)
    battle.player.armor = amount
end

function activate!(battle::BattleState, (; amount)::Regen)
    battle.player.mp += amount
end


"""
    cast!(battle::BattleState, ::SpellName, (; cost, effect)::Instant)
    cast!(battle::BattleState, name::SpellName, (; cost, rounds, effect)::Ongoing)

Cast a spell. An `Instant` spell has its effect applied immediately. An 
`Ongoing` spell has its effect added to the battle's list of ongoing effects.
"""
function cast!(battle::BattleState, ::SpellName, (; cost, effect)::Instant)
    battle.player.mp -= cost
    activate!(battle, effect)
end

function cast!(battle::BattleState, name::SpellName, (; cost, rounds, effect)::Ongoing)
    battle.player.mp -= cost
    battle.effects[name] = (rounds, effect)
end


"Placeholder, for a function call we'll need for Hard Mode"
preprocess!(::NormalMode) = missing

"""
    possible_states(battle::BattleState)

Given a `BattleState`, create a version of the state where each spell the player
can cast has been cast on the player's turn and the boss has taken his turn as
well. Follows the flow of the battle described in the puzzle.
"""
function possible_states(battle::BattleState)
    # Pre-emptive copy, to avoid modifying the input
    battle = deepcopy(battle)

    # In Hard Mode, there are modifications made to the battle state at this point
    preprocess!(battle)

    # The steps of each round...
    # 1. On the player's turn, process the ongoing effects...
    process_effects!(battle)

    # 2. If the battle is over, then there's only one state worth returning.
    has_ended(battle) && return [(0, battle)]

    # 3. Try casting each available spell...
    states = Tuple{Int,BattleState}[]   # (mana spent, new state)
    for (spell_name, spell) in SPELLBOOK
        # If the spell is too expensive to cast, or the spell effect is still
        # ongoing, skip trying to cast this one.
        spell.cost > battle.player.mp && continue
        haskey(battle.effects, spell_name) && continue

        # If the player can cast this spell, we need to make and modify a copy
        # of the battle state for each different spell cast
        new_state = deepcopy(battle)
        cast!(new_state, spell_name, spell)
        push!(states, (spell.cost, new_state))
    end

    # 4. For each possible cast, try to take the boss's turn...
    for (_, state) in states
        # Process the ongoing effects on the boss's turn
        process_effects!(state)

        # If the boss is dead, then there's nothing left to be done
        state.boss.hp <= 0 && continue

        # If the boss is alive, then he takes a swing at the player
        state.player.hp -= max(state.boss.attack - state.player.armor, 1)
    end

    # Return all the possible states that can be reached from `battle`
    return states
end

"""
    cheap_win(battle::BattleState)

Given an initial `BattleState`, search through the possible ensuing battle
states to find the state where the player wins while spending the minimum
amount of mana.
"""
Base.isless(a::BattleState, b::BattleState) = a.boss.hp < b.boss.hp
function cheap_win(battle::BattleState)
    heap = BinaryMinHeap{Tuple{Int,BattleState}}([(0, battle)])

    while !isempty(heap)
        (mana_spent, battle_state) = pop!(heap)
        player_wins(battle_state) && return mana_spent
        has_ended(battle_state) && continue

        for (mana_cost, next_state) in possible_states(battle_state)
            total_spent = mana_spent + mana_cost
            push!(heap, (total_spent, next_state))
        end
    end
end

"""
    part1()

Solve part one of the puzzle.
"""
function part1()
    initial = NormalMode(Player(50, 500), BOSS)
    return cheap_win(initial)
end
