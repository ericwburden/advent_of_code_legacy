module Day21
using AdventOfCode: getinput

include("ingest.jl")
include("part01.jl")
include("part02.jl")

export run
function run()
    inpath = getinput(2017, 21, "input")
    input = ingest(inpath)
    answer1 = part1(input)
    answer2 = part2(input)

    println("\n    Day 21")
    println("    ├─ Part 01: $(answer1)")
    println("    └─ Part 02: $(answer2)")
end

end # module
