"""
An `AbstractNodeState` represents one of the states of a node described 
in part 2 of the puzzle instructions.
"""
abstract type AbstractNodeState end
struct Clean <: AbstractNodeState end
struct Weakened <: AbstractNodeState end
struct Infected <: AbstractNodeState end
struct Flagged <: AbstractNodeState end

const NodeStates = Dict{Tuple{Int,Int},AbstractNodeState}

"""
    convert(::Type{NodeStates}, nodes::InfectedNodes)

Convert a set of infected nodes to a dictionary of node states.
"""
function Base.convert(::Type{NodeStates}, nodes::InfectedNodes)
    node_states = NodeStates()
    for node in nodes
        node_states[node] = Infected()
    end
    return node_states
end

"Overloaded functions for reversing the heading of a `Carrier` to turn right"
reverse((; position, heading)::Carrier{North}) = Carrier(position, South)
reverse((; position, heading)::Carrier{East}) = Carrier(position, West)
reverse((; position, heading)::Carrier{South}) = Carrier(position, North)
reverse((; position, heading)::Carrier{West}) = Carrier(position, East)

"""
    burst_v2!(nodes::InfectedNodes, carrier::Carrier)

Make the carrier take a single turn, as described by the (part 2) puzzle
instructions. 
"""
function burst_v2!(node_states::NodeStates, carrier::Carrier)
    new_infection = false
    node_state = get!(node_states, carrier.position, Clean())
    if node_state == Clean()
        carrier = turn_left(carrier)
        node_states[carrier.position] = Weakened()
    elseif node_state == Weakened()
        node_states[carrier.position] = Infected()
        new_infection = true
    elseif node_state == Infected()
        carrier = turn_right(carrier)
        node_states[carrier.position] = Flagged()
    elseif node_state == Flagged()
        carrier = reverse(carrier)
        node_states[carrier.position] = Clean()
    else
        error("Unreachable!")
    end
    return (forward(carrier), new_infection)
end

"""
    part2(input)

Given the input as a tuple of a carrier and set of infected nodes, make the
carrier take 10M turns, and return the number of nodes infected (or re-infected).
"""
function part2(input)
    new_infections = 0
    carrier, infected_nodes = deepcopy(input)
    node_states = convert(NodeStates, infected_nodes)
    for _ = 1:10_000_000
        carrier, new_infection = burst_v2!(node_states, carrier)
        new_infections += new_infection ? 1 : 0
    end
    return new_infections
end
