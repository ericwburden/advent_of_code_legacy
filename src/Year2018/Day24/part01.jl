"""
An `IdentifiedGroup` is just like a `Group`, but with an added `id` to help keep
track of which group it is. Each group will be stored in a dictionary referenced
by id in the `Battlefield`.
"""
mutable struct IdentifiedGroup{T<:AbstractTeam}
    id::Int
    team::Type{T}
    units::Int
    max_hp::Int
    attack::Int
    damage::AbstractDamageKind
    initiative::Int
    weaknesses::Weaknesses
    immunities::Immunities
end

"""
Constructor to convert a `Group` into an `IdentifiedGroup`.
"""
function IdentifiedGroup(id_group::Tuple{Int,Group})
    id, group = id_group
    (; team, units, max_hp, attack, damage, initiative, weaknesses, immunities) = group
    return IdentifiedGroup(
        id,
        team,
        units,
        max_hp,
        attack,
        damage,
        initiative,
        weaknesses,
        immunities,
    )
end

"""
A `Battlefield` represents the current state of the battle, tracking all the
current `Group`s, which groups have been targeted, and a listing of which groups
have targeted which other groups.
"""
mutable struct Battlefield
    groups::Dict{Int,IdentifiedGroup}
    targets::Dict{Int,Int}
    targeted::Set{Int}
end

"""
Constructor to convert a list of `Group`s to a `Battlefield`.
"""
function Battlefield(groups::Vector{Group})
    identified_groups = IdentifiedGroup.(enumerate(groups))
    groups = Dict(id => group for (id, group) in enumerate(identified_groups))
    return Battlefield(groups, Dict{Int,Int}(), Set{Int}())
end

Base.getindex((; groups)::Battlefield, idx::Int) = groups[idx]
effective_power((; units, attack)::IdentifiedGroup) = units * attack
effective_hp((; units, max_hp)::IdentifiedGroup) = units * max_hp

function untargeted_groups((; groups, targeted)::Battlefield)
    return Iterators.filter(g -> g.id ∉ targeted, values(groups))
end

function effective_power_order(a::IdentifiedGroup, b::IdentifiedGroup)
    a_power = effective_power(a)
    b_power = effective_power(b)
    return a_power == b_power ? initiative_order(a, b) : a_power < b_power
end

function initiative_order(a::IdentifiedGroup, b::IdentifiedGroup)
    return a.initiative < b.initiative
end

function potential_damage(attacker::IdentifiedGroup, defender::IdentifiedGroup)
    attacker.damage ∈ defender.immunities && return 0
    multiplier = attacker.damage ∈ defender.weaknesses ? 2 : 1
    return effective_power(attacker) * multiplier
end

function select_target!(group::IdentifiedGroup, battlefield::Battlefield)
    groups = untargeted_groups(battlefield)
    other_team = Iterators.filter(g -> g.team != group.team, groups)
    still_alive = Iterators.filter(g -> g.units > 0, other_team)
    can_attack = Iterators.filter(g -> group.damage ∉ g.immunities, still_alive)

    targets = Group[]
    max_damage = 0
    for defender in can_attack
        damage_estimate = potential_damage(group, defender)
        damage_estimate == max_damage && push!(targets, defender)
        damage_estimate > max_damage || continue
        targets = [defender]
        max_damage = damage_estimate
    end

    # If there are no viable targets, then just move on
    isempty(targets) && return
    priority = sort!(targets, lt = effective_power_order, rev = true)
    target = first(priority)
    push!(battlefield.targeted, target.id)
    setindex!(battlefield.targets, target.id, group.id)
end

function select_targets!(battlefield::Battlefield)
    groups = values(battlefield.groups) |> collect
    sort!(groups, lt = effective_power_order, rev = true)
    for group in groups
        group.units > 0 || continue
        select_target!(group, battlefield)
    end
end

function attack!(attacker::IdentifiedGroup, defender::IdentifiedGroup)
    hp_remaining = effective_hp(defender) - potential_damage(attacker, defender)
    defender.units = ceil(Int, hp_remaining / defender.max_hp)
end

function attack_targets!(battlefield::Battlefield)
    groups = values(battlefield.groups) |> collect
    sort!(groups, lt = initiative_order, rev = true)
    for group in groups
        group.units > 0 || continue
        target = get(battlefield.targets, group.id, nothing)
        isnothing(target) && continue
        attack!(group, battlefield[target])
    end
end

function reset!(battlefield::Battlefield)
    battlefield.targets = Dict{Int,Int}()
    battlefield.targeted = Set{Int}()
    for (id, group) in battlefield.groups
        group.units > 0 && continue
        delete!(battlefield.groups, id)
    end
end

function is_active((; groups)::Battlefield)
    immune_system = 0
    infection = 0
    for group in values(groups)
        group.units > 0 || continue
        group.team == ImmuneSystem && (immune_system += 1)
        group.team == Infection && (infection += 1)
    end
    return immune_system > 0 && infection > 0
end

function fight!(battlefield::Battlefield)
    select_targets!(battlefield)
    attack_targets!(battlefield)
    reset!(battlefield)
    return is_active(battlefield)
end

function total_units((; groups)::Battlefield)
    return sum(g -> g.units, values(groups))
end

"""
    part1(input)

Simulate the battle and return the number of remaining units at the end.
"""
function part1(input)
    battlefield = Battlefield(input)
    while fight!(battlefield)
    end
    return total_units(battlefield)
end
