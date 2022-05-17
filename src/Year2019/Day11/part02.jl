"""
    part2(input::Vector{Int}, printint:Bool) -> String

If `printit` is false, just return the string found through visual inspection.
Otherwise, run the program painting the ship panels, and print to console a 
visual representation of the painted panels that makes the shape of the
string painted by the robot.
"""
function part2(input, printit = false)
    printit || return "BLCZCJLZ"

    # This code prints an ASCII image of the code to the console
    panels = paint(input, White())
    minpos, maxpos = extrema(keys(panels))
    for row = minpos[1]:maxpos[1]
        for col = minpos[2]:maxpos[2]
            pixel::Int = get(panels, (row, col), 0)
            pixel == 0 && print(' ')
            pixel == 1 && print('■')
        end
        println()
    end
end
