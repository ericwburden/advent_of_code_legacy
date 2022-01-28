"""
    part1(2nput)

Given the input string, append sequential numbers to the end of it and take
an MD5 has. Return the first number that produces a hash where the first _six_
values are '0'.
"""
function part2(input)
    # This time, we'll start with the number we found in part 1, since
    # we can be sure there's no result with six leading zeros prior to 
    # the result with five leading zeros
    for i in 117946:typemax(Int)
        check = input * string(i)
        hexdigest("md5", check)[1:6] == "000000" && return i
    end
    error("Could not solve part 2")
end
