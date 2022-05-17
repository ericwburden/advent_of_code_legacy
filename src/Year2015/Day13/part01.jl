using Combinatorics

# Helper functions for working with the AdjacencyMatrix
Base.keys(a::AdjacencyMatrix) = keys(a.keys)
people(a::AdjacencyMatrix) = keys(a) |> collect
Combinatorics.permutations(a::AdjacencyMatrix) = people(a) |> permutations

"""
    happiness(adjacency_matrix::AdjacencyMatrix, p1::String, p2::String)

Return the total change in happiness when two people are seated next to
one another at the table.
"""
function happiness(adjacency_matrix::AdjacencyMatrix, p1::String, p2::String)
    p1_idx = get(adjacency_matrix.keys, p1, nothing)
    isnothing(p1_idx) && error("$p1 is not an entry!")

    p2_idx = get(adjacency_matrix.keys, p2, nothing)
    isnothing(p2_idx) && error("$p2 is not an entry!")

    cost1 = adjacency_matrix.values[p1_idx, p2_idx]
    isnothing(cost1) && error("There is no edge between $p1 and $p2")

    cost2 = adjacency_matrix.values[p2_idx, p1_idx]
    isnothing(cost2) && error("There is no edge between $p2 and $p1")

    return cost1 + cost2
end

"""
    happiness(adjacency_matrix::AdjacencyMatrix, people::Vector{String})

Given an adjacency matrix and a vector of person names, return the total
happiness of the table if each adjacent person is seated in the order
of `people`.
"""
function happiness(adjacency_matrix::AdjacencyMatrix, people::Vector{String})
    howhappy((p1, p2)) = happiness(adjacency_matrix, p1, p2)
    seating = zip(people, circshift(people, -1))
    return mapreduce(howhappy, +, seating)
end

"""
    part1(input)

Given an adjacency matrix, calculate the total happiness for the entire table
for each possible seating arrangement and return the maximum happiness achieved.
"""
function part1(input)
    howhappy(people) = happiness(input, people)
    return mapreduce(howhappy, max, permutations(input))
end
