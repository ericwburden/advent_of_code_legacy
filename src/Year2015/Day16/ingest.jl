"""
    AuntSue(number::Int, compounds::Dict{Symbol,Int})

Struct to store the known data related to each of the 500 Aunts "Sue". Contains
the numeric designation and the known quantities of each "compound" associated
with each aunt.
"""
struct AuntSue
    number::Int
    compounds::Dict{Symbol,Int}
end

"""
    compoundpair(s::AbstractString)

Given a string in the format "<name>: <amount>", return a Pair{Symbol,Int} where
the <name> is represented by a Symbol and the <amount> is represented by an Int.
"""
function compoundpair(s::AbstractString)
    (name, value) = split(s, ": ")
    return Symbol(name) => parse(Int, value)
end

"""
    ingest(path)

Given a path to the input file, parse each line into an `AuntSue` and return the
list of parsed structs.
"""
function ingest(path)
    aunts = []
    open(path) do f
        for line in eachline(f)
            (sue, compounds) = split(line, ": ", limit=2)
            suenumber = parse(Int, filter(isdigit, sue))

            (suecompounds
                =  compounds
                |> (x -> split(x, ", "))
                |> (x -> map(compoundpair, x))
                |> Dict)

            push!(aunts, AuntSue(suenumber, suecompounds))
        end
    end
    return aunts
end
