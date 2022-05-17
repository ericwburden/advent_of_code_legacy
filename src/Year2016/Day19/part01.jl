"""
    msb(v::UInt)

Given an unsigned integer, return an unsigned integer with only the most 
significant bit of `v` set.
"""
function msb(v::UInt32)
    max_bit = (sizeof(v) * 8) - 1 |> UInt
    check_bit = UInt(2)^max_bit
    while check_bit > 1
        v & check_bit > 0 && break
        check_bit >>= 1
    end
    return check_bit
end

"""
    josephus_number(n::UInt)

Given a number `n`, return the 'Josephus Number' indicating which place in a 
circular present-stealing squad will get all the presents. Explanation for
this can be found here: https://www.youtube.com/watch?v=uCsD3ZGzMgE
"""
function josephus_number(n::UInt32)
    no_msb = n & ~msb(n)
    shifted = no_msb << 1
    return shifted | UInt(1)
end

"Return the Josephus Number as an integer"
part1(input) = josephus_number(input) |> Int
