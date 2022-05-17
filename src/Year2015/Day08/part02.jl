"""
    encode(s::String)

Given a string, "encode" it according to the puzzle instructions, escaping all
backslashes (and whatever they escaped before) and adding an escaped quote to 
the beginning and end of the string.
"""
function encode(s::String)
    escaped = replace(s, "\"" => "\\\"", "\\" => "\\\\")
    return "\"" * escaped * "\""
end

"""
    part2(input)

Given the input as a vector of the lines from the input file, return the 
difference between the "raw" version of the file contents and the "encoded"
version.
"""
function part2(input)
    ncodeunits = mapreduce(length, +, input)
    nencodedchars = mapreduce(length ∘ encode, +, input)
    return nencodedchars - ncodeunits
end
