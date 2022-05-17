"Represents a network packet"
const Packet = @NamedTuple{dest::Int, x::Int, y::Int}

"""
A `NetworkComputer` represents one of the computers on the network with
it's incoming packet list
"""
mutable struct NetworkComputer
    incoming::Vector{Packet}
    computer::Computer
end

"""
    NetworkComputer(address::Int, program::Vector{Int}) -> NetworkComputer

'Boot up' a new network computer at the given `address`, running the given
program.   
"""
function NetworkComputer(address::Int, program::Vector{Int})
    computer = Computer(program)
    add_input!(computer, address)
    computer = run!(computer)
    return NetworkComputer(Packet[], computer)
end

"""
    produce_packets!((; incoming, computer)::NetworkComputer) -> (NetworkComputer, Packet[])

Have a `NetworkComputer` pass information from all incoming packets to input, in
order, then run the computer until all the incoming packets are processed,
collecting all the produced outgoing packets to be delivered to other computers.
"""
function produce_packets!((; incoming, computer)::NetworkComputer)
    isempty(incoming) && add_input!(computer, -1)
    for (; x, y) in incoming
        add_input!(computer, x)
        add_input!(computer, y)
    end

    computer = run!(computer)

    packets = Packet[]
    while !isempty(computer.output)
        dest = get_output!(computer)
        x = get_output!(computer)
        y = get_output!(computer)
        push!(packets, (dest = dest, x = x, y = y))
    end
    return (NetworkComputer(Packet[], computer), packets)
end

"""
    part1(input) -> BigInt

Spin up 50 network computers and run the network, passing packets round robin
style until one of the computers tries to send a packet to address 255. Return
the `y` value from that packet.
"""
function part1(input)
    computers = map(addr -> NetworkComputer(addr, input), 0:49)

    @label cycle

    for (address, computer) in zip(0:49, computers)
        computer, packets = produce_packets!(computer)
        computers[address+1] = computer

        for packet in packets
            packet.dest == 255 && return packet.y
            recipient = computers[packet.dest+1]
            push!(recipient.incoming, packet)
        end
    end

    @goto cycle
end
