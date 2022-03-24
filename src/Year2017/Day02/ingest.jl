"""
    ingest(path)

Given a path to the input file, parse each row into a vector of integers and
return a Matrix{Int} where each column is a row from the input file.
"""
function ingest(path)
    to_numbers(x) = parse.(Int, split(x))
    return mapreduce(to_numbers, hcat, readlines(path))
end
