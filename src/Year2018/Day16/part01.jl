"""
The `AbstractInstructionKind` is the supertype for a set of types
that can represent the 'kind' of operation supported by a particular
`Instruction`. There's one sub-type per kind of supported instruction.
These types are used to sub-type the `CodedInstruction` to support
function dispatch based on particular instructions.
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

"List of all `AbstractInstructionKind` types"
const INSTRUCTION_KINDS = NTuple{16}([
    ADDR, ADDI, MULR, MULI,
    BANR, BANI, BORR, BORI,
    SETR, SETI, GTIR, GTRI,
    GTRR, EQIR, EQRI, EQRR
])

"""
A `CodedInstruction` is an instruction that has been identified (or
assigned) a particular kind, such that it can be executed.
"""
struct CodedInstruction{K <: AbstractInstructionKind}
    kind::Type{K}
    opcode::Int
    input1::Int
    input2::Int
    output::Int
end

function CodedInstruction(kind::Type{K}, i::Instruction) where K <: AbstractInstructionKind
    opcode, input1, input2, output = i
    return CodedInstruction(kind, opcode, input1, input2, output)
end

"Sets a value at an index in a `Registers`"
function set_register(r::Registers, i::Int, v::Int)
    # Not to self: NO ALLOCATIONS!!!
    return NTuple{4}(idx - 1 == i ? v : val for (idx, val) in enumerate(r))
end

"Get a value at an index in a `Registers`"
function get_value(r::Registers, i::Int)
    return r[i + 1]
end


"""
Each `execute` takes a `CodedInstruction` and a set of `Registers` and produces
a new set of `Registers` with the instruction applied.

Addition:

- addr (add register) stores into register C the result of adding register A
  and register B.
- addi (add immediate) stores into register C the result of adding register
  A and value B.
"""
function execute((; input1, input2, output)::CodedInstruction{ADDR}, r::Registers)
    a = get_value(r, input1)
    b = get_value(r, input2)
    return set_register(r, output, a + b)
end

function execute((; input1, input2, output)::CodedInstruction{ADDI}, r::Registers)
    a = get_value(r, input1)
    b = input2
    return set_register(r, output, a + b)
end

"""
Multiplication:

- mulr (multiply register) stores into register C the result of multiplying
  register A and register B.
- muli (multiply immediate) stores into register C the result of multiplying
  register A and value B.
"""
function execute((; input1, input2, output)::CodedInstruction{MULR}, r::Registers)
    a = get_value(r, input1)
    b = get_value(r, input2)
    return set_register(r, output, a * b)
end

function execute((; input1, input2, output)::CodedInstruction{MULI}, r::Registers)
    a = get_value(r, input1)
    b = input2
    return set_register(r, output, a * b)
end

"""
Bitwise AND:

- banr (bitwise AND register) stores into register C the result of the
  bitwise AND of register A and register B.
- bani (bitwise AND immediate) stores into register C the result of the
  bitwise AND of register A and value B.
"""
function execute((; input1, input2, output)::CodedInstruction{BANR}, r::Registers)
    a = get_value(r, input1)
    b = get_value(r, input2)
    return set_register(r, output, a & b)
end

function execute((; input1, input2, output)::CodedInstruction{BANI}, r::Registers)
    a = get_value(r, input1)
    b = input2
    return set_register(r, output, a & b)
end

"""
Bitwise OR:

- borr (bitwise OR register) stores into register C the result of the
  bitwise OR of register A and register B.
- bori (bitwise OR immediate) stores into register C the result of the
  bitwise OR of register A and value B.
"""
function execute((; input1, input2, output)::CodedInstruction{BORR}, r::Registers)
    a = get_value(r, input1)
    b = get_value(r, input2)
    return set_register(r, output, a | b)
end

function execute((; input1, input2, output)::CodedInstruction{BORI}, r::Registers)
    a = get_value(r, input1)
    b = input2
    return set_register(r, output, a | b)
end

"""
Assignment:

- setr (set register) copies the contents of register A into register C.
  (Input B is ignored.)
- seti (set immediate) stores value A into register C. (Input B is ignored.)
"""
function execute((; input1, output)::CodedInstruction{SETR}, r::Registers)
    a = get_value(r, input1)
    return set_register(r, output, a)
end

function execute((; input1, output)::CodedInstruction{SETI}, r::Registers)
    a = input1
    return set_register(r, output, a)
end

"""
Greater-than testing:

- gtir (greater-than immediate/register) sets register C to 1 if value A is
  greater than register B. Otherwise, register C is set to 0.
- gtri (greater-than register/immediate) sets register C to 1 if register A
  is greater than value B. Otherwise, register C is set to 0.
- gtrr (greater-than register/register) sets register C to 1 if register A
  is greater than register B. Otherwise, register C is set to 0.
"""
function execute((; input1, input2, output)::CodedInstruction{GTIR}, r::Registers)
    a = input1
    b = get_value(r, input2)
    return set_register(r, output, a > b ? 1 : 0)
end

function execute((; input1, input2, output)::CodedInstruction{GTRI}, r::Registers)
    a = get_value(r, input1)
    b = input2
    return set_register(r, output, a > b ? 1 : 0)
end

function execute((; input1, input2, output)::CodedInstruction{GTRR}, r::Registers)
    a = get_value(r, input1)
    b = get_value(r, input2)
    return set_register(r, output, a > b ? 1 : 0)
end

"""
Equality testing:

- eqir (equal immediate/register) sets register C to 1 if value A is equal
  to register B. Otherwise, register C is set to 0.
- eqri (equal register/immediate) sets register C to 1 if register A is equal
  to value B. Otherwise, register C is set to 0.
- eqrr (equal register/register) sets register C to 1 if register A is equal
  to register B. Otherwise, register C is set to 0.
"""
function execute((; input1, input2, output)::CodedInstruction{EQIR}, r::Registers)
    a = input1
    b = get_value(r, input2)
    return set_register(r, output, a == b ? 1 : 0)
end

function execute((; input1, input2, output)::CodedInstruction{EQRI}, r::Registers)
    a = get_value(r, input1)
    b = input2
    return set_register(r, output, a == b ? 1 : 0)
end

function execute((; input1, input2, output)::CodedInstruction{EQRR}, r::Registers)
    a = get_value(r, input1)
    b = get_value(r, input2)
    return set_register(r, output, a == b ? 1 : 0)
end


"""
    possible_instruction_kinds(operation::SampleOperation)

Given a `SampleOperation`, identify every `AbstractInstructionKind` that,
if the embedded instruction were of that type, would produce the set of
`after` registers from the `before` registers when the instruction was
applied.
"""
function possible_instruction_kinds((; before, after, instruction)::SampleOperation)
    possible_kinds = Set{AnyAbstractInstructionKind}()
    for kind in INSTRUCTION_KINDS
        coded_instruction = CodedInstruction(kind, instruction)
        result = execute(coded_instruction, before)
        after == result && push!(possible_kinds, kind)
    end
    return possible_kinds
end




function part1(input)
    sample_operations, _ = input
    three_or_more(op) = (length ∘ possible_instruction_kinds)(op) >= 3
    return mapreduce(three_or_more, +, sample_operations)
end
