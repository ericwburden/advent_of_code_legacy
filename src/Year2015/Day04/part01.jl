using Nettle

"""
    part1(input)

Given the input string, append sequential numbers to the end of it and take
an MD5 has. Return the first number that produces a hash where the first five
values are '0'.
"""
function part1(input)
    for i in 1:typemax(Int)
        check = input * string(i)
        hexdigest("md5", check)[1:5] == "00000" && return i
    end
    error("Could not solve part 1")
end
