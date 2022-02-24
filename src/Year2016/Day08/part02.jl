"""
    part2(input)

Given the input as a list of `Instruction`s, apply all the instructions to a
'screen' of the appropriate size and print a representation of the screen to
the console. This representation should resemble the characters displayed on
the 'screen'
"""
function part2(input)
    screen = falses(6, 50)
    process_instructions!(screen, input)
    for row in eachrow(screen)
        for light in row
            if (light) print("█") else print(" ") end
        end
        println()
    end
end
