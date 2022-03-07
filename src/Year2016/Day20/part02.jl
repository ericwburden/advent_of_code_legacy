"Overload length() for IPRanges"
Base.length((; low, high)::IPRange) = length(low:high)

"""
    part2(input)

Block all the IP's in the list of blocked ranges, then return the number of IP's
that are still allowed after all blocked ranges are blocked.
"""
function part2(input)
    allowed_ranges = find_allowed_ranges(input)
    return mapreduce(length, +, allowed_ranges)
end
