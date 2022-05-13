# Include path for testing in the REPL
# include("src/Year2019/IntCode.jl")

using .IntCode: Computer, Running, Halted, add_input!, get_output!, run!

"Read a comma-separated list of numbers"
ingest(path) = parse.(Int, split(readline(path), ","))
