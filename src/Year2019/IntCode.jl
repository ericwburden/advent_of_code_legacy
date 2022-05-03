module IntCode

export run!, execute!, Program

"""
An `AbstractState` indicates the state of the `Program`, whether it is 
running or halted. Used to sub-type `Program`.
"""
abstract type     AbstractState end
struct Running <: AbstractState end
struct Halted  <: AbstractState end

"""
A `Tape` is a layer of abstraction over an integer vector to make the
list of values stored in the `Program` 0-indexed as opposed to the normal
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
A `Program` encapsulates the full state of the program, the current pointer
value, and the 'tape' of integer values.
"""
mutable struct Program{S <: AbstractState}
    state::Type{S}
    pointer::Int
    tape::Tape
end

Program(values::Vector{Int}) = Program(Running, 0, Tape(values))

Base.getindex((; tape)::Program, idx::Int) = tape[idx]
Base.setindex!((; tape)::Program, v::Int, idx::Int)   = setindex!(tape, v, idx)

"""
    add!(program::Program)

Carry out an `add` instruction, based on the current pointer and list of
values in the program. If the pointer is moved off the tape, returns a
halted program, otherwise returns the modified, running program.
"""
function add!((; pointer, tape)::Program)
    input1, input2, output = @view tape[(pointer+1):(pointer+3)]
    tape[output] = tape[input1] + tape[input2]
    pointer += 4
    state    = pointer >= length(tape) ? Halted : Running
    return Program(state, pointer, tape)
end

"""
    mul!(program::Program)

Carry out a `mul` instruction, based on the current pointer and list of
values in the program. If the pointer is moved off the tape, returns a
halted program, otherwise returns the modified, running program.
"""
function mul!((; pointer, tape)::Program)
    input1, input2, output = @view tape[(pointer+1):(pointer+3)]
    tape[output] = tape[input1] * tape[input2]
    pointer += 4
    state    = pointer >= length(tape) ? Halted : Running
    return Program(state, pointer, tape)
end

"""
    exit!((; pointer, values)::Program)

Halts the program.
"""
function exit!((; pointer, tape)::Program)
    return Program(Halted, pointer, tape)
end

"""
    execute!(program::Program{Running})

Get the instruction at the current pointer location and run it, returning
a program that represents the state after running the next instruction.
"""
function execute!(program::Program{Running})
    (; pointer, tape) = program
    fn = tape[pointer]
    fn == 1  && return add!(program)
    fn == 2  && return mul!(program)
    fn == 99 && return exit!(program)
end

"Halted programs don't do anything..."
execute!(program::Program{Halted}) = program

"""
    run!(program::Program)

Execute instructions until the program halts
"""
function run!(program::Program)
    while program isa Program{Running}
        program = execute!(program)
    end
    return program
end
end
