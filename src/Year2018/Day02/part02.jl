"""
    is_similar(a::AbstractString, b::AbstractString)

Indicates whether two strings differ by more than one character.
"""
is_similar(x::Tuple{AbstractString,AbstractString}) = is_similar(x...)
function is_similar(a::AbstractString, b::AbstractString)
    diffs = 0
    for (c₁, c₂) in zip(a, b)
        if (c₁ != c₂) diffs += 1 end
        diffs > 1 && return false
    end
    return true
end

"""
    same_chars(a::AbstractString, b::AbstractString)

Given two strings, return a string containing the matching characters between
the two.
"""
same_chars(x::Tuple{AbstractString,AbstractString}) = same_chars(x...)
function same_chars(a::AbstractString, b::AbstractString)
    (zip(a, b)
        |> (x -> Iterators.filter(c -> c[1] == c[2], x))
        |> (x -> map(first, x))
        |> join)
end

"""
    part2(input)

Given the input as a list of strings, sort the input and check each pair
of sequential strings to find a pair that differs by only one character, then
return a string containing the matching characters between those two strings.
"""
function part2(input)
    sort!(input)
    (result
        =  zip(input, input[2:end])
        |> (x -> Iterators.filter(is_similar, x))
        |> first
        |> same_chars)
    return result
end
