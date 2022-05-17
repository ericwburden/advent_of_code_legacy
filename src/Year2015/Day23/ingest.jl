using Match

#=------------------------------------------------------------------------------
| For today's puzzle, we're simulating a simple computer's instruction set
------------------------------------------------------------------------------=#

"""
    AbstractInstruction
    Half(register::Char)
    Triple(register::Char)
    Increment(register::Char)
    Jump(offset::Int)
    JumpIfEven(register::Char, offset::Int)
    JumpIfOne(register::Char, offset::Int)

Structs to represent each type of instruction for the virtual computer. All are
sub-types of `AbstractInstruction`.
"""
abstract type AbstractInstruction end

struct Half <: AbstractInstruction
    register::Char
end
struct Triple <: AbstractInstruction
    register::Char
end
struct Increment <: AbstractInstruction
    register::Char
end
struct Jump <: AbstractInstruction
    offset::Int
end
struct JumpIfEven <: AbstractInstruction
    register::Char
    offset::Int
end
struct JumpIfOne <: AbstractInstruction
    register::Char
    offset::Int
end

# For parsing instructions
const INSTRUCTION_RE = r"(?<ins>^\w{3}) (?<reg>a|b)?(?>, )?(?<off>[-+]?\d+)?"

"""
    parse(::Type{AbstractInstruction}, s::String)

Parse one of the AbstractInstruction types from a string, depending on how
it matches the INSTRUCTION_RE.
"""
function Base.parse(::Type{AbstractInstruction}, s::String)
    m = match(INSTRUCTION_RE, s)
    (instruction, register, offset) = m.captures
    offset = isnothing(offset) ? nothing : parse(Int, offset)
    @match instruction begin
        "hlf" => Half(register[1])
        "tpl" => Triple(register[1])
        "inc" => Increment(register[1])
        "jmp" => Jump(offset)
        "jie" => JumpIfEven(register[1], offset)
        "jio" => JumpIfOne(register[1], offset)
    end
end

"""
    ingest(path)

Given a path to the input file, parse each line into an `AbstractInstruction`
and return the resulting vector of instructions.
"""
function ingest(path)
    parse_instruction(s) = parse(AbstractInstruction, s)
    open(path) do f
        map(parse_instruction, eachline(f))
    end
end
