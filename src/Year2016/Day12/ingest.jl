abstract type Value end

function Base.parse(::Type{Value}, s::AbstractString)
    occursin(r"^a|b|c|d$", s) && return parse(Register, s)
    occursin(r"^-?\d+$", s) && return parse(Literal, s)
    error("Cannot parse $s into a `Value`!")
end

struct Register <: Value
    name::Char
end
Base.parse(::Type{Register}, s::AbstractString) = Register(s[1])

struct Literal <: Value
    value::Int
end
Base.parse(::Type{Literal}, s::AbstractString) = Literal(parse(Int, s))


abstract type Instruction end

function Base.parse(::Type{Instruction}, s::AbstractString)
    m = match(r"(?<instr>\w+) (?<rem>.+)", s)
    occursin("cpy", m["instr"]) && return parse(Cpy, m["rem"])
    occursin("inc", m["instr"]) && return parse(Inc, m["rem"])
    occursin("dec", m["instr"]) && return parse(Dec, m["rem"])
    occursin("jnz", m["instr"]) && return parse(Jnz, m["rem"])
    error("Cannot parse $s into an `Instruction`!")
end


struct Cpy{T<:Value} <: Instruction
    from::T
    to::Register
end

function Base.parse(::Type{Cpy}, s::AbstractString)
    m = match(r"([^\s]+) (.+)", s)
    arg1, arg2 = parse.(Value, m.captures)
    return Cpy(arg1, arg2)
end


struct Inc <: Instruction
    register::Register
end

function Base.parse(::Type{Inc}, s::AbstractString)
    register = parse(Register, s)
    return Inc(register)
end


struct Dec <: Instruction
    register::Register
end

function Base.parse(::Type{Dec}, s::AbstractString)
    register = parse(Register, s)
    return Dec(register)
end


struct Jnz{T<:Value}
    check::T
    offset::Literal
end

function Base.parse(::Type{Jnz}, s::AbstractString)
    m = match(r"([^\s]+) (.+)", s)
    arg1, arg2 = parse.(Value, m.captures)
    return Jnz(arg1, arg2)
end


function ingest(path)
    return parse.(Instruction, readlines(path))
end
