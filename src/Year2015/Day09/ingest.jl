#=------------------------------------------------------------------------------
| Data structure used to represent the input as an undirected graph of the
| input in the format START <-|cost|-> STOP
------------------------------------------------------------------------------=#

struct AdjacencyMatrix
    keys::Dict{String,Int}
    values::Matrix{Union{Nothing,Int}}
end

AdjacencyMatrix(s::Int) = AdjacencyMatrix(Dict(), fill(nothing, s, s))

"Add a start/stop pair to the Adjacency Matrix"
function add!(c::AdjacencyMatrix, v::Tuple{String,String,Int})
    leftidx  = get!(c.keys, v[1], length(c.keys)+1)
    rightidx = get!(c.keys, v[2], length(c.keys)+1)
    c.values[leftidx, rightidx] = v[3]
end

"Regular expression for parsing the input lines"
const INPUT_RE = r"^(?<left>\w+) to (?<right>\w+) = (?<cost>\d+)"

"""
    ingest(path)

Given a path to the input file, parse each line into a pair of entries in 
an adjacency matrix. Including both entries to represent an undirected graph.
"""
function ingest(path)
    adjacency_matrix = AdjacencyMatrix(8)
    open(path) do f
        for line in eachline(f)
            m = match(INPUT_RE, line)
            left  = string(m["left"])
            right = string(m["right"])
            cost  = parse(Int, m["cost"])
            add!(adjacency_matrix, (left, right, cost))
            add!(adjacency_matrix, (right, left, cost))
        end
    end
    return adjacency_matrix
end
