# SpringScript derived by hand (gross!) that will run the SpringBot
const WALKSCRIPT = [
    "NOT A J", # If there is a hole one spot away, J -> TRUE, else J -> FALSE
    "NOT B T", # If there is a hole two spots away, J -> TRUE, else J -> FALSE
    "AND D T", # Set T -> TRUE if there is a hole four spots away 
    "OR T J",  # Set J -> TRUE if either J or T are TRUE, otherwise FALSE
    "NOT C T", # Set T -> TRUE if there is a hole three spots away
    "OR T J",  # Set J -> TRUE if either J or T are TRUE, otherwise FALSE
    "AND D J", # If there is ground four spots away and J == TRUE, set J -> TRUE
    "WALK",    # Execute the program
    ""         # Empty final line
]

"""
    hull_damage(input, script) -> Int

Given an IntCode program as `input` and a SpringScript as `script`, initialize
an IntCode computer with `input`, pass in the `script` as computer input, then
have the computer run the script and return the final output, which represents
the amount of hull damage detected by the SpringBot.
"""
function hull_damage(input, script)
    computer = Computer(input)
    for char in collect(join(script, "\n"))
        add_input!(computer, Int(char))
    end
    computer = run!(computer)

    output = nothing
    while !isempty(computer.output)
        output = get_output!(computer)
    end
    return output
end

part1(input) = hull_damage(input, WALKSCRIPT)
