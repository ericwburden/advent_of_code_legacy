mutable struct HardMode <: BattleState
    player::Player
    boss::Boss
    effects::OngoingEffects
end
HardMode(player, boss) = HardMode(player, boss, Dict())

"In Hard Mode, the player loses 1 HP at the beginning of each of their turns"
preprocess!(battle::HardMode) = battle.player.hp -= 1

"""
    part1()

Solve part one of the puzzle.
"""
function part2()
    initial = HardMode(Player(50, 500), BOSS)
    return cheap_win(initial)
end
