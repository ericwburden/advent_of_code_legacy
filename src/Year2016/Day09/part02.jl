"""
    lengthv2((; text)::RegularText)
    lengthv2((; marker, text)::CompressedText)

Calculate the length of `Tokens` as described in part two of the puzzle. The 
length of `CompressedText` is calculated recursively to account for nested
compression.
"""
lengthv2((; text)::RegularText) = length(text)
function lengthv2((; marker, text)::CompressedText)
    tokens = tokenize(text)
    return mapreduce(lengthv2, +, tokens) * marker.reps
end

"""
    part2(input)

Given the input as a compressed string, tokenize the compressed string and
determine how long the uncompressed string would be as described in part two
of the puzzle.
"""
function part2(input)
    tokens = tokenize(input)
    return mapreduce(lengthv2, +, tokens)
end
