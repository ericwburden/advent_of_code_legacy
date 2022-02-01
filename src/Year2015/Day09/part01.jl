using Combinatorics

# Helper functions for working with the AdjacencyMatrix
Base.keys(a::AdjacencyMatrix) = keys(a.keys)
stops(a::AdjacencyMatrix) = keys(a) |> collect
Combinatorics.permutations(a::AdjacencyMatrix) = stops(a) |> permutations

"""
    distance(adjacency_matrix::AdjacencyMatrix, start::String, stop::String)

Return the distance between two destinations in the AdjacencyMatrix
"""
function distance(adjacency_matrix::AdjacencyMatrix, start::String, stop::String)
    startidx = get(adjacency_matrix.keys, start, nothing)
    stopidx  = get(adjacency_matrix.keys, stop, nothing)
    
    isnothing(startidx) && error("$start is not an entry!")
    isnothing(stopidx)  && error("$stop is not an entry!")
    
    cost = adjacency_matrix.values[startidx, stopidx]
    isnothing(cost) && error("There is no edge between $start and $stop")

    return cost
end

"""
    triplength(adjacency_matrix::AdjacencyMatrix, stops::Vector{String})

Given an adjacency matrix and a vector of destination names, return the total
length of the trip if each destination is visited in order.
"""
function triplength(adjacency_matrix::AdjacencyMatrix, stops::Vector{String})
    dist((start, stop)) = distance(adjacency_matrix, start, stop)
    trips = zip(stops, stops[2:end])
    return mapreduce(dist, +, trips)
end

"""
    part1(input)

Given an adjacency matrix, calculate the distance traveled for each permutation
of the destinations and return the shortest path length.
"""
function part1(input)
    route(p) = triplength(input, p)
    return mapreduce(route, min, permutations(input))
end
