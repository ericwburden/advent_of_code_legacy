module IntCode

using DataStructures: Queue, enqueue!, dequeue!

export run!, execute!, add_input!, get_output!, Computer

"""
An `AbstractState` indicates the state of the `Computer`, whether it is 
running or halted. Used to sub-type `Computer`.
"""
abstract type     AbstractState end
struct Running <: AbstractState end
struct Halted  <: AbstractState end
struct Waiting <: AbstractState end

"""
A `Memory` is a layer of abstraction over an integer vector to make the
list of values stored in the `Computer` 0-indexed as opposed to the normal
Julia 1-indexing, useful to prevent confusion when referring to puzzle
instructions.
"""
struct Memory
    inner::Dict{BigInt,BigInt}
end

Base.getindex((; inner)::Memory, idx::Int)                = get(inner, idx + 1, 0)
Base.getindex((; inner)::Memory, idx::BigInt)             = get(inner, idx + 1, 0)
Base.setindex!((; inner)::Memory, v::Int,    idx::Int)    = setindex!(inner, v, idx + 1)
Base.setindex!((; inner)::Memory, v::Int,    idx::BigInt) = setindex!(inner, v, idx + 1)
Base.setindex!((; inner)::Memory, v::BigInt, idx::Int)    = setindex!(inner, v, idx + 1)
Base.setindex!((; inner)::Memory, v::BigInt, idx::BigInt) = setindex!(inner, v, idx + 1)
Base.length((; inner)::Memory) = length(inner)
Base.view((; inner)::Memory, idx::UnitRange{Int}) = view(inner, idx .+ 1)

"""
A `Computer` encapsulates the full state of the computer, the current pointer
value, and the 'memory' of integer values.
"""
mutable struct Computer{S <: AbstractState}
    state::Type{S}
    pointer::Int
    relative_base::Int
    memory::Memory
    input::Queue{BigInt}
    output::Queue{BigInt}
end

Computer(values::Vector{Int}) = Computer([BigInt(i) for i in values])

function Computer(values::Vector{BigInt})
    values = Dict(BigInt(i) => v for (i, v) in enumerate(values))
    Computer(Running, 0, 0, Memory(values), Queue{BigInt}(), Queue{BigInt}())
end

"""
    add_input!(computer::Computer, value::BigInt)

Add an input value to the `Computer`'s input. Currently only supports writing
to a Queue for input, can be extended to support other inputs later if needed.
"""
function add_input!((; input)::Computer, value::BigInt)
    enqueue!(input, value)
end
function add_input!((; input)::Computer, value::Int)
    enqueue!(input, BigInt(value))
end

"""
    get_output!((; output)::Computer) -> BigInt

Retrieve an output value from the `Computer`'s output. Currently only supports
reading from a `Queue` for output, can be extended to support other outputs
later if needed.
"""
function get_output!((; output)::Computer)
    return dequeue!(output)
end

current_address((; pointer, memory)::Computer) = memory[pointer]
Base.setindex!((; memory)::Computer, v::Int,    idx::Int)    = setindex!(memory, v, idx)
Base.setindex!((; memory)::Computer, v::Int,    idx::BigInt) = setindex!(memory, v, idx)
Base.setindex!((; memory)::Computer, v::BigInt, idx::Int)    = setindex!(memory, v, idx)
Base.setindex!((; memory)::Computer, v::BigInt, idx::BigInt) = setindex!(memory, v, idx)
Base.getindex((; memory)::Computer, idx::Int)    = memory[idx]
Base.getindex((; memory)::Computer, idx::BigInt) = memory[idx]

"""
An `AbstractMode` represents the mode with which a parameter should be
handled. 
"""
abstract type       AbstractMode end
struct Position  <: AbstractMode end
struct Immediate <: AbstractMode end
struct Relative  <: AbstractMode end

"Dispatch for different subtypes of `AbstractMode`"
function AbstractMode(int::Int)
    int == 0 && return Position()
    int == 1 && return Immediate()
    int == 2 && return Relative()
    error("'$int' is not a valid mode value!")
end

