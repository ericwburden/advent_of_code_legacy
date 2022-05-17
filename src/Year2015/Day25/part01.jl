"Convert a row/col index to a linear index in the order of insertion"
toindex(row::Int, col::Int) = (((row + col)^2 - (row + col)) ÷ 2) - row

"""
    part1(input = INPUT)

Calculate the value at a given row/column index based on the process
described in the puzzle. The process described in the text is essentially
[modular exponentiation](https://en.wikipedia.org/wiki/Modular_exponentiation),
where the sequence with which the value is placed into the list serves as 
the exponent, reduced by one to account for 0-indexing vs 1-indexing. The 
other values used in this calculation are given.
"""
function part1(input = INPUT)
    row, col = input
    first_code = 20151125
    base = 252533
    mod_by = 33554393
    exponent = toindex(row, col)
    return (powermod(base, exponent, mod_by) * first_code) % mod_by
end
