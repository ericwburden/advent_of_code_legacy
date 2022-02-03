#=------------------------------------------------------------------------------
| Data structure used to represent the input as a directed graph of the
| input in the format PERSON -|happiness delta|-> PERSON
------------------------------------------------------------------------------=#

struct AdjacencyMatrix
    keys::Dict{String,Int}
    values::Matrix{Union{Nothing,Int}}
end

AdjacencyMatrix(s::Int) = AdjacencyMatrix(Dict(), fill(nothing, s, s))

"Add a person-person relationship to the Adjacency Matrix"
function add!(c::AdjacencyMatrix, v::Tuple{String,String,Int})
    leftidx  = get!(c.keys, v[1], length(c.keys)+1)
    rightidx = get!(c.keys, v[2], length(c.keys)+1)
    c.values[leftidx, rightidx] = v[3]
end

"Regular expression for parsing the input lines"
const INPUT_RE = r"^(?<p1>\w+).*(?<change>gain|lose)\s(?<happy>\d+).*\s(?<p2>\w+)\.$"

"""
    ingest(path)

Given a path to the input file, parse each line into a pair of entries in 
an adjacency matrix. 
"""
function ingest(path)
    adjacency_matrix = AdjacencyMatrix(9)
    open(path) do f
        for line in eachline(f)
            m = match(INPUT_RE, line)
            p1, p2, change = string.((m["p1"], m["p2"], m["change"]))
            happy = parse(Int, m["happy"])
            if change == "lose" happy *= -1 end
            add!(adjacency_matrix, (p1, p2, happy))
        end
    end
    return adjacency_matrix
end
