module IntCode

export run!, execute!, Computer

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
A `Computer` encapsulates the full state of the program, the current pointer
value, and the 'tape' of integer values.
"""
mutable struct Computer{S <: AbstractState}
    state::Type{S}
    pointer::Int
    tape::Tape
end

Computer(values::Vector{Int}) = Computer(Running, 0, Tape(values))

Base.getindex((; tape)::Computer, idx::Int) = tape[idx]
Base.setindex!((; tape)::Computer, v::Int, idx::Int)   = setindex!(tape, v, idx)

"""
    add!(program::Computer)

Carry out an `add` instruction, based on the current pointer and list of
values in the program. If the pointer is moved off the tape, returns a
halted program, otherwise returns the modified, running program.
"""
function add!((; pointer, tape)::Computer)
    input1, input2, output = @view tape[(pointer+1):(pointer+3)]
    tape[output] = tape[input1] + tape[input2]
    pointer += 4
    state    = pointer >= length(tape) ? Halted : Running
    return Computer(state, pointer, tape)
end

"""
    mul!(program::Computer)

Carry out a `mul` instruction, based on the current pointer and list of
values in the program. If the pointer is moved off the tape, returns a
halted program, otherwise returns the modified, running program.
"""
function mul!((; pointer, tape)::Computer)
    input1, input2, output = @view tape[(pointer+1):(pointer+3)]
    tape[output] = tape[input1] * tape[input2]
    pointer += 4
    state    = pointer >= length(tape) ? Halted : Running
    return Computer(state, pointer, tape)
end

"""
    exit!((; pointer, values)::Computer)

Halts the program.
"""
function exit!((; pointer, tape)::Computer)
    return Computer(Halted, pointer, tape)
end

"""
    execute!(program::Computer{Running})

Get the instruction at the current pointer location and run it, returning
a program that represents the state after running the next instruction.
"""
function execute!(program::Computer{Running})
    (; pointer, tape) = program
    fn = tape[pointer]
    fn == 1  && return add!(program)
    fn == 2  && return mul!(program)
    fn == 99 && return exit!(program)
end

"Halted programs don't do anything..."
execute!(program::Computer{Halted}) = program

"""
    run!(program::Computer)

Execute instructions until the program halts
"""
function run!(program::Computer)
    while program isa Computer{Running}
        program = execute!(program)
    end
    return program
end
end
