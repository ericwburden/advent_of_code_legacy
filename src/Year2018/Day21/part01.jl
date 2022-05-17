using DataStructures: OrderedSet

const MAGIC_POINTER = 28
const MAGIC_REGISTER = 5

"Sets a value at an index in a `Registers`"
function set_register(r::Registers, i::Int, v::Int)
    # Not to self: NO ALLOCATIONS!!!
    return NTuple{6}(idx - 1 == i ? v : val for (idx, val) in enumerate(r))
end

"Get a value at an index in a `Registers`"
function get_value(r::Registers, i::Int)
    return r[i+1]
end


"""
Each `execute` takes a `Instruction` and a set of `Registers` and produces
a new set of `Registers` with the instruction applied.

Addition:

- addr (add register) stores into register C the result of adding register A
  and register B.
- addi (add immediate) stores into register C the result of adding register
  A and value B.
"""
function execute((; input1, input2, output)::Instruction{ADDR}, r::Registers)
    a = get_value(r, input1)
    b = get_value(r, input2)
    return set_register(r, output, a + b)
end

function execute((; input1, input2, output)::Instruction{ADDI}, r::Registers)
    a = get_value(r, input1)
    b = input2
    return set_register(r, output, a + b)
end

"""
Multiplication:

- mulr (multiply register) stores into register C the result of multiplying
  register A and register B.
- muli (multiply immediate) stores into register C the result of multiplying
  register A and value B.
"""
function execute((; input1, input2, output)::Instruction{MULR}, r::Registers)
    a = get_value(r, input1)
    b = get_value(r, input2)
    return set_register(r, output, a * b)
end

function execute((; input1, input2, output)::Instruction{MULI}, r::Registers)
    a = get_value(r, input1)
    b = input2
    return set_register(r, output, a * b)
end

"""
Bitwise AND:

- banr (bitwise AND register) stores into register C the result of the
  bitwise AND of register A and register B.
- bani (bitwise AND immediate) stores into register C the result of the
  bitwise AND of register A and value B.
"""
function execute((; input1, input2, output)::Instruction{BANR}, r::Registers)
    a = get_value(r, input1)
    b = get_value(r, input2)
    return set_register(r, output, a & b)
end

function execute((; input1, input2, output)::Instruction{BANI}, r::Registers)
    a = get_value(r, input1)
    b = input2
    return set_register(r, output, a & b)
end

"""
Bitwise OR:

- borr (bitwise OR register) stores into register C the result of the
  bitwise OR of register A and register B.
- bori (bitwise OR immediate) stores into register C the result of the
  bitwise OR of register A and value B.
"""
function execute((; input1, input2, output)::Instruction{BORR}, r::Registers)
    a = get_value(r, input1)
    b = get_value(r, input2)
    return set_register(r, output, a | b)
end

function execute((; input1, input2, output)::Instruction{BORI}, r::Registers)
    a = get_value(r, input1)
    b = input2
    return set_register(r, output, a | b)
end

"""
Assignment:

- setr (set register) copies the contents of register A into register C.
  (Input B is ignored.)
- seti (set immediate) stores value A into register C. (Input B is ignored.)
"""
function execute((; input1, output)::Instruction{SETR}, r::Registers)
    a = get_value(r, input1)
    return set_register(r, output, a)
end

function execute((; input1, output)::Instruction{SETI}, r::Registers)
    a = input1
    return set_register(r, output, a)
end

"""
Greater-than testing:

- gtir (greater-than immediate/register) sets register C to 1 if value A is
  greater than register B. Otherwise, register C is set to 0.
- gtri (greater-than register/immediate) sets register C to 1 if register A
  is greater than value B. Otherwise, register C is set to 0.
- gtrr (greater-than register/register) sets register C to 1 if register A
  is greater than register B. Otherwise, register C is set to 0.
"""
function execute((; input1, input2, output)::Instruction{GTIR}, r::Registers)
    a = input1
    b = get_value(r, input2)
    return set_register(r, output, a > b ? 1 : 0)
end

function execute((; input1, input2, output)::Instruction{GTRI}, r::Registers)
    a = get_value(r, input1)
    b = input2
    return set_register(r, output, a > b ? 1 : 0)
end

function execute((; input1, input2, output)::Instruction{GTRR}, r::Registers)
    a = get_value(r, input1)
    b = get_value(r, input2)
    return set_register(r, output, a > b ? 1 : 0)
end

"""
Equality testing:

- eqir (equal immediate/register) sets register C to 1 if value A is equal
  to register B. Otherwise, register C is set to 0.
- eqri (equal register/immediate) sets register C to 1 if register A is equal
  to value B. Otherwise, register C is set to 0.
- eqrr (equal register/register) sets register C to 1 if register A is equal
  to register B. Otherwise, register C is set to 0.
"""
function execute((; input1, input2, output)::Instruction{EQIR}, r::Registers)
    a = input1
    b = get_value(r, input2)
    return set_register(r, output, a == b ? 1 : 0)
end

function execute((; input1, input2, output)::Instruction{EQRI}, r::Registers)
    a = get_value(r, input1)
    b = input2
    return set_register(r, output, a == b ? 1 : 0)
end

function execute((; input1, input2, output)::Instruction{EQRR}, r::Registers)
    a = get_value(r, input1)
    b = get_value(r, input2)
    return set_register(r, output, a == b ? 1 : 0)
end


"""
    execute(instructions::Instructions, program::Program)

Given the current state of the `Program`, identify and execute the next instruction
in sequence, updating the pointer and bound pointer register as described in the
puzzle description. If the program state indicates an instruction outside the bounds
of the instructions, return a `Halted` program.

Also halts the program at the instruction that, upon inspection of the ElfCode, would
cause the program to halt based on the value in register `0`. 
"""
function execute(instructions::Instructions, (; pointer, bind, registers)::Program)
    0 <= pointer < length(instructions) || return Program(Halted, pointer, bind, registers)
    registers = set_register(registers, bind, pointer)
    instruction = instructions[pointer+1]  # 1-indexing
    registers = execute(instruction, registers)
    pointer = get_value(registers, bind) + 1

    # Halts on this instruction every time. 
    pointer == MAGIC_POINTER && return Program(Halted, pointer, bind, registers)

    return Program(Running, pointer, bind, registers)
end

"""
    part1(input)

Given the input as a tuple containing the initial program state and list of
instructions, run the program until it halts and report the value that, if 
present in register `0`, would have caused the program to halt naturally.
"""
function part1(input)
    program, instructions = input
    while program.state == Running
        program = execute(instructions, program)
    end
    return get_value(program.registers, MAGIC_REGISTER)
end
