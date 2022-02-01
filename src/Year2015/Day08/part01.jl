"""
    part1(input)

Given the input as a vector of the lines from the input file, return the 
difference between the "raw" version of the file contents and the "parsed"
version.

The `Meta.parse` function from the `Meta` module essentially evaluates the raw
string from the input file into a parsed string, such that `\"abc\\x27\"`
becomes `"abc\x27"`.
"""
function part1(input)
    nrawchars    = mapreduce(length, +, input)
    nparsedchars = mapreduce(length ∘ Meta.parse, +, input)
    return nrawchars - nparsedchars
end
