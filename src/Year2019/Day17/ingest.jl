# Include path for testing in the REPL
# include("src/Year2019/IntCode.jl")

using .IntCode: Computer, Running, Halted, add_input!, get_output!, run!

"Read a comma-separated list of numbers"
ingest(path) = parse.(Int, split(readline(path), ","))

"""
    robot_output(input) -> String

Given the input ASCII program, run it and return a string containing
all the output, converted from ASCII codes to characters.
"""
function robot_output(input)
    computer = Computer(input)
    computer = run!(computer)
    output = ""
    while !isempty(computer.output)
        char = get_output!(computer)
        output *= Char(char)
    end
    return output
end

"""
    scaffolds(input) -> Matrix{Char}

Given the input ASCII program, run it and return a character matrix
derived from the output, representing the shape of the scaffolding.
"""
function scaffolds(input)
    output = robot_output(input)
    lines = filter(l -> !isempty(l), split(output, "\n"))
    row(s) = reshape(collect(s), 1, :)
    return mapreduce(row, vcat, lines)
end
