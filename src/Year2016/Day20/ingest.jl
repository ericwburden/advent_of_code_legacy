"""
    BlockedRange(low::Int, high::Int) <: IPRange

Represents a range of blocked IP addresses.
"""
abstract type IPRange end

struct BlockedRange <: IPRange
    low::Int
    high::Int
end

"Parse a BlockedRange from an input line"
function Base.parse(::Type{BlockedRange}, s::AbstractString)
    low, high = parse.(Int, split(s, '-'))
    return BlockedRange(low, high)
end

"Parse each line of the input into a BlockedRange and return the list"
ingest(path) = map(l -> parse(BlockedRange, l), readlines(path))
