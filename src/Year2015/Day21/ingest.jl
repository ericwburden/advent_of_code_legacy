#=------------------------------------------------------------------------------
| Today's input is represented as a bunch of constants, because parsing the 
| input file is not really necessary.
|
| Setup the metadata for the item shop
------------------------------------------------------------------------------=#

abstract type EquipmentKind end
struct Weapon <: EquipmentKind end
struct Armor <: EquipmentKind end
struct Ring <: EquipmentKind end
const AnyEquipmentType = Union{Type{Weapon},Type{Armor},Type{Ring}}

struct Equipment
    kind::AnyEquipmentType
    cost::Int
    attack::Int
    defense::Int
end

const SHOP_INVENTORY = Dict(
    Weapon => [
        Equipment(Weapon, 8, 4, 0),
        Equipment(Weapon, 10, 5, 0),
        Equipment(Weapon, 25, 6, 0),
        Equipment(Weapon, 40, 7, 0),
        Equipment(Weapon, 74, 8, 0),
    ],
    Armor => [
        Equipment(Armor, 0, 0, 0), # Represents the 'No Armor' option
        Equipment(Armor, 13, 0, 1),
        Equipment(Armor, 31, 0, 2),
        Equipment(Armor, 53, 0, 3),
        Equipment(Armor, 75, 0, 4),
        Equipment(Armor, 102, 0, 5),
    ],
    Ring => [
        Equipment(Ring, 0, 0, 0), # Represents the 'No Ring' option
        Equipment(Ring, 25, 1, 0),
        Equipment(Ring, 50, 2, 0),
        Equipment(Ring, 100, 3, 0),
        Equipment(Ring, 20, 0, 1),
        Equipment(Ring, 40, 0, 2),
        Equipment(Ring, 80, 0, 3),
    ],
)


#=------------------------------------------------------------------------------
| Setup for a Combatant (the PLAYER and BOSS)
------------------------------------------------------------------------------=#

struct Combatant
    hp::Int
    damage::Int
    armor::Int
end

const BOSS = Combatant(100, 8, 2)
const PLAYER = Combatant(100, 0, 0)
