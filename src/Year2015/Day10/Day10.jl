module Day10
using AdventOfCode: getinput

include("solve.jl")

export run
function run()
    answer1 = solve(input, 40)
    answer2 = solve(input, 50)

    println("\n    Day 10")
    println("    ├─ Part 01: $(answer1)")
    println("    └─ Part 02: $(answer2)")
end

end # module
