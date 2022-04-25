"""
An `AbstractSquare` represents the material found at each coordinate
location of the ground scan.
"""
abstract type AbstractSquare end
struct Clay    <: AbstractSquare end
struct Water   <: AbstractSquare end
struct WetSand <: AbstractSquare end
struct DrySand <: AbstractSquare end

"Handy type aliases"
const Position     = Tuple{Int,Int}
const ScanMap      = Dict{Position,AbstractSquare}
const ScanMapEntry = Pair{Position,AbstractSquare}
const ClayVein     = Vector{ScanMapEntry}

"""
    parse(::Type{ClayVein}, s::AbstractString)

Parse a string from the input file into a 'vein' of Clay, a series of
`ScanMapEntry` pairs.
"""
function Base.parse(::Type{ClayVein}, s::AbstractString)
    m = match(r"(x|y)=(\d+), (x|y)=(\d+)..(\d+)", s)
    dim1, val1, dim2, val2, val3 = m.captures
    val1, val2, val3 = parse.(Int, (val1, val2, val3))
    clay_vein_entries = ScanMapEntry[]
    for (c1, c2) in zip(Iterators.repeated(val1), val2:val3)
        coordinate = if dim1 == "x" && dim2 == "y"
            (c1, c2)
        else
            (c2, c1)
        end
        push!(clay_vein_entries, coordinate => Clay())
    end
    return clay_vein_entries
end


"""
    ingest(path)

Given the path to the input file, read and parse each line into a series
of `ScanMapEntry` pairs, then return a dictionary representing the scanned
slice of ground.
"""
ingest(path) = mapreduce(l -> parse(ClayVein, l), vcat, readlines(path)) |> ScanMap

function range_of(scan_map::ScanMap)
    min_x = min_y = typemax(Int)
    max_x = max_y = typemin(Int)
    for (x, y) in keys(scan_map)
        x < min_x && (min_x = x)
        x > max_x && (max_x = x)
        y < min_y && (min_y = y)
        y > max_y && (max_y = y)
    end
    return (min_x:max_x, min_y:max_y)
end

"""
    show(scan_map::ScanMap)

Pretty printing for the `ScanMap`
"""
function Base.show(scan_map::ScanMap)
    x_range, y_range = range_of(scan_map)
    for y in y_range
        for x in x_range
            square = get(scan_map, (x, y), DrySand())
            show(square)
        end
        println()
    end
end

Base.show(::Clay)    = print('#')
Base.show(::Water)   = print('~')
Base.show(::WetSand) = print('|')
Base.show(::DrySand) = print('.')


