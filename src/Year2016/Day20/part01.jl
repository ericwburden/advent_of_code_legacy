"""
    AllowedRange(low::Int, high::Int) <: IPRange

Represents a range of allowed IP addresses.
"""
struct AllowedRange <: IPRange
    low::Int
    high::Int
end

AllowedRange() = AllowedRange(0, 4294967295)

"""
    block(allowed::AllowedRange, blocked::BlockedRange)

Given a range of allowed IP addresses and a range of blocked IP addresses, 
return one or more allowed ranges that remain after blocking the IP's in 
the blocked range.
"""
function block(allowed::AllowedRange, blocked::BlockedRange)
    # If the blocked range lies entirely inside the allowed range, split
    # the allowed range around the blocked range and return the pieces.
    if allowed.low < blocked.low && allowed.high > blocked.high
        return [
            AllowedRange(allowed.low, blocked.low - 1),
            AllowedRange(blocked.high + 1, allowed.high),
        ]
    end

    # If the blocked range completely engulfs the allowed range, then return
    # an empty list indicating no allowed range remains
    if blocked.low <= allowed.low && blocked.high >= allowed.high
        return []
    end

    # If the blocked range partially overlaps the allowed range, return the
    # range not covered by the blocked range
    if allowed.low <= blocked.high < allowed.high
        return [AllowedRange(blocked.high + 1, allowed.high)]
    end
    if allowed.low < blocked.low <= allowed.high
        return [AllowedRange(allowed.low, blocked.low - 1)]
    end

    # If the blocked range does not overlap the allowed range, just return
    # the allowed range.
    return [allowed]
end

"""
    find_allowed_ranges(blocked_ranges::Vector{BlockedRange})

Starting with the full range of allowed IP addresses, given a list of ranges to
block, block the IP's from the `blocked_ranges` until all the blocked IP's are
removed from the list of allowed ranges. Returns a list of allowed ranges.
"""
function find_allowed_ranges(blocked_ranges::Vector{BlockedRange})
    allowed_ranges = [AllowedRange()]

    for blocked_range in blocked_ranges
        block_range(r) = block(r, blocked_range)
        allowed_ranges = Iterators.flatten(map(block_range, allowed_ranges))
    end

    return collect(allowed_ranges)
end

"""
    part1(input)

Block all the ranges indicated by the input and return the smallest IP that is
not blocked.
"""
function part1(input)
    allowed_ranges = find_allowed_ranges(input)
    return first(allowed_ranges).low
end
