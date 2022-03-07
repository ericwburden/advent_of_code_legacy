"""
    part2(input)

Given the input as a BitVector where 1's represent traps, determine the 
next 400,000 rows and return the count of traps in all rows.
"""
function part2(input)
    take_400k(xs)   = Iterators.take(xs, 400_000)
    count_safe(row) = count(x -> !x, row)
    return (iterated(next_row, input)
        |> take_400k
        |> (x -> mapreduce(count_safe, +, x)))
end