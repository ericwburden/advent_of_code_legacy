"""
    ingest(path)

Given the path to the input file, parse a single line consisting of only the
characters '(' and ')' into a vector such that each instance of '(' is 
represented by `1` and each instance of ')' is represented by `-1`.
"""
function ingest(path)
    instructions = []
    open(path) do f
        while !eof(f)
            val = read(f, Char) == '(' ? 1 : -1
            push!(instructions, val)
        end
    end
    return instructions
end