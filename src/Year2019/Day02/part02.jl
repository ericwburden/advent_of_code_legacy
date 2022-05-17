const MAGIC_VALUE = 19690720

"""
    part2(input)

Given the input as a list of numbers, replace values incrementally until the
value in memory address 0 after running the program equals the 'MAGIC_VALUE'.
Returns a number indicating which values yielded this result.
"""
function part2(input)
    for noun = 0:99, verb = 0:99
        values = deepcopy(input)
        program = Computer(values)
        program[1] = noun
        program[2] = verb
        run!(program)
        program[0] == MAGIC_VALUE || continue
        return (100 * noun) + verb
    end
    error("Could not generate $(MAGIC_VALUE)!")
end
