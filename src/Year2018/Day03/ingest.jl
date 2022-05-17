"Used to represent a single 'claim' on a portion of the fabric"
struct Claim
    id::Int
    rows::UnitRange
    cols::UnitRange
end

"Parse an input line into a `Claim`"
function Base.parse(::Type{Claim}, s::AbstractString)
    m = match(r"^#(?<id>\d+) @ (?<loc>\d+,\d+): (?<size>\d+x\d+)", s)
    id = parse(Int, m["id"])
    left, top = parse.(Int, split(m["loc"], ",")) .+ 1
    width, height = parse.(Int, split(m["size"], "x"))
    rows = top:(top+height-1)
    cols = left:(left+width-1)
    return Claim(id, rows, cols)
end

"Parse each line into a `Claim` and return the list of claims"
ingest(path) = [parse(Claim, l) for l in readlines(path)]
