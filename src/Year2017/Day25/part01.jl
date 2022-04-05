"Friendly abstraction around writing values to the tape"
function write!(tape::Tape, value::Int, position::Int)
    value > 1  && error("Can only write value '0' or '1'!")
    value < 0  && error("Can only write value '0' or '1'!")
    value == 1 && push!(tape, position)
    value == 0 && delete!(tape, position)
end

"Friendly abstraction around getting values from the tape"
function value_at(tape::Tape, position::Int)
    return position ∈ tape ? 1 : 0
end

"""
    step!(tape::Tape, (; position)::Cursor)

These functions encapsulate the logic described by the input, writing values
and moving the cursor around. Each one modifies the tape and returns the new
cursor state.
"""
function step!(tape::Tape, (; position)::Cursor{A})
    if value_at(tape, position) == 0
        write!(tape, 1, position)
        return Cursor(position + 1, B)
    end
    if value_at(tape, position) == 1
        write!(tape, 0, position)
        return Cursor(position - 1, B)
    end
end

function step!(tape::Tape, (; position)::Cursor{B})
    if value_at(tape, position) == 0
        write!(tape, 1, position)
        return Cursor(position - 1, C)
    end
    if value_at(tape, position) == 1
        write!(tape, 0, position)
        return Cursor(position + 1, E)
    end
end

function step!(tape::Tape, (; position)::Cursor{C})
    if value_at(tape, position) == 0
        write!(tape, 1, position)
        return Cursor(position + 1, E)
    end
    if value_at(tape, position) == 1
        write!(tape, 0, position)
        return Cursor(position - 1, D)
    end
end

function step!(tape::Tape, (; position)::Cursor{D})
    if value_at(tape, position) == 0
        write!(tape, 1, position)
        return Cursor(position - 1, A)
    end
    if value_at(tape, position) == 1
        write!(tape, 1, position)
        return Cursor(position - 1, A)
    end
end

function step!(tape::Tape, (; position)::Cursor{E})
    if value_at(tape, position) == 0
        write!(tape, 0, position)
        return Cursor(position + 1, A)
    end
    if value_at(tape, position) == 1
        write!(tape, 0, position)
        return Cursor(position + 1, F)
    end
end

function step!(tape::Tape, (; position)::Cursor{F})
    if value_at(tape, position) == 0
        write!(tape, 1, position)
        return Cursor(position + 1, E)
    end
    if value_at(tape, position) == 1
        write!(tape, 1, position)
        return Cursor(position + 1, A)
    end
end

"""
Solve the puzzle by creating a new tape and cursor, then stepping the cursor
through the required amount of times and returning the number of 'on' bits
on the `tape`.
"""
function part1()
    tape, cursor  = Tape(), Cursor()
    foreach(_ -> cursor = step!(tape, cursor), 1:STEPS)
    return length(tape)
end