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

"""
A `Tape` is a layer of abstraction over an integer vector to make the
list of values stored in the `Computer` 0-indexed as opposed to the normal
Julia 1-indexing, useful to prevent confusion when referring to puzzle
instructions.
"""
struct Tape
    inner::Vector{Int}
end

Base.getindex((; inner)::Tape, idx::Int)            = inner[idx + 1]
Base.getindex((; inner)::Tape, idx::UnitRange{Int}) = inner[idx .+ 1]
Base.setindex!((; inner)::Tape, v::Int, idx::Int)   = setindex!(inner, v, idx + 1)
Base.length((; inner)::Tape) = length(inner)
Base.view((; inner)::Tape, idx::UnitRange{Int}) = view(inner, idx .+ 1)

"""
A `Computer` encapsulates the full state of the computer, the current pointer
value, and the 'tape' of integer values.
"""
mutable struct Computer{S <: AbstractState}
    state::Type{S}
    pointer::Int
    tape::Tape
    input::Queue{Int}
    output::Queue{Int}
end

Computer(values::Vector{Int}) = Computer(Running, 0, Tape(values), Queue{Int}(), Queue{Int}())

"""
    add_input!(computer::Computer, value::Int)

Add an input value to the `Computer`'s input. Currently only supports writing
to a Queue for input, can be extended to support other inputs later if needed.
"""
function add_input!((; input)::Computer, value::Int)
    enqueue!(input, value)
end

"""
    get_output!((; output)::Computer)

Retrieve an output value from the `Computer`'s output. Currently only supports
reading from a `Queue` for output, can be extended to support other outputs
later if needed.
"""
function get_output!((; output)::Computer)
    return dequeue!(output)
end

Base.setindex!((; tape)::Computer, v::Int, idx::Int) = setindex!(tape, v, idx)
Base.getindex((; tape)::Computer, idx::Int) = tape[idx]

"""
An `AbstractMode` represents the mode with which a parameter should be
handled. 
"""
abstract type       AbstractMode end
struct Position  <: AbstractMode end
struct Immediate <: AbstractMode end

"Dispatch for different subtypes of `AbstractMode`"
function AbstractMode(int::Int)
    int == 0 && return Position()
    int == 1 && return Immediate()
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
function Modes(value::Int)
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
index in the `Computer` tape. An `Immediate` mode indicates that the value is the
parameter itself.
"""
struct Parameter{M <: AbstractMode}
    mode::M
    value::Int
end

Base.getindex((; inner)::Tape, (; value)::Parameter{Position})     = inner[value + 1]
Base.getindex((; tape)::Computer, (; value)::Parameter{Position})  = tape[value]
Base.getindex((; inner)::Tape, (; value)::Parameter{Immediate})    = value
Base.getindex((; tape)::Computer, (; value)::Parameter{Immediate}) = value


"""
    add!(computer::Computer) -> Int

Carry out an `add` instruction, based on the current pointer and list of
values in the computer. Returns the position of the pointer after the
instruction has been completed.
"""
function add!((; pointer, tape)::Computer, modes::Modes)
    input1 = Parameter(modes[1], tape[pointer+1])
    input2 = Parameter(modes[2], tape[pointer+2])
    output = tape[pointer+3]
    tape[output] = tape[input1] + tape[input2]
    return pointer + 4
end

"""
    mul!(computer::Computer) -> Int

Carry out a `mul` instruction, based on the current pointer and list of
values in the computer. Returns the position of the pointer after the
instruction has been completed.
"""
function mul!((; pointer, tape)::Computer, modes::Modes)
    input1 = Parameter(modes[1], tape[pointer+1])
    input2 = Parameter(modes[2], tape[pointer+2])
    output = tape[pointer+3]
    tape[output] = tape[input1] * tape[input2]
    return pointer + 4
end

"""
    input!(computer::Computer) -> Int

Carry out an `input` instruction, reading input from the `Computer`'s current
input and storing it in the indicated memory position. Returns the position
of the pointer after the instruction has been completed.
"""
function input!((; pointer, tape, input)::Computer)
    input  = dequeue!(input)
    output = tape[pointer+1]
    tape[output] = input
    return pointer + 2
end

"""
    output!(computer::Computer) -> Int

