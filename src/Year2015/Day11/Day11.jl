module Day11

include("solve.jl")

export run
function run()
    answer1 = solve(input)
    answer2 = solve(answer1)

    println("\n    Day 11")
    println("    ├─ Part 01: $(answer1)")
    println("    └─ Part 02: $(answer2)")
end

end # module
