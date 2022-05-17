"""
    part2(input)

Given the input as a list of numbers, create an IntCode computer with
the values as the program. Set the input of the computer to `5` and 
run the program to completion. Return the diagnostic code: the only
value output.
"""
function part2(input)
    values = [input...]
    computer = Computer(values)
    add_input!(computer, 5)
    run!(computer)
    return get_output!(computer)
end