"""
A `Modes` represents an indexable listing of modes for the various parameters
referenced by an instruction. All positive integer indices default to a
`Position` if not otherwise indicated.
"""
struct Modes{N}
    modes::NTuple{N,AbstractMode}
end

# This default constructor with an empty Tuple will return a `Position` mode
# for any index fetched.
Modes() = Modes(())

# This constructor takes the parameter-specifying integer and returns a
# `Modes` specifying the modes from the parameter integer.
function Modes(value::BigInt)
    modes = Tuple(AbstractMode(d) for d in digits(value))
    return Modes(modes)
end

"""
    getindex((; modes)::Modes, idx::Int) -> AbstractMode
    
Fetch an `AbstractMode` from `Modes`, defaulting to a `Position` 
unless the index is explicitly specified.
"""
function Base.getindex((; modes)::Modes, idx::Int)
    0 < idx <= length(modes) || return Position()
    return modes[idx]
end

"""
A `Parameter` wraps a given parameter (integer) from the IntCode, specifying
the mode to be used to access the value of the parameter.

A `Position` mode indicates that the value should be taken from the corresponding
index in the `Computer` memory. An `Immediate` mode indicates that the value is the
parameter itself.
"""
struct Parameter{M <: AbstractMode}
    mode::M
    value::BigInt
end

Base.getindex((; memory)::Computer, (; value)::Parameter{Position})  = memory[value]
Base.getindex((; memory)::Computer, (; value)::Parameter{Immediate}) = value

Base.getindex(
    (; memory, relative_base)::Computer, 
    (; value)::Parameter{Relative}
) = memory[value + relative_base]

Base.setindex!(
    (; memory, relative_base)::Computer, 
    v,
    (; value)::Parameter{Relative}
) = setindex!(memory, v, value + relative_base)
Base.setindex!(
    (; memory)::Computer, 
    v,
    (; value)::Parameter{Position}
) = setindex!(memory, v, value)


"""
    add!(computer::Computer) -> Int

Carry out an `add` instruction, based on the current pointer and list of
values in the computer. Returns the position of the pointer after the
instruction has been completed.
"""
function add!(computer::Computer, modes::Modes)
    (; pointer) = computer
    param1 = Parameter(modes[1], computer[pointer+1])
    param2 = Parameter(modes[2], computer[pointer+2])
    param3 = Parameter(modes[3], computer[pointer+3])
    computer[param3] = computer[param1] + computer[param2]
    computer.pointer += 4
    return computer
end

"""
    mul!(computer::Computer) -> Int

Carry out a `mul` instruction, based on the current pointer and list of
values in the computer. Returns the position of the pointer after the
instruction has been completed.
"""
function mul!(computer::Computer, modes::Modes)
    (; pointer) = computer
    param1 = Parameter(modes[1], computer[pointer+1])
    param2 = Parameter(modes[2], computer[pointer+2])
    param3 = Parameter(modes[3], computer[pointer+3])
    computer[param3] = computer[param1] * computer[param2]
    computer.pointer += 4
    return computer
end

"""
    input!(computer::Computer) -> Int

Carry out an `input` instruction, reading input from the `Computer`'s current
input and storing it in the indicated memory position. Returns the position
of the pointer after the instruction has been completed.
"""
function input!(computer::Computer, modes::Modes)
    (; pointer, relative_base, memory, input, output) = computer
    isempty(input) && return Computer(Waiting, pointer, relative_base, memory, input, output)
    value  = dequeue!(input)
    param = Parameter(modes[1], computer[pointer+1])
    computer[param] = value
    return Computer(Running, pointer + 2, relative_base, memory, input, output)
end

"""
    output!(computer::Computer) -> Int

Carry out an `output` instruction, writing the indicated value to the 
`Computer`'s current output. Returns the position of the pointer after
the instruction has been completed.
"""
function output!(computer::Computer, modes::Modes)
    (; pointer, output) = computer
    param = Parameter(modes[1], computer[pointer+1])
    enqueue!(output, computer[param])
    computer.pointer += 2
    return computer
end

