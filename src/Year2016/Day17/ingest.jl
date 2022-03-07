using Nettle

"Another single string input"
ingest(path) = readchomp(path)


#=------------------------------------------------------------------------------
| Although the input for today's puzzle is a single string, we're going to
| need a data structure to represent the floor map of fixed walls and doors.
| We'll represent each room as a 4-bit value, where 1's represent walls and 
| 0's represent doors, in the order up, down, left, right. For example, 
| `1001`, or `9`, will represent the top-left corner.
------------------------------------------------------------------------------=#
const FloorMap = Matrix{UInt8}

const FLOOR_MAP = [
    UInt8(10) UInt8(8) UInt8(8) UInt8(9)
    UInt8(2)  UInt8(0) UInt8(0) UInt8(1)
    UInt8(2)  UInt8(0) UInt8(0) UInt8(1)
    UInt8(6)  UInt8(4) UInt8(4) UInt8(5)
]

"""
    open_doors(room::UInt8, code::String)

Given a room representation as a UInt8 and the current code (plus path), return
a UInt8 that indicates which walls are open doors, if any. The 4 bits represent
walls and closed doors as 1's in the same pattern as the floor map: up, down,
left, and right.
"""
function open_doors(room::UInt8, code::String)
    first_four = hexdigest("md5", code)[1:4]
    place      = 3

    for char in first_four
        if (char ∉ "bcdef") room |= UInt8(2^place) end
        place -= 1
    end

    return room
end