Carry out an `output` instruction, writing the indicated value to the 
`Computer`'s current output. Returns the position of the pointer after
the instruction has been completed.
"""
function output!((; pointer, tape, output)::Computer, modes::Modes)
    input = Parameter(modes[1], tape[pointer+1])
    enqueue!(output, tape[input])
    return pointer + 2
end

"""
    jit!(computer::Computer, modes::Modes) -> Int

Carry out a `jump-if-true` instruction. If the first parameter is non-zero,
it return a pointer position according to the second parameter, otherwise
returns the position of the next instruction.
"""
function jit!((; pointer, tape)::Computer, modes::Modes)
    input1 = Parameter(modes[1], tape[pointer+1])
    input2 = Parameter(modes[2], tape[pointer+2])
    tape[input1] == 0 || return tape[input2]
    return pointer + 3
end

"""
    jif!(computer::Computer, modes::Modes) -> Int

Carry out a `jump-if-false` instruction. If the first parameter is zero,
it return a pointer position according to the second parameter, otherwise
returns the position of the next instruction.
"""
function jif!((; pointer, tape)::Computer, modes::Modes)
    input1 = Parameter(modes[1], tape[pointer+1])
    input2 = Parameter(modes[2], tape[pointer+2])
    tape[input1] == 0 && return tape[input2]
    return pointer + 3
end

"""
    lt!(computer::Computer, modes::Modes) -> Int

Carry out a `less-than` instruction. If the first parameter is less than the
second parameter, set the memory address referenced by the third parameter
to `1`, otherwise set it to `0`. Returns the position of the next instruction.
"""
function lt!((; pointer, tape)::Computer, modes::Modes)
    input1 = Parameter(modes[1], tape[pointer+1])
    input2 = Parameter(modes[2], tape[pointer+2])
    output = tape[pointer+3]
    tape[output] = tape[input1] < tape[input2] ? 1 : 0
    return pointer + 4
end

"""
    eq!(computer::Computer, modes::Modes) -> Int

Carry out an `equal-to` instruction. If the first parameter is equal to the
second parameter, set the memory address referenced by the third parameter
to `1`, otherwise set it to `0`. Returns the position of the next instruction.
"""
function eq!((; pointer, tape)::Computer, modes::Modes)
    input1 = Parameter(modes[1], tape[pointer+1])
    input2 = Parameter(modes[2], tape[pointer+2])
    output = tape[pointer+3]
    tape[output] = tape[input1] == tape[input2] ? 1 : 0
    return pointer + 4
end

"""
    exit!(computer::Computer) -> Computer

Halts the computer.
"""
function exit!((; pointer, tape, input, output)::Computer)
    return Computer(Halted, pointer, tape, input, output)
end

"""
    execute!(computer::Computer{Running}) -> Computer

Get the instruction at the current pointer location and run it, returning
a computer that represents the state after running the next instruction.
"""
function execute!(computer::Computer{Running})
    (; state, pointer, tape, input, output) = computer
    modes, opcode = divrem(tape[pointer], 100)

    # Dispatch based on opcode
    opcode == 1  && (pointer =    add!(computer, Modes(modes)))
    opcode == 2  && (pointer =    mul!(computer, Modes(modes)))
    opcode == 3  && (pointer =  input!(computer))
    opcode == 4  && (pointer = output!(computer, Modes(modes)))
    opcode == 5  && (pointer =    jit!(computer, Modes(modes)))
    opcode == 6  && (pointer =    jif!(computer, Modes(modes)))
    opcode == 7  && (pointer =     lt!(computer, Modes(modes)))
    opcode == 8  && (pointer =     eq!(computer, Modes(modes)))
    opcode == 99 && return exit!(computer)

    # Halt the computer if the pointer is aimed outside the 
    # available memory space. Otherwise, keep running.
    0 < pointer <= length(tape) || (state = Halted)
    return Computer(state, pointer, tape, input, output)
end

"Halted computers don't do anything..."
execute!(computer::Computer{Halted}) = computer

"""
    run!(computer::Computer) -> Computer

Execute instructions until the computer halts
"""
function run!(computer::Computer)
    while computer isa Computer{Running}
        computer = execute!(computer)
    end
    return computer
end

end
