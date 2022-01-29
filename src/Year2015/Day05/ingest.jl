"""
    ingest(path)

Given the path to the input file, parse the contents into a vector of `String`s,
one string per line.
"""
function ingest(path)
    open(path) do f
        f |> eachline |> collect
    end
end
