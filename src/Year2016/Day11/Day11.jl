module Day11
using AdventOfCode: getinput

include("ingest.jl")
include("solve.jl")

export run
function run()
    answer1 = part1()
    answer2 = part2()

    println("\n    Day 11")
    println("    ├─ Part 01: $(answer1)")
    println("    └─ Part 02: $(answer2)")
end

end # module
