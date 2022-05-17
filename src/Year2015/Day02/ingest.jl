"""
    Box

Represents a box for the elves to wrap. `l`, `w`, and `h` are the dimensions
of the box. This struct satisfies the constraints `l` >= `w` >= `h`.
"""
struct Box
    l::Int
    w::Int
    h::Int

    function Box(l, w, h)
        l >= w >= h || error("Arguments do not satisfy $l >= $w >= $h")
        return new(l, w, h)
    end
end

"""
    parse(Box, s::String)

Parses a string in the format of "<Int>x<Int>x<Int>" into a Box
"""
function Base.parse(::Type{Box}, s::String)
    nums = parse.(Int, split(s, 'x'))
    sort!(nums)
    return Box(nums[3], nums[2], nums[1])
end


"""
    ingest(path)

Given the path to the input file, parse lines of the format "<Int>x<Int>x<Int>"
into `Box` data structures, containing the length, width, and height of the
`Box`. The length is always the longest side.
"""
function ingest(path)
    boxes = []
    open(path) do f
        for line in eachline(f)
            push!(boxes, parse(Box, line))
        end
    end
    return boxes
end
