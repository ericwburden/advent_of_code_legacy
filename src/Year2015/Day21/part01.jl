"A pre-calculated set of all possible equipment combinations"
const ALL_EQUIPMENT_COMBOS = begin
    output = Vector{NTuple{4,Equipment}}
    weapons = SHOP_INVENTORY[Weapon]
    armors = SHOP_INVENTORY[Armor]
    rings = SHOP_INVENTORY[Ring]

    Iterators.product(weapons, armors, rings, rings) |> collect
end

"""
    equip(combatant::Combatant, equipment::Equipment...)

Given a `combatant` and any number of `equipment`, simulate the process of 
equipping each item to the `combatant` and return a tuple of the total equipment
cost and the upgraded `combatant`.
"""
function equip(combatant::Combatant, equipment::Equipment...)
    total_cost = 0
    total_damage = combatant.damage
    total_armor = combatant.armor
    for equip in equipment
        total_cost += equip.cost
        total_damage += equip.attack
        total_armor += equip.defense
    end

    return (total_cost, Combatant(combatant.hp, total_damage, total_armor))
end

"""
    can_win(player::Combatant)

Given a `player`, pit that player against the BOSS and determine whether the
player can win. Calculates how many rounds it takes the player to kill the BOSS
and vice versa, then determines the winner by identifying which combatant dies
first.
"""
function can_win(player::Combatant)
    player_win_turns = ceil(BOSS.hp / max(player.damage - BOSS.armor, 1))
    boss_win_turns = ceil(player.hp / max(BOSS.damage - player.armor, 1))
    return player_win_turns <= boss_win_turns
end

"""
    part1()

Using ALL_EQUIPMENT_COMBOS (no need for taking input), equip the player with 
all combinations of equipment, filter to keep only the equpped players that 
can beat the boss, extract the cost of the equipment from those players, then
return the minimum.
"""
function part1()
    (
        ALL_EQUIPMENT_COMBOS |>
        (x -> map(combo -> equip(PLAYER, combo...), x)) |>
        (x -> filter(cost_player -> can_win(cost_player[2]), x)) |>
        (x -> map(cost_player -> cost_player[1], x)) |>
        minimum
    )
end
