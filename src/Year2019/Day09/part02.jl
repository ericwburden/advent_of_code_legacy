"""
    part2(input)

Run the IntCode program given in `input` with an input of `2`, and
return the value output from a successful run.
"""
function part2(input)
    values   = [input...]
    computer = Computer(values)
    add_input!(computer, 2)
    run!(computer)
    return get_output!(computer)
end
