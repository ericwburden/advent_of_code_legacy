abstract type AbstractUnitKind end

struct Elf <: AbstractUnitKind end
struct Goblin <: AbstractUnitKind end

const Position = Tuple{Int,Int}

mutable struct Unit{K<:AbstractUnitKind}
    kind::Type{K}
    hp::Int
    attack::Int
end

function Unit(team::Type{K}) where {K<:AbstractUnitKind}
    return Unit(team, 200, 3)
end

struct Obstacle end

const MapObject = Union{Unit,Obstacle,Nothing}
const Terrain = Vector{Vector{MapObject}}
const UnitMap = Dict{Unit,Position}
const UnitMapEntry = Pair{Unit,Position}

mutable struct BattleState
    terrain::Terrain
    unit_map::UnitMap
    elves::Int
    goblins::Int
end

function Base.getindex((; terrain)::BattleState, position::Position)
    row, col = position
    return terrain[row][col]
end

function Base.setindex!((; terrain)::BattleState, object::MapObject, position::Position)
    row, col = position
    terrain[row][col] = object
end

function Base.getindex((; unit_map)::BattleState, unit::Unit)
    return unit_map[unit]
end

function Base.setindex!((; unit_map)::BattleState, position::Position, unit::Unit)
    unit_map[unit] = position
end


function map_object(char::Char)
    char == '.' && return nothing
    char == '#' && return Obstacle()
    char == 'E' && return Unit(Elf)
    char == 'G' && return Unit(Goblin)
    error("Cannot make a `MapObject` of '$char'")
end


function ingest(path)
    terrain = Terrain()
    unit_map = UnitMap()
    elves = 0
    goblins = 0

    for (row_idx, line) in (enumerate ∘ readlines)(path)
        map_row = MapObject[]
        for (col_idx, char) in enumerate(line)
            object = map_object(char)
            push!(map_row, object)
            object isa Unit && setindex!(unit_map, (row_idx, col_idx), object)
            if (object isa Unit{Elf})
                elves += 1
            end
            if (object isa Unit{Goblin})
                goblins += 1
            end
        end
        push!(terrain, map_row)
    end

    return BattleState(terrain, unit_map, elves, goblins)
end


function Base.show((; terrain)::BattleState)
    for row in terrain
        stats = []
        for object in row
            object isa Nothing && print('.')
            object isa Obstacle && print('#')
            object isa Unit{Elf} && print('E')
            object isa Unit{Goblin} && print('G')
            if object isa Unit
                stat = object.kind == Elf ? "E" : "G"
                stat *= "($(object.hp))"
                push!(stats, stat)
            end
        end
        print("\t")
        println(join(stats, ", "))
    end
end
