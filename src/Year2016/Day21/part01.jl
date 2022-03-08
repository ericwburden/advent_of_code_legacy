const PASSWORD = "abcdefgh"

"""
    part1(input)

Given the input as a list of functions that perform in place transformations of
a Char vector, apply each transformation to the input password and return the
result.
"""
function part1(input)
    chars = collect(PASSWORD)
    for fn in input
        fn(chars)
    end
    return join(chars)
end
