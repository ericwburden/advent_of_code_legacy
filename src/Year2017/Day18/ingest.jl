"""
`AbstractValue`s consist of `Static` and `Register` values. A `Static` value
is just a simple wrapper around an `Int`, whereas a `Register` wraps a `Char`
which is the name of a register in use by the program being run. Using
`AbstractValue`s in this way abstracts over the need to differentiate between
instruction arguments that reference a register vs those that contain 
static values.
"""
abstract type AbstractValue end

struct Static   <: AbstractValue value::Int end
struct Register <: AbstractValue register::Char end

Base.parse(::Type{AbstractValue}, s::Nothing) = nothing
function Base.parse(::Type{AbstractValue}, s::AbstractString)
    maybe_value = tryparse(Int, s)
    if isnothing(maybe_value)
        register = first(s)
        return Register(register)
    else
        return Static(maybe_value)
    end
end


"""
`AbstractInstruction`s are the possible instructions that may be executed in
the simulated program, specialized for each type of instruction with the
values needed to carry out the instruction. All values in an 
`AbstractInstruction` are represented as `AbstractValue`s. Having a separate
type for each instruction allows for dispatching execution based on type.
"""
abstract type AbstractInstruction end

struct Sound   <: AbstractInstruction  freq::AbstractValue  end
struct Set     <: AbstractInstruction  left::AbstractValue; right::AbstractValue end
struct Add     <: AbstractInstruction  left::AbstractValue; right::AbstractValue end
struct Mul     <: AbstractInstruction  left::AbstractValue; right::AbstractValue end
struct Mod     <: AbstractInstruction  left::AbstractValue; right::AbstractValue end
struct Recover <: AbstractInstruction input::AbstractValue  end
struct Jgz     <: AbstractInstruction input::AbstractValue;  jump::AbstractValue end

function Base.parse(::Type{AbstractInstruction}, s::AbstractString)
    m = match(r"(?<instr>\w{3}) (?<first>-?[\w\d]+) ?(?<second>-?[\w\d]+)?", s)
    instr  = m["instr"]
    first  = parse(AbstractValue, m["first"])
    second = parse(AbstractValue, m["second"])

    instr == "snd" && return Sound(first)
    instr == "set" && return Set(first, second)
    instr == "add" && return Add(first, second)
    instr == "mul" && return Mul(first, second)
    instr == "mod" && return Mod(first, second)
    instr == "rcv" && return Recover(first)
    instr == "jgz" && return Jgz(first, second)
    error("Cannot parse \"$s\" to an `AbstractInstruction`")
end

const Instructions = Vector{AbstractInstruction}

"Read each line from the input file, parse into an instruction, and return the list"
ingest(path) = [parse(AbstractInstruction, s) for s in readlines(path)]
