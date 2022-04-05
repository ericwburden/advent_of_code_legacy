module Day25
using AdventOfCode: getinput

include("ingest.jl")
include("part01.jl")

export run
function run()
    answer1 = part1()

    println("\n    Day 25")
    println("    ├─ Part 01: $(answer1)")
    println("    └─ Part 02: $(answer2)")
end

end # module
