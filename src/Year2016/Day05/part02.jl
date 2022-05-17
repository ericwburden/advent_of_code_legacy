"""
    tryinsert!(v::AbstractVector, i::Int, c::Char)

Attempt to insert `c` into vector `v` at index `i`. Will not insert if
`i` is not a valid index for `v` or `i` is already occupied by a valid
hexadecimal digit.
"""
function tryinsert!(v::AbstractVector, i::Int, c::Char)
    if checkbounds(Bool, v, i) && !isxdigit(v[i])
        v[i] = c
    end
end

"""
    part2(input)

Given the input string, generate valid hashes, filling in the password field
one character at a time as described in the puzzle input until 8 password
characters have been produced.
"""
function part2(input)
    password = fill('X', 8)
    for hash in valid_hashes(input)
        position, char = (parse(Int, hash[6], base = 16) + 1, hash[7])
        tryinsert!(password, position, char)
        # print(" >>> $(join(password))\r")
        all(isxdigit, password) && return join(password)
    end
end
