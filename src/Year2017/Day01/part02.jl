"""
    part2(input)

Given the input as a list of numbers, return the sum of all numbers where
the number is the same as the number that occurs exactly `n` numbers after it, 
where `n` is half the length of the input vector. Numbers in the second half
of the input are compared to numbers in the first half, as if the input vector
"wrapped around".
"""
function part2(input)
    shift = length(input) ÷ 2
    pairs = zip(input, circshift(input, -shift))
    return foldl(+, (l for (l, r) in pairs if l == r), init = 0)
end
