"""
    part2(input)

Given the input as a vector of `AbstractInstruction`s, run the instructions
starting from a default program state (with register 'a' set to 1) and return
the value in register 'b' when the program terminates.
"""
function part2(input)
    program = ProgramState(1, Registers('a' => 1, 'b' => 0))
    run_program!(program, input)
    return program.registers['b']
end
