"""
    ingest(path)

Given the path to the input file, parse each line as an integer and return
the list of integers.
"""
function ingest(path)
    open(path) do f
        parse.(Int, eachline(f))
    end
end
