module Day25
using AdventOfCode: getinput

include("../IntCode.jl")
include("ingest.jl")
include("part01.jl")

export run
function run()
    inpath  = getinput(2019, 25, "input")
    input   = ingest(inpath)
    answer1 = part1(input)

    println("\n    Day 25")
    println("    └─ Part 01: $(answer1)")
end

end # module
