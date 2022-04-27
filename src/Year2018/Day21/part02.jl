"""
    part2(input)

Given the input as a tuple containing the initial program state and list of
instructions, run the program until it halts, and record the value stored in
`MAGIC_REGISTER`. Restart the program, running it until it halts again,
continuing this process and recording the value that halts the program each
time until a repeating value is found. Return the last unique value that 
halts the program. 

NOTE: This process is >>SLOW<<. I should probably reverse engineer the ElfCode
and re-write it in Julia, but as of the moment I have completed this puzzle, I
don't feel like it. The function will complete, but it takes a couple of
minutes.
"""
function part2(input)
    program, instructions = input
    seen_magic_values = OrderedSet{Int}()
    magic_value = 0

    while magic_value ∉ seen_magic_values
        push!(seen_magic_values, magic_value)

        while program.state == Running
            program = execute(instructions, program)
        end

        (; pointer, bind, registers) = program
        magic_value = get_value(registers, MAGIC_REGISTER)

        # Restart the program
        program = Program(Running, pointer, bind, registers)
    end

    return last(seen_magic_values)
end

