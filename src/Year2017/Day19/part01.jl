"""
`AbstractHeading` is a blanket type for the four cardinal directions, with
`VerticalHeading` acting as a supertype for `North` and `South`, while 
`HorizontalHeading` acts as a supertype for `East` and `West`. These types 
are used to indicate which direction the network packet is currenting moving
and which directions are available at a junction.
"""
abstract type AbstractHeading end

abstract type VerticalHeading   <: AbstractHeading end
abstract type HorizontalHeading <: AbstractHeading end

struct North <: VerticalHeading   end
struct East  <: HorizontalHeading end
struct South <: VerticalHeading   end
struct West  <: HorizontalHeading end


"""
`AbstractPath` is a supertype for all the spaces in a map of the network, 
including empty spaces, single-direction paths, junctions (for turning), and
path spaces that contain a letter.

A `Junction` is a path space where the packet changes direction, turning
either to the left or the right.
"""
abstract type AbstractPath end

struct EmptySpace  <: AbstractPath end
struct ForwardPath <: AbstractPath end
struct LetterPath  <: AbstractPath letter::Char end

struct Junction{V<:VerticalHeading,H<:HorizontalHeading} <: AbstractPath
    vertical::Type{V}
    horizontal::Type{H}
end

const NetworkMap = Matrix{AbstractPath}

"""
A `Chunk` is a set of five values representing the spaces centered on a single
index in a character matrix and the characters found in each of the four
immediately adjacent spaces (in each cardinal direction). This allows conversion
from a character matrix to a matrix of `AbstractPath` structs, needed
because the available directions at a junction depend on the characters 
adjacent to that junction space.
"""
struct Chunk
    center::Char
    north::Char
    east::Char
    south::Char
    west::Char
end

function chunk_at(chars::Matrix{Char}, idx::CartesianIndex)
    center = chars[idx]
    offsets = map(i -> idx + CartesianIndex(i), [(-1, 0), (0, 1), (1, 0), (0, -1)])
    north, south, east, west = [get(chars, o, ' ') for o in offsets]
    return Chunk(center, north, south, east, west)
end

function Base.convert(::Type{AbstractPath}, chunk::Chunk)
    chunk.center == ' ' && return EmptySpace()
    chunk.center == '|' && return ForwardPath()
    chunk.center == '-' && return ForwardPath()
    chunk.center == '+' && return convert(Junction, chunk)
    isletter(chunk.center) && return LetterPath(chunk.center)
    error("Cannot convert $chunk to an `AbstractPath`")
end

function Base.convert(::Type{Junction}, chunk::Chunk)
    # Indicates whether there is a path character in each cardinal direction
    north_path = chunk.north == '|' || isletter(chunk.north)
    east_path  = chunk.east  == '-' || isletter(chunk.east)
    south_path = chunk.south == '|' || isletter(chunk.south)
    west_path  = chunk.west  == '-' || isletter(chunk.west)

    # We trust that each junction only has two adjacent path characters
    north_path && east_path && return Junction(North, East)
    north_path && west_path && return Junction(North, West)
    south_path && east_path && return Junction(South, East)
    south_path && west_path && return Junction(South, West)

    error("Cannot convert $chunk to a `Junction`")
end

function Base.convert(::Type{NetworkMap}, chars::Matrix{Char})
    network_map::NetworkMap = fill(EmptySpace(), size(chars))
    for idx in CartesianIndices(chars)
        chars[idx] == ' ' && continue
        chunk = chunk_at(chars, idx)
        network_map[idx] = convert(AbstractPath, chunk)
    end
    return network_map
end


"""
A `NetworkPacket` represents the packet as it moves through the network and 
keeps track of the number of steps taken and the letters encountered, in order.
"""
struct NetworkPacket{H<:AbstractHeading}
    heading::Type{H}
    position::CartesianIndex
    letters::Vector{Char}
    steps::Int
end

"""
Given a `NetworkPacket` and, optionally, a letter, move the packet one more
index in the direction of its current heading. If a letter is provided, add
that letter to the list of encountered letters.
"""
function move_forward(
    (; heading, position, letters, steps)::NetworkPacket,
    letter::Union{Nothing,Char}=nothing
)
    new_position = if heading isa Type{North}
        position + CartesianIndex(-1, 0)
    elseif heading isa Type{East}
        position + CartesianIndex(0, 1)
    elseif heading isa Type{South}
        position + CartesianIndex(1, 0)
    elseif heading isa Type{West}
        position + CartesianIndex(0, -1)
    end
    !isnothing(letter) && push!(letters, letter)
    return NetworkPacket(heading, new_position, letters, steps + 1)
end

"""
Given a heading and a `NetworkPacket`, adjust the packet's heading and move
it forward one space in the new direction.
"""
function turn_packet(new_heading, (; heading, position, letters, steps)::NetworkPacket)
    turned_packet = NetworkPacket(new_heading, position, letters, steps)
    return move_forward(turned_packet)
end

"""
These numerous `step` functions are responsible for moving a `NetworkPacket`
through the `NetworkMap`, based on the current space of the `NetworkPacket`. 
`ForwardPath`s just move the packet forward in the direction it is facing, 
`LetterPath`s do the same while adding a letter to the packet's list of 
encountered letters, and `Junction`s change the packet's direction before
moving it along.
"""
step(N::NetworkMap, P::NetworkPacket)                      = step(N[P.position], P)
step(::ForwardPath, packet::NetworkPacket)                 = move_forward(packet)
step((; letter)::LetterPath, packet::NetworkPacket)        = move_forward(packet, letter)

step(::Junction{North,East}, packet::NetworkPacket{South}) = turn_packet(East, packet)
step(::Junction{North,East}, packet::NetworkPacket{West})  = turn_packet(North, packet)
step(::Junction{North,West}, packet::NetworkPacket{South}) = turn_packet(West, packet)
step(::Junction{North,West}, packet::NetworkPacket{East})  = turn_packet(North, packet)
step(::Junction{South,East}, packet::NetworkPacket{North}) = turn_packet(East, packet)
step(::Junction{South,East}, packet::NetworkPacket{West})  = turn_packet(South, packet)
step(::Junction{South,West}, packet::NetworkPacket{North}) = turn_packet(West, packet)
step(::Junction{South,West}, packet::NetworkPacket{East})  = turn_packet(South, packet)

"""
    travel(network_map::NetworkMap, packet::NetworkPacket)

Moves the `NetworkPacket` forward until it lands on an `EmptySpace` and
return the final state of the packet.
"""
function travel(network_map::NetworkMap, packet::NetworkPacket)
    while !(network_map[packet.position] isa EmptySpace)
        packet = step(network_map, packet)
    end
    return packet
end

"""
    find_start(network_map::NetworkMap)

Find the only `ForwardPath` space in the top row of the `NetworkMap` and 
return its cartesian index.
"""
function find_start(network_map::NetworkMap)
    start_col = findfirst(x -> x isa ForwardPath, network_map[1, :])
    return CartesianIndex(1, start_col)
end

"""
    part1(input)

Given the input as a character matrix, convert the character matrix to a
`NetworkMap`, find the starting space, then move a packet from the first
space to the final space it can reach. Return the letters encountered along
the way as a string.
"""
function part1(input)
    network_map = convert(NetworkMap, input)
    start_index = find_start(network_map)
    packet = NetworkPacket(South, start_index, Char[], 0)
    packet = travel(network_map, packet)
    return join(packet.letters)
end
