"More handy type aliases"
const InstructionKindSet = Set{AnyAbstractInstructionKind}
const OpcodeMap          = Dict{Int,AnyAbstractInstructionKind}

"""
    decode_opcodes(samples::Vector{SampleOperation})

Given a list of sample operations, identify and return a mapping of opcodes
to the appropriate `AnyAbstractInstructionKind`.
"""
function decode_opcodes(samples::Vector{SampleOperation})
    # Start by assuming each opcode can be any of the `AnyAbstractInstructionKind`s,
    # then check each sample operation to seek which kinds satisfy the example.
    # For each set of `AnyAbstractInstructionKind`s that do satisfy the example,
    # narrow the list of possibilies by eliminating the kinds of operations that
    # do not satisfy the example.
    possible_opcodes = Dict{Int,InstructionKindSet}()
    for sample_operation in samples
        opcode            = sample_operation.instruction[1]
        possible_kinds    = possible_instruction_kinds(sample_operation)
        current_possibles = get!(possible_opcodes, opcode, possible_kinds)
        possible_opcodes[opcode] = intersect!(current_possibles, possible_kinds)
    end

    # Given this initial set of possibilities, reduce the set of possible
    # kinds of instruction per opcode until each opcode only refers to
    # a single kind of instruction.
    while any(s -> length(s) > 1, values(possible_opcodes))
        reduce_possibilities!(possible_opcodes)
    end

    # Just converts the Dict{Int,InstructionKindSet} to a 
    # Dict{Int,AnyAbstractInstructionKind}
    decoded_opcodes = OpcodeMap()
    for (opcode, possibilities) in pairs(possible_opcodes)
        decoded_opcodes[opcode] = only(possibilities)
    end

    return decoded_opcodes
end

"""
    reduce_possibilities!(possible_opcodes::Dict{Int,InstructionKindSet})

Uses 'process of elimination' to reduce the sets of possible kinds of operations
per opcode in `possible_opcodes`. Any opcode that is positively identified (its
set only contains one kind of operation) is kept, and the kind of operation it
refers to is removed from all other opcode possible kinds of operations.
"""
function reduce_possibilities!(possible_opcodes::Dict{Int,InstructionKindSet})
    identified_set = reduce(∪, s for s in values(possible_opcodes) if length(s) == 1)
    for (opcode, possibilities) in pairs(possible_opcodes)
        length(possibilities) == 1 && continue
        possible_opcodes[opcode] = setdiff(possibilities, identified_set)
    end
end

"""
    identify_instruction(opcode_map::OpcodeMap, instruction::Instruction)

Use the mapping of opcodes to kind of operation to convert an `Instruction`
to a `CodedInstruction`.
"""
function identify_instruction(opcode_map::OpcodeMap, instruction::Instruction)
    opcode = instruction[1]
    kind   = opcode_map[opcode]
    return CodedInstruction(kind, instruction)
end

"""
    part2(input)

Given the input as a tuple of sample operations and list of unidentified
instructions, decode the opcodes using the sample operations, identify 
the kinds of the unidentified instructions, run the newly identified 
instructions against a set of `Registers` initialized to `0`, and return
the final value in the first register.
"""
function part2(input)
    sample_operations, sample_program = input
    opcode_map = decode_opcodes(sample_operations)
    instructions = [identify_instruction(opcode_map, i) for i in sample_program]
    registers    = Registers(zeros(Int, 4))
    for instruction in instructions
        registers = execute(instruction, registers)
    end
    return first(registers)
end
