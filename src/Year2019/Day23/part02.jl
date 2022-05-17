"Detect when a `NetworkComputer` is idle by empty incoming packet queues"
is_idle((; incoming)::NetworkComputer) = isempty(incoming)

"""
    part2(input) -> BigInt

Spin up 50 network computers and run the network, passing packets round robin
style. Every time a packet is sent to address `255`, if the network is otherwise
idle, check the packet to see if it's `y` value has been seen before. If so, 
return it, otherwise pass the packet to the computer at address `0` to kick
the network back into action.
"""
function part2(input)
    computers = map(addr -> NetworkComputer(addr, input), 0:49)
    resume_y_vals = Set{Int}()

    @label cycle

    for (address, computer) in zip(0:49, computers)
        computer, packets = produce_packets!(computer)
        computers[address+1] = computer

        for packet in packets
            if packet.dest == 255
                all(is_idle, computers) || continue
                packet.y ∈ resume_y_vals && return packet.y
                push!(computers[1].incoming, packet)
                push!(resume_y_vals, packet.y)
                continue
            end

            recipient = computers[packet.dest+1]
            push!(recipient.incoming, packet)
        end
    end

    @goto cycle
end
