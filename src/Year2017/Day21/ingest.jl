"""
    all_arrangements(pixels::BitMatrix)

Given a `BitMatrix` representing a set of lit pixels, return a list of 
`BitMatrix`es that have been flipped and rotated into all 8 possible
orientations.
"""
function all_arrangements(pixels::BitMatrix)
    arrangements = BitMatrix[]
    for i in 0:7
        arrangement = rotr90(pixels, i % 4)
        i >= 4 && reverse!(arrangement, dims = 2)
        push!(arrangements, arrangement)
    end
    return arrangements
end

"""
    parse(::Type{BitMatrix}, s::AbstractString)

Parse a string into a `BitMatrix`, in accordance with the method described
in the puzzle input.
"""
function Base.parse(::Type{BitMatrix}, s::AbstractString)
    char_matrix = reduce(hcat, collect(l) for l in split(s, "/"))
    return char_matrix .== '#'
end

const ReplacementMap = Dict{BitMatrix,BitMatrix}

"""
    ingest(path)

Parse each line into one or more entries in a `ReplacementMap`, indicating 
how to replace size 2 or 3 matrix, to "enhance" the image.
"""
function ingest(path)
    replacement_map = ReplacementMap()
    for line in readlines(path)
        key, value = [parse(BitMatrix, p) for p in split(line, " => ")]
        for arrangement in all_arrangements(key)
            replacement_map[arrangement] = value
        end
    end
    return replacement_map
end