"""
    jit!(computer::Computer, modes::Modes) -> Int

Carry out a `jump-if-true` instruction. If the first parameter is non-zero,
it return a pointer position according to the second parameter, otherwise
returns the position of the next instruction.
"""
function jit!(computer::Computer, modes::Modes)
    (; pointer) = computer
    param1 = Parameter(modes[1], computer[pointer+1])
    param2 = Parameter(modes[2], computer[pointer+2])
    computer.pointer = computer[param1] == 0 ? pointer + 3 : computer[param2]
    return computer
end

"""
    jif!(computer::Computer, modes::Modes) -> Int

Carry out a `jump-if-false` instruction. If the first parameter is zero,
it return a pointer position according to the second parameter, otherwise
returns the position of the next instruction.
"""
function jif!(computer::Computer, modes::Modes)
    (; pointer) = computer
    param1 = Parameter(modes[1], computer[pointer+1])
    param2 = Parameter(modes[2], computer[pointer+2])
    computer.pointer = computer[param1] == 0 ? computer[param2] : pointer + 3
    return computer
end

"""
    lt!(computer::Computer, modes::Modes) -> Int

Carry out a `less-than` instruction. If the first parameter is less than the
second parameter, set the memory address referenced by the third parameter
to `1`, otherwise set it to `0`. Returns the position of the next instruction.
"""
function lt!(computer::Computer, modes::Modes)
    (; pointer) = computer
    param1 = Parameter(modes[1], computer[pointer+1])
    param2 = Parameter(modes[2], computer[pointer+2])
    param3 = Parameter(modes[3], computer[pointer+3])
    computer[param3] = computer[param1] < computer[param2] ? 1 : 0
    computer.pointer += 4
    return computer
end

"""
    eq!(computer::Computer, modes::Modes) -> Int

Carry out an `equal-to` instruction. If the first parameter is equal to the
second parameter, set the memory address referenced by the third parameter
to `1`, otherwise set it to `0`. Returns the position of the next instruction.
"""
function eq!(computer::Computer, modes::Modes)
    (; pointer) = computer
    param1 = Parameter(modes[1], computer[pointer+1])
    param2 = Parameter(modes[2], computer[pointer+2])
    param3 = Parameter(modes[3], computer[pointer+3])
    computer[param3] = computer[param1] == computer[param2] ? 1 : 0
    computer.pointer += 4
    return computer
end

function rebase!(computer::Computer, modes::Modes)
    (; pointer) = computer
    param1 = Parameter(modes[1], computer[pointer+1])
    computer.relative_base += computer[param1]
    computer.pointer += 2
    return computer
end

"""
    halt!(computer::Computer) -> Computer

Halts the computer.
"""
function halt!(computer::Computer)
    (; pointer, relative_base, memory, input, output) = computer
    return Computer(Halted, pointer, relative_base, memory, input, output)
end

"""
    execute!(computer::Computer{Running}) -> Computer

Get the instruction at the current pointer location and run it, returning
a computer that represents the state after running the next instruction.
"""
function execute!(computer::Computer)
    modes, opcode = divrem(current_address(computer), 100)

    # Dispatch based on opcode
    opcode == 1  && return    add!(computer, Modes(modes))
    opcode == 2  && return    mul!(computer, Modes(modes))
    opcode == 3  && return  input!(computer, Modes(modes))
    opcode == 4  && return output!(computer, Modes(modes))
    opcode == 5  && return    jit!(computer, Modes(modes))
    opcode == 6  && return    jif!(computer, Modes(modes))
    opcode == 7  && return     lt!(computer, Modes(modes))
    opcode == 8  && return     eq!(computer, Modes(modes))
    opcode == 9  && return rebase!(computer, Modes(modes))
    opcode == 99 && return   halt!(computer)
    error("'$opcode' is not a valid opcode!")
end

"Halted computers don't do anything..."
execute!(computer::Computer{Halted}) = computer

"""
    run!(computer::Computer) -> Computer

Execute instructions until the computer halts
"""
function run!(computer::Computer)
    computer = execute!(computer)
    while computer isa Computer{Running}
        computer = execute!(computer)
    end
    return computer
end

end
