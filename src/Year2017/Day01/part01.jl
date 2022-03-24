"""
    part1(input)

Given the input as a list of numbers, return the sum of all numbers where
the number is the same as the number that comes after it.
"""
function part1(input)
    pairs = zip(input, circshift(input, -1))
    return sum(l for (l, r) in pairs if l == r)
end
