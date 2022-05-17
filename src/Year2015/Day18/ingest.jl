# Helper functions for parsing the input
linelights(s::String) = [c == '#' for c in s]
tolights(v) = mapreduce(linelights, hcat, v) |> transpose

"""
    ingest(path)

Given the path to the input file, parse each line into a BitVector, with `true`
values corresponding to the character '#' in the input, then `hcat` all the
BitVectors into a BitMatrix. Returns the BitMatrix
"""
function ingest(path)
    open(path) do f
        return eachline(f) |> tolights |> BitMatrix
    end
end
