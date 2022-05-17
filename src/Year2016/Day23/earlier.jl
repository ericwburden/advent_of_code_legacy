#=------------------------------------------------------------------------------
| Today's puzzle relies on parsing and execution logic developed in Day 12's
| puzzle. Instead of trying to reference those files directly, I've opted to 
| keep each day relatively self-contained and have copied over the relevant
| bits to this file.
------------------------------------------------------------------------------=#


#=------------------------------------------------------------------------------
| This section relates to the data structures used to represent instructions.
------------------------------------------------------------------------------=#

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


# This one was modified to support either a `Literal` or `Register` in both
# `check` and `offset`.
struct Jnz{T<:Value,U<:Value} <: Instruction
    check::T
    offset::U
end

function Base.parse(::Type{Jnz}, s::AbstractString)
    m = match(r"([^\s]+) (.+)", s)
    arg1, arg2 = parse.(Value, m.captures)
    return Jnz(arg1, arg2)
end


#=------------------------------------------------------------------------------
| This section relates to the data structures and functions used to keep track
| of register values and execution of instructions.
------------------------------------------------------------------------------=#

struct Registers
    inner::Dict{Register,Literal}
end

function Registers(pairs::Pair{Char,Int}...)
    registers = Dict{Register,Literal}()
    for (r, v) in pairs
        registers[Register(r)] = Literal(v)
    end
    return Registers(registers)
end

eval(::Registers, lit::Literal) = lit
eval(r::Registers, key::Register) = eval(r, r[key])

mutable struct Program
    pointer::Int
    registers::Registers
    code::Vector{Instruction}
end

Base.getindex((; inner)::Registers, r::Register) = getindex(inner, r)
Base.getindex((; inner)::Registers, c::Char) = getindex(inner, Register(c))
Base.setindex!((; inner)::Registers, l::Literal, r::Register) = Base.setindex!(inner, l, r)
Base.:+((; value)::Literal, b::Int) = Literal(value + b)
Base.:+((; value)::Literal, b::Literal) = Literal(value + b.value)
Base.:-((; value)::Literal, b::Int) = Literal(value - b)
Base.:+(a::Int, (; value)::Literal) = a + value
Base.:*(a::Literal, b::Literal) = Literal(a.value * b.value)


# Execution functions needed to be slightly modified to accommodate toggling, 
# additionally taking and returning the pointer to the line to be run, as
# opposed to returning a value indicating the offset to the next line.

function execute!(program::Program, (; from, to)::Cpy)
    program.registers[to] = eval(program.registers, from)
    program.pointer += 1
end

function execute!(program::Program, (; register)::Inc)
    program.registers[register] += 1
    program.pointer += 1
end

function execute!(program::Program, (; register)::Dec)
    program.registers[register] -= 1
    program.pointer += 1
end

function execute!(program::Program, (; check, offset)::Jnz)
    if eval(program.registers, check) == Literal(0)
        program.pointer += 1
    else
        program.pointer += eval(program.registers, offset)
    end
end
