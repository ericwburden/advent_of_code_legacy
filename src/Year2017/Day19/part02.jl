"""
    part2(input)

Given the input as a character matrix, convert the character matrix to a
`NetworkMap`, find the starting space, then move a packet from the first
space to the final space it can reach. Return the total number of steps
taken to get to the final space.
"""
function part2(input)
    network_map = convert(NetworkMap, input)
    start_index = find_start(network_map)
    packet = NetworkPacket(South, start_index, Char[], 0)
    packet = travel(network_map, packet)
    return packet.steps
end