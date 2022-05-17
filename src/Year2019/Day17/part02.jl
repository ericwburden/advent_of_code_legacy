# These instructions were derived by hand, by printing out the image
# of the scaffolding from `robot_output()` and tracing the path through
const RAW_INSTRUCTIONS = [
    "A,C,A,B,A,C,B,A,C,B", # Main Routine
    "R,12,R,4,R,10,R,12",  # Function A
    "L,8,R,4,R,4,R,6",     # Function B
    "R,6,L,8,R,10",        # Function C
    "n",                   # Interactive Mode?
    "",                     # Extra newline
]

"""
    part2(input) -> Int

Given the input program, run the cleaning robot, passing in the instructions
that will cause it to navigate to the end of the scaffolding, touching every
space along the way. Return the amount of dust collected (?) as the robot
makes this epic journey.
"""
function part2(input)
    # Parse instructions to ASCII integer codes
    instruction_chars = collect(join(RAW_INSTRUCTIONS, "\n"))
    parsed_instructions = [Int(c) for c in instruction_chars]

    # Initialize the computer, set memory address 0 to `2`
    # add instruction values to input, and run 
    computer = Computer(input)
    computer[0] = 2
    foreach(i -> add_input!(computer, i), parsed_instructions)
    computer = run!(computer)

    # Take the last value from output
    output = nothing
    while !isempty(computer.output)
        output = string(get_output!(computer))
    end

    return parse(Int, output)
end
