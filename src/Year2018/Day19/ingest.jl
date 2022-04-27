"""
The `AbstractInstructionKind` is the supertype for a set of types
that can represent the 'kind' of operation supported by a particular
`Instruction`. There's one sub-type per kind of supported instruction.
"""
abstract type AbstractInstructionKind end

struct ADDR <: AbstractInstructionKind end
struct ADDI <: AbstractInstructionKind end
struct MULR <: AbstractInstructionKind end
struct MULI <: AbstractInstructionKind end
struct BANR <: AbstractInstructionKind end
struct BANI <: AbstractInstructionKind end
struct BORR <: AbstractInstructionKind end
struct BORI <: AbstractInstructionKind end
struct SETR <: AbstractInstructionKind end
struct SETI <: AbstractInstructionKind end
struct GTIR <: AbstractInstructionKind end
struct GTRI <: AbstractInstructionKind end
struct GTRR <: AbstractInstructionKind end
struct EQIR <: AbstractInstructionKind end
struct EQRI <: AbstractInstructionKind end
struct EQRR <: AbstractInstructionKind end

"Type union of all `AbstractInstructionKind` types."
const AnyAbstractInstructionKind = Union{
    Type{ADDR}, Type{ADDI}, Type{MULR}, Type{MULI},
    Type{BANR}, Type{BANI}, Type{BORR}, Type{BORI},
    Type{SETR}, Type{SETI}, Type{GTIR}, Type{GTRI},
    Type{GTRR}, Type{EQIR}, Type{EQRI}, Type{EQRR}
}

"""
An `Instruction` represents an instruction in the program.
"""
struct Instruction{K <: AbstractInstructionKind}
    kind::Type{K}
    input1::Int  
    input2::Int  
    output::Int
end

function Base.parse(::Type{Instruction}, s::AbstractString)
    m = match(r"(\w{4}) (\d+) (\d+) (\d+)", s)
    kind, input1, input2, output = m.captures
    input1, input2, output = parse.(Int, [input1, input2, output])
    kind == "addr" && return Instruction(ADDR, input1, input2, output)
    kind == "addi" && return Instruction(ADDI, input1, input2, output)
    kind == "mulr" && return Instruction(MULR, input1, input2, output)
    kind == "muli" && return Instruction(MULI, input1, input2, output)
    kind == "banr" && return Instruction(BANR, input1, input2, output)
    kind == "bani" && return Instruction(BANI, input1, input2, output)
    kind == "borr" && return Instruction(BORR, input1, input2, output)
    kind == "bori" && return Instruction(BORI, input1, input2, output)
    kind == "setr" && return Instruction(SETR, input1, input2, output)
    kind == "seti" && return Instruction(SETI, input1, input2, output)
    kind == "gtir" && return Instruction(GTIR, input1, input2, output)
    kind == "gtri" && return Instruction(GTRI, input1, input2, output)
    kind == "gtrr" && return Instruction(GTRR, input1, input2, output)
    kind == "eqir" && return Instruction(EQIR, input1, input2, output)
    kind == "eqri" && return Instruction(EQRI, input1, input2, output)
    kind == "eqrr" && return Instruction(EQRR, input1, input2, output)
    error("'$kind' is not a valid kind of instruction!")
end

"Handy type aliases"
const Registers    = NTuple{6,Int}
const Instructions = Vector{Instruction}

"""
An `AbstractProgramState` indicates the state of the `Program`, whether
it is running or halted. Implemented as a type in order to sub-type
`Program` for type-checking.
"""
abstract type AbstractProgramState end
struct Running <: AbstractProgramState end
struct Halted  <: AbstractProgramState end

"""
A `Program` encapsulates the state of the running program, including the 
current pointer, the register the pointer is bound to, and the collected
register values.
"""
struct Program{S <: AbstractProgramState}
    state::Type{S}
    pointer::Int
    bind::Int
    registers::Registers
end

"""
    ingest(path)

Given the path to the input file, read the first line and parse the 
binding for the program pointer, then parse the rest of the lines into
`Instructions`. Package them into a running `Program` and return it.
"""
ingest(path) = open(path) do f
    _, bind      = (split ∘ readline)(f)
    bind         = parse(Int, bind)
    registers    = (0, 0, 0, 0, 0, 0)
    instructions = parse.(Instruction, readlines(f))
    (Program(Running, 0, bind, registers), instructions)
end

