"Represents the data about a Room, from the input"
struct RoomDesignation 
    encrypted_name::String
    sector_id::Int
    checksum::String
end

"""
    Base.parse(::Type{RoomDesignation}, s::String)

Parses a string into a `RoomDesignation`. Matches a line from the input against
a regular expression and identifies each part.
"""
function Base.parse(::Type{RoomDesignation}, s::String)
    re = r"^(?<name>[a-z-]+)-(?<id>\d+)\[(?<cs>\w+)\]$"
    m  = match(re, s)
    id = parse(Int, m["id"])
    return RoomDesignation(m["name"], id, m["cs"])
end

"""
    ingest(path)

Given a path to the input file, parse each line into a `RoomDesignation` and
return the resulting list.
"""
function ingest(path)
    rooms = RoomDesignation[]
    open(path) do f
        for line in eachline(f)
            push!(rooms, parse(RoomDesignation, line))
        end
    end
    return rooms
end
