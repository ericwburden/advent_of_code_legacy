using DataStructures: Queue, enqueue!, dequeue!

"""
    undirected!(orbits::Dict{String,Vector{String}}) -> Dict{String,Vector{String}}

Given a directed adjacency list of orbits, convert it to an undirected adjacency
list, that is. for each pair of key and values, add an entry for the key to each
value.
"""
function undirected!(orbits::Dict{String,Vector{String}})
    for (key, values) in orbits
        for value in values
            current = get!(orbits, value, [])
            push!(current, key)
        end
    end
end

"""
    part2(input) -> Int

Given the directed adjacency list from the input, convert it to an undirected
adjacency list and perform a BFS to find the shortest path from "YOU" to 
"SAN" and return that value (minus two to adjust for orbital hops).
"""
function part2(input)
    queue  = Queue{String}()
    enqueue!(queue, "YOU")
    steps  = Dict("YOU" => 0)
    undirected!(input)

    while !isempty(queue)
        current = dequeue!(queue)
        current == "SAN" && break
        
        for neighbor in get(input, current, [])
            neighbor ∈ keys(steps) && continue
            steps[neighbor] = steps[current] + 1
            enqueue!(queue, neighbor)
        end
    end

    # Subtract 2 since we want the distance from the objects
    # we are orbiting
    return steps["SAN"] - 2
end
