"""
    ProgramState(pointer::Int, registers::Dict{Char,Int})

Represents the current state of the program, including a `pointer` to the 
current line and the value in each register.
"""
const Registers = Dict{Char,Int}
mutable struct ProgramState
    pointer::Int
    registers::Registers
end
ProgramState() = ProgramState(1, Registers('a' => 0, 'b' => 0))


"""
    execute!((; register)::Half, state::ProgramState)
    execute!((; register)::Triple, state::ProgramState)
    execute!((; register)::Increment, state::ProgramState)
    execute!((; offset)::Jump, state::ProgramState)
    execute!((; register, offset)::JumpIfEven, state::ProgramState)
    execute!((; register, offset)::JumpIfEven, state::ProgramState)

Execute an instruction according to the puzzle description.
"""
function execute!((; register)::Half, state::ProgramState)
    state.pointer += 1
    state.registers[register] ÷= 2
end

function execute!((; register)::Triple, state::ProgramState)
    state.pointer += 1
    state.registers[register] *= 3
end

function execute!((; register)::Increment, state::ProgramState)
    state.pointer += 1
    state.registers[register] += 1
end

function execute!((; offset)::Jump, state::ProgramState)
    state.pointer += offset
end

function execute!((; register, offset)::JumpIfEven, state::ProgramState)
    if state.registers[register] |> iseven 
        state.pointer += offset
    else
        state.pointer += 1
    end
end

function execute!((; register, offset)::JumpIfOne, state::ProgramState)
    if state.registers[register] == 1
        state.pointer += offset
    else
        state.pointer += 1
    end
end

"""
    run_program!(state::ProgramState, instructions::Instructions)

Run each instruction, modifying the program state as appropriate, until the
program attempts to run a line outside the bounds of the instructions.
"""
const Instructions = Vector{AbstractInstruction}
function run_program!(state::ProgramState, instructions::Instructions)
    while checkbounds(Bool, instructions, state.pointer)
        instruction = instructions[state.pointer]
        execute!(instruction, state)
    end
end


"""
    part1(input)

Given the input as a vector of `AbstractInstruction`s, run the instructions
starting from a default program state and return the value in register 'b' when
the program terminates.
"""
function part1(input)
    program = ProgramState()
    run_program!(program, input)
    return program.registers['b']
end
