# No real 'parsing' going on here, mostly just coding in the logic

# Treating the 'tape' as a set of Ints, representing the indices of '1' slots
const Tape = Set{Int}

abstract type AbstractState end
struct A <: AbstractState end
struct B <: AbstractState end
struct C <: AbstractState end
struct D <: AbstractState end
struct E <: AbstractState end
struct F <: AbstractState end

struct Cursor{S <: AbstractState}
    position::Int
    state::Type{S}
end
Cursor() = Cursor(0, A)

const STEPS = 12861455