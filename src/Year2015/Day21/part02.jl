"""
    part2()

Using ALL_EQUIPMENT_COMBOS (no need for taking input), equip the player with 
all combinations of equipment, filter to keep only the equpped players that 
will lose to the boss, extract the cost of the equipment from those players, 
then return the maximum.
"""
function part2()
    (ALL_EQUIPMENT_COMBOS
        |> (x -> map(combo -> equip(PLAYER, combo...), x))
        |> (x -> filter(cost_player -> !can_win(cost_player[2]), x))
        |> (x -> map(cost_player -> cost_player[1], x))
        |> maximum)
end