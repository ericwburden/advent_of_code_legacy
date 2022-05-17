#=------------------------------------------------------------------------------
| Lots of modeling! Most of it is self-explanatory, so I'm not including too
| many comments. Most of the abstract types and structs are for the purpose
| of constructing a representation of the railway map, where each space in
| the map indicates how a cart can move from that space.
------------------------------------------------------------------------------=#

abstract type AbstractDirection end

abstract type VerticalDirection <: AbstractDirection end
abstract type HorizontalDirection <: AbstractDirection end

struct North <: VerticalDirection end
struct South <: VerticalDirection end
struct East <: HorizontalDirection end
struct West <: HorizontalDirection end


abstract type AbstractOrientation end

struct VerticalOrientation <: AbstractOrientation end
struct HorizontalOrientation <: AbstractOrientation end


abstract type AbstractRail end

struct Intersection <: AbstractRail end

struct StraightRail{O<:AbstractOrientation} <: AbstractRail
    orientation::Type{O}
end

struct CurvedRail{V<:VerticalDirection,H<:HorizontalDirection} <: AbstractRail
    vertical::Type{V}
    horizontal::Type{H}
end


#=------------------------------------------------------------------------------
| `Chunk`s are used for parsing the input file, mostly just for determining 
| what type of curve a '/' or '\' represents.
------------------------------------------------------------------------------=#

struct Chunk
    center::Char
    north::Union{Nothing,Char}
    east::Union{Nothing,Char}
    south::Union{Nothing,Char}
    west::Union{Nothing,Char}
end

function chunk_at(char_matrix::Matrix{Char}, idx::CartesianIndex{2})
    offsets = CartesianIndex.([(0, 0), (-1, 0), (0, 1), (1, 0), (0, -1)])
    neighbors = map(o -> get(char_matrix, o + idx, nothing), offsets)
    return Chunk(neighbors...)
end

function Base.convert(::Type{AbstractRail}, chunk::Chunk)
    chunk.center == '-' && return StraightRail(HorizontalOrientation)
    chunk.center == '>' && return StraightRail(HorizontalOrientation)
    chunk.center == '<' && return StraightRail(HorizontalOrientation)
    chunk.center == '|' && return StraightRail(VerticalOrientation)
    chunk.center == '^' && return StraightRail(VerticalOrientation)
    chunk.center == 'v' && return StraightRail(VerticalOrientation)
    chunk.center == '+' && return Intersection()
    chunk.center == '/' && return convert(CurvedRail, chunk)
    chunk.center == '\\' && return convert(CurvedRail, chunk)
    error("Don't know how to convert $chunk to a Rail")
end

function Base.convert(::Type{CurvedRail}, chunk::Chunk)
    north_rail = chunk.north ∈ ['|', '+', '>', 'v', '<', '^']
    east_rail = chunk.east ∈ ['-', '+', '>', 'v', '<', '^']
    south_rail = chunk.south ∈ ['|', '+', '>', 'v', '<', '^']
    west_rail = chunk.west ∈ ['-', '+', '>', 'v', '<', '^']
    if chunk.center == '\\'
        (west_rail && south_rail) && return CurvedRail(South, West)
        (east_rail && north_rail) && return CurvedRail(North, East)
    end
    if chunk.center == '/'
        (east_rail && south_rail) && return CurvedRail(South, East)
        (west_rail && north_rail) && return CurvedRail(North, West)
    end
    error("Don't know how to convert $chunk to a CurvedRail")
end


#=------------------------------------------------------------------------------
| A `Cart` represents one of the carts on the track, including a unique
| identifier for each cart, its current heading (direction), its current
| location, and which direction it will turn at the next intersection.
------------------------------------------------------------------------------=#

abstract type AbstractTurn end

struct Straight <: AbstractTurn end
struct TurnLeft <: AbstractTurn end
struct TurnRight <: AbstractTurn end

struct Cart{H<:AbstractDirection,T<:AbstractTurn}
    id::String
    heading::Type{H}
    location::CartesianIndex
    turn::Type{T}
end

function Base.isless(a::Cart, b::Cart)
    return Tuple(a.location) < Tuple(b.location)
end

function Base.convert(::Type{AbstractDirection}, char::Char)
    char == '^' && return North
    char == '>' && return East
    char == 'v' && return South
    char == '<' && return West
    error("Don't know now to convert $char to a Direction")
end

matrixrow(s::String) = reshape(collect(s), 1, length(s))

function Base.convert(::Type{Matrix{Char}}, strings::Vector{String})
    return mapreduce(matrixrow, vcat, strings)
end


"""
    ingest(path)

Given the path to the input file, parse the text into a representation of the
railway map and a list of `Cart`s. Return a tuple containing both.
"""
function ingest(path)
    char_matrix = convert(Matrix{Char}, readlines(path))
    rail_carts = Cart[]
    rail_map::Matrix{Union{Nothing,AbstractRail}} = fill(nothing, size(char_matrix))

    cart_id = 0

    for idx in CartesianIndices(char_matrix)
        char = char_matrix[idx]
        char == ' ' && continue

        chunk = chunk_at(char_matrix, idx)
        rail_map[idx] = convert(AbstractRail, chunk)
        if char ∈ ['^', '>', 'v', '<']
            direction = convert(AbstractDirection, char)
            hex_id = string(cart_id, base = 16)
            push!(rail_carts, Cart(hex_id, direction, idx, TurnLeft))
            cart_id += 1
        end
    end

    return (rail_map, rail_carts)
end


#=------------------------------------------------------------------------------
| These functions help with pretty-printing data structures
------------------------------------------------------------------------------=#

function Base.show(char_matrix::Matrix{Char})
    for row in eachrow(char_matrix)
        foreach(print, row)
        println()
    end
end

const RailSystem = Tuple{Matrix{Union{Nothing,AbstractRail}},Vector{Cart}}
function Base.show(rail_system::RailSystem)
    rail_map, carts = rail_system
    cart_indices = Dict([c.location => c.id for c in carts])
    for (row_idx, row) in enumerate(eachrow(rail_map))
        for (col_idx, rail) in enumerate(row)
            cart_idx = CartesianIndex(row_idx, col_idx)
            if cart_idx in keys(cart_indices)
                print(cart_indices[cart_idx])
                continue
            end
            rail isa Nothing && print(' ')
            rail isa StraightRail && print('.')
            rail isa Intersection && print('+')
            rail isa CurvedRail{North,West} && print('/')
            rail isa CurvedRail{South,East} && print('/')
            rail isa CurvedRail{North,East} && print('\\')
            rail isa CurvedRail{South,West} && print('\\')
        end
        println()
    end
    println()
end
