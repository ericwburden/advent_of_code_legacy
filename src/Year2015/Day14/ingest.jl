"""
Represents a reindeer for the purposes of this puzzle, with the following
fields:
    - name::String - The reindeer's name
    - speed::Int - The reindeer's running speed
    - runtime::Int - How long the reindeer can run at a time (seconds)
    - resttime::Int - How long the reindeer must rest between runs (seconds)
"""
struct Reindeer
    name::String
    speed::Int
    runtime::Int
    resttime::Int
end

"Regular expression for parsing a line of the input file"
const INPUT_RE = r"^(?<name>\w+)\D*(?<speed>\d+)\D*(?<run>\d+)\D+(?<rest>\d+)"

"""
    ingest(path)

Given the path to the input file, read lines from the file and parse each one
into a `Reindeer`, returning a vector of `Reindeer` as the result.
"""
function ingest(path)
    reindeer = []
    open(path) do f
        for line in eachline(f)
            m = match(INPUT_RE, line)
            name = string(m["name"])
            (speed, run, rest) = parse.(Int, (m["speed"], m["run"], m["rest"]))
            push!(reindeer, Reindeer(name, speed, run, rest))
        end
    end
    return reindeer
end
