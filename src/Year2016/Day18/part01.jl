using IterTools: iterated

"Given a row of semi-trapped tiles, return the next row"
next_row(row::BitVector) = (row << 1) .⊻ (row >> 1)

"""
    part1(input)

Given the input as a BitVector where 1's represent traps, determine the 
next 40 rows and return the count of traps in all rows.
"""
function part1(input)
    take_40(xs)     = Iterators.take(xs, 40)
    count_safe(row) = count(x -> !x, row)
    return (iterated(next_row, input)
        |> take_40
        |> (x -> mapreduce(count_safe, +, x)))
end
