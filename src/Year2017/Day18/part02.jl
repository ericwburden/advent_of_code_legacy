using DataStructures: Queue, enqueue!, dequeue!

"""
`AsyncProgram`s hold the state needed to run the 'real' program described
in part 2. Instead of the last sound frequency and a list of recovered
frequencies, the program now keeps track of the number of messages sent
and its own incoming message queue.
"""
mutable struct AsyncProgram <: AbstractProgram
    registers::Registers
    pointer::Int
    send_count::Int
    message_queue::Queue{Int}
end
AsyncProgram(id::Int) = AsyncProgram(Dict(Register('p') => id), 1, 0, Queue{Int}())

"New instructions for `AsyncProgram`s"
struct Send <: AbstractInstruction
    value::AbstractValue
end
struct Receive <: AbstractInstruction
    register::AbstractValue
end

"""
`AbstractMessage`s represent the return values from executing an instruction, 
a message that can be passed to other `AsyncProgram`s. Messages communicate the
result of the instruction.
"""
abstract type AbstractMessage end

struct SendMsg <: AbstractMessage
    value::Int
end
struct BlockedMsg <: AbstractMessage end
struct ExitMsg <: AbstractMessage end
struct SuccessMsg <: AbstractMessage end


"""
    execute!(state::AsyncProgram, (; value)::Send)
    execute!(state::AsyncProgram, (; register)::Receive)
    execute!(state::AsyncProgram, (; left, right)::Set)
    execute!(state::AsyncProgram, (; left, right)::Add)
    execute!(state::AsyncProgram, (; left, right)::Mul)
    execute!(state::AsyncProgram, (; left, right)::Mod)
    execute!(state::AsyncProgram, (; input, jump)::Jgz)

Functions used to execute each type of instruction, modifying the state of the 
given program. Each function includes the logic (described in the puzzle input)
for modifying the program state correctly.

These versions are modified to return `AbstractMessage`s, in addition to the
`Send` and `Receive` instructions.
"""
function execute!(state::AsyncProgram, (; value)::Send)
    state.send_count += 1
    state.pointer += 1
    return SendMsg(valueof(state, value))
end

function execute!(state::AsyncProgram, (; register)::Receive)
    length(state.message_queue) > 0 || return BlockedMsg()
    state.registers[register] = dequeue!(state.message_queue)
    state.pointer += 1
    return SuccessMsg()
end

function execute!(state::AsyncProgram, (; left, right)::Set)
    state.registers[left] = valueof(state, right)
    state.pointer += 1
    return SuccessMsg()
end

function execute!(state::AsyncProgram, (; left, right)::Add)
    state.registers[left] = valueof(state, left) + valueof(state, right)
    state.pointer += 1
    return SuccessMsg()
end

function execute!(state::AsyncProgram, (; left, right)::Mul)
    state.registers[left] = valueof(state, left) * valueof(state, right)
    state.pointer += 1
    return SuccessMsg()
end

function execute!(state::AsyncProgram, (; left, right)::Mod)
    state.registers[left] = valueof(state, left) % valueof(state, right)
    state.pointer += 1
    return SuccessMsg()
end

function execute!(state::AsyncProgram, (; input, jump)::Jgz)
    state.pointer += valueof(state, input) > 0 ? valueof(state, jump) : 1
    return SuccessMsg()
end


"""
    execute!(program::AsyncProgram, instructions::Vector{AbstractInstruction})
    
Execute instructions against the `program` until either the program exits or
it is blocked by trying to read a message from an empty queue. Returns the number
of lines successfully executed and a list of outgoing messages to pass off to
another `AsyncProgram`.
"""
function execute!(program::AsyncProgram, instructions::Vector{AbstractInstruction})
    outgoing_messages = AbstractMessage[]
    lines_executed = 0

    # Execute instructions until the program is blocked or exits normally
    while 1 <= program.pointer <= length(instructions)
        message = execute!(program, instructions[program.pointer])
        push!(outgoing_messages, message)
        if message isa BlockedMsg
            return (lines_executed, outgoing_messages)
        else
            lines_executed += 1
        end
    end

    # If the program exited normally, add that message to the list 
    push!(outgoing_messages, ExitMsg())
    return (lines_executed, outgoing_messages)
end

const AsyncPrograms = Vector{AsyncProgram}

"""
    execute!(prog0::AsyncProgram, prog1::AsyncProgram, instructions::Instructions)

Given two `AsyncProgram`s and a set of instructions, have each program execute
instructions until each cannot continue, in turn. Pass messages between the
two programs, and return a value indicating whether any lines were successfully
executed.
"""
function execute!(prog0::AsyncProgram, prog1::AsyncProgram, instructions::Instructions)
    prog0_executed, incoming_messages = execute!(prog0, instructions)
    value_messages = filter(msg -> msg isa SendMsg, incoming_messages)
    foreach(msg -> enqueue!(prog1.message_queue, msg.value), value_messages)

    prog1_executed, incoming_messages = execute!(prog1, instructions)
    value_messages = filter(msg -> msg isa SendMsg, incoming_messages)
    foreach(msg -> enqueue!(prog0.message_queue, msg.value), value_messages)

    lines_executed = prog0_executed + prog1_executed

    return lines_executed > 0
end

"For updating the instructions to match the new spec"
update((; freq)::Sound) = Send(freq)
update((; input)::Recover) = Receive(input)
update(instr::AbstractInstruction) = instr


"""
    part2(input)

Given the set of instructions parsed from the input file, update this set
of instructions to reflect the part 2 understanding. Run this set of 
instructions against two separate programs until both exit, then return the
number of messages sent by the program with ID `1`.
"""
function part2(input)
    updated_instructions = update.(input)
    prog0, prog1 = AsyncProgram(0), AsyncProgram(1)
    while execute!(prog0, prog1, updated_instructions)
    end
    return prog1.send_count
end
