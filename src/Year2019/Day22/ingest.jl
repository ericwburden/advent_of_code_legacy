"The different kinds of shuffles that can occur"
abstract type       AbstractShuffle end
struct NewStack  <: AbstractShuffle end
struct Cut       <: AbstractShuffle n::Int end
struct Increment <: AbstractShuffle n::Int end

"""
    parse(::Type{AbstractShuffle}, s::AbstractString) -> AbstractShuffle
    parse(::Type{NewStack},        s::AbstractString) -> NewStack
    parse(::Type{Cut},             s::AbstractString) -> Cut
    parse(::Type{Increment},       s::AbstractString) -> Increment

Parse lines from the input file into the appropriate type of shuffle descriptor.
"""
function Base.parse(::Type{AbstractShuffle}, s::AbstractString)
    occursin("stack",     s) && return parse(NewStack, s)
    occursin("cut",       s) && return parse(Cut, s)
    occursin("increment", s) && return parse(Increment, s)
    error("Cannot parse $s into an `AbstractShuffle`!")
end

function Base.parse(::Type{NewStack}, s::AbstractString)
    s == "deal into new stack" && return NewStack()
    error("Cannot parse $s into a `NewStack`!")
end

function Base.parse(::Type{Cut}, s::AbstractString)
    m = match(r"cut (-?\d+)", s)
    isnothing(m[1]) && error("Cannot parse $s into a `Cut`!")
    n = parse(Int, m[1])
    return Cut(n)
end

function Base.parse(::Type{Increment}, s::AbstractString)
    m = match(r"deal with increment (-?\d+)", s)
    isnothing(m[1]) && error("Cannot parse $s into an `Increment`!")
    n = parse(Int, m[1])
    return Increment(n)
end

"Parse each line into an `AbstractShuffle` and return the list"
ingest(path) = [parse(AbstractShuffle, line) for line in readlines(path)]
