"""
An `AbstractTile` represents a space in the map of the caves. The different
sub-types represent the different kinds of tiles represented.
"""
abstract type AbstractTile end

struct Wall <: AbstractTile end

struct Empty <: AbstractTile
    idx::CartesianIndex
end

struct Door <: AbstractTile
    idx::CartesianIndex
    id::UInt32
end

struct Key <: AbstractTile
    idx::CartesianIndex
    id::UInt32
end

struct Entrance <: AbstractTile
    idx::CartesianIndex
end

const Caves = Matrix{AbstractTile}

function AbstractTile(char::Char, idx::CartesianIndex)
    char == '#' && return Wall()
    char == '.' && return Empty(idx)
    char == '@' && return Entrance(idx)

    id = UInt32(1) << UInt32(lowercase(char) - 97)
    isuppercase(char) && return Door(idx, id)
    islowercase(char) && return Key(idx, id)

    error("Cannot convert $char to an `AbstractTile`")
end

"""
    ingest(path) -> Caves

Given the path to the input file, read the file into a matrix of `AbstractTile`s
mirroring the characters from the file.
"""
function ingest(path)
    rows = Vector{Matrix{AbstractTile}}()
    for (row, line) in enumerate(readlines(path))
        tiles = AbstractTile[]
        for (col, char) in enumerate(line)
            idx = CartesianIndex(row, col)
            push!(tiles, AbstractTile(char, idx))
        end
        push!(rows, reshape(tiles, 1, :))
    end
    return reduce(vcat, rows)
end

function Base.show(caves::Caves)
    for row in eachrow(caves)
        for tile in row
            tile isa Wall      && print('#')
            tile isa Empty     && print('.')
            tile isa Entrance  && print('@')
            
            hasproperty(tile, :id) || continue
            label = Char(log2(tile.id & -tile.id) + UInt32('a'))
            tile isa Door     && print(uppercase(label))
            tile isa Key      && print(label)
        end
        println()
    end
    println()
end
