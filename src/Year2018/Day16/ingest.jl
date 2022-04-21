"Handy type aliases"
const Registers   = NTuple{4,Int}
const Instruction = NTuple{4,Int}

"""
A `SampleOperation` represents the entries in the top part of the input
file, containing the before and after registers and the included
instruction as indicated. These instructions are 'un-identified', the
opcodes are still represented by integer values instead of by name.
"""
struct SampleOperation
    before::Registers
    after::Registers
    instruction::Instruction
end

"""
    parse(::Type{Instruction}, s::AbstractString)
    parse(::Type{Registers}, s::AbstractString)
    parse(::Type{SampleOperation}, s::AbstractString)

Parsing functions to convert a line (or chunk of lines) from the 
input into the relevant data types.
"""
function Base.parse(::Type{Instruction}, s::AbstractString)
    return NTuple{4}([parse(Int, n) for n in split(s)])
end

function Base.parse(::Type{Registers}, s::AbstractString)
    return NTuple{4}([parse(Int, m.match) for m in eachmatch(r"\d+", s)])
end

function Base.parse(::Type{SampleOperation}, s::AbstractString)
    strings     = split(s, "\n")
    before      = parse(Registers,   strings[1])
    instruction = parse(Instruction, strings[2])
    after       = parse(Registers,   strings[3])
    return SampleOperation(before, after, instruction)
end

"""
    ingest(path)

Given the path to the input file, parse the top section into a list of
`SampleOperation`s and the bottom section into a list of `Instruction`s.
Returns a tuple of (<sample operations>, <unidentified instructions>).
"""
function ingest(path)
    sample_operations = SampleOperation[]
    open(path) do f
        while !eof(f)
            chunk = readuntil(f, "\n\n")
            chunk == "" && break
            push!(sample_operations, parse(SampleOperation, chunk))
        end
        sample_program = parse.(Instruction, readlines(f))
        return (sample_operations, sample_program)
    end
end
