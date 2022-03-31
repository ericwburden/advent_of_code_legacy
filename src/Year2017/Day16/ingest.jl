"""
Represents a move in the dance, with instructions for completing that move.
"""
abstract type AbstractMove end

struct Spin     <: AbstractMove n::Int           end
struct Exchange <: AbstractMove a::Int;  b::Int  end
struct Partner  <: AbstractMove a::Char; b::Char end

"""
    Base.parse(::Type{AbstractMove}, s::AbstractString)
    Base.parse(::Type{Spin},         s::AbstractString)
    Base.parse(::Type{Exchange},     s::AbstractString)
    Base.parse(::Type{Partner},      s::AbstractString)

Parsers for the various move instructions.
"""
function Base.parse(::Type{Spin}, s::AbstractString)
    m = match(r"s(?<n>\d+)", s)
    n = parse(Int, m["n"])
    return Spin(n)
end

function Base.parse(::Type{Exchange}, s::AbstractString)
    m = match(r"x(?<a>\d+)/(?<b>\d+)", s)
    a = parse(Int, m["a"]) + 1
    b = parse(Int, m["b"]) + 1
    return Exchange(a, b)
end

function Base.parse(::Type{Partner}, s::AbstractString)
    m = match(r"p(?<a>\w+)/(?<b>\w+)", s)
    a = first(m["a"])
    b = first(m["b"])
    return Partner(a, b)
end

function Base.parse(::Type{AbstractMove}, s::AbstractString)
    type = first(s)
    type == 's' && return parse(Spin, s)
    type == 'x' && return parse(Exchange, s)
    type == 'p' && return parse(Partner, s)
    error("""
        Cannot parse "$s", see the documentation for
        Base.parse(::Type{AbstractMove}, s::AbstractString) for
        specifications.
    """)
end

"Read each entry, parse into an AbstractMove, return the list"
ingest(path) = [parse(AbstractMove, s) for s in split(readline(path), ",")]
