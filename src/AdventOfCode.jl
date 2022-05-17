module AdventOfCode

# Utility function used by all puzzles to get the canonical path
# to the input files
inputdirpath = normpath(joinpath(@__FILE__, "..", "..", "inputs"))
getinput(y, d, fn) = joinpath(inputdirpath, "$y", lpad(d, 2, "0"), "$fn.txt")
export getinput

# Bring all Year modules into scope
const YEARMODRE = r"Year\d{4}/Year\d{4}.jl$"
for (root, _, files) in walkdir(@__DIR__)
    for file in files
        filepath = joinpath(root, file)
        if occursin(YEARMODRE, filepath)
            include(filepath)
        end
    end
end

end # module
