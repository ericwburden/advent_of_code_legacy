"""
`AbstractProgram`s represent the state of a program during execution. Part 2 
uses a different type of program with different execution behavior, 
necessitating the abstract type.

A `SoundProgram` represents the program described in part 1, tracking the
values in each register, the current instruction number (as `pointer`), the 
value of the last sound produces, and a list of the recovered frequencies.
"""
const Registers = Dict{Register,Int}

abstract type AbstractProgram end

mutable struct SoundProgram <: AbstractProgram
    registers::Registers
    pointer::Int
    last_sound::Union{Int,Nothing}
    recovered::Vector{Int}
end
SoundProgram() = SoundProgram(Dict(), 1, nothing, [])

"""
For any `AbstractProgram`, the underlying value of an `AbstractValue` can
be obtained with the registers.
"""
valueof(state::AbstractProgram, register::Register)::Int =
    get!(state.registers, register, 0)
valueof(::AbstractProgram, (; value)::Static)::Int = value

"""
    execute!(state::SoundProgram, (; freq)::Sound)
    execute!(state::SoundProgram, (; left, right)::Set)
    execute!(state::SoundProgram, (; left, right)::Add)
    execute!(state::SoundProgram, (; left, right)::Mul)
    execute!(state::SoundProgram, (; left, right)::Mod)
    execute!(state::SoundProgram, (; input)::Recover)
    execute!(state::SoundProgram, (; input, jump)::Jgz)

Functions used to execute each type of instruction, modifying the state of the 
given program. Each function includes the logic (described in the puzzle input)
for modifying the program state correctly.
"""
function execute!(state::SoundProgram, (; freq)::Sound)
    state.last_sound = valueof(state, freq)
    state.pointer += 1
end

function execute!(state::SoundProgram, (; left, right)::Set)
    state.registers[left] = valueof(state, right)
    state.pointer += 1
end

function execute!(state::SoundProgram, (; left, right)::Add)
    state.registers[left] = valueof(state, left) + valueof(state, right)
    state.pointer += 1
end

function execute!(state::SoundProgram, (; left, right)::Mul)
    state.registers[left] = valueof(state, left) * valueof(state, right)
    state.pointer += 1
end

function execute!(state::SoundProgram, (; left, right)::Mod)
    state.registers[left] = valueof(state, left) % valueof(state, right)
    state.pointer += 1
end

function execute!(state::SoundProgram, (; input)::Recover)
    state.pointer += 1
    valueof(state, input) == 0 && return
    push!(state.recovered, state.last_sound)
end

function execute!(state::SoundProgram, (; input, jump)::Jgz)
    state.pointer += valueof(state, input) > 0 ? valueof(state, jump) : 1
end

"""
    part1(instructions)

Given the set of instructions parsed from the input file, execute the 
instructions until a frequency is recovered and return that frequency.
"""
function part1(instructions)
    state = SoundProgram()

    # The program may loop, so stop checking after the first 
    # frequency is recovered.
    while length(state.recovered) == 0
        current_instruction = instructions[state.pointer]
        execute!(state, current_instruction)
    end

    return first(state.recovered)
end
