#=------------------------------------------------------------------------------
| There's no real input to parse, but there's a LOT of different data
| structures and types we'll set up to represent the flow of the game.
------------------------------------------------------------------------------=#

"""
    AbstractEffect
    Damage(amount) <: AbstractEffect
    Siphon(amount) <: AbstractEffect
    Armor(amount)  <: AbstractEffect
    Regen(amount)  <: AbstractEffect

Represents a spell effect, which is any change to the state of the game 
resulting from a spell. Effects can be applied instantaneously or over time.
"""
abstract type AbstractEffect end
struct Damage <: AbstractEffect
    amount::Int
end
struct Siphon <: AbstractEffect
    amount::Int
end
struct Armor <: AbstractEffect
    amount::Int
end
struct Regen <: AbstractEffect
    amount::Int
end


"""
    AbstractSpell
    Instant(cost, effect) <: AbstractSpell
    Ongoing(cost, rounds, effect) <: AbstractSpell

Represents a spell being cast, either instantly or as an ongoing spell. All 
spells have a cost and an effect, ongoing spells also have a number of rounds
for which the spell is active and cannot be recast.
"""
abstract type AbstractSpell end

struct Instant <: AbstractSpell
    cost::Int
    effect::AbstractEffect
end

struct Ongoing <: AbstractSpell
    cost::Int
    rounds::Int
    effect::AbstractEffect
end


"Represents the player"
mutable struct Player
    hp::Int
    mp::Int
    armor::Int
end
Player(hp, mp) = Player(hp, mp, 0)

"Represents the Boss"
mutable struct Boss
    hp::Int
    attack::Int
end

"List of possible spell names as an Enum"
@enum SpellName begin
    MagicMissile
    Drain
    Shield
    Poison
    Recharge
end

"""
    BattleState
    NormalMode(player, boss, effects) <: BattleState
    HardMode(player, boss, effects)   <: BattleState

Represents the current state of the battle, either in normal mode (for part 1) 
or *hard* mode (for part 2). The data contained is the same for both.
"""
abstract type BattleState end
const OngoingEffects = Dict{SpellName,Tuple{Int,AbstractEffect}}
mutable struct NormalMode <: BattleState
    player::Player
    boss::Boss
    effects::OngoingEffects
end
NormalMode(player, boss) = NormalMode(player, boss, Dict())

# Useful constants.
const BOSS = Boss(58, 9)
const SPELLBOOK = Dict{SpellName,AbstractSpell}(
    MagicMissile => Instant(53, Damage(4)),
    Drain => Instant(73, Siphon(2)),
    Shield => Ongoing(113, 6, Armor(7)),
    Poison => Ongoing(173, 6, Damage(3)),
    Recharge => Ongoing(229, 5, Regen(101)),
)
