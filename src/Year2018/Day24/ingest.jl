"""
An `AbstractTeam` is used to sub-type the groups, indicating whether it is an
Immune System group or an Infection group.
"""
abstract type          AbstractTeam end
struct ImmuneSystem <: AbstractTeam end
struct Infection    <: AbstractTeam end

"""
An `AbstractDamageKind` is used to indicate what kinds of damage a group does,
as well as what kinds of damage it is weak or immune to.
"""
abstract type         AbstractDamageKind end
struct Cold        <: AbstractDamageKind end
struct Fire        <: AbstractDamageKind end
struct Radiation   <: AbstractDamageKind end
struct Slashing    <: AbstractDamageKind end
struct Bludgeoning <: AbstractDamageKind end

const Weaknesses = Set{AbstractDamageKind}
const Immunities = Set{AbstractDamageKind}

"""
A `Group` represents a group of combatants.
"""
mutable struct Group{T <: AbstractTeam}
    team::Type{T}
    units::Int
    max_hp::Int
    attack::Int
    damage::AbstractDamageKind
    initiative::Int
    weaknesses::Weaknesses
    immunities::Immunities
end

const INPUT_REGEX = r"(?<units>\d+) [\w ]+ (?<hp>\d+) [\w ]*(?<stats>\(.*\))?[\w ]* (?<atk>\d+) (?<dmg>\w+) [\w ]+ (?<init>\d+)"

function Base.parse(::Type{AbstractDamageKind}, s::AbstractString)
    s == "cold"        && return Cold()
    s == "fire"        && return Fire()
    s == "radiation"   && return Radiation()
    s == "slashing"    && return Slashing()
    s == "bludgeoning" && return Bludgeoning()
    error("Cannot convert $s to a damage kind!")
end

to_stats(::Nothing) = (Weaknesses(), Immunities())
function to_stats(s::AbstractString)::Tuple{Weaknesses,Immunities}
    wmatch = match(r"weak to ([\w, ]+)", s)
    imatch = match(r"immune to ([\w, ]+)", s)
    dmg_kinds(s) = parse.(AbstractDamageKind, split(s, ", ")) |> Set
    weaknesses = isnothing(wmatch) ? Weaknesses() : dmg_kinds(wmatch[1])
    immunities = isnothing(imatch) ? Immunities() : dmg_kinds(imatch[1])
    return (weaknesses, immunities)
end

function Base.parse(team::Type{T}, s::AbstractString) where T <: AbstractTeam
    m = match(INPUT_REGEX, s)
    units, max_hp, atk, init = parse.(Int, [m["units"], m["hp"], m["atk"], m["init"]])
    weaknesses, immunities   = to_stats(m["stats"])
    damage   = parse(AbstractDamageKind, m["dmg"])
    return Group(team, units, max_hp, atk, damage, init, weaknesses, immunities)
end

"""
    ingest(path)

Given the path to the input file, parse lines into `Group`s. The top section
are parsed into ImmuneSystem groups, the bottom section are parsed into 
Infection groups. Return the list of `Group`s.
"""
ingest(path) = open(path) do f
    immune_lines    = split(readuntil(f, "\n\n"), "\n")
    infection_lines = readlines(f)

    immune_system = parse.(ImmuneSystem, immune_lines[2:end])
    infection     = parse.(Infection,    infection_lines[2:end])
    return [immune_system..., infection...]
end

