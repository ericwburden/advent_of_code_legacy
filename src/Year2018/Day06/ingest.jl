"Parse a string into a `CartesianIndex`"
function Base.parse(::Type{CartesianIndex}, s::AbstractString)
    m = match(r"(\d+), (\d+)", s)
    col, row = parse.(Int, m.captures)
    return CartesianIndex(row, col)
end

"Parse each line from the input file into a CartesianIndex, and return the list"
ingest(path) = [parse(CartesianIndex, l) for l in readlines(path)]
