using DataStructures: Queue, enqueue!, dequeue!


function Base.isless(a::UnitMapEntry, b::UnitMapEntry)
    _, a_position = a
    _, b_position = b
    return a_position < b_position
end

function dims(terrain::Terrain)
    rows = length(terrain)
    cols = (length ∘ first)(terrain)
    return (rows, cols)
end

function get_units((; unit_map)::BattleState)
    unit_positions = (sort ∘ collect ∘ pairs)(unit_map)
    return map(up -> up.first, unit_positions)
end

function get_unit_position((; unit_map)::BattleState, unit::Unit)
    return unit_map[unit]
end

function is_inbounds((; terrain)::BattleState, position::Position)
    rows, cols = dims(terrain)
    row, col = position
    0 < row <= rows || return false
    0 < col <= cols || return false
    return true
end

function get_nearby_positions(state::BattleState, position::Position)
    add_offset_to_position(o) = o .+ position
    keep_inbounds(p) = is_inbounds(state, p)
    (
        nearby_positions =
            [(-1, 0), (0, -1), (0, 1), (1, 0)] |>
            (x -> Iterators.map(add_offset_to_position, x)) |>
            (x -> Iterators.filter(keep_inbounds, x))
    )
    return nearby_positions
end

function get_nearby_opponent(state::BattleState, unit::Unit)
    unit_position = get_unit_position(state, unit)
    nearest_opponent = nothing

    for position in get_nearby_positions(state, unit_position)
        object = getindex(state, position)
        object isa Unit || continue
        object.kind == unit.kind && continue
        if isnothing(nearest_opponent) || object.hp < nearest_opponent.hp
            nearest_opponent = object
        end
    end

    return nearest_opponent
end

const PositionQueue = Queue{Tuple{Position,Vector{Position}}}
function step_to_opponent(state::BattleState, unit::Unit)
    start_position = getindex(state, unit)
    position_queue = PositionQueue()
    found_path = nothing
    visited = Set{Position}()
    get_object(p) = getindex(state, p)
    is_enemy(o) = o isa Unit && o.kind != unit.kind
    is_ally(o) = o isa Unit && o.kind == unit.kind
    has_enemy(p) = (is_enemy ∘ get_object)(p)
    enqueue!(position_queue, (start_position, []))

    while !isempty(position_queue)
        current, path = dequeue!(position_queue)
        current ∈ visited && continue
        push!(visited, current)

        if has_enemy(current)
            isnothing(found_path) && (found_path = path)
            length(path) > length(found_path) && return first(found_path)
            last(path) < last(found_path) && (found_path = path)
        end

        for neighbor in get_nearby_positions(state, current)
            neighbor ∈ visited && continue
            neighbor_object = get_object(neighbor)
            neighbor_object isa Obstacle && continue
            is_ally(neighbor_object) && continue
            enqueue!(position_queue, (neighbor, [path..., neighbor]))
        end
    end
    return isnothing(found_path) ? nothing : first(found_path)
end

function fight!(state::BattleState)
    # Find each unit, sorted by action order, then have
    # each one attempt to act. If any unit does not move
    # or attack, that is because there are no opponents left
    # and combat ends.
    for unit in get_units(state)
        # Skip units who died during the round
        unit.hp > 0 || continue
        act!(state, unit)
    end

    # It is possible for the last blow struck in a round to end
    # the fight. In that case, the round ends with one team 
    # entirely eliminated, and combat does not proceed to
    # another round.
    return state.elves > 0 && state.goblins > 0
end

function act!(state::BattleState, unit::Unit)
    moved = attacked = false
    acquire_target() = get_nearby_opponent(state, unit)

    opponent = acquire_target()
    moved = isnothing(opponent) && move!(state, unit)

    # Re-acquire target if the unit moved
    opponent = moved ? acquire_target() : opponent

    attacked = attack!(state, unit, opponent)

    return moved || attacked
end

attack!(::BattleState, ::Unit, ::Nothing) = false
function attack!(state::BattleState, attacker::Unit, defender::Unit)
    defender.hp -= attacker.attack
    defender.hp > 0 && return true # Return early if no one was defeated

    # Update the number of combatants if one is defeated
    if (defender.kind == Elf)
        state.elves -= 1
    end
    if (defender.kind == Goblin)
        state.goblins -= 1
    end

    # Clean up defeated opponents
    position = getindex(state, defender)
    state[position] = nothing
    delete!(state.unit_map, defender)

    return true
end

function move!(state::BattleState, unit::Unit)
    step = step_to_opponent(state, unit)
    isnothing(step) && return false
    position = getindex(state, unit)
    state[position] = nothing
    state[step] = unit
    state[unit] = step
    return true
end

function part1(input)
    battle_state = deepcopy(input)
    rounds = 0
    while fight!(battle_state)
        rounds += 1
    end
    (hp_remaining = get_units(battle_state) |> (x -> Iterators.map(c -> c.hp, x)) |> sum)
    return hp_remaining * rounds
end
