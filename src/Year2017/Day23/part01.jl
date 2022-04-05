"""
`Program`s represent the state of a program during execution, tracking the
values in each register, the current instruction number (as `pointer`), and
a debug dictionary that keeps track of how many times each type of instruction
is called.
"""
const Registers = Dict{Register,Int}
const Debug = Dict{Type{<:AbstractInstruction},Int}

mutable struct Program
    registers::Registers
    pointer::Int
    debug::Debug
end
Program() = Program(Registers(), 1, Debug())

"""
The underlying value of an `AbstractValue` can be obtained from the registers.
"""
valueof(P::Program, R::Register)::Int = get!(P.registers, R, 0)
valueof(::Program,  (; value)::Static)::Int  = value


"""
    execute!(program::Program, (; left, right)::Set)
    execute!(program::Program, (; left, right)::Sub)
    execute!(program::Program, (; left, right)::Mul)
    execute!(program::Program, (; input, jump)::Jnz)

Functions used to execute each type of instruction, modifying the state of the 
given program. Each function includes the logic (described in the puzzle input)
for modifying the program state correctly.
"""
function execute!(program::Program, (; left, right)::Set)
    program.registers[left] = valueof(program, right)
    program.pointer += 1
    program.debug[Set] = get!(program.debug, Set, 0) + 1
end

function execute!(program::Program, (; left, right)::Sub)
    program.registers[left] = valueof(program, left) - valueof(program, right)
    program.pointer += 1
    program.debug[Sub] = get!(program.debug, Sub, 0) + 1
end

function execute!(program::Program, (; left, right)::Mul)
    program.registers[left] = valueof(program, left) * valueof(program, right)
    program.pointer += 1
    program.debug[Mul] = get!(program.debug, Mul, 0) + 1
end

function execute!(program::Program, (; input, jump)::Jnz)
    program.pointer += valueof(program, input) != 0 ? valueof(program, jump) : 1
    program.debug[Jnz] = get!(program.debug, Jnz, 0) + 1
end

"""
    execute!(program::Program, instructions::Instructions)

If the program pointer is within the range of the passed instructions, 
execute the instruction pointed at and return `true`. Otherwise, return 
`false` to indicate that the program has fully executed.
"""
function execute!(program::Program, instructions::Instructions)
    1 <= program.pointer <= length(instructions) || return false
    current_instruction = instructions[program.pointer]
    execute!(program, current_instruction)
    return true
end

"""
    part1(input)

Given the input as a list of program instructions, execute the program to 
completion and return the number of times the `Mul` instruction is called.
"""
function part1(input)
    program = Program()
    while execute!(program, input) end
    return program.debug[Mul]
end
