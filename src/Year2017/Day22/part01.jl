"Overloaded functions for changing the heading of a `Carrier` to turn right"
turn_right((; position, heading)::Carrier{North}) = Carrier(position, East)
turn_right((; position, heading)::Carrier{East}) = Carrier(position, South)
turn_right((; position, heading)::Carrier{South}) = Carrier(position, West)
turn_right((; position, heading)::Carrier{West}) = Carrier(position, North)

"Overloaded functions for changing the heading of a `Carrier` to turn left"
turn_left((; position, heading)::Carrier{North}) = Carrier(position, West)
turn_left((; position, heading)::Carrier{East}) = Carrier(position, North)
turn_left((; position, heading)::Carrier{South}) = Carrier(position, East)
turn_left((; position, heading)::Carrier{West}) = Carrier(position, South)

"Overloaded functions for moving a `Carrier` forward"
forward((; position, heading)::Carrier{North}) = Carrier(position .+ (-1, 0), heading)
forward((; position, heading)::Carrier{East}) = Carrier(position .+ (0, 1), heading)
forward((; position, heading)::Carrier{South}) = Carrier(position .+ (1, 0), heading)
forward((; position, heading)::Carrier{West}) = Carrier(position .+ (0, -1), heading)

"""
    burst!(nodes::InfectedNodes, carrier::Carrier)

Make the carrier take a single turn, as described by the puzzle instructions. 
"""
function burst!(nodes::InfectedNodes, carrier::Carrier)
    new_infection = false
    if carrier.position ∈ nodes
        carrier = turn_right(carrier)
        delete!(nodes, carrier.position)
    else
        carrier = turn_left(carrier)
        push!(nodes, carrier.position)
        new_infection = true
    end
    return (forward(carrier), new_infection)
end

"""
    part1(input)

Given the input as a tuple of a carrier and set of infected nodes, make the
carrier take 10K turns, and return the number of nodes infected (or re-infected).
"""
function part1(input)
    new_infections = 0
    carrier, infected_nodes = deepcopy(input)
    for _ = 1:10_000
        carrier, new_infection = burst!(infected_nodes, carrier)
        new_infections += new_infection ? 1 : 0
    end
    return new_infections
end